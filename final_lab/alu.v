module alu
    #(parameter WIDTH = 32)
    (   input  [WIDTH - 1 : 0] a,b,
        input  [2 : 0] m,

        
        output reg [WIDTH - 1 : 0] y,
        output reg zf,      
        output reg cf,      
        output reg of      
          
    );


    always@(*)
    begin
        case(m)
            3'b000:
                begin
                    {cf,y} = a + b;
                end
        
            3'b001:
                begin
                    {cf,y} = a - b;
                end
        
            3'b010:
                begin
                    y = a & b;
                end
        
            3'b011:
                begin
                    y = a | b;
                end

            3'b100:
                begin
                    y = a ^ b;
                end
            default:
                begin
                    y = y;
                end
        endcase

        zf = (y == 0);
        of = a[WIDTH - 1] ^ b[WIDTH - 1] ^ y[WIDTH - 1] ^ cf;

    end


endmodule