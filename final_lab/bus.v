module bus
    (
        input clk,rst,
        input [1:0] is_ready,
        input [31:0] data_input,
        
        output data_output
    );

    /*
        总线控制器模块
        
        d_bus_1 表示输入至 cpu 的数据总线分支
        d_bus_2     cpu 输出 的数据线
        c_bus_1 表示输入至 cpu 的控制总线分支
        c_bus_2     cpu 输出 的控制总线
        a_bus   地址总线
    */

    reg [33 : 0] d_bus_1, 
    reg [31 : 0] d_bus_2;
    reg [31 : 0] a_bus;
    reg [ 1 : 0] c_bus;

    wire [31:0] data_IO, data_MEM;


    cpu_one_cycle CPU
    (
        .d_bus_1(d_bus_1),
        .d_bus_2(d_bus_2),
        .c_bus_1(c_bus_1),
        .c_bus_2(c_bus_2),
        .a_bus(a_bus),
        .clk(clk),
        .rst(rst)
    );

    IO_interface IO
    (
        .sel(c_bus),
        .clk(clk),
        .is_ready_1(is_ready[0]),
        .is_ready_2(is_ready[1]),
        .data_input(data_input),    //来自于输入外设

        .DOR(d_bus_2),
        .DIR(data_IO),              //可输出至总线，供 CPU 使用
        .CR(),
        .SR(d_bus_1[33:32]),
        .data_output(data_output)
    );

    mem MEM(
        .addr(a_bus),
        .clk(clk),
        .we(we),
        .r_data(data_MEM),
        .w_data(d_bus_2)
    );

    //确定 I/O 输入与 存储器读 谁占据数据线
    assign d_bus_1[31:0] = addr > 32'h0000_0400 ? data_IO : data_MEM;

    assign we = (c_bus_2 == 2'b10) & (addr <= 32'h0000_0400);


endmodule