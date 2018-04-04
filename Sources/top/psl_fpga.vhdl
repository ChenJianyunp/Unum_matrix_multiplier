-- *! (C) Copyright 2014 International Business Machines

library ieee, work;
use ieee.std_logic_1164.all;
--use work.std_ulogic_function_support.all;
--use work.std_ulogic_support.all;
--use work.std_ulogic_unsigned.all;

ENTITY psl_fpga IS
  PORT(
       -- flash bus
       o_flash_oen: out std_logic;
       o_flash_wen: out std_logic;
       o_flash_rstn: out std_logic;
       o_flash_a: out std_logic_vector(1 to 26);
       o_flash_advn: out std_logic;
       b_flash_dq: inout std_logic_vector(0 to 15);
       o_flash_cen: out std_logic;

       -- PTMON PMBUS
       b_basei2c_scl: inout std_logic;                                       -- clock
       b_basei2c_sda: inout std_logic;                                       -- data
       i_cable_present: in std_logic;                                        -- detect external cable low active
       b_vpdi2c_scl: inout std_logic;
       b_vpdi2c_sda: inout std_logic;
      
       -- pci interface
       pci_pi_nperst0: in std_logic;                                         -- Active low reset from the PCIe reset pin of the device
       pci_pi_refclk_p0: in std_logic;                                       -- 100MHz Refclk
       pci_pi_refclk_n0: in std_logic;                                       -- 100MHz Refclk
       
       -- Xilinx requires both pins of differential transceivers
       pci0_i_rxp_in0: in std_logic;
       pci0_i_rxn_in0: in std_logic;
       pci0_i_rxp_in1: in std_logic;
       pci0_i_rxn_in1: in std_logic;
       pci0_i_rxp_in2: in std_logic;
       pci0_i_rxn_in2: in std_logic;
       pci0_i_rxp_in3: in std_logic;
       pci0_i_rxn_in3: in std_logic;
       pci0_i_rxp_in4: in std_logic;
       pci0_i_rxn_in4: in std_logic;
       pci0_i_rxp_in5: in std_logic;
       pci0_i_rxn_in5: in std_logic;
       pci0_i_rxp_in6: in std_logic;
       pci0_i_rxn_in6: in std_logic;
       pci0_i_rxp_in7: in std_logic;
       pci0_i_rxn_in7: in std_logic;
       pci0_o_txp_out0: out std_logic;
       pci0_o_txn_out0: out std_logic;
       pci0_o_txp_out1: out std_logic;
       pci0_o_txn_out1: out std_logic;
       pci0_o_txp_out2: out std_logic;
       pci0_o_txn_out2: out std_logic;
       pci0_o_txp_out3: out std_logic;
       pci0_o_txn_out3: out std_logic;
       pci0_o_txp_out4: out std_logic;
       pci0_o_txn_out4: out std_logic;
       pci0_o_txp_out5: out std_logic;
       pci0_o_txn_out5: out std_logic;
       pci0_o_txp_out6: out std_logic;
       pci0_o_txn_out6: out std_logic;
       pci0_o_txp_out7: out std_logic;
       pci0_o_txn_out7: out std_logic;
       o_debug: out std_logic_vector(0 to 3));

       attribute secure_config : string;
       attribute secure_config of psl_fpga : entity is "PROTECT";
       attribute secure_netlist : string;       
       attribute secure_netlist of psl_fpga : entity is "ENCRYPT";
END psl_fpga;



ARCHITECTURE psl_fpga OF psl_fpga IS

