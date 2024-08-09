
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

library bitvis_vip_axilite;
context bitvis_vip_axilite.vvc_context;
-- use bitvis_vip_axilite.td_vvc_framework_common_methods_pkg.all;

entity axi_dynclk_tb is
  generic
  (
    runner_cfg : string
  );
end;

architecture bench of axi_dynclk_tb is
  -- Clock period
  constant clk_period : time := 10 ns;
  -- Generics
  constant kRefClkFreqHz           : natural := 100_000_000;
  constant kVersionMajor           : natural := 1;
  constant kVersionMinor           : natural := 0;
  constant kAddBUFMR               : boolean := false;
  constant C_S_AXI_LITE_DATA_WIDTH : integer := 32;
  constant C_S_AXI_LITE_ADDR_WIDTH : integer := 6;
  -- Ports
  signal REF_CLK_I    : std_logic := '1';
  signal PXL_CLK_O    : std_logic;
  signal PXL_CLK_5X_O : std_logic;
  signal LOCKED_O     : std_logic;

  signal s_axi_lite_aclk    : std_logic := '1';
  signal s_axi_lite_aresetn : std_logic;
  signal s_axi_lite_if      : t_axilite_if(
  write_address_channel(awaddr(C_S_AXI_LITE_ADDR_WIDTH - 1 downto 0)),
  write_data_channel(wdata(C_S_AXI_LITE_DATA_WIDTH - 1 downto 0),
  wstrb((C_S_AXI_LITE_DATA_WIDTH / 8) - 1 downto 0)),
  read_address_channel(araddr(C_S_AXI_LITE_ADDR_WIDTH - 1 downto 0)),
  read_data_channel(rdata(C_S_AXI_LITE_DATA_WIDTH - 1 downto 0))
  );

  -- AXIL Register
  signal DDYNCLK_CTRL         : unsigned(C_S_AXI_LITE_ADDR_WIDTH - 1 downto 0) := to_unsigned(0, C_S_AXI_LITE_ADDR_WIDTH);
  signal DDYNCLK_STATUS       : unsigned(C_S_AXI_LITE_ADDR_WIDTH - 1 downto 0) := to_unsigned(4, C_S_AXI_LITE_ADDR_WIDTH);
  signal DDYNCLK_CLK_L        : unsigned(C_S_AXI_LITE_ADDR_WIDTH - 1 downto 0) := to_unsigned(8, C_S_AXI_LITE_ADDR_WIDTH);
  signal DDYNCLK_FB_L         : unsigned(C_S_AXI_LITE_ADDR_WIDTH - 1 downto 0) := to_unsigned(12, C_S_AXI_LITE_ADDR_WIDTH);
  signal DDYNCLK_FB_H_CLK_H   : unsigned(C_S_AXI_LITE_ADDR_WIDTH - 1 downto 0) := to_unsigned(16, C_S_AXI_LITE_ADDR_WIDTH);
  signal DDYNCLK_DIV          : unsigned(C_S_AXI_LITE_ADDR_WIDTH - 1 downto 0) := to_unsigned(20, C_S_AXI_LITE_ADDR_WIDTH);
  signal DDYNCLK_LOCK_L       : unsigned(C_S_AXI_LITE_ADDR_WIDTH - 1 downto 0) := to_unsigned(24, C_S_AXI_LITE_ADDR_WIDTH);
  signal DDYNCLK_FLTR_LOCK_H  : unsigned(C_S_AXI_LITE_ADDR_WIDTH - 1 downto 0) := to_unsigned(28, C_S_AXI_LITE_ADDR_WIDTH);
  signal DDYNCLK_REF_CLK_FREQ : unsigned(C_S_AXI_LITE_ADDR_WIDTH - 1 downto 0) := to_unsigned(32, C_S_AXI_LITE_ADDR_WIDTH);

