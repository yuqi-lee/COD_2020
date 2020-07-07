module register_file
    #(  parameter WIDTH = 32,
        parameter DEEPTH = 32)
    (
        input clk,we,
        input [WIDTH - 1 : 0] wd,
        input [4 : 0] wa,
        input [4 : 0] ra1,
        input [4 : 0] ra2,
        input [4 : 0] ra3,

        output [WIDTH - 1 : 0] rd1,rd2,rd3
    );
    //32 个 32 位寄存器
    reg [WIDTH - 1 : 0] r [DEEPTH - 1 : 0];
    reg [WIDTH - 1 : 0] _rd3,_rd1,_rd2;
    assign rd0 = _rd3;
    assign rd1 = _rd1; 
    assign rd2 = _rd2; 

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
        _rd0 = r[ra3];
        _rd1 = r[ra1];
        _rd2 = r[ra2];
    end

endmodule