Component psl_accel
  PORT(
       -- Accelerator Command Interface
       ah_cvalid: out std_ulogic;                                            -- A valid command is present
       ah_ctag: out std_ulogic_vector(0 to 7);                               -- request id
       ah_com: out std_ulogic_vector(0 to 12);                               -- command PSL will execute
       ah_cpad: out std_ulogic_vector(0 to 2);                               -- prefetch attributes
       ah_cabt: out std_ulogic_vector(0 to 2);                               -- abort if translation intr is generated
       ah_cea: out std_ulogic_vector(0 to 63);                               -- Effective byte address for command
       ah_cch: out std_ulogic_vector(0 to 15);                               -- Context Handle
       ah_csize: out std_ulogic_vector(0 to 11);                             -- Number of bytes
       ha_croom: in std_ulogic_vector(0 to 7);                               -- Commands PSL is prepared to accept
       
       -- command parity
       ah_ctagpar: out std_ulogic;
       ah_compar: out std_ulogic;
       ah_ceapar: out std_ulogic;
       
       -- Accelerator Buffer Interfaces
       ha_brvalid: in std_ulogic;                                            -- A read transfer is present
       ha_brtag: in std_ulogic_vector(0 to 7);                               -- Accelerator generated ID for read
       ha_brad: in std_ulogic_vector(0 to 5);                                -- half line index of read data
       ah_brlat: out std_ulogic_vector(0 to 3);                              -- Read data ready latency
       ah_brdata: out std_ulogic_vector(0 to 511);                           -- Read data
       ah_brpar: out std_ulogic_vector(0 to 7);                              -- Read data parity
       ha_bwvalid: in std_ulogic;                                            -- A write data transfer is present
       ha_bwtag: in std_ulogic_vector(0 to 7);                               -- Accelerator ID of the write
       ha_bwad: in std_ulogic_vector(0 to 5);                                -- half line index of write data
       ha_bwdata: in std_ulogic_vector(0 to 511);                            -- Write data
       ha_bwpar: in std_ulogic_vector(0 to 7);                               -- Write data parity
       
       -- buffer tag parity
       ha_brtagpar: in std_ulogic;
       ha_bwtagpar: in std_ulogic;
       
       -- PSL Response Interface
       ha_rvalid: in std_ulogic;                                             --A response is present
       ha_rtag: in std_ulogic_vector(0 to 7);                                --Accelerator generated request ID
       ha_response: in std_ulogic_vector(0 to 7);                            --response code
       ha_rcredits: in std_ulogic_vector(0 to 8);                            --twos compliment number of credits
       ha_rcachestate: in std_ulogic_vector(0 to 1);                         --Resultant Cache State
       ha_rcachepos: in std_ulogic_vector(0 to 12);                          --Cache location id
       ha_rtagpar: in std_ulogic;
       
       -- MMIO Interface
       ha_mmval: in std_ulogic;                                              -- A valid MMIO is present
       ha_mmrnw: in std_ulogic;                                              -- 1 = read, 0 = write
       ha_mmdw: in std_ulogic;                                               -- 1 = doubleword, 0 = word
       ha_mmad: in std_ulogic_vector(0 to 23);                               -- mmio address
       ha_mmdata: in std_ulogic_vector(0 to 63);                             -- Write data
       ha_mmcfg: in std_ulogic;                                              -- mmio is to afu descriptor space
       ah_mmack: out std_ulogic;                                             -- Write is complete or Read is valid pulse
       ah_mmdata: out std_ulogic_vector(0 to 63);                            -- Read data
       
       -- mmio parity
       ha_mmadpar: in std_ulogic;
       ha_mmdatapar: in std_ulogic;
       ah_mmdatapar: out std_ulogic;
       
       -- Accelerator Control Interface
       ha_jval: in std_ulogic;                                               -- A valid job control command is present
       ha_jcom: in std_ulogic_vector(0 to 7);                                -- Job control command opcode
       ha_jea: in std_ulogic_vector(0 to 63);                                -- Save/Restore address
       ah_jrunning: out std_ulogic;                                          -- Accelerator is running level
       ah_jdone: out std_ulogic;                                             -- Accelerator is finished pulse
       ah_jcack: out std_ulogic;                                             -- Accelerator is with context llcmd pulse
       ah_jerror: out std_ulogic_vector(0 to 63);                            -- Accelerator error code. 0 = success
       ah_tbreq: out std_ulogic;                                             -- Timebase request pulse
       ah_jyield: out std_ulogic;                                            -- Accelerator wants to stop
       ha_jeapar: in std_ulogic;
       ha_jcompar: in std_ulogic;
       ah_paren: out std_ulogic;
       ha_pclock: in std_ulogic);
