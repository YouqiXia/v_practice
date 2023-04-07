NOVAS_HOME = /opt/cad/synopsys/installs/verdi/Q-2020.03-SP2
SIM_PATH = ./logs
C_PATH = ./c_file
SRC_PATH = ./srcs

dump_on = 1
top_module = top

VLOGAN_OPTS = -full64 +v2k -l $(SIM_PATH)/com.log +define+SIMULATION_EN -sverilog

.PHONY:build analysis elaborate simulate verdi
all:analysis elaborate simulate verdi

build:
	-mkdir logs
	$(shell find $(SRC_PATH) -type f  -name "*v" > flist.f)

analysis: build
	vlogan $(VLOGAN_OPTS) -f ./flist.f -o $(SIM_PATH)
	make -C $(C_PATH) run

elaborate:
	vcs \
	-full64 \
	-debug_pp \
	-t ps \
	-licqueue \
	-l elaborate.log \
	-dpi $(C_PATH)/build/test.so \
	-P ${NOVAS_HOME}/share/PLI/VCS/LINUX64/novas.tab ${NOVAS_HOME}/share/PLI/VCS/LINUX64/pli.a \
	$(top_module) \
	-o $(SIM_PATH)/simv

simulate:
	time $(SIM_PATH)/simv -l $(SIM_PATH)/sim.log +dumpon=$(dump_on) +sim_log=$(SIM_PATH)

verdi:
	Verdi-SX \
	-f flist_v.f \
	-ssf $(SIM_PATH)/waves.fsdb
 
clean:
	rm -rf ./64 ./csrc ./verdiLog ./*.log ./top.fsdb ./ucli.key ./inter.vpd ./novas* ./DVEfiles ./simv ./simv.daidir

