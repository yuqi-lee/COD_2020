module control 
    #(  parameter WIDTH = 6)
    (
        input [WIDTH - 1 : 0] data,
        input [5 : 0] data_1,
        input [31 : 0] v0,

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
        signal[10]  isSyscall
        signal[11]  input or output  1 表示输入， 0 表示输出
    */


    always @(*)
    begin
        case(data)
            6'b000000:      //add
            begin
                if(data_1 == 6'b100000)
                    signal = 12'b001001000001;
                else
                    if(v0 == 32'h0005)
                        signal = 12‘b11


            6'b001000:      //addi
                signal = 12'b001100000001;

            6'b100011:      //lw
                signal = 12'b001100011000;

            6'b101011:      //sw
                signal = 12'b000110000000;

            6'b000100:      //beq
                signal = 12'b000000100100;

            6'b000010:      //j
                signal = 12'b000000000010;

            6'b
            default:        //nop
                signal = 12'b000000000000;

        endcase
    end


endmodule