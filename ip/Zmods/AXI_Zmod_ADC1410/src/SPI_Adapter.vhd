----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/23/2019 05:17:57 PM
-- Design Name: 
-- Module Name: SPI_Adapter - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SPI_Adapter is
    Port ( SysClk : in STD_LOGIC;
           AxiLiteClk : in STD_LOGIC;
           sRst_n : in std_logic;
           lRst_n : in STD_LOGIC;
           sADC_SPI_CmdDone : in std_logic;
           sSPI_CmdRunStop  : in STD_LOGIC;
           sSPI_CmdReadEn : in STD_LOGIC;
           lSPI_CmdTx : in STD_LOGIC_VECTOR(23 downto 0);
           lSPI_CmdRx : out STD_LOGIC_VECTOR(7 downto 0);
           lSPI_CmdTxDone : out STD_LOGIC;
           lSPI_CmdRxDone : out STD_LOGIC;
           lSPI_CmdTxCount : out STD_LOGIC_VECTOR(6 downto 0);
           lSPI_CmdRxCount : out STD_LOGIC_VECTOR(6 downto 0);
           lSPI_CmdTxRxError : out STD_LOGIC_VECTOR(3 downto 0);
           lTxFifoWrEn : in STD_LOGIC;
           sTxFifoRdEn : in STD_LOGIC; --
           sTxFifoRdEnRdy : out STD_LOGIC; --the lower level IP should first assign sTxFifoRdEn and than wait sTxFifoRdEnRdy to be asserted before signaling command completion
           sTxFifoDout : out STD_LOGIC_VECTOR(23 downto 0); --
           sSPI_TxValid : out STD_LOGIC;
           lRxFifoRdEn : in STD_LOGIC;
           sRxFifoWrEn : in STD_LOGIC; --
           sRxFifoDin : in STD_LOGIC_VECTOR (7 downto 0) --
          
           );
end SPI_Adapter;


architecture Behavioral of SPI_Adapter is

COMPONENT RX_FIFO
  PORT (
    rst : IN STD_LOGIC;
    wr_clk : IN STD_LOGIC;
    rd_clk : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    full : OUT STD_LOGIC;
    almost_full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC;
    almost_empty : OUT STD_LOGIC;
    valid : OUT STD_LOGIC;
    rd_data_count : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    wr_rst_busy : OUT STD_LOGIC;
    rd_rst_busy : OUT STD_LOGIC
  );
END COMPONENT;

COMPONENT TX_FIFO
  PORT (
    rst : IN STD_LOGIC;
    wr_clk : IN STD_LOGIC;
    rd_clk : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
    full : OUT STD_LOGIC;
    almost_full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC;
    almost_empty : OUT STD_LOGIC;
    valid : OUT STD_LOGIC;
    wr_data_count : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    wr_rst_busy : OUT STD_LOGIC;
    rd_rst_busy : OUT STD_LOGIC
  );
END COMPONENT;

component HandshakeData is
   Generic (
      kDataWidth : natural := 8);
   Port (
      InClk : in STD_LOGIC;
      OutClk : in STD_LOGIC;
      iData : in STD_LOGIC_VECTOR (kDataWidth-1 downto 0);
      oData : out STD_LOGIC_VECTOR (kDataWidth-1 downto 0);
      iPush : in STD_LOGIC;
      iRdy : out STD_LOGIC;
      oAck : in STD_LOGIC := '1';
      oValid : out STD_LOGIC;
      aReset : in std_logic);
end component HandshakeData;

signal sRxFifoFull : STD_LOGIC;
signal sRxFifoAlmostFull : STD_LOGIC;
signal lRxFifoEmpty : STD_LOGIC;
signal lRxFifoAlmostEmpty : STD_LOGIC;
signal lRxFifoValid : STD_LOGIC;
signal sRxFifoWrRstBusy : STD_LOGIC;
signal lRxFifoRdRstBusy : STD_LOGIC;
signal lTxFifoFull : STD_LOGIC;
signal lTxFifoAlmostFull : STD_LOGIC;
signal sTxFifoEmpty: STD_LOGIC;
signal lTxFifoEmpty, lTxFifoEmptyR, lTxFifoEmptyPulse : STD_LOGIC;
signal sTxFifoAlmostEmpty : STD_LOGIC;

signal lTxFifoWrRstBusy : STD_LOGIC;
signal sTxFifoRdRstBusy : STD_LOGIC;
signal lADC_CmdDone, lTxDoneSet, lTxDoneSetR, lTxDonePulse : std_logic;

