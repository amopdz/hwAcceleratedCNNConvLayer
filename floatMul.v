`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/14/2023 10:59:08 PM
// Design Name: 
// Module Name: floatMul
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

module floatMul(rst,en,a,b,y,done);

//input clk;
input rst;
input en;
input[31:0]a;
input[31:0]b;
output [31:0]y;
output done;

wire [47:0]temp;
wire [9:0]exp;
wire overflow;
wire underflow;
wire round;

//assign y[31]=a[31]^b[31];
////assign temp=(|a[22:0])?{1'b1,a[22:0]}:(24'b0)*(|b[22:0])?{1'b1,b[22:0]}:(24'b0);
//assign temp={|a[22:0],a[22:0]}*{|b[22:0],b[22:0]};
//assign exp=a[30:23]+b[30:23]+temp[47]-'d127;
//assign overflow=exp[9:8]==2'b01;
//assign underflow=exp[9:8]==2'b10;
////assign round=0;
//assign round=(!temp[47]&&!(&temp[46:24])&&(|temp[23:0]))?1:
//             (temp[47]&&!(&temp[45:23])&&(|temp[22:0]))?1:0;
//assign y[30:0]=overflow?31'hFFFFFFFF:
//               underflow?31'h00000000:
//               (temp==48'b0)?31'b0:
//               temp[47]?{exp[7:0],temp[46:24]+round}:
//               {exp[7:0],temp[45:23]+round};//+(!overflow&&!underflow)?round:0;
////               (!overflow&&!underflow&&!temp[47]&&!(&temp[46:24])&&(|temp[23:0]))?1:
////               (!overflow&&!underflow&&temp[47]&&!(&temp[45:23])&&(|temp[22:0]))?1:0;
//assign done=!rst&&en;

//assign y[31]=a[31]^b[31];
//assign temp=(|a[22:0])?{1'b1,a[22:0]}:(24'b0)*(|b[22:0])?{1'b1,b[22:0]}:(24'b0);
assign temp={|a[22:0],a[22:0]}*{|b[22:0],b[22:0]};
assign exp=a[30:23]+b[30:23]+temp[47]-'d127;
assign overflow=exp[9:8]==2'b01;
assign underflow=exp[9:8]==2'b10;
assign round=(!temp[47]&&!(&temp[46:24])&&(|temp[23:0]))?1:
             (temp[47]&&!(&temp[45:23])&&(|temp[22:0]))?1:0;
assign y=overflow?{a[31]^b[31],31'hFFFFFFFF}:
         underflow?32'b0:
         (!(|a[30:23])||!(|b[30:23]))?32'b0:
         (temp==48'b0&&!(|a[22:0]))?{a[31]^b[31],exp[7:0],b[22:0]}:
         (temp==48'b0&&!(|b[22:0]))?{a[31]^b[31],exp[7:0],a[22:0]}:
         temp[47]?{a[31]^b[31],exp[7:0],temp[46:24]+round}:
         {a[31]^b[31],exp[7:0],temp[45:23]+round};
assign done=!rst&&en;

endmodule

//=================================================================================================================================================================================================
//module floatMult(clk,rst,en,a,b,y,done);

//input clk;
//input rst;
//input en;
//input[31:0]a;
//input[31:0]b;
//output reg[31:0]y;
//output reg done;

//reg [47:0]temp;
//reg [8:0]exp;

//always @(posedge clk)begin
//    if(rst)begin
//        done = 0;
//        temp = 0;
//    end else if(en)begin
//        if((&a[30:23])|(&b[30:23]))begin
//            y=32'b0;//Exception
//        end else begin
//            exp<=a[30:23]+b[30:23]-8'd127;
//            if(!exp[8]&&exp[7])begin
//                y[31]=a[31]^b[31];
//                y[30:23]=exp;
//                temp<={1'b1,a[22:0]}*{1'b1,b[22:0]};
//                temp<=temp[47]?temp:temp<<1;
//                y[22:0]<=temp[46:24]+|temp[23:0];
//            end else if(exp[8])begin//overflow
//                y<={a[31]^b[31],8'hFF,23'd0};
//            end else begin//underflow
//                y<={a[31]^b[31],31'b0};
//            end
//            done<=1;
//        end
//    end
//end

//endmodule

//=================================================================================================================================================================================================
//module floatMul(clk,rst,en,a,b,y,done);

//input clk;
//input rst;
//input en;
//input [31:0]a;
//input [31:0]b;
//output [31:0]y;
//output reg done;

//Multiplication Mul(.a_operand(a),
//               .b_operand(b),
//               .result(y));

////wire [31:0]result;
////wire sign,product_round,normalised,zero;
////wire [8:0] exponent,sum_exponent;
////wire [22:0] product_mantissa;
////wire [23:0] operand_a,operand_b;
////wire [47:0] product,product_normalised;
////wire Exception,Overflow,Underflow;

////assign sign = a[31]^b[31];
////assign Exception=(&a[30:23])|(&b[30:23]); //Exception flag sets 1 if either one of the exponent is 255.
////assign operand_a = {1'b1,a[22:0]};
////assign operand_b = {1'b1,b[22:0]};
////assign product = operand_a * operand_b;
////assign product_round = |product_normalised[22:0];  //Ending 22 bits are OR'ed for rounding operation.
////assign normalised = product[47] ? 1'b1 : 1'b0;	
////assign product_normalised = normalised ? product : product << 1;
////assign product_mantissa = product_normalised[46:24] + (product_normalised[23] & product_round);
////assign zero = Exception ? 1'b0 : (product_mantissa == 23'd0) ? 1'b1 : 1'b0;
////assign sum_exponent = a[30:23] + b[30:23];
////assign exponent = sum_exponent - 8'd127 + normalised;
////assign Overflow = ((exponent[8] & !exponent[7]) & !zero) ; //If overall exponent is greater than 255 then Overflow condition.
////assign Underflow = ((exponent[8] & exponent[7]) & !zero) ? 1'b1 : 1'b0; //If sum of both exponents is less than 127 then Underflow condition.
////assign result = Exception ? 32'd0 : zero ? {sign,31'd0} : Overflow ? {sign,8'hFF,23'd0} : Underflow ? {sign,31'd0} : {sign,exponent[7:0],product_mantissa};


//always @(posedge clk)begin
//    if(rst)begin
//        done=0;
//    end else if(en)begin
////        y<=result;
//        done<=1;
//    end
//end

//endmodule

////=================================================================================================================================================================================================
//module Multiplication(
//		input [31:0] a_operand,
//		input [31:0] b_operand,
//		output Exception,Overflow,Underflow,
//		output [31:0] result
//		);

//wire sign,product_round,normalised,zero;
//wire [8:0] exponent,sum_exponent;
//wire [22:0] product_mantissa;
//wire [23:0] operand_a,operand_b;
//wire [47:0] product,product_normalised; //48 Bits


//assign sign = a_operand[31] ^ b_operand[31];

////Exception flag sets 1 if either one of the exponent is 255.
//assign Exception = (&a_operand[30:23]) | (&b_operand[30:23]);

////Assigining significand values according to Hidden Bit.
////If exponent is equal to zero then hidden bit will be 0 for that respective significand else it will be 1

//assign operand_a = (|a_operand[30:23]) ? {1'b1,a_operand[22:0]} : {1'b0,a_operand[22:0]};

//assign operand_b = (|b_operand[30:23]) ? {1'b1,b_operand[22:0]} : {1'b0,b_operand[22:0]};

//assign product = operand_a * operand_b;			//Calculating Product

//assign product_round = |product_normalised[22:0];  //Ending 22 bits are OR'ed for rounding operation.

//assign normalised = product[47] ? 1'b1 : 1'b0;	

//assign product_normalised = normalised ? product : product << 1;	//Assigning Normalised value based on 48th bit

////Final Manitssa.
//assign product_mantissa = product_normalised[46:24] + (product_normalised[23] & product_round); 

//assign zero = Exception ? 1'b0 : (product_mantissa == 23'd0) ? 1'b1 : 1'b0;

//assign sum_exponent = a_operand[30:23] + b_operand[30:23];

//assign exponent = sum_exponent - 8'd127 + normalised;

//assign Overflow = ((exponent[8] & !exponent[7]) & !zero) ; //If overall exponent is greater than 255 then Overflow condition.
////Exception Case when exponent reaches its maximu value that is 384.

////If sum of both exponents is less than 127 then Underflow condition.
//assign Underflow = ((exponent[8] & exponent[7]) & !zero) ? 1'b1 : 1'b0; 

//assign result = Exception ? 32'd0 : zero ? {sign,31'd0} : Overflow ? {sign,8'hFF,23'd0} : Underflow ? {sign,31'd0} : {sign,exponent[7:0],product_mantissa};


//endmodule
