module bus
    (
        input clk,rst,

        input [1:0] is_ready,
        input [31:0] data_input,
        
        output data_output
    );

    /*
        总线控制器模块
        
        100位 总线

        d_bus_1 表示输入至 cpu 的数据总线分支
        d_bus_2     cpu 输出 的数据线
        c_bus    cpu 输出 的控制总线
        a_bus   地址总线
    */

    wire [33 : 0] d_bus_1, 
    wire [31 : 0] d_bus_2;
    wire [31 : 0] a_bus;
    wire [ 1 : 0] c_bus;

    wire [31:0] data_IO, data_MEM;
    wire we_1,we_2;

    cpu CPU
    (
        .d_bus_1(d_bus_1),
        .d_bus_2(d_bus_2),
        .c_bus(c_bus),
        .a_bus(a_bus),
        .clk(clk),
        .rst(rst)
    );

    IO_interface IO
    (
        .clk(clk),
        .is_ready_1(is_ready[0]),
        .is_ready_2(is_ready[1]),
        .data_input(data_input),    //来自于输入外设
        .data_cpu(d_bus_2),
        .we(we_2),
        .CR(c_bus),

        .DIR(data_IO),              //可输出至总线，供 CPU 使用
        .SR(d_bus_1[33:32]),
        .data_output(data_output)
    );

    mem MEM(
        .addr(a_bus),
        .clk(clk),
        .we(we_1),
        .r_data(data_MEM),
        .w_data(d_bus_2)
    );

    // 确定 I/O 输入与 存储器读 谁占据数据线
    assign d_bus_1[31:0] = a_bus > 32'h0000_0400 ? data_IO : data_MEM;

    // 此 we 控制数据存储器是否可写
    assign we_1 = (c_bus == 2'b10) & (a_bus <= 32'h0000_0400);

    // 此 we 控制是否要把数据写入 io 接口的 DOR
    assign we_2 = (c_bus == 2'b10) & (a_bus > 32'h0000_0400);
    
endmodule