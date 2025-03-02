//******************************************************************************
// file:    porta_glue_coleco.v
//
// author:  JAY CONVERTINO
//
// date:    2024/11/06
//
// about:   Brief
// Colecovision SGM glue logic chip
//
// license: License MIT
// Copyright 2024 Jay Convertino
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.
//
//******************************************************************************

// Constant: DEF_RESET_DELAY
// Number ticks for reset delay register
`define DEF_RESET_DELAY 255
// Constant: DEF_FB_MONOSTABLE_COUNT
// delay till state is at 1 instead of 0 (its stable state) for feedback stable circuit
`define DEF_FB_MONOSTABLE_COUNT   4000
// Constant: DEF_IRQ_MONOSTABLE_COUNT
// delay till state is at 1 instead of 0 (its stable state) for the controller (spinner) generated interrupt.
`define DEF_IRQ_MONOSTABLE_COUNT  63

/*
 * Module: porta_glue_coleco
 *
 * Colecovision Super Game Module Glue Logic
 *
 * Ports:
 *
 *   clk            - Clock for all devices in the core
 *   A              - Address input bus from Z80
 *   C1P1           - DB9 Controller 1 Pin 1
 *   C1P2           - DB9 Controller 1 Pin 2
 *   C1P3           - DB9 Controller 1 Pin 3
 *   C1P4           - DB9 Controller 1 Pin 4
 *   C1P6           - DB9 Controller 1 Pin 6
 *   C1P7           - DB9 Controller 1 Pin 7
 *   C1P9           - DB9 Controller 1 Pin 9
 *   C2P1           - DB9 Controller 2 Pin 1
 *   C2P2           - DB9 Controller 2 Pin 2
 *   C2P3           - DB9 Controller 2 Pin 3
 *   C2P4           - DB9 Controller 2 Pin 4
 *   C2P6           - DB9 Controller 2 Pin 6
 *   C2P7           - DB9 Controller 2 Pin 7
 *   C2P9           - DB9 Controller 2 Pin 9
 *   MREQn          - Z80 memory request input, active low
 *   IORQn          - Z80 IO request input, active low
 *   RFSHn          - Z80 Refresh input, active low
 *   M1n            - Z80 M1 state, active low
 *   WRn            - Z80 Write to bus, active low
 *   RESETn_SW      - Input for reset switch
 *   RDn            - Z80 Read from bus, active low
 *   D              - Z80 8 bit data bus, tristate IN/OUT
 *   CP5_ARM        - DB9 Controller 1&2 ARM Select
 *   CP8_FIRE       - DB9 Controller 1&2 FIRE Select
 *   CS_h8000n      - Select when Z80 requests memory at h8000 (GAME CART), active low
 *   CS_hA000n      - Select when Z80 requests memory at hA000 (GAME CART), active low
 *   CS_hC000n      - Select when Z80 requests memory at hC000 (GAME CART), active low
 *   CS_hE000n      - Select when Z80 requests memory at hE000 (GAME CART), active low
 *   SND_ENABLEn    - SN76489 Sound chip enable, active low
 *   ROM_ENABLEn    - Enable BIOS ROM, active low
 *   RAM_CSn        - RAM chip select, active low
 *   RAM_OEn        - RAM Ouput enable, active low
 *   CSWn           - Chip Select Write for VDP, active low
 *   CSRn           - Chip Select Read for VDP, active low
 *   WAITn          - Wait state generator for Z80, active low
 *   RESETn         - Timed reset generated by Logic, active low
 *   RAM_MIRRORn    - Extended RAM, high is extended RAM, active low is mirrored.
 *   INTn           - Interrupt generator for Z80, active low
 *   AS             - AY sound chip address(0)/data(1) select
 *   AY_SND_ENABLEn - AY sound enable, active low
 */
module porta_glue_coleco
  (
    input         clk,
    input [15:0]  A,
    input         C1P1,
    input         C1P2,
    input         C1P3,
    input         C1P4,
    input         C1P6,
    input         C1P7,
    input         C1P9,
    input         C2P1,
    input         C2P2,
    input         C2P3,
    input         C2P4,
    input         C2P6,
    input         C2P7,
    input         C2P9,
    input         MREQn,
    input         IORQn,
    input         RFSHn,
    input         M1n,
    input         WRn,
    input         RESETn_SW,
    input         RDn,
    inout [7:0]   D,
    output        CP5_ARM,
    output        CP8_FIRE,
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
    output        RAM_MIRRORn,
    output        INTn,
    output        AS,
    output        AY_SND_ENABLEn
  );

  //****************************************************************************
  // Group: Register Information
  // Core has 3 registers at the addresses that follow.
  //
  //  <SOUND_ADDR_CACHE>  - h50
  //  <SOUND_CACHE>       - h51
  //  <RAM_24K_ENABLE>    - h53
  //  <SWAP_BIOS_TO_RAM>  - h7F
  //****************************************************************************

  // Register Address: SOUND_ADDR_CACHE
  // Defines the address of r_snd_addr_cache
  // (see diagrams/reg_sound_addr_cache.png)
  // Setup an address for cache the sound address so each write will be to a proper address (opcode games need to write multiple and read multiple addresses)
  // The resister is only 2 bits, and is set to data line bits 2:1 to create a shift to divide all address by 2. Reducing the number of registers in r_snd_cache to 4.
  localparam SOUND_ADDR_CACHE = 8'h50;
  // Register Address: SOUND_CACHE
  // Defines the address of r_snd_cache
  // (see diagrams/reg_sound_cache.png)
  // Cache Sound Chip as the SGM games read from it (Yamaha chip does not have a read like a GI does).
  localparam SOUND_CACHE = 8'h51;
  // Register Address: RAM_24K_ENABLE
  // Defines the address of r_24k_ena
  // (see diagrams/reg_24k_ram_enable.png)
  // Super Game Module 24K RAM enable using bit 0 (Active High)
  localparam RAM_24K_ENABLE = 8'h53;
  // Register Address: SWAP_BIOS_TO_RAM
  // Defines the address of r_swap_ena
  // (see diagrams/reg_swap_bios_enable.png)
  // Super Game Module BIOS to RAM swap on bit 1 (Active Low)
  localparam SWAP_BIOS_TO_RAM = 8'h7F;

  //internal wires
  wire s_enable_u5;
  wire s_enable_u6;
  wire s_ctrl_en_1n;
  wire s_ctrl_en_2n;
  wire s_ctrl_readn;
  wire s_ram_csn;
  wire s_ram0_csn;
  wire s_ram1_csn;
  wire s_ram2_csn;
  wire s_y0_seln;

  //int logic
  wire s_int_p1;
  wire s_int_p2;

  // var: r_snd_addr_cache
  // register for SOUND_ADDR_CACHE
  // See Also: <SOUND_ADDR_CACHE>
  reg [ 1:0]  r_snd_addr_cache         = 0;
  // var: r_24k_ena
  // register for RAM_24K_ENABLE
  // See Also: <RAM_24K_ENABLE>
  reg [ 7:0]  r_24k_ena         = 0;
  // var: r_swap_ena
  // register for 8K RAM/ROM swap
  // See Also: <SWAP_BIOS_TO_RAM>
  reg [ 7:0]  r_swap_ena        = 8'h0F;
  // var: r_snd_cache
  // register for SOUND_CACHE
  // See Also: <SOUND_CACHE>
  reg [ 7:0]  r_snd_cache[3:0];

  // var: r_int_p1
  // Interrupt from player one control
  reg         r_int_p1          = 1'b0;
  // var: r_int_p2
  // Interrupt from player two control
  reg         r_int_p2          = 1'b0;
  // var: r_wait
  // Wait state generated register
  reg         r_wait            = 1'b0;

  // var: r_reset_counter
  // Timed reset counter
  reg [ 7:0]  r_reset_counter   = 0;
  // var: r_resetn
  // Registered reset output, active low
  reg         r_resetn          = 0;

  // var: r_mono_count_p1
  // monostable circuit counters, player 1 AND
  reg [11:0]  r_mono_count_p1     = 0;
  // var: r_mono_count_p2
  // monostable circuit counters, player 2 AND
  reg [11:0]  r_mono_count_p2     = 0;
  // var: r_mono_count_int_p1
  // monostable circuit counters, player 1 interrupt
  reg [ 5:0]  r_mono_count_int_p1 = 0;
  // var: r_mono_count_int_p2
  // monostable circuit counters, player 2 interrupt
  reg [ 5:0]  r_mono_count_int_p2 = 0;

  // var: r_mono_p1
  // Feedback from IRQ to controller 1 register
  reg         r_mono_p1       = 1'b0;
  // var: r_mono_p2
  // Feedback from IRQ to controller 2 register
  reg         r_mono_p2       = 1'b0;

  // var: r_ctrl_fire
  // NAND Feedback Flip Flop FIRE select.
  reg         r_ctrl_fire     = 1'b1;
  // var: r_ctrl_arm
  // NAND Feedback Flip Flop ARM select.
  reg         r_ctrl_arm      = 1'b0;

  //****************************************************************************
  // Group: Assignment Information
  // How signals are created
  //****************************************************************************

  /* assign: s_ram_csn
   * RAM Chip select when address is requested (active low).
   *
   * (s_y0_seln | r_swap_ena[1])   - address range starting at h0000, swap bios/rom bit is enabled (1 is disabled).
   * (s_ram1_csn  | ~r_24k_ena[0]) - address range starting at h4000, 24k enable bit from register.
   * (s_ram2_csn  | ~r_24k_ena[0]) - address range starting at h2000, 24k enable bit from register.
   * s_ram0_csn                    - address range starting h6000, this is always an available range.
   */
  assign s_ram_csn = (s_y0_seln | r_swap_ena[1]) & (s_ram2_csn  | ~r_24k_ena[0]) & (s_ram1_csn | ~r_24k_ena[0]) & s_ram0_csn;

  /* assign: RAM_OEn
   * RAM Output enable when read is requested (active low).
   *
   * RDn        - Z80 read request, active low.
   * s_ram_csn  - See Also: <s_ram_csn>
   */
  assign RAM_OEn = RDn | s_ram_csn;

  /* assign: RAM_CSn
   * RAM Chip Select output assignment.
   *
   * s_ram_csn  - See Also: <s_ram_csn>
   */
  assign RAM_CSn = s_ram_csn;

  /* assign: RAM_MIRRORn
   * RAM Mirror enable. Output to AND gates that block address lines (active low)
   *
   * r_24k_ena[0]  - If 24k ram extension is disabled, enable ram mirror
   * r_swap_ena[1] - If ram/bios swap is disabled, enable ram mirror.
   */
  assign RAM_MIRRORn = (r_24k_ena[0] | ~r_swap_ena[1]);

  /* assign: ROM_ENABLEn
   * ROM enable (active low).
   *
   * s_y0_seln     - Only select ROM when address range h0000 is enabled.
   * r_swap_ena[1] - If ram/bios swap is disabled, enable ROM.
   */
  assign ROM_ENABLEn = (s_y0_seln | ~r_swap_ena[1]);

  //****************************************************************************
  /// decoders for address selection.
  /// No clock, based on AND from TI 74138 datasheet.
  //****************************************************************************

  //****************************************************************************
  // Group: Decoder Information for U5
  // How address decoder is created.
  //****************************************************************************

  /* assign: s_enable_u5
   * Enable the the decoder, duplicates U5 functionality from colecovision.
   * always 1, RFSH is a double inversion on coleco (inverter + 138 internal)
   *
   * RFSHn - Z80 Refresh line, when not in refresh enable is active.
   * MREQn - When the MREQn is active then encoder is enabled.
   */
  assign s_enable_u5 = (RFSHn & ~MREQn);

  /* assign: s_y0_seln
   * Address h0000, ROM/RAM
   *
   * s_enable_u5  - Enable decoder
   * A[15:13]     - Address lines used for select lines.
   */
  assign s_y0_seln      = ~(s_enable_u5 & ~A[15] & ~A[14] & ~A[13]); //Y0

  /* assign: s_ram2_csn
   * Address h2000, RAM
   *
   * s_enable_u5  - Enable decoder
   * A[15:13]     - Address lines used for select lines.
   */
  assign s_ram2_csn     = ~(s_enable_u5 & ~A[15] & ~A[14] &  A[13]); //Y1

  /* assign: s_ram1_csn
   * Address h4000, RAM
   *
   * s_enable_u5  - Enable decoder
   * A[15:13]     - Address lines used for select lines.
   */
  assign s_ram1_csn     = ~(s_enable_u5 & ~A[15] &  A[14] & ~A[13]); //Y2

  /* assign: s_ram0_csn
   * Address h6000, RAM
   *
   * s_enable_u5  - Enable decoder
   * A[15:13]     - Address lines used for select lines.
   */
  assign s_ram0_csn     = ~(s_enable_u5 & ~A[15] &  A[14] &  A[13]); //Y3

  /* assign: CS_h8000n
   * Address h8000, Game ROM bank select.
   *
   * s_enable_u5  - Enable decoder
   * A[15:13]     - Address lines used for select lines.
   */
  assign CS_h8000n      = ~(s_enable_u5 &  A[15] & ~A[14] & ~A[13]); //Y4

  /* assign: CS_hA000n
   * Address hA000, Game ROM bank select.
   *
   * s_enable_u5  - Enable decoder
   * A[15:13]     - Address lines used for select lines.
   */
  assign CS_hA000n      = ~(s_enable_u5 &  A[15] & ~A[14] &  A[13]); //Y5

  /* assign: CS_hC000n
   * Address hC000, Game ROM bank select.
   *
   * s_enable_u5  - Enable decoder
   * A[15:13]     - Address lines used for select lines.
   */
  assign CS_hC000n      = ~(s_enable_u5 &  A[15] &  A[14] & ~A[13]); //Y6

  /* assign: CS_hE000n
   * Address hE000, Game ROM bank select.
   *
   * s_enable_u5  - Enable decoder
   * A[15:13]     - Address lines used for select lines.
   */
  assign CS_hE000n      = ~(s_enable_u5 &  A[15] &  A[14] &  A[13]); //Y7

  //****************************************************************************
  // Group: Decoder Information for U6
  // How address decoder is created
  //****************************************************************************

  /* assign: s_enable_u5
   * Enable the the decoder, duplicates U6 functionality from colecovision.
   *
   * A[7] - Address IO range h80 to hFF
   * IORQn - When the IORQn is active then encoder is enabled.
   */
  assign s_enable_u6 = (A[7] & ~IORQn);

  /* assign: s_ctrl_en_2n
   * h80 PORT IO for controller Fire Select
   *
   * s_enable_u6  - Enable decoder
   * A[6:5]       - Address lines used for select lines.
   * WRn          - Select write or read.
   */
  assign s_ctrl_en_2n   = ~(s_enable_u6 & ~A[6] & ~A[5] & ~WRn); //Y0, FIRE

  // assign NOTHING     = ~(s_enable_u6 & ~A6 & ~A5 &  WRn); //Y1, NOT USED IN COLECO

  /* assign: CSWn
   * hBE PORT IO for VDP write
   *
   * s_enable_u6  - Enable decoder
   * A[6:5]       - Address lines used for select lines.
   * WRn          - Select write or read.
   */
  assign CSWn           = ~(s_enable_u6 & ~A[6] &  A[5] & ~WRn); //Y2

  /* assign: CSRn
   * hBF PORT IO for VDP read
   *
   * s_enable_u6  - Enable decoder
   * A[6:5]       - Address lines used for select lines.
   * WRn          - Select write or read.
   */
  assign CSRn           = ~(s_enable_u6 & ~A[6] &  A[5] &  WRn); //Y3

  /* assign: s_ctrl_en_1n
   * hC0 PORT IO for controller ARM select
   *
   * s_enable_u6  - Enable decoder
   * A[6:5]       - Address lines used for select lines.
   * WRn          - Select write or read.
   */
  assign s_ctrl_en_1n   = ~(s_enable_u6 &  A[6] & ~A[5] & ~WRn); //Y4, ARM

  // assign NOTHING     = ~(s_enable_u6 &  A6 & ~A5 &  WRn); //Y5, NOT USED IN COLECO

  /* assign: SND_ENABLEn
   * hFF PORT IO for sound enable.
   *
   * s_enable_u6  - Enable decoder
   * A[6:5]       - Address lines used for select lines.
   * WRn          - Select write or read.
   */
  assign SND_ENABLEn    = ~(s_enable_u6 &  A[6] &  A[5] & ~WRn); //Y6

  /* assign: s_ctrl_readn
   * hFC/FF PORT IO for controller read
   *
   * s_enable_u6  - Enable decoder
   * A[6:5]       - Address lines used for select lines.
   * WRn          - Select write or read.
   */
  assign s_ctrl_readn   = ~(s_enable_u6 &  A[6] &  A[5] &  WRn); //Y7

  //****************************************************************************
  // Group: Decoder Information for Super Game Module
  // How address decoder is created for Super Game Module
  //
  // SGM IO REG - Clocked IO decoder for Super Game Module.
  //****************************************************************************

  /* assign: AS
   * h50 is the address select, when selected its in data mode
   *
   * A[7:0] - If address matches h50, enable
   * IORQn  - Active IO request, enable
   * WRn    - Z80 write is active, enable
   */
  assign AS             = (A[7:0] == 8'h50 & ~IORQn & ~WRn      ? 1'b0 : 1'b1);

  /* assign: AY_SND_ENABLEn
   * match both h50 and h51 by ignoring bit 0. Enable AY sound chip.
   *
   * A[7:0] - If address matches h50 or h51, enable
   * IORQn  - Active IO request, enable
   * WRn    - Z80 write is active, enable
   */
  assign AY_SND_ENABLEn = (A[7:1] == 7'b0101000 & ~IORQn & ~WRn ? 1'b0 : 1'b1);

  /* assign: AY_SND_ENABLEn
   * read cached register from previous write (AY emulation), at set address location (0=0,1=0,2=1,3=1,4=2,5=2,6=3,7=3).
   *
   * A[7:0] - If address matches h52, enable
   * IORQn  - Active IO request, enable
   * RDn    - Z80 read is active, enable
   */
  assign D              = (A[7:0] == 8'h52 & ~IORQn & ~RDn      ? r_snd_cache[{6'b0, r_snd_addr_cache}]  : 8'bzzzzzzzz);

  //IO registers
  //This logic is registered

  //****************************************************************************
  /// SGM IO REG
  /// Decoder logic for writes to the SGM address range.
  //****************************************************************************
  always @(negedge clk)
  begin
    if(~r_resetn)
    begin
      r_swap_ena  <= 8'h0F;
      r_24k_ena   <= 0;
      r_snd_cache[0] <= 0;
      r_snd_cache[1] <= 0;
      r_snd_cache[2] <= 0;
      r_snd_cache[3] <= 0;
    end else begin

      if(~IORQn & ~WRn)
      begin
        case (A[7:0])
          // on write to sound chip address reg, cache address. Get bits 2:1 into 1:0 create a right shift by 1 (divide by 2).
          SOUND_ADDR_CACHE: r_snd_addr_cache <= D[2:1];
          // on write to sound chip data reg, cache data. Write to cached address location.
          SOUND_CACHE: r_snd_cache[{6'b0, r_snd_addr_cache}] <= D;
          //exapand ram to 24k by setting bit 0 to 1
          RAM_24K_ENABLE: r_24k_ena  <= D;
          //swap out bios for ram by setting bit 1 to 0
          SWAP_BIOS_TO_RAM: r_swap_ena <= D;
          default:
          begin
          end
        endcase
      end
    end
  end

  //****************************************************************************
  // Group: Controller Register Read
  // How to read controller inputs for player 1 and 2, works with roller and standard gamepads.
  //****************************************************************************

  // 1st player and 2nd player use the same lines
  /* assign: CP5_ARM
   * Activate ARM porition of controllers.
   *
   * r_ctrl_arm - See Also: <r_ctrl_arm>
   */
  assign CP5_ARM   = r_ctrl_arm;

  /* assign: CP8_FIRE
   * Activate FIRE porition of controllers.
   *
   * r_ctrl_fire - See Also: <r_ctrl_fire>
   */
  assign CP8_FIRE  = r_ctrl_fire;

  //data lines asserted when controller port read requested
  //player 1
  /* assign: D[0]
   * Data bit zero for P1
   *
   * s_ctrl_readn - See Also: <s_ctrl_readn>, read when active low
   * A[1]         - Address bit 1 is 0, read
   */
  assign D[0] = (~s_ctrl_readn & ~A[1] ? C1P1        : 1'bz);

  /* assign: D[1]
   * Data bit one for P1
   *
   * s_ctrl_readn - See Also: <s_ctrl_readn>, read when active low
   * A[1]         - Address bit 1 is 0, read
   */
  assign D[1] = (~s_ctrl_readn & ~A[1] ? C1P4        : 1'bz);

  /* assign: D[2]
   * Data bit two for P1
   *
   * s_ctrl_readn - See Also: <s_ctrl_readn>, read when active low
   * A[1]         - Address bit 1 is 0, read
   */
  assign D[2] = (~s_ctrl_readn & ~A[1] ? C1P2        : 1'bz);

  /* assign: D[3]
   * Data bit three for P1
   *
   * s_ctrl_readn - See Also: <s_ctrl_readn>, read when active low
   * A[1]         - Address bit 1 is 0, read
   */
  assign D[3] = (~s_ctrl_readn & ~A[1] ? C1P3        : 1'bz);

  /* assign: D[4]
   * Data bit one for P1
   *
   * s_ctrl_readn - See Also: <s_ctrl_readn>, read when active low
   * A[1]         - Address bit 1 is 0, read
   */
  assign D[4] = (~s_ctrl_readn & ~A[1] ? r_mono_p1   : 1'bz);

  /* assign: D[5]
   * Data bit five for P1
   *
   * s_ctrl_readn - See Also: <s_ctrl_readn>, read when active low
   * A[1]         - Address bit 1 is 0, read
   */
  assign D[5] = (~s_ctrl_readn & ~A[1] ? C1P7        : 1'bz);

  /* assign: D[6]
   * Data bit six for P1
   *
   * s_ctrl_readn - See Also: <s_ctrl_readn>, read when active low
   * A[1]         - Address bit 1 is 0, read
   */
  assign D[6] = (~s_ctrl_readn & ~A[1] ? C1P6        : 1'bz);

  /* assign: D[7]
   * Data bit seven for P1
   *
   * s_ctrl_readn - See Also: <s_ctrl_readn>, read when active low
   * A[1]         - Address bit 1 is 0, read
   */
  assign D[7] = (~s_ctrl_readn & ~A[1] ? s_int_p1    : 1'bz);

  //int used in data port and mono trigger to cpu.
  /* assign: s_int_p1
   * generate interrupt for player one
   *
   * r_mono_p1 - See Also: <r_mono_p1>, RC TL emulation
   * C1P9      - Input from controller port. Roller controller only.
   */
  assign s_int_p1 = ~(r_mono_p1 & C1P9);

  //player 2
  /* assign: D[0]
   * Data bit zero for P2
   *
   * s_ctrl_readn - See Also: <s_ctrl_readn>, read when active low
   * A[1]         - Address bit 1 is 1, read
   */
  assign D[0] = (~s_ctrl_readn & A[1] ? C2P1       : 1'bz);

  /* assign: D[1]
   * Data bit one for P2
   *
   * s_ctrl_readn - See Also: <s_ctrl_readn>, read when active low
   * A[1]         - Address bit 1 is 1, read
   */
  assign D[1] = (~s_ctrl_readn & A[1] ? C2P4       : 1'bz);

  /* assign: D[2]
   * Data bit two for P2
   *
   * s_ctrl_readn - See Also: <s_ctrl_readn>, read when active low
   * A[1]         - Address bit 1 is 1, read
   */
  assign D[2] = (~s_ctrl_readn & A[1] ? C2P2       : 1'bz);

  /* assign: D[3]
   * Data bit three for P2
   *
   * s_ctrl_readn - See Also: <s_ctrl_readn>, read when active low
   * A[1]         - Address bit 1 is 1, read
   */
  assign D[3] = (~s_ctrl_readn & A[1] ? C2P3       : 1'bz);

  /* assign: D[4]
   * Data bit four for P2
   *
   * s_ctrl_readn - See Also: <s_ctrl_readn>, read when active low
   * A[1]         - Address bit 1 is 1, read
   */
  assign D[4] = (~s_ctrl_readn & A[1] ? r_mono_p2  : 1'bz);

  /* assign: D[5]
   * Data bit five for P2
   *
   * s_ctrl_readn - See Also: <s_ctrl_readn>, read when active low
   * A[1]         - Address bit 1 is 1, read
   */
  assign D[5] = (~s_ctrl_readn & A[1] ? C2P7       : 1'bz);

  /* assign: D[6]
   * Data bit six for P2
   *
   * s_ctrl_readn - See Also: <s_ctrl_readn>, read when active low
   * A[1]         - Address bit 1 is 1, read
   */
  assign D[6] = (~s_ctrl_readn & A[1] ? C2P6       : 1'bz);

  /* assign: D[7]
   * Data bit seven for P2
   *
   * s_ctrl_readn - See Also: <s_ctrl_readn>, read when active low
   * A[1]         - Address bit 1 is 1, read
   */
  assign D[7] = (~s_ctrl_readn & A[1] ? s_int_p2   : 1'bz);

  //int used in data port and mono trigger to cpu.
  /* assign: s_int_p2
   * generate interrupt for player one
   *
   * r_mono_p1 - See Also: <r_mono_p1>, RC TL emulation
   * C2P9      - Input from controller port. Roller controller only.
   */
  assign s_int_p2 = ~(r_mono_p2 & C2P9);

  /* assign: INTn
   * INTn is generated by monostable circuit based on NAND outputs.
   *
   * r_int_p1 - See Also: <r_int_p1>, RC TL emulation
   * r_int_p2 - See Also: <r_int_p2>, RC TL emulation
   */
  assign INTn = ~(r_int_p1 | r_int_p2);

  //****************************************************************************
  // Group: Circuit Emulation
  // Everything below emulates a part of the circuit that uses some sort of
  // linear/non-linear components to perform its task. Things such as RC reset
  // circuits, RC interrupts, IRQ and others. See this source file for details.
  //
  // WAIT GENERATE   - Generate wait states for the Z80 procressor
  // RESET GENERATE  - Generate a timed reset for the CPU/VDP/ETC.
  // TL RC RESET     - Generate a interrupt for a monostable circuit that will trigger a 1 for a short duration.
  // CONTROLLER NAND - Controller NAND Latch FIRE/ARM emulation.
  // NAND IRQ PULSE  - Controller bit 4 is a pulse that represents the spinner state.
  //****************************************************************************

  //****************************************************************************
  /// WAIT GENERATE
  /// D flip flop used to generate wait. Original uses a inverted clock in
  /// reference to the original. using a negedge will emulate the same without
  /// generating a new inverted clock.
  //****************************************************************************
  assign WAITn = (r_wait ? ~r_wait : 1'bz);

  always @(negedge clk)
  begin
    r_wait <= ~r_wait;

    //when not in machine cycle 1, hold r_wait at 0.
    if(M1n)
    begin
      r_wait <= 1'b0;
    end
  end

  //****************************************************************************
  /// RESET GENERATE
  /// Reset circuit based on number of cycle count, replace cap/resistor.
  //****************************************************************************
  assign RESETn     = r_resetn;

  always @(negedge clk)
  begin

    r_reset_counter <= r_reset_counter + 1;

    if(r_reset_counter >= `DEF_RESET_DELAY)
    begin
      r_resetn        <= 1'b1;
      r_reset_counter <= `DEF_RESET_DELAY;
    end

    //when 0, reset is asserted
    if(~RESETn_SW)
    begin
      r_resetn        <= 1'b0;
      r_reset_counter <= 0;
    end
  end

  //****************************************************************************
  /// TL RC RESET
  /// int is only held low for a small amount of time. int for p1 and p2 are
  /// seperate monostable circuits.
  //****************************************************************************
  //player 1 int
  always @(negedge clk)
  begin
    r_mono_count_int_p1 <= 0;
    r_int_p1 <= 1'b0;

    if(s_int_p1)
    begin
      r_mono_count_int_p1 <= r_mono_count_int_p1 + 1;
      r_int_p1 <= 1'b1;

      if(r_mono_count_int_p1 >= `DEF_IRQ_MONOSTABLE_COUNT)
      begin
        r_mono_count_int_p1 <= `DEF_IRQ_MONOSTABLE_COUNT;
        r_int_p1 <= 1'b0;
      end
    end
  end

  //player 2 int
  always @(negedge clk)
  begin
    r_mono_count_int_p2 <= 0;
    r_int_p2 <= 1'b0;

    if(s_int_p2)
    begin
      r_mono_count_int_p2 <= r_mono_count_int_p2 + 1;
      r_int_p2 <= 1'b1;

      if(r_mono_count_int_p2 >= `DEF_IRQ_MONOSTABLE_COUNT)
      begin
        r_mono_count_int_p2 <= `DEF_IRQ_MONOSTABLE_COUNT;
        r_int_p2 <= 1'b0;
      end
    end
  end

  //****************************************************************************
  /// CONTROLLER NAND
  /// Original was a NAND circuit that would keep the last selection
  /// enabled till the other controller select is enabled.
  /// emulation of feedback nand, hold last state by default.
  /// 00 is a invalid state.
  //****************************************************************************
  always @(negedge clk)
  begin
    r_ctrl_arm  <= r_ctrl_arm;
    r_ctrl_fire <= r_ctrl_fire;

    if(s_ctrl_en_1n ^ s_ctrl_en_2n)
    begin
      r_ctrl_arm  <= ~s_ctrl_en_1n;
      r_ctrl_fire <= ~s_ctrl_en_2n;
    end
  end

  //****************************************************************************
  /// NAND IRQ PULSE
  /// emulation of monostable transistor ciruit for controller port NAND feedback.
  //****************************************************************************
  //player 1
  always @(negedge clk)
  begin
    r_mono_count_p1 <= 0;
    r_mono_p1 <= ~s_int_p1;

    if(s_int_p1)
    begin
      r_mono_count_p1 <= r_mono_count_p1 + 1;
      if(r_mono_count_p1 >= `DEF_FB_MONOSTABLE_COUNT)
      begin
        r_mono_count_p1 <= `DEF_FB_MONOSTABLE_COUNT;
        r_mono_p1 <= 1'b1;
      end
    end
  end

  //player 2
  always @(negedge clk)
  begin
    r_mono_count_p2 <= 0;
    r_mono_p2 <= ~s_int_p2;

    if(s_int_p2)
    begin
      r_mono_count_p2 <= r_mono_count_p2 + 1;
      if(r_mono_count_p2 >= `DEF_FB_MONOSTABLE_COUNT)
      begin
        r_mono_count_p2 <= `DEF_FB_MONOSTABLE_COUNT;
        r_mono_p2 <= 1'b1;
      end
    end
  end

endmodule
