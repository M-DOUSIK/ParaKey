set_db init_lib_search_path /home/install/FOUNDRY/digital/45nm/LIBS/lib/max
set_db lef_library /home/install/FOUNDRY/digital/45nm/LIBS/lef/gsclib045.fixed.lef
set_db library slow.lib

read_hdl {./../../Default/Default.srcs/sources_1/new/top.v}

elaborate

read_sdc ./constraints_top.sdc



syn_generic
syn_map
syn_opt

write_hdl > top_netlist.v
write_sdc > top_sdc.sdc

report power > top_power.rpt
report area > top_area.rpt
report gates > top_gates.rpt
report timing > top_timing.rpt

gui_show
