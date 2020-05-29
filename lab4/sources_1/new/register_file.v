`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/25 18:24:18
// Design Name: 
// Module Name: register_file
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


//32 x WIDTH寄存器堆
module register_file #(parameter WIDTH = 32)(
    input clk,              //时钟（上升沿有效）
    input rst,              // 异步复位，高电平有效
    input we,               // 写使能，高电平有效
    input [4:0] ra1,        // 读端口0地址
    input [4:0] ra2,        // 读端口1地址
    input [4:0] ra3,        // DBU 读地址
    input [4:0] wa,         // 写端口地址
    input [WIDTH-1:0] wd,        // 写端口数据
    output [WIDTH-1:0] rd1,      // 读端口0数据
    output [WIDTH-1:0] rd2,      // 读端口1数据
    output  [WIDTH-1:0] rd3      // DBU 读数据
    );


    reg [WIDTH-1:0] r [31:0];   // 32个寄存器
    
    integer i;
    initial
    begin
        for(i=0; i<32; i=i+1)
            r[i] <= 0;  //初始化寄存器
    end
    
    
    always @ (posedge clk, posedge rst)
    begin
        if (rst)
            for (i=0;i<32;i=i+1)
                r[i]=0;
        else
        begin
            if (we && (wa != 5'b00000))
                r[wa] <= wd;
        end
    end

    assign rd1 = r[ra1];    // 异步读数
    assign rd2 = r[ra2];    // 异步读数
    assign rd3 = r[ra3];    // 异步读数
endmodule

