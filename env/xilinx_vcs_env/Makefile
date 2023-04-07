NOVAS_HOME = /opt/cad/synopsys/installs/verdi/Q-2020.03-SP2
SIM_PATH = ./log
SRC_PATH = ./srcs

dump_on = 1
top_module = demo_tb

VLOGAN_OPTS = -work xil_defaultlib -full64 +v2k -l $(SIM_PATH)/com.log +define+SIMULATION_EN -sverilog
VHDLAN_OPTS = -work xil_defaultlib -full64 

.PHONY:build analysis elaborate simulate verdi
all:analysis elaborate simulate verdi

build:
	-mkdir log
	$(shell find $(SRC_PATH) -type f  -name "*.v" > flist_v.f)
	$(shell find $(SRC_PATH) -type f  -name "*.vhd" > flist_vhdl.f)

analysis: build
	vlogan $(VLOGAN_OPTS) -f ./flist_v.f
	-vhdlan $(VHDLAN_OPTS) -f ./flist_vhdl.f

elaborate:
	vcs \
	-full64 \
	-debug_pp \
	-t ps \
	-licqueue \
	-l elaborate.log \
	-P ${NOVAS_HOME}/share/PLI/VCS/LINUX64/novas.tab ${NOVAS_HOME}/share/PLI/VCS/LINUX64/pli.a \
	xil_defaultlib.$(top_module) \
	xil_defaultlib.glbl \
	-o $(SIM_PATH)/simv

simulate:
	$(SIM_PATH)/simv -l $(SIM_PATH)/sim.log +notimingcheck +nospecify +dumpon=$(dump_on) +sim_log=$(SIM_PATH)

verdi:
	Verdi-SX \
	-f flist_v.f \
	-ssf $(SIM_PATH)/waves.fsdb
 
clean:
	rm -rf ./64 ./csrc ./verdiLog ./*.log ./top.fsdb ./ucli.key ./inter.vpd ./novas* ./DVEfiles ./simv ./simv.daidir

