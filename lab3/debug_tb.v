module debug_tb;
    reg clk,rst;
    reg  succ,step,m_rf,inc,dec;
    reg [3:0] sel;

    wire [10:0] status;
    wire [31:0] m_data,rf_data;
    wire [31:0] pc_out, pc_in, instr, rf_rd1, rf_rd2, alu_y, m_rd;

    wire run;
    wire [7:0] m_rf_addr;
    wire [15:0] led;
    wire [31:0] seg;

    dub DEBUGGER
    (
        .clk(clk),.rst(rst),
        .succ(succ),.step(step),
        .m_rf(m_rf),.inc(inc),.dec(dec),
        .sel(sel),
        .status(status),.m_data(m_data),.rf_data(rf_data),
        .pc_in(pc_in),.pc_out(pc_out),.instr(instr),
        .rf_rd1(rf_rd1),.rf_rd2(rf_rd2),
        .alu_y(alu_y),.m_rd(m_rd),
        .run(run),.m_rf_addr(m_rf_addr),
        .led(led),.seg(seg)
    );

    cpu_debug CPU_DEBUG
    (
        .clk(clk),.rst(rst),.run(run),
        .m_rf_addr(m_rf_addr),.status(status),
        .m_data(m_data),.rf_data(rf_data),
        .pc(pc_out),.pc_new(pc_in),
        .rd1(rf_rd1),.rd2(rf_rd2),
        .alu_result(alu_y),.mem_data(m_data)
    );

    