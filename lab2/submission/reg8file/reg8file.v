`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/10/19 14:35:22
// Design Name: 
// Module Name: reg8file
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


module reg8file (
    input  wire clk,  
    input  wire clr,    
    input  wire en,
    input  wire [7:0] d,
    input  wire [2:0] wsel,
    input  wire [2:0] rsel,
    output reg  [7:0] q    
);

reg [7:0] regfile[7:0];
integer i;

always @ (posedge clk or posedge clr) begin
    if(clr)begin
        for(i=0;i<8;i=i+1)begin
        regfile[i]<=8'h00;
        end
    end else if(en)begin
        regfile[wsel]<=d;
    end
end
    
always @ (*) begin
    q=regfile[rsel];
end

endmodule
