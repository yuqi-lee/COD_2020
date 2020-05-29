`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/06 09:46:03
// Design Name: 
// Module Name: fifo_tb
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


module fifo_tb;
    reg clk,rst,en_in,en_out;
    reg [7:0] din;
    wire [7:0] dout;
    wire [4:0] counter;
    //wire pos_1,pos_2;

    fifo queue(.clk(clk),.rst(rst),.en_in(en_in),.en_out(en_out),.din(din),.count(counter),.dout(dout));

    parameter PERIOD = 5, 
    CYCLE = 20;

    initial
    begin
        clk = 0;
        repeat (16 * CYCLE)
        	#(PERIOD/2) clk = ~clk;
        $finish;
    end

    initial
    begin
    #(6)
        en_in = 1;
        repeat(6)
        begin
            #(10)
                en_in = ~en_in;
            #(40)
                en_in = ~en_in;
        end
        #(5)
            en_in = 0;
    end

    initial
    begin
        en_out = 0;
        #(16*CYCLE)
        repeat(4 * CYCLE)
        begin
            #(40)
                en_out = ~en_out;
            #(10)
                en_out = ~en_out;
        end
    end

    initial
    begin
        din = 2;
        repeat(4 * CYCLE)
            #(10 * PERIOD) din = din + 3;
    end

    initial
    begin
        rst = 1;
        #(5) rst = 0;
        /*repeat(4 * CYCLE)
        begin
            #(10) rst = ~rst;
            #(10 * PERIOD) rst = ~rst;
        end*/
    end

endmodule