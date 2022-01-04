############################################################
## This file is generated automatically by Vitis HLS.
## Please DO NOT edit it.
## Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
############################################################
open_project Vitis
set_top sha256chunk
add_files Vitis/csrc/shalibHLS.c
open_solution "First" -flow_target vivado
set_part {xc7a100t-ftg256-1}
create_clock -period 20 -name default
config_export -vivado_clock 20
source "./Vitis/First/directives.tcl"
#csim_design -ldflags {-m64 -B/usr/lib/x86_64-linux-gnu}
csynth_design
#cosim_design -ldflags {-m64 -B/usr/lib/x86_64-linux-gnu}
export_design -flow syn -rtl vhdl -format ip_catalog
