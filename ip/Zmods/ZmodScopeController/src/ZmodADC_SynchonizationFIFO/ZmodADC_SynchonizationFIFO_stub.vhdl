-- Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2021.1 (win64) Build 3247384 Thu Jun 10 19:36:33 MDT 2021
-- Date        : Thu Jan 20 16:40:35 2022
-- Host        : balas-ro-TP running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               d:/Workspace/Vivado/eclypse_z7/hw/repo/vivado-library/ip/Zmods/ZmodScopeController/src/ZmodADC_SynchonizationFIFO/ZmodADC_SynchonizationFIFO_stub.vhdl
-- Design      : ZmodADC_SynchonizationFIFO
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7z020clg484-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ZmodADC_SynchonizationFIFO is
  Port ( 
    rst : in STD_LOGIC;
    wr_clk : in STD_LOGIC;
    rd_clk : in STD_LOGIC;
    din : in STD_LOGIC_VECTOR ( 31 downto 0 );
    wr_en : in STD_LOGIC;
    rd_en : in STD_LOGIC;
    dout : out STD_LOGIC_VECTOR ( 31 downto 0 );
    full : out STD_LOGIC;
    overflow : out STD_LOGIC;
    empty : out STD_LOGIC;
    valid : out STD_LOGIC
  );

end ZmodADC_SynchonizationFIFO;

architecture stub of ZmodADC_SynchonizationFIFO is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "rst,wr_clk,rd_clk,din[31:0],wr_en,rd_en,dout[31:0],full,overflow,empty,valid";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "fifo_generator_v13_2_5,Vivado 2021.1";
begin
end;
