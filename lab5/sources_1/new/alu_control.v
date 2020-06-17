`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/06 16:18:26
// Design Name: 
// Module Name: alu_control
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


module alu_control(
    input [1:0] ALUOp,
    input [5:0] funct,
    output reg [2:0] m
    );

    always @(*)
    case(ALUOp)
        2'b00: m = 3'b000;
        2'b01: m = 3'b001;
        2'b10:
        begin
            case(funct)
                6'b100000: m = 3'b000;
                6'b100010: m = 3'b001;
                default: m = 3'b000;
            endcase
        end
        default: m = 3'b000;
    endcase
endmodule