begin

  --------------------------------------
  -- DUT
  --------------------------------------
  axi_dynclk_inst : entity work.axi_dynclk
    generic
    map (
    kRefClkFreqHz           => kRefClkFreqHz,
    kVersionMajor           => kVersionMajor,
    kVersionMinor           => kVersionMinor,
    kAddBUFMR               => kAddBUFMR,
    C_S_AXI_LITE_DATA_WIDTH => C_S_AXI_LITE_DATA_WIDTH,
    C_S_AXI_LITE_ADDR_WIDTH => C_S_AXI_LITE_ADDR_WIDTH
    )
    port map
    (
      REF_CLK_I    => REF_CLK_I,
      PXL_CLK_O    => PXL_CLK_O,
      PXL_CLK_5X_O => PXL_CLK_5X_O,
      LOCKED_O     => LOCKED_O,

      s_axi_lite_aclk    => s_axi_lite_aclk,
      s_axi_lite_aresetn => s_axi_lite_aresetn,

      s_axi_lite_awaddr  => s_axi_lite_if.write_address_channel.awaddr,
      s_axi_lite_awprot  => s_axi_lite_if.write_address_channel.awprot,
      s_axi_lite_awvalid => s_axi_lite_if.write_address_channel.awvalid,
      s_axi_lite_awready => s_axi_lite_if.write_address_channel.awready,

      s_axi_lite_wdata  => s_axi_lite_if.write_data_channel.wdata,
      s_axi_lite_wstrb  => s_axi_lite_if.write_data_channel.wstrb,
      s_axi_lite_wvalid => s_axi_lite_if.write_data_channel.wvalid,
      s_axi_lite_wready => s_axi_lite_if.write_data_channel.wready,

      s_axi_lite_bresp  => s_axi_lite_if.write_response_channel.bresp,
      s_axi_lite_bvalid => s_axi_lite_if.write_response_channel.bvalid,
      s_axi_lite_bready => s_axi_lite_if.write_response_channel.bready,

      s_axi_lite_araddr  => s_axi_lite_if.read_address_channel.araddr,
      s_axi_lite_arprot  => s_axi_lite_if.read_address_channel.arprot,
      s_axi_lite_arvalid => s_axi_lite_if.read_address_channel.arvalid,
      s_axi_lite_arready => s_axi_lite_if.read_address_channel.arready,

      s_axi_lite_rdata  => s_axi_lite_if.read_data_channel.rdata,
      s_axi_lite_rresp  => s_axi_lite_if.read_data_channel.rresp,
      s_axi_lite_rvalid => s_axi_lite_if.read_data_channel.rvalid,
      s_axi_lite_rready => s_axi_lite_if.read_data_channel.rready
    );

  --------------------------------------
  -- Verification Component
  --------------------------------------
  ti_uvvm_engine_inst : entity uvvm_vvc_framework.ti_uvvm_engine;

  tx_axil_vc : entity bitvis_vip_axilite.axilite_vvc
    generic
    map
    (
    GC_ADDR_WIDTH   => C_S_AXI_LITE_ADDR_WIDTH,
    GC_DATA_WIDTH   => C_S_AXI_LITE_DATA_WIDTH,
    GC_INSTANCE_IDX => 1
    )
    port
    map
    (
    clk                   => s_axi_lite_aclk,
    axilite_vvc_master_if => s_axi_lite_if
    );

  --------------------------------------
  -- Clocking
  --------------------------------------
  REF_CLK_I       <= not REF_CLK_I after clk_period/2;
  s_axi_lite_aclk <= not s_axi_lite_aclk after clk_period / 2;

  --------------------------------------
  -- Test Cases
  --------------------------------------
  main : process
    variable var_data : std_logic_vector(C_S_AXI_LITE_DATA_WIDTH - 1 downto 0);
  begin
    test_runner_setup(runner, runner_cfg);

    await_uvvm_initialization(VOID);

    while test_suite loop

      s_axi_lite_aresetn <= '0';
      wait for 5 * clk_period;
      s_axi_lite_aresetn <= '1';
      wait for 5 * clk_period;

      if run("read all") then

        for i in 0 to 63 loop
          axilite_read(AXILITE_VVCT, 1, to_unsigned(i, C_S_AXI_LITE_ADDR_WIDTH), "");
        end loop;

      elsif run("write freq") then

        -- Disable Clock
        axilite_write(AXILITE_VVCT, 1, DDYNCLK_CTRL, x"0000", "");

        wait for 1 us;
        axilite_write(AXILITE_VVCT, 1, DDYNCLK_CLK_L, x"0080_0083", "");
        axilite_write(AXILITE_VVCT, 1, DDYNCLK_FB_L, x"0080_0411", "");
        axilite_write(AXILITE_VVCT, 1, DDYNCLK_FB_H_CLK_H, x"0000_0000", "");
        axilite_write(AXILITE_VVCT, 1, DDYNCLK_DIV, x"0000_0082", "");
        axilite_write(AXILITE_VVCT, 1, DDYNCLK_LOCK_L, x"d2cf_a401", "");
        axilite_write(AXILITE_VVCT, 1, DDYNCLK_FLTR_LOCK_H, x"0063_00ff", "");

        -- Enable Clock
        axilite_write(AXILITE_VVCT, 1, DDYNCLK_CTRL, x"0001", "");

        wait for 50 us;
      end if;
      test_runner_cleanup(runner);
    end loop;
  end process main;

end;