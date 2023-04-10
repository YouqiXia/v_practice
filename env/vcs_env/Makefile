# parameter for dump fsdb
NOVAS_HOME = /opt/cad/synopsys/installs/verdi/Q-2020.03-SP2

SIM_PATH = ./sim
SIM_LOG = ./logs
dump_on = 1

CINC_PATH = ./cfile
CC_FLAGS = 
LDFLGAS = 
FILE_LIST = flist.f
TOP_MODULE = tb_top

# for create flist
RTL_PATH = ../srcs
DUT_PATH = ./dut

default: compile, build, run, wave, clean, creaflist

creaflist:
	-find -L $(RTL_PATH)/include/ -type f -regex '.*\.\(v\|sv\|vh\)' > flist.f
	-find -L $(DUT_PATH)/include/ -type f -regex '.*\.\(v\|sv\)' >> flist.f
	-find -L $(RTL_PATH)/rtl/ -type f -regex '.*\.\(v\|sv\)' >> flist.f
	-find -L $(DUT_PATH)/rtl/ -type f -regex '.*\.\(v\|sv\)' >> flist.f
	-find -L $(CINC_PATH) -type f -name '*c' >> flist.f

build: 
	-mkdir $(SIM_LOG) $(SIM_PATH)

compile: build
	vcs -full64 +vcs+lic+wait +vc+list \
		-f ${FILE_LIST} \
		-sverilog -v2k_generate \
		-kdb +vpi \
		-dpi -CFLAGS "$(CC_FLAGS)" -incdir+"$(CINC_PATH)" -LDFLGAS "$(LDFLGAS)" \
		-P ${NOVAS_HOME}/share/PLI/VCS/LINUX64/novas.tab ${NOVAS_HOME}/share/PLI/VCS/LINUX64/pli.a \
		+lint=TFIPC-L +lint=PCWM-L -debug_access+all +error+10 \
		-top $(TOP_MODULE) -timescale=1ns/1ps \
		-o $(SIM_PATH)/simv

# optional: +loopdetect+number

#	vcs +vcs+lic+wait -sverilog -kdb $(VCS_MACRO) $(VCS_PARAM) \
		+vc+list +vpi $(CC_FILE) ${BLD}/rrvtb.so ${VCS_MODEL_OPTS} \
		-load ${BLD}/rrvtb.so:tb_init_cb \
		-CFLAGS "$(CC_INC) $(CC_FLAGS)" \
		-LDFLAGS "-lgmp -T$(LDS_FILE) -g" \
		+lint=TFIPC-L -full64 -F ${FILE_LIST} \
		-top $(TOP_MODULE) -timescale=1ns/1ps \
		-v2k_generate -debug_access+all

run: compile
	time $(SIM_PATH)/simv +dumpon=$(dump_on) +sim_log=$(SIM_LOG) 2>&1 | tee $(SIM_LOG)/sim.log

wave: run
	Verdi-SX -f $(FILE_LIST) -ssf $(SIM_LOG)/waves.fsdb 

clean:
	-rm $(SIM_LOG) $(SIM_PATH) -r
	-rm bld.log simv ucli.key waves.*
	-rm -r csrc simv.daidir logs Verdi-SXLog
	-rm *.log
	-rm novas* .nfs* 
