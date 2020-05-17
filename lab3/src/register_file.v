module register_file
    #(  parameter WIDTH = 32,
        parameter DEEPTH = 32)
    (
        input clk,we,
        input [WIDTH - 1 : 0] wd,
        input [4 : 0] wa,
        input [4 : 0] ra0,
        input [4 : 0] ra1,

        output [WIDTH - 1 : 0] rd0,rd1
    );
    //32 个 32 位寄存器
    reg [WIDTH - 1 : 0] r [DEEPTH - 1 : 0];
    reg [WIDTH - 1 : 0] _rd0,_rd1;
    assign rd0 = _rd0;
    assign rd1 = _rd1;  

    always @(posedge clk)//同步写
    begin   
        if(we)
            if(wa)
                r[wa] <= wd;
            else
                r[wa] <= 0;
    end

    always @(*) //异步读
    begin
        _rd0 = r[ra0];
        _rd1 = r[ra1];
    end

endmodule