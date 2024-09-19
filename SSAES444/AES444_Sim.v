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
	reg		[63:0]		key_in;
	reg		[63:0]		text_in;
	wire	[63:0]		text_out;
	
	AES444 AES444 (
	.clk( clk ),
	.rst( rst ),
	.start( start ),
	.key_in( key_in ),
	.text_in( text_in ),
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
		
		#100
		
		key_in = 64'hFEDC_BA98_7654_3210;
		text_in = 64'h0;
		
		#100
		
		start = 1'b1;
		
		#15
		
		start = 1'b0;
		
		#985
		
		$finish;
		
	end

endmodule