signal lTxFifoCounter : std_logic_vector (6 downto 0);
signal lTxFifoRdEn : std_logic;
signal lRxFifoCounter : std_logic_vector (6 downto 0);
signal lRxFifoWrEn : std_logic;

signal sSetPushTxFifoEmpty, sTxFifoEmptyR, sRstPushTxFifoEmpty, sPushTxFifoEmpty, sRdyTxFifoEmpty, lValidTxFifoEmpty : std_logic;
signal sDinTxFifioEmpty, lDoutTxFifioEmpty : std_logic_vector(0 downto 0);

signal lRst_p : std_logic;

    attribute mark_debug : string;
    attribute keep : string;
    
--    attribute mark_debug of lTxFifoEmpty : signal is "true";
--    attribute keep of lTxFifoEmpty : signal is "true";
--    attribute mark_debug of lTxFifoEmptyPulse : signal is "true";
--    attribute keep of lTxFifoEmptyPulse : signal is "true";
--    attribute mark_debug of lADC_CmdDone : signal is "true";
--    attribute keep of lADC_CmdDone : signal is "true";
--    attribute mark_debug of lADC_CmdDone_Pulse : signal is "true";
--    attribute keep of lADC_CmdDone_Pulse : signal is "true";
--    attribute mark_debug of lTxDoneSet : signal is "true";
--    attribute keep of lTxDoneSet : signal is "true";
--    attribute mark_debug of lTxDonePulse : signal is "true";
--    attribute keep of lTxDonePulse : signal is "true";
    
--    attribute mark_debug of lTxFifoWrEn : signal is "true";
--    attribute keep of lTxFifoWrEn : signal is "true";
--    attribute mark_debug of lRxFifoRdEn : signal is "true";
--    attribute keep of lRxFifoRdEn : signal is "true";
--    attribute mark_debug of lSPI_CmdTxCount : signal is "true";
--    attribute keep of lSPI_CmdTxCount : signal is "true";
--    attribute mark_debug of lSPI_CmdRxCount : signal is "true";
--    attribute keep of lSPI_CmdRxCount : signal is "true";
--    attribute mark_debug of lSPI_CmdTx : signal is "true";
--    attribute keep of lSPI_CmdTx : signal is "true";
--    attribute mark_debug of sTxFifoDout : signal is "true";
--    attribute keep of sTxFifoDout : signal is "true";
--    attribute mark_debug of sRxFifoDin : signal is "true";
--    attribute keep of sRxFifoDin : signal is "true";
--    attribute mark_debug of sRxFifoWrEn : signal is "true";
--    attribute keep of sRxFifoWrEn : signal is "true";
--    attribute mark_debug of lSPI_CmdTxDone : signal is "true";
--    attribute keep of lSPI_CmdTxDone : signal is "true";
    
--    attribute mark_debug of lRxFifoValid : signal is "true";
--    attribute keep of lRxFifoValid : signal is "true";
--    attribute mark_debug of lRst_p : signal is "true";
--    attribute keep of lRst_p : signal is "true";
--        attribute mark_debug of lRst_n : signal is "true";
--    attribute keep of lRst_n : signal is "true";    
--    attribute mark_debug of lSPI_CmdRx : signal is "true";
--    attribute keep of lSPI_CmdRx : signal is "true";
--    attribute mark_debug of lRxFifoEmpty : signal is "true";
--    attribute keep of lRxFifoEmpty : signal is "true";
--    attribute mark_debug of sRxFifoWrRstBusy : signal is "true";
--    attribute keep of sRxFifoWrRstBusy : signal is "true";        
--    attribute mark_debug of lRxFifoRdRstBusy : signal is "true";
--    attribute keep of lRxFifoRdRstBusy : signal is "true";     
       
--    attribute mark_debug of sTxFifoRdEn : signal is "true";
--    attribute keep of sTxFifoRdEn : signal is "true";
--        attribute mark_debug of sSPI_TxValid : signal is "true";
--    attribute keep of sSPI_TxValid : signal is "true";  
    
               
begin

lRst_p <= not lRst_n;

lSPI_CmdTxCount <= lTxFifoCounter;
lSPI_CmdRxCount <= lRxFifoCounter;

