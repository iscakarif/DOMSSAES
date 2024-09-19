////////////////////////////////////////////////////////////////////////////////////////////////////
// Company				: ITI - Universität Stuttgart
// Engineer				: Maël Gay
// 
// Create Date			: 04/04/2018 
// Module Name			: SubBytes
// Target Device		: 
// Description			: Small Scale AES 444 - Sub Bytes
//
// Version				: 1.0
// Additional Comments	: 
////////////////////////////////////////////////////////////////////////////////////////////////////

module SubBytes (
	input     [3:0]  a00, a10, a20, a30,    // Data input
	input     [3:0]  a01, a11, a21, a31,    // Data input
	input     [3:0]  a02, a12, a22, a32,    // Data input
	input     [3:0]  a03, a13, a23, a33,    // Data input

	output    [3:0]  b00, b10, b20, b30,    // Data output
	output    [3:0]  b01, b11, b21, b31,    // Data output
	output    [3:0]  b02, b12, b22, b32,    // Data output
	output    [3:0]  b03, b13, b23, b33     // Data output
);

	assign b00 = s_box( a00 );
	assign b10 = s_box( a10 );
	assign b20 = s_box( a20 );
	assign b30 = s_box( a30 );

	assign b01 = s_box( a01 );
	assign b11 = s_box( a11 );
	assign b21 = s_box( a21 );
	assign b31 = s_box( a31 );

	assign b02 = s_box( a02 );
	assign b12 = s_box( a12 );
	assign b22 = s_box( a22 );
	assign b32 = s_box( a32 );

	assign b03 = s_box( a03 );
	assign b13 = s_box( a13 );
	assign b23 = s_box( a23 );
	assign b33 = s_box( a33 );

	function [3:0] s_box;
		input    [3:0] aij;
		reg      [3:0] sb[0:15];
	begin
		{	sb[  0],sb[  1],sb[  2],sb[  3],sb[  4],sb[  5],sb[  6],sb[  7],
			sb[  8],sb[  9],sb[ 10],sb[ 11],sb[ 12],sb[ 13],sb[ 14],sb[ 15]
		} =

		{	4'h6, 4'hb, 4'h5, 4'h4, 4'h2, 4'he, 4'h7, 4'ha,
			4'h9, 4'hd, 4'hf, 4'hc, 4'h3, 4'h1, 4'h0, 4'h8
		};

		s_box =sb[aij];
	end
	endfunction

endmodule