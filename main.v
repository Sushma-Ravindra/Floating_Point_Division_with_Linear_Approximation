`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/16/2024 02:36:41 PM
// Design Name: 
// Module Name: error_cal
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

module FloatingDivision#(parameter XLEN=32)
                        (input [XLEN-1:0]A,
                         input [XLEN-1:0]B,
                         input rst,
                         input clk,
                         output overflow,
                         output underflow,
                         output exception,
                         output [XLEN-1:0] result ,
                         output reg done);
                         
reg [23:0] A_Mantissa,B_Mantissa;
//reg [31:0] result2 = 32'd0;
reg [22:0] Mantissa;
wire [7:0] exp;
reg [23:0] Temp_Mantissa;
reg [7:0] A_Exponent,B_Exponent,Temp_Exponent,diff_Exponent;
wire [7:0] Exponent;
reg [7:0] A_adjust,B_adjust;
reg A_sign,B_sign,Sign;
reg [32:0] Temp;
wire [31:0] temp1,temp2,temp3,temp4,temp5,temp6,temp7,debug;
wire [31:0] reciprocal;
wire [31:0] x0,x1,x2,x3;
reg [6:0] exp_adjust;
reg [XLEN-1:0] B_scaled; 
reg en1,en2,en3,en4,en5;
reg dummy;
wire do;
/*----Initial value----*/
FloatingMultiplication M1(.A({{1'b0,8'd126,B[22:0]}}),.B(32'h3ff0f0f1),.clk(clk),.result(temp1)); //verified
assign debug = {1'b1,temp1[30:0]};
FloatingAddition A1(.A(32'h4034b4b5),.B({1'b1,temp1[30:0]}),.result(x0), .clk(clk));

/*----First Iteration----*/
FloatingMultiplication M2(.A({{1'b0,8'd126,B[22:0]}}),.B(x0),.clk(clk),.result(temp2));
FloatingAddition A2(.A(32'h40000000),.B({!temp2[31],temp2[30:0]}),.result(temp3), .clk(clk));
FloatingMultiplication M3(.A(x0),.B(temp3),.clk(clk),.result(x1));

/*----Second Iteration----*/
FloatingMultiplication M4(.A({1'b0,8'd126,B[22:0]}),.B(x1),.clk(clk),.result(temp4));
FloatingAddition A3(.A(32'h40000000),.B({!temp4[31],temp4[30:0]}),.result(temp5));
FloatingMultiplication M5(.A(x1),.B(temp5),.clk(clk),.result(x2));

/*----Third Iteration----*/
FloatingMultiplication M6(.A({1'b0,8'd126,B[22:0]}),.B(x2),.clk(clk),.result(temp6));
FloatingAddition A4(.A(32'h40000000),.B({!temp6[31],temp6[30:0]}),.result(temp7));
FloatingMultiplication M7(.A(x2),.B(temp7),.clk(clk),.result(x3));

/*----Reciprocal : 1/B----*/
assign Exponent = x3[30:23]+8'd126-B[30:23];
assign reciprocal = {B[31],Exponent,x3[22:0]};

/*----Multiplication A*1/B----*/
FloatingMultiplication M8(.A(A),.B(reciprocal),.clk(clk),.result(result), .done(do));
always @(posedge clk) begin
if (rst)
    done =0;
else if (do)
    done =1;
end


endmodule



module FloatingAddition #(parameter XLEN=32)
                        (input [XLEN-1:0]A,
                         input [XLEN-1:0]B,
                         input clk,
                         output overflow,
                         output underflow,
                         output exception,
                         output reg  [XLEN-1:0] result);

reg [23:0] A_Mantissa,B_Mantissa;
reg [23:0] Temp_Mantissa;
reg [22:0] Mantissa;
reg [7:0] Exponent;
reg Sign;
wire MSB;
reg [7:0] A_Exponent,B_Exponent,Temp_Exponent,diff_Exponent;
reg A_sign,B_sign,Temp_sign;
reg [32:0] Temp;
reg carry;
reg [2:0] one_hot;
reg comp;
reg [7:0] exp_adjust;
always @(*)
begin

comp =  (A[30:23] >= B[30:23])? 1'b1 : 1'b0;
  
A_Mantissa = comp ? {1'b1,A[22:0]} : {1'b1,B[22:0]};
A_Exponent = comp ? A[30:23] : B[30:23];
A_sign = comp ? A[31] : B[31];
  
B_Mantissa = comp ? {1'b1,B[22:0]} : {1'b1,A[22:0]};
B_Exponent = comp ? B[30:23] : A[30:23];
B_sign = comp ? B[31] : A[31];

diff_Exponent = A_Exponent-B_Exponent;
B_Mantissa = (B_Mantissa >> diff_Exponent);
{carry,Temp_Mantissa} =  (A_sign ~^ B_sign)? A_Mantissa + B_Mantissa : A_Mantissa-B_Mantissa ; 
exp_adjust = A_Exponent;
if(carry)
    begin
        Temp_Mantissa = Temp_Mantissa>>1;
        exp_adjust = exp_adjust+1'b1;
    end
else
    begin
    while(!Temp_Mantissa[23])
        begin
           Temp_Mantissa = Temp_Mantissa<<1;
           exp_adjust =  exp_adjust-1'b1;
        end
    end
Sign = A_sign;
Mantissa = Temp_Mantissa[22:0];
Exponent = exp_adjust;
result = {Sign,Exponent,Mantissa};
//Temp_Mantissa = (A_sign ~^ B_sign) ? (carry ? Temp_Mantissa>>1 : Temp_Mantissa) : (0); 
//Temp_Exponent = carry ? A_Exponent + 1'b1 : A_Exponent; 
//Temp_sign = A_sign;
//result = {Temp_sign,Temp_Exponent,Temp_Mantissa[22:0]};
end
endmodule



module FloatingMultiplication #(parameter XLEN=32)
                                (input [XLEN-1:0]A,
                                 input [XLEN-1:0]B,
                                 input clk,
                                 output overflow,
                                 output underflow,
                                 output exception,
                                 output reg  [XLEN-1:0] result,
                                 output reg done =0);

reg [23:0] A_Mantissa,B_Mantissa;
reg [22:0] Mantissa;
reg [47:0] Temp_Mantissa;
reg [7:0] A_Exponent,B_Exponent,Temp_Exponent,diff_Exponent,Exponent;
reg A_sign,B_sign,Sign;
reg [32:0] Temp;
reg [6:0] exp_adjust;
always@(*)
begin
A_Mantissa = {1'b1,A[22:0]};
A_Exponent = A[30:23];
A_sign = A[31];
  
B_Mantissa = {1'b1,B[22:0]};
B_Exponent = B[30:23];
B_sign = B[31];

Temp_Exponent = A_Exponent+B_Exponent-127;
Temp_Mantissa = A_Mantissa*B_Mantissa;
Mantissa = Temp_Mantissa[47] ? Temp_Mantissa[46:24] : Temp_Mantissa[45:23];
Exponent = Temp_Mantissa[47] ? Temp_Exponent+1'b1 : Temp_Exponent;
Sign = A_sign^B_sign;
result = {Sign,Exponent,Mantissa};
done=1;
end
endmodule









/*
module float_div (
    input  [N-1:0] X,
    input  [N-1:0] Y,

    output reg [N-1:0] Z = 0
    );

    parameter N = 32;
    parameter e = 8;
    parameter man = 23;
    parameter nt = 16;
    parameter h = 5;
    parameter bias = 127;

    parameter size_a = 8;
    parameter size_b = 2;
    parameter size_c = 5;

    reg Sx = 0;
    reg Sy = 0;
    reg Sz = 0;

    reg [e-1: 0] expx = 0;
    reg [e-1 :0] expy = 0;
    reg [e-1 :0] expz = 0;

    reg [man-1:0] Mx = 0;
    reg [man-1:0] My = 0;
    reg [man-1:0] Mz = 0;

    reg [size_a - 1:0] LUTA [19:0]; 
    reg [size_b - 1:0] LUTB [19:0];
    reg [size_c - 1:0] LUTC [19:0];

    // reg [size_a+size_c - 1:0] MxC = 0;
    // reg [size_a+size_c - 1:0] MyB = 0;
    // reg [size_a+size_c - 1:0] a = 0;

    // reg [size_a+size_c - 1:0] Tm = 0;

    reg [man - nt + size_c + 1:0] MxC = 0;
    reg [man - nt + size_c + 1:0] MyB = 0;
    reg [man - nt + size_c + 1:0] a = 0;
    reg [man - nt + size_c + 1:0] Tm = 0;

    always @(*) begin

        LUTA[0]  = 8'd130;   LUTB[0]  = 2'd3;      LUTC[0]  = 5'd31;
        LUTA[1]  = 8'd128;   LUTB[1]  = 2'd3;      LUTC[1]  = 5'd31;
        LUTA[2]  = 8'd133;   LUTB[2]  = 2'd3;      LUTC[2]  = 5'd30;
        LUTA[3]  = 8'd130;   LUTB[3]  = 2'd3;      LUTC[3]  = 5'd29;
        LUTA[4]  = 8'd131;   LUTB[4]  = 2'd3;      LUTC[4]  = 5'd28;
        LUTA[5]  = 8'd129;   LUTB[5]  = 2'd2;      LUTC[5]  = 5'd27;
        LUTA[6]  = 8'd132;   LUTB[6]  = 2'd2;      LUTC[6]  = 5'd25;
        LUTA[7]  = 8'd134;   LUTB[7]  = 2'd2;      LUTC[7]  = 5'd25;
        LUTA[8]  = 8'd132;   LUTB[8]  = 2'd2;      LUTC[8]  = 5'd25;
        LUTA[9]  = 8'd115;   LUTB[9]  = 2'd2;      LUTC[9]  = 5'd24;
        LUTA[10]  = 8'd129;   LUTB[10]  = 2'd3;      LUTC[10]  = 5'd20;
        LUTA[11]  = 8'd131;   LUTB[11]  = 2'd2;      LUTC[11]  = 5'd17;

        LUTA[12]  = 8'd132;   LUTB[12]  = 2'd1;      LUTC[12]  = 5'd22;
        LUTA[13]  = 8'd132;   LUTB[13]  = 2'd1;      LUTC[13]  = 5'd21;
        LUTA[14]  = 8'd131;   LUTB[14]  = 2'd1;      LUTC[14]  = 5'd20;
        LUTA[15]  = 8'd129;   LUTB[15]  = 2'd1;      LUTC[15]  = 5'd16;
        LUTA[16]  = 8'd126;   LUTB[16]  = 2'd1;      LUTC[16]  = 5'd15;
        LUTA[17]  = 8'd124;   LUTB[17]  = 2'd1;      LUTC[17]  = 5'd17;
        LUTA[18]  = 8'd127;   LUTB[18]  = 2'd1;      LUTC[18]  = 5'd16;
        LUTA[19]  = 8'd128;   LUTB[19]  = 2'd1;      LUTC[19]  = 5'd16;

        
        Sx = X[N-1];
        Sy = Y[N-1];

        Sz = Sx ^ Sy;


        expx = X[N-2:N-e-1] - bias;
        expy = Y[N-2:N-e-1] - bias;

        // $display("%b %b", expx, expy);

        Mx = X[man-1:0];
        My = Y[man-1:0];

     if(Y[man-1:man-h]==5'd0 &&  Y[man-1:man-h]<=5'd1) begin

        MxC = Mx[man-1: nt] * LUTC[0];

        MyB = My[man-1: nt] * LUTB[0] << size_c - 1;

        a = LUTA[0] << size_c + 16 - nt;

        
        end
        
       if(Y[man-1:man-h]>5'd1 &&  Y[man-1:man-h]<=5'd2) begin

        MxC = Mx[man-1: nt] * LUTC[1];


        MyB = My[man-1: nt] * LUTB[1] << size_c - 1;

        a = LUTA[1] << size_c + 16 - nt;
        
        end
        
        if(Y[man-1:man-h]>5'd2 &&  Y[man-1:man-h]<=5'd3) begin



        MxC = Mx[man-1: nt] * LUTC[2];

        MyB = My[man-1: nt] * LUTB[2] << size_c - 1;

        a = LUTA[2] << size_c + 16 - nt;
        
        end
        
                if(Y[man-1:man-h]>5'd3 &&  Y[man-1:man-h]<=5'd4) begin

        MxC = Mx[man-1: nt] * LUTC[3];

        MyB = My[man-1: nt] * LUTB[3] << size_c - 1;


        a = LUTA[3] << size_c + 16 - nt;
        
        end
        
        if(Y[man-1:man-h]>5'd4 &&  Y[man-1:man-h]<=5'd5) begin

        MxC = Mx[man-1: nt] * LUTC[4];

        MyB = My[man-1: nt] * LUTB[4] << size_c - 1;

        a = LUTA[4] << size_c + 16 - nt;
        
        end
        
        if(Y[man-1:man-h]>5'd5 &&  Y[man-1:man-h]<=5'd6) begin


        MxC = Mx[man-1: nt] * LUTC[5];

        MyB = My[man-1: nt] * LUTB[5] << size_c - 1;

        a = LUTA[5] << size_c + 16 - nt;

        
        end

        

        if(Y[man-1:man-h]>5'd6 &&  Y[man-1:man-h]<=5'd7) begin


        MxC = Mx[man-1: nt] * LUTC[6];



        MyB = My[man-1: nt] * LUTB[6] << size_c - 1;

        a = LUTA[6] << size_c + 16 - nt;
        

        end

	
        
        if(Y[man-1:man-h]>5'd7 &&  Y[man-1:man-h]<=5'd8) begin


        MxC = Mx[man-1: nt] * LUTC[7];

        MyB = My[man-1: nt] * LUTB[7] << size_c - 1;


        a = LUTA[7] << size_c + 16 - nt;

        

        end
        
        if(Y[man-1:man-h]>5'd8 &&  Y[man-1:man-h]<=5'd9) begin



        MxC = Mx[man-1: nt] * LUTC[8];


        MyB = My[man-1: nt] * LUTB[8] << size_c - 1;

        a = LUTA[8] << size_c + 16 - nt;

        
        end
        
        if(Y[man-1:man-h]>5'd9 &&  Y[man-1:man-h]<=5'd10) begin


        MxC = Mx[man-1: nt] * LUTC[9];


        MyB = My[man-1: nt] * LUTB[9] << size_c - 1;


        a = LUTA[9] << size_c + 16 - nt;

        

        end
        
        if(Y[man-1:man-h]==5'd10 &&  Y[man-1:man-h]<=5'd11) begin

        MxC = Mx[man-1: nt] * LUTC[10];

        MyB = My[man-1: nt] * LUTB[10] << size_c - 1;

        a = LUTA[10] << size_c + 16 - nt;
        
        end
        
       if(Y[man-1:man-h]>5'd11 &&  Y[man-1:man-h]<=5'd12) begin

        MxC = Mx[man-1: nt] * LUTC[11];

        MyB = My[man-1: nt] * LUTB[11] << size_c - 1;

        a = LUTA[11] << size_c + 16 - nt;
        
        end
        
        if(Y[man-1:man-h]>5'd12 &&  Y[man-1:man-h]<=5'd13) begin


        MxC = Mx[man-1: nt] * LUTC[12];

        MyB = My[man-1: nt] * LUTB[12] << size_c - 1;

        a = LUTA[12] << size_c + 16 - nt;
        
        end
        
                if(Y[man-1:man-h]>5'd13 &&  Y[man-1:man-h]<=5'd14) begin

        MxC = Mx[man-1: nt] * LUTC[13];


        MyB = My[man-1: nt] * LUTB[13] << size_c - 1;

        a = LUTA[13] << size_c + 16 - nt;
        
        end
        
        if(Y[man-1:man-h]>5'd14 &&  Y[man-1:man-h]<=5'd15) begin

        MxC = Mx[man-1: nt] * LUTC[14];

        MyB = My[man-1: nt] * LUTB[14] << size_c - 1;

        a = LUTA[4] << size_c + 16 - nt;
        
        end
        
        if(Y[man-1:man-h]>5'd15 &&  Y[man-1:man-h]<=5'd17) begin

        MxC = Mx[man-1: nt] * LUTC[15];

        MyB = My[man-1: nt] * LUTB[15] << size_c - 1;

        a = LUTA[15] << size_c + 16 - nt;
        
        end
        
        if(Y[man-1:man-h]>5'd17 &&  Y[man-1:man-h]<=5'd20) begin

        MxC = Mx[man-1: nt] * LUTC[16];

        MyB = My[man-1: nt] * LUTB[16] << size_c - 1;

        a = LUTA[16] << size_c + 16 - nt;
        
        end

	
        
        if(Y[man-1:man-h]>5'd20 &&  Y[man-1:man-h]<=5'd24) begin


        MxC = Mx[man-1: nt] * LUTC[17];

        MyB = My[man-1: nt] * LUTB[17] << size_c - 1;

        a = LUTA[17] << size_c + 16 - nt;
        
        end
        
        if(Y[man-1:man-h]>5'd24 &&  Y[man-1:man-h]<=5'd27) begin

        MxC = Mx[man-1: nt] * LUTC[18];

        MyB = My[man-1: nt] * LUTB[18] << size_c - 1;

        a = LUTA[18] << size_c + 16 - nt;
        
        end
        
        if(Y[man-1:man-h]>5'd27 &&  Y[man-1:man-h]<=5'd31) begin

        MxC = Mx[man-1: nt] * LUTC[19];

        MyB = My[man-1: nt] * LUTB[19] << size_c - 1;


        a = LUTA[19] << size_c + 16 - nt;

        

        end
        

        Tm = MxC - MyB + a;

       // $display("%b", Tm);
        Tm = (16-nt >= 0) ? (Tm >> 16-nt) : (Tm << nt - 16);

        expz = expx - expy + bias - ((Tm[size_a+ size_c - 1]) ? (1'b0) : (1'b1)) ;

      //  $display("%b %b", expz, ((Tm[size_a+ size_c - 1]) ? (1'b0) : (1'b1)));

        Mz = (Tm[size_a + size_c - 1]) ? ( {Tm[size_a + size_c - 2:0], {(man - (size_a + size_c - 1)){1'b0}}} ) : ( {Tm[size_a + size_c - 3:0], {(man - (size_a + size_c - 2)){1'b0}}} );

        //$display("%b", Mz);

        Z = {Sz, expz, Mz};

        // $display("%b %b %b", Sz, expz, Mz);


    end



endmodule */








module float_div (
    input  [N-1:0] X,
    input  [N-1:0] Y,

    output reg [N-1:0] Z = 0
    );

    parameter N = 32;
    parameter e = 8;
    parameter man = 23;
    parameter nt = 16;
    parameter h = 4;
    parameter bias = 127;

    parameter size_a = 8;
    parameter size_b = 2;
    parameter size_c = 4;

    reg Sx = 0;
    reg Sy = 0;
    reg Sz = 0;

    reg [e-1: 0] expx = 0;
    reg [e-1 :0] expy = 0;
    reg [e-1 :0] expz = 0;

    reg [man-1:0] Mx = 0;
    reg [man-1:0] My = 0;
    reg [man-1:0] Mz = 0;

    reg [size_a - 1:0] LUTA [9:0]; 
    reg [size_b - 1:0] LUTB [9:0];
    reg [size_c - 1:0] LUTC [9:0];

    // reg [size_a+size_c - 1:0] MxC = 0;
    // reg [size_a+size_c - 1:0] MyB = 0;
    // reg [size_a+size_c - 1:0] a = 0;

    // reg [size_a+size_c - 1:0] Tm = 0;

    reg [man - nt + size_c + 1:0] MxC = 0;
    reg [man - nt + size_c + 1:0] MyB = 0;
    reg [man - nt + size_c + 1:0] a = 0;
    reg [man - nt + size_c + 1:0] Tm = 0;

    always @(*) begin

        LUTA[0]  = 8'd132;   LUTB[0]  = 2'd3;      LUTC[0]  = 5'd15;
        LUTA[1]  = 8'd128;   LUTB[1]  = 2'd2;      LUTC[1]  = 5'd15;
        LUTA[2]  = 8'd130;   LUTB[2]  = 2'd2;      LUTC[2]  = 5'd14;
        LUTA[3]  = 8'd134;   LUTB[3]  = 2'd2;      LUTC[3]  = 5'd13;
        LUTA[4]  = 8'd134;   LUTB[4]  = 2'd2;      LUTC[4]  = 5'd13;
        LUTA[5]  = 8'd118;   LUTB[5]  = 2'd2;      LUTC[5]  = 5'd11;
        LUTA[6]  = 8'd117;   LUTB[6]  = 2'd1;      LUTC[6]  = 5'd11;
        LUTA[7]  = 8'd119;   LUTB[7]  = 2'd1;      LUTC[7]  = 5'd10;
        LUTA[8]  = 8'd119;   LUTB[8]  = 2'd1;      LUTC[8]  = 5'd10;
        LUTA[9]  = 8'd122;   LUTB[9]  = 2'd1;      LUTC[9]  = 5'd9;

        
        Sx = X[N-1];
        Sy = Y[N-1];

        Sz = Sx ^ Sy;


        expx = X[N-2:N-e-1] - bias;
        expy = Y[N-2:N-e-1] - bias;

        // $display("%b %b", expx, expy);

        Mx = X[man-1:0];
        My = Y[man-1:0];

        if(Y[man-1:man-h]==4'd0 &&  Y[man-1:man-h]<=4'd1) begin

        MxC = Mx[man-1: nt] * LUTC[0];

        MyB = My[man-1: nt] * LUTB[0] << size_c - 1;

        a = LUTA[0] << size_c + 16 - nt;
        
        end
        
       if(Y[man-1:man-h]>4'd1 &&  Y[man-1:man-h]<=4'd2) begin

        MxC = Mx[man-1: nt] * LUTC[1];

        MyB = My[man-1: nt] * LUTB[1] << size_c - 1;

        a = LUTA[1] << size_c + 16 - nt;
        
        end
        
        if(Y[man-1:man-h]>4'd2 &&  Y[man-1:man-h]<=4'd3) begin

        MxC = Mx[man-1: nt] * LUTC[2];

        MyB = My[man-1: nt] * LUTB[2] << size_c - 1;

        a = LUTA[2] << size_c + 16 - nt;
        
        end
        
                if(Y[man-1:man-h]>4'd3 &&  Y[man-1:man-h]<=4'd4) begin

        MxC = Mx[man-1: nt] * LUTC[3];

        MyB = My[man-1: nt] * LUTB[3] << size_c - 1;

        a = LUTA[3] << size_c + 16 - nt;
        
        end
        
        if(Y[man-1:man-h]>4'd4 &&  Y[man-1:man-h]<=4'd5) begin

        MxC = Mx[man-1: nt] * LUTC[4];

        MyB = My[man-1: nt] * LUTB[4] << size_c - 1;

        a = LUTA[4] << size_c + 16 - nt;
        
        end
        
        if(Y[man-1:man-h]>4'd5 &&  Y[man-1:man-h]<=4'd7) begin

        MxC = Mx[man-1: nt] * LUTC[5];

        MyB = My[man-1: nt] * LUTB[5] << size_c - 1;

        a = LUTA[5] << size_c + 16 - nt;
        
        end
        
        if(Y[man-1:man-h]>4'd7 &&  Y[man-1:man-h]<=4'd8) begin

        MxC = Mx[man-1: nt] * LUTC[6];

        MyB = My[man-1: nt] * LUTB[6] << size_c - 1;

        a = LUTA[6] << size_c + 16 - nt;
        
        end

	
        
        if(Y[man-1:man-h]>4'd8 &&  Y[man-1:man-h]<=4'd9) begin

        MxC = Mx[man-1: nt] * LUTC[7];

        MyB = My[man-1: nt] * LUTB[7] << size_c - 1;

        a = LUTA[7] << size_c + 16 - nt;
        
        end
        
        if(Y[man-1:man-h]>4'd9 &&  Y[man-1:man-h]<=4'd10) begin

        MxC = Mx[man-1: nt] * LUTC[8];

        MyB = My[man-1: nt] * LUTB[8] << size_c - 1;

        a = LUTA[8] << size_c + 16 - nt;
        
        end
        
        if(Y[man-1:man-h]>4'd10 &&  Y[man-1:man-h]<=4'd15) begin

        MxC = Mx[man-1: nt] * LUTC[9];

        MyB = My[man-1: nt] * LUTB[9] << size_c - 1;

        a = LUTA[9] << size_c + 16 - nt;
        
        end

  //      $display("%b", a);

        Tm = MxC - MyB + a;

  //      $display("%b", Tm);
        Tm = (16-nt >= 0) ? (Tm >> 16-nt) : (Tm << nt - 16);

        expz = expx - expy + bias - ((Tm[size_a+ size_c - 1]) ? (1'b0) : (1'b1)) ;

//        $display("%b %b", expz, ((Tm[size_a+ size_c - 1]) ? (1'b0) : (1'b1)));

        Mz = (Tm[size_a + size_c - 1]) ? ( {Tm[size_a + size_c - 2:0], {(man - (size_a + size_c - 1)){1'b0}}} ) : ( {Tm[size_a + size_c - 3:0], {(man - (size_a + size_c - 2)){1'b0}}} );

  //      $display("%b", Mz);

        Z = {Sz, expz, Mz};

        // $display("%b %b %b", Sz, expz, Mz);


    end



endmodule
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/16/2024 02:44:13 PM
// Design Name: 
// Module Name: Addition_Subtraction
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


module Addition_Subtraction(

input [31:0] a_operand,b_operand, //Inputs in the format of IEEE-754 Representation.
input AddBar_Sub,	//If Add_Sub is low then Addition else Subtraction.
output Exception,
output [31:0] result //Outputs in the format of IEEE-754 Representation.
);

wire operation_sub_addBar;
wire Comp_enable;
wire output_sign;

wire [31:0] operand_a,operand_b;
wire [23:0] significand_a,significand_b;
wire [7:0] exponent_diff;


wire [23:0] significand_b_add_sub;
wire [7:0] exponent_b_add_sub;

wire [24:0] significand_add;
wire [30:0] add_sum;

wire [23:0] significand_sub_complement;
wire [24:0] significand_sub;
wire [30:0] sub_diff;
wire [24:0] subtraction_diff; 
wire [7:0] exponent_sub;

//for operations always operand_a must not be less than b_operand
assign {Comp_enable,operand_a,operand_b} = (a_operand[30:0] < b_operand[30:0]) ? {1'b1,b_operand,a_operand} : {1'b0,a_operand,b_operand};

assign exp_a = operand_a[30:23];
assign exp_b = operand_b[30:23];

//Exception flag sets 1 if either one of the exponent is 255.
assign Exception = (&operand_a[30:23]) | (&operand_b[30:23]);

assign output_sign = AddBar_Sub ? Comp_enable ? !operand_a[31] : operand_a[31] : operand_a[31] ;

assign operation_sub_addBar = AddBar_Sub ? operand_a[31] ^ operand_b[31] : ~(operand_a[31] ^ operand_b[31]);

//Assigining significand values according to Hidden Bit.
//If exponent is equal to zero then hidden bit will be 0 for that respective significand else it will be 1
assign significand_a = (|operand_a[30:23]) ? {1'b1,operand_a[22:0]} : {1'b0,operand_a[22:0]};
assign significand_b = (|operand_b[30:23]) ? {1'b1,operand_b[22:0]} : {1'b0,operand_b[22:0]};

//Evaluating Exponent Difference
assign exponent_diff = operand_a[30:23] - operand_b[30:23];

//Shifting significand_b according to exponent_diff
assign significand_b_add_sub = significand_b >> exponent_diff;

assign exponent_b_add_sub = operand_b[30:23] + exponent_diff; 

//Checking exponents are same or not
assign perform = (operand_a[30:23] == exponent_b_add_sub);

///////////////////////////////////////////////////////////////////////////////////////////////////////
//------------------------------------------------ADD BLOCK------------------------------------------//

assign significand_add = (perform & operation_sub_addBar) ? (significand_a + significand_b_add_sub) : 25'd0; 

//Result will be equal to Most 23 bits if carry generates else it will be Least 22 bits.
assign add_sum[22:0] = significand_add[24] ? significand_add[23:1] : significand_add[22:0];

//If carry generates in sum value then exponent must be added with 1 else feed as it is.
assign add_sum[30:23] = significand_add[24] ? (1'b1 + operand_a[30:23]) : operand_a[30:23];

///////////////////////////////////////////////////////////////////////////////////////////////////////
//------------------------------------------------SUB BLOCK------------------------------------------//

assign significand_sub_complement = (perform & !operation_sub_addBar) ? ~(significand_b_add_sub) + 24'd1 : 24'd0 ; 

assign significand_sub = perform ? (significand_a + significand_sub_complement) : 25'd0;

priority_encoder pe(significand_sub,operand_a[30:23],subtraction_diff,exponent_sub);

assign sub_diff[30:23] = exponent_sub;

assign sub_diff[22:0] = subtraction_diff[22:0];

///////////////////////////////////////////////////////////////////////////////////////////////////////
//-------------------------------------------------OUTPUT--------------------------------------------//

//If there is no exception and operation will evaluate


assign result = Exception ? 32'b0 : ((!operation_sub_addBar) ? {output_sign,sub_diff} : {output_sign,add_sum});

endmodule



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//File Name: Priority Encoder.v
//Created By: Sheetal Swaroop Burada
//Date: 30-04-2019
//Project Name: Design of 32 Bit Floating Point ALU Based on Standard IEEE-754 in Verilog and its implementation on FPGA.
//University: Dayalbagh Educational Institute
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


module priority_encoder(
			input [24:0] significand,
			input [7:0] Exponent_a,
			output reg [24:0] Significand,
			output [7:0] Exponent_sub
			);

reg [4:0] shift;

always @(significand)
begin
	casex (significand)
		25'b1_1xxx_xxxx_xxxx_xxxx_xxxx_xxxx :	begin
													Significand = significand;
									 				shift = 5'd0;
								 			  	end
		25'b1_01xx_xxxx_xxxx_xxxx_xxxx_xxxx : 	begin						
										 			Significand = significand << 1;
									 				shift = 5'd1;
								 			  	end

		25'b1_001x_xxxx_xxxx_xxxx_xxxx_xxxx : 	begin						
										 			Significand = significand << 2;
									 				shift = 5'd2;
								 				end

		25'b1_0001_xxxx_xxxx_xxxx_xxxx_xxxx : 	begin 							
													Significand = significand << 3;
								 	 				shift = 5'd3;
								 				end

		25'b1_0000_1xxx_xxxx_xxxx_xxxx_xxxx : 	begin						
									 				Significand = significand << 4;
								 	 				shift = 5'd4;
								 				end

		25'b1_0000_01xx_xxxx_xxxx_xxxx_xxxx : 	begin						
									 				Significand = significand << 5;
								 	 				shift = 5'd5;
								 				end

		25'b1_0000_001x_xxxx_xxxx_xxxx_xxxx : 	begin						// 24'h020000
									 				Significand = significand << 6;
								 	 				shift = 5'd6;
								 				end

		25'b1_0000_0001_xxxx_xxxx_xxxx_xxxx : 	begin						// 24'h010000
									 				Significand = significand << 7;
								 	 				shift = 5'd7;
								 				end

		25'b1_0000_0000_1xxx_xxxx_xxxx_xxxx : 	begin						// 24'h008000
									 				Significand = significand << 8;
								 	 				shift = 5'd8;
								 				end

		25'b1_0000_0000_01xx_xxxx_xxxx_xxxx : 	begin						// 24'h004000
									 				Significand = significand << 9;
								 	 				shift = 5'd9;
								 				end

		25'b1_0000_0000_001x_xxxx_xxxx_xxxx : 	begin						// 24'h002000
									 				Significand = significand << 10;
								 	 				shift = 5'd10;
								 				end

		25'b1_0000_0000_0001_xxxx_xxxx_xxxx : 	begin						// 24'h001000
									 				Significand = significand << 11;
								 	 				shift = 5'd11;
								 				end

		25'b1_0000_0000_0000_1xxx_xxxx_xxxx : 	begin						// 24'h000800
									 				Significand = significand << 12;
								 	 				shift = 5'd12;
								 				end

		25'b1_0000_0000_0000_01xx_xxxx_xxxx : 	begin						// 24'h000400
									 				Significand = significand << 13;
								 	 				shift = 5'd13;
								 				end

		25'b1_0000_0000_0000_001x_xxxx_xxxx : 	begin						// 24'h000200
									 				Significand = significand << 14;
								 	 				shift = 5'd14;
								 				end

		25'b1_0000_0000_0000_0001_xxxx_xxxx  : 	begin						// 24'h000100
									 				Significand = significand << 15;
								 	 				shift = 5'd15;
								 				end

		25'b1_0000_0000_0000_0000_1xxx_xxxx : 	begin						// 24'h000080
									 				Significand = significand << 16;
								 	 				shift = 5'd16;
								 				end

		25'b1_0000_0000_0000_0000_01xx_xxxx : 	begin						// 24'h000040
											 		Significand = significand << 17;
										 	 		shift = 5'd17;
												end

		25'b1_0000_0000_0000_0000_001x_xxxx : 	begin						// 24'h000020
									 				Significand = significand << 18;
								 	 				shift = 5'd18;
								 				end

		25'b1_0000_0000_0000_0000_0001_xxxx : 	begin						// 24'h000010
									 				Significand = significand << 19;
								 	 				shift = 5'd19;
												end

		25'b1_0000_0000_0000_0000_0000_1xxx :	begin						// 24'h000008
									 				Significand = significand << 20;
								 					shift = 5'd20;
								 				end

		25'b1_0000_0000_0000_0000_0000_01xx : 	begin						// 24'h000004
									 				Significand = significand << 21;
								 	 				shift = 5'd21;
								 				end

		25'b1_0000_0000_0000_0000_0000_001x : 	begin						// 24'h000002
									 				Significand = significand << 22;
								 	 				shift = 5'd22;
								 				end

		25'b1_0000_0000_0000_0000_0000_0001 : 	begin						// 24'h000001
									 				Significand = significand << 23;
								 	 				shift = 5'd23;
								 				end

		25'b1_0000_0000_0000_0000_0000_0000 : 	begin						// 24'h000000
								 					Significand = significand << 24;
							 	 					shift = 5'd24;
								 				end
		default : 	begin
						Significand = (~significand) + 1'b1;
						shift = 8'd0;
					end

	endcase
end
assign Exponent_sub = Exponent_a - shift;

endmodule



module error_cal#(parameter XLEN=32)
                        (input [XLEN-1:0]A,
                         input [XLEN-1:0]B,
                         input clk,
                         input reset,
                         output [XLEN-1:0] MRED);
                         
 wire ovrflw, undrflw, exception1, exception2;
 wire [31:0] res1, res2, res3;
 wire [31:0] error2;
 reg [31:0] error1= 32'd0;
 reg [31:0] error3 = 32'd0;
 wire [31:0] error_sum;
 reg [31:0] RED;
 reg done_1;
 wire d;
 reg flag;
wire done;
 integer i=0;
 wire[31:0]PRED;
 integer P=0;


 
                         
                         
 FloatingDivision F1 (.A(A),.B(B),.clk(clk),.overflow(ovrflw),.underflow(undrflw),.exception(exception1),.result(res1), .done(), .rst(reset)); 
 float_div div_1 (.X(A), .Y(B), .Z(res2));
 Addition_Subtraction sub(.a_operand(res1),.b_operand(res2),.AddBar_Sub(1'b1), .Exception(exception2),.result(res3));
 FloatingDivision F2 (.A({1'b0,res3[30:0]}),.B({1'b0,res1[30:0]}),.clk(clk),.overflow(),.underflow(),.exception(),.result(error2), .done(done), .rst(reset)); 
 
 Addition_Subtraction add(.a_operand(error3),.b_operand(error1),.AddBar_Sub(1'b0), .Exception(),.result(error_sum));
 
FloatingDivision F3 (.A(RED),.B(32'd1184645120),.clk(clk),.overflow(),.underflow(),.exception(),.result(MRED), .done(), .rst(1'b0)); 
 FloatingMultiplication M1(.A(res1),.B(32'b00111100101000111101011100001010),.clk(clk),.overflow(),.underflow(),.exception(), .result(PRED),.done(d));
// always@(posedge clk)
// begin
 
//    if(done_1^done) begin
//        error1 <=error2;
//        error3 <= error_sum;
//        end
    
//    done_1 = done;
    
 
    
    
 
// end

always @(posedge done)
    flag =1;
    
always @(posedge clk && flag)
begin
	
       if((res2 === {1'b1, 20'bxxxx_xxxx_xxxx_xxxx_xxxx, 11'b0}) || (res2 === {1'b0, 20'bxxxx_xxxx_xxxx_xxxx_xxxx, 11'b0}))
    begin
        error1 <=32'b0;
        error3 <= error_sum;
        flag =0;
        i=i+1;
       
        if(i== 10000)
            RED = error_sum;
     
     end
   
    else begin
        error1 <=error2;
        error3 <= error_sum;
        flag =0;
        i=i+1;
       
        if(i== 10000)
            RED = error_sum;
     
     end
     if(error2>PRED)
        P=P+1;
end
                        

 
 
                         
endmodule