End Component psl_accel;

Component base_img
  PORT(
       -- flash bus
       o_flash_oen: out std_logic;
       o_flash_wen: out std_logic;
       o_flash_rstn: out std_logic;
       o_flash_a: out std_logic_vector(1 to 26);
       o_flash_advn: out std_logic;
       b_flash_dq: inout std_logic_vector(0 to 15);
       o_flash_cen: out std_logic;

       -- PTMON PMBUS
       b_basei2c_scl: inout std_logic;                                       -- clock
       b_basei2c_sda: inout std_logic;                                       -- data
       i_cable_present: in std_logic;                                        -- detect external cable low active
       b_vpdi2c_scl: inout std_logic;
       b_vpdi2c_sda: inout std_logic;

       -- pci interface
       pci_pi_nperst0: in std_logic;                                         -- Active low reset from the PCIe reset pin of the device
       pci_pi_refclk_p0: in std_logic;                                       -- 100MHz Refclk
       pci_pi_refclk_n0: in std_logic;                                       -- 100MHz Refclk

       -- Xilinx requires both pins of differential transceivers
       pci0_i_rxp_in0: in std_logic;
       pci0_i_rxn_in0: in std_logic;
       pci0_i_rxp_in1: in std_logic;
       pci0_i_rxn_in1: in std_logic;
       pci0_i_rxp_in2: in std_logic;
       pci0_i_rxn_in2: in std_logic;
       pci0_i_rxp_in3: in std_logic;
       pci0_i_rxn_in3: in std_logic;
       pci0_i_rxp_in4: in std_logic;
       pci0_i_rxn_in4: in std_logic;
       pci0_i_rxp_in5: in std_logic;
       pci0_i_rxn_in5: in std_logic;
       pci0_i_rxp_in6: in std_logic;
       pci0_i_rxn_in6: in std_logic;
       pci0_i_rxp_in7: in std_logic;
       pci0_i_rxn_in7: in std_logic;
       pci0_o_txp_out0: out std_logic;
       pci0_o_txn_out0: out std_logic;
       pci0_o_txp_out1: out std_logic;
       pci0_o_txn_out1: out std_logic;
       pci0_o_txp_out2: out std_logic;
       pci0_o_txn_out2: out std_logic;
       pci0_o_txp_out3: out std_logic;
       pci0_o_txn_out3: out std_logic;
       pci0_o_txp_out4: out std_logic;
       pci0_o_txn_out4: out std_logic;
       pci0_o_txp_out5: out std_logic;
       pci0_o_txn_out5: out std_logic;
       pci0_o_txp_out6: out std_logic;
       pci0_o_txn_out6: out std_logic;
       pci0_o_txp_out7: out std_logic;
       pci0_o_txn_out7: out std_logic;

       a0h_cvalid: in std_ulogic;
       a0h_ctag: in std_ulogic_vector(0 to 7);
       a0h_com: in std_ulogic_vector(0 to 12);
       a0h_cpad: in std_ulogic_vector(0 to 2);
       a0h_cabt: in std_ulogic_vector(0 to 2);
       a0h_cea: in std_ulogic_vector(0 to 63);
       a0h_cch: in std_ulogic_vector(0 to 15);
       a0h_csize: in std_ulogic_vector(0 to 11);
       ha0_croom: out std_ulogic_vector(0 to 7);
       a0h_ctagpar: in std_ulogic;
       a0h_compar: in std_ulogic;
       a0h_ceapar: in std_ulogic;
       ha0_brvalid: out std_ulogic;
       ha0_brtag: out std_ulogic_vector(0 to 7);
       ha0_brad: out std_ulogic_vector(0 to 5);
       a0h_brlat: in std_ulogic_vector(0 to 3);
       a0h_brdata: in std_ulogic_vector(0 to 511);
       a0h_brpar: in std_ulogic_vector(0 to 7);
       ha0_bwvalid: out std_ulogic;
       ha0_bwtag: out std_ulogic_vector(0 to 7);
       ha0_bwad: out std_ulogic_vector(0 to 5);
       ha0_bwdata: out std_ulogic_vector(0 to 511);
       ha0_bwpar: out std_ulogic_vector(0 to 7);
       ha0_brtagpar: out std_ulogic;
       ha0_bwtagpar: out std_ulogic;
       ha0_rvalid: out std_ulogic;
       ha0_rtag: out std_ulogic_vector(0 to 7);
       ha0_response: out std_ulogic_vector(0 to 7);
       ha0_rcredits: out std_ulogic_vector(0 to 8);
       ha0_rcachestate: out std_ulogic_vector(0 to 1);
       ha0_rcachepos: out std_ulogic_vector(0 to 12);
       ha0_rtagpar: out std_ulogic;
       ha0_mmval: out std_ulogic;
       ha0_mmrnw: out std_ulogic;
       ha0_mmdw: out std_ulogic;
       ha0_mmad: out std_ulogic_vector(0 to 23);
       ha0_mmdata: out std_ulogic_vector(0 to 63);
       ha0_mmcfg: out std_ulogic;
       a0h_mmack: in std_ulogic;
       a0h_mmdata: in std_ulogic_vector(0 to 63);
       ha0_mmadpar: out std_ulogic;
       ha0_mmdatapar: out std_ulogic;
       a0h_mmdatapar: in std_ulogic;
       ha0_jval: out std_ulogic;
       ha0_jcom: out std_ulogic_vector(0 to 7);
       ha0_jea: out std_ulogic_vector(0 to 63);
       a0h_jrunning: in std_ulogic;
       a0h_jdone: in std_ulogic;
       a0h_jcack: in std_ulogic;
       a0h_jerror: in std_ulogic_vector(0 to 63);
       a0h_tbreq: in std_ulogic;
       a0h_jyield: in std_ulogic;
       ha0_jeapar: out std_ulogic;
       ha0_jcompar: out std_ulogic;
       a0h_paren: in std_ulogic;
       ha0_pclock: out std_ulogic;
       gold_factory: in std_ulogic);

