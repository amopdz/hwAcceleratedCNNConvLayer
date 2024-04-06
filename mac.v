`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/01/2023 10:54:11 PM
// Design Name: 
// Module Name: autoMac
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


module mac(clk,rst,en,a,b,c,y,done);
//`define FPU
parameter width=8;
parameter out_width=8;
parameter size=9;

input clk;
input rst;
input en;
input [size*width-1:0]a;
input [size*width-1:0]b;
input [width-1:0]c;
output reg [out_width-1:0]y;
output reg done;

reg [width-1:0]addr;

`ifndef FPU
//localparam numStage=$clog2(size);

//wire [size*width-1:0]wA;
//wire [size*width-1:0]wB;

//assign wA=a;
//assign wB=b;

//wire [size*width-1:0]temp;
//wire [size-1:0]doneMul;
//wire doneMulCheck;
//generate
//genvar i;
//for(i = 0; i<size; i=i+1)begin
//    intMul(.clk(clk),
//           .rst(rst),
//           .en(en),
//           .a(wA[(i+1)*width-1-:width]),
//           .b(wB[(i+1)*width-1-:width]),
//           .y(temp[(i+1)*width-1-:width]));
//end
//endgenerate
//check #(.size(size))
//      mulCheck(.clk(clk),
//               .rst(rst),
//               .en(en),
//               .a(doneMul),
//               .done(doneMulCheck));

//wire []doneAddCheck;

always @(posedge clk)
begin
    if(rst)begin
        y=0;
    end else if(en) begin
        if(addr==0)begin
            y=a[(addr+1)*width-1 -: width]*b[(addr+1)*width-1 -: width]+c;
        end else if((0<addr)&(addr<size)) begin
            y=a[(addr+1)*width-1 -: width]*b[(addr+1)*width-1 -: width]+y;
        end
    end
end

always @(posedge clk) begin
    if(rst) begin
        done = 0;
        addr = 0;
    end else if(en) begin
        addr <= addr + 1;
        if(addr>=size) begin
            done = 1;
        end
    end
end
`else

wire [size*width-1:0]temp;
wire [size-1:0]doneAdd;
wire [size*width-1:0]tempAdd;
wire [size-1:0]doneMul;
generate
genvar k;
for(k=0;k<size;k=k+1)begin: Mul
floatMul FPUMul(//.clk(clk),
                 .rst(rst),
                 .en(en),
                 .a(a[(k+1)*width-1-:width]),
                 .b(b[(k+1)*width-1-:width]),
                 .y(temp[(k+1)*width-1-:width]),
                 .done(doneMul[k]));
end
floatAdd FPUAdd0(//.clk(clk),
         .rst(rst),
         .en(en&& &doneMul),
         .a(temp[width-1-:width]),
         .b(c),
         .y(tempAdd[width-1-:width]),
         .done(doneAdd[0]));
for(k=1;k<size;k=k+1)begin: Add
floatAdd FPUAdd(//.clk(clk),
         .rst(rst),
         .en(en&&doneAdd[k-1]),
         .a(tempAdd[k*width-1-:width]),
         .b(temp[(k+1)*width-1-:width]),
         .y(tempAdd[(k+1)*width-1-:width]),
         .done(doneAdd[k]));
 end
endgenerate

always @(posedge clk)begin
    if(rst)begin
        done=0;
        addr=0;
    end else if(en)begin
        y=tempAdd[size*width-1-:width];
        done=&doneAdd;
    end
end

`endif
endmodule
