root_dir := $(PWD)
src_dir := ./src
syn_dir := ./syn
pr_dir := ./pr/icc2_ADFP_tsri/run
inc_dir := ./include
sim_dir := ./sim
vip_dir := $(PWD)/vip
bld_dir := ./build
lib_dir := /usr/cad/CBDK/CBDK018_UMC_Faraday_v1.0/orig_lib/fsa0m_a/2009Q2v2.0/GENERIC_CORE/FrontEnd/verilog
lib_dir_io := /usr/cad/CBDK/Executable_Package/Collaterals/IP/stdio/N16ADFP_StdIO/VERILOG/

FSDB_DEF :=
ifeq ($(FSDB),1)
FSDB_DEF := +FSDB
else ifeq ($(FSDB),2)
FSDB_DEF := +FSDB_ALL
endif
maxpend :=
ifeq ($(pend),1)
	maxpend := 1
else ifeq ($(pend),2) 
	maxpend := 2
else
	maxpend := 0
endif
$(info maxpend=$(maxpend))

export vip_dir
export maxpend

$(bld_dir):
	mkdir -p $(bld_dir)

$(syn_dir):
	mkdir -p $(syn_dir)

$(pr_dir):
	mkdir -p $(pr_dir)

$(bld_dir):
	mkdir -p $(bld_dir)
# AXI simulation
vip_b: clean | $(bld_dir)
	cd $(bld_dir); \
	jg ../script/jg_bridge.tcl &

# TA use this to check result
TA_run: 
  
# RTL simulation
rtl_all: rtl0 rtl1 rtl2 rtl3

rtl_inst: | clean $(bld_dir)
	cd $(bld_dir); \
	vcs -R -sverilog $(root_dir)/$(sim_dir)/prog_inst/top_tb_prog_inst.sv -debug_access+all -full64 -debug_region+cell +memcbk \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	-f $(root_dir)/$(src_dir)/rtl_sim.f \
	+define+prog_inst$(FSDB_DEF) \
	+prog_path=$(root_dir)/$(sim_dir)/prog_inst \
  	+rdcycle=1 \
	+notimingcheck

rtl0: | clean $(bld_dir)
	make -C $(sim_dir)/prog0/; \
	cd $(bld_dir); \
	vcs -R -sverilog $(root_dir)/$(sim_dir)/top_tb.sv -debug_access+all -full64 -debug_region+cell +memcbk \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	-f $(root_dir)/$(src_dir)/rtl_sim.f \
	+define+prog0$(FSDB_DEF) \
	+prog_path=$(root_dir)/$(sim_dir)/prog0 \
  	+rdcycle=1 \
	+notimingcheck

rtl1: | clean $(bld_dir)
	make -C $(sim_dir)/prog1/; \
	cd $(bld_dir); \
	vcs -R -sverilog $(root_dir)/$(sim_dir)/top_tb.sv -debug_access+all -full64 -debug_region+cell +memcbk \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	-f $(root_dir)/$(src_dir)/rtl_sim.f \
	+define+prog1$(FSDB_DEF) \
	+prog_path=$(root_dir)/$(sim_dir)/prog1 \
	+rdcycle=1 \
	+notimingcheck

rtl2: | clean $(bld_dir)
	make -C $(sim_dir)/prog2/; \
	cd $(bld_dir); \
	vcs -R -sverilog $(root_dir)/$(sim_dir)/top_tb.sv -debug_access+all -full64 -debug_region+cell +memcbk \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	-f $(root_dir)/$(src_dir)/rtl_sim.f \
	+define+prog2$(FSDB_DEF) \
	+prog_path=$(root_dir)/$(sim_dir)/prog2 \
	+rdcycle=1 \
	+notimingcheck

