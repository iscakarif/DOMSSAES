////////////////////////////////////////////////////////////////////////////////////////////////////
// Company				: ITI - Universität Stuttgart
// Engineer				: Maël Gay
// 
// Create Date			: 04/04/2018 
// Module Name			: SubWord
// Target Device		: 
// Description			: Small Scale AES 444 - Sub Word
//
// Version				: 1.0
// Additional Comments	: 
////////////////////////////////////////////////////////////////////////////////////////////////////

module SubWord (
	input  [15:0] a,
	output [15:0] b
);

	assign b = {s_box( a[15:12] ), s_box( a[11:8] ), s_box( a[7: 4] ),  s_box( a[ 3: 0] )};

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