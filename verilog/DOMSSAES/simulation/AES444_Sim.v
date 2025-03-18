////////////////////////////////////////////////////////////////////////////////////////////////////
// Company				: ITI - Universität Stuttgart
// Engineer				: Maël Gay
// Edited By				: Arif Iscak 
//
// Create Date			: 04/04/2018 
// Update Date			: 18/03/2025
// Module Name			: AES444_Sim
// Target Device		: 
// Description			: Domain-Oriented Masking on Small Scale AES 444 - test Bench
//
// Version				: 1.0
// Additional Comments	: 
////////////////////////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ns

module AES444_Sim();
 
	reg			clk;
	reg			rst;
	
	reg			start;
	reg	[63:0]		key_in, k_mask;
	reg	[63:0]		text_in, t_mask;
	reg     [359:0]     	random_bits;
	
	wire	[63:0]		text_out;
	
	AES444 AES444 (
	.clk( clk ),
	.rst( rst ),
	.start( start ),
	.key_in( key_in ),
	.text_in( text_in ),
	.t_mask( t_mask ),
	.k_mask( k_mask ),
	.random_bits( random_bits ),
	.text_out( text_out )
	);
	
	initial begin
	
		clk = 1'b0;
		rst = 1'b1;
		
		repeat(4) #10 clk = ~clk;
		rst = 1'b0;
		
		forever #10 clk = ~clk;
		
	end

	initial begin
		
		start = 1'b0;
		key_in = 64'h0;
		text_in = 64'h0;
		
		t_mask = 64'h0;
		k_mask = 64'h0;
		random_bits = 359'h0;
				
		#100
		
		key_in = 64'hFEDC_BA98_7654_3210;
		text_in = 64'h0;
		
		t_mask = 64'hcf262e324a00edca;
		k_mask = 64'h6865498b823f27f8;
		random_bits = 359'h32d39e615212b905fdebd979817d8c88c314c05ca12b0df4def4db49378b64aa319f1cd732b2ce26d311b92de8;
		
		#100
		
		start = 1'b1;
		
		#15
		
		start = 1'b0;
		random_bits = 359'h3ce2ca1f6f598d418992efa48038fb778634303f733e3b65c169c96bf2665d91bb9676379a1b2e7298addea3c5;
		
		#80
		
		random_bits = 359'h0af19694c7918f80fca35fc6e0ca754023a815ca00c1206002d88f77a6baa122163cb02bb382fbeaa81a73e8ba;
		
		#80
		
		random_bits = 359'h253106ef890c5f0432801254b1da1ab51ab24788db728b6fb1756d4e69b88d134675d911dcffe9be5860517c10;
		
		#80
		
		random_bits = 359'h05006500bf527f2c21fd735772eb9c9a64a9fc581bd11f0e1a982bdaae3f5333bec424fec3bb787108cd07ee5b;
		
		#80
		
		random_bits = 359'h4882d9349a6db65a7b3a2a2b960319a8a88ce4e0ba78f0d2d9ec6db771bd6fab11c21fdff306c521c922f0e583;
		
		#80
		
		random_bits = 359'h2f7ab5242ba3fface28c867d9cbbfa5a437fe78983162d2537de36b2c9e64bea153a6d46af9043748531fe1208;
		
		#80
		
		random_bits = 359'h0040a51e2d37ccbfb3f8bef7f738963c26afc61fec568f7414f9794599053ca39e5dca77cdf1bd98bd3f196b2a;
		
		#80
		
		random_bits = 359'h3a1ee36c3fe7199b5ac05894433a2f384e062c155a7558a045dad3eecebdaf37c78979e30d92bbdfba4a1c22a8;
		
		#80
		
		random_bits = 359'h4882d9349a6db65a7b3a2a2b960319a8a88ce4e0ba78f0d2d9ec6db771bd6fab11c21fdff306c521c922f0e583;
		
		#265
		
		#300
		
		$finish;
		
	end

endmodule