RECEIVE_FIFO : RX_FIFO
  PORT MAP (
    rst => lRst_p,
    wr_clk => SysClk,
    rd_clk => AxiLiteClk,
    din => sRxFifoDin,
    wr_en => sRxFifoWrEn,
    rd_en => lRxFifoRdEn,
    dout => lSPI_CmdRx,
    full => sRxFifoFull,
    almost_full => sRxFifoAlmostFull,
    empty => lRxFifoEmpty,
    almost_empty => lRxFifoAlmostEmpty,
    valid => lRxFifoValid,
    rd_data_count => open,
    wr_rst_busy => sRxFifoWrRstBusy,
    rd_rst_busy => lRxFifoRdRstBusy
  );
  
 TRANSMIT_FIFO : TX_FIFO
  PORT MAP (
    rst => lRst_p,
    wr_clk => AxiLiteClk,
    rd_clk => SysClk,
    din => lSPI_CmdTx,
    wr_en => lTxFifoWrEn,
    rd_en => sTxFifoRdEn,
    dout => sTxFifoDout,
    full => lTxFifoFull,
    almost_full => lTxFifoAlmostFull,
    empty => sTxFifoEmpty,
    almost_empty => sTxFifoAlmostEmpty,
    valid => sSPI_TxValid,
    wr_data_count => open,
    wr_rst_busy => lTxFifoWrRstBusy,
    rd_rst_busy => sTxFifoRdRstBusy
  );

