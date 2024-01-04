#************************************************************
# THIS IS A WIZARD-GENERATED FILE.                           
#
# Version 13.0.1 Build 232 06/12/2013 Service Pack 1 SJ Web Edition
#
#************************************************************

# Copyright (C) 1991-2013 Altera Corporation
# Your use of Altera Corporation's design tools, logic functions 
# and other software and tools, and its AMPP partner logic 
# functions, and any output files from any of the foregoing 
# (including device programming or simulation files), and any 
# associated documentation or information are expressly subject 
# to the terms and conditions of the Altera Program License 
# Subscription Agreement, Altera MegaCore Function License 
# Agreement, or other applicable license agreement, including, 
# without limitation, that your use is for the sole purpose of 
# programming logic devices manufactured by Altera and sold by 
# Altera or its authorized distributors.  Please refer to the 
# applicable agreement for further details.



# Clock constraints
# 3.579545 MHz
create_clock -name "ntsc_clock" -period 279.365ns [get_ports {clk}]


# Automatically constrain PLL and other generated clocks
derive_pll_clocks -create_base_clocks

# Automatically calculate clock uncertainty to jitter and other effects.
#derive_clock_uncertainty
# Not supported for family MAX7000S

# tsu/th constraints


set_input_delay -clock "ntsc_clock" 100.000ns [get_ports {C1_*}]

set_input_delay -clock "ntsc_clock" 100.000ns [get_ports {C2_*}]

set_input_delay -clock "ntsc_clock" 65.000ns [get_ports {A*}]

set_input_delay -clock "ntsc_clock" 65.000ns [get_ports {MREQn}]
 
set_input_delay -clock "ntsc_clock" 55.000ns [get_ports {IORQn}]

set_input_delay -clock "ntsc_clock" 65.000ns [get_ports {M1n}]
 
set_input_delay -clock "ntsc_clock" 55.000ns [get_ports {WRn}]

set_input_delay -clock "ntsc_clock" 40.000ns [get_ports {RESETn_SW}]

set_input_delay -clock "ntsc_clock" 80.000ns [get_ports {RFSH}]

# tco constraints

set_output_delay -clock "ntsc_clock" -min 0.000ns [get_ports {D[*]}]
set_output_delay -clock "ntsc_clock" -max 25.000ns [get_ports {D[*]}]

set_output_delay -clock "ntsc_clock" 100.000ns [get_ports {C1_*}]

set_output_delay -clock "ntsc_clock" 100.000ns [get_ports {C2_*}]

set_output_delay -clock "ntsc_clock" 40.000ns [get_ports {CS*}]

set_output_delay -clock "ntsc_clock" 10.000ns [get_ports {RAM_CSn}]

set_output_delay -clock "ntsc_clock" -min 10.000ns [get_ports {RESETn}]
set_output_delay -clock "ntsc_clock" -max 40.000ns [get_ports {RESETn}]

set_output_delay -clock "ntsc_clock" 150.000ns [get_ports {ROM_ENABLEn}]

set_output_delay -clock "ntsc_clock" 150.000ns [get_ports {SND_ENABLEn}]

set_output_delay -clock "ntsc_clock" -min 10.000ns [get_ports {WAITn}]
set_output_delay -clock "ntsc_clock" -min 20.000ns [get_ports {WAITn}]


