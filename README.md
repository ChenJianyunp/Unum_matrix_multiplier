# Unum_matrix_multiplier
Matrix multiplier of 32-bit Posit number (Unum type-III) with es=2. This multiplier consists of 64 exact-multiply-accumulators, so it can do mutiplication more accurate than normal ones. This design is based on IBM CAPI interface with the fpga Xilinx Vertex7.<br>
Posit number (or Unum type-III) is a new kind of format proposed by John Gustafson. For detail of the posit number, see https://posithub.org/docs/Posits4.pdf

Publication
----
The paper for this project is published in ACM digital library, see: https://dl.acm.org/citation.cfm?id=3190340 \
And a presentation of this project is given on the conference ConGA 2018, see:\
Slides: https://posithub.org/conga/2018/docs/2-Jianyu-Chen.pdf \
Video: https://www.youtube.com/watch?v=aogyhyh5_U4&feature=youtu.be

Directory:
----
Sources/afu/: all the source files of AFU<br>
Sources/afu/mm: all source files on of matrix multiplier<br>
Sources/afu/lib & Source/afu/pkg & Source/afu/rtl: files for other part of afu, which are based on the design of https://github.com/mbrobbel/capi-streaming-framework<br>
Sources/afu/ip_xxx: files for the Vivado ip cores

Steps to build the .dat file:
----
The steps below should be done on a linux computer with software Vivado:
```bash
git clone https://github.com/ChenJianyunp/Unum_matrix_multiplier.git
cd ./Unum_matrix_multiplier/
source /opt/applics/bin/xilinx-vivado-2017.1.sh
```
Move the b_route_design.dcp file you need to the folder ./Checkpoint<br>
Modify and add files (if you want to do some change on this design)<br>
Modify ./Source/prj/psl_fpga.prj (if you add or delete some fiels)<br>
```bash
vivado -mode batch -source psl_fpga.tcl -notrace
vivado -mode batch -source write_bitstream.tcl -notrace
```
The steps below should be done on TACC x86 node:
Move the psl_fpga.bit file to TACC server (x86)
``` bash
source /tools/x86_64/xilinx/Vivado/2016.1/settings64.sh
/tools/x86_64/capi_flash/x86_files/create_flash_file.sh psl_fpga.bit
```
And you will see the .dat file in the folder "output"

Steps to flash the fpga (on TACC PowerPC):
----
```bash
sudo /tools/ppc_64/capi_flash/capi-flash-fpga.sh psl_fpga.dat
````
Choose card0 (Alpha-data Xilinx 7)<br>
WARNING: each time, after flashing, it doesn't work when you run the host program at the first time, it will return "respond count: 2", just "ctrl + c" to kill it and run again.  
Remind: please choose card1 if you use Atera Nallatech 5SGXMA7H2F35C2

Steps to run the host software (on TACC PowerPC):
----
```bash
export LD_LIBRARY_PATH=/tools/ppc_64/libcxl
export C_INCLUDE_PATH=/tools/ppc_64/libcxl
export CPLUS_INCLUDE_PATH=/tools/ppc_64/libcxl
cd ./Unum_matrix_multiplier/host
g++ example.cpp -o example -I /tools/ppc_64/libcxl -L /tools/ppc_64/libcxl -lcxl
./example
```
Citations to this Posit number design
----
You may cite this work by referring to the following paper:<br>
A Matrix-Multiply Unit for Posits in Reconfigurable Logic Using (Open)CAPI, to appear in the proceedings of CoNGA 2018

If you have some questions or advices, please contact Jianyu Chen, Delft University of Technology, the Netherlands, at chenjy0046@gmail.com 

The authors acknowledge the Texas Advanced Computing Center (TACC) at The University of Texas at Austin for providing HPC resources that have contributed to the research results reported within this project. URL: http://www.tacc.utexas.edu <br>

WARNING: this design is under test now, there may be some update soon
