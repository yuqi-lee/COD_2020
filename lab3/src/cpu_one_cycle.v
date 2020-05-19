`timescale 1ns / 1ps

module cpu_one_cycle
    (   
        input clk,          
        input rst     
    );

    /*
    *   有关pc的32位信号
    *   其中pc要在时钟边沿更新，为reg型
    *   其余为线网型
    */
    reg [31:0] pc;
    wire [31:0] pc_next, pc_branch, pc_jump, pc_new;    

    /* 其它 32 位信号 */
    wire [31:0] alu_result; // ALU运算结果
    wire [31:0] ins, imm_32, mem_data;  
    wire [31:0] rd1, rd2, wd, b;   

    /* done 信号为 地址0x08的数据，检验 cpu 设计正确性时用到 */
    output [31:0] done;     
    localparam ADDR = 8'h02;

    wire [9:0] signal;    //控制信号
    wire [4:0] wa;  //寄存器堆写地址
    
    /* ALU运算选择 */
    wire [2:0] m;    

    /* ALU  0 信号־*/
    wire zf;    
    
    // 256*32 双端口RAM 数据存储器
    dist_mem_gen_0  data_mem(
        .clk(clk),
        .a(alu_result[9:2]),
        .d(rd2),
        .we(signal[7]),
        .spo(mem_data),
        .dpra(ADDR),
        .dpo(done)
    );
    
    // 256*32 ָROM 指令存储器
    dist_mem_gen_1  ins_mem(.a(pc[9:2]),.spo(ins));
    
    // ALU
    alu #(32)   alu_data(.a(rd1),.b(b),.m(m),.zf(zf),.y(alu_result));
    
    //  32 个 32 位寄存器
    register_file rf(
        .ra1(ins[25:21]),
        .ra2(ins[20:16]),
        .wa(wa),
        .clk(clk),
        .wd(wd),
        .rd1(rd1),
        .rd2(rd2),
        .we(signal[9])
    );
    
    
    // 控制模块
    control #(6) ctrl(.data(ins[31:26]),.s(signal));
    alu_control alu_ctrl(.funct(ins[5:0]),.ALUop(signal[6:5]),.m(m));
    
    /* 确定新 pc 值 */
    assign pc_next = pc + 4;
    assign pc_branch = pc_next + (imm_32 << 2);
    assign pc_new = signal[1] ? pc_jump : ((signal[2] & zf) ? pc_branch : pc_next);
    assign pc_jump = {pc_next[31:28],ins[25:0],2'b00};

    assign imm_32 = {{16{ins[15]}},ins[15:0]};
    // 确定ALU的第二个操作数来源于寄存器堆还是立即数扩展
    assign b = signal[8] ? imm_32 : rd2;
    
    // 确定寄存器堆的 写地址、写数据的来源(ALU运算结果 or MEM_DATA读)
    assign wa = signal[0] ? ins[15:11] : ins[20:16];
    assign wd = signal[4] ? mem_data : alu_result;
    
    /* 异步复位以及更新 pc */
    always @(posedge clk or posedge rst)
    begin
        if(rst) 
        begin 
            pc = 32'h00000000;
        end
        else 
        begin
            pc = pc_new;

        end
    end
endmodule
