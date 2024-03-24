#*******************************************************************************
##  file: porta_glue_coleco.sdc
##  author: Jay Convertino (electrobs@gmail.com)
##  date: 01/01/2024
##  brief: Constraints based upon external devices and emulated devices.
##          - 6116LA20 RAM
##          - Z80 cmos 10MHz CPU
##          - 74LS138
##          - 27C256 ROM 150 NS
##          - 76489
##          - TMS9918
## Partially auto-generated
#*******************************************************************************

# Clock constraints
# 3.579545 MHz
create_clock -name "ntsc_clock" -period 279.365ns [get_ports {clk}]

# Automatically constrain PLL and other generated clocks
derive_pll_clocks -create_base_clocks

# input delays
set_input_delay -clock "ntsc_clock" 100.000ns [get_ports {C1P1}]
set_input_delay -clock "ntsc_clock" 100.000ns [get_ports {C1P2}]
set_input_delay -clock "ntsc_clock" 100.000ns [get_ports {C1P3}]
set_input_delay -clock "ntsc_clock" 100.000ns [get_ports {C1P4}]
set_input_delay -clock "ntsc_clock" 100.000ns [get_ports {C1P6}]
set_input_delay -clock "ntsc_clock" 100.000ns [get_ports {C1P7}]
set_input_delay -clock "ntsc_clock" 100.000ns [get_ports {C1P9}]

set_input_delay -clock "ntsc_clock" 100.000ns [get_ports {C2P1}]
set_input_delay -clock "ntsc_clock" 100.000ns [get_ports {C2P2}]
set_input_delay -clock "ntsc_clock" 100.000ns [get_ports {C2P3}]
set_input_delay -clock "ntsc_clock" 100.000ns [get_ports {C2P4}]
set_input_delay -clock "ntsc_clock" 100.000ns [get_ports {C2P6}]
set_input_delay -clock "ntsc_clock" 100.000ns [get_ports {C2P7}]
set_input_delay -clock "ntsc_clock" 100.000ns [get_ports {C2P9}]

set_input_delay -clock "ntsc_clock" 65.000ns [get_ports {A*}]

set_input_delay -clock "ntsc_clock" 65.000ns [get_ports {MREQn}]
 
set_input_delay -clock "ntsc_clock" 55.000ns [get_ports {IORQn}]

set_input_delay -clock "ntsc_clock" 65.000ns [get_ports {M1n}]
 
set_input_delay -clock "ntsc_clock" 55.000ns [get_ports {WRn}]

set_input_delay -clock "ntsc_clock" 55.000ns [get_ports {RDn}]

set_input_delay -clock "ntsc_clock" 40.000ns [get_ports {RESETn_SW}]

set_input_delay -clock "ntsc_clock" 80.000ns [get_ports {RFSHn}]

set_input_delay -clock "ntsc_clock" 55.000ns [get_ports {BUSAKn}]

# output delays
set_output_delay -clock "ntsc_clock" -min 10.000ns  [get_ports {D[*]}]
set_output_delay -clock "ntsc_clock" -max 100.000ns [get_ports {D[*]}]

set_output_delay -clock "ntsc_clock" 100.000ns [get_ports {CP5_ARM}]
set_output_delay -clock "ntsc_clock" 100.000ns [get_ports {CP8_FIRE}]

set_output_delay -clock "ntsc_clock" -min 30.000ns [get_ports {CSWn}]
set_output_delay -clock "ntsc_clock" -max 100.000ns [get_ports {CSWn}]

set_output_delay -clock "ntsc_clock" -min 30.000ns [get_ports {CSRn}]
set_output_delay -clock "ntsc_clock" -max 100.000ns [get_ports {CSRn}]

set_output_delay -clock "ntsc_clock" 100.000ns [get_ports {RAM_CSn}]

set_output_delay -clock "ntsc_clock" 100.000ns [get_ports {RAM_OEn}]

set_output_delay -clock "ntsc_clock" -min 10.000ns [get_ports {RESETn}]
set_output_delay -clock "ntsc_clock" -max 40.000ns [get_ports {RESETn}]

set_output_delay -clock "ntsc_clock" -min 10.000ns [get_ports {VDP_RESETn}]
set_output_delay -clock "ntsc_clock" -max 40.000ns [get_ports {VDP_RESETn}]

set_output_delay -clock "ntsc_clock" 150.000ns [get_ports {ROM_ENABLEn}]

set_output_delay -clock "ntsc_clock" 150.000ns [get_ports {CS_*}]

set_output_delay -clock "ntsc_clock" 150.000ns [get_ports {SND_ENABLEn}]

set_output_delay -clock "ntsc_clock" 100.000ns [get_ports {WAITn}]

set_output_delay -clock "ntsc_clock" 100.000ns [get_ports {INTn}]

set_output_delay -clock "ntsc_clock" 100.000ns [get_ports {BUSREQn}]
