module mux_3to1
    #(parameter N 4)
    (
        input [1 : 0]   m,
        input [N - 1 : 0] data1,
        input [N - 1 : 0] data2,
        input [N - 1 : 0] data3,
        output[N - 1 : 0] result
    );
    reg result;

    always@(*)
    begin
        case(m)
            2'b01:  result = data1;
            2'b10:  result = data2;
            2'b11:  result = data3;
            default:    result = data1;
        endcase
    end

endmodule

