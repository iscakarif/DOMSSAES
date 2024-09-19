////////////////////////////////////////////////////////////////////////////////////////////////////
// Company				: ITI - Universität Stuttgart
// Engineer				: Maël Gay
// 
// Create Date			: 04/02/2018 
// Module Name			: sc_aes_444_table_ecb
// Target Device		: 
// Description			: Encryption - Small Scale AES 444
//
// Version				: 1.0
// Additional Comments	: 
////////////////////////////////////////////////////////////////////////////////////////////////////

`timescale 1 ns/10 ps

module sc_aes_444_table_ecb (
  input               resetn,       // Async reset
  input               clock,        // Clock
  input               enc_dec,      // Encrypt/Decrypt select. 0:Encrypt  1:Decrypt
  input               start,        // Encrypt or Decrypt Start
  input      [63:0]   key_in,       // Key input
  input      [63:0]   text_in,      // Cipher Text or Inverse Cipher Text input
  output     [63:0]   text_out,     // Cipher Text or Inverse Cipher Text output
  output    		  debug,		// Debug Output Parameters
  output reg          busy          // AES unit Busy
);

// State Machine stage name
`define  IDLE				3'h0 // Idle stage.
`define  ROUND_LOOP_START	3'h1 // Cipher start stage.
`define  ROUND_LOOP_SB		3'h2 // Cipher SBox stage.
`define  ROUND_LOOP_MC		3'h3 // Cipher permutation stage.
`define  ROUND_LOOP_KS		3'h4 // Cipher key schedule stage.
`define  ROUND_LOOP_ARK		3'h5 // Cipher add round key stage.
`define  ROUND_LOOP_END		3'h6 // Cipher end stage.

// ==================================================================
// Internal signals
// ==================================================================
  reg       [2:0]  now_state;       // State Machine register
  reg       [2:0]  next_state;      // Next State Machine value
  reg              start_flag;      // Cipher or Inverse Cipher start pending flag
  reg       [3:0]  round_n;         // Number of Round counter

// Cipher Key Expansion
  reg     [63:0]  w;				// Cipher Key work register
  wire    [3:0]   rcon;				// The round constant word array
  wire    [15:0]  temp;				// Key Expansion temporary value
  wire    [63:0]  next_key;			// Cipher Next round Key value

// Cipher (Encrypt)
  reg     [63:0]  sb_out;      		// Sbox output
  reg     [63:0]  mc_out;      		// MixColumns output
  reg     [63:0]  ark_out;      	// Add Round Key output
  reg     [63:0]  ciphertext;		// Ciphertext register
  wire    [3:0]   s_box[0:3][0:3];
  wire    [3:0]   s_row[0:3][0:3];
  wire    [3:0]   m_col[0:3][0:3];
  wire    [63:0]  add_roundkey0;
  wire    [63:0]  add_roundkey;