rtl3: | clean $(bld_dir)
	make -C $(sim_dir)/prog3/; \
	cd $(bld_dir); \
	vcs -R -sverilog $(root_dir)/$(sim_dir)/top_tb_WDT.sv -debug_access+all -full64 -debug_region+cell +memcbk \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	-f $(root_dir)/$(src_dir)/rtl_sim.f \
	+define+prog3$(FSDB_DEF) \
	+prog_path=$(root_dir)/$(sim_dir)/prog3 \
	+rdcycle=1 \
	+notimingcheck

rtl_conv0: | clean $(bld_dir)
	make -C $(sim_dir)/conv0/; \
	cd $(bld_dir); \
	vcs -R -sverilog $(root_dir)/$(sim_dir)/conv0/top_tb_conv0.sv -debug_access+all -full64 -debug_region+cell +memcbk \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	-f $(root_dir)/$(src_dir)/rtl_sim.f \
	+define+conv0$(FSDB_DEF) \
	+prog_path=$(root_dir)/$(sim_dir)/conv0 \
	+rdcycle=1 \
	+notimingcheck

rtl_conv1: | clean $(bld_dir)
	make -C $(sim_dir)/conv1/; \
	cd $(bld_dir); \
	vcs -R -sverilog $(root_dir)/$(sim_dir)/conv1/top_tb_conv1.sv -debug_access+all -full64 -debug_region+cell +memcbk \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	-f $(root_dir)/$(src_dir)/rtl_sim.f \
	+define+conv1$(FSDB_DEF) \
	+prog_path=$(root_dir)/$(sim_dir)/conv1 \
	+rdcycle=1 \
	+notimingcheck
	
rtl_conv2: | clean $(bld_dir)
	make -C $(sim_dir)/conv2/; \
	cd $(bld_dir); \
	vcs -R -sverilog $(root_dir)/$(sim_dir)/conv2/top_tb_conv2.sv -debug_access+all -full64 -debug_region+cell +memcbk \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	-f $(root_dir)/$(src_dir)/rtl_sim.f \
	+define+conv2$(FSDB_DEF) \
	+prog_path=$(root_dir)/$(sim_dir)/conv2 \
	+rdcycle=1 \
	+notimingcheck

rtl_conv3: | clean $(bld_dir)
	make -C $(sim_dir)/conv3/; \
	cd $(bld_dir); \
	vcs -R -sverilog $(root_dir)/$(sim_dir)/conv3/top_tb_conv3.sv -debug_access+all -full64 -debug_region+cell +memcbk \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	-f $(root_dir)/$(src_dir)/rtl_sim.f \
	+define+conv3$(FSDB_DEF) \
	+prog_path=$(root_dir)/$(sim_dir)/conv3 \
	+rdcycle=1 \
	+notimingcheck

rtl_gap: | clean $(bld_dir)
	make -C $(sim_dir)/gap/; \
	cd $(bld_dir); \
	vcs -R -sverilog $(root_dir)/$(sim_dir)/gap/top_tb_gap.sv -debug_access+all -full64 -debug_region+cell +memcbk \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	-f $(root_dir)/$(src_dir)/rtl_sim.f \
	+define+gap$(FSDB_DEF) \
	+prog_path=$(root_dir)/$(sim_dir)/gap \
	+rdcycle=1 \
	+notimingcheck

rtl_fc1: | clean $(bld_dir)
	make -C $(sim_dir)/fc1/; \
	cd $(bld_dir); \
	vcs -R -sverilog $(root_dir)/$(sim_dir)/fc1/top_tb_fc1.sv -debug_access+all -full64 -debug_region+cell +memcbk \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	-f $(root_dir)/$(src_dir)/rtl_sim.f \
	+define+fc1$(FSDB_DEF) \
	+prog_path=$(root_dir)/$(sim_dir)/fc1 \
	+rdcycle=1 \
	+notimingcheck

rtl_epu_all: | clean $(bld_dir)
	make -C $(sim_dir)/epu_all/; \
	cd $(bld_dir); \
	vcs -R -sverilog $(root_dir)/$(sim_dir)/epu_all/top_tb_epu_all.sv -debug_access+all -full64 -debug_region+cell +memcbk \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	-f $(root_dir)/$(src_dir)/rtl_sim.f \
	+define+epu_all$(FSDB_DEF) \
	+prog_path=$(root_dir)/$(sim_dir)/epu_all \
	+rdcycle=1 \
	+notimingcheck

