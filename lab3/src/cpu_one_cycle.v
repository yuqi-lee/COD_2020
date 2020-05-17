`timescale 1ns / 1ps

module cpu_one_cycle(   // ������CPU
    input clk,          // ʱ�ӣ���������Ч��
    input rst,           // �첽��λ���ߵ�ƽ��Ч
    output reg [31:0] pc=32'h00000000,
    output [31:0] alu_result,
    output [31:0] done
    );

    //reg [31:0] pc;
    wire [31:0] pc_next, pc_branch, pc_jump;    // PC+4�� ��֧��ַ�� ��ת��ַ
    wire [31:0] pc_new; // ʵ����PC��һ���ڵ�ֵ
    //wire [31:0] alu_result; // ALU������
    wire [31:0] ins, imm_32, mem_data;  //��ǰָ���չ������������洢����������
    wire [31:0] rd1, rd2, wd, b;    // b�ǵڶ���ALU������
    wire [4:0] ra1, ra2;
    wire [9:0] signal;    // �����ź�
    wire [4:0] wa;  // �Ĵ����ѵ�д��ַ
    wire [2:0] m;    // ALU���Ƶ�Ԫ���������ѡ���ź�
    wire zf;    // 0 ��־
    reg  flag = 1'b0;
    
    // 256*32 RAM
    dist_mem_gen_0  data_mem(
        .clk(clk),
        .a(alu_result[9:2]),
        .d(rd2),
        .we(signal[7]),
        .spo(mem_data),
        .dpra(8'h02),
        .dpo(done)
    );
    
    // 256*32 ָ指令存储器
    dist_mem_gen_1  ins_mem(.a(pc[9:2]),.spo(ins));
    
    // ALU
    alu #(32)   alu_data(.a(rd1),.b(b),.m(m),.zf(zf),.y(alu_result));
    
    //  32 个 32 位寄存器堆
    register_file rf(
        .ra1(ins[25:21]),
        .ra2(ins[20:16]),
        .wa(wa),
        .clk(clk),
        .wd(wd),
        .rd1(rd1),
        .rd2(rd2),
        .we(signal[9])
    );
    
    
    // ������
    control #(6) ctrl(.data(ins[31:26]),.s(signal));
    alu_control alu_ctrl(.funct(ins[5:0]),.ALUop(signal[6:5]),.m(m));
    
    assign ra1 = ins[25:21];
    assign ra2 = ins[20:16];
    
    assign pc_next = pc + 4;
    assign pc_branch = pc_next + (imm_32 << 2);
    assign imm_32 = {{16{ins[15]}},ins[15:0]};
    assign pc_new = signal[1] ? pc_jump : ((signal[2] & zf) ? pc_branch : pc_next);
    assign pc_jump = {pc_next[31:28],ins[25:0],2'b00};
    
    // ѡ��ALU�ڶ���������
    assign b = signal[8] ? imm_32 : rd2;
    
    // д�Ĵ�����
    assign wa = signal[0] ? ins[15:11] : ins[20:16];
    assign wd = signal[4] ? mem_data : alu_result;
    
    always @(posedge clk or posedge rst)
    begin
        if(rst) begin pc = 32'h00000000;flag = 1'b0;end
        else 
        begin
            pc = pc_new;
            flag = flag + 1'b1;
            //if(flag == 1'b1) pc = pc_new;
        end
    end
endmodule
