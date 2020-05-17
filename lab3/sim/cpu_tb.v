module cpu_tb;
    reg clk,rst;
    cpu_one_cycle(.clk(clk),.rst(rst));

    initial
    begin
        #(5)
        rst = 1;
        #(5)
        rst = 0;
    end

    initial
    begin
        clk = 0;
        repeat (2 * 20)
        	#(5/2) clk = ~clk;
        $finish;
    end

endmodule