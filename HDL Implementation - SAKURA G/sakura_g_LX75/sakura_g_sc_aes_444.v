////////////////////////////////////////////////////////////////////////////////////////////////////
// Company				: ITI - Universität Stuttgart
// Engineer				: Maël Gay
// 
// Create Date			: 28.09.2022
// Module Name			: sakura_g_sc_aes_444
// Target Device		: 
// Description			: Main - SSAES
//
// Version				: 1.0
// Additional Comments	: 
////////////////////////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module sakura_g_sc_aes_444(
  // Host interface
  input         lbus_rstn,    // Reset from Control FPGA
  input         lbus_clk,     // Clock from Control FPGA

  output        lbus_rdy,     // Device ready
  input   [7:0] lbus_wd,      // Local bus data input
  input         lbus_we,      // Data write enable
  output        lbus_ful,     // Data write ready low
  output        lbus_aful,    // Data near write end
  output  [7:0] lbus_rd,      // Data output
  input         lbus_re,      // Data read enable
  output        lbus_emp,     // Data read ready low
  output        lbus_aemp,    // Data near read end
  output        TRGOUTn,      // AES start trigger (SAKURA-G Only)

  // LED display
  output  [6:0] led,          // M_LED (led[8], led[9] SAKURA-G Only)

  // Trigger output
  output  [4:0] M_HEADER,     // User Header Pin (SAKURA-G Only)
  output        M_CLK_EXT0_P, // J4 SMA  AES start (SAKURA-G Only)

  // FTDI USB interface portB (SAKURA-G Only)
  // FTDI side
  input         FTDI_BCBUS0_RXF_B,
  input         FTDI_BCBUS1_TXE_B,
  output        FTDI_BCBUS2_RD_B,
  output        FTDI_BCBUS3_WR_B,
  inout   [7:0] FTDI_BDBUS_D,

  // FTDI USB interface portB (SAKURA-G Only)
  // Control FPGA side
  output        PORT_B_RXF,
  output        PORT_B_TXE,
  input         PORT_B_RD,
  input         PORT_B_WR,
  input   [7:0] PORT_B_DIN,
  output  [7:0] PORT_B_DOUT,
  input         PORT_B_OEn,
  
  // Main FPGA Clock
  input         M_CLK_OSC
);

// ================================================================================
// Internal signals
// ================================================================================
  // Reset and clock
  wire          resetn; // Hardware reset
  wire          clock;  // System clock

  // Block cipher
  wire          enc_dec;  // Encrypt/Decrypt select. 0:Encrypt  1:Decrypt
  wire          start;    // Encrypt or Decrypt Start
  wire  [63:0]  key;      // Round Key input
  wire  [63:0]  text_in;  // Cipher Text or Inverse Cipher Text input
  wire  [63:0]  text_out; // Cipher Text or Inverse Cipher Text output
  wire  		debug;    // Debug Output Parameters
  wire          busy;     // AES unit Busy

  // etc
  reg    [21:0] count;  // Clock monitor counter

// ================================================================================
// Equations
// ================================================================================
  // ------------------------------------------------------------------------------
  // Clock input driver
  // ------------------------------------------------------------------------------
  IBUFG clkdrv (.I( lbus_clk ), .O( clock )); // 48MHz input

  // ------------------------------------------------------------------------------
  // Trigger signals output
  // ------------------------------------------------------------------------------
  assign M_HEADER[0] = start;      // trig_startn
  assign M_HEADER[1] = busy;       // trig_exec
  assign M_HEADER[2] = enc_dec;    // trig_mode
  assign M_HEADER[3] = debug;      // debug signal

  assign M_CLK_EXT0_P = start;     // SMA J4 output

  assign TRGOUTn = ~start;

  // ------------------------------------------------------------------------------
  // Host interface
  // ------------------------------------------------------------------------------
  host_if host_if (
    .RSTn( lbus_rstn ), .CLK( clock ),
    .RSTOUTn( resetn ),
    .DEVRDY( lbus_rdy ), .RRDYn( lbus_emp ), .WRDYn( lbus_ful ),
    .HRE( lbus_re ), .HWE( lbus_we ), .HDIN( lbus_wd ), .HDOUT( lbus_rd ),
    .ENCn_DEC( enc_dec ), .DATA_EN( start ),
    .KEY_OUT( key ), .DATA_OUT( text_in ), .RESULT( text_out )
  );

  assign lbus_aful = 1'b1;
  assign lbus_aemp = 1'b1;


  // ------------------------------------------------------------------------------
  // AES unit
  // ------------------------------------------------------------------------------
  sc_aes_444_table_ecb ssaes_unit (
    .resetn( resetn ), .clock( clock ),
    .enc_dec( enc_dec ), .start( start ),
    .key_in( key ), .text_in( text_in ), .text_out( text_out ),
    .debug( debug ),
    .busy( busy )
  );

  // ------------------------------------------------------------------------------
  // Clock monitor counter
  // ------------------------------------------------------------------------------
  always @( posedge clock or negedge resetn ) begin
    if ( resetn == 1'b0 ) count <= 22'h000000;
    else count <= count + 1'b1;
  end

  // ------------------------------------------------------------------------------
  // LED display outputs
  // ------------------------------------------------------------------------------
  assign led[0] = ~resetn;
  assign led[1] = lbus_rdy;      // Main FPGA ready
  assign led[2] = enc_dec;
  assign led[3] = start;
  assign led[4] = busy;
  assign led[5] = count[21];
  assign led[6] = ~count[21];

  // ------------------------------------------------------------------------------
  // USB PORT B
  // ------------------------------------------------------------------------------
  assign PORT_B_RXF = FTDI_BCBUS0_RXF_B;
  assign PORT_B_TXE = FTDI_BCBUS1_TXE_B;
  assign FTDI_BCBUS2_RD_B = PORT_B_RD;
  assign FTDI_BCBUS3_WR_B = PORT_B_WR;
  assign FTDI_BDBUS_D = ( PORT_B_OEn == 1'b0 )? PORT_B_DIN : 8'hzz;
  assign PORT_B_DOUT = FTDI_BDBUS_D;

endmodule