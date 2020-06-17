`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/05 14:51:56
// Design Name: 
// Module Name: rf_tb
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


module rf_tb;
    reg clk;
    reg rst;
    reg [4:0] ra,wa;
    wire [31:0] rd;
    reg [31:0] wd;
    
    register_file #(32) rf(
    .clk(clk),
    .rst(rst),
    .we(1),
    .ra1(ra),
    .wa(wa),
    .wd(wd),
    .rd1(rd)
    );
    
    initial
    begin
        rst = 0;
        #1 rst = 1;
        #1 rst = 0;
    end
    
    initial
    begin
        clk = 0;
        repeat(20)
            #5 clk = ~clk;
        $finish;
    end
    
    initial
    begin
        #20
        wa = 5'b00001;
        ra = 5'b00001;
        wd = 32'hffff0000;
    end
endmodule
