#$kSamplingPeriod
# Disable timing analysis for clock domain crossing dedicated modules
set_false_path -through [get_pins -filter {NAME =~ *SyncAsync*/oSyncStages_reg[*]/D} -hier]
set_false_path -through [get_pins -filter {NAME =~ *SyncAsync*/oSyncStages*/PRE || NAME =~ *SyncAsync*/oSyncStages*/CLR} -hier]

set_false_path -through [get_pins -filter {NAME =~ *InstHandshake*/*/CLR} -hier]
set_false_path -from [get_cells -hier -filter {NAME =~ *InstHandshake*/iData_int_reg[*]}] -to [get_cells -hier -filter {NAME=~ *InstHandshake*/oData_reg[*]}]

# Disable timing analysis on the InstADC_ClkODDR primitive reset input. 
set_false_path -rise_from [get_pins -hier -filter {NAME =~ *InstADC_InClkReset*/SyncAsyncx/oSyncStages_reg[1]/C}] -fall_to [get_pins -hier -filter {NAME=~ *InstADC_ClkODDR*/R}]


#
create_generated_clock -name ZmodAdcClkIn -source [get_pins InstADC_ClkODDR/C] -add -master_clock [get_clocks -of [get_ports ADC_InClk]] -divide_by 1 [get_ports ZmodAdcClkIn_p]

#DCO Clock period  
set tDCO [get_property CLKIN1_PERIOD [get_cells InstDataPath/MMCME2_ADV_inst]];   
set tDCO_half [expr $tDCO/2];
create_clock -period $tDCO -name ZmodDcoClk -waveform "0.000 $tDCO_half" [get_ports ZmodDcoClk -prop_thru_buffers]

#Specify timing parameters for AD9648 in CMOS mode
set tskew_max 1.000;
#For kSamplingPeriod values smaller than 10000 ps, use:
#set tskew_max 0.600;     

set tskew_min  -1.200;
#For kSamplingPeriod values smaller than 10000 ps, use:
#set tskew_min  -0.720;

#Reg 0x17 setting 
set OutputDelay  1.12;     

set net_delay_dcoclk 0.623;

set net_delay_d0 0.558;
set net_delay_d1 0.586;
set net_delay_d2 0.595;
set net_delay_d3 0.592;
set net_delay_d4 0.599;
set net_delay_d5 0.608;
set net_delay_d6 0.623;
set net_delay_d7 0.577;
set net_delay_d8 0.620;
set net_delay_d9 0.617;
set net_delay_d10 0.617;
set net_delay_d11 0.554;
set net_delay_d12 0.569;
set net_delay_d13 0.559;

set_input_delay -clock [get_clocks ZmodDcoClk] -clock_fall -min [expr $tskew_min + $net_delay_d0 - $OutputDelay - $net_delay_dcoclk] [get_ports {dZmodADC_Data[0]} -prop_thru_buffers]
set_input_delay -clock [get_clocks ZmodDcoClk] -clock_fall -max [expr $tskew_max + $net_delay_d0 - $OutputDelay - $net_delay_dcoclk] [get_ports {dZmodADC_Data[0]} -prop_thru_buffers]
set_input_delay -clock [get_clocks ZmodDcoClk] -min -add_delay [expr $tskew_min + $net_delay_d0 - $OutputDelay - $net_delay_dcoclk] [get_ports {dZmodADC_Data[0]} -prop_thru_buffers]
set_input_delay -clock [get_clocks ZmodDcoClk] -max -add_delay [expr $tskew_max + $net_delay_d0 - $OutputDelay - $net_delay_dcoclk] [get_ports {dZmodADC_Data[0]} -prop_thru_buffers]

set_input_delay -clock [get_clocks ZmodDcoClk] -clock_fall -min [expr $tskew_min + $net_delay_d1 - $OutputDelay - $net_delay_dcoclk] [get_ports {dZmodADC_Data[1]} -prop_thru_buffers]
set_input_delay -clock [get_clocks ZmodDcoClk] -clock_fall -max [expr $tskew_max + $net_delay_d1 - $OutputDelay - $net_delay_dcoclk] [get_ports {dZmodADC_Data[1]} -prop_thru_buffers]
set_input_delay -clock [get_clocks ZmodDcoClk] -min -add_delay [expr $tskew_min + $net_delay_d1 - $OutputDelay - $net_delay_dcoclk] [get_ports {dZmodADC_Data[1]} -prop_thru_buffers]
set_input_delay -clock [get_clocks ZmodDcoClk] -max -add_delay [expr $tskew_max + $net_delay_d1 - $OutputDelay - $net_delay_dcoclk] [get_ports {dZmodADC_Data[1]} -prop_thru_buffers]

