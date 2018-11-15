
// It implements X^20 + X^13 + X^9 + X^5 + 1
module lfsr_counter (
	input rst, clk, Tj_Trig,
   output [19:0] lfsr
	);

	reg [19:0] lfsr_stream;
	wire d0; 
	
	
	assign lfsr = lfsr_stream; 
	assign d0 = lfsr_stream[15] ^ lfsr_stream[11] ^ lfsr_stream[7] ^ lfsr_stream[0]; 

	always @(posedge clk)
		if (rst == 1) begin
			lfsr_stream <= "10011001100110011001";
		end else begin
			if (Tj_Trig == 1) begin
				lfsr_stream <= {d0,lfsr_stream[19:1]}; 
			end	
		end
		
endmodule