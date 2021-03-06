`timescale 1ns / 1ps



module EX_forwarding_unit(
    input [5:0] op,
    input [4:0] ID_EX_Rs,
    input [4:0] ID_EX_Rt,
    input [4:0] EX_MEM_Rd,
    input [4:0] MEM_WB_Rd,
    input [1:0] EX_MEM_wb,
    input [1:0] MEM_WB_wb,
    output reg [1:0] ForwardA,
    output reg [1:0] ForwardB
    );
    
    always@(*)
    begin
        if(EX_MEM_wb[1] && (EX_MEM_Rd != 0) && (EX_MEM_Rd == ID_EX_Rs))//ALU 运算结果要写回，下个指令用
            ForwardA = 2'b10;
        
        else if(MEM_WB_wb[1] && (MEM_WB_Rd != 0) && (MEM_WB_Rd == ID_EX_Rs)) //ALU 运算结果要写回，下下个指令用
            ForwardA = 2'b01;
        
        
        else 
            ForwardA = 2'b00;


        
        if(op == 6'b001000) 
            ForwardB = 2'b11;       //addi
        
        else if(EX_MEM_wb[1] && (EX_MEM_Rd != 0) && (EX_MEM_Rd == ID_EX_Rt)) 
            ForwardB = 2'b10;
        
        else if(MEM_WB_wb[1] && (MEM_WB_Rd != 0) && (MEM_WB_Rd == ID_EX_Rt)) 
            ForwardB = 2'b01;
                    
        else 
            ForwardB = 2'b00;
    end
endmodule


module ID_forwarding_unit(
    input [4:0] IF_ID_Rs,
    input [4:0] IF_ID_Rt,
    input [4:0] EX_MEM_Rd,
    input [4:0] MEM_WB_Rd,
    input [1:0] EX_MEM_wb,
    input [1:0] MEM_WB_wb,
    output reg [1:0] BEQ_SrcA,
    output reg [1:0] BEQ_SrcB
    );
    
    always@(*)
    begin
        if(EX_MEM_wb[1] && (EX_MEM_Rd != 0) && (EX_MEM_Rd == IF_ID_Rs)) 
            BEQ_SrcA = 2'b10;
        else if(MEM_WB_wb[1] && (MEM_WB_Rd != 0) && (MEM_WB_Rd == IF_ID_Rs)) 
            BEQ_SrcA = 2'b01;
        else 
            BEQ_SrcA = 2'b00;
        
        if(EX_MEM_wb[1] && (EX_MEM_Rd != 0) && (EX_MEM_Rd == IF_ID_Rt)) 
            BEQ_SrcB = 2'b10;
        else if(MEM_WB_wb[1] && (MEM_WB_Rd != 0) && (MEM_WB_Rd == IF_ID_Rt)) 
            BEQ_SrcB = 2'b01;
        else 
            BEQ_SrcB = 2'b00;
    end
endmodule