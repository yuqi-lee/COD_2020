`timescale 1ns / 1ps



module cpu_multi_cycle(	//多周期CPU
    input clk,			
    input rst,  
    output isIF,        
    output [31:0] done, 
    output [31:0] pc_out
    );

    // 状态机信号
    localparam  IF  = 4'b0000,
                ID  = 4'b0001,
                MAC = 4'b0010,
                MAL = 4'b0011,
                WB  = 4'b0100,
                MAS = 4'b0101,
                EX  = 4'b0110,
                RC  = 4'b0111,
                BC  = 4'b1000,
                JC  = 4'b1001,
                AIC = 4'b1010;
    
    //指令
    localparam  ADD    = 6'b000000,
                ADDI    = 6'b001000,
                LW      = 6'b100011,
                SW      = 6'b101011,
                BEQ     = 6'b000100,
                J       = 6'b000010;

    
    
    
    //内部信号
    reg PCwe,IorD,MemRead,MemWrite,MemtoReg,IRWrite,ALUSrcA,RegWrite,RegDst;
    reg [1:0] PCSource,ALUSrcB;
    reg [2:0] alu_m;
    reg [3:0] state,next_state;
    reg [32:0] pc,mdr,a,b,alu_out,instr;   
    wire zf;
    wire [31:0] pc_in,pc_jump,MemData;
    wire [31:0] rd1,rd2;
    wire [31:0] alu_result;
    wire [31:0] mem_addr;
    wire [31:0] wd_rf;
    wire [31:0] alu_a,alu_b;
    wire [4:0] wa_rf;
    wire [31:0] signed_extend_imm,s_e_shift_imm;
    
    
   
    
    
    dist_mem_gen_0 ram(
        .a(mem_addr[10:2]),
        .d(b),
        .clk(clk),
        .we(MemWrite),
        .spo(MemData),
        .dpra(2),
        .dpo(done)
        );
        
    register_file rf(
        .clk(clk),
        .rst(rst),
        .we(RegWrite),
        .ra1(instr[25:21]),
        .ra2(instr[20:16]),
        .wa(wa_rf),
        .wd(wd_rf),
        .rd1(rd1),
        .rd2(rd2)
        );

    alu ALU(
        .a(alu_a),
        .b(alu_b),
        .m(alu_m),
        .y(alu_result),
        .zf(zf)
        );

    assign isIF = (state == IF);
    assign mem_addr = IorD ? alu_out : pc;
    assign wa_rf = RegDst ? instr[15:11] : instr[20:16];
    assign wd_rf = MemtoReg ? mdr : alu_out;
    assign alu_a = ALUSrcA ? a : pc;
    assign alu_b = ALUSrcB[1] ? 
                (ALUSrcB[0] ? s_e_shift_imm : signed_extend_imm) : (ALUSrcB[0] ? 4 :b );
    assign pc_in = PCSource[1] ? 
                (PCSource[0] ? 0 : pc_jump) : (PCSource[0] ? alu_out : alu_result);
    assign pc_out = pc;
    assign signed_extend_imm = instr[15] ? {{16{1'b1}},instr[15:0]} : {{16{1'b0}},instr[15:0]};
    assign s_e_shift_imm = {signed_extend_imm[29:0],2'b00};
    assign pc_jump = {pc[31:28],instr[25:0],2'b00};

    always@(posedge clk,posedge rst)
    begin
        if(rst)
        begin
            pc = 0;
            instr = 0;
            mdr = 0;
            a = 0;
            b = 0;
            alu_out = 0;
        end
        else
        begin
            if(PCwe) 
                pc = pc_in;
            if(IRWrite) 
                instr = MemData;
            mdr = MemData;
            a = rd1;
            b = rd2;
            alu_out = alu_result;
        end
    end
    
    always@(posedge clk,posedge rst)
    begin
        if(rst) 
        begin
            state = IF;
        end
        else 
        begin
            state = next_state;
        end
    end

    //next_state logic
    always@(*)
    begin
        case(state)
            IF: next_state = ID;
            ID:
            begin
                case(instr[31:26])
                    ADD:next_state = EX;
                    ADDI:next_state = MAC;
                    LW:next_state = MAC;
                    SW:next_state = MAC;
                    BEQ:next_state =BC;
                    J:next_state = JC;
                    default:next_state = IF;
                endcase
            end
            MAC:
            begin
                case(instr[31:26])
                    ADDI:next_state = AIC;
                    LW:next_state = MAL;
                    SW:next_state = MAS;
                    default:next_state = IF;
                endcase
            end
            MAL:next_state = WB;
            WB:next_state = IF;
            MAS:next_state = IF;
            EX:next_state = RC;
            RC:next_state = IF;
            BC:next_state = IF;
            JC:next_state = IF;
            AIC:next_state = IF;
            default:next_state = IF;
        endcase
    end

    //output logic
    always@(*)  
    begin   
        ALUSrcA = 0;
        ALUSrcB = 2'b00;
        alu_m = 3'b000;
        MemRead = 0;
        IorD = 0;
        IRWrite = 0;
        MemWrite = 0;
        MemtoReg = 0;
        RegWrite = 0;
        RegDst = 0;
        PCwe = 0;
        PCSource = 2'b00;
        case(state)
            IF:
            begin
                MemRead = 1'b1;
                IorD = 1'b0;
                IRWrite = 1'b1;
                ALUSrcA = 1'b0;
                ALUSrcB = 2'b01;
                alu_m = 3'b000;
                PCwe =1'b1;
                PCSource = 2'b00;
            end
            ID:
            begin
                ALUSrcA = 1'b0;
                ALUSrcB = 2'b11;
                alu_m = 3'b000;

            end
            MAC:
            begin
                ALUSrcA = 1;
                ALUSrcB = 2'b10;
                alu_m = 3'b000;

            end
            MAL:
            begin
                MemRead = 1;
                IorD = 1;

            end
            WB:
            begin
                RegDst = 0;
                RegWrite = 1;
                MemtoReg = 1;

            end
            MAS:
            begin
                MemWrite = 1;
                IorD = 1;

            end
            EX:
            begin
                ALUSrcA = 1;
                ALUSrcB = 2'b00;
                alu_m = 3'b000;

            end
            RC:
            begin
                RegDst = 1;
                RegWrite = 1;
                MemtoReg = 0;

            end
            BC:
            begin
                ALUSrcA = 1;
                ALUSrcB = 2'b00;
                alu_m = 3'b001;
                PCSource = 2'b01;
                PCwe = (zf==1);
            end
            JC:
            begin
                PCwe = 1;
                PCSource = 2'b10;
            end
            AIC:
            begin
                RegDst = 0;
                RegWrite = 1;
                MemtoReg = 0;
            end
            default: ;
        endcase
    end
endmodule


