////////////////////////////////////////////////////////////////////////////////////////////////////
// Company				: ITI - Universit t Stuttgart
// Engineer				: Ma l Gay
// Edited by				: Arif Iscak
// 
// Create Date			: 16/02/2025 
// Module Name			: DOMAES444NoReg
// Target Device		: 
// Description			: DOM Small Scale AES 444 with no registers in SBox transform
//
// Version				: 1.0
// Additional Comments	: 
////////////////////////////////////////////////////////////////////////////////////////////////////

module DOMAES444NoReg (
	input			clk,			// Clock
	input			rst,			// Reset   
    
    input   [191:0] r_bits,         // Random shares           
    input   [63:0]  t_mask,         // Text Mask    
    input   [63:0]  k_mask,         // Key Mask
    
    
	input			start,			// Encryption trigger
	input	[63:0]	key_in,			// Key input
	input	[63:0]	text_in,		// Plaintext input
	output	[63:0]	text_out		// Ciphertext output
);
	
	// ==================================================
	// State Machine Stage
	// ==================================================
	`define  IDLE          3'h0           // Idle stage
	`define  ROUND_LOOP    3'h1           // Round stage
	`define  ROUND_LOOP_B  3'h2           // Round stage B

	// ==================================================
	// Internal Signals
	// ==================================================

	// States
	reg			[2:0]	now_state;			// State machine register
	reg			[2:0]	next_state;			// Next state register
	reg			[3:0]	round_n;			// Round counter

	// Key Schedule
	reg			[63:0]	w_a;				// A-Key work register
	reg			[63:0]	w_b;				// B-Key work register
	wire		[3:0]	rcon;				// Round constant
	wire		[15:0]	temp_a;				// Key-A - Temporary
	wire		[15:0]	temp_b;				// Key-B - Temporary
	wire		[63:0]	next_key_a;			// Next round key-A
	wire		[63:0]	next_key_b;			// Next round key-B

	// Encryption
	reg         [63:0]  enc_state_a;        // A-Cipher work register
	reg			[63:0]	enc_state_b;      	// B-Cipher work register
	wire		[3:0]	s_box[0:3][0:3];	// A-SBox
	wire		[3:0]	s_box_b[0:3][0:3];	// B-SBox
	wire		[3:0]	s_row[0:3][0:3];	// A-Shift rows
	wire		[3:0]	s_row_b[0:3][0:3];	// B-Shift rows
	wire		[3:0]	m_col[0:3][0:3];	// A-Mix columns
	wire		[3:0]	m_col_b[0:3][0:3];	// B-Mix columns
	wire		[63:0]	add_roundkey0;		// Initial add A-round key
	wire		[63:0]	add_roundkey0_b;	// Initial add B-round key
	wire		[63:0]	add_roundkey;		// Add round A-key
	wire		[63:0]	add_roundkey_b;		// Add round B-key
	wire		[63:0]	cipher_text;		// A-Ciphertext
	wire        [63:0]  cipher_text_b;      // B-Ciphertext
	wire        [63:0]  masked_in;          // Text_in Masked
	wire        [63:0]  masked_k;           // Key_in Masked
	

	  
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
			if ( next_state == `IDLE ) begin 
			     round_n <= 4'h0;
			end
			else begin
			     round_n <= round_n + 1'b1;
			end
		end
	end

	// Output
	assign text_out = enc_state_a; // ^ enc_state_b;

	// --------------------------------------------------
	// 64-bit Cipher Key Expansion
	// --------------------------------------------------
	always @(posedge clk or posedge rst) begin
		if ( rst ) begin
			w_a <= {64{1'b0}};	// Cipher Round Key register
			w_b <= {64{1'b0}}; 
		end
		else begin
			// Cipher Round Key
			if ( next_state == `IDLE ) begin 
			     w_a <= key_in ^ k_mask;
			     w_b <= k_mask;
			end
			else if ( next_state == `ROUND_LOOP ) begin 
			     w_a <= next_key_a; 
			     w_b <= next_key_b; 
			end
			else begin 
			     w_a <= w_a; 
			     w_b <= w_b; 
			end
		end
	end

	// SubWord
	domSBoxNoR dsb0 (.a(w_a[15:12]), .b(w_b[15:12]), .r_bits(r_bits[11:0]), .aq(temp_a[15:12]), .bq(temp_b[15:12]));
	domSBoxNoR dsb1 (.a(w_a[11:08]), .b(w_b[11:08]), .r_bits(r_bits[11:0]), .aq(temp_a[11:08]), .bq(temp_b[11:08]));
	domSBoxNoR dsb2 (.a(w_a[07:04]), .b(w_b[07:04]), .r_bits(r_bits[11:0]), .aq(temp_a[07:04]), .bq(temp_b[07:04]));
	domSBoxNoR dsb3 (.a(w_a[03:00]), .b(w_b[03:00]), .r_bits(r_bits[11:0]), .aq(temp_a[03:00]), .bq(temp_b[03:00]));
	
	// Next Round Key-A
	assign next_key_a[03:00] = temp_a[15:12] ^ w_a[51:48] ^ w_a[35:32] ^ w_a[19:16] ^ w_a[03:00];
	assign next_key_a[07:04] = temp_a[11:08] ^ w_a[55:52] ^ w_a[39:36] ^ w_a[23:20] ^ w_a[07:04];
	assign next_key_a[11:08] = temp_a[07:04] ^ w_a[59:56] ^ w_a[43:40] ^ w_a[27:24] ^ w_a[11:08];
	assign next_key_a[15:12] = temp_a[03:00] ^ w_a[63:60] ^ w_a[47:44] ^ w_a[31:28] ^ w_a[15:12] ^ rcon;
	assign next_key_a[19:16] = temp_a[15:12] ^ w_a[51:48] ^ w_a[35:32] ^ w_a[19:16];
	assign next_key_a[23:20] = temp_a[11:08] ^ w_a[55:52] ^ w_a[39:36] ^ w_a[23:20];
	assign next_key_a[27:24] = temp_a[07:04] ^ w_a[59:56] ^ w_a[43:40] ^ w_a[27:24];
	assign next_key_a[31:28] = temp_a[03:00] ^ w_a[63:60] ^ w_a[47:44] ^ w_a[31:28] ^ rcon;
	assign next_key_a[35:32] = temp_a[15:12] ^ w_a[51:48] ^ w_a[35:32];
	assign next_key_a[39:36] = temp_a[11:08] ^ w_a[55:52] ^ w_a[39:36];
	assign next_key_a[43:40] = temp_a[07:04] ^ w_a[59:56] ^ w_a[43:40];
	assign next_key_a[47:44] = temp_a[03:00] ^ w_a[63:60] ^ w_a[47:44] ^ rcon;
	assign next_key_a[51:48] = temp_a[15:12] ^ w_a[51:48];
	assign next_key_a[55:52] = temp_a[11:08] ^ w_a[55:52];
	assign next_key_a[59:56] = temp_a[07:04] ^ w_a[59:56];
	assign next_key_a[63:60] = temp_a[03:00] ^ w_a[63:60] ^ rcon;
	
	// Next Round Key-B
	assign next_key_b[03:00] = temp_b[15:12] ^ w_b[51:48] ^ w_b[35:32] ^ w_b[19:16] ^ w_b[03:00];
	assign next_key_b[07:04] = temp_b[11:08] ^ w_b[55:52] ^ w_b[39:36] ^ w_b[23:20] ^ w_b[07:04];
	assign next_key_b[11:08] = temp_b[07:04] ^ w_b[59:56] ^ w_b[43:40] ^ w_b[27:24] ^ w_b[11:08];
	assign next_key_b[15:12] = temp_b[03:00] ^ w_b[63:60] ^ w_b[47:44] ^ w_b[31:28] ^ w_b[15:12];
	assign next_key_b[19:16] = temp_b[15:12] ^ w_b[51:48] ^ w_b[35:32] ^ w_b[19:16];
	assign next_key_b[23:20] = temp_b[11:08] ^ w_b[55:52] ^ w_b[39:36] ^ w_b[23:20];
	assign next_key_b[27:24] = temp_b[07:04] ^ w_b[59:56] ^ w_b[43:40] ^ w_b[27:24];
	assign next_key_b[31:28] = temp_b[03:00] ^ w_b[63:60] ^ w_b[47:44] ^ w_b[31:28];
	assign next_key_b[35:32] = temp_b[15:12] ^ w_b[51:48] ^ w_b[35:32];
	assign next_key_b[39:36] = temp_b[11:08] ^ w_b[55:52] ^ w_b[39:36];
	assign next_key_b[43:40] = temp_b[07:04] ^ w_b[59:56] ^ w_b[43:40];
	assign next_key_b[47:44] = temp_b[03:00] ^ w_b[63:60] ^ w_b[47:44];
	assign next_key_b[51:48] = temp_b[15:12] ^ w_b[51:48];
	assign next_key_b[55:52] = temp_b[11:08] ^ w_b[55:52];
	assign next_key_b[59:56] = temp_b[07:04] ^ w_b[59:56];
	assign next_key_b[63:60] = temp_b[03:00] ^ w_b[63:60];

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
			enc_state_a <= {64{1'b0}};
			enc_state_b <= {64{1'b0}};
		end
		else begin
			if (( start == 1'b1 ) && ( round_n == 4'h0 )) begin	// Nr = 0  Add Round Key
				enc_state_a <= add_roundkey0;
				enc_state_b <= add_roundkey0_b;
			end
			else if (( now_state == `ROUND_LOOP ) && ( round_n >= 4'd1 ) && ( round_n <= 4'd9 )) begin	// Nr = 1 to Nr = 9  Add round key
				enc_state_a <= add_roundkey;
				enc_state_b <= add_roundkey_b;
			end
			else if (( now_state == `ROUND_LOOP ) && ( round_n == 4'd10 )) begin	// Nr = 10
				enc_state_a <= cipher_text ^ cipher_text_b;
			end
			else begin 
			     enc_state_a <= enc_state_a; 
			     enc_state_b <= enc_state_b; 
			end
		end
	end

	// --------------------------------------------------
	// Data Input and Add Round Key(Nr = 0)
	// --------------------------------------------------
	assign add_roundkey0 = masked_in ^ masked_k;
	assign add_roundkey0_b = t_mask ^ k_mask;
    
	// --------------------------------------------------
	// Input Masking
	// --------------------------------------------------
    assign masked_in = text_in ^ t_mask;
    assign masked_k = key_in ^ k_mask;
    
	// --------------------------------------------------
	// SubBytes Transformation
	// --------------------------------------------------
	
	wire[63:0] sbox_a, sbox_b; 
	
    domSBoxNoR dsbt0 (.a(enc_state_a[63:60]), .b(enc_state_b[63:60]), .r_bits(r_bits[011:000]), .aq(sbox_a[63:60]), .bq(sbox_b[63:60]));
	domSBoxNoR dsbt1 (.a(enc_state_a[59:56]), .b(enc_state_b[59:56]), .r_bits(r_bits[023:012]), .aq(sbox_a[59:56]), .bq(sbox_b[59:56]));
	domSBoxNoR dsbt2 (.a(enc_state_a[55:52]), .b(enc_state_b[55:52]), .r_bits(r_bits[035:024]), .aq(sbox_a[55:52]), .bq(sbox_b[55:52]));
	domSBoxNoR dsbt3 (.a(enc_state_a[51:48]), .b(enc_state_b[51:48]), .r_bits(r_bits[047:036]), .aq(sbox_a[51:48]), .bq(sbox_b[51:48]));
	domSBoxNoR dsbt4 (.a(enc_state_a[47:44]), .b(enc_state_b[47:44]), .r_bits(r_bits[059:048]), .aq(sbox_a[47:44]), .bq(sbox_b[47:44]));
	domSBoxNoR dsbt5 (.a(enc_state_a[43:40]), .b(enc_state_b[43:40]), .r_bits(r_bits[071:060]), .aq(sbox_a[43:40]), .bq(sbox_b[43:40]));
	domSBoxNoR dsbt6 (.a(enc_state_a[39:36]), .b(enc_state_b[39:36]), .r_bits(r_bits[083:072]), .aq(sbox_a[39:36]), .bq(sbox_b[39:36]));
	domSBoxNoR dsbt7 (.a(enc_state_a[35:32]), .b(enc_state_b[35:32]), .r_bits(r_bits[095:084]), .aq(sbox_a[35:32]), .bq(sbox_b[35:32]));
	domSBoxNoR dsbt8 (.a(enc_state_a[31:28]), .b(enc_state_b[31:28]), .r_bits(r_bits[107:096]), .aq(sbox_a[31:28]), .bq(sbox_b[31:28]));
	domSBoxNoR dsbt9 (.a(enc_state_a[27:24]), .b(enc_state_b[27:24]), .r_bits(r_bits[119:108]), .aq(sbox_a[27:24]), .bq(sbox_b[27:24]));
	domSBoxNoR dsbta (.a(enc_state_a[23:20]), .b(enc_state_b[23:20]), .r_bits(r_bits[131:120]), .aq(sbox_a[23:20]), .bq(sbox_b[23:20]));
	domSBoxNoR dsbtb (.a(enc_state_a[19:16]), .b(enc_state_b[19:16]), .r_bits(r_bits[143:132]), .aq(sbox_a[19:16]), .bq(sbox_b[19:16]));
	domSBoxNoR dsbtc (.a(enc_state_a[15:12]), .b(enc_state_b[15:12]), .r_bits(r_bits[155:144]), .aq(sbox_a[15:12]), .bq(sbox_b[15:12]));
	domSBoxNoR dsbtd (.a(enc_state_a[11:08]), .b(enc_state_b[11:08]), .r_bits(r_bits[167:156]), .aq(sbox_a[11:08]), .bq(sbox_b[11:08]));
	domSBoxNoR dsbte (.a(enc_state_a[07:04]), .b(enc_state_b[07:04]), .r_bits(r_bits[179:168]), .aq(sbox_a[07:04]), .bq(sbox_b[07:04]));
	domSBoxNoR dsbtf (.a(enc_state_a[03:00]), .b(enc_state_b[03:00]), .r_bits(r_bits[191:180]), .aq(sbox_a[03:00]), .bq(sbox_b[03:00]));
    
    assign s_box[0][0] = sbox_a[63:60];     assign s_box[0][1] = sbox_a[47:44];     assign s_box[0][2] = sbox_a[31:28];     assign s_box[0][3] = sbox_a[15:12];
    assign s_box[1][0] = sbox_a[59:56];     assign s_box[1][1] = sbox_a[43:40];     assign s_box[1][2] = sbox_a[27:24];     assign s_box[1][3] = sbox_a[11:08];
    assign s_box[2][0] = sbox_a[55:52];     assign s_box[2][1] = sbox_a[39:36];     assign s_box[2][2] = sbox_a[23:20];     assign s_box[2][3] = sbox_a[07:04];
    assign s_box[3][0] = sbox_a[51:48];     assign s_box[3][1] = sbox_a[35:32];     assign s_box[3][2] = sbox_a[19:16];     assign s_box[3][3] = sbox_a[03:00];
       
    assign s_box_b[0][0] = sbox_b[63:60];   assign s_box_b[0][1] = sbox_b[47:44];   assign s_box_b[0][2] = sbox_b[31:28];   assign s_box_b[0][3] = sbox_b[15:12];
    assign s_box_b[1][0] = sbox_b[59:56];   assign s_box_b[1][1] = sbox_b[43:40];   assign s_box_b[1][2] = sbox_b[27:24];   assign s_box_b[1][3] = sbox_b[11:08];
    assign s_box_b[2][0] = sbox_b[55:52];   assign s_box_b[2][1] = sbox_b[39:36];   assign s_box_b[2][2] = sbox_b[23:20];   assign s_box_b[2][3] = sbox_b[07:04];
    assign s_box_b[3][0] = sbox_b[51:48];   assign s_box_b[3][1] = sbox_b[35:32];   assign s_box_b[3][2] = sbox_b[19:16];   assign s_box_b[3][3] = sbox_b[03:00];
    
	// --------------------------------------------------
	// ShiftRows
	// --------------------------------------------------
	assign { s_row[0][0], s_row[0][1], s_row[0][2], s_row[0][3] } = { s_box[0][0], s_box[0][1], s_box[0][2], s_box[0][3] };
	assign { s_row[1][0], s_row[1][1], s_row[1][2], s_row[1][3] } = { s_box[1][1], s_box[1][2], s_box[1][3], s_box[1][0] };
	assign { s_row[2][0], s_row[2][1], s_row[2][2], s_row[2][3] } = { s_box[2][2], s_box[2][3], s_box[2][0], s_box[2][1] };
	assign { s_row[3][0], s_row[3][1], s_row[3][2], s_row[3][3] } = { s_box[3][3], s_box[3][0], s_box[3][1], s_box[3][2] };
	
	assign { s_row_b[0][0], s_row_b[0][1], s_row_b[0][2], s_row_b[0][3] } = { s_box_b[0][0], s_box_b[0][1], s_box_b[0][2], s_box_b[0][3] };
	assign { s_row_b[1][0], s_row_b[1][1], s_row_b[1][2], s_row_b[1][3] } = { s_box_b[1][1], s_box_b[1][2], s_box_b[1][3], s_box_b[1][0] };
	assign { s_row_b[2][0], s_row_b[2][1], s_row_b[2][2], s_row_b[2][3] } = { s_box_b[2][2], s_box_b[2][3], s_box_b[2][0], s_box_b[2][1] };
	assign { s_row_b[3][0], s_row_b[3][1], s_row_b[3][2], s_row_b[3][3] } = { s_box_b[3][3], s_box_b[3][0], s_box_b[3][1], s_box_b[3][2] };

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
	
	
	MixColumn MixColumnB0 (
	.s0c( s_row_b[0][0] ), .s1c( s_row_b[1][0] ), .s2c( s_row_b[2][0] ), .s3c( s_row_b[3][0] ),
	.m0c( m_col_b[0][0] ), .m1c( m_col_b[1][0] ), .m2c( m_col_b[2][0] ), .m3c( m_col_b[3][0] )
	);
	MixColumn MixColumnB1 (
	.s0c( s_row_b[0][1] ), .s1c( s_row_b[1][1] ), .s2c( s_row_b[2][1] ), .s3c( s_row_b[3][1] ),
	.m0c( m_col_b[0][1] ), .m1c( m_col_b[1][1] ), .m2c( m_col_b[2][1] ), .m3c( m_col_b[3][1] )
	);
	MixColumn MixColumnB2 (
	.s0c( s_row_b[0][2] ), .s1c( s_row_b[1][2] ), .s2c( s_row_b[2][2] ), .s3c( s_row_b[3][2] ),
	.m0c( m_col_b[0][2] ), .m1c( m_col_b[1][2] ), .m2c( m_col_b[2][2] ), .m3c( m_col_b[3][2] )
	);
	MixColumn MixColumnB3 (
	.s0c( s_row_b[0][3] ), .s1c( s_row_b[1][3] ), .s2c( s_row_b[2][3] ), .s3c( s_row_b[3][3] ),
	.m0c( m_col_b[0][3] ), .m1c( m_col_b[1][3] ), .m2c( m_col_b[2][3] ), .m3c( m_col_b[3][3] )
	);

	// --------------------------------------------------
	// Add Round Key
	// --------------------------------------------------
	// Nr = 1 to Nr = 9 for A-Text
	assign add_roundkey[63:48] = { m_col[0][0], m_col[1][0], m_col[2][0], m_col[3][0] } ^ w_a[63:48]; // ^ w_b[63:48];
	assign add_roundkey[47:32] = { m_col[0][1], m_col[1][1], m_col[2][1], m_col[3][1] } ^ w_a[47:32]; // ^ w_b[47:32];
	assign add_roundkey[31:16] = { m_col[0][2], m_col[1][2], m_col[2][2], m_col[3][2] } ^ w_a[31:16]; // ^ w_b[31:16];
	assign add_roundkey[15:00] = { m_col[0][3], m_col[1][3], m_col[2][3], m_col[3][3] } ^ w_a[15:00]; // ^ w_b[15:00];
	
	// Nr = 1 to Nr = 9 for B-Text
	assign add_roundkey_b[63:48] = { m_col_b[0][0], m_col_b[1][0], m_col_b[2][0], m_col_b[3][0] } ^ w_b[63:48];
	assign add_roundkey_b[47:32] = { m_col_b[0][1], m_col_b[1][1], m_col_b[2][1], m_col_b[3][1] } ^ w_b[47:32];
	assign add_roundkey_b[31:16] = { m_col_b[0][2], m_col_b[1][2], m_col_b[2][2], m_col_b[3][2] } ^ w_b[31:16];
	assign add_roundkey_b[15:00] = { m_col_b[0][3], m_col_b[1][3], m_col_b[2][3], m_col_b[3][3] } ^ w_b[15:00];

	// Nr = 10 
	// A-Cipher Text Output
	assign cipher_text[63:48] = { s_row[0][0], s_row[1][0], s_row[2][0], s_row[3][0] } ^ w_a[63:48]; // ^ w_b[63:48];
	assign cipher_text[47:32] = { s_row[0][1], s_row[1][1], s_row[2][1], s_row[3][1] } ^ w_a[47:32]; // ^ w_b[47:32];
	assign cipher_text[31:16] = { s_row[0][2], s_row[1][2], s_row[2][2], s_row[3][2] } ^ w_a[31:16]; // ^ w_b[31:16];
	assign cipher_text[15:00] = { s_row[0][3], s_row[1][3], s_row[2][3], s_row[3][3] } ^ w_a[15:00]; // ^ w_b[15:00];
	
	// B-Cipher Text Output
	assign cipher_text_b[63:48] = { s_row_b[0][0], s_row_b[1][0], s_row_b[2][0], s_row_b[3][0] } ^ w_b[63:48];
	assign cipher_text_b[47:32] = { s_row_b[0][1], s_row_b[1][1], s_row_b[2][1], s_row_b[3][1] } ^ w_b[47:32];
	assign cipher_text_b[31:16] = { s_row_b[0][2], s_row_b[1][2], s_row_b[2][2], s_row_b[3][2] } ^ w_b[31:16];
	assign cipher_text_b[15:00] = { s_row_b[0][3], s_row_b[1][3], s_row_b[2][3], s_row_b[3][3] } ^ w_b[15:00];

endmodule