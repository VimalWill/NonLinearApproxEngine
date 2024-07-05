set target_library /nfs/zsc10/disks/mvds_nn_arch_disk001/araha/papers_patents/synthesis/NanGate15nm/front_end/timing_power_noise/ECSM/NanGate_15nm_OCL_typical_conditional_ecsm.db

set synthetic_library /p/hdk/rtl/cad/x86-64_linux30/synopsys/designcompiler/R-2020.09/libraries/syn/dw_foundation.sldb

set link_library "* $target_library $synthetic_library"

analyze -format verilog { \
  Memory/BRAM_DP.v \
  Memory/Coeff_cntr.v \
  Memory/CoeffFIFO.v \
  Memory/InputFIFO.v \
  Memory/PriorityEncoder.v \
  Adder_32.v \
  cntlz.v \
  controller.v \
  datapath.v \
  MAC.v \
  Multi_32.v \
}

elaborate mac
