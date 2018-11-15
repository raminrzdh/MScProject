`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   16:20:11 03/08/2013
// Design Name:   top
// Module Name:   D:/TrustHUB/HardwareTrojan/AES/AES128/AES3/AM_Transmission/AES_tb.v
// Project Name:  AM_Transmission
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

module AES_tb;

	// Inputs
	reg clk;
	reg rst;
	reg [127:0] state;
	reg [127:0] key;

	// Outputs
	wire [127:0] out;
	wire Antena;

	// Instantiate the Unit Under Test (UUT)
	top uut (
		.clk(clk), 
		.rst(rst), 
		.state(state), 
		.key(key), 
		.out(out), 
		.Antena(Antena)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 0;
		state = 0;
		key = 0;

		// Wait 100 ns for global reset to finish
		#5;
      rst = 1;     
		state = 128'hFFFFFFFF_FFFFFFFF_FFFFFFFF_FFFFFFFF;
		//state = 128'h3243f6a8_885a308d_313198a2_e0370734;
      key   = 128'haaaaaaaa_aaaaaaaa_aaaaaaaa_aaaaaaaa;

		#15
		rst = 0;

		#300 $finish;
	end
	
   always #10.015 clk = ~clk;
	
endmodule

