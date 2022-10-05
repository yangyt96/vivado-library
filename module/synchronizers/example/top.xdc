create_clock -period 100.000 -name OneClk -waveform {0.000 50.000} [get_ports OneClk]
create_clock -period 100.000 -name TwoClk -waveform {1.000 51.000} [get_ports TwoClk]

current_instance -quiet

# Begin scope to SyncAsync instance
current_instance [get_cells SyncAsync1]
# Input to synchronizer ignored for timing analysis
set_false_path -through [get_ports -scoped_to_current_instance aIn]
# Constrain internal synchronizer paths to half-period, which is expected to be easily met with ASYNC_REG=true
set ClkPeriod [get_property PERIOD [get_clocks -of_objects [get_ports -scoped_to_current_instance OutClk]]]
set_max_delay -from [get_cells oSyncStages_reg[*]] -to [get_cells oSyncStages_reg[*]] [expr $ClkPeriod/2]
current_instance -quiet
# End scope to SyncAsync instance

# Begin scope to ResetBridge instance
current_instance [get_cells ResetBridgePos]
 # Reset input to the synchronizer must be ignored for timing analysis
set_false_path -through [get_ports -scoped_to_current_instance aRst]
# Constrain internal synchronizer paths to half-period, which is expected to be easily met with ASYNC_REG=true
set ClkPeriod [get_property PERIOD [get_clocks -of_objects [get_ports -scoped_to_current_instance OutClk]]]
set_max_delay -from [get_cells OutputFF*.SyncAsyncx/oSyncStages_reg[*]] -to [get_cells OutputFF*.SyncAsyncx/oSyncStages_reg[*]] [expr $ClkPeriod/2]
current_instance -quiet
# End scope to ResetBridge instance

# Begin scope to ResetBridge instance
current_instance [get_cells ResetBridgeNeg]
 # Reset input to the synchronizer must be ignored for timing analysis
set_false_path -through [get_ports -scoped_to_current_instance aRst]
# Constrain internal synchronizer paths to half-period, which is expected to be easily met with ASYNC_REG=true
set ClkPeriod [get_property PERIOD [get_clocks -of_objects [get_ports -scoped_to_current_instance OutClk]]]
set_max_delay -from [get_cells OutputFF*.SyncAsyncx/oSyncStages_reg[*]] -to [get_cells OutputFF*.SyncAsyncx/oSyncStages_reg[*]] [expr $ClkPeriod/2]
current_instance -quiet
# End scope to ResetBridge instance

# Begin scope to ResetBridge instance
current_instance [get_cells ResetBridgeBack]
 # Reset input to the synchronizer must be ignored for timing analysis
set_false_path -through [get_ports -scoped_to_current_instance aRst]
# Constrain internal synchronizer paths to half-period, which is expected to be easily met with ASYNC_REG=true
set ClkPeriod [get_property PERIOD [get_clocks -of_objects [get_ports -scoped_to_current_instance OutClk]]]
set_max_delay -from [get_cells OutputFF*.SyncAsyncx/oSyncStages_reg[*]] -to [get_cells OutputFF*.SyncAsyncx/oSyncStages_reg[*]] [expr $ClkPeriod/2]
current_instance -quiet
# End scope to ResetBridge instance

# Replace <InstSyncBase> with path to SyncBase instance, keep rest unchanged
# Begin scope to SyncBase instance
current_instance [get_cells SyncBase]
# Input to synchronizer ignored for timing analysis
set_false_path -through [get_pins SyncAsyncx/aIn]
# Constrain internal synchronizer paths to half-period, which is expected to be easily met with ASYNC_REG=true
set ClkPeriod [get_property PERIOD [get_clocks -of_objects [get_ports -scoped_to_current_instance OutClk]]]
set_max_delay -from [get_cells SyncAsyncx/oSyncStages_reg[*]] -to [get_cells SyncAsyncx/oSyncStages_reg[*]] [expr $ClkPeriod/2]
current_instance -quiet
# End scope to SyncBase instance
