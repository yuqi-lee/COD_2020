`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/01 13:51:24
// Design Name: 
// Module Name: hazard_detection_unit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module hazard_detection_unit(
    input [31:0] IF_ID_ir,
    input [31:0] ID_EX_ir,
    input ID_EX_MemRead,
    input ID_EX_RegWrite,
    input EX_MEM_MemRead,
    input [4:0] EX_MEM_wa,
    input [4:0] rf_wa,
    output reg PC_IF_ID_Write,
    output reg stall
    );
    
    wire Branch;
    reg [2:0] flag;
    assign Branch = (IF_ID_ir[31:26] == 6'b000100);


    always@(*)
    begin
        if(EX_MEM_MemRead && Branch &&
            (EX_MEM_wa == IF_ID_ir[25:21] ||
            EX_MEM_wa == IF_ID_ir[20:16])) //lw-beq (P216)
        begin
            stall = 1;
            PC_IF_ID_Write = 0;
            flag = 1;
        end


        else if(ID_EX_MemRead &&
            (ID_EX_ir[20:16] == IF_ID_ir[25:21] ||
            ID_EX_ir[20:16] == IF_ID_ir[20:16])) //lw-alu and lw-beq(P212)
        begin
            stall = 1;
            PC_IF_ID_Write = 0;
            flag = 2;
        end


        else if(ID_EX_RegWrite && Branch &&
            (rf_wa == IF_ID_ir[25:21] ||
            rf_wa == IF_ID_ir[20:16]))          /* alu-beq */
        begin
            stall = 1;
            PC_IF_ID_Write = 0;
            flag = 3;
        end

        
        else
        begin
            stall = 0;
            PC_IF_ID_Write = 1;
            flag = 4;
        end
    end
endmodule
