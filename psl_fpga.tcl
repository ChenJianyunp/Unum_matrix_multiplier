###############################################################
###   Tcl Variables
###############################################################
#set tclParams [list <param1> <value> <param2> <value> ... <paramN> <value>]
set tclParams [list hd.visual 1 \
              ]

#Define location for "Tcl" directory. Defaults to "./Tcl"
set tclHome "./Tcl"
if {[file exists $tclHome]} {
   set tclDir $tclHome
} elseif {[file exists "./Tcl"]} {
   set tclDir  "./Tcl"
} else {
   error "ERROR: No valid location found for required Tcl scripts. Set \$tclDir in design.tcl to a valid location."
}

###############################################################
### Define Part, Package, Speedgrade 
###############################################################
set device       "xc7vx690t"
set package      "ffg1157"
set speed        "-2"
set part         $device$package$speed

###############################################################
###  Setup Variables
###############################################################
####flow control
set run.topSynth   1
set run.oocSynth   0
set run.tdImpl     0
set run.oocImpl    0
set run.topImpl    1
set run.flatImpl   0

####Report and DCP controls - values: 0-required min; 1-few extra; 2-all
set verbose      1
set dcpLevel     1

set_param project.enableVHDL2008 1


####Output Directories
set synthDir  "./Synth"
set implDir   "./Implement"
set dcpDir    "./Checkpoint"

####Input Directories
set srcDir     "./Sources"
set pslDir     "$srcDir/psl"
set topDir     "$srcDir/top"
set afuDir     "$srcDir/afu"
set prjDir     "$srcDir/prj"
set xdcDir     "$srcDir/xdc"
set coreDir    "$srcDir/cores"
set netlistDir "$srcDir/netlist"

####Source required Tcl Procs
source $tclDir/design_utils.tcl
source $tclDir/synth_utils.tcl
source $tclDir/impl_utils.tcl
source $tclDir/hd_floorplan_utils.tcl


###############################################################
### Top Definition
###############################################################
set top "psl_fpga"
add_module $top
set_attribute module $top    top_level     1
set_attribute module $top    prj           $prjDir/$top.prj
set_attribute module $top    synth         ${run.topSynth}
set_attribute module $top    synth_options "-flatten_hierarchy rebuilt -fanout_limit 60 -fsm_extraction one_hot -keep_equivalent_registers -resource_sharing off -no_lc -shreg_min_size 5 -no_iobuf"
set_attribute module $top    ip            [list  $afuDir/ip_ram_input1/ram_input1.xci       \
                                                  $afuDir/ip_ram_input2/ram_input2.xci         \
                                                  $afuDir/ip_ram_output/ram_output.xci         \
                                           ]
add_implementation $top
set_attribute impl $top      top           $top
set_attribute impl $top      linkXDC       [list $xdcDir/b_xilinx_capi_pcie_gen3_alphadata_brd.xdc  \             ] 
set_attribute impl $top      impl          ${run.topImpl}
set_attribute impl $top      hd.impl       1
set_attribute impl $top      opt_directive Explore
set_attribute impl $top      place_directive ExtraNetDelay_high
#set_attribute impl $top      place_directive Explore
set_attribute impl $top      phys_directive AggressiveExplore
#set_attribute impl $top      phys_directive Explore
set_attribute impl $top      route_directive Explore
#set_attribute impl $top      phys.pre      [list rerun_phys_opt.tcl                 \
#					   ]

####################################################################
### OOC Module Definition and OOC Implementation for each instance
####################################################################
set module1 "base_img"
add_module $module1
set_attribute module $module1 prj          $prjDir/psl.prj
set_attribute module $module1 synth        ${run.oocSynth}
set_attribute module $module1 synth_options "-flatten_hierarchy rebuilt -fanout_limit 400 -fsm_extraction one_hot -keep_equivalent_registers -resource_sharing off -no_lc -shreg_min_size 5"
set_attribute module $module1 ip           [list $coreDir/tx_wr_fifo/tx_wr_fifo.xci \
                                           $coreDir/pcie3_7x_0/pcie3_7x_0.xci       \
                                           $coreDir/clk_wiz_0/clk_wiz_0.xci         \
                                           ]
set instance "b"
add_ooc_implementation $instance
set_attribute ooc $instance   module       $module1
set_attribute ooc $instance   inst         $instance
set_attribute ooc $instance   hierInst     $instance
set_attribute ooc $instance   implXDC      [list $xdcDir/${instance}_ooc_timing.xdc   \
                                                 $xdcDir/${instance}_ooc_budget.xdc   \
                                                 $xdcDir/${instance}_ooc_optimize.xdc \
                                           ] 
set_attribute ooc $instance   impl         ${run.oocImpl}
set_attribute ooc $instance   preservation routing
set_attribute ooc $instance   opt_directive Explore
set_attribute ooc $instance   place_directive Explore
set_attribute ooc $instance   phys_directive Explore
set_attribute ooc $instance   route_directive Explore
set_attribute ooc $instance   opt.pre      [list read_b_ooc_mcp_const.tcl             \
					   ]
set_attribute ooc $instance   phys.pre     [list rerun_phys_opt.tcl                 \
					   ]
set_attribute ooc $instance   route.pre    [list routed.tcl                         \
                                           ]
set_attribute ooc $instance   route.post   [list post_route.tcl                     \
                                           ]

########################################################################
### Task / flow portion
########################################################################

# Build the designs
source $tclDir/run.tcl

exit
