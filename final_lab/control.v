module control 
    #(  parameter WIDTH = 6)
    (
        input [WIDTH - 1 : 0] data,

        output reg [9 : 0] signal
    );

    /*
        signal[0]   RegDst
        signal[1]   Jump
        signal[2]   Branch
        signal[3]   MemRead
        signal[4]   MemtoReg
        signal[5~6]   ALUop
        signal[7]   MemWrite
        signal[8]   ALUsrc
        signal[9]   RegWrite

    */


    always @(*)
    begin
        case(data)
            6'b000000:      //add
           
                signal = 10'b10010_00001;

            6'b001000:      //addi
                signal = 10'b11000_00001;

            6'b100011:      //lw
                signal = 10'b11000_11000;

            6'b101011:      //sw
                signal = 10'b01100_00000;

            6'b000100:      //beq
                signal = 10'b00001_00100;

            6'b000010:      //j
                signal = 10'b00000_00010;

            default:        //nop
                signal = 10'b00000_00000;

        endcase
    end


endmodule