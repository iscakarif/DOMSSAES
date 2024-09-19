////////////////////////////////////////////////////////////////////////////////////////////////////
// Company				: ITI - Universität Stuttgart
// Engineer				: Maël Gay
// 
// Create Date			: 04/04/2018 
// Module Name			: AES444
// Target Device		: 
// Description			: Small Scale AES 444
//
// Version				: 1.0
// Additional Comments	: 
////////////////////////////////////////////////////////////////////////////////////////////////////

module AES444 (
	input			clk,			// Clock
	input			rst,			// Reset

	input			start,			// Encryption trigger
	input	[63:0]	key_in,			// Key input
	input	[63:0]	text_in,		// Plaintext input
	output	[63:0]	text_out		// Ciphertext output
);
	
	// ==================================================
	// State Machine Stage
	// ==================================================
	`define  IDLE        3'h0           // Idle stage
	`define  ROUND_LOOP  3'h1           // Round stage

	// ==================================================
	// Internal Signals
	// ==================================================

	// States
	reg			[2:0]	now_state;			// State machine register
	reg			[2:0]	next_state;			// Next state register
	reg			[3:0]	round_n;			// Round counter

	// Key Schedule
	reg			[63:0]	w;					// Key work register
	wire		[3:0]	rcon;				// Round constant
	wire		[15:0]	temp;				// Key - Temporary
	wire		[63:0]	next_key;			// Next round key

	// Encryption
	reg			[63:0]	enc_state;      	// Cipher work register
	wire		[3:0]	s_box[0:3][0:3];	// SBox
	wire		[3:0]	s_row[0:3][0:3];	// Shift rows
	wire		[3:0]	m_col[0:3][0:3];	// Mix columns
	wire		[63:0]	add_roundkey0;		// Initial add round key
	wire		[63:0]	add_roundkey;		// Add round key
	wire		[63:0]	cipher_text;		// Ciphertext
	  
	// ==================================================
	// Small Scale AES - 444
	// ==================================================

	// --------------------------------------------------
	// Main State Machine
	// --------------------------------------------------
	always @( now_state or start or round_n ) begin
		case ( now_state )
			`IDLE			:
				if ( start == 1'b1 ) next_state = `ROUND_LOOP;
				else next_state = `IDLE;
			`ROUND_LOOP		:
				if ( round_n == 4'd10 ) next_state = `IDLE;
				else next_state = `ROUND_LOOP;
			default			:
				next_state = `IDLE;
		endcase
	end

	always @(posedge clk or posedge rst) begin
		if ( rst ) now_state <= `IDLE;
		else now_state <= next_state;
	end

	// --------------------------------------------------
	// Control signals
	// --------------------------------------------------
	always @(posedge clk or posedge rst) begin
		if ( rst ) begin
			round_n <= 4'h0;
		end
		else begin
			// Round counter
			if ( next_state == `IDLE ) round_n <= 4'h0;
			else round_n <= round_n + 1'b1;
		end
	end

	// Output
	assign text_out = enc_state;

	// --------------------------------------------------
	// 64-bit Cipher Key Expansion
	// --------------------------------------------------
	always @(posedge clk or posedge rst) begin
		if ( rst ) begin
			w <= {64{1'b0}};	// Cipher Round Key register
		end
		else begin
			// Cipher Round Key
			if ( next_state == `IDLE ) w <= key_in;
			else if ( next_state == `ROUND_LOOP ) w <= next_key;
			else w <= w;
		end
	end

	// SubWord
	SubWord SubWord0 ( .a( w[15: 0] ), .b( temp ));

	// Next Round Key
	assign next_key[03:00] = temp[15:12] ^ w[51:48] ^ w[35:32] ^ w[19:16] ^ w[03:00];
	assign next_key[07:04] = temp[11:08] ^ w[55:52] ^ w[39:36] ^ w[23:20] ^ w[07:04];
	assign next_key[11:08] = temp[07:04] ^ w[59:56] ^ w[43:40] ^ w[27:24] ^ w[11:08];
	assign next_key[15:12] = temp[03:00] ^ w[63:60] ^ w[47:44] ^ w[31:28] ^ w[15:12] ^ rcon;
	assign next_key[19:16] = temp[15:12] ^ w[51:48] ^ w[35:32] ^ w[19:16];
	assign next_key[23:20] = temp[11:08] ^ w[55:52] ^ w[39:36] ^ w[23:20];
	assign next_key[27:24] = temp[07:04] ^ w[59:56] ^ w[43:40] ^ w[27:24];
	assign next_key[31:28] = temp[03:00] ^ w[63:60] ^ w[47:44] ^ w[31:28] ^ rcon;
	assign next_key[35:32] = temp[15:12] ^ w[51:48] ^ w[35:32];
	assign next_key[39:36] = temp[11:08] ^ w[55:52] ^ w[39:36];
	assign next_key[43:40] = temp[07:04] ^ w[59:56] ^ w[43:40];
	assign next_key[47:44] = temp[03:00] ^ w[63:60] ^ w[47:44] ^ rcon;
	assign next_key[51:48] = temp[15:12] ^ w[51:48];
	assign next_key[55:52] = temp[11:08] ^ w[55:52];
	assign next_key[59:56] = temp[07:04] ^ w[59:56];
	assign next_key[63:60] = temp[03:00] ^ w[63:60] ^ rcon;

	// Rcon[] The round constant word arrey
	assign rcon = ( round_n == 4'h0 )? 4'h1 : 4'h0
				| ( round_n == 4'h1 )? 4'h2 : 4'h0
				| ( round_n == 4'h2 )? 4'h4 : 4'h0
				| ( round_n == 4'h3 )? 4'h8 : 4'h0
				| ( round_n == 4'h4 )? 4'h3 : 4'h0
				| ( round_n == 4'h5 )? 4'h6 : 4'h0
				| ( round_n == 4'h6 )? 4'hc : 4'h0
				| ( round_n == 4'h7 )? 4'hb : 4'h0
				| ( round_n == 4'h8 )? 4'h5 : 4'h0
				| ( round_n == 4'h9 )? 4'ha : 4'h0;

	// --------------------------------------------------
	// SC-AES-444.Encrypt
	// Cipher
	// --------------------------------------------------
	// Cipher state registers
	always @(posedge clk or posedge rst) begin
		if ( rst ) begin
			enc_state <= {64{1'b0}};
		end
		else begin
			if (( start == 1'b1 ) && ( round_n == 4'h0 )) begin	// Nr = 0  Add Round Key
				enc_state <= add_roundkey0;
			end
			else if (( now_state == `ROUND_LOOP ) && ( round_n >= 4'd1 ) && ( round_n <= 4'd9 )) begin	// Nr = 1 to Nr = 9  Add round key
				enc_state <= add_roundkey;
			end
			else if (( now_state == `ROUND_LOOP ) && ( round_n == 4'd10 )) begin	// Nr = 10
				enc_state <= cipher_text;
			end
			else enc_state <= enc_state;
		end
	end

	// --------------------------------------------------
	// Data Input and Add Round Key(Nr = 0)
	// --------------------------------------------------
	assign add_roundkey0 = text_in ^ w;

	// --------------------------------------------------
	// SubBytes Transformation
	// --------------------------------------------------
	SubBytes SubBytes0 (
	.a00( enc_state[63:60] ), .a01( enc_state[47:44] ), .a02( enc_state[31:28] ), .a03( enc_state[15:12] ),
	.a10( enc_state[59:56] ), .a11( enc_state[43:40] ), .a12( enc_state[27:24] ), .a13( enc_state[11:08] ),
	.a20( enc_state[55:52] ), .a21( enc_state[39:36] ), .a22( enc_state[23:20] ), .a23( enc_state[07:04] ),
	.a30( enc_state[51:48] ), .a31( enc_state[35:32] ), .a32( enc_state[19:16] ), .a33( enc_state[03:00] ),

	.b00( s_box[0][0] ), .b01( s_box[0][1] ), .b02( s_box[0][2] ), .b03( s_box[0][3] ),
	.b10( s_box[1][0] ), .b11( s_box[1][1] ), .b12( s_box[1][2] ), .b13( s_box[1][3] ),
	.b20( s_box[2][0] ), .b21( s_box[2][1] ), .b22( s_box[2][2] ), .b23( s_box[2][3] ),
	.b30( s_box[3][0] ), .b31( s_box[3][1] ), .b32( s_box[3][2] ), .b33( s_box[3][3] )
	);

	// --------------------------------------------------
	// ShiftRows
	// --------------------------------------------------
	assign { s_row[0][0], s_row[0][1], s_row[0][2], s_row[0][3] } = { s_box[0][0], s_box[0][1], s_box[0][2], s_box[0][3] };
	assign { s_row[1][0], s_row[1][1], s_row[1][2], s_row[1][3] } = { s_box[1][1], s_box[1][2], s_box[1][3], s_box[1][0] };
	assign { s_row[2][0], s_row[2][1], s_row[2][2], s_row[2][3] } = { s_box[2][2], s_box[2][3], s_box[2][0], s_box[2][1] };
	assign { s_row[3][0], s_row[3][1], s_row[3][2], s_row[3][3] } = { s_box[3][3], s_box[3][0], s_box[3][1], s_box[3][2] };

	// --------------------------------------------------
	// MixColumns
	// --------------------------------------------------
	MixColumn MixColumn0 (
	.s0c( s_row[0][0] ), .s1c( s_row[1][0] ), .s2c( s_row[2][0] ), .s3c( s_row[3][0] ),
	.m0c( m_col[0][0] ), .m1c( m_col[1][0] ), .m2c( m_col[2][0] ), .m3c( m_col[3][0] )
	);
	MixColumn MixColumn1 (
	.s0c( s_row[0][1] ), .s1c( s_row[1][1] ), .s2c( s_row[2][1] ), .s3c( s_row[3][1] ),
	.m0c( m_col[0][1] ), .m1c( m_col[1][1] ), .m2c( m_col[2][1] ), .m3c( m_col[3][1] )
	);
	MixColumn MixColumn2 (
	.s0c( s_row[0][2] ), .s1c( s_row[1][2] ), .s2c( s_row[2][2] ), .s3c( s_row[3][2] ),
	.m0c( m_col[0][2] ), .m1c( m_col[1][2] ), .m2c( m_col[2][2] ), .m3c( m_col[3][2] )
	);
	MixColumn MixColumn3 (
	.s0c( s_row[0][3] ), .s1c( s_row[1][3] ), .s2c( s_row[2][3] ), .s3c( s_row[3][3] ),
	.m0c( m_col[0][3] ), .m1c( m_col[1][3] ), .m2c( m_col[2][3] ), .m3c( m_col[3][3] )
	);

	// --------------------------------------------------
	// Add Round Key
	// --------------------------------------------------
	// Nr = 1 to Nr = 9
	assign add_roundkey[63:48] = { m_col[0][0], m_col[1][0], m_col[2][0], m_col[3][0] } ^ w[63:48];
	assign add_roundkey[47:32] = { m_col[0][1], m_col[1][1], m_col[2][1], m_col[3][1] } ^ w[47:32];
	assign add_roundkey[31:16] = { m_col[0][2], m_col[1][2], m_col[2][2], m_col[3][2] } ^ w[31:16];
	assign add_roundkey[15:00] = { m_col[0][3], m_col[1][3], m_col[2][3], m_col[3][3] } ^ w[15:00];

	// Nr = 10 
	// Cipher Text Output
	assign cipher_text[63:48] = { s_row[0][0], s_row[1][0], s_row[2][0], s_row[3][0] } ^ w[63:48];
	assign cipher_text[47:32] = { s_row[0][1], s_row[1][1], s_row[2][1], s_row[3][1] } ^ w[47:32];
	assign cipher_text[31:16] = { s_row[0][2], s_row[1][2], s_row[2][2], s_row[3][2] } ^ w[31:16];
	assign cipher_text[15:00] = { s_row[0][3], s_row[1][3], s_row[2][3], s_row[3][3] } ^ w[15:00];

endmodule