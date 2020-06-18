`timescale 1ns / 1ps


module cpu_pipeline(    
    input clk,			
    input rst,          
    output [31:0] done,
    output [31:0] pc_out
    );

    reg [31:0]   pc, 

                IF_ID_npc,
                IF_ID_ir,

                ID_EX_a, 
                ID_EX_b, 
                ID_EX_imm, 
                ID_EX_ir,

                EX_MEM_y,
                EX_MEM_b,

                MEM_WB_mdr,
                MEM_WB_y;

    reg [4:0]   EX_MEM_wa,
                MEM_WB_wa;

    reg [2:0]   ID_EX_ex;//{RegDst,ALUOp1,ALUOp0}

    reg [1:0]   ID_EX_m,
                EX_MEM_m;//{MemRead,MemWrite}

    reg [1:0]   ID_EX_wb,
                EX_MEM_wb,
                MEM_WB_wb;//{RegWrite,MemtoReg}


    wire RegDst,MemRead,MemWrite,RegWrite,MemtoReg;
    wire [1:0] ALUOp,PCSrc;
    wire [2:0] ID_ex;
    wire [1:0] ID_m;
    wire [1:0] ID_wb;
    wire Zero,PC_IF_ID_Write;
    wire [1:0] ForwardA,ForwardB,BEQ_SrcA,BEQ_SrcB;
    wire [31:0] instr,mem_rd,rf_wd,rd1,rd2,alu_a,alu_b,alu_result;
    wire [31:0] SignExtendImm,SignExtendShiftImm,beq_a,beq_b;
    wire [4:0] rf_wa;
    wire [2:0] m;
    wire stall, IF_flush;
    wire [31:0] pc_in,pc_jump,pc_branch;

    dist_mem_gen_0 ROM
    (
        .a(pc[9:2]),
        .spo(instr)
    );

    dist_mem_gen_1 RAM
    (
        .a(EX_MEM_y),
        .d(EX_MEM_b),
        .clk(clk),
        .we(MemWrite),
        .spo(mem_rd)
    );

    register_file RF
    (
        .clk(clk),
        .rst(rst),
        .we(RegWrite),
        .ra1(IF_ID_ir[25:21]),
        .ra2(IF_ID_ir[20:16]),
        .ra3(9),
        .wa(MEM_WB_wa),
        .wd(rf_wd),
        .rd1(rd1),
        .rd2(rd2),
        .rd3(done)
    );

    alu ALU_EX
    (
        .a(alu_a),
        .b(alu_b),
        .y(alu_result),
        .m(m)
    );

    EX_forwarding_unit EX_FU
    (
        .op(ID_EX_ir[31:26]),
        .ID_EX_Rs(ID_EX_ir[25:21]),//rs
        .ID_EX_Rt(ID_EX_ir[20:16]),//rt
        .EX_MEM_Rd(EX_MEM_wa),
        .MEM_WB_Rd(MEM_WB_wa),
        .EX_MEM_wb(EX_MEM_wb),
        .MEM_WB_wb(MEM_WB_wb),
        .ForwardA(ForwardA),
        .ForwardB(ForwardB)
    );

    ID_forwarding_unit ID_FU
    (
        .IF_ID_Rs(IF_ID_ir[25:21]),
        .IF_ID_Rt(IF_ID_ir[20:16]),
        .EX_MEM_Rd(EX_MEM_wa),
        .MEM_WB_Rd(MEM_WB_wa),
        .EX_MEM_wb(EX_MEM_wb),
        .MEM_WB_wb(MEM_WB_wb),
        .BEQ_SrcA(BEQ_SrcA),
        .BEQ_SrcB(BEQ_SrcB)
    );

    control CTRL
    (
        .instr(IF_ID_ir),
        .Zero(Zero),
        .signal_wb(ID_wb),
        .signal_m(ID_m),
        .signal_ex(ID_ex),
        .flush(IF_flush),
        .PCSrc(PCSrc)
    );

    hazard_detection_unit HDU
    (
        .IF_ID_ir(IF_ID_ir),
        .ID_EX_ir(ID_EX_ir),
        .ID_EX_MemRead(ID_EX_m[1]),
        .ID_EX_RegWrite(ID_EX_wb[1]),
        .EX_MEM_MemRead(EX_MEM_m[1]),
        .EX_MEM_wa(EX_MEM_wa),
        .rf_wa(rf_wa),
        .PC_IF_ID_Write(PC_IF_ID_Write),
        .stall(stall)
    );

    alu_control ALU_CTRL
    (
        .ALUOp(ALUOp),
        .funct(ID_EX_ir[5:0]),
        .m(m)
    );
    
    assign RegDst = ID_EX_ex[2];
    assign ALUOp = ID_EX_ex[1:0];
    assign MemRead = EX_MEM_m[1];
    assign MemWrite = EX_MEM_m[0];
    assign RegWrite = MEM_WB_wb[1];
    assign MemtoReg = MEM_WB_wb[0];
    assign pc_out = pc;
    assign Zero = (beq_a == beq_b);
    assign alu_a = ForwardA[1] ?
            (ForwardA[0] ? 0 : EX_MEM_y) : (ForwardA[0] ? rf_wd : ID_EX_a);
    assign alu_b = ForwardB[1] ?
            (ForwardB[0] ? ID_EX_imm : EX_MEM_y) : (ForwardB[0] ? rf_wd : ID_EX_b);
    assign rf_wd = MemtoReg ? MEM_WB_mdr : MEM_WB_y;
    assign rf_wa = RegDst ? ID_EX_ir[15:11] : ID_EX_ir[20:16];
    assign pc_jump = {IF_ID_npc[31:28],IF_ID_ir[25:0],2'b00};
    assign SignExtendImm = {{16{IF_ID_ir[15]}},IF_ID_ir[15:0]};
    assign SignExtendShiftImm = {SignExtendImm[29:0],2'b00};
    assign pc_branch = SignExtendShiftImm + IF_ID_npc;
    assign pc_in = PCSrc[1] ?
            (PCSrc[0] ? 0: pc_jump) : (PCSrc[0] ? pc_branch: pc + 4);
    assign beq_a = BEQ_SrcA[1] ?
            (BEQ_SrcA[0] ? 0: EX_MEM_y) : (BEQ_SrcA[0] ? rf_wd: rd1);
    assign beq_b = BEQ_SrcB[1] ?
            (BEQ_SrcB[0] ? 0: EX_MEM_y) : (BEQ_SrcB[0] ? rf_wd: rd2);


    always@(posedge clk,posedge rst)
    begin
        if(rst)
        begin
            MEM_WB_wb <= 0;
            MEM_WB_mdr <= 0;
            MEM_WB_y <= 0;
            MEM_WB_wa <= 0;
            EX_MEM_wb <= 0;
            EX_MEM_m <= 0;
            EX_MEM_y <= 0;
            EX_MEM_wa <= 0;
            EX_MEM_b <= 0;
            ID_EX_wb <= 0;
            ID_EX_m <= 0;
            ID_EX_ex <= 0;
            ID_EX_a <= 0;
            ID_EX_b <= 0;
            ID_EX_imm <= 0;
            ID_EX_ir <= 0;
            IF_ID_npc <= 0;
            IF_ID_ir <= 0;
            pc <= 0;
        end
        else
        begin
            MEM_WB_wb <= EX_MEM_wb;
            MEM_WB_mdr <= mem_rd;
            MEM_WB_y <= EX_MEM_y;
            MEM_WB_wa <= EX_MEM_wa;
            EX_MEM_wb <= ID_EX_wb;
            EX_MEM_m <= ID_EX_m;
            EX_MEM_y <= alu_result;
            EX_MEM_wa <= rf_wa;
            EX_MEM_b <= alu_b;
            ID_EX_wb <= stall ? 2'b00 : ID_wb;
            ID_EX_m <= stall ? 2'b00 : ID_m;
            ID_EX_ex <= stall ? 3'b000 : ID_ex;
            ID_EX_a <= rd1;
            ID_EX_b <= rd2;
            ID_EX_imm <= SignExtendImm;
            ID_EX_ir <= IF_ID_ir;
            IF_ID_npc <= PC_IF_ID_Write ? pc + 4 : IF_ID_npc;
            
            if(stall)
                IF_ID_ir <= IF_ID_ir;
            else if(IF_flush) 
                IF_ID_ir <= 0;
            else 
                IF_ID_ir <= instr;
            pc <= PC_IF_ID_Write ? pc_in : pc;
        end
    end
endmodule