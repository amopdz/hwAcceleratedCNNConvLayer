`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/23/2023 12:59:52 PM
// Design Name: 
// Module Name: controller
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


module controller(clk,dataIn,dataOut);
`define FPU
`ifndef FPU
localparam width=8;
localparam out_width=8;
`else
localparam width=32;
localparam out_width=32;
`endif
parameter dataWidth=32;
parameter col=3;
parameter row=3;
parameter channel=3;
parameter depth=2;
parameter k_size=2;
parameter stride=1;
parameter pad_size=1;
parameter mem_size=4096;
localparam integer col_size=(col-k_size+2*pad_size)/stride+1;
localparam integer row_size=(row-k_size+2*pad_size)/stride+1;

input clk;
input [dataWidth-1:0] dataIn;
output reg [dataWidth-1:0]dataOut;

reg [mem_size-1:0]memoryIn;
reg [mem_size-1:0]memoryReady;
reg [mem_size-1:0]memoryOut;
wire [depth*col_size*row_size*out_width-1:0]memoryConv;
reg [mem_size/width:0]addrRead;
reg [mem_size/width:0]addrWrite;
reg readyConv;
wire doneConv;
reg [1:0]bitComp;

wire doneK;
wire [width*channel-1:0]Kmap;

getKernelParam #(.width(width),
                 .size(channel))
               getKernelParam(.clk(clk),
                              .rst(dataIn[dataWidth-1]|dataIn[dataWidth-3]|dataIn[dataWidth-5]),
                              .kerMap(Kmap),
                              .done(doneK));

convolution #(.width(width),
              .out_width(out_width),
              .col(col),
              .row(row),
              .channel(channel),
              .depth(depth),
              .k_size(k_size),
              .stride(stride),
              .pad_size(pad_size))
            conv_unit(.clk(clk),
                      .rst(dataIn[dataWidth-1]),
                      .en(readyConv),
                      .a(memoryReady[mem_size-1-depth*k_size*k_size*channel*width-depth*out_width -: col*row*channel*width]),
                      .b(memoryReady[mem_size-1 -: depth*k_size*k_size*channel*width]),
                      .c(memoryReady[mem_size-1-depth*k_size*k_size*channel*width -: depth*out_width]),
                      .Kmap(Kmap),
                      .y(memoryConv),
                      .done(doneConv));

//Convolution controller
always @(posedge clk)begin
    if(dataIn[dataWidth-1])begin
        memoryReady = 0;
        readyConv = 0;
        dataOut[dataWidth-4 -: 3] = 'h0;
    end else if(dataIn[dataWidth-2]  && !readyConv)begin
        memoryReady = memoryIn;
        readyConv = 1;
    end
    dataOut[dataWidth-1]<=doneConv;
end

//Read controller
always @(posedge clk)begin
    if (dataIn[dataWidth-3] && dataIn[dataWidth-4]) begin   //reset input map, not reset kernel
        bitComp[1] = 0;
        addrRead = mem_size-depth*k_size*k_size*channel*width-depth*out_width;
        memoryIn[addrRead-1 -: col*row*channel*width] = 'h0;
        dataOut[dataWidth-2] = 0;
        dataOut[dataWidth-7] = 0;
    end else if(dataIn[dataWidth-3]) begin  //reset both input map and kernel
        bitComp[1] = 0;
        memoryIn = 0;
        addrRead = mem_size;
        dataOut[dataWidth-2] = 0;
        dataOut[dataWidth-7] = 0;
    end else if(dataIn[dataWidth-4] && !dataOut[dataWidth-2] && dataIn[dataWidth-7]==bitComp[1])begin   //inputting
        bitComp[1] = !bitComp[1];
        dataOut[dataWidth-7] <= bitComp[1];
        memoryIn[addrRead-1 -: dataWidth-8] = dataIn[dataWidth-9 -: dataWidth-8];
        addrRead = addrRead-(dataWidth-8);
        if(addrRead <= mem_size-(col*row*channel+depth*k_size*k_size*channel)*width-depth*out_width)begin
            dataOut[dataWidth-2] = 1;
        end
    end
end

//Write controller
always @(posedge clk)begin
    if (dataIn[dataWidth-5] && dataIn[dataWidth-6]) begin
        dataOut[dataWidth-9 -: dataWidth-8] = dataIn[dataWidth-9 -: dataWidth-8];
    end else if(dataIn[dataWidth-5])begin
        bitComp[0] = 0;
        memoryOut = 0;
        addrWrite = mem_size;
        dataOut[dataWidth-3] = 0;
        dataOut[dataWidth-8] = 0;
    end else if(dataIn[dataWidth-6] && !dataOut[dataWidth-3] && dataIn[dataWidth-8]==bitComp[0])begin
        bitComp[0] = !bitComp[0];
        dataOut[dataWidth-8] <= bitComp[0];
        if(addrWrite == mem_size)begin
            memoryOut[mem_size-1 -: depth*col_size*row_size*out_width] = memoryConv;
        end
        dataOut[dataWidth-9 -: dataWidth-8] = memoryOut[addrWrite-1 -: dataWidth-8];
        addrWrite = addrWrite-(dataWidth-8);
        if(addrWrite <= mem_size-depth*col_size*row_size*out_width)begin
            dataOut[dataWidth-3] <= 1;
        end
    end
end

endmodule
