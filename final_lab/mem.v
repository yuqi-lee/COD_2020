module mem
    (
        input [31 : 0] addr,
        input clk,we, 
        input [31 : 0] w_data,
        input en_r,en_w,
        output [31 : 0] r_data

    );


    // 256*32 双端口RAM 数据存储器
    dist_mem_gen_0  data_mem(
        .clk(clk),
        .a(addr[9:2]),
        .d(w_data),
        .we(en_w),
        .spo(data),
    );

endmodule