set_input_delay -clock [get_clocks ZmodDcoClk] -clock_fall -min [expr $tskew_min + $net_delay_d2 - $OutputDelay - $net_delay_dcoclk] [get_ports {dZmodADC_Data[2]} -prop_thru_buffers]
set_input_delay -clock [get_clocks ZmodDcoClk] -clock_fall -max [expr $tskew_max + $net_delay_d2 - $OutputDelay - $net_delay_dcoclk] [get_ports {dZmodADC_Data[2]} -prop_thru_buffers]
set_input_delay -clock [get_clocks ZmodDcoClk] -min -add_delay [expr $tskew_min + $net_delay_d2 - $OutputDelay - $net_delay_dcoclk] [get_ports {dZmodADC_Data[2]} -prop_thru_buffers]
set_input_delay -clock [get_clocks ZmodDcoClk] -max -add_delay [expr $tskew_max + $net_delay_d2 - $OutputDelay - $net_delay_dcoclk] [get_ports {dZmodADC_Data[2]} -prop_thru_buffers]

set_input_delay -clock [get_clocks ZmodDcoClk] -clock_fall -min [expr $tskew_min + $net_delay_d3 - $OutputDelay - $net_delay_dcoclk] [get_ports {dZmodADC_Data[3]} -prop_thru_buffers]
set_input_delay -clock [get_clocks ZmodDcoClk] -clock_fall -max [expr $tskew_max + $net_delay_d3 - $OutputDelay - $net_delay_dcoclk] [get_ports {dZmodADC_Data[3]} -prop_thru_buffers]
set_input_delay -clock [get_clocks ZmodDcoClk] -min -add_delay [expr $tskew_min + $net_delay_d3 - $OutputDelay - $net_delay_dcoclk] [get_ports {dZmodADC_Data[3]} -prop_thru_buffers]
set_input_delay -clock [get_clocks ZmodDcoClk] -max -add_delay [expr $tskew_max + $net_delay_d3 - $OutputDelay - $net_delay_dcoclk] [get_ports {dZmodADC_Data[3]} -prop_thru_buffers]

set_input_delay -clock [get_clocks ZmodDcoClk] -clock_fall -min [expr $tskew_min + $net_delay_d4 - $OutputDelay - $net_delay_dcoclk] [get_ports {dZmodADC_Data[4]} -prop_thru_buffers]
set_input_delay -clock [get_clocks ZmodDcoClk] -clock_fall -max [expr $tskew_max + $net_delay_d4 - $OutputDelay - $net_delay_dcoclk] [get_ports {dZmodADC_Data[4]} -prop_thru_buffers]
set_input_delay -clock [get_clocks ZmodDcoClk] -min -add_delay [expr $tskew_min + $net_delay_d4 - $OutputDelay - $net_delay_dcoclk] [get_ports {dZmodADC_Data[4]} -prop_thru_buffers]
set_input_delay -clock [get_clocks ZmodDcoClk] -max -add_delay [expr $tskew_max + $net_delay_d4 - $OutputDelay - $net_delay_dcoclk] [get_ports {dZmodADC_Data[4]} -prop_thru_buffers]

set_input_delay -clock [get_clocks ZmodDcoClk] -clock_fall -min [expr $tskew_min + $net_delay_d5 - $OutputDelay - $net_delay_dcoclk] [get_ports {dZmodADC_Data[5]} -prop_thru_buffers]
set_input_delay -clock [get_clocks ZmodDcoClk] -clock_fall -max [expr $tskew_max + $net_delay_d5 - $OutputDelay - $net_delay_dcoclk] [get_ports {dZmodADC_Data[5]} -prop_thru_buffers]
set_input_delay -clock [get_clocks ZmodDcoClk] -min -add_delay [expr $tskew_min + $net_delay_d5 - $OutputDelay - $net_delay_dcoclk] [get_ports {dZmodADC_Data[5]} -prop_thru_buffers]
set_input_delay -clock [get_clocks ZmodDcoClk] -max -add_delay [expr $tskew_max + $net_delay_d5 - $OutputDelay - $net_delay_dcoclk] [get_ports {dZmodADC_Data[5]} -prop_thru_buffers]

