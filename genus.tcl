set_db init_lib_search_path
/home/himanshukumarrai/Downloads/lasyasushma/counter_design_databa
se_45nm/lib
set_db init_hdl_search_path
/home/himanshukumarrai/Downloads/lasyasushma
read_libs fast_vdd1v0_basicCells.lib
read_hdl B_8_A.v
read_hdl array_8.v
read_hdl full_adder.v
read_hdl half_adder.v
#set $top B_8_A
elaborate B_8_A
read_sdc
/home/himanshukumarrai/Downloads/lasyasushma/constraints_top.sdc
set_db syn_generic_effort medium
set_db syn_map_effort medium
set_db syn_opt_effort medium
syn_generic
syn_map
#reports_before
report_timing > reports_before/report_timing_before.rpt
report_power > reports_before/report_power_before.rpt
report_area > reports_before/report_area_before.rpt
report_qor > reports_before/report_qor_before.rpt
syn_opt
#reports_after
report_timing > reports_after/report_timing_after.rpt
report_power > reports_after/report_power_after.rpt
report_area > reports_after/report_area_after.rpt
report_qor > reports_after/report_qor_after.rpt
#Outputs
write_hdl > outputs/B_8_A_netlist.v
write_sdc > outputs/B_8_A.sdc
write_sdf -timescale ns -nonegchecks -recrem split -edges check_edge -
setuphold split > outputs/delays.sdf