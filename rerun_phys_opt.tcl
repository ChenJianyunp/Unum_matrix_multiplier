# rerun phys_opt_design a maximum of 5 times
# stop optimization when timing is met or timing no longer improves

for { set i 1 } { $i <= 5 } { incr i } {
    if {$i == 1} {
        phys_opt_design -directive Explore
        #write_checkpoint -force phys_opt_1.dcp
        report_timing_summary -file phys_opt_1.rpt -max_paths 100
    } elseif {$i == 2} {
        phys_opt_design
        #write_checkpoint -force phys_opt_2.dcp
        report_timing_summary -file phys_opt_2.rpt -max_paths 100
    } elseif {$i == 3} {
        phys_opt_design -directive AggressiveExplore
        #write_checkpoint -force phys_opt_3.dcp
        report_timing_summary -file phys_opt_3.rpt -max_paths 100
    } elseif {$i == 4} {
        phys_opt_design -directive AlternateDelayModeling
        #write_checkpoint -force phys_opt_4.dcp
        report_timing_summary -file phys_opt_4.rpt -max_paths 100
    } else {
        phys_opt_design -directive ExploreWithHoldFix
        #write_checkpoint -force phys_opt_5.dcp
        report_timing_summary -file phys_opt_5.rpt -max_paths 100
    }
}         
 
