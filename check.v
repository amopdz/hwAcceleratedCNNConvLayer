`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/01/2023 11:53:16 PM
// Design Name: 
// Module Name: check
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


module check(clk,rst,en,a,done);

parameter size=9;

input clk;
input rst;
input en;
input [size-1:0]a;
output reg done;

always @(posedge clk)
begin
    if(rst) begin
        done<=0;
    end else if(en) begin
        done<=&a;
    end
end

endmodule
