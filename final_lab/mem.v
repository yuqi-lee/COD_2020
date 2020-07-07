module mem
    (
        input [31 : 0] addr,
        input clk,en //signal[7]
        input [31 : 0] w_data,
        input en_r,en_w,
        output [31 : 0] r_data

    );

    wire we;
    assign we = (addr <= 32'h0000_0400);

    // 256*32 双端口RAM 数据存储器
    dist_mem_gen_0  data_mem(
        .clk(clk),
        .a(addr[9:2]),
        .d(w_data),
        .we(en_w),
        .spo(data),
    );

endmodule