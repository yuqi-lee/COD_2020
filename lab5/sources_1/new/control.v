`timescale 1ns / 1ps



module control(
    input [31:0] instr,
    input Zero,
    output reg [1:0] signal_wb,
    output reg [1:0] signal_m,
    output reg [2:0] signal_ex,
    output reg flush,
    output reg [1:0] PCSrc
    );
    wire [5:0] op;
    wire [5:0] funct;
  
  assign op = instr[31:26];
  assign funct = instr[5:0];  
  
    always@(*)
    begin
        case(op)
            6'b000000:
            begin
                if(funct == 6'b100000)//add
                begin
                    signal_wb = 2'b10;
                    signal_m = 2'b00;
                    signal_ex = 3'b110;
                    flush = 0;
                    PCSrc = 2'b00;
                end
                else
                begin
                    signal_wb = 2'b00;
                    signal_m = 2'b00;
                    signal_ex = 3'b000;
                    flush = 0;
                    PCSrc = 2'b00;
                end
            end
            6'b001000:  //addi
            begin
                signal_wb = 2'b10;
                signal_m = 2'b00;
                signal_ex = 3'b000;
                flush = 0;
                PCSrc = 2'b00;
            end
            6'b100011:  //lw
            begin
                signal_wb = 2'b11;
                signal_m = 2'b10;
                signal_ex = 3'b000;
                flush = 0;
                PCSrc = 2'b00;
            end
            6'b101011:  //sw
            begin
                signal_wb = 2'b00;
                signal_m = 2'b01;
                signal_ex = 3'b000;
                flush = 0;
                PCSrc = 2'b00;
            end
            6'b000100:  //beq
            begin
                signal_wb = 2'b00;
                signal_m = 2'b00;
                signal_ex = 3'b000;
                if(Zero) 
                begin
                    PCSrc = 2'b01;
                    flush = 1;
                end
                else
                begin
                    PCSrc = 2'b00;
                    flush = 0;
                end
            end
            6'b000010:  //j
            begin
                signal_wb = 2'b00;
                signal_m = 2'b00;
                signal_ex = 3'b000;
                flush = 1;
                PCSrc = 2'b10;
            end
            default:    //nop
            begin
                signal_wb = 2'b00;
                signal_m = 2'b00;
                signal_ex = 3'b000;
                flush = 0;
                PCSrc = 2'b00;
            end
        endcase
    end
endmodule
