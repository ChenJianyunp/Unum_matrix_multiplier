#!/bin/sh

# 
# Vivado(TM)
# runme.sh: a Vivado-generated Runs Script for UNIX
# Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
# 

if [ -z "$PATH" ]; then
  PATH=/opt/applics/xilinx-vivado-2017.1/SDK/2017.1/bin:/opt/applics/xilinx-vivado-2017.1/Vivado/2017.1/ids_lite/ISE/bin/lin64:/opt/applics/xilinx-vivado-2017.1/Vivado/2017.1/bin
else
  PATH=/opt/applics/xilinx-vivado-2017.1/SDK/2017.1/bin:/opt/applics/xilinx-vivado-2017.1/Vivado/2017.1/ids_lite/ISE/bin/lin64:/opt/applics/xilinx-vivado-2017.1/Vivado/2017.1/bin:$PATH
fi
export PATH

if [ -z "$LD_LIBRARY_PATH" ]; then
  LD_LIBRARY_PATH=/opt/applics/xilinx-vivado-2017.1/Vivado/2017.1/ids_lite/ISE/lib/lin64
else
  LD_LIBRARY_PATH=/opt/applics/xilinx-vivado-2017.1/Vivado/2017.1/ids_lite/ISE/lib/lin64:$LD_LIBRARY_PATH
fi
export LD_LIBRARY_PATH

HD_PWD='/shares/bulk/jianyuchen/capi_development_kit3/alphadata/adv7_capi_1_1_release/Sources/hdk3.runs/synth_1'
cd "$HD_PWD"

HD_LOG=runme.log
/bin/touch $HD_LOG

ISEStep="./ISEWrap.sh"
EAStep()
{
     $ISEStep $HD_LOG "$@" >> $HD_LOG 2>&1
     if [ $? -ne 0 ]
     then
         exit
     fi
}

EAStep vivado -log psl_fpga.vds -m64 -product Vivado -mode batch -messageDb vivado.pb -notrace -source psl_fpga.tcl
