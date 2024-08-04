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
add wave -noupdate -radix hexadecimal -childformat {{/axi_dynclk_tb/rec_axil_dynclk.WriteAddress -radix hexadecimal -childformat {{/axi_dynclk_tb/rec_axil_dynclk.WriteAddress.Valid -radix hexadecimal} {/axi_dynclk_tb/rec_axil_dynclk.WriteAddress.Ready -radix hexadecimal} {/axi_dynclk_tb/rec_axil_dynclk.WriteAddress.Addr -radix hexadecimal} {/axi_dynclk_tb/rec_axil_dynclk.WriteAddress.Prot -radix hexadecimal}}} {/axi_dynclk_tb/rec_axil_dynclk.WriteData -radix hexadecimal -childformat {{/axi_dynclk_tb/rec_axil_dynclk.WriteData.Valid -radix hexadecimal} {/axi_dynclk_tb/rec_axil_dynclk.WriteData.Ready -radix hexadecimal} {/axi_dynclk_tb/rec_axil_dynclk.WriteData.Data -radix hexadecimal} {/axi_dynclk_tb/rec_axil_dynclk.WriteData.Strb -radix hexadecimal}}} {/axi_dynclk_tb/rec_axil_dynclk.WriteResponse -radix hexadecimal -childformat {{/axi_dynclk_tb/rec_axil_dynclk.WriteResponse.Valid -radix hexadecimal} {/axi_dynclk_tb/rec_axil_dynclk.WriteResponse.Ready -radix hexadecimal} {/axi_dynclk_tb/rec_axil_dynclk.WriteResponse.Resp -radix hexadecimal}}} {/axi_dynclk_tb/rec_axil_dynclk.ReadAddress -radix hexadecimal -childformat {{/axi_dynclk_tb/rec_axil_dynclk.ReadAddress.Valid -radix hexadecimal} {/axi_dynclk_tb/rec_axil_dynclk.ReadAddress.Ready -radix hexadecimal} {/axi_dynclk_tb/rec_axil_dynclk.ReadAddress.Addr -radix hexadecimal} {/axi_dynclk_tb/rec_axil_dynclk.ReadAddress.Prot -radix hexadecimal}}} {/axi_dynclk_tb/rec_axil_dynclk.ReadData -radix hexadecimal -childformat {{/axi_dynclk_tb/rec_axil_dynclk.ReadData.Valid -radix hexadecimal} {/axi_dynclk_tb/rec_axil_dynclk.ReadData.Ready -radix hexadecimal} {/axi_dynclk_tb/rec_axil_dynclk.ReadData.Data -radix hexadecimal} {/axi_dynclk_tb/rec_axil_dynclk.ReadData.Resp -radix hexadecimal}}}} -expand -subitemconfig {/axi_dynclk_tb/rec_axil_dynclk.WriteAddress {-height 15 -radix hexadecimal -childformat {{/axi_dynclk_tb/rec_axil_dynclk.WriteAddress.Valid -radix hexadecimal} {/axi_dynclk_tb/rec_axil_dynclk.WriteAddress.Ready -radix hexadecimal} {/axi_dynclk_tb/rec_axil_dynclk.WriteAddress.Addr -radix hexadecimal} {/axi_dynclk_tb/rec_axil_dynclk.WriteAddress.Prot -radix hexadecimal}} -expand} /axi_dynclk_tb/rec_axil_dynclk.WriteAddress.Valid {-height 15 -radix hexadecimal} /axi_dynclk_tb/rec_axil_dynclk.WriteAddress.Ready {-height 15 -radix hexadecimal} /axi_dynclk_tb/rec_axil_dynclk.WriteAddress.Addr {-height 15 -radix hexadecimal} /axi_dynclk_tb/rec_axil_dynclk.WriteAddress.Prot {-height 15 -radix hexadecimal} /axi_dynclk_tb/rec_axil_dynclk.WriteData {-height 15 -radix hexadecimal -childformat {{/axi_dynclk_tb/rec_axil_dynclk.WriteData.Valid -radix hexadecimal} {/axi_dynclk_tb/rec_axil_dynclk.WriteData.Ready -radix hexadecimal} {/axi_dynclk_tb/rec_axil_dynclk.WriteData.Data -radix hexadecimal} {/axi_dynclk_tb/rec_axil_dynclk.WriteData.Strb -radix hexadecimal}} -expand} /axi_dynclk_tb/rec_axil_dynclk.WriteData.Valid {-height 15 -radix hexadecimal} /axi_dynclk_tb/rec_axil_dynclk.WriteData.Ready {-height 15 -radix hexadecimal} /axi_dynclk_tb/rec_axil_dynclk.WriteData.Data {-height 15 -radix hexadecimal} /axi_dynclk_tb/rec_axil_dynclk.WriteData.Strb {-height 15 -radix hexadecimal} /axi_dynclk_tb/rec_axil_dynclk.WriteResponse {-height 15 -radix hexadecimal -childformat {{/axi_dynclk_tb/rec_axil_dynclk.WriteResponse.Valid -radix hexadecimal} {/axi_dynclk_tb/rec_axil_dynclk.WriteResponse.Ready -radix hexadecimal} {/axi_dynclk_tb/rec_axil_dynclk.WriteResponse.Resp -radix hexadecimal}} -expand} /axi_dynclk_tb/rec_axil_dynclk.WriteResponse.Valid {-height 15 -radix hexadecimal} /axi_dynclk_tb/rec_axil_dynclk.WriteResponse.Ready {-height 15 -radix hexadecimal} /axi_dynclk_tb/rec_axil_dynclk.WriteResponse.Resp {-height 15 -radix hexadecimal} /axi_dynclk_tb/rec_axil_dynclk.ReadAddress {-height 15 -radix hexadecimal -childformat {{/axi_dynclk_tb/rec_axil_dynclk.ReadAddress.Valid -radix hexadecimal} {/axi_dynclk_tb/rec_axil_dynclk.ReadAddress.Ready -radix hexadecimal} {/axi_dynclk_tb/rec_axil_dynclk.ReadAddress.Addr -radix hexadecimal} {/axi_dynclk_tb/rec_axil_dynclk.ReadAddress.Prot -radix hexadecimal}} -expand} /axi_dynclk_tb/rec_axil_dynclk.ReadAddress.Valid {-height 15 -radix hexadecimal} /axi_dynclk_tb/rec_axil_dynclk.ReadAddress.Ready {-height 15 -radix hexadecimal} /axi_dynclk_tb/rec_axil_dynclk.ReadAddress.Addr {-height 15 -radix hexadecimal} /axi_dynclk_tb/rec_axil_dynclk.ReadAddress.Prot {-height 15 -radix hexadecimal} /axi_dynclk_tb/rec_axil_dynclk.ReadData {-height 15 -radix hexadecimal -childformat {{/axi_dynclk_tb/rec_axil_dynclk.ReadData.Valid -radix hexadecimal} {/axi_dynclk_tb/rec_axil_dynclk.ReadData.Ready -radix hexadecimal} {/axi_dynclk_tb/rec_axil_dynclk.ReadData.Data -radix hexadecimal} {/axi_dynclk_tb/rec_axil_dynclk.ReadData.Resp -radix hexadecimal}} -expand} /axi_dynclk_tb/rec_axil_dynclk.ReadData.Valid {-height 15 -radix hexadecimal} /axi_dynclk_tb/rec_axil_dynclk.ReadData.Ready {-height 15 -radix hexadecimal} /axi_dynclk_tb/rec_axil_dynclk.ReadData.Data {-height 15 -radix hexadecimal} /axi_dynclk_tb/rec_axil_dynclk.ReadData.Resp {-height 15 -radix hexadecimal}} /axi_dynclk_tb/rec_axil_dynclk
add wave -noupdate -color Coral -radix hexadecimal /axi_dynclk_tb/REF_CLK_I
add wave -noupdate -color Coral -radix hexadecimal /axi_dynclk_tb/PXL_CLK_O
add wave -noupdate -color Coral -radix hexadecimal /axi_dynclk_tb/PXL_CLK_5X_O
add wave -noupdate -color Coral -radix hexadecimal /axi_dynclk_tb/LOCKED_O
add wave -noupdate -radix hexadecimal /axi_dynclk_tb/axi_dynclk_inst/clk_state
add wave -noupdate -radix hexadecimal /axi_dynclk_tb/axi_dynclk_inst/xLocked
add wave -noupdate -radix hexadecimal /axi_dynclk_tb/axi_dynclk_inst/aLocked
add wave -noupdate -radix hexadecimal /axi_dynclk_tb/axi_dynclk_inst/mmcm_fbclk_in
add wave -noupdate -radix hexadecimal /axi_dynclk_tb/axi_dynclk_inst/mmcm_fbclk_out
add wave -noupdate -radix hexadecimal /axi_dynclk_tb/axi_dynclk_inst/mmcm_clk
add wave -noupdate -group {MMCM IO} -color {Medium Slate Blue} -radix hexadecimal /axi_dynclk_tb/axi_dynclk_inst/Inst_mmcme2_drp/SEN
add wave -noupdate -group {MMCM IO} -color {Medium Slate Blue} -radix hexadecimal /axi_dynclk_tb/axi_dynclk_inst/Inst_mmcme2_drp/SCLK
add wave -noupdate -group {MMCM IO} -color {Medium Slate Blue} -radix hexadecimal /axi_dynclk_tb/axi_dynclk_inst/Inst_mmcme2_drp/RST
add wave -noupdate -group {MMCM IO} -color {Medium Slate Blue} -radix hexadecimal /axi_dynclk_tb/axi_dynclk_inst/Inst_mmcme2_drp/SRDY
add wave -noupdate -group {MMCM IO} -color {Medium Slate Blue} -radix hexadecimal /axi_dynclk_tb/axi_dynclk_inst/Inst_mmcme2_drp/S1_CLKOUT0
add wave -noupdate -group {MMCM IO} -color {Medium Slate Blue} -radix hexadecimal /axi_dynclk_tb/axi_dynclk_inst/Inst_mmcme2_drp/S1_CLKFBOUT
add wave -noupdate -group {MMCM IO} -color {Medium Slate Blue} -radix hexadecimal /axi_dynclk_tb/axi_dynclk_inst/Inst_mmcme2_drp/S1_DIVCLK
add wave -noupdate -group {MMCM IO} -color {Medium Slate Blue} -radix hexadecimal /axi_dynclk_tb/axi_dynclk_inst/Inst_mmcme2_drp/S1_LOCK
add wave -noupdate -group {MMCM IO} -color {Medium Slate Blue} -radix hexadecimal /axi_dynclk_tb/axi_dynclk_inst/Inst_mmcme2_drp/S1_DIGITAL_FILT
add wave -noupdate -group {MMCM IO} -color {Medium Slate Blue} -radix hexadecimal /axi_dynclk_tb/axi_dynclk_inst/Inst_mmcme2_drp/REF_CLK
add wave -noupdate -group {MMCM IO} -color {Medium Slate Blue} -radix hexadecimal /axi_dynclk_tb/axi_dynclk_inst/Inst_mmcme2_drp/PXL_CLK
add wave -noupdate -group {MMCM IO} -color {Medium Slate Blue} -radix hexadecimal /axi_dynclk_tb/axi_dynclk_inst/Inst_mmcme2_drp/CLKFBOUT_O
add wave -noupdate -group {MMCM IO} -color {Medium Slate Blue} -radix hexadecimal /axi_dynclk_tb/axi_dynclk_inst/Inst_mmcme2_drp/CLKFBOUT_I
add wave -noupdate -group {MMCM IO} -color {Medium Slate Blue} -radix hexadecimal /axi_dynclk_tb/axi_dynclk_inst/Inst_mmcme2_drp/LOCKED_O
add wave -noupdate -expand -group {MMCM internal} -radix hexadecimal /axi_dynclk_tb/axi_dynclk_inst/Inst_mmcme2_drp/rom
add wave -noupdate -expand -group {MMCM internal} -radix hexadecimal /axi_dynclk_tb/axi_dynclk_inst/Inst_mmcme2_drp/rom_addr
add wave -noupdate -expand -group {MMCM internal} -radix hexadecimal /axi_dynclk_tb/axi_dynclk_inst/Inst_mmcme2_drp/rom_do
add wave -noupdate -expand -group {MMCM internal} -radix hexadecimal /axi_dynclk_tb/axi_dynclk_inst/Inst_mmcme2_drp/next_srdy
add wave -noupdate -expand -group {MMCM internal} -radix hexadecimal /axi_dynclk_tb/axi_dynclk_inst/Inst_mmcme2_drp/next_rom_addr
add wave -noupdate -expand -group {MMCM internal} -radix hexadecimal /axi_dynclk_tb/axi_dynclk_inst/Inst_mmcme2_drp/next_daddr
add wave -noupdate -expand -group {MMCM internal} -radix hexadecimal /axi_dynclk_tb/axi_dynclk_inst/Inst_mmcme2_drp/next_dwe
add wave -noupdate -expand -group {MMCM internal} -radix hexadecimal /axi_dynclk_tb/axi_dynclk_inst/Inst_mmcme2_drp/next_den
add wave -noupdate -expand -group {MMCM internal} -radix hexadecimal /axi_dynclk_tb/axi_dynclk_inst/Inst_mmcme2_drp/next_rst_mmcm
add wave -noupdate -expand -group {MMCM internal} -radix hexadecimal /axi_dynclk_tb/axi_dynclk_inst/Inst_mmcme2_drp/next_di
add wave -noupdate -expand -group {MMCM internal} -radix hexadecimal /axi_dynclk_tb/axi_dynclk_inst/Inst_mmcme2_drp/DO
add wave -noupdate -expand -group {MMCM internal} -radix hexadecimal /axi_dynclk_tb/axi_dynclk_inst/Inst_mmcme2_drp/DRDY
add wave -noupdate -expand -group {MMCM internal} -radix hexadecimal /axi_dynclk_tb/axi_dynclk_inst/Inst_mmcme2_drp/LOCKED
add wave -noupdate -expand -group {MMCM internal} -radix hexadecimal /axi_dynclk_tb/axi_dynclk_inst/Inst_mmcme2_drp/DWE
add wave -noupdate -expand -group {MMCM internal} -radix hexadecimal /axi_dynclk_tb/axi_dynclk_inst/Inst_mmcme2_drp/DEN
add wave -noupdate -expand -group {MMCM internal} -radix hexadecimal /axi_dynclk_tb/axi_dynclk_inst/Inst_mmcme2_drp/DADDR
add wave -noupdate -expand -group {MMCM internal} -radix hexadecimal /axi_dynclk_tb/axi_dynclk_inst/Inst_mmcme2_drp/DI
add wave -noupdate -expand -group {MMCM internal} -radix hexadecimal /axi_dynclk_tb/axi_dynclk_inst/Inst_mmcme2_drp/DCLK
add wave -noupdate -expand -group {MMCM internal} -radix hexadecimal /axi_dynclk_tb/axi_dynclk_inst/Inst_mmcme2_drp/RST_MMCM
add wave -noupdate -expand -group {MMCM internal} -color {Orange Red} -radix hexadecimal /axi_dynclk_tb/axi_dynclk_inst/Inst_mmcme2_drp/current_state
add wave -noupdate -expand -group {MMCM internal} -color {Orange Red} -radix hexadecimal /axi_dynclk_tb/axi_dynclk_inst/Inst_mmcme2_drp/next_state
add wave -noupdate -expand -group {MMCM internal} -radix hexadecimal /axi_dynclk_tb/axi_dynclk_inst/Inst_mmcme2_drp/state_count
add wave -noupdate -expand -group {MMCM internal} -radix hexadecimal /axi_dynclk_tb/axi_dynclk_inst/Inst_mmcme2_drp/next_state_count
add wave -noupdate -expand -group {MMCM internal} -radix hexadecimal /axi_dynclk_tb/axi_dynclk_inst/Inst_mmcme2_drp/psdone_unused
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1335561 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 441
configure wave -valuecolwidth 100
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
WaveRestoreZoom {0 ps} {5801728 ps}
