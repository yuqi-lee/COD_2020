module register
    #(parameter N 4)
    (
        input[N - 1 : 0]    id,
        input en,               //当en信号为1时，才写入
        input rst,
        input clk,
        output reg [N - 1 : 0] od
    );

    
    always@(posedge clk)
    begin  
        if(rst == 1)
            od <= 0;
        else
        begin
            if(en == 1)
                od <= id;
            else
                od <= od;
        end
    end
    

endmodule