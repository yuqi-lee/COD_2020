`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/15 10:49:47
// Design Name: 
// Module Name: dbu_1
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns / 1ps

module dbu(
    input clk,
    input rst,
    input succ,
    input step,
    input [3:0] sel,
    input m_rf,
    input inc,
    input dec,
    input [11:0] status,
    input [31:0] m_data,
    input [31:0] rf_data,
    input [31:0] instr,
    input [31:0] pc_in,
    input [31:0] pc_out,
    input [31:0] rd1,
    input [31:0] rd2,
    input [31:0] alu_rslt,
    input [31:0] m_rd,
    
    output run,
    output reg [7:0] m_rf_addr,
    output reg [15:0] led=0,
    output reg [7:0] an,
    output reg [7:0] seg,
    output reg [31:0] display=0   //
    );
    
    
    wire step_edg,dec_edg,inc_edg;
    
    assign run = succ | step_edg;
    
    get_edg        EDG1(.clk0(clk),.rst0(rst),.y(step),.q(step_edg));
    get_edg        EDG2(.clk0(clk),.rst0(rst),.y(dec),.q(dec_edg));
    get_edg        EDG3(.clk0(clk),.rst0(rst),.y(inc),.q(inc_edg));

    
      
    always @ (posedge clk, posedge rst)
    begin
        if (rst) 
        begin
            m_rf_addr <= 8'h02;
        end 
        else if (inc_edg)         
        begin
            m_rf_addr = m_rf_addr + 8'h01;
        end 
        else if (dec_edg)
        begin
            m_rf_addr = m_rf_addr - 8'h01;
        end         
    end
    
    always@(*)
    begin
    case (sel)
        3'b000:begin 
             if(m_rf)
                    begin
                    display <=  m_data;                        
                    end
             else begin                  
                    display <= rf_data;
                    end 
              led <= {8'h00,m_rf_addr};      
            end
   3'b001:begin 
            display <= pc_in  ; 
            led <= {4'b0,status};
          end
    3'b010:begin 
            display <= pc_out  ; 
            led <= {4'b0,status};
          end
    3'b011:begin 
    display <= instr  ; 
           led <= {4'b0,status};
          end         
    3'b100:begin 
            display <= rd1  ; 
            led <= {4'b0,status};
          end         
   3'b101:begin 
            display <= rd2  ; 
            led <= {4'b0,status};
          end         
     3'b110:begin 
            display <=  alu_rslt ; 
            led <= {4'b0,status};
          end        
     3'b111: begin
             display <= m_rd ;
             led <= {4'b0,status};
             end  
     default: begin
              display <= 0;
              led <= 16'h0000; 
              end                           
   endcase
end
endmodule

