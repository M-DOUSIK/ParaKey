set_db init_lib_search_path /home/install/FOUNDRY/digital/45nm/LIBS/lib/max
set_db lef_library /home/install/FOUNDRY/digital/45nm/LIBS/lef/gsclib045.fixed.lef
set_db library slow.lib

read_hdl {./../../Default/Source/KeyPadInterpreter.v}

elaborate

read_sdc ./constraints_KeyPadInterpreter.sdc



syn_generic
syn_map
syn_opt

write_hdl > KeyPadInterpreter_netlist.v
write_sdc > KeyPadInterpreter_sdc.sdc

report power > KeyPadInterpreter_power.rpt
report area > KeyPadInterpreter_area.rpt
report gates > KeyPadInterpreter_gates.rpt
report timing -unconstrained > KeyPadInterpreter_timing.rpt

gui_show