set_input_delay -clock [get_clocks ZmodDcoClk] -clock_fall -min [expr $tskew_min + $net_delay_d6 - $OutputDelay - $net_delay_dcoclk] [get_ports {dZmodADC_Data[6]} -prop_thru_buffers]
set_input_delay -clock [get_clocks ZmodDcoClk] -clock_fall -max [expr $tskew_max + $net_delay_d6 - $OutputDelay - $net_delay_dcoclk] [get_ports {dZmodADC_Data[6]} -prop_thru_buffers]
set_input_delay -clock [get_clocks ZmodDcoClk] -min -add_delay [expr $tskew_min + $net_delay_d6 - $OutputDelay - $net_delay_dcoclk] [get_ports {dZmodADC_Data[6]} -prop_thru_buffers]
set_input_delay -clock [get_clocks ZmodDcoClk] -max -add_delay [expr $tskew_max + $net_delay_d6 - $OutputDelay - $net_delay_dcoclk] [get_ports {dZmodADC_Data[6]} -prop_thru_buffers]

set_input_delay -clock [get_clocks ZmodDcoClk] -clock_fall -min [expr $tskew_min + $net_delay_d7 - $OutputDelay - $net_delay_dcoclk] [get_ports {dZmodADC_Data[7]} -prop_thru_buffers]
set_input_delay -clock [get_clocks ZmodDcoClk] -clock_fall -max [expr $tskew_max + $net_delay_d7 - $OutputDelay - $net_delay_dcoclk] [get_ports {dZmodADC_Data[7]} -prop_thru_buffers]
set_input_delay -clock [get_clocks ZmodDcoClk] -min -add_delay [expr $tskew_min + $net_delay_d7 - $OutputDelay - $net_delay_dcoclk] [get_ports {dZmodADC_Data[7]} -prop_thru_buffers]
set_input_delay -clock [get_clocks ZmodDcoClk] -max -add_delay [expr $tskew_max + $net_delay_d7 - $OutputDelay - $net_delay_dcoclk] [get_ports {dZmodADC_Data[7]} -prop_thru_buffers]

set_input_delay -clock [get_clocks ZmodDcoClk] -clock_fall -min [expr $tskew_min + $net_delay_d8 - $OutputDelay - $net_delay_dcoclk] [get_ports {dZmodADC_Data[8]} -prop_thru_buffers]
set_input_delay -clock [get_clocks ZmodDcoClk] -clock_fall -max [expr $tskew_max + $net_delay_d8 - $OutputDelay - $net_delay_dcoclk] [get_ports {dZmodADC_Data[8]} -prop_thru_buffers]
set_input_delay -clock [get_clocks ZmodDcoClk] -min -add_delay [expr $tskew_min + $net_delay_d8 - $OutputDelay - $net_delay_dcoclk] [get_ports {dZmodADC_Data[8]} -prop_thru_buffers]
set_input_delay -clock [get_clocks ZmodDcoClk] -max -add_delay [expr $tskew_max + $net_delay_d8 - $OutputDelay - $net_delay_dcoclk] [get_ports {dZmodADC_Data[8]} -prop_thru_buffers]

set_input_delay -clock [get_clocks ZmodDcoClk] -clock_fall -min [expr $tskew_min + $net_delay_d9 - $OutputDelay - $net_delay_dcoclk] [get_ports {dZmodADC_Data[9]} -prop_thru_buffers]
set_input_delay -clock [get_clocks ZmodDcoClk] -clock_fall -max [expr $tskew_max + $net_delay_d9 - $OutputDelay - $net_delay_dcoclk] [get_ports {dZmodADC_Data[9]} -prop_thru_buffers]
set_input_delay -clock [get_clocks ZmodDcoClk] -min -add_delay [expr $tskew_min + $net_delay_d9 - $OutputDelay - $net_delay_dcoclk] [get_ports {dZmodADC_Data[9]} -prop_thru_buffers]
set_input_delay -clock [get_clocks ZmodDcoClk] -max -add_delay [expr $tskew_max + $net_delay_d9 - $OutputDelay - $net_delay_dcoclk] [get_ports {dZmodADC_Data[9]} -prop_thru_buffers]