END Component base_img;

Signal a0h_brdata: std_ulogic_vector(0 to 511);  -- hline
Signal a0h_brlat: std_ulogic_vector(0 to 3);  -- v4bit
Signal a0h_brpar: std_ulogic_vector(0 to 7);  -- v8bit
Signal a0h_cabt: std_ulogic_vector(0 to 2);  -- cabt
Signal a0h_cch: std_ulogic_vector(0 to 15);  -- ctxhndl
Signal a0h_cea: std_ulogic_vector(0 to 63);  -- ead
Signal a0h_ceapar: std_ulogic;  -- bool
Signal a0h_com: std_ulogic_vector(0 to 12);  -- apcmd
Signal a0h_compar: std_ulogic;  -- bool
Signal a0h_cpad: std_ulogic_vector(0 to 2);  -- pade
Signal a0h_csize: std_ulogic_vector(0 to 11);  -- v12bit
Signal a0h_ctag: std_ulogic_vector(0 to 7);  -- acctag
Signal a0h_ctagpar: std_ulogic;  -- bool
Signal a0h_cvalid: std_ulogic;  -- bool
Signal a0h_jcack: std_ulogic;  -- bool
Signal a0h_jdone: std_ulogic;  -- bool
Signal a0h_jerror: std_ulogic_vector(0 to 63);  -- v64bit
Signal a0h_jrunning: std_ulogic;  -- bool
Signal a0h_jyield: std_ulogic;  -- bool
Signal a0h_mmack: std_ulogic;  -- bool
Signal a0h_mmdata: std_ulogic_vector(0 to 63);  -- v64bit
Signal a0h_mmdatapar: std_ulogic;  -- bool
Signal a0h_paren: std_ulogic;  -- bool
Signal a0h_tbreq: std_ulogic;  -- bool
Signal gold_factory: std_ulogic; --bool  Leave as 0 to indicate factory image. Set to 1 to indicate user image space.
Signal ha0_brad: std_ulogic_vector(0 to 5);  -- v6bit
Signal ha0_brtag: std_ulogic_vector(0 to 7);  -- acctag
Signal ha0_brtagpar: std_ulogic;  -- bool
Signal ha0_brvalid: std_ulogic;  -- bool
Signal ha0_bwad: std_ulogic_vector(0 to 5);  -- v6bit
Signal ha0_bwdata: std_ulogic_vector(0 to 511);  -- hline
Signal ha0_bwpar: std_ulogic_vector(0 to 7);  -- v8bit
Signal ha0_bwtag: std_ulogic_vector(0 to 7);  -- acctag
Signal ha0_bwtagpar: std_ulogic;  -- bool
Signal ha0_bwvalid: std_ulogic;  -- bool
Signal ha0_croom: std_ulogic_vector(0 to 7);  -- v8bit
Signal ha0_jcom: std_ulogic_vector(0 to 7);  -- jbcom
Signal ha0_jcompar: std_ulogic;  -- bool
Signal ha0_jea: std_ulogic_vector(0 to 63);  -- v64bit
Signal ha0_jeapar: std_ulogic;  -- bool
Signal ha0_jval: std_ulogic;  -- bool
Signal ha0_mmad: std_ulogic_vector(0 to 23);  -- v24bit
Signal ha0_mmadpar: std_ulogic;  -- bool
Signal ha0_mmcfg: std_ulogic;  -- bool
Signal ha0_mmdata: std_ulogic_vector(0 to 63);  -- v64bit
Signal ha0_mmdatapar: std_ulogic;  -- bool
Signal ha0_mmdw: std_ulogic;  -- bool
Signal ha0_mmrnw: std_ulogic;  -- bool
Signal ha0_mmval: std_ulogic;  -- bool
Signal ha0_pclock: std_ulogic;  -- bool
Signal ha0_rcachepos: std_ulogic_vector(0 to 12);  -- v13bit
Signal ha0_rcachestate: std_ulogic_vector(0 to 1);  -- statespec
Signal ha0_rcredits: std_ulogic_vector(0 to 8);  -- v9bit
Signal ha0_response: std_ulogic_vector(0 to 7);  -- apresp
Signal ha0_rtag: std_ulogic_vector(0 to 7);  -- acctag
Signal ha0_rtagpar: std_ulogic;  -- bool
Signal ha0_rvalid: std_ulogic;  -- bool

