//`timescale 1ns / 1ps

//module FloatingDivision_tb;

//    reg clk = 0;
//    reg [31:0] A;
//    reg [31:0] B;
//    wire overflow;
//    wire underflow;
//    wire exception;
//    wire [31:0] result;

//    FloatingDivision #(.XLEN(32)) DUT(
//        .A(A),
//        .B(B),
//        .clk(clk),
//        .overflow(overflow),
//        .underflow(underflow),
//        .exception(exception),
//        .result(result)
//    );

//    initial begin
//        $dumpfile("tb.vcd");
//        $dumpvars(0, FloatingDivision_tb);

//        // Random input generation
//        repeat (10000) begin
//            A = $random;
//            B = $random;
//            #20;  // Delay to allow DUT to process inputs
//        end

//        // Clock generation
//        forever #5 clk = ~clk;
//    end

//endmodule




`timescale 1ns / 1ps

module error_cal_tb;

    reg clk = 0;
    reg [31:0] A;
    reg [31:0] B;
    reg rst = 1;
    wire [31:0] MRED;
    integer i;

    // Instantiate the error_cal module
    error_cal #(.XLEN(32)) dut (
        .A(A),
        .B(B),
        .clk(clk),
        .reset(rst),
        .MRED(MRED)
    );
   
    // Clock generation
    always #5 clk = ~clk;
    

    // Initialize inputs
    initial begin
    $dumpfile("out_1.vcd");
    $dumpvars(0,error_cal_tb);
    

//        rst = 0;
//        A = 32'b0_10000001_00001100110011001100110;  // 4.2 
//        B = 32'b0_10000000_10011001100110011001100;  // 3.2
//        #20
//        rst =1;
//        #10
//        rst = 0;
//        A = 32'b0_01111110_01010001111010111000010;  // 0.66
//        B = 32'b0_01111110_00000101000111101011100;  // 0.51
//        #20
//        rst =1;
//        #10
//        rst = 0;
//        A = 32'b1_10000001_10011001100110011001100;  // -6.4 
//        B = 32'b1_01111110_00000000000000000000000;  // -0.5
//        #20
//        rst =1;
//        #10
//        rst = 0;
//        A = 32'b0_10000001_10011001100110011001100;  // 6.4
//        B = 32'b1_01111110_00000000000000000000000;  // -0.5


         repeat (20000) begin
           
            rst =0;
            for(i=0;i<32;i=i+1)begin
            A[i] = $random ;
            B[i] = $random ;
            end
            
          
            #20;  // Delay to allow DUT to process inputs
            rst=1;
            #5;
        end

//        A = 32'h00000000; B = 32'h00000000; #1; $display("A = %h, B = %h, result = %h", A, B, result);
//        A = 32'hFFFFFFFF; B = 32'hFFFFFFFF; #1; $display("A = %h, B = %h, result = %h", A, B, result);
//        A = 32'h00000000; B = 32'hFFFFFFFF; #1; $display("A = %h, B = %h, result = %h", A, B, result);
//        A = 32'hFFFFFFFF; B = 32'h00000000; #1; $display("A = %h, B = %h, result = %h", A, B, result);
//        // Wait for initial stability
        #100;

        // Display initial values
    //    $display("Initial values: A = %f, B = %f", $realtobits(A), $realtobits(B));

        // Apply test cases
        // You can apply more test cases here

        // End simulation
      #100 $finish;
    end

endmodule
