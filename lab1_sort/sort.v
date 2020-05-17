`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/04/27 14:34:11
// Design Name: 
// Module Name: sort
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module sort
    #(parameter N = 4)
    (
        output reg [N - 1 : 0] s0,s1,s2,s3,
        output reg done,
        output reg [2:0] current_state,next_state,
        
        input  [N - 1 : 0] x0,x1,x2,x3,
        input clk,rst
    );

    wire [N - 1 : 0] i0,i1,i2,i3;   //4个寄存器的输入
    wire [N - 1 : 0] r0,r1,r2,r3;   //4个寄存器的输出
    wire [N - 1 : 0] op1,op2;       //ALU 2个输入

    reg  [1:0] m0,m1,m2,m3,m4,m5; // 6 个 3 选 1 选择器
    wire of,zf;
    wire [3:0] y;
    reg en0,en1,en2,en3;     //4个寄存器的写使能信号
    

    // FSM 8 个状态
    localparam LOAD    = 3'b000;
    localparam CX01_1  = 3'b001;
    localparam CX12_1  = 3'b010;
    localparam CX23_1  = 3'b011;
    localparam CX01_2  = 3'b100;
    localparam CX12_2  = 3'b101;
    localparam CX01_3  = 3'b110;
    localparam HLT     = 3'b111;

    // ALU 始终进行减法运算
    localparam  SUB = 3'b001;

    
    
    //Data Path
    register    RO(i0,en0,rst,clk,r0),
                R1(i1,en1,rst,clk,r1),
                R2(i2,en2,rst,clk,r2),
                R3(i3,en3,rst,clk,r3);
    
    alu #(4) ALU(.a(op1),.b(op2),.m(SUB),.cf(cf),.y(y),.of(of),.zf(zf));

    mux_3to1    M0(m0,x0,x0,r1,i0),        //4个寄存器输入的选择器
                M1(m1,r0,x1,r2,i1),
                M2(m2,r1,x2,r3,i2),
                M3(m3,r2,x3,x3,i3);

    mux_3to1    M4(m4,r0,r1,r2,op1),           //ALU 2 个输入端前的选择器
                M5(m5,r1,r2,r3,op2);



    //Control  Unit
    always@(posedge clk,posedge rst)
    if(rst)
        current_state <= LOAD;
    else
        current_state <= next_state;


    always@(*)
    begin
        case (current_state)
            LOAD:           next_state = CX01_1;
            CX01_1:         next_state = CX12_1;
            CX12_1:         next_state = CX23_1;
            CX23_1:         next_state = CX01_2;
            CX01_2:         next_state = CX12_2;
            CX12_2:         next_state = CX01_3;
            CX01_3:         next_state = HLT;
            HLT:            next_state = HLT;
            default:        next_state = HLT;
        endcase
    end

    //output
    always@(*)
    begin   
        {en0,en1,en2,en3} = 4'h0;
        done = 0;
        case(current_state)
            LOAD:  
            begin         
                {m0,m1,m2,m3} = 8'b10101010;
                {m4,m5} = 4'b0101;
                {en0,en1,en2,en3} = 4'b1111;
            end   
            CX01_1,CX01_2,CX01_3:   //第 1、2 个数进行比较
            begin
                m0 = 2'b11;
                m1 = 2'b01;
                m4 = 2'b01;
                m5 = 2'b01;
                en0 = (of & y[N - 1] & ~zf)|(~of & ~y[N - 1] & ~zf);
                en1 = (of & y[N - 1] & ~zf)|(~of & ~y[N - 1] & ~zf);
            end
            CX12_1,CX12_2:          //第 2、3 个数进行比较
            begin
                m1 = 2'b11;
                m2 = 2'b01;
                m4 = 2'b10;
                m5 = 2'b10;
                en1 = (of & y[N - 1] & ~zf)|(~of & ~y[N - 1] & ~zf);
                en2 = (of & y[N - 1] & ~zf)|(~of & ~y[N - 1] & ~zf);
            end
            CX23_1:                 //第 3、4 个数进行比较
            begin
                m2 = 2'b11;
                m3 = 2'b01;
                m4 = 2'b11;
                m5 = 2'b11;
                en2 = (of & y[N - 1] & ~zf)|(~of & ~y[N - 1] & ~zf);
                en3 = (of & y[N - 1] & ~zf)|(~of & ~y[N - 1] & ~zf);
            end   
            HLT:
                done = 1;
        endcase
        {s0,s1,s2,s3} = {r0,r1,r2,r3};
    end

endmodule