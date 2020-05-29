`timescale 1ns / 100ps

module reg_file_tb;
    reg clk;
    reg we;
    reg [31:0] wd;
    reg [4:0] ra0,ra1,wa;

    wire[31:0] rd0,rd1;

    register_file rf(.clk(clk),.we(we),.wd(wd),.wa(wa),.ra0(ra0),.ra1(ra1),.rd0(rd0),.rd1(rd1));

    parameter PERIOD = 5, 
    CYCLE = 20;

    initial
    begin
        clk = 0;
        repeat (4 * CYCLE)
        	#(PERIOD/2) clk = ~clk;
        $finish;
    end

    initial
    begin
        ra0 = 5'b00000;
        ra1 = 5'b10010;
        wa  = 5'b00001;
        wd  = 32'h0000002f;

        repeat (4 * CYCLE)
        	#(PERIOD) 
            begin
                ra0 = ra0 + 3;
                ra1 = ra1 + 5;
                wa  = wa + 1;
                wd = wd - 1;
            end
    end

    initial
    begin
        we = 1;
        repeat (4 * CYCLE)
        #(4)    we = ~we;
    end

endmodule