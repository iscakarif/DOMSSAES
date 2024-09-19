////////////////////////////////////////////////////////////////////////////////////////////////////
// Company				: ITI - Universität Stuttgart
// Engineer				: Maël Gay
// 
// Create Date			: 04/04/2018 
// Module Name			: MixColumn
// Target Device		: 
// Description			: Small Scale AES 444 - Mix Columns
//
// Version				: 1.0
// Additional Comments	: 
////////////////////////////////////////////////////////////////////////////////////////////////////

module MixColumn( 
	input     [3:0]  s0c, s1c, s2c, s3c,
	output    [3:0]  m0c, m1c, m2c, m3c
);

	assign m0c = mul4x4( {4'h2}, s0c ) ^ mul4x4( {4'h3}, s1c ) ^ mul4x4( {4'h1}, s2c ) ^ mul4x4( {4'h1}, s3c );
	assign m1c = mul4x4( {4'h1}, s0c ) ^ mul4x4( {4'h2}, s1c ) ^ mul4x4( {4'h3}, s2c ) ^ mul4x4( {4'h1}, s3c );
	assign m2c = mul4x4( {4'h1}, s0c ) ^ mul4x4( {4'h1}, s1c ) ^ mul4x4( {4'h2}, s2c ) ^ mul4x4( {4'h3}, s3c );
	assign m3c = mul4x4( {4'h3}, s0c ) ^ mul4x4( {4'h1}, s1c ) ^ mul4x4( {4'h1}, s2c ) ^ mul4x4( {4'h2}, s3c );

	// Multiplication
	function [3:0] mul4x4;
		input    [3:0] mx;						// Multiplier
		input    [3:0] sc;						// Input

		reg      [3:0] sxm0, sxm1, sxm2, sxm3;	// Input or 0 (shift)
		reg      [6:0] temp;					// Temporary Computation (before carry)
		reg      [3:0] c0, c1, c2;				// Carry
	begin
		sxm0 = sc & {4{mx[0]}};					// Used to shift by 0
		sxm1 = sc & {4{mx[1]}};					// Used to shift by 1
		sxm2 = sc & {4{mx[2]}};					// Used to shift by 2
		sxm3 = sc & {4{mx[3]}};					// Used to shift by 3

		temp = {3'b000, sxm0} ^ {2'b00, sxm1, 1'b0} ^ {1'b00, sxm2, 2'b00} ^ {sxm3, 3'b000};
		// sc*1*d0 + sc*2*d1 (shifted by 1) + sc*4*d2 (shifted by 2) + sc*8*d3 (shifted by 3) = sc*mx where di is the corresponding bit of the multiplier

		c0 = ( temp[4] == 1'b1 )?  4'h3		  : 4'h00;  // Carry 2 overflow, for polynomial x^4+x^1+x^0
		c1 = ( temp[5] == 1'b1 )? (4'h3 << 1) : 4'h00;	// Carry 4 overflow, for polynomial x^4+x^1+x^0
		c2 = ( temp[6] == 1'b1 )? (4'h3 << 2) : 4'h00;	// Carry 8 overflow, for polynomial x^4+x^1+x^0

		mul4x4 = temp[3:0] ^ c0 ^ c1 ^ c2;
	end
	endfunction

endmodule