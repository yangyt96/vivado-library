onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -color {Dark Orchid} -radix hexadecimal /axi_dynclk_tb/axi_dynclk_inst/axi_dynclk_S00_AXI_inst/CTRL_REG
add wave -noupdate -color {Dark Orchid} -radix hexadecimal /axi_dynclk_tb/axi_dynclk_inst/axi_dynclk_S00_AXI_inst/STAT_REG
add wave -noupdate -color {Dark Orchid} -radix hexadecimal /axi_dynclk_tb/axi_dynclk_inst/axi_dynclk_S00_AXI_inst/CLK_O_REG
add wave -noupdate -color {Dark Orchid} -radix hexadecimal /axi_dynclk_tb/axi_dynclk_inst/axi_dynclk_S00_AXI_inst/CLK_FB_REG
add wave -noupdate -color {Dark Orchid} -radix hexadecimal /axi_dynclk_tb/axi_dynclk_inst/axi_dynclk_S00_AXI_inst/CLK_FRAC_REG
add wave -noupdate -color {Dark Orchid} -radix hexadecimal /axi_dynclk_tb/axi_dynclk_inst/axi_dynclk_S00_AXI_inst/CLK_DIV_REG
add wave -noupdate -color {Dark Orchid} -radix hexadecimal /axi_dynclk_tb/axi_dynclk_inst/axi_dynclk_S00_AXI_inst/CLK_LOCK_REG
add wave -noupdate -color {Dark Orchid} -radix hexadecimal /axi_dynclk_tb/axi_dynclk_inst/axi_dynclk_S00_AXI_inst/CLK_FLTR_REG
add wave -noupdate -radix hexadecimal /axi_dynclk_tb/runner_cfg
add wave -noupdate -radix hexadecimal /axi_dynclk_tb/s_axi_lite_aclk
add wave -noupdate -radix hexadecimal /axi_dynclk_tb/s_axi_lite_aresetn
add wave -noupdate -expand -subitemconfig {/axi_dynclk_tb/s_axi_lite_if.write_address_channel -expand /axi_dynclk_tb/s_axi_lite_if.write_data_channel -expand /axi_dynclk_tb/s_axi_lite_if.write_response_channel -expand /axi_dynclk_tb/s_axi_lite_if.read_address_channel -expand /axi_dynclk_tb/s_axi_lite_if.read_data_channel -expand} /axi_dynclk_tb/s_axi_lite_if
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {4644588 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 376
configure wave -valuecolwidth 40
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits us
update
WaveRestoreZoom {0 ps} {26426 ps}