# Post-Synthesis simulation
syn_all: syn0 syn1 syn2 syn3

syn_inst: | clean $(bld_dir)
	cd $(bld_dir); \
	vcs -R -sverilog +neg_tchk -negdelay -v $(lib_dir)/N16ADFP_StdCell.v  $(root_dir)/$(sim_dir)/prog_inst/top_tb_prog_inst.sv -debug_access+all -full64 -diag=sdf:verbose \
	+incdir+$(root_dir)/$(syn_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+SYN+prog_inst$(FSDB_DEF) \
	+no_notifier \
	+prog_path=$(root_dir)/$(sim_dir)/prog_inst \
  +rdcycle=1

syn0: | clean $(bld_dir)
	make -C $(sim_dir)/prog0/; \
	cd $(bld_dir); \
	vcs -R -sverilog +neg_tchk -negdelay -v $(lib_dir)/N16ADFP_StdCell.v  $(root_dir)/$(sim_dir)/top_tb.sv -debug_access+all -full64 -diag=sdf:verbose \
	+incdir+$(root_dir)/$(syn_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+SYN+prog0$(FSDB_DEF) \
	+no_notifier \
	+prog_path=$(root_dir)/$(sim_dir)/prog0 \
  +rdcycle=1


syn1: | clean $(bld_dir)
	make -C $(sim_dir)/prog1/; \
	cd $(bld_dir); \
	vcs -R -sverilog +neg_tchk -negdelay -v $(lib_dir)/N16ADFP_StdCell.v  $(root_dir)/$(sim_dir)/top_tb.sv -debug_access+all -full64 -diag=sdf:verbose \
	+incdir+$(root_dir)/$(syn_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+SYN+prog1$(FSDB_DEF) \
	+no_notifier \
	+prog_path=$(root_dir)/$(sim_dir)/prog1 \
  +rdcycle=1

syn2: | clean $(bld_dir)
	make -C $(sim_dir)/prog2/; \
	cd $(bld_dir); \
	vcs -R -sverilog +neg_tchk -negdelay -v $(lib_dir)/N16ADFP_StdCell.v  $(root_dir)/$(sim_dir)/top_tb.sv -debug_access+all -full64 -diag=sdf:verbose \
	+incdir+$(root_dir)/$(syn_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+SYN+prog2$(FSDB_DEF) \
	+no_notifier \
	+prog_path=$(root_dir)/$(sim_dir)/prog2 \

syn3: | clean $(bld_dir)
	make -C $(sim_dir)/prog3/; \
	cd $(bld_dir); \
	vcs -R -sverilog +neg_tchk -negdelay -v $(lib_dir)/N16ADFP_StdCell.v  $(root_dir)/$(sim_dir)/top_tb_WDT.sv -debug_access+all -full64 -diag=sdf:verbose \
	+incdir+$(root_dir)/$(syn_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+SYN+prog3$(FSDB_DEF) \
	+no_notifier \
	+prog_path=$(root_dir)/$(sim_dir)/prog3 \

syn_conv0: | clean $(bld_dir)
	make -C $(sim_dir)/conv0/; \
	cd $(bld_dir); \
	vcs -R -sverilog +neg_tchk -negdelay -v $(lib_dir)/N16ADFP_StdCell.v  $(root_dir)/$(sim_dir)/conv0/top_tb_conv0.sv -debug_access+all -full64 -diag=sdf:verbose \
	+incdir+$(root_dir)/$(syn_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+SYN+conv0$(FSDB_DEF) \
	+no_notifier \
	+prog_path=$(root_dir)/$(sim_dir)/conv0 \

syn_conv1: | clean $(bld_dir)
	make -C $(sim_dir)/conv1/; \
	cd $(bld_dir); \
	vcs -R -sverilog +neg_tchk -negdelay -v $(lib_dir)/N16ADFP_StdCell.v  $(root_dir)/$(sim_dir)/conv1/top_tb_conv1.sv -debug_access+all -full64 -diag=sdf:verbose \
	+incdir+$(root_dir)/$(syn_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+SYN+conv1$(FSDB_DEF) \
	+no_notifier \
	+prog_path=$(root_dir)/$(sim_dir)/conv1 \
	
syn_conv2: | clean $(bld_dir)
	make -C $(sim_dir)/conv2/; \
	cd $(bld_dir); \
	vcs -R -sverilog +neg_tchk -negdelay -v $(lib_dir)/N16ADFP_StdCell.v  $(root_dir)/$(sim_dir)/conv2/top_tb_conv2.sv -debug_access+all -full64 -diag=sdf:verbose \
	+incdir+$(root_dir)/$(syn_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+SYN+conv2$(FSDB_DEF) \
	+no_notifier \
	+prog_path=$(root_dir)/$(sim_dir)/conv2 \

syn_conv3: | clean $(bld_dir)
	make -C $(sim_dir)/conv3/; \
	cd $(bld_dir); \
	vcs -R -sverilog +neg_tchk -negdelay -v $(lib_dir)/N16ADFP_StdCell.v  $(root_dir)/$(sim_dir)/conv3/top_tb_conv3.sv -debug_access+all -full64 -diag=sdf:verbose \
	+incdir+$(root_dir)/$(syn_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+SYN+conv3$(FSDB_DEF) \
	+no_notifier \
	+prog_path=$(root_dir)/$(sim_dir)/conv3 \

syn_gap: | clean $(bld_dir)
	make -C $(sim_dir)/gap/; \
	cd $(bld_dir); \
	vcs -R -sverilog +neg_tchk -negdelay -v $(lib_dir)/N16ADFP_StdCell.v  $(root_dir)/$(sim_dir)/gap/top_tb_gap.sv -debug_access+all -full64 -diag=sdf:verbose \
	+incdir+$(root_dir)/$(syn_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+SYN+gap$(FSDB_DEF) \
	+no_notifier \
	+prog_path=$(root_dir)/$(sim_dir)/gap \

syn_fc1: | clean $(bld_dir)
	make -C $(sim_dir)/fc1/; \
	cd $(bld_dir); \
	vcs -R -sverilog +neg_tchk -negdelay -v $(lib_dir)/N16ADFP_StdCell.v  $(root_dir)/$(sim_dir)/fc1/top_tb_fc1.sv -debug_access+all -full64 -diag=sdf:verbose \
	+incdir+$(root_dir)/$(syn_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+SYN+fc1$(FSDB_DEF) \
	+no_notifier \
	+prog_path=$(root_dir)/$(sim_dir)/fc1 \

syn_epu_all: | clean $(bld_dir)
	make -C $(sim_dir)/epu_all/; \
	cd $(bld_dir); \
	vcs -R -sverilog +neg_tchk -negdelay -v $(lib_dir)/N16ADFP_StdCell.v  $(root_dir)/$(sim_dir)/epu_all/top_tb_epu_all.sv -debug_access+all -full64 -diag=sdf:verbose \
	+incdir+$(root_dir)/$(syn_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+SYN+fc1$(FSDB_DEF) \
	+no_notifier \
	+prog_path=$(root_dir)/$(sim_dir)/epu_all \

# Post-Layout simulation
pr_all: pr0 pr1 pr2 pr3

pr_inst: | clean $(bld_dir)
	cd $(bld_dir); \
	vcs -R -sverilog +neg_tchk -negdelay -v $(lib_dir)/N16ADFP_StdCell.v  $(root_dir)/$(sim_dir)/prog_inst/top_tb_prog_inst.sv -debug_access+all -full64 -diag=sdf:verbose \
	+incdir+$(root_dir)/$(pr_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+PR+prog_inst$(FSDB_DEF) \
	+no_notifier \
	+maxdelays \
	+prog_path=$(root_dir)/$(sim_dir)/prog_inst \

pr0: | clean $(bld_dir)
	make -C $(sim_dir)/prog0/; \
	cd $(bld_dir); \
	vcs -R -sverilog +neg_tchk -negdelay -v $(lib_dir)/N16ADFP_StdCell.v  $(root_dir)/$(sim_dir)/top_tb.sv -debug_access+all -full64 -diag=sdf:verbose \
	+incdir+$(root_dir)/$(pr_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+PR+prog0$(FSDB_DEF) \
	+no_notifier \
	+maxdelays \
	+prog_path=$(root_dir)/$(sim_dir)/prog0 \

pr1: | clean $(bld_dir)
	make -C $(sim_dir)/prog1/; \
	cd $(bld_dir); \
	vcs -R -sverilog +neg_tchk -negdelay -v $(lib_dir)/N16ADFP_StdCell.v  $(root_dir)/$(sim_dir)/top_tb.sv -debug_access+all -full64 -diag=sdf:verbose \
	+incdir+$(root_dir)/$(pr_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+PR+prog1$(FSDB_DEF) \
	+no_notifier \
	+maxdelays \
	+prog_path=$(root_dir)/$(sim_dir)/prog1 \

pr2: | clean $(bld_dir)
	make -C $(sim_dir)/prog2/; \
	cd $(bld_dir); \
	vcs -R -sverilog +neg_tchk -negdelay -v $(lib_dir)/N16ADFP_StdCell.v  $(root_dir)/$(sim_dir)/top_tb.sv -debug_access+all -full64 -diag=sdf:verbose \
	+incdir+$(root_dir)/$(pr_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+PR+prog2$(FSDB_DEF) \
	+no_notifier \
	+maxdelays \
	+prog_path=$(root_dir)/$(sim_dir)/prog2 \

pr3: | clean $(bld_dir)
	make -C $(sim_dir)/prog3/; \
	cd $(bld_dir); \
	vcs -R -sverilog +neg_tchk -negdelay -v $(lib_dir)/N16ADFP_StdCell.v  $(root_dir)/$(sim_dir)/top_tb_WDT.sv -debug_access+all -full64 -diag=sdf:verbose \
	+incdir+$(root_dir)/$(pr_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+PR+prog3$(FSDB_DEF) \
	+no_notifier \
	+maxdelays \
	+prog_path=$(root_dir)/$(sim_dir)/prog3 \

pr_conv0: | clean $(bld_dir)
	make -C $(sim_dir)/conv0/; \
	cd $(bld_dir); \
	vcs -R -sverilog +neg_tchk -negdelay -v $(lib_dir)/N16ADFP_StdCell.v  $(root_dir)/$(sim_dir)/conv0/top_tb_conv0.sv -debug_access+all -full64 -diag=sdf:verbose \
	+incdir+$(root_dir)/$(pr_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+PR+conv0$(FSDB_DEF) \
	+no_notifier \
	+maxdelays \
	+prog_path=$(root_dir)/$(sim_dir)/conv0 \

pr_conv1: | clean $(bld_dir)
	make -C $(sim_dir)/conv1/; \
	cd $(bld_dir); \
	vcs -R -sverilog +neg_tchk -negdelay -v $(lib_dir)/N16ADFP_StdCell.v  $(root_dir)/$(sim_dir)/conv1/top_tb_conv1.sv -debug_access+all -full64 -diag=sdf:verbose \
	+incdir+$(root_dir)/$(pr_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+PR+conv1$(FSDB_DEF) \
	+no_notifier \
	+maxdelays \
	+prog_path=$(root_dir)/$(sim_dir)/conv1 \
	
pr_conv2: | clean $(bld_dir)
	make -C $(sim_dir)/conv2/; \
	cd $(bld_dir); \
	vcs -R -sverilog +neg_tchk -negdelay -v $(lib_dir)/N16ADFP_StdCell.v  $(root_dir)/$(sim_dir)/conv2/top_tb_conv2.sv -debug_access+all -full64 -diag=sdf:verbose \
	+incdir+$(root_dir)/$(pr_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+PR+conv2$(FSDB_DEF) \
	+no_notifier \
	+maxdelays \
	+prog_path=$(root_dir)/$(sim_dir)/conv2 \

pr_conv3: | clean $(bld_dir)
	make -C $(sim_dir)/conv3/; \
	cd $(bld_dir); \
	vcs -R -sverilog +neg_tchk -negdelay -v $(lib_dir)/N16ADFP_StdCell.v  $(root_dir)/$(sim_dir)/conv3/top_tb_conv3.sv -debug_access+all -full64 -diag=sdf:verbose \
	+incdir+$(root_dir)/$(pr_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+PR+conv3$(FSDB_DEF) \
	+no_notifier \
	+maxdelays \
	+prog_path=$(root_dir)/$(sim_dir)/conv3 \

pr_gap: | clean $(bld_dir)
	make -C $(sim_dir)/gap/; \
	cd $(bld_dir); \
	vcs -R -sverilog +neg_tchk -negdelay -v $(lib_dir)/N16ADFP_StdCell.v  $(root_dir)/$(sim_dir)/gap/top_tb_gap.sv -debug_access+all -full64 -diag=sdf:verbose \
	+incdir+$(root_dir)/$(pr_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+PR+gap$(FSDB_DEF) \
	+no_notifier \
	+maxdelays \
	+prog_path=$(root_dir)/$(sim_dir)/gap \

pr_fc1: | clean $(bld_dir)
	make -C $(sim_dir)/fc1/; \
	cd $(bld_dir); \
	vcs -R -sverilog +neg_tchk -negdelay -v $(lib_dir)/N16ADFP_StdCell.v  $(root_dir)/$(sim_dir)/fc1/top_tb_fc1.sv -debug_access+all -full64 -diag=sdf:verbose \
	+incdir+$(root_dir)/$(pr_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+PR+fc1$(FSDB_DEF) \
	+no_notifier \
	+maxdelays \
	+prog_path=$(root_dir)/$(sim_dir)/fc1 \

pr_epu_all: | clean $(bld_dir)
	make -C $(sim_dir)/epu_all/; \
	cd $(bld_dir); \
	vcs -R -sverilog +neg_tchk -negdelay -v $(lib_dir)/N16ADFP_StdCell.v  $(root_dir)/$(sim_dir)/epu_all/top_tb_epu_all.sv -debug_access+all -full64 -diag=sdf:verbose \
	+incdir+$(root_dir)/$(pr_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+PR+epu_all$(FSDB_DEF) \
	+no_notifier \
	+maxdelays \
	+prog_path=$(root_dir)/$(sim_dir)/epu_all \
# Utilities
nWave: | $(bld_dir)
	cd $(bld_dir); \
	nWave chip.fsdb &

verdi: | $(bld_dir)
	cd $(bld_dir); \
	verdi -ssf top.fsdb &

superlint: | $(bld_dir)
	cd $(bld_dir); \
	jg -superlint ../script/superlint.tcl &

dv: | $(bld_dir) $(syn_dir)
	cp script/synopsys_dc.setup $(bld_dir)/.synopsys_dc.setup; \
	cd $(bld_dir); \
	dc_shell -gui -no_home_init &

synthesize: | $(bld_dir) $(syn_dir)
	cp script/synopsys_dc.setup $(bld_dir)/.synopsys_dc.setup; \
	cd $(bld_dir); \
	dc_shell -no_home_init -f ../script/synthesis.tcl | tee syn_compile.log

innovus: | $(bld_dir) $(pr_dir)
	cd $(bld_dir); \
	innovus

icc2: | $(pr_dir)
	make clean_pr; \
	cd $(pr_dir); \
	icc2_shell -file ../scripts/00_run.tcl

icc2_gui: | $(pr_dir)
	cd $(pr_dir); \
	icc2_shell -gui;

spyglass: | $(bld_dir)
	cd $(bld_dir); \
	spyglass -tcl ../script/Spyglass_CDC.tcl &

# Check file structure
BLUE=\033[1;34m
RED=\033[1;31m
NORMAL=\033[0m

check: clean
	@if [ -f StudentID ]; then \
		STUDENTID=$$(grep -v '^$$' StudentID); \
		if [ -z "$$STUDENTID" ]; then \
			echo -e "$(RED)Student ID number is not provided$(NORMAL)"; \
			exit 1; \
		else \
			ID_LEN=$$(expr length $$STUDENTID); \
			if [ $$ID_LEN -eq 9 ]; then \
				if [[ $$STUDENTID =~ ^[A-Z][A-Z0-9][0-9]+$$ ]]; then \
					echo -e "$(BLUE)Student ID number pass$(NORMAL)"; \
				else \
					echo -e "$(RED)Student ID number should be one capital letter and 8 numbers (or 2 capital letters and 7 numbers)$(NORMAL)"; \
					exit 1; \
				fi \
			else \
				echo -e "$(RED)Student ID number length isn't 9$(NORMAL)"; \
				exit 1; \
			fi \
		fi \
	else \
		echo -e "$(RED)StudentID file is not found$(NORMAL)"; \
		exit 1; \
	fi; \
	if [ -f StudentID2 ]; then \
		STUDENTID2=$$(grep -v '^$$' StudentID2); \
		if [ -z "$$STUDENTID2" ]; then \
			echo -e "$(RED)Second student ID number is not provided$(NORMAL)"; \
			exit 1; \
		else \
			ID2_LEN=$$(expr length $$STUDENTID2); \
			if [ $$ID2_LEN -eq 9 ]; then \
				if [[ $$STUDENTID2 =~ ^[A-Z][A-Z0-9][0-9]+$$ ]]; then \
					echo -e "$(BLUE)Second student ID number pass$(NORMAL)"; \
				else \
					echo -e "$(RED)Second student ID number should be one capital letter and 8 numbers (or 2 capital letters and 7 numbers)$(NORMAL)"; \
					exit 1; \
				fi \
			else \
				echo -e "$(RED)Second student ID number length isn't 9$(NORMAL)"; \
				exit 1; \
			fi \
		fi \
	fi; \
	if [ $$(ls -1 *.docx 2>/dev/null | wc -l) -eq 0 ]; then \
		echo -e "$(RED)Report file is not found$(NORMAL)"; \
		exit 1; \
	elif [ $$(ls -1 *.docx 2>/dev/null | wc -l) -gt 1 ]; then \
		echo -e "$(RED)More than one docx file is found, please delete redundant file(s)$(NORMAL)"; \
		exit 1; \
	elif [ ! -f $${STUDENTID}.docx ]; then \
		echo -e "$(RED)Report file name should be $$STUDENTID.docx$(NORMAL)"; \
		exit 1; \
	else \
		echo -e "$(BLUE)Report file name pass$(NORMAL)"; \
	fi; \
	if [ $$(basename $(PWD)) != $$STUDENTID ]; then \
		echo -e "$(RED)Main folder name should be \"$$STUDENTID\"$(NORMAL)"; \
		exit 1; \
	else \
		echo -e "$(BLUE)Main folder name pass$(NORMAL)"; \
	fi

tar: check
	STUDENTID=$$(basename $(PWD)); \
	cd ..; \
	tar cvf $$STUDENTID.tar $$STUDENTID

.PHONY: clean


clean_pr:
	rm -rf ./pr/icc2_ADFP_tsri/run; \
	mkdir ./pr/icc2_ADFP_tsri/run;
	
clean:
	rm -rf $(bld_dir); \
	rm -rf $(sim_dir)/prog*/result*.txt; \
	make -C $(sim_dir)/prog0/ clean; \
