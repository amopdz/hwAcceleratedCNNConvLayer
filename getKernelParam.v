`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/08/2023 03:45:26 PM
// Design Name: 
// Module Name: getKernelParam
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


module getKernelParam(clk,rst,kerMap,done);

parameter width = 8;
parameter size = 3;
input clk;
input rst;
output reg [width*size-1:0]kerMap;
output reg done;
reg i;

always @(posedge clk)begin
    if(rst)begin
        kerMap = 0;
        i = 0;
        done = 0;
    end else begin
        if(i<size)begin
        `ifndef FPU
            kerMap = (kerMap<<width)|'h1;
        `else
            kerMap = (kerMap<<width)|'h3f800000;
        `endif
            i=i+1;
            if(i>=size)done=1;
        end
    end
end

endmodule
