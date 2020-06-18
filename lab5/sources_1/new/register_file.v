`timescale 1ns / 1ps


module register_file #(parameter WIDTH = 32)(
    input clk,              //ʱ�ӣ���������Ч��
    input rst,              // �첽��λ���ߵ�ƽ��Ч
    input we,               // дʹ�ܣ��ߵ�ƽ��Ч
    input [4:0] ra1,        // ���˿�0��ַ
    input [4:0] ra2,        // ���˿�1��ַ
    input [4:0] ra3,        // DBU ����ַ
    input [4:0] wa,         // д�˿ڵ�ַ
    input [WIDTH-1:0] wd,        // д�˿�����
    output [WIDTH-1:0] rd1,      // ���˿�0����
    output [WIDTH-1:0] rd2,      // ���˿�1����
    output  [WIDTH-1:0] rd3      // DBU ������
    );


    reg [WIDTH-1:0] r [31:0];   // 32���Ĵ���
    
    integer i;
    initial
    begin
        for(i=0; i<32; i=i+1)
            r[i] = 0;  //��ʼ���Ĵ���
    end
    
    
    always @ (posedge clk, posedge rst)
    begin
        if (rst)
            for (i=0;i<32;i=i+1)
                r[i] <= 0;
        else
        begin
            if (we && (wa != 5'b00000))
                r[wa] <= wd;
        end
    end

    assign rd1 = r[ra1];    // �첽����
    assign rd2 = r[ra2];    // �첽����
    assign rd3 = r[ra3];    // �첽����
endmodule