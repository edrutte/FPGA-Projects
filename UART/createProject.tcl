proc init {} {
    create_project -part xc7a100tftg256-1 UART
    config_webtalk -user off
    set_property target_language VHDL [current_project]
    set_property simulator_language Mixed [current_project]
}

proc setupFiles {} {
    add_files "src/sources_1/"
    add_files -fileset constrs_1 "src/constrs_1/mercury2_baseboard.xdc"
    add_files -fileset sim_1 "src/sim_1/"
    set_property top UART_tb [get_filesets sim_1]
}

init
setupFiles
