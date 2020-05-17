module dbu
    (
        input clk,rst,
        input succ,
        input step,
        input [3:0] sel,
        input m_rf,
        input inc,
        input dec,

        input [10:0] status,
        input [31:0] m_data,rf_data,

        input [31:0] pc, pc_in, instr, rf_rd1, rf_rd2, alu_y, m_rd,
        
        output run,
        output reg [7:0] m_rf_addr,
        output reg [15:0] led,
        output reg [31:0] seg
    );

wire step_edg;

get_edg EDG_1(.clk0(clk),.y(step),.rst0(rst),.q(step_edg));

assign run = succ | step_edg;

always @(posedge clk or posedge clk) 
    if(rst)
    begin
        m_rf_addr = 8'h00;
    end

    


always @(*)
begin
    if(sel == 3'b000)
    begin
        led = {8'h00,m_rf_addr};
        if(m_rf)
            seg = m_data;
        else
            seg = rf_data;
        if(inc)
            m_rf_addr = m_rf_addr + 1;
        else if(dec)
            m_rf_addr = m_rf_addr + 1;   
    end
    else
    begin
        led = {5'b00000,status};
        case(sel)
            3'b001: seg = pc_in;
            3'b010: seg = pc_out;
            3'b011: seg = instr;
            3'b100: seg = rf_rd1;
            3'b101: seg = rf_rd2;
            3'b110: seg = alu_y;
            3'b111: seg = m_rd;
        endcase
    end
end



endmodule