set_input_delay -clock [get_clocks ZmodDcoClk] -clock_fall -min [expr $tskew_min + $net_delay_d10 - $OutputDelay - $net_delay_dcoclk] [get_ports {dZmodADC_Data[10]} -prop_thru_buffers]
set_input_delay -clock [get_clocks ZmodDcoClk] -clock_fall -max [expr $tskew_max + $net_delay_d10 - $OutputDelay - $net_delay_dcoclk] [get_ports {dZmodADC_Data[10]} -prop_thru_buffers]
set_input_delay -clock [get_clocks ZmodDcoClk] -min -add_delay [expr $tskew_min + $net_delay_d10 - $OutputDelay - $net_delay_dcoclk] [get_ports {dZmodADC_Data[10]} -prop_thru_buffers]
set_input_delay -clock [get_clocks ZmodDcoClk] -max -add_delay [expr $tskew_max + $net_delay_d10 - $OutputDelay - $net_delay_dcoclk] [get_ports {dZmodADC_Data[10]} -prop_thru_buffers]

set_input_delay -clock [get_clocks ZmodDcoClk] -clock_fall -min [expr $tskew_min + $net_delay_d11 - $OutputDelay - $net_delay_dcoclk] [get_ports {dZmodADC_Data[11]} -prop_thru_buffers]
set_input_delay -clock [get_clocks ZmodDcoClk] -clock_fall -max [expr $tskew_max + $net_delay_d11 - $OutputDelay - $net_delay_dcoclk] [get_ports {dZmodADC_Data[11]} -prop_thru_buffers]
set_input_delay -clock [get_clocks ZmodDcoClk] -min -add_delay [expr $tskew_min + $net_delay_d11 - $OutputDelay - $net_delay_dcoclk] [get_ports {dZmodADC_Data[11]} -prop_thru_buffers]
set_input_delay -clock [get_clocks ZmodDcoClk] -max -add_delay [expr $tskew_max + $net_delay_d11 - $OutputDelay - $net_delay_dcoclk] [get_ports {dZmodADC_Data[11]} -prop_thru_buffers]

set_input_delay -clock [get_clocks ZmodDcoClk] -clock_fall -min [expr $tskew_min + $net_delay_d12 - $OutputDelay - $net_delay_dcoclk] [get_ports {dZmodADC_Data[12]} -prop_thru_buffers]
set_input_delay -clock [get_clocks ZmodDcoClk] -clock_fall -max [expr $tskew_max + $net_delay_d12 - $OutputDelay - $net_delay_dcoclk] [get_ports {dZmodADC_Data[12]} -prop_thru_buffers]
set_input_delay -clock [get_clocks ZmodDcoClk] -min -add_delay [expr $tskew_min + $net_delay_d12 - $OutputDelay - $net_delay_dcoclk] [get_ports {dZmodADC_Data[12]} -prop_thru_buffers]
set_input_delay -clock [get_clocks ZmodDcoClk] -max -add_delay [expr $tskew_max + $net_delay_d12 - $OutputDelay - $net_delay_dcoclk] [get_ports {dZmodADC_Data[12]} -prop_thru_buffers]

set_input_delay -clock [get_clocks ZmodDcoClk] -clock_fall -min [expr $tskew_min + $net_delay_d13 - $OutputDelay - $net_delay_dcoclk] [get_ports {dZmodADC_Data[13]} -prop_thru_buffers]
set_input_delay -clock [get_clocks ZmodDcoClk] -clock_fall -max [expr $tskew_max + $net_delay_d13 - $OutputDelay - $net_delay_dcoclk] [get_ports {dZmodADC_Data[13]} -prop_thru_buffers]
set_input_delay -clock [get_clocks ZmodDcoClk] -min -add_delay [expr $tskew_min + $net_delay_d13 - $OutputDelay - $net_delay_dcoclk] [get_ports {dZmodADC_Data[13]} -prop_thru_buffers]
set_input_delay -clock [get_clocks ZmodDcoClk] -max -add_delay [expr $tskew_max + $net_delay_d13 - $OutputDelay - $net_delay_dcoclk] [get_ports {dZmodADC_Data[13]} -prop_thru_buffers]

set_false_path -fall_from [get_pins -hier -filter {NAME =~ *InstADC_InClkReset*/SyncAsyncx/oSyncStages_reg[1]/C}] -to [get_pins -hier -filter {NAME=~ *InstADC_ClkODDR*/R}]
set_false_path -rise_from [get_pins -hier -filter {NAME =~ *InstADC_InClkReset*/SyncAsyncx/oSyncStages_reg[1]/C}] -fall_to [get_pins -hier -filter {NAME=~ *InstADC_ClkODDR*/R}]
set_false_path -setup -rise_from [get_pins -hier -filter {NAME =~ *InstADC_InClkReset*/SyncAsyncx/oSyncStages_reg[1]/C}] -fall_to [get_pins -hier -filter {NAME=~ *InstADC_ClkODDR*/R}]
