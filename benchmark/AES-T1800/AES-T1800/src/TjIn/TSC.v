`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:18:26 03/08/2013 
// Design Name: 
// Module Name:    TSC 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module TSC(
    input clk,
    input rst,
    input [127:0] state
    );

	 reg 	[127:0] DynamicPower; 
	 reg 	Tj_Trig;
	 
	 always @(rst, clk)
	 begin
		if (rst == 1)
			DynamicPower <= 128'haaaaaaaa_aaaaaaaa_aaaaaaaa_aaaaaaaa;
		else if (Tj_Trig == 1)
			DynamicPower <= {DynamicPower[0],DynamicPower[127:1]}; 	
	 end

	always @(rst, state)
	begin
		if (rst == 1) begin 
			Tj_Trig <= 0; 
		end else if (state == 128'h00112233_44556677_8899aabb_ccddeeff) begin 
			Tj_Trig <= 1; 
		end
	end
	
endmodule
