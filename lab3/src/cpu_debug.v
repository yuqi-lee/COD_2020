`timescale 1ns / 1ps

module cpu_debug(   
    input clk,          
    input rst,  
    input run, 
    input [7:0] m_rf_addr,        
    

    output [10:0] status,
    output [31:0] m_data,
    output [31:0] rf_data,

    output reg [31:0] pc,
    output  [31:0] pc_new, ins, rd1, rd2, alu_result,mem_data
    );

    //reg [31:0] pc;
    wire [31:0] pc_next, pc_branch, pc_jump;    // PC+4ýý ýý§ýý·ýý ýýêýý·
    //wire [31:0] pc_new; // µýýýýPCýý»ýýýµýµ
    //wire [31:0] alu_result; // ALUýýýýýý
    wire [31:0] /*ins,*/ imm_32/*, mem_data*/ ; //ýýð¸ýìýýyýýýýýýýýýýýý"ýýýýýýýýýý
    wire [31:0] /*rd1, rd2,*/ wd, b;    // býõ¶ýýýALUýýýýýý
    wire [4:0] ra1, ra2;
    wire [9:0] signal;    // ýýýýýzý
    wire [4:0] wa;  // ý4ýýýýuý4ýý·
    wire [2:0] m;    // ALUýýýµý*ýýýýýýýýýaýýýzý
    wire zf;    // 0 ýý¾
    reg  flag = 1'b0;
    
    //ýýýýh·
    // 256*32 
    dist_mem_gen_2  data_mem_debug(
        
        .clk(clk),
        .a(alu_result[9:2]),
        .d(rd2),
        .we(signal[7]),
        .spo(mem_data),
        .dpra(m_rf_addr),
        .dpo(m_data)
        
    );
    
    // 256*32 ¸ROM
    dist_mem_gen_1  ins_mem(.a(pc[9:2]),.spo(ins));
    
    // ALU
    alu #(32)   alu_data(.a(rd1),.b(b),.m(m),.zf(zf),.y(alu_result));
    
    // 
    register_file_debug rf(
        .ra_debug(m_rf_addr[4:0]),
        .ra1(ins[25:21]),
        .ra2(ins[20:16]),
        .wa(wa),
        .clk(clk),
        .wd(wd),
        .rd1(rd1),
        .rd2(rd2),
        .rd_debug(rf_data),
        .we(signal[9])
    );
    
    
    // 
    control #(6) ctrl(.data(ins[31:26]),.s(signal));
    alu_control alu_ctrl(.funct(ins[5:0]),.ALUop(signal[6:5]),.m(m));
    
    assign ra1 = ins[25:21];
    assign ra2 = ins[20:16];
    assign status = {zf,signal};
    assign pc_next = pc + 4;
    assign pc_branch = pc_next + (imm_32 << 2);
    assign imm_32 = {{16{ins[15]}},ins[15:0]};
    assign pc_new = signal[1] ? pc_jump : ((signal[2] & zf) ? pc_branch : pc_next);
    assign pc_jump = {pc_next[31:28],ins[25:0],2'b00};


    // 
    assign b = signal[8] ? imm_32 : rd2;
    
    // 
    assign wa = signal[0] ? ins[15:11] : ins[20:16];
    assign wd = signal[4] ? mem_data : alu_result;
    

    reg flag = 1'b0;


    always @(posedge clk or posedge rst)
    begin
        flag = flag + 1;
        if(flag)
        begin
            if(rst) 
                pc = 32'h00000000;
            else if(run)
            begin
                pc = pc_new;
            end
        end
    end
endmodule
