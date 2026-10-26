`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/10/19 14:03:28
// Design Name: 
// Module Name: diff
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


module dff (
    input      clk,
    input      clr,
    input      en ,
    input      d  ,
    output reg q
);

always @ (posedge clk or posedge clr) begin
    if(clr)begin
        q<=1'b0;
    end else if(en)begin
        q<=d;
    end

end
endmodule
