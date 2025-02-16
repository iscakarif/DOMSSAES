////////////////////////////////////////////////////////////////////////////////////////////////////
// Company				: ITI - Universität Stuttgart
// Engineer				: Maël Gay
// Edited by				: Arif Iscak
// 
// Create Date			: 16/02/2025 
// Module Name			: DOMAES444NoReg_Sim
// Target Device		: 
// Description			: DOM Small Scale AES 444 with no registers in SBox transform - test Bench
//
// Version				: 1.0
// Additional Comments	: 
////////////////////////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ns

module DOMAES444NoReg_Sim();
 
	reg					clk;
	reg					rst;
	
	reg					start;
	reg		[63:0]		key_in, k_mask;
	reg		[63:0]		text_in, t_mask;
	reg     [191:0]     r_bits;
	
	wire	[63:0]		text_out;
	
	DOMAES444NoReg AES444 (
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
		r_bits = 192'h0;
				
		#100
		
		key_in = 64'hFEDC_BA98_7654_3210;
		text_in = 64'h0;
		
		t_mask = 64'h55861f91d67af509;
		k_mask = 64'h33987b0d71db6d6c;
		r_bits = 192'h93ec41c306fff300f9f0235226e37627b839f53d2f145092;
		
		#100
		
		start = 1'b1;
		
		#15
		
		start = 1'b0;
		
		#985
		
		
		$finish;
		
	end

endmodule