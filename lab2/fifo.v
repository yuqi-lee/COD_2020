module ptph
    (
        input clk, rst,		
        input [7:0] din,		
        input en_in, 		
        input en_out,	
        
        output  [7:0] dout, 	
        output reg [4:0] count	
    );

//队空、队满信号
wire full;
wire empty;	

//去边沿得到的入队、出队使能信号
wire edg_in;
wire edg_out;

//加入队空队满判断后的使能信号
wire en1,en2;

//头尾指针与 RAM 端口的地址
reg [3:0]pt;    //pointer of tail
reg [3:0]ph;    //pointer of head
reg [3:0]addr;


assign full = (count == 5'b10000);
assign empty = (count == 5'b00000);

assign en1 = (edg_in & ~full);
assign en2 = (edg_out & ~empty);

reg [1:0] state;
wire [7:0] _dout;   //RAM的输出

dist_mem_gen_0  mem(.a(addr),.d(din),.clk(clk),.we(edg_in),.spo(_dout));

edg edg_en_in(.y(en_in),.rst0(rst),.clk0(clk),.q(edg_in));
edg edg_en_out(.y(en_out),.rst0(rst),.clk0(clk),.q(edg_out));

//寄存器用来保存上一个出队的值
register R1(_dout,edg_out,rst,clk,dout);


always @(posedge clk)
begin
    if(rst)
    begin
        pt = 4'b0000;
        ph = 4'b0000;
        count = 5'b00000;
    end
end

always @(*)
    state = {en1,en2};

always @(state)
begin
    case(state)
        2'b00:
        begin 
            count = count;
        end
        2'b01:
        begin
            addr = ph;
            count = (count - 1);
            ph = (ph + 1);                
        end 
        2'b10,2'b11://两信号都有效时，屏蔽出队信号
        begin
            addr = pt;
            count = count + 1;
            pt = (pt + 1);  
        end
    endcase
end
            
endmodule