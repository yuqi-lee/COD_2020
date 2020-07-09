`timescale 1ns / 1ps

module cpu
    (   
        input clk,          
        input rst,
        input [33:0] d_bus_1,

        output [31:0] d_bus_2,
        output [1:0] c_bus,
        output [31:0] a_bus 
        

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
    wire [31:0]  imm_32, mem_data;  
    wire [31:0] rd1, rd2, wd, b;   

    
    wire [9:0] signal;    //控制信号
    wire [4:0] wa;  //寄存器堆写地址
    
    /* ALU运算选择 */
    wire [2:0] m;    

    /* ALU  0 信号־*/
    wire zf;    
    
    wire [31:0] ins;
    wire nop;
    wire rf_we;
    
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
        .rst(rst),
        .wd(wd),
        .rd1(rd1),
        .rd2(rd2),
        .we(rf_we)
        
    );

    
    
    
    // 控制模块
    control #(6) ctrl(.data(ins[31:26]),.signal(signal));
    alu_control alu_ctrl(.funct(ins[5:0]),.ALUop(signal[6:5]),.m(m));
    
    /* 确定新 pc 值 */
    assign pc_next = pc + 4;
    assign pc_branch = pc_next + (imm_32 << 2);
    assign pc_new = signal[1] ? pc_jump : ((signal[2] & zf) ? pc_branch : pc_next);
    assign pc_jump = {pc_next[31:28],ins[25:0],2'b00};

    assign imm_32 = ins[15] == 1 ? {{16'hffff,ins[15:0]} :  {{16'h0000,ins[15:0]};

    // 确定ALU的第二个操作数来源于寄存器堆还是立即数扩展
    assign b = signal[8] ? imm_32 : rd2;
    
    // 确定寄存器堆的 写地址、写数据的来源(ALU运算结果 or MEM_DATA读)
    assign wa = signal[0] ? ins[15:11] : ins[20:16];
    assign wd = signal[4] ? mem_data : alu_result;
    
    // 通过总线读取数据
    assign mem_data = d_bus_1[31:0];

    // 判断是否要等待 I/O
    assign nop = ( (alu_result > 32'h0000_0400) & 
                    ( (signal[3] & ~d_bus_1[32]) | (signal[7] & ~d_bus_1[33]) ) );

    // 输出总线上的控制信号
    assign c_bus = {signal[7],signal[3]};

    assign a_bus = alu_result;
    assign d_bus_2 = rd2;
    assign rf_we = signal[9] & ~nop;

    /* 异步复位以及更新 pc */
    always @(posedge clk or posedge rst)
    begin
        if(rst) 
        begin 
            pc = 32'h00000000;
        end
        else if(!nop)
        begin
            pc = pc_new;
        end
    end
endmodule