ProcTxFifoEmptyReg: process (SysClk) 
begin
    if (SysClk' event and SysClk = '1') then
        if (sRst_n = '0') then
            sTxFifoEmptyR <=  '0'; 
        else
            sTxFifoEmptyR <= sTxFifoEmpty;
        end if;
    end if;
end process;

ProcTxFifoEmptyPushSet: process (SysClk) 
--Since iPush transition only trigers input data to propagate
--towrds the output if iRdy is set, it is necessary to have two distinct signals: one to monitor regster modifications
--and one to push data through the hanshake block whenever the input data was modified and the hanshake module is ready
begin
    if (SysClk' event and SysClk = '1') then
        if (sRst_n = '0') then
            sSetPushTxFifoEmpty <=  '0'; 
            sDinTxFifioEmpty <= (others => '0');
        else
            if (sTxFifoEmptyR /= sTxFifoEmpty) then
                sSetPushTxFifoEmpty <= '1';
                sDinTxFifioEmpty(0) <= sTxFifoEmpty;
            elsif (sRstPushTxFifoEmpty = '1') then
                sSetPushTxFifoEmpty <= '0';
            end if;
        end if;
    end if;
end process;
              
ProcTxFifoEmptyPush: process (SysClk) 
begin
    if (SysClk' event and SysClk = '1') then
        if (sRst_n = '0') then
            sPushTxFifoEmpty  <=  '0';
            sRstPushTxFifoEmpty <= '0';
        else
                if ((sSetPushTxFifoEmpty = '1') and (sRdyTxFifoEmpty = '1') and (sPushTxFifoEmpty = '0'))then
                    sPushTxFifoEmpty <= '1';
                    sRstPushTxFifoEmpty <= '1';
                else
                    sPushTxFifoEmpty <= '0';
                    sRstPushTxFifoEmpty <= '0';
                end if;     
        end if;
    end if;
end process;

InstTxFifoEmptyHandshake : HandshakeData -- synchronization module for AXI LITE LENGTH register crossing to PROG_CLK clock domain 
generic map (
    kDataWidth	=> 1
    )
    Port map (
        InClk => SysClk,
        OutClk => AxiLiteClk,
        iData => sDinTxFifioEmpty,
        oData => lDoutTxFifioEmpty,   -- synchronized output
        iPush => sPushTxFifoEmpty,
        iRdy => sRdyTxFifoEmpty,  
        oAck => '1',  
        oValid => lValidTxFifoEmpty,   -- indicates valid synchronized data
        aReset => lRst_p
        );
 
ProcTxFifoEmptyOdata: process (AxiLiteClk) 
begin
    if (AxiLiteClk' event and AxiLiteClk = '1') then
        if (lRst_n = '0') then
            lTxFifoEmpty <=  '0'; 
        else
            if (lValidTxFifoEmpty = '1') then
                lTxFifoEmpty <= lDoutTxFifioEmpty(0);
            end if;
        end if;
    end if;
end process;

InstAdcCmdDoneEmptyHandshake : HandshakeData -- synchronization module for AXI LITE LENGTH register crossing to PROG_CLK clock domain 
generic map (
    kDataWidth	=> 1
    )
    Port map (
        InClk => SysClk,
        OutClk => AxiLiteClk,
        iData => "1",
        oData => open,   -- synchronized output
        iPush => sADC_SPI_CmdDone,
        iRdy => open,  
        oAck => '1',  
        oValid => lADC_CmdDone,   -- indicates valid synchronized data
        aReset => lRst_p
        );

InstTxFifoRdEnHandshake : HandshakeData -- synchronization module for AXI LITE LENGTH register crossing to PROG_CLK clock domain 
generic map (
    kDataWidth	=> 1
    )
    Port map (
        InClk => SysClk,
        OutClk => AxiLiteClk,
        iData => "1",
        oData => open,   -- synchronized output
        iPush => sTxFifoRdEn,
        iRdy => sTxFifoRdEnRdy,  
        oAck => '1',  
        oValid => lTxFifoRdEn,   -- indicates valid synchronized data
        aReset => lRst_p
        );
        
--lTxFifoRdEn <= sTxFifoRdEn;

InstRxFifoWrEnHandshake : HandshakeData -- synchronization module for AXI LITE LENGTH register crossing to PROG_CLK clock domain 
generic map (
    kDataWidth	=> 1
    )
    Port map (
        InClk => SysClk,
        OutClk => AxiLiteClk,
        iData => "1",
        oData => open,   -- synchronized output
        iPush => sRxFifoWrEn,
        iRdy => open,  
        oAck => '1',  
        oValid => lRxFifoWrEn,   -- indicates valid synchronized data
        aReset => lRst_p
        );
        
--lRxFifoWrEn <= sRxFifoWrEn;

TX_FIFO_COUNTER_PROC: process (AxiLiteClk)  
begin
    if (AxiLiteClk' event and AxiLiteClk = '1') then
        if (lRst_n = '0') then
            lTxFifoCounter <= (others => '0');
        else
            if ((lTxFifoWrEn = '1') and (lTxFifoRdEn = '0')) then
                lTxFifoCounter <= lTxFifoCounter + '1';
            elsif ((lTxFifoWrEn = '0') and (lTxFifoRdEn = '1')) then
                lTxFifoCounter <= lTxFifoCounter - '1';
            end if;        
        end if;
    end if;
end process;

RX_FIFO_COUNTER_PROC: process (AxiLiteClk)  
begin
    if (AxiLiteClk' event and AxiLiteClk = '1') then
        if (lRst_n = '0') then
            lRxFifoCounter <= (others => '0');
        else
            if ((lRxFifoWrEn = '1') and (lRxFifoRdEn = '0')) then
                lRxFifoCounter <= lRxFifoCounter + '1';
            elsif ((lRxFifoWrEn = '0') and (lRxFifoRdEn = '1')) then
                lRxFifoCounter <= lRxFifoCounter - '1';
            end if;        
        end if;
    end if;
end process;
 
FIFO_EMPTY_R_PROC: process (AxiLiteClk)  
begin
    if (AxiLiteClk' event and AxiLiteClk = '1') then
        if (lRst_n = '0') then
            lTxFifoEmptyR <= '0';
--            lADC_CmdDone_r <= '0';
        else
            lTxFifoEmptyR <= lTxFifoEmpty;
--            lADC_CmdDone_r <= lADC_CmdDone;
        end if;
    end if;
end process;

lTxFifoEmptyPulse <= lTxFifoEmpty and (not lTxFifoEmptyR);
--lADC_CmdDone_Pulse <= lADC_CmdDone and (not lADC_CmdDone_r);

SYS_TXDONE_PROC: process (AxiLiteClk)  
begin
    if (AxiLiteClk' event and AxiLiteClk = '1') then
        if (lRst_n = '0') then
            lTxDoneSet <= '0';
        else
            if (lADC_CmdDone = '1' and lTxFifoCounter = "000000") then
                lTxDoneSet <= '1';
            elsif (lTxDoneSet = '1') then
                lTxDoneSet <= '0';
            end if;
        end if;
    end if;
end process;

FIFO_TXDONE_R_PROC: process (AxiLiteClk)  -- SysClk = 100MHz => AP_START=1MHz
begin
    if (AxiLiteClk' event and AxiLiteClk = '1') then
        if (lRst_n = '0') then
            lTxDoneSetR <= '0';
        else
            lTxDoneSetR <= lTxDoneSet;
        end if;
    end if;
end process;

lTxDonePulse <= lTxDoneSet and (not lTxDoneSetR);
lSPI_CmdTxDone <= lTxDonePulse;--lTxFifoEmptyPulse;


end Behavioral;
