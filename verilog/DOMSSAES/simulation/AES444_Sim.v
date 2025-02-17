////////////////////////////////////////////////////////////////////////////////////////////////////
// Company				: ITI - Universität Stuttgart
// Engineer				: Maël Gay
// 
// Create Date			: 04/04/2018 
// Module Name			: AES444_Sim
// Target Device		: 
// Description			: Small Scale AES 444 - test Bench
//
// Version				: 1.0
// Additional Comments	: 
////////////////////////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ns

module AES444_Sim();
 
	reg					clk;
	reg					rst;
	
	reg					start;
	reg		[63:0]		key_in, k_mask;
	reg		[63:0]		text_in, t_mask;
	reg     [359:0]     r_bits;
	
	wire	[63:0]		text_out;
	
	AES444 AES444 (
	.clk( clk ),
	.rst( rst ),
	.start( start ),
	.key_in( key_in ),
	.text_in( text_in ),
	.t_mask( t_mask ),
	.k_mask( k_mask ),
	.r_bits( r_bits ),
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
		r_bits = 359'h0;
				
		#100
		
		key_in = 64'hFEDC_BA98_7654_3210;
		text_in = 64'h0;
		
		t_mask = 64'hcf262e324a00edca;
		k_mask = 64'h6865498b823f27f8;
		r_bits = 359'h8225d4753f1bdf0270553d13bdcb32a22385e99d3fd9e1f05a5be33a8b6524a1bf54f9e30653e8ec2a3d2877ff;
		
		#100
		
		start = 1'b1;
		
		#15
		
		start = 1'b0;
		
		#985
		
		#300
		
		$finish;
		
	end

endmodule