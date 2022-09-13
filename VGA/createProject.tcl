proc init {} {
    create_project -part xc7a100tftg256-1 VGA
    config_webtalk -user off
    set_property target_language VHDL [current_project]
    set_property simulator_language Mixed [current_project]
}

proc setupFiles {} {
    add_files "src/sources_1/"
    add_files -fileset constrs_1 "src/constrs_1/"
    add_files -fileset sim_1 "src/sim_1/"
    set_property FILE_TYPE {VHDL 2008} [get_files {vga.vhd}]
}

proc genMMCM {} {
    set clk_wiz_0 [create_ip -name clk_wiz -vendor xilinx.com -library ip -version 6.0 -module_name clk_wiz_0]
    set_property -dict {
	CONFIG.PRIM_IN_FREQ {50}
	CONFIG.CLKIN1_JITTER_PS {200.0}
	CONFIG.PRIMARY_PORT {sys_clk}
	CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {25.2}
	CONFIG.CLK_OUT1_PORT {pix_clk}
	CONFIG.USE_LOCKED {false}
	CONFIG.USE_RESET {false}
	CONFIG.MMCM_CLKFBOUT_MULT_F {23.625}
	CONFIG.MMCM_CLKIN1_PERIOD {20.000}
	CONFIG.MMCM_CLKIN2_PERIOD {10.0}
	CONFIG.MMCM_CLKOUT0_DIVIDE_F {46.875}
	CONFIG.CLKOUT1_JITTER {197.862}
	CONFIG.CLKOUT1_PHASE_ERROR {153.873}
	CONFIG.USE_SAFE_CLOCK_STARTUP {true}
} [get_ips clk_wiz_0]
    set_property -dict {
	GENERATE_SYNTH_CHECKPOINT {1}
    } $clk_wiz_0
}

init
setupFiles
genMMCM