begin

     a0: psl_accel
      PORT MAP (
         ah_cvalid => a0h_cvalid,
         ah_ctag => a0h_ctag,
         ah_com => a0h_com,
         ah_cpad => a0h_cpad,
         ah_cabt => a0h_cabt,
         ah_cea => a0h_cea,
         ah_cch => a0h_cch,
         ah_csize => a0h_csize,
         ha_croom => ha0_croom,
         ah_ctagpar => a0h_ctagpar,
         ah_compar => a0h_compar,
         ah_ceapar => a0h_ceapar,
         ha_brvalid => ha0_brvalid,
         ha_brtag => ha0_brtag,
         ha_brad => ha0_brad,
         ah_brlat => a0h_brlat,
         ah_brdata => a0h_brdata,
         ah_brpar => a0h_brpar,
         ha_bwvalid => ha0_bwvalid,
         ha_bwtag => ha0_bwtag,
         ha_bwad => ha0_bwad,
         ha_bwdata => ha0_bwdata,
         ha_bwpar => ha0_bwpar,
         ha_brtagpar => ha0_brtagpar,
         ha_bwtagpar => ha0_bwtagpar,
         ha_rvalid => ha0_rvalid,
         ha_rtag => ha0_rtag,
         ha_response => ha0_response,
         ha_rcredits => ha0_rcredits,
         ha_rcachestate => ha0_rcachestate,
         ha_rcachepos => ha0_rcachepos,
         ha_rtagpar => ha0_rtagpar,
         ha_mmval => ha0_mmval,
         ha_mmrnw => ha0_mmrnw,
         ha_mmdw => ha0_mmdw,
         ha_mmad => ha0_mmad,
         ha_mmdata => ha0_mmdata,
         ha_mmcfg => ha0_mmcfg,
         ah_mmack => a0h_mmack,
         ah_mmdata => a0h_mmdata,
         ha_mmadpar => ha0_mmadpar,
         ha_mmdatapar => ha0_mmdatapar,
         ah_mmdatapar => a0h_mmdatapar,
         ha_jval => ha0_jval,
         ha_jcom => ha0_jcom,
         ha_jea => ha0_jea,
         ah_jrunning => a0h_jrunning,
         ah_jdone => a0h_jdone,
         ah_jcack => a0h_jcack,
         ah_jerror => a0h_jerror,
         ah_tbreq => a0h_tbreq,
         ah_jyield => a0h_jyield,
         ha_jeapar => ha0_jeapar,
         ha_jcompar => ha0_jcompar,
         ah_paren => a0h_paren,
         ha_pclock => ha0_pclock
    );

    gold_factory <= '1'; --set to 1 to indicate user image. leaving set to 0 will indicate factory image.
    b: base_img
     PORT MAP (
         pci_pi_nperst0 => pci_pi_nperst0,                                
         pci_pi_refclk_p0 => pci_pi_refclk_p0,       
         pci_pi_refclk_n0 => pci_pi_refclk_n0,                                       
         pci0_i_rxp_in0 => pci0_i_rxp_in0,
         pci0_i_rxn_in0 => pci0_i_rxn_in0,
         pci0_i_rxp_in1 => pci0_i_rxp_in1,
         pci0_i_rxn_in1 => pci0_i_rxn_in1,
         pci0_i_rxp_in2 => pci0_i_rxp_in2,
         pci0_i_rxn_in2 => pci0_i_rxn_in2,
         pci0_i_rxp_in3 => pci0_i_rxp_in3,
         pci0_i_rxn_in3 => pci0_i_rxn_in3,
         pci0_i_rxp_in4 => pci0_i_rxp_in4,
         pci0_i_rxn_in4 => pci0_i_rxn_in4,
         pci0_i_rxp_in5 => pci0_i_rxp_in5,
         pci0_i_rxn_in5 => pci0_i_rxn_in5,
         pci0_i_rxp_in6 => pci0_i_rxp_in6,
         pci0_i_rxn_in6 => pci0_i_rxn_in6,
         pci0_i_rxp_in7 => pci0_i_rxp_in7,
         pci0_i_rxn_in7 => pci0_i_rxn_in7,
         pci0_o_txp_out0 => pci0_o_txp_out0,
         pci0_o_txn_out0 => pci0_o_txn_out0,
         pci0_o_txp_out1 => pci0_o_txp_out1,
         pci0_o_txn_out1 => pci0_o_txn_out1,
         pci0_o_txp_out2 => pci0_o_txp_out2,
         pci0_o_txn_out2 => pci0_o_txn_out2,
         pci0_o_txp_out3 => pci0_o_txp_out3,
         pci0_o_txn_out3 => pci0_o_txn_out3,
         pci0_o_txp_out4 => pci0_o_txp_out4,
         pci0_o_txn_out4 => pci0_o_txn_out4,
         pci0_o_txp_out5 => pci0_o_txp_out5,
         pci0_o_txn_out5 => pci0_o_txn_out5,
         pci0_o_txp_out6 => pci0_o_txp_out6,
         pci0_o_txn_out6 => pci0_o_txn_out6,
         pci0_o_txp_out7 => pci0_o_txp_out7,
         pci0_o_txn_out7 => pci0_o_txn_out7,

       -- flash bus
         o_flash_oen => o_flash_oen,
         o_flash_wen => o_flash_wen,
         o_flash_rstn => o_flash_rstn,
         o_flash_a => o_flash_a,
         o_flash_advn => o_flash_advn,
         b_flash_dq => b_flash_dq,
         o_flash_cen => o_flash_cen,

       -- PTMON PMBUS
         b_basei2c_scl => b_basei2c_scl,                                       -- clock
         b_basei2c_sda => b_basei2c_sda,                                       -- data
         i_cable_present => i_cable_present,                                   -- detect external cable low active
         b_vpdi2c_scl => b_vpdi2c_scl,
         b_vpdi2c_sda => b_vpdi2c_sda,

         a0h_cvalid => a0h_cvalid,
         a0h_ctag => a0h_ctag,
         a0h_com => a0h_com,
         a0h_cpad => a0h_cpad,
         a0h_cabt => a0h_cabt,
         a0h_cea => a0h_cea,
         a0h_cch => a0h_cch,
         a0h_csize => a0h_csize,
         ha0_croom => ha0_croom,
         a0h_ctagpar => a0h_ctagpar,
         a0h_compar => a0h_compar,
         a0h_ceapar => a0h_ceapar,
         ha0_brvalid => ha0_brvalid,
         ha0_brtag => ha0_brtag,
         ha0_brad => ha0_brad,
         a0h_brlat => a0h_brlat,
         a0h_brdata => a0h_brdata,
         a0h_brpar => a0h_brpar,
         ha0_bwvalid => ha0_bwvalid,
         ha0_bwtag => ha0_bwtag,
         ha0_bwad => ha0_bwad,
         ha0_bwdata => ha0_bwdata,
         ha0_bwpar => ha0_bwpar,
         ha0_brtagpar => ha0_brtagpar,
         ha0_bwtagpar => ha0_bwtagpar,
         ha0_rvalid => ha0_rvalid,
         ha0_rtag => ha0_rtag,
         ha0_response => ha0_response,
         ha0_rcredits => ha0_rcredits,
         ha0_rcachestate => ha0_rcachestate,
         ha0_rcachepos => ha0_rcachepos,
         ha0_rtagpar => ha0_rtagpar,
         ha0_mmval => ha0_mmval,
         ha0_mmrnw => ha0_mmrnw,
         ha0_mmdw => ha0_mmdw,
         ha0_mmad => ha0_mmad,
         ha0_mmdata => ha0_mmdata,
         ha0_mmcfg => ha0_mmcfg,
         a0h_mmack => a0h_mmack,
         a0h_mmdata => a0h_mmdata,
         ha0_mmadpar => ha0_mmadpar,
         ha0_mmdatapar => ha0_mmdatapar,
         a0h_mmdatapar => a0h_mmdatapar,
         ha0_jval => ha0_jval,
         ha0_jcom => ha0_jcom,
         ha0_jea => ha0_jea,
         a0h_jrunning => a0h_jrunning,
         a0h_jdone => a0h_jdone,
         a0h_jcack => a0h_jcack,
         a0h_jerror => a0h_jerror,
         a0h_tbreq => a0h_tbreq,
         a0h_jyield => a0h_jyield,
         ha0_jeapar => ha0_jeapar,
         ha0_jcompar => ha0_jcompar,
         a0h_paren => a0h_paren,
         ha0_pclock => ha0_pclock,
         gold_factory => gold_factory
    );

END psl_fpga;
