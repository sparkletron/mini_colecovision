// test bench

`define DEF_NTSC_MHZ 140

`timescale 1ns/1ps

module tb_porta_glue_console
  ();

  integer   index = 0;

  reg       clkv = 1'b0;
  reg       resetn_sw = 1'b0;
  reg       A1 = 1'b0;
  reg       A5 = 1'b0;
  reg       A6 = 1'b0;
  reg       A7 = 1'b0;
  reg       A13 = 1'b0;
  reg       A14 = 1'b0;
  reg       A15 = 1'b0;
  reg [5:0] C1 = 0;
  reg [5:0] C2 = 0;
  reg       MREQn = 1'b1;
  reg       IORQn = 1'b1;
  reg       RFSHn = 1'b0;
  reg       M1n   = 1'b1;
  reg       WRn   = 1'b1;
  reg       RDn   = 1'b0;

  wire [7:0]  data_bus;
  wire        ctrl1_fire;
  wire        ctrl1_arm;
  wire        ctrl2_fire;
  wire        ctrl2_arm;
  wire        rom_bank0;
  wire        rom_bank1;
  wire        rom_bank2;
  wire        rom_bank3;
  wire        snd_enable;
  wire        rom_enable;
  wire        ram_enable;
  wire        vdp_wn;
  wire        vdp_rn;
  wire        cpu_waitn;
  wire        cpu_resetn;
  wire        vdp_resetn;

  porta_glue_coleco dut
  (
    .clk(clkv),
    .A({A15,A14,A13,{5{1'b0}},A7,A6,A5,{3{1'b0}},A1,1'b0}),
    .RDn(RDn),
    .C1_0(C1[0]),
    .C1_1(C1[1]),
    .C1_2(C1[2]),
    .C1_3(C1[3]),
    .C1_5(C1[4]),
    .C1_6(C1[5]),
    .C1_8(1'b1),
    .C2_0(C2[0]),
    .C2_1(C2[1]),
    .C2_2(C2[2]),
    .C2_3(C2[3]),
    .C2_5(C2[4]),
    .C2_6(C2[5]),
    .C2_8(1'b1),
    .MREQn(MREQn),
    .IORQn(IORQn),
    .RFSHn(RFSHn),
    .M1n(M1n),
    .WRn(WRn),
    .RESETn_SW(resetn_sw),
    .C1_4(ctrl1_arm),
    .C1_7(ctrl1_fire),
    .C2_4(ctrl2_arm),
    .C2_7(ctrl2_fire),
    .D(data_bus),
    .CS_h8000n(rom_bank0),
    .CS_hA000n(rom_bank1),
    .CS_hC000n(rom_bank2),
    .CS_hE000n(rom_bank3),
    .SND_ENABLEn(snd_enable),
    .ROM_ENABLEn(rom_enable),
    .RAM_CSn(ram_enable),
    .CSWn(vdp_wn),
    .CSRn(vdp_rn),
    .WAITn(cpu_waitn),
    .RESETn(cpu_resetn),
    .VDP_RESETn(vdp_resetn),
    .RAM_OEn()
  );

    // fst dump command
  initial
  begin
    $dumpfile ("tb_porta_glue_console.fst");
    $dumpvars (0, tb_porta_glue_console);
    #1;
  end

  always
  begin
    // toggle indexed clock
    clkv <= ~clkv;
    #(`DEF_NTSC_MHZ);
  end


  initial
  begin
    //hold in reset, and then release
    #50000;
    resetn_sw <= 1'b1;
    #1000000000;
    //should be out of reset, reassert
    resetn_sw <= 1'b0;
    #1000000000;
    //take out of reset
    resetn_sw <= 1'b1;
    #1000000000;
    //check decoder U5
    //enable
    RFSHn <= 1'b1;
    MREQn <= 1'b0;
    #50000;
    //ROM
    A13 <= 1'b0;
    A14 <= 1'b0;
    A15 <= 1'b0;
    #50000;
    //RAM
    A13 <= 1'b1;
    A14 <= 1'b1;
    #50000;
    //rom_bank0
    A13 <= 1'b0;
    A14 <= 1'b0;
    A15 <= 1'b1;
    #50000;
    //rom_bank1
    A13 <= 1'b1;
    #50000;
    //rom_bank2
    A13 <= 1'b0;
    A14 <= 1'b1;
    #50000;
    //rom_bank3
    A13 <= 1'b1;
    #50000;
    //disable
    RFSHn <= 1'b0;
    MREQn <= 1'b1;
    #50000;
    //deassert address lines
    A13 <= 1'b0;
    A14 <= 1'b0;
    A15 <= 1'b0;
    #50000;
    //check decoder U6
    //enable
    IORQn <= 1'b0;
    A7    <= 1'b1;
    #50000;
    //control enable 2 (FIRE)
    WRn <= 1'b0;
    A5  <= 1'b0;
    A6  <= 1'b0;
    #50000;
    //vdp write enable (CSWn)
    A5  <= 1'b1;
    #50000;
    //vdp read enable (CSRn)
    WRn <= 1'b1;
    #50000;
    //control enable 1 (ARM)
    WRn <= 1'b0;
    A5  <= 1'b0;
    A6  <= 1'b1;
    #50000;
    //sound enable
    A5  <= 1'b1;
    #50000;
    //control read enable
    WRn <= 1'b1;
    #50000;
    WRn <= 1'b0;
    #50000;
    //controller tests with enabled decoder U6
    //player 1
    WRn <= 1'b1;
    for(index = 0; index < 256; index = index + 1)
    begin
      C1  <= index%64;
      #5000;
    end
    //player 2
    A1 <= 1'b1;
    for(index = 0; index < 256; index = index + 1)
    begin
      C2  <= index%64;
      #5000;
    end
    A1    <= 1'b0;
    WRn   <= 1'b0;
    IORQn <= 1'b1;
    A7    <= 1'b0;
    #5000;
    //assert M1n to test cpu_wait
    M1n <= 1'b0;
    #5000;
    M1n <= 1'b1;
    #500000;
    $finish;
  end

endmodule