// ================================================================================
// Equations
// ================================================================================
// --------------------------------------------------------------------------------
// Main State Machine
// --------------------------------------------------------------------------------
  always @( now_state or enc_dec or start or start_flag or round_n ) begin
    case ( now_state )
      `IDLE       : if ( start == 1'b1 )
                      next_state = `ROUND_LOOP_START;
                    else if ( start_flag == 1'b1 ) next_state = `ROUND_LOOP_START;
                    else next_state = `IDLE;
      `ROUND_LOOP_START : next_state = `ROUND_LOOP_SB; // Round 0
	  `ROUND_LOOP_SB    : next_state = `ROUND_LOOP_MC; // SBox Layer
	  `ROUND_LOOP_MC    : next_state = `ROUND_LOOP_KS; // Permutation Layer
	  `ROUND_LOOP_KS    : next_state = `ROUND_LOOP_ARK; // Key Schedule
	  `ROUND_LOOP_ARK    : if ( round_n == 4'd10 ) next_state = `ROUND_LOOP_END; // Add Round Key
						   else next_state = `ROUND_LOOP_SB;
      `ROUND_LOOP_END : next_state = `IDLE; // End of Encryption
       default    : next_state = `IDLE;
    endcase
  end

  always @(posedge clock or negedge resetn) begin
    if ( resetn == 1'b0 ) now_state <= `IDLE;
    else now_state <= next_state;
  end


// ------------------------------------------------------------------------------
// Control signals
// ------------------------------------------------------------------------------
  always @(posedge clock or negedge resetn) begin
    if ( resetn == 1'b0 ) begin
      busy <= 1'b0;
      start_flag <= 1'b0;
      round_n <= 4'h0;
    end
    else begin
      // Busy flag
      if ( start == 1'b1 ) busy <= 1'b1;
      else if ( now_state == `ROUND_LOOP_END ) busy <= 1'b0;
      else busy <= busy;

      // Start flag
      if ( start == 1'b1 ) start_flag <= 1'b1;
      else if ( now_state == `ROUND_LOOP_START ) start_flag <= 1'b0;
      else start_flag <= start_flag;

      // Nr counter
      if ( now_state == `IDLE ) round_n <= 4'h0;
	  else if ( now_state == `ROUND_LOOP_SB ) round_n <= round_n + 1'b1;
	  else round_n <= round_n;
    end
  end

  // Outputs
  assign text_out = ciphertext;
  
  // Debug
  assign debug = round_n[0];


// ------------------------------------------------------------------------------------------
// SC-AES-444.Encrypt
// Cipher
// ------------------------------------------------------------------------------------------
  // Cipher state registers
  always @(posedge clock or negedge resetn) begin
    if ( resetn == 1'b0 ) begin
	  //Encryption
	  sb_out <= {64{1'b0}};
	  mc_out <= {64{1'b0}};
	  w <= {64{1'b0}};
	  ark_out <= {64{1'b0}};
      ciphertext <= {64{1'b0}};
    end
    else begin
	  // SBox layer
	  if ( now_state == `ROUND_LOOP_SB ) begin
		sb_out <= { s_box[0][0], s_box[1][0], s_box[2][0], s_box[3][0],
					s_box[0][1], s_box[1][1], s_box[2][1], s_box[3][1],
					s_box[0][2], s_box[1][2], s_box[2][2], s_box[3][2],
					s_box[0][3], s_box[1][3], s_box[2][3], s_box[3][3] };
	  end
	  else sb_out <= sb_out;
	  // Permutation layer
	  if ( ( now_state == `ROUND_LOOP_MC ) && ( round_n >= 4'd1 ) && ( round_n <= 4'd9 ) ) begin
		mc_out <= { m_col[0][0], m_col[1][0], m_col[2][0], m_col[3][0],
					m_col[0][1], m_col[1][1], m_col[2][1], m_col[3][1],
					m_col[0][2], m_col[1][2], m_col[2][2], m_col[3][2],
					m_col[0][3], m_col[1][3], m_col[2][3], m_col[3][3] };
	  end
	  else if ( ( now_state == `ROUND_LOOP_MC ) && ( round_n == 4'd10 ) ) begin
		mc_out <= { s_row[0][0], s_row[1][0], s_row[2][0], s_row[3][0],
					s_row[0][1], s_row[1][1], s_row[2][1], s_row[3][1],
					s_row[0][2], s_row[1][2], s_row[2][2], s_row[3][2],
					s_row[0][3], s_row[1][3], s_row[2][3], s_row[3][3] };
	  end
	  else mc_out <= mc_out;
	  // Cipher Round Key
      if ( next_state == `IDLE ) begin
		w <= key_in;
	  end
      else if (now_state == `ROUND_LOOP_KS) begin
		w <= next_key;
	  end
      else w <= w;
	  // Add Round Key
	  if ( (( start == 1'b1 ) || ( start_flag == 1'b1 )) && ( round_n == 4'h0 ) ) begin // Round 0
		ark_out <= add_roundkey0;
	  end
	  else if ( now_state == `ROUND_LOOP_ARK ) begin
		ark_out <= add_roundkey;
	  end
	  else ark_out <= ark_out;
	  // Ciphertext
      if ( enc_dec == 1'b0 ) begin
        /*if ((( start == 1'b1 ) || ( start_flag == 1'b1 )) && ( round_n == 4'h0 )) begin // Round 0
          ciphertext <= {64{1'b0}};
        end
		else*/ if ( ( now_state == `ROUND_LOOP_END ) ) begin
          ciphertext <= ark_out;
        end
        else ciphertext <= ciphertext;
      end
      else ciphertext <= ciphertext;
    end
  end

  // ------------------------------------------------------------------------------------------------------------
  // Data Input and Add Round Key (Nr = 0)
  // ------------------------------------------------------------------------------------------------------------
  assign add_roundkey0 = text_in ^ w;

  // ------------------------------------------------------------------------------------------------------------
  // SubBytes Transformation
  // ------------------------------------------------------------------------------------------------------------
  subbytes SubBytes0 (
	.a00( ark_out[63:60] ), .a01( ark_out[47:44] ), .a02( ark_out[31:28] ), .a03( ark_out[15:12] ),
	.a10( ark_out[59:56] ), .a11( ark_out[43:40] ), .a12( ark_out[27:24] ), .a13( ark_out[11:08] ),
	.a20( ark_out[55:52] ), .a21( ark_out[39:36] ), .a22( ark_out[23:20] ), .a23( ark_out[07:04] ),
	.a30( ark_out[51:48] ), .a31( ark_out[35:32] ), .a32( ark_out[19:16] ), .a33( ark_out[03:00] ),

	.b00( s_box[0][0] ), .b01( s_box[0][1] ), .b02( s_box[0][2] ), .b03( s_box[0][3] ),
	.b10( s_box[1][0] ), .b11( s_box[1][1] ), .b12( s_box[1][2] ), .b13( s_box[1][3] ),
	.b20( s_box[2][0] ), .b21( s_box[2][1] ), .b22( s_box[2][2] ), .b23( s_box[2][3] ),
	.b30( s_box[3][0] ), .b31( s_box[3][1] ), .b32( s_box[3][2] ), .b33( s_box[3][3] )
	);

  // ------------------------------------------------------------------------------------------------------------
  // ShiftRows
  // ------------------------------------------------------------------------------------------------------------
  assign { s_row[0][0], s_row[0][1], s_row[0][2], s_row[0][3] } = { sb_out[63:60], sb_out[47:44], sb_out[31:28], sb_out[15:12] };
  assign { s_row[1][0], s_row[1][1], s_row[1][2], s_row[1][3] } = { sb_out[43:40], sb_out[27:24], sb_out[11:08], sb_out[59:56] };
  assign { s_row[2][0], s_row[2][1], s_row[2][2], s_row[2][3] } = { sb_out[23:20], sb_out[07:04], sb_out[55:52], sb_out[39:36] };
  assign { s_row[3][0], s_row[3][1], s_row[3][2], s_row[3][3] } = { sb_out[03:00], sb_out[51:48], sb_out[35:32], sb_out[19:16] };

  // ------------------------------------------------------------------------------------------------------------
  // MixColumns
  // ------------------------------------------------------------------------------------------------------------
  mixcolumns MixColumns0 (
    .s0c( s_row[0][0] ), .s1c( s_row[1][0] ), .s2c( s_row[2][0] ), .s3c( s_row[3][0] ),
    .m0c( m_col[0][0] ), .m1c( m_col[1][0] ), .m2c( m_col[2][0] ), .m3c( m_col[3][0] )
  );
  mixcolumns MixColumns1 (
    .s0c( s_row[0][1] ), .s1c( s_row[1][1] ), .s2c( s_row[2][1] ), .s3c( s_row[3][1] ),
    .m0c( m_col[0][1] ), .m1c( m_col[1][1] ), .m2c( m_col[2][1] ), .m3c( m_col[3][1] )
  );
  mixcolumns MixColumns2 (
    .s0c( s_row[0][2] ), .s1c( s_row[1][2] ), .s2c( s_row[2][2] ), .s3c( s_row[3][2] ),
    .m0c( m_col[0][2] ), .m1c( m_col[1][2] ), .m2c( m_col[2][2] ), .m3c( m_col[3][2] )
  );
  mixcolumns MixColumns3 (
    .s0c( s_row[0][3] ), .s1c( s_row[1][3] ), .s2c( s_row[2][3] ), .s3c( s_row[3][3] ),
    .m0c( m_col[0][3] ), .m1c( m_col[1][3] ), .m2c( m_col[2][3] ), .m3c( m_col[3][3] )
  );
  
  // ------------------------------------------------------------------------------------------------------------
  // Key Schedule
  // ------------------------------------------------------------------------------------------------------------
  
  // SubWord
  subword SubWord ( .a( w[15: 0] ), .b( temp ));

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

  // Rcon[] The round constant word array
  assign rcon = ( round_n == 4'h1 )? 4'h1 : 4'h0
			  | ( round_n == 4'h2 )? 4'h2 : 4'h0
			  | ( round_n == 4'h3 )? 4'h4 : 4'h0
			  | ( round_n == 4'h4 )? 4'h8 : 4'h0
			  | ( round_n == 4'h5 )? 4'h3 : 4'h0
			  | ( round_n == 4'h6 )? 4'h6 : 4'h0
			  | ( round_n == 4'h7 )? 4'hc : 4'h0
			  | ( round_n == 4'h8 )? 4'hb : 4'h0
			  | ( round_n == 4'h9 )? 4'h5 : 4'h0
			  | ( round_n == 4'ha )? 4'ha : 4'h0;

  // ------------------------------------------------------------------------------------------------------------
  // Add Round Key
  // ------------------------------------------------------------------------------------------------------------
  assign add_roundkey = mc_out ^ w;

endmodule



/////////////////////////////////////////////////////////////////////////////////////////////////////////
// Module Name         : subbytes
/////////////////////////////////////////////////////////////////////////////////////////////////////////
module subbytes (
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

/////////////////////////////////////////////////////////////////////////////////////////////////////////
// Module Name         : subword
/////////////////////////////////////////////////////////////////////////////////////////////////////////
module subword (
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


/////////////////////////////////////////////////////////////////////////////////////////////////////////
// Module Name         : mixcolumns
/////////////////////////////////////////////////////////////////////////////////////////////////////////
module mixcolumns( 
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