`timescale 1ns / 1ps

module ram_tb;
    reg clk;
    reg [7:0] din;
    reg en, we;
    reg [3:0] addr;
    wire [7:0] dout1, dout2;

    parameter PERIOD = 10;
    parameter CYCLE = 20;   

    
    dist_mem_gen_0 dist_ram(addr, din ,clk, we, dout1);
    blk_mem_gen_0 blk_ram(clk, en, we, addr, din, dout2);

    initial
    begin
        clk = 0;
        repeat (2 * CYCLE)
            #(PERIOD/2) clk = ~clk;
        $finish;
    end

    initial
    begin
        we = 1;
        repeat (1 * CYCLE)
            #(PERIOD*2) we = ~we;
    end

    initial
    begin
        en = 1;
        repeat (2 * CYCLE)
            #(PERIOD*10) en = ~en;
    end

    initial
    begin
        addr = 4'b0000;
        repeat (2 * CYCLE)
            #(PERIOD*3) addr = (addr+1) % 16;
    end

    initial
    begin
        din = 8'h01;
        repeat (2 * CYCLE)
            #(PERIOD) din = (din+1) % 256;
    end

endmodule