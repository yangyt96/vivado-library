
from pathlib import Path
from vunit import VUnit
import glob



#############################################################


vu = VUnit.from_argv()
vu.add_verilog_builtins()
vu.add_vhdl_builtins()

osvvm = vu.add_library("osvvm")
osvvm_files = glob.glob("C:/project/OsvvmLibraries/osvvm/*.vhd")
osvvm_files = [file for file in osvvm_files if "aldec" not in file.lower()]
osvvm_files = [file for file in osvvm_files if "LanguageSupport2019Pkg.vhd" not in file]
osvvm.add_source_files(osvvm_files)

osvvm_common = vu.add_library("osvvm_common")
osvvm_files = glob.glob("C:/project/OsvvmLibraries/Common/src/*.vhd")
osvvm_files = [file for file in osvvm_files if "xilinx" not in file.lower()]
osvvm_common.add_source_files(osvvm_files)

osvvm_axi4 = vu.add_library("osvvm_axi4")
osvvm_files = glob.glob("C:/project/OsvvmLibraries/AXI4/**/src/*.vhd")
osvvm_axi4.add_source_files(osvvm_files)

vu.add_external_library("unisims_ver", "C:/intelFPGA/20.1/xil-2018.3/unisims_ver")
vu.add_external_library("unisim", "C:/intelFPGA/20.1/xil-2018.3/unisim")

#############################################################

axi_dynclk = vu.add_library("axi_dynclk")


root = Path(__file__).parent

axi_dynclk.add_source_files([
    "E:/Xilinx/Vivado/2018.3/ids_lite/ISE/verilog/src/glbl.v",

    root/"src/*.vhd",
    root/"src/*.v",
    root/"tb/*.vhd",
])


######################


axi_dynclk.set_sim_option(
    "modelsim.vsim_flags", 
    ["axi_dynclk.glbl "],
)

axi_dynclk.set_sim_option(
    name="modelsim.init_file.gui",
    value=str(root/"tb/axi_dynclk_tb.do"),
    allow_empty=True
)


vu.main()