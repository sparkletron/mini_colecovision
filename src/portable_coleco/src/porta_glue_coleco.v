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

`define DEF_RESET_BINARY_DELAY      21
`define DEF_VDP_RESET_BINARY_DELAY   4

module porta_glue_coleco
  (
    input         clk,
    input [15:0]  A,
    input         C1_0,
    input         C1_1,
    input         C1_2,
    input         C1_3,
    input         C1_5,
    input         C1_6,
    input         C1_8,
    input         C2_0,
    input         C2_1,
    input         C2_2,
    input         C2_3,
    input         C2_5,
    input         C2_6,
    input         C2_8,
    input         MREQn,
    input         IORQn,
    input         RFSHn,
    input         M1n,
    input         WRn,
    input         RESETn_SW,
    input         RDn,
    output        C1_4,
    output        C1_7,
    output        C2_4,
    output        C2_7,
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
    output        INTn
  );

  //decoder logic
  wire enable_u5;
  wire enable_u6;
  wire ctrl_en_1n;
  wire ctrl_en_2n;
  wire ctrl_readn;
  wire ram_csn;

  //wait d flip flop
  reg r_wait = 1'b0;

  //timed reset circuit counter
  reg [31:0] reset_counter = 0;
  reg r_resetn = 0;
  reg r_vdp_resetn = 0;

  //emulate feedback nand circuit
  reg r_ctrl_fire = 1'b0;
  reg r_ctrl_arm  = 1'b1;

  //dangling outputs
  assign INTn = 1'bz;

  //****************************************************************************
  /// RAM Output enable when read is needed.
  //****************************************************************************
  assign RAM_OEn = RDn | ram_csn;

  //****************************************************************************
  /// decoder for address selection.
  /// No clock, based on AND from TI 74138 datasheet.
  //****************************************************************************

  assign RAM_CSn = ram_csn;
  //AUX_DECODE always 1, RFSH is a double inversion (inverter + 138 internal)
  assign enable_u5 = (RFSHn & ~MREQn); //add ~AUX_DECODE_1 for CS_h2000n/CS_h4000n on the expansion port.

  assign ROM_ENABLEn  = ~(enable_u5 & ~A[15] & ~A[14] & ~A[13]); //Y0
  // assign CS_h2000n = ~(enable_u5 & ~A15 & ~A14 &  A13); //Y1
  // assign CS_h4000n = ~(enable_u5 & ~A15 &  A14 & ~A13); //Y2
  assign ram_csn      = ~(enable_u5 & ~A[15] &  A[14] &  A[13]); //Y3
  assign CS_h8000n    = ~(enable_u5 &  A[15] & ~A[14] & ~A[13]); //Y4
  assign CS_hA000n    = ~(enable_u5 &  A[15] & ~A[14] &  A[13]); //Y5
  assign CS_hC000n    = ~(enable_u5 &  A[15] &  A[14] & ~A[13]); //Y6
  assign CS_hE000n    = ~(enable_u5 &  A[15] &  A[14] &  A[13]); //Y7

  assign enable_u6 = (A[7] & ~IORQn); //add ~AUX_DECODE_2 for expansion port

  assign ctrl_en_2n   = ~(enable_u6 & ~A[6] & ~A[5] & ~WRn); //Y0, FIRE
  // assign NOTHING   = ~(enable_u6 & ~A6 & ~A5 &  WRn); //Y1, NOT USED IN COLECO
  assign CSWn         = ~(enable_u6 & ~A[6] &  A[5] & ~WRn); //Y2
  assign CSRn         = ~(enable_u6 & ~A[6] &  A[5] &  WRn); //Y3
  assign ctrl_en_1n   = ~(enable_u6 &  A[6] & ~A[5] & ~WRn); //Y4, ARM
  // assign NOTHING   = ~(enable_u6 &  A6 & ~A5 &  WRn); //Y5, NOT USED IN COLECO
  assign SND_ENABLEn  = ~(enable_u6 &  A[6] &  A[5] & ~WRn); //Y6
  assign ctrl_readn   = ~(enable_u6 &  A[6] &  A[5] &  WRn); //Y7

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
  assign RESETn = r_resetn;
  assign VDP_RESETn = r_vdp_resetn;

  always @(negedge clk)
  begin

    reset_counter <= reset_counter + 1;

    if(reset_counter[`DEF_VDP_RESET_BINARY_DELAY] == 1'b1)
    begin
      r_vdp_resetn <= 1'b1;
    end

    if(reset_counter[`DEF_RESET_BINARY_DELAY] == 1'b1)
    begin
      r_resetn <= 1'b1;
      reset_counter <= reset_counter;
    end

    if(RESETn_SW == 1'b0)
    begin
      r_resetn <= 1'b0;
      r_vdp_resetn <= 1'b0;
      reset_counter <= 0;
    end
  end

  //****************************************************************************
  /// Controller Player 1 and 2
  /// Player 1 and 2, Joystick pad only. Removed all other compatibilty for the
  /// portable console.
  //****************************************************************************

  //controller, original was a NAND circuit that would keep the last selection enabled till the other controller select is enabled.
  //1st player
  assign C1_4 = r_ctrl_arm;
  assign C1_7 = r_ctrl_fire;
  //2nd player (just cause I have enough IO, could just use C1_* above)
  assign C2_4 = r_ctrl_arm;
  assign C2_7 = r_ctrl_fire;

  //player 1
  //assign D[0] = (~ctrl_readn & ~A[1] ? C1_0 : 1'bz);
  //assign D[1] = (~ctrl_readn & ~A[1] ? C1_3 : 1'bz);
  //assign D[2] = (~ctrl_readn & ~A[1] ? C1_1 : 1'bz);
  //assign D[3] = (~ctrl_readn & ~A[1] ? C1_2 : 1'bz);
  //assign D[4] = (~ctrl_readn & ~A[1] ? 1'b1 : 1'bz); //feedback isn't used for standard controller
  //assign D[5] = (~ctrl_readn & ~A[1] ? C1_6 : 1'bz);
  //assign D[6] = (~ctrl_readn & ~A[1] ? C1_5 : 1'bz);
  //assign D[7] = (~ctrl_readn & ~A[1] ? 1'b0 : 1'bz); //feedback isn't used for standard controller

  //player 2
  //assign D[0] = (~ctrl_readn & A[1] ? C2_0 : 1'bz);
  //assign D[1] = (~ctrl_readn & A[1] ? C2_3 : 1'bz);
  //assign D[2] = (~ctrl_readn & A[1] ? C2_1 : 1'bz);
  //assign D[3] = (~ctrl_readn & A[1] ? C2_2 : 1'bz);
  //assign D[4] = (~ctrl_readn & A[1] ? 1'b1 : 1'bz); //feedback isn't used for standard controller
  //assign D[5] = (~ctrl_readn & A[1] ? C2_6 : 1'bz);
  //assign D[6] = (~ctrl_readn & A[1] ? C2_5 : 1'bz);
  //assign D[7] = (~ctrl_readn & A[1] ? 1'b0 : 1'bz); //feedback isn't used for standard controller
	
	assign D = {8{1'bz}};
  //emulation of feedback nand, hold last state by default.
  //00 is a invalid state.
  //always @(ctrl_en_1n or ctrl_en_2n)
  always @(negedge clk) //probably fast enough that it doesn't matter.
  begin
    case({ctrl_en_1n, ctrl_en_2n})
      2'b01:
      begin
        r_ctrl_arm  <= 1'b1;
        r_ctrl_fire <= 1'b0;
      end
      2'b10:
      begin
        r_ctrl_arm  <= 1'b0;
        r_ctrl_fire <= 1'b1;
      end
      default:
      begin
        r_ctrl_arm  <= r_ctrl_arm;
        r_ctrl_fire <= r_ctrl_fire;
      end
    endcase
  end

endmodule
