`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   11:50:53 03/08/2013
// Design Name:   AM_Transmission
// Module Name:   D:/TrustHUB/HardwareTrojan/AES/AES128/AES3/AM_Transmission/tb_AM.v
// Project Name:  AM_Transmission
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: AM_Transmission
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_AM;

	// Inputs
	reg [127:0] key;
	reg clk;
	reg rst;
	reg Tj_Trig;
	
	// Outputs
	wire Antena;

	// Instantiate the Unit Under Test (UUT)
	AM_Transmission uut (
		.key(key), 
		.clk(clk), 
		.rst(rst), 
		.Tj_Trig(Tj_Trig),
		.Antena(Antena)
	);

	initial begin
		// Initialize Inputs
		key = 0;
		clk = 0;
		rst = 0;
		Tj_Trig = 0;

		// Wait 100 ns for global reset to finish
		#5;
      rst = 1;
		Tj_Trig = 1;
		key = 128'hAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA;
		// Add stimulus here
		#25
		Tj_Trig = 0;
		rst = 0;
		#300 $finish;
	end
	
   always #10.015 clk = ~clk;
endmodule

