`timescale 1ns / 1ps



module cpu_tb;
    reg clk;
    reg rst;
    wire [31:0] pc;
    wire [31:0] done;
    
    parameter PERIOD = 10;
    parameter CYCLE = 40;
    
    cpu_pipeline cpu(
        .clk(clk),
        .rst(rst),
        .done(done),
        .pc_out(pc)
    );
    
    initial
    begin
        clk = 0;
        repeat (2 * CYCLE)
        	#(PERIOD/2) clk = ~clk;
        $finish;
    end
    
    initial
    begin
        rst = 0;
        #1 rst = 1;
        #1 rst = 0;
    end
endmodule
