`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/01/2023 11:48:35 PM
// Design Name: 
// Module Name: convolution
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


module convolution(clk,rst,en,a,b,c,Kmap,y,done);

parameter width=8;
parameter out_width=8;
parameter col=3;
parameter row=3;
parameter channel=3;
parameter depth=2;
parameter k_size=2;
parameter stride=1;
parameter pad_size=1;
parameter integer col_size=((col-k_size+2*pad_size)/stride+1);
parameter integer row_size=((row-k_size+2*pad_size)/stride+1);

input clk;
input rst;
input en;
input [col*row*channel*width-1:0]a;
input [depth*k_size*k_size*channel*width-1:0]b;
input [depth*out_width-1:0]c;
input [width*channel-1:0]Kmap;
output [depth*col_size*row_size*out_width-1:0]y;
output done;

//Stage 1: Padding (DONE)
wire [channel*(col+2*pad_size)*(row+2*pad_size)*width-1:0]X;

generate
genvar i,j,k;
for(i=0;i<channel;i=i+1) begin  //assigning input values
    for(j=0;j<row;j=j+1) begin
        for(k=0;k<col;k=k+1) begin
            assign X[(i*(row+2*pad_size)*(col+2*pad_size)+(j+pad_size)*(col+2*pad_size)+k+pad_size+1)*width-1 -: width]
                  =a[(i*row*col+j*col+k+1)*width-1 -: width];
        end
    end
end
for(i=0;i<channel;i=i+1) begin  //zero padding
    for(j=0;j<pad_size;j=j+1) begin //upper & lower
        for(k=0;k<(col+2*pad_size)*width;k=k+1) begin   //assigning bit by bit to the whole row
            assign X[(i*(row+2*pad_size)*(col+2*pad_size)+j*(col+2*pad_size))*width+k]=1'b0;    //upper
            assign X[(i*(row+2*pad_size)*(col+2*pad_size)+(j+row+pad_size)*(col+2*pad_size))*width+k]=1'b0; //lower
        end
    end
    for(j=0;j<row;j=j+1) begin  //left & right, row by row
        for(k=0;k<pad_size*width;k=k+1) begin   //assigning bit by bit to each padded elements in a row
            assign X[(i*(row+2*pad_size)*(col+2*pad_size)+(j+pad_size)*(col+2*pad_size))*width+k]=1'b0; //left
            assign X[(i*(row+2*pad_size)*(col+2*pad_size)+(j+pad_size)*(col+2*pad_size)+col+pad_size)*width+k]=1'b0;    //right
        end
    end
end
endgenerate

//Stage 2: Wiring padded input (DONE)
wire [channel*k_size*k_size*width-1:0]W[col_size*row_size-1:0];

generate
genvar l,m,n,o;
for(l=0;l<col_size*row_size;l=l+1)    //going channel by channel
begin
    for(m=0;m<channel;m=m+1)  //going receptive field by receptive field
    begin
        for(n=0;n<k_size;n=n+1) //going row by row
        begin
            for(o=0;o<k_size;o=o+1) //going column by column
            begin
                 assign W[l][(m*k_size*k_size+n*k_size+o+1)*width-1 -: width]
                      =X[(m*(row+2*pad_size)*(col+2*pad_size)+(n+l/col_size*stride)
                      *(col+2*pad_size)+o+l%row_size*stride+1)*width-1 -: width];
            end
        end
    end
end
endgenerate

//Stage 3: Convolution
/*
    IDEA:
    1. Apply convolution on each receptive field to get 1 output
    2. Apply it by #channels => size: channel*output_col*output_row
    3. Apply it by #depths => size: depth*channel*output_col*output_row
        #check bits: depth*channel*output_col*output_row
    4. If all check bits in 1 channel is 1 -> done is enabled -> enable signal for convolution of a channel
    5. Apply convolution for a channel by #output_col*output_row*depth => size: depth*output_row*output_col
    DONE IDEA
*/
wire [channel*out_width-1:0]Y[depth-1:0][col_size*row_size-1:0];  //temporary output
wire [channel-1:0]Z[depth-1:0][col_size*row_size-1:0];  //checker bits
wire C[depth-1:0][col_size*row_size-1:0];   //checker output
wire [depth*col_size*row_size-1:0]D;    //final checker bits

generate
genvar p,q,r,s;
for(p=0;p<depth;p=p+1)
begin: by_depth
    for(q=0;q<col_size*row_size;q=q+1)
    begin: by_receptive_field
        for(r=0;r<channel;r=r+1)
        begin: by_channel
            mac #(.width(width),
                  .out_width(out_width),
                  .size(k_size*k_size))
                mac_on_padded(.clk(clk),
                              .rst(rst),
                              .en(en),
                              .a(W[q][(r+1)*k_size*k_size*width-1 -: width*k_size*k_size]),
                              .b(b[(p*channel+r+1)*width*k_size*k_size-1 -: width*k_size*k_size]),
                              .c('b0),
                              .y(Y[p][q][(r+1)*out_width-1 -: out_width]),
                              .done(Z[p][q][r]));
        end
        check #(.size(channel))
              check_channel(.clk(clk),
                            .rst(rst),
                            .en(en),
                            .a(Z[p][q]),
                            .done(C[p][q]));
        mac #(.width(out_width),
              .out_width(out_width),
              .size(channel))
            mac_on_whole_channel(.clk(clk),
                                 .rst(rst),
                                 .en(en&&C[p][q]),
                                 .a(Y[p][q]),
                                 .b(Kmap),
                                 .c(c[(p+1)*out_width-1 -: out_width]),
                                 .y(y[(p*col_size*row_size+q+1)*out_width-1 -: out_width]),
                                 .done(D[p*col_size*row_size+q]));
    end
end
endgenerate
check #(.size(channel))
      check_whole_depth(.clk(clk),
                        .rst(rst),
                        .en(en),
                        .a(D),
                        .done(done));
endmodule