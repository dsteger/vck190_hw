set ip_dir [lindex $argv 2]
set config_tcl [lindex $argv 3]

source $config_tcl

proc config_design {} {
    set_part $::device
    create_clock -period $::period -name default
}

open_project ndt
set_top ndt_accel
add_files $ip_dir/ndt/ndt.cc
open_solution "soln"
config_design
csynth_design
export_design -format ip_catalog
close_project

exit

