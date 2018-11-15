`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   10:26:15 03/19/2013
// Design Name:   top
// Module Name:   D:/TrustHUB/HardwareTrojan/AES/AES128/AES-T1001/AES/tbTOP.v
// Project Name:  AES
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: top
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tbTOP;

	// Inputs
	reg clk;
	reg rst;
	reg [127:0] state;
	reg [127:0] key;

	// Outputs
	wire [127:0] out;
	wire [63:0] Capacitance;

	// Instantiate the Unit Under Test (UUT)
	top uut (
		.clk(clk), 
		.rst(rst), 
		.state(state), 
		.key(key), 
		.out(out), 
		.Capacitance(Capacitance)
	);

	initial begin		clk = 0;
		state = 0;
		key = 0;
		rst = 0;
		
		#20;
		rst = 1;

		#20;
		rst = 0;
		
		#60;
        /*
         * TIMEGRP "key" OFFSET = IN 6.4 ns VALID 6 ns AFTER "clk" HIGH;
         * TIMEGRP "state" OFFSET = IN 6.4 ns VALID 6 ns AFTER "clk" HIGH;
         * TIMEGRP "out" OFFSET = OUT 2.2 ns BEFORE "clk" HIGH;
         */
        @ (negedge clk);
        # 2;
        state = 128'h3243f6a8_885a308d_313198a2_e0370734;
        key   = 128'h2b7e1516_28aed2a6_abf71588_09cf4f3c;
        #10;
        state = 128'h00112233_44556677_8899aabb_ccddeeff;
        #10;
        state = 128'h0;
        #10;
        state = 128'h0;
        #10;
        state = 128'h1;
        #220;
        $finish;
	end
      
    always #5 clk = ~clk;
      
endmodule

