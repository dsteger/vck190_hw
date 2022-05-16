set root_dir [lindex $argv 0]
set config_tcl [lindex $argv 1]

source ${config_tcl}

set constrs_dir ${root_dir}/constrs
set proj_dir ${root_dir}/build/vivado/${board}_platform${platform_index}/
set bd_tcl_dir ${root_dir}/designs/${board}_platform${platform_index}/
set ip_repo_path ${root_dir}/build/hls
set ext_ip_repo_path ${root_dir}/external

set proj_name ${board}_platform${platform_index}
set output {zip xsa bit}

create_project -name ${proj_name} -force -dir ${proj_dir} -part ${device}
set_property BOARD_PART xilinx.com:${board}:part0:${board_ver} [current_project]
set_property strategy ${strategy} [get_runs impl_1]

source ${bd_tcl_dir}/constraints.tcl
import_files -fileset constrs_1 ${xdc_list}

set ip_repo_paths {}
lappend ip_repo_paths \
    [list ${ip_repo_path}] \
    [list ${ext_ip_repo_path}]
set_property ip_repo_paths ${ip_repo_paths} [current_fileset]
update_ip_catalog -rebuild
update_ip_catalog

create_bd_design ${proj_name}
current_bd_design ${proj_name}

set parentCell [get_bd_cells /]
set parentObj [get_bd_cells $parentCell]
current_bd_instance $parentObj

source ${bd_tcl_dir}/${board}_platform${platform_index}.tcl
save_bd_design

make_wrapper -files [get_files ${proj_dir}/${proj_name}.srcs/sources_1/bd/${proj_name}/${proj_name}.bd] -top
import_files -force -norecurse ${proj_dir}/${proj_name}.srcs/sources_1/bd/${proj_name}/hdl/${proj_name}_wrapper.v
update_compile_order
set_property top ${proj_name}_wrapper [current_fileset]
update_compile_order -fileset sources_1

save_bd_design
validate_bd_design

set_property platform.board_id ${proj_name} [current_project]
set_property platform.default_output_type "xclbin" [current_project]
set_property platform.design_intent.datacenter false [current_project]
set_property platform.design_intent.embedded true [current_project]
set_property platform.design_intent.external_host false [current_project]
set_property platform.design_intent.server_managed false [current_project]
set_property platform.extensible true [current_project]
set_property platform.platform_state "pre_synth" [current_project]
set_property platform.full_pdi_file ${proj_dir}/${proj_name}.runs/impl_1/${proj_name}_wrapper.pdi [current_project]
set_property platform.name ${proj_name} [current_project]
set_property platform.vendor ${vendor} [current_project]
set_property platform.version ${version} [current_project]
set_property pfm_name ${proj_name} [get_files -all ${proj_name}.bd]

if { $artifacts eq "True" } {
    launch_runs synth_1 -jobs 16
    wait_on_run synth_1

    launch_runs impl_1 -to_step write_device_image -jobs 16
    wait_on_run impl_1
    open_run impl_1

    write_hw_platform -force -include_bit ${proj_dir}/${proj_name}_wrapper.xsa
    validate_hw_platform ${proj_dir}/${proj_name}_wrapper.xsa -verbose
    archive_project -force ${proj_dir}/${proj_name}.zip
}

exit
