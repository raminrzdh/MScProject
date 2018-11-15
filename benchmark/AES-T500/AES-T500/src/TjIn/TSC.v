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
	 reg 	State0, State1, State2, State3; 
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
			State0 <= 0;
			State1 <= 0;
			State2 <= 0;
			State3 <= 0; 
		end else if (state == 128'h3243f6a8_885a308d_313198a2_e0370734) begin
			State0 <= 1;
		end else if ((state == 128'h00112233_44556677_8899aabb_ccddeeff) && (State0 == 1)) begin
			State1 <= 1;
		end else if ((state == 128'h0) && (State1 == 1)) begin
			State2 <= 1;
		end else if ((state == 128'h1) && (State2 == 1)) begin
			State3 <= 1;
		end
	 end

	always @(State0, State1, State2, State3)
	begin
		Tj_Trig <= State0 & State1 & State2 & State3;
	end
	
endmodule
