module fibo_tb;

    reg clk;
    reg rst;
    reg [1:0] is_ready;
    reg [31:0] data_input;

    wire [31:0] data_output;

    parameter PERIOD = 8;
    parameter CYCLE = 20;

    initial
    begin
        clk = 0;
        repeat (5 * CYCLE)
        	#(PERIOD/2) clk = ~clk;
        $finish;
    end

    initial
    begin
        rst = 1;
        #(8)   rst = 0; 

    end

    initial
    begin
        is_ready[0] = 0;
        #(16) is_ready[0] = 1;
        #(8)  is_ready[0] = 0;

        #(32) is_ready[0] = 1;
        #(8)  is_ready[0] = 0;
    end

    initial
    begin
        is_ready[1] = 1;
    end

    initial
    begin
        data_input = 32'h0000_0001;
    end



    bus BUS
    (
        .clk(clk),
        .rst(rst),


        .is_ready(is_ready),
        .data_input(data_input),
        .data_output(data_output)
    );

endmodule