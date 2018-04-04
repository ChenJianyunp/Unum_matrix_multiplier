open_checkpoint Implement/psl_fpga/psl_fpga_route_design.dcp
write_bitstream -force psl_fpga.bit
write_cfgmem -format bin -loadbit "up 0x0 psl_fpga.bit" -file psl_fpga_flash -size 128 -interface  BPIx16 -force
