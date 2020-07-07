module IO_interface
    (
        input sel,clk,
        input is_ready_1,
        input is_ready_2,
        input [31:0] data_input,
        input [31:0] DOR,
        input [1:0] CR,

        output [31:0] data_output,
        output reg [31:0] DIR,
        output reg [1:0] SR

    );

    /*
    *  is_ready_1 表示 I/O 输入是否已经准备就绪
    *  is_ready_2 表示 I/O 输出是否已经准备就绪
    *  data 表示从外设接收到的数据
    */


    

    always@(posedge clk)
    begin
        SR[0] = is_ready_1;
        SR[1] = is_ready_2;

        if(is_ready_1)   
        begin 
            DIR = data_input;
        end

        if(is_ready_2)     //若输出外设已准备好，那么将 DOR 中的数据输出
        begin
            data_output = DOR;
        end
        
    end

         
endmodule


    