`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/14/2023 09:28:23 PM
// Design Name: 
// Module Name: floatAdd
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

module floatAdd(rst,en,a,b,y,done);

input rst;
input en;
input [31:0]a;
input [31:0]b;
output [31:0]y;
output done;
wire [23:0]operandA;
wire [23:0]operandB;
wire [24:0]mantissaA;
wire [24:0]mantissaB;
wire [24:0]mantissaRes;
wire [7:0]expA;
wire [7:0]expB;
wire [8:0]expRes;
wire overflow;
wire underflow;
wire round;
wire sign;

//assign operandA={|a[22:0],a[22:0]}>>(expB>expA?(expB-expA):0);
//assign operandB={|b[22:0],b[22:0]}>>(expA>expB?(expA-expB):0);
assign operandA={|a[30:23],a[22:0]}>>(expB>expA?(expB-expA):0);
assign operandB={|b[30:23],b[22:0]}>>(expA>expB?(expA-expB):0);
assign mantissaA={a[31],operandA};
assign mantissaB={b[31],operandB};
assign expA=a[30:23];
assign expB=b[30:23];
assign sign=expA>expB?a[31]:
            expB>expA?b[31]:
            mantissaA>mantissaB?a[31]:b[31];
assign mantissaRes=mantissaA+mantissaB;
assign overflow=mantissaRes[24]&&!a[31]&&!b[31];
assign underflow=!mantissaRes[24]&&a[31]&&b[31];
assign expRes=overflow-underflow+(expA>expB?expA:expB);
assign round=(((!expRes[8]&&overflow)||(!(&expRes)&&underflow))&&!(&mantissaRes[24:2])&&mantissaRes[1])?1:
             (!expRes[8]&&!(&expRes)&&!(mantissaRes[24]&&sign)&&!(&mantissaRes[23:1])&&mantissaRes[0])?1:0;
assign y=(a!=32'b0&&b==32'b0)?a:
         (b!=32'b0&&a==32'b0)?b:
         expRes[8]?{sign,31'hFFFFFFFF}:
         (&expRes)?32'h00000000:
         ((!expRes[8]&&overflow)||(!(&expRes)&&underflow))?{sign,expRes[7:0],mantissaRes[23:1]}:
         (mantissaRes[24]&&sign)?{sign,expRes[7:0],mantissaRes[22:0]}:
         {sign,expRes[7:0],mantissaRes[23:1]};
assign done=!rst&&en;

endmodule

//=================================================================================================================================================================================================

//module floatAdd(rst,en,a,b,y,done);

//input rst;
//input en;
//input [31:0]a;
//input [31:0]b;
//output [31:0]y;
//output done;
//wire [23:0]mantissaA;
//wire [23:0]mantissaB;
//wire [25:0]mantissaRes;
//wire [7:0]expA;
//wire [7:0]expB;
//wire [8:0]expRes;
//wire overflow;
//wire underflow;
//wire round;
//wire sign;
//wire [1:0]avsb;

////assign mantissaA={|a[22:0],a[22:0]};
////assign mantissaB={|b[22:0],b[22:0]};
//assign mantissaA={|a[22:0],a[22:0]}>>(expB>expA?(expB-expA):0);
//assign mantissaB={|b[22:0],b[22:0]}>>(expA>expB?(expA-expB):0);
////assign sign=expA>expB?a[31]:
////            expB>expA?b[31]:
////            mantissaA>mantissaB?a[31]:b[31];
////assign mantissaA={|a[22:0],a[22:0]}*(a[31]?(-1):1);
////assign mantissaB={|b[22:0],b[22:0]}*(b[31]?(-1):1);
//assign expA={1'b0,a[30:23]};
//assign expB={1'b0,b[30:23]};
//assign avsb=expA>expB?1:
//            expA<expB?-1:
//            expA==expB?0:
//            mantissaA>mantissaB?1:
//            mantissaA<mantissaB?-1:0;
////assign mantissaRes=expA>expB?mantissaA+(mantissaB>>(expA-expB)):
////                   expB>expA?(mantissaA>>(expB-expA))+mantissaB:
////                   mantissaA+mantissaB;
////assign mantissaRes=(a[31]?-mantissaA:mantissaA)+(b[31]?-mantissaB:mantissaB);
//assign mantissaRes=mantissaA+mantissaB;
//assign overflow=(mantissaRes[25:24]==2'b01)
//                &&(((expA>expB)&&(!a[31]))
//                   ||((expB>expA)&&(!b[31]))
//                   ||((expA==expB)&&(!a[31])&&(!b[31])));
//assign underflow=(mantissaRes[25:24]==2'b10);
//assign expRes=overflow-underflow+(expA>expB?expA:expB);
//assign round=(!expRes[8]&&!(&expRes)&&overflow&&!(&mantissaRes[24:2])&&(mantissaRes[1]))?1:
//             (!expRes[8]&&!(&expRes)&&!overflow&&!(&mantissaRes[23:1])&&mantissaRes[0])?1:0;
//assign y[30:0]=expRes[8]?31'hFFFFFFFF:
//               (&expRes)?31'h00000000:
//               (!expRes[8]&&overflow)?{expRes[7:0],mantissaRes[24:2]+round}:
//               {expRes[7:0],mantissaRes[23:1]+round};
////assign y[30:0]=expRes[8]?31'hFFFFFFFF:
////              (&expRes)?31'h00000000:
////              (!expRes[8]&&overflow)?{expRes[7:0],mantissaRes[24:2]+((&mantissaRes[24:2])?mantissaRes[1]:0)}:
////              {expRes[7:0],mantissaRes[23:1]+((&mantissaRes[23:1])?mantissaRes[0]:0)};
////               (!expRes[8]&&overflow&&mantissaRes[0]&&!(&mantissaRes[23:1]))?1://Rounding
////               (!expRes[8]&&!(&expRes)&&!overflow&&!(&mantissaRes[24:2])&&(|mantissaRes[1:0]))?1:0;
//assign done=!rst&&en;

//endmodule

//=================================================================================================================================================================================================

//module floatA(clk,rst,en,a,b,y,done);

//input clk;
//input rst;
//input en;
//input [31:0]a;
//input [31:0]b;
//output reg [31:0]y;
//output reg done;
//reg [25:0]mantissaA;
//reg [25:0]mantissaB;
//reg [25:0]mantissaRes;
//reg [8:0]expA;
//reg [8:0]expB;
//reg [8:0]expRes;
//reg overflow;
//reg underflow;

//always @(posedge clk)begin
//    if(rst)begin
//        done='b0;
//        y='b0;
//        mantissaRes='b0;
//        expRes='b0;
//    end else if(en)begin
//        if(!done)begin
//            expA=a[30:23];
//            expB=b[30:23];
//            if(expA>expB)begin
//                y[31]=a[31];
//                expRes=expA;
//                mantissaA={a[31],1'b1,a[22:0]};
//                mantissaB=({b[31],1'b1,b[22:0]})>>(a[30:23]-b[30:23]);
//            end else if(expB>expA)begin
//                y[31]=b[31];
//                expRes=expB;
//                mantissaA=({a[31],1'b1,a[22:0]})>>(b[30:23]-a[30:23]);
//                mantissaB={b[31],1'b1,b[22:0]};
//            end else begin
//                y[31]=a[22:0]>b[22:0]?a[31]:b[31];
//                expRes=expA;
//                mantissaA={a[31],1'b1,a[22:0]};
//                mantissaB={b[31],1'b1,b[22:0]};
//            end
//            mantissaRes=mantissaA+mantissaB;
//            overflow<=mantissaRes[25:24]==2'b01;
//            underflow<=mantissaRes[25:24]==2'b10;
//            if(overflow)begin//Overflow
//                expRes<=expRes+1;
//                if(expRes[8])y[30:0]<=31'hFFFFFFFF;
//                else begin
//                    y[30:0]<={expRes[7:0],mantissaRes[23:1]};
////                    y[30:23]=expRes[7:0];
////                    y[22:0]=mantissaRes[23:1];
//                end
//            end else if(underflow)begin//Underflow
//                expRes<=expRes-1;
//                if(&expRes)y<=32'h00000000;
//                else begin
//                    y[30:0]<={expRes[7:0],mantissaRes[24:2]};
////                    y[30:23]=expRes[7:0];
////                    y[22:0]=mantissaRes[24:2];
//                end
//            end else begin
//                y[30:0]<={expRes[7:0],mantissaRes[24:2]};
////                y[30:23]=expRes[7:0];
////                y[22:0]=mantissaRes[24:2];
//            end
//            done<=1;
            
////            expRes<=expRes+(mantissaRes[25:24]==2'b01)?1:(mantissaRes[25:24]==2'b10)?(-1):0;
////            mantissaRes<=expRes[8]?'hFFF:mantissaRes[24]?mantissaRes:mantissaRes<<1;
////            y[22:0]<=mantissaRes[23:1];
////            y[30:23]<=expRes[8]?8'hFF:expRes[7:0];
////            done<=1;

////            if(a[30:23]>b[30:23])begin
////                y[31]=a[31];
////                expRes=a[30:23];
////                mantissaA={1'b1,a[22:0]};
////                mantissaB=({1'b1,b[22:0]})>>(a[30:23]-b[30:23]);
////            end else if(b[30:23]>a[30:23])begin
////                y[31]=b[31];
////                expRes=b[30:23];
////                mantissaA=({1'b1,a[22:0]})>>(b[30:23]-a[30:23]);
////                mantissaB={1'b1,b[22:0]};
////            end else begin
////                y[31]=a[22:0]>b[22:0]?a[31]:b[31];
////                expRes=a[30:23];
////                mantissaA={1'b1,a[22:0]};
////                mantissaB={1'b1,b[22:0]};
////            end
////            mantissaRes<=mantissaA+mantissaB;
////            expRes<=expRes+mantissaRes[24];
////            mantissaRes<=expRes[8]?'hFFF:mantissaRes[24]?mantissaRes:mantissaRes<<1;
////            y[22:0]<=mantissaRes[23:1];
////            y[30:23]<=expRes[8]?8'hFF:expRes[7:0];
////            done<=1;
            
//            //Compare, Shift & Add
////            y[31]=a[30:23]>b[30:23]?a[31]:
////                  b[30:23]>a[30:23]?b[31]:
////                  a[22:0]>b[22:0]?a[31]:
////                                  b[31];
////            mantissaRes<=a[30:23]>b[30:23]?{1'b1,a[22:0]}+{1'b1,b[22:0]}>>(a[30:23]-b[30:23]):
////                         b[30:23]>a[30:23]?{1'b1,a[22:0]}>>(b[30:23]-a[30:23])+{1'b1,b[22:0]}:
////                         {1'b1,a[22:0]}+{1'b1,b[22:0]};
////            //Largest exponential + If decimal part of mantissa added >= 2
////            expRes<=a[30:23]>b[30:23]?a[30:23]:b[30:23]+mantissaRes[24];
////            //Check overflow first, else if decimal part of mantissa added >= 2, divide by 2
////            mantissaRes<=expRes[8]?25'hFFF:mantissaRes[24]?mantissaRes:mantissaRes<<1;
////            y[22:0]<=mantissaRes[23:1];
////            //Overflow if exponential larger than 255
////            y[30:23]<=expRes[8]?8'hFF:expRes[7:0];
////            done<=1;
//        end
//    end
//end

//endmodule

//=================================================================================================================================================================================================

//module floatAdd(clk,rst,en,a,b,y,done);

//input clk;
//input rst;
//input en;
//input [31:0]a;
//input [31:0]b;
//output [31:0]y;
//output done;

////wire wDone;
//adder Add(.clk(clk),
//      .en(en),
//      .reset(rst),
//      .operand_1(a),
//      .operand_2(b),
//      .Sum(y),
//      .done_4(done));

////check #(.size(1))
////      checker(.clk(clk),
////              .rst(rst),
////              .en(en),
////              .a(wDone),
////              .done(done));

//endmodule

//=================================================================================================================================================================================================

//module adder(operand_1,operand_2,clk,reset,en,Sum,done_1,done_2,done_3,done_4);

////Declaring input and outputs
//input [31:0] operand_1;
//input [31:0] operand_2;
//input clk;
//input en;
//input reset;
//output [31:0] Sum;
//output done_1,done_2,done_3;
//output reg done_4;
//reg [31:0] sum;
////Declaration of other variables
//reg [7:0] exponent_1, exponent_2;
//reg [23:0] mantissa_1, mantissa_2;
//reg [7:0] new_exponent;
//wire [7:0] exponent_final;
//wire [23:0] mantissa_final;
//reg [24:0] mantissa_sum;
//reg [23:0] shifted_mantissa_1,shifted_mantissa_2;
//wire [23:0] cas_shifted_mantissa_1,cas_shifted_mantissa_2;
//wire [24:0] add_mantissa_sum;
//reg [7:0] tmp_new_exponent;
//wire [7:0] add_new_exponent;
//wire [7:0] cas_new_exponent;


//reg busy_1=0;
//reg busy_2=0;
//reg busy_3=0;

//compandshift cas(mantissa_1,mantissa_2,exponent_1,exponent_2,clk,reset,cas_shifted_mantissa_1,cas_shifted_mantissa_2,cas_new_exponent,done_1);
//addition add(shifted_mantissa_1,shifted_mantissa_2,tmp_new_exponent,clk,reset,add_mantissa_sum,add_new_exponent,done_2); 
//normalisation normalise(mantissa_sum,new_exponent,clk,reset,mantissa_final,exponent_final,done_3);

//always @(posedge clk)
//begin
//    if(reset)begin
//        busy_1=0;
//        busy_2=0;
//        busy_3=0;
//        done_4=0;
//    end
//    else if(en)begin
//    if(busy_1==0)
//    begin
//        exponent_1<=operand_1[30:23];
//        exponent_2<=operand_2[30:23];
//        mantissa_1<={1'b1,operand_1[22:0]};
//        mantissa_2<={1'b1,operand_2[22:0]};
//        busy_1<=1;    
//    end
//    else if (done_1==1 && busy_2==0)
//    begin
//        shifted_mantissa_1<=cas_shifted_mantissa_1;
//        shifted_mantissa_2<=cas_shifted_mantissa_2;
//        tmp_new_exponent<=cas_new_exponent;
//        busy_1<=0;
//        busy_2<=1;
//    end
//    else if(done_2==1 && busy_3==0)
//    begin
//        mantissa_sum <= add_mantissa_sum;
//        new_exponent <= add_new_exponent;
//        busy_2<=0;
//        busy_3<=1;
//    end
//    else if(done_3==1)
//    begin
//        sum<={operand_1[31],exponent_final,mantissa_final[22:0]};
//        busy_3<=0;
//        done_4<=1;
//        // $display("module:%b",sum);
//    end
//    end
//end
//assign Sum = sum; 
//endmodule

////=================================================================================================================================================================================================
////This module Compares Exponent of both inputs and shifts mantissa to make exponent equal.
//module compandshift(cas_mantissa_1,cas_mantissa_2,cas_exponent_1,cas_exponent_2,clk,reset,cas_shifted_mantissa_1,cas_shifted_mantissa_2,cas_new_exponent,done_1);

//input [23:0] cas_mantissa_1, cas_mantissa_2;
//input [7:0] cas_exponent_1, cas_exponent_2;
//input clk,reset;
//output reg [23:0] cas_shifted_mantissa_1,cas_shifted_mantissa_2;
//output reg [7:0] cas_new_exponent;
//output reg done_1=0;
//reg [7:0] diff; 

//always @(posedge clk)
//begin
//    if(cas_exponent_1 == cas_exponent_2)
//    begin
//        cas_shifted_mantissa_1<=cas_mantissa_1;
//        cas_shifted_mantissa_2<=cas_mantissa_2;
//        cas_new_exponent<=cas_exponent_1+1'b1;
//        done_1<=1;
//    end
//    else if(cas_exponent_1>cas_exponent_2)
//    begin
//        diff=cas_exponent_1-cas_exponent_2;
//        cas_shifted_mantissa_1<=cas_mantissa_1;
//        cas_shifted_mantissa_2<=(cas_mantissa_2>>diff);
//        cas_new_exponent<=cas_exponent_1+1'b1;
//        done_1<=1;
//    end
//    else if(cas_exponent_2>cas_exponent_1)
//    begin
//        diff=cas_exponent_2-cas_exponent_1;
//        cas_shifted_mantissa_2<=cas_mantissa_2;
//        cas_shifted_mantissa_1<=(cas_mantissa_1>>diff);
//        cas_new_exponent<=cas_exponent_2+1'b1;
//        done_1<=1;
//    end
//end
//endmodule
////=============================================================================================================================================================================================
////This module add shifted mantissas
//module addition(shifted_mantissa_1,shifted_mantissa_2,tmp_new_exponent,clk,reset,mantissa_sum,add_new_exponent,done_2);
//input [23:0] shifted_mantissa_1;
//input [23:0] shifted_mantissa_2;
//input [7:0] tmp_new_exponent;
//input clk,reset;
//output reg [24:0] mantissa_sum;
//output reg done_2=0;
//output reg [7:0] add_new_exponent;
//always @(posedge clk)
//begin
//    mantissa_sum<=shifted_mantissa_1+shifted_mantissa_2;
//    add_new_exponent<=tmp_new_exponent;
//    if(mantissa_sum==(shifted_mantissa_1+shifted_mantissa_2))
//    begin
//        done_2<=1;
//    end
//end 
//endmodule

////==============================================================================================================================================================================================
////This module normalises the output mantissa
//module normalisation(mantissa_sum,new_exponent,clk,reset,mantissa_final,exponent_final,done_3);
//input [24:0] mantissa_sum;
//input [7:0] new_exponent;
//input clk,reset;
//output reg [23:0] mantissa_final;
//output reg [7:0] exponent_final;
//output reg done_3=0;
//reg rst=0;

//always @(posedge clk)
//begin
//    if(rst==0)
//    begin
//        mantissa_final<=mantissa_sum[24:1];
//        exponent_final<=new_exponent;
//        if(mantissa_final==mantissa_sum[24:1])
//        begin
//            rst<=1;
//        end
//    end
//    else begin
//        repeat(24) begin
//            if(mantissa_final[23]==0)
//            begin
//                mantissa_final<=(mantissa_final<<1'b1);
//                exponent_final<=exponent_final-1'b1;
//            end
//            else begin
//                done_3<=1;
//                rst<=0;
//            end
//        end
//    end
//end
//endmodule
//=====================================================================================================================================================================================
