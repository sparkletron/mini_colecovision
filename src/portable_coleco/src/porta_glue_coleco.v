//******************************************************************************
/// file:   porta_glue_coleco.v
/// author: Jay Convertino (electrobs@gmail.com)
/// date:   2023/27/12
/// brief:  TTL Glue logic of the coleco reduced for a 2 player portable.
///         - More signals then neeeded, future proof to add more features for
///           larger CPLDS. If not needed just don't connect in schematic.
///           Idea is a serial device to take control of the bus to read data
///           from devices attached. Probably won't fit on a EPM7064.
//******************************************************************************

`define DEF_RESET_BINARY_DELAY      15
`define DEF_VDP_RESET_BINARY_DELAY   4

module porta_glue_coleco
  (
    input         clk,
    input [15:0]  A,
    input         C1P0,
    input         C1P1,
    input         C1P2,
    input         C1P3,
    input         C1P5,
    input         C1P6,
    input         C2P0,
    input         C2P1,
    input         C2P2,
    input         C2P3,
    input         C2P5,
    input         C2P6,
    input         MREQn,
    input         IORQn,
    input         RFSHn,
    input         M1n,
    input         WRn,
    input         RESETn_SW,
    input         RDn,
    input         RX,
    input         BUSAKn,
    output        C4_ARM,
    output        C7_FIRE,
    output [7:0]  D,
    output        CS_h8000n,
    output        CS_hA000n,
    output        CS_hC000n,
    output        CS_hE000n,
    output        SND_ENABLEn,
    output        ROM_ENABLEn,
    output        RAM_CSn,
    output        RAM_OEn,
    output        CSWn,
    output        CSRn,
    output        WAITn,
    output        RESETn,
    output        VDP_RESETn,
    output        INTn,
    output        TX,
    output        BUSREQn
  );

  //decoder logic
  wire s_enable_u5;
  wire s_enable_u6;
  wire s_ctrl_en_1n;
  wire s_ctrl_en_2n;
  wire s_ctrl_readn;
  wire s_ram_csn;

  //wait d flip flop
  reg         r_wait          = 1'b0;

  //timed reset circuit counter
  reg [15:0]  r_reset_counter = 0;
  reg         r_resetn        = 0;
  reg         r_vdp_resetn    = 0;

  //emulate feedback nand circuit
  reg         r_ctrl_fire     = 1'b0;
  reg         r_ctrl_arm      = 1'b1;

  //dangling outputs
  assign INTn     = 1'bz;

  assign TX       = 1'bz;

  assign BUSREQn  = 1'bz;

  //****************************************************************************
  /// RAM Output enable when read is needed.
  //****************************************************************************
  assign RAM_OEn = RDn | s_ram_csn;

  //****************************************************************************
  /// decoder for address selection.
  /// No clock, based on AND from TI 74138 datasheet.
  //****************************************************************************

  assign RAM_CSn = s_ram_csn;
  //AUX_DECODE always 1, RFSH is a double inversion on coleco (inverter + 138 internal)
  assign s_enable_u5 = (RFSHn & ~MREQn); //add AUX_DECODE_1 for CS_h2000n/CS_h4000n on the expansion port.

  assign ROM_ENABLEn    = ~(s_enable_u5 & ~A[15] & ~A[14] & ~A[13]); //Y0
  // assign CS_h2000n   = ~(s_enable_u5 & ~A15 & ~A14 &  A13); //Y1
  // assign CS_h4000n   = ~(s_enable_u5 & ~A15 &  A14 & ~A13); //Y2
  assign s_ram_csn      = ~(s_enable_u5 & ~A[15] &  A[14] &  A[13]); //Y3
  assign CS_h8000n      = ~(s_enable_u5 &  A[15] & ~A[14] & ~A[13]); //Y4
  assign CS_hA000n      = ~(s_enable_u5 &  A[15] & ~A[14] &  A[13]); //Y5
  assign CS_hC000n      = ~(s_enable_u5 &  A[15] &  A[14] & ~A[13]); //Y6
  assign CS_hE000n      = ~(s_enable_u5 &  A[15] &  A[14] &  A[13]); //Y7

  assign s_enable_u6 = (A[7] & ~IORQn); //add ~AUX_DECODE_2 for expansion port

  assign s_ctrl_en_2n   = ~(s_enable_u6 & ~A[6] & ~A[5] & ~WRn); //Y0, FIRE
  // assign NOTHING     = ~(s_enable_u6 & ~A6 & ~A5 &  WRn); //Y1, NOT USED IN COLECO
  assign CSWn           = ~(s_enable_u6 & ~A[6] &  A[5] & ~WRn); //Y2
  assign CSRn           = ~(s_enable_u6 & ~A[6] &  A[5] &  WRn); //Y3
  assign s_ctrl_en_1n   = ~(s_enable_u6 &  A[6] & ~A[5] & ~WRn); //Y4, ARM
  // assign NOTHING     = ~(s_enable_u6 &  A6 & ~A5 &  WRn); //Y5, NOT USED IN COLECO
  assign SND_ENABLEn    = ~(s_enable_u6 &  A[6] &  A[5] & ~WRn); //Y6
  assign s_ctrl_readn   = ~(s_enable_u6 &  A[6] &  A[5] &  WRn); //Y7


  //****************************************************************************
  /// wait generate
  /// D flip flop used to generate wait. Original uses a inverted clock in
  /// reference to the original. using a negedge will emulate the same without
  /// generating a new inverted clock.
  //****************************************************************************
  assign WAITn = (r_wait ? ~r_wait : 1'bz);

  always @(negedge clk)
  begin
    r_wait <= ~r_wait;

    if(M1n == 1'b1)
    begin
      r_wait <= 1'b0;
    end
  end

  //****************************************************************************
  /// Reset circuit based on number of cycle count, replace cap/resistor.
  //****************************************************************************
  assign RESETn     = r_resetn;
  assign VDP_RESETn = r_vdp_resetn;

  always @(negedge clk)
  begin

    r_reset_counter <= r_reset_counter + 1;

    if(r_reset_counter[`DEF_VDP_RESET_BINARY_DELAY] == 1'b1)
    begin
      r_vdp_resetn <= 1'b1;
    end

    if(r_reset_counter[`DEF_RESET_BINARY_DELAY] == 1'b1)
    begin
      r_resetn        <= 1'b1;
      r_reset_counter <= r_reset_counter;
    end

    if(RESETn_SW == 1'b0)
    begin
      r_resetn        <= 1'b0;
      r_vdp_resetn    <= 1'b0;
      r_reset_counter <= 0;
    end
  end

  //****************************************************************************
  /// Controller Player 1 and 2
  /// Player 1 and 2, Joystick pad only. Removed all other compatibilty for the
  /// portable console.
  //****************************************************************************

  //controller, original was a NAND circuit that would keep the last selection enabled till the other controller select is enabled.
  //1st player and 2nd player
  assign C4_ARM   = r_ctrl_arm;
  assign C7_FIRE  = r_ctrl_fire;

  //player 1
  assign D[0] = (~s_ctrl_readn & ~A[1] ? C1P0 : 1'bz);
  assign D[1] = (~s_ctrl_readn & ~A[1] ? C1P3 : 1'bz);
  assign D[2] = (~s_ctrl_readn & ~A[1] ? C1P1 : 1'bz);
  assign D[3] = (~s_ctrl_readn & ~A[1] ? C1P2 : 1'bz);
  assign D[4] = (~s_ctrl_readn & ~A[1] ? 1'b1 : 1'bz); //feedback isn't used for standard controller
  assign D[5] = (~s_ctrl_readn & ~A[1] ? C1P6 : 1'bz);
  assign D[6] = (~s_ctrl_readn & ~A[1] ? C1P5 : 1'bz);
  assign D[7] = (~s_ctrl_readn & ~A[1] ? 1'b1 : 1'bz); //feedback isn't used for standard controller

  //player 2
  assign D[0] = (~s_ctrl_readn & A[1] ? C2P0 : 1'bz);
  assign D[1] = (~s_ctrl_readn & A[1] ? C2P3 : 1'bz);
  assign D[2] = (~s_ctrl_readn & A[1] ? C2P1 : 1'bz);
  assign D[3] = (~s_ctrl_readn & A[1] ? C2P2 : 1'bz);
  assign D[4] = (~s_ctrl_readn & A[1] ? 1'b1 : 1'bz); //feedback isn't used for standard controller
  assign D[5] = (~s_ctrl_readn & A[1] ? C2P6 : 1'bz);
  assign D[6] = (~s_ctrl_readn & A[1] ? C2P5 : 1'bz);
  assign D[7] = (~s_ctrl_readn & A[1] ? 1'b1 : 1'bz); //feedback isn't used for standard controller
	
  //emulation of feedback nand, hold last state by default.
  //00 is a invalid state.
  always @(negedge clk) //probably fast enough that it doesn't matter.
  begin
    r_ctrl_arm  <= r_ctrl_arm;
    r_ctrl_fire <= r_ctrl_fire;

    if((s_ctrl_en_1n ^ s_ctrl_en_2n) == 1'b1)
    begin
      r_ctrl_arm  <= ~s_ctrl_en_1n;
      r_ctrl_fire <= ~s_ctrl_en_2n;
    end
  end

endmodule
