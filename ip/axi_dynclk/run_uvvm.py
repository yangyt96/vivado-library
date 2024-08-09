from vunit import VUnit
from pathlib import Path

vu = VUnit.from_argv()
vu.add_vhdl_builtins()
vu.add_verilog_builtins()

#############################################################
# Verification Component

# from vunit_helpers import add_uvvm_sources
# add_uvvm_sources(vu, "C:/project/UVVM", [
#     "uvvm_util",
#     "uvvm_vvc_framework",
#     "bitvis_vip_scoreboard",
#     "bitvis_vip_axilite",
# ])

PATH_UVVM = Path("C:/project/UVVM")

uvvm_util = vu.add_library("uvvm_util")
uvvm_util.add_source_files(PATH_UVVM / "uvvm_util/src/*.vhd")

uvvm_vvc_framework = vu.add_library("uvvm_vvc_framework")
uvvm_vvc_framework.add_source_files(PATH_UVVM / "uvvm_vvc_framework/src/*.vhd")

uvvm_scoreboard = vu.add_library("bitvis_vip_scoreboard")
uvvm_scoreboard.add_source_files(PATH_UVVM / "bitvis_vip_scoreboard/src/*.vhd")

uvvm_axil = vu.add_library("bitvis_vip_axilite")
uvvm_axil.add_source_files([
    PATH_UVVM / "bitvis_vip_axilite/src/*.vhd",
    PATH_UVVM / "uvvm_vvc_framework/src_target_dependent/*.vhd",
])

#############################################################
# Library
vu.add_external_library(
    "unisims_ver", "C:/intelFPGA/20.1/xil-2018.3/unisims_ver")
vu.add_external_library("unisim", "C:/intelFPGA/20.1/xil-2018.3/unisim")

#############################################################

ROOT = Path(__file__).parent

axi_dynclk = vu.add_library("axi_dynclk")
axi_dynclk.add_source_files([
    "E:/Xilinx/Vivado/2018.3/ids_lite/ISE/verilog/src/glbl.v",
    ROOT/"src/*.vhd",
    ROOT/"src/*.v",
    ROOT/"tb/*uvvm_tb.vhd",
])
axi_dynclk.set_sim_option(
    name="modelsim.vsim_flags",
    value=["axi_dynclk.glbl "]
)
axi_dynclk.set_sim_option(
    name="modelsim.init_file.gui",
    value=str(ROOT/"tb/axi_dynclk_uvvm_tb.do"),
    allow_empty=True
)

vu.main()
