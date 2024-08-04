
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;

library osvvm_Axi4;
context osvvm_Axi4.Axi4LiteContext;

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

  signal rec_axil_dynclk : Axi4LiteRecType(
  WriteAddress (Addr(C_S_AXI_LITE_ADDR_WIDTH - 1 downto 0)),
  WriteData (Data(C_S_AXI_LITE_DATA_WIDTH - 1 downto 0), Strb((C_S_AXI_LITE_DATA_WIDTH/8) - 1 downto 0)),
  ReadAddress (Addr(C_S_AXI_LITE_ADDR_WIDTH - 1 downto 0)),
  ReadData (Data(C_S_AXI_LITE_DATA_WIDTH - 1 downto 0)));

  signal rec_manager : AddressBusRecType(
  Address(C_S_AXI_LITE_ADDR_WIDTH - 1 downto 0),
  DataToModel(C_S_AXI_LITE_DATA_WIDTH - 1 downto 0),
  DataFromModel(C_S_AXI_LITE_DATA_WIDTH - 1 downto 0)
  );

  -- AXIL Register
  signal DDYNCLK_CTRL         : std_logic_vector(31 downto 0) := x"0000_0000";
  signal DDYNCLK_STATUS       : std_logic_vector(31 downto 0) := x"0000_0004";
  signal DDYNCLK_CLK_L        : std_logic_vector(31 downto 0) := x"0000_0008";
  signal DDYNCLK_FB_L         : std_logic_vector(31 downto 0) := x"0000_000C";
  signal DDYNCLK_FB_H_CLK_H   : std_logic_vector(31 downto 0) := x"0000_0010";
  signal DDYNCLK_DIV          : std_logic_vector(31 downto 0) := x"0000_0014";
  signal DDYNCLK_LOCK_L       : std_logic_vector(31 downto 0) := x"0000_0018";
  signal DDYNCLK_FLTR_LOCK_H  : std_logic_vector(31 downto 0) := x"0000_001C";
  signal DDYNCLK_REF_CLK_FREQ : std_logic_vector(31 downto 0) := x"0000_0020";

begin

  -- DUT
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

      s_axi_lite_awaddr  => rec_axil_dynclk.WriteAddress.Addr,
      s_axi_lite_awprot  => rec_axil_dynclk.WriteAddress.Prot,
      s_axi_lite_awvalid => rec_axil_dynclk.WriteAddress.Valid,
      s_axi_lite_awready => rec_axil_dynclk.WriteAddress.Ready,

      s_axi_lite_wdata  => rec_axil_dynclk.WriteData.Data,
      s_axi_lite_wstrb  => rec_axil_dynclk.WriteData.Strb,
      s_axi_lite_wvalid => rec_axil_dynclk.WriteData.Valid,
      s_axi_lite_wready => rec_axil_dynclk.WriteData.Ready,

      s_axi_lite_bresp  => rec_axil_dynclk.WriteResponse.Resp,
      s_axi_lite_bvalid => rec_axil_dynclk.WriteResponse.Valid,
      s_axi_lite_bready => rec_axil_dynclk.WriteResponse.Ready,

      s_axi_lite_araddr  => rec_axil_dynclk.ReadAddress.Addr,
      s_axi_lite_arprot  => rec_axil_dynclk.ReadAddress.Prot,
      s_axi_lite_arvalid => rec_axil_dynclk.ReadAddress.Valid,
      s_axi_lite_arready => rec_axil_dynclk.ReadAddress.Ready,

      s_axi_lite_rdata  => rec_axil_dynclk.ReadData.Data,
      s_axi_lite_rresp  => rec_axil_dynclk.ReadData.Resp,
      s_axi_lite_rvalid => rec_axil_dynclk.ReadData.Valid,
      s_axi_lite_rready => rec_axil_dynclk.ReadData.Ready
    );

  main : process
    variable var_data : std_logic_vector(C_S_AXI_LITE_DATA_WIDTH - 1 downto 0);
  begin
    test_runner_setup(runner, runner_cfg);
    while test_suite loop

      s_axi_lite_aresetn <= '0';
      wait for 1 us;
      s_axi_lite_aresetn <= '1';
      wait for 1 us;

      if run("read all") then

        for itr in 0 to 63 loop
          ReadAddressAsync(rec_manager, std_logic_vector(to_unsigned(0, C_S_AXI_LITE_ADDR_WIDTH)));
        end loop;

        for itr in 0 to 63 loop
          ReadData(rec_manager, var_data);
          -- Check
        end loop;

        wait for 10 us;

      elsif run("freq") then

        -- Disable Clock
        Write(rec_manager, x"0000_0000", x"0000_0000");

        wait for 1 us;
        Write(rec_manager, DDYNCLK_CLK_L, x"0080_0083");
        Write(rec_manager, DDYNCLK_FB_L, x"0080_0411");
        Write(rec_manager, DDYNCLK_FB_H_CLK_H, x"0000_0000");
        Write(rec_manager, DDYNCLK_DIV, x"0000_0082");
        Write(rec_manager, DDYNCLK_LOCK_L, x"d2cf_a401");
        Write(rec_manager, DDYNCLK_FLTR_LOCK_H, x"0063_00ff");

        -- Enable Clock
        Write(rec_manager, x"0000_0000", x"0000_0001");
        -- WriteAddressAsync(rec_manager, std_logic_vector(to_unsigned(0, C_S_AXI_LITE_ADDR_WIDTH)));
        -- WriteDataAsync (rec_manager, std_logic_vector(to_unsigned(1, C_S_AXI_LITE_DATA_WIDTH)));

        wait for 50 us;

        -- Read(rec_manager, x"0000_0004", var_data);

      end if;
      test_runner_cleanup(runner);
    end loop;
  end process main;

  REF_CLK_I       <= not REF_CLK_I after clk_period/2;
  s_axi_lite_aclk <= not s_axi_lite_aclk after clk_period / 2;

  -- Verification Component
  vc_manager : entity osvvm_Axi4.Axi4LiteManager
    port
    map (
    Clk    => s_axi_lite_aclk,
    nReset => s_axi_lite_aresetn,

    -- AXI Manager Functional Interface
    AxiBus => rec_axil_dynclk,

    -- Testbench Transaction Interface
    TransRec => rec_manager
    );

end;