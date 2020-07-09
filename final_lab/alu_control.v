module alu_control
    (
        input [1:0] ALUop,
        input [5:0] funct,
        output reg [2:0] m
    );

always @(*)
    case(ALUop)
        2'b00:
            m = 3'b000;
            
        2'b01:
            m = 3'b001;
            
        2'b10:
            begin
                if(funct == 6'b100000)
                    m = 3'b000;
                else if(funct == 6'b100010)
                    m = 3'b001;
                else
                    m = 3'b000;
            end

        default
            m = 3'b000;
    endcase

endmodule