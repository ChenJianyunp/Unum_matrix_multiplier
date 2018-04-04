#Floorplan
create_pblock afu0
add_cells_to_pblock [get_pblocks afu0] [get_cells -quiet [list a0]]
resize_pblock [get_pblocks afu0] -add {CLOCKREGION_X0Y0:CLOCKREGION_X1Y6}
resize_pblock [get_pblocks afu0] -add {RAMB36_X0Y0:RAMB36_X3Y99}
resize_pblock [get_pblocks afu0] -add {RAMB18_X0Y0:RAMB18_X3Y199}
resize_pblock [get_pblocks afu0] -add {SLICE_X0Y0:SLICE_X51Y499}
resize_pblock [get_pblocks afu0] -add {DSP48_X0Y0:DSP48_X2Y199}

#Enable Config Frame Checking
set_property POST_CRC ENABLE [current_design]
set_property POST_CRC_ACTION HALT [current_design]
set_property POST_CRC_FREQ 50 [current_design]
set_property POST_CRC_INIT_FLAG ENABLE [current_design]
set_property POST_CRC_SOURCE PRE_COMPUTED [current_design]

set_property BITSTREAM.CONFIG.OVERTEMPPOWERDOWN ENABLE [current_design]

# SelectMap port must not persist after configuration
set_property BITSTREAM.CONFIG.PERSIST {No} [ current_design ]
set_property BITSTREAM.GENERAL.COMPRESS {True} [ current_design]

# Configuration from G18 Flash as per XAPP587
set_property BITSTREAM.STARTUP.STARTUPCLK {Cclk} [ current_design ]
set_property BITSTREAM.CONFIG.BPI_1ST_READ_CYCLE {1} [ current_design ]
set_property BITSTREAM.CONFIG.BPI_PAGE_SIZE {1} [ current_design ]
set_property BITSTREAM.CONFIG.BPI_SYNC_MODE {Type1} [ current_design ]
set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN {div-1} [ current_design ]
set_property BITSTREAM.CONFIG.CONFIGRATE {3} [ current_design ]
# Set CFGBVS to GND to match schematics
set_property CFGBVS {GND} [ current_design ]
# Set CONFIG_VOLTAGE to 1.8V to match schematics
set_property CONFIG_VOLTAGE {1.8} [ current_design ]
