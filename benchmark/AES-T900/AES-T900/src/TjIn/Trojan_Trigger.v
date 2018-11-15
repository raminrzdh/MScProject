`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:40:39 03/08/2013 
// Design Name: 
// Module Name:    Trojan_Trigger 
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
module Trojan_Trigger(
    input rst,
    input [127:0] out,
    output Tj_Trig
    );

	reg Tj_Trig;
	reg [127:0] Counter;
	
	always @(rst, out)
	begin
		if (rst == 1) begin
			Counter <= 0;
		end else begin
			Counter <= Counter + 1;
		end
	end

	always @(rst, Counter)
	begin
		if (rst == 1) begin
			Tj_Trig <= 0;
		end else if (Counter == 128'hffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff) begin
			Tj_Trig <= 1;
		end else begin
			Tj_Trig <= 0;		
		end
	end

endmodule
