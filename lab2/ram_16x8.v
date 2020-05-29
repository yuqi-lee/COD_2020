module ram_16x8
    (
        input clk,
        input en,we,
        input [3 : 0] addr,
        input [7 : 0] din,

        output [7 : 0] dout
    );

reg [3 : 0] addr_reg;
reg [15: 0] mem [7 : 0];

initial 
    $readmemh("",mem);

assign dout = mem[addr_reg];

always @(posedge clk)
begin   
    if(en)
    begin
        addr_reg <= addr;
        if(we)
            mem[addr] <= din;
    end
end

endmodule