`timescale 1ns / 1ps


module register_file #(parameter WIDTH = 32)(
    input clk,              
    input rst,             
    input we,               
    input [4:0] ra1,        
    input [4:0] ra2,        
    input [4:0] ra3,        
    input [4:0] wa,        
    input [WIDTH-1:0] wd,       
    output [WIDTH-1:0] rd1,      
    output [WIDTH-1:0] rd2,      
    output  [WIDTH-1:0] rd3     
    );


    reg [WIDTH-1:0] r [31:0];   
    
    integer i;
    initial
    begin
        for(i=0; i<32; i=i+1)
            r[i] = 0; 
    end
    
    
    always @ (posedge clk, posedge rst)
    begin
        if (rst)
            for (i=0;i<32;i=i+1)
                r[i] <= 0;
        else
        begin
            if (we && (wa != 5'b00000))
                r[wa] <= wd;
        end
    end

    assign rd1 = r[ra1];    // �첽����
    assign rd2 = r[ra2];    // �첽����
    assign rd3 = r[ra3];    // �첽����
endmodule