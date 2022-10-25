proc init {} {
    create_project -part xc7a100tftg256-1 MIPS
    config_webtalk -user off
    set_property target_language VHDL [current_project]
    set_property simulator_language Mixed [current_project]
}

proc setupFiles {} {
    add_files "src/sources_1/"
    add_files -fileset constrs_1 "src/constrs_1/mercury2_baseboard.xdc"
    add_files -fileset sim_1 "src/sim_1/MipsTB.vhd"
    set_property FILE_TYPE {VHDL 2008} [get_files {core.vhd InstructionDecode.vhd MipsTB.vhd}]
    set_property used_in_simulation false [get_files MIPS.vhd]
    set_property top MipsTB [get_filesets sim_1]
}

proc genMMCM {} {
    set clk_wiz_0 [create_ip -name clk_wiz -vendor xilinx.com -library ip -version 6.0 -module_name clk_wiz_0]
    set_property -dict {
	CONFIG.PRIM_IN_FREQ {50}
	CONFIG.CLKIN1_JITTER_PS {200.0}
	CONFIG.PRIMARY_PORT {clkin}
	CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {100}
	CONFIG.CLK_OUT1_PORT {clk}
	CONFIG.USE_LOCKED {false}
	CONFIG.USE_RESET {false}
	CONFIG.MMCM_CLKFBOUT_MULT_F {20.000}
	CONFIG.MMCM_CLKIN1_PERIOD {20.000}
	CONFIG.MMCM_CLKIN2_PERIOD {10.0}
	CONFIG.MMCM_CLKOUT0_DIVIDE_F {10.000}
	CONFIG.CLKOUT1_JITTER {162.035}
	CONFIG.CLKOUT1_PHASE_ERROR {164.985}
	CONFIG.USE_SAFE_CLOCK_STARTUP {true}
} [get_ips clk_wiz_0]
    set_property -dict {
	GENERATE_SYNTH_CHECKPOINT {1}
    } $clk_wiz_0
}

proc createRuns {} {
    set_property -name "strategy" -value "Performance_ExtraTimingOpt" -objects [get_runs impl_1]
    set_property -name "steps.post_route_phys_opt_design.is_enabled" -value "1" -objects [get_runs impl_1]
}

init
setupFiles
genMMCM
createRuns
