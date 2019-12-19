----------------------------------------------------------------------------------
-- Company: Digilent
-- Engineer: Tudor Gherman
-- 
-- Create Date: 01/14/2019 09:55:58 AM
-- Design Name: 
-- Module Name: AD9648_SPI - Behavioral
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
use IEEE.STD_LOGIC_1164.ALL;
Library UNISIM;
use UNISIM.vcomponents.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
USE IEEE.STD_LOGIC_ARITH.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity AD9648_SPI is
    Port (
           SysClk : in STD_LOGIC; --100MHZ input clock
           sRst_n : in STD_LOGIC; --active low reset signal
           --AD9648 SPI interface signals
           sSPI_Clk : out STD_LOGIC;  
           sSDIO : inout STD_LOGIC;
           sCS : out STD_LOGIC;
           --Upper layer Interface signals
           sRdData : out std_logic_vector(15 downto 0); --SPI read data output
           sWrData : in std_logic_vector(15 downto 0);  --SPI register data
           sAddr : in std_logic_vector(12 downto 0);  --SPI register sAddr
           sWidth : in std_logic_vector(1 downto 0);  --Number of data bytes + 1; only width 0 tested
           sRdEn : in STD_LOGIC;  --Trigger an SPI read operation
           sWrEn : in STD_LOGIC;  --Trigger an SPI write operation
           sDone : out STD_LOGIC); --Transfer complete flag
end AD9648_SPI;

architecture Behavioral of AD9648_SPI is

signal sClkCounter : std_logic_vector(3 downto 0);
signal sSPI_ClkRst: std_logic;
signal sRdDataR : std_logic_vector(15 downto 0);
signal sTxVector : std_logic_vector (31 downto 0);
signal sRdWr : std_logic;
signal sRxData, sTxData : std_logic;
signal sTxShift, sRxShift : std_logic;
signal sLdTx : std_logic;
signal sTxCount, sRxCount : std_logic_vector(4 downto 0);
signal sBitCount, sBitCountR : std_logic_vector(4 downto 0);
signal sDir, sDirFsm : std_logic;
signal sCS_Fsm : std_logic;
signal sDoneFsm : std_logic;
type FsmStates_t is (StIdle, StWrite, StRead1, StRead2, StRead3, StDone); 
signal sCurrentState, sNextState : FsmStates_t;
signal fsm_state, fsm_state_r : std_logic_vector(3 downto 0);

--    attribute mark_debug : string;
--    attribute keep : string;
--    attribute mark_debug of fsm_state : signal is "true";
--    attribute keep of fsm_state : signal is "true";
--    attribute mark_debug of sLdTx : signal is "true";
--    attribute keep of sLdTx : signal is "true";
--    attribute mark_debug of sRdDataR : signal is "true";
--    attribute keep of sRdDataR : signal is "true";
--    attribute mark_debug of sTxVector : signal is "true";
--    attribute keep of sTxVector : signal is "true";
--    attribute mark_debug of sDir : signal is "true";
--    attribute keep of sDir : signal is "true";
--    attribute mark_debug of sCS : signal is "true";
--    attribute keep of sCS : signal is "true";
--    attribute mark_debug of sTxCount : signal is "true";
--    attribute keep of sTxCount : signal is "true";
--    attribute mark_debug of sRxCount : signal is "true";
--    attribute keep of sRxCount : signal is "true";
--    attribute mark_debug of sTxShift : signal is "true";
--    attribute keep of sTxShift : signal is "true";
--    attribute mark_debug of sRxShift : signal is "true";
--    attribute keep of sRxShift : signal is "true";
--    attribute mark_debug of sTxData : signal is "true";
--    attribute keep of sTxData : signal is "true";
--    attribute mark_debug of sRxData : signal is "true";
--    attribute keep of sRxData : signal is "true";
--    attribute mark_debug of sBitCountR : signal is "true";
--    attribute keep of sBitCountR : signal is "true";
--    attribute mark_debug of sRst_n : signal is "true";
--    attribute keep of sRst_n : signal is "true";
--    attribute mark_debug of sClkCounter : signal is "true";
--    attribute keep of sClkCounter : signal is "true";
--    attribute mark_debug of sSPI_Clk : signal is "true";
--    attribute keep of sSPI_Clk : signal is "true";
--    attribute mark_debug of sDone : signal is "true";
--    attribute keep of sDone : signal is "true";
--    attribute mark_debug of sRdData : signal is "true";
--    attribute keep of sRdData : signal is "true";
--        attribute mark_debug of sRdEn : signal is "true";
--    attribute keep of sRdEn : signal is "true";
--        attribute mark_debug of sWrEn : signal is "true";
--    attribute keep of sWrEn : signal is "true";

begin

InstIOBUF : IOBUF --SDIO three state output buffer
   generic map (
      DRIVE => 12,
      IOSTANDARD => "LVCMOS18",
      SLEW => "SLOW")
   port map (
      O => sRxData,     -- Buffer output
      IO => sSDIO,   -- Buffer inout port (connect directly to top-level port)
      I => sTxData,     -- Buffer input
      T => sDir      -- 3-state enable input, high=input, low=output 
   );
   
ProcClkCounter: process (SysClk) --clock frequency divider
      begin
          if (SysClk' event and SysClk = '1') then
              if ((sRst_n = '0') or (sSPI_ClkRst = '1')) then
                  sClkCounter <= (others => '0');
              else
                  sClkCounter <= sClkCounter + '1';
              end if;
          end if;
      end process; 

sSPI_Clk <= sClkCounter(3); --divide input clock by 16                   

sBitCount <= (sWidth + '1') & "000";

ProcShiftTx: process (SysClk) --Transmit shift register
      begin
          if (SysClk' event and SysClk = '1') then
              if ((sRst_n = '0') or (sLdTx = '1')) then
                  sTxVector <= sRdWr & sWidth & sAddr & sWrData;
                  sTxData <= '0';
              else
                if(sTxShift = '1') then 
                    if (sClkCounter = "0100") then
                      sTxVector(31 downto 0) <= sTxVector(30 downto 0) & '0';
                      sTxData <= sTxVector(31);
                    end if;  
                end if;    
              end if;
          end if;
      end process;

ProcTxCount: process (SysClk) --Count transmitted bits over SDIO signal
      begin
          if (SysClk' event and SysClk = '1') then
              if ((sRst_n = '0') or (sLdTx = '1')) then
                  sTxCount <= (others => '0');
              else
                if(sTxShift = '1') then 
                    if (sClkCounter = "0100") then
                      sTxCount <= sTxCount + '1';
                    end if;  
                end if;    
              end if;
          end if;
      end process;

ProcDir: process (SysClk) --Three state buffer direction control register
      begin
          if (SysClk' event and SysClk = '1') then
              if ((sRst_n = '0') or (sLdTx = '1')) then
                  sDir <= sDirFsm;
              else
                if (sClkCounter = "1111") then
                      sDir <= sDirFsm;
                end if;  
              end if;    
          end if;
      end process;
 
ProcShiftRx: process (SysClk) --Receive deserializer
    begin
        if (SysClk' event and SysClk = '1') then
            if ((sRst_n = '0') or (sRxShift = '0')) then
                sRdDataR <= (others =>'0');
                sRxCount <= (others =>'0');
            else
                if (sRxShift = '1') then
                    if (sClkCounter = "1000") then
                        sRdDataR(15 downto 0) <= sRdDataR(14 downto 0) & sRxData;
                        sRxCount <= sRxCount + '1';
                    end if;    
                end if;  
            end if;
        end if;
    end process;
    
ProcRdData: process (SysClk) --register SPI read data once read instruction is completed
      begin
         if (SysClk'event and SysClk = '1') then
            if (sRst_n = '0') then
               sRdData <= (others => '0');
               sDone <= sDoneFsm;
            else
                sDone <= sDoneFsm;
                if (sDoneFsm = '1') then
                    sRdData <= sRdDataR;
                end if;    
            end if;        
         end if;
      end process;
  
ProcFsmSync: process (SysClk) --State machine synchronous process
      begin
         if (SysClk'event and SysClk = '1') then
            if (sRst_n = '0') then
               sCurrentState <= StIdle;
            else
               sCurrentState <= sNextState;
            end if;        
         end if;
      end process;
      
ProcNextStateAndOutputDecode: process (sCurrentState, sRdEn, sWrEn, sTxCount, sRxCount, sBitCount)
      begin         
         sNextState <= sCurrentState;  
         sDirFsm <= '0';
         sCS_Fsm <= '1';
         sDoneFsm <= '0';
         sRxShift <= '0';
         sTxShift <= '0';
         fsm_state <= (others => '0');
         sRdWr <= '0';
         sLdTx <= '0';
         sSPI_ClkRst <= '1';
         
         case (sCurrentState) is
            when StIdle =>
               fsm_state <= "0000";
               sLdTx <= '1';
               if (sRdEn = '1') then
                  sNextState <= StRead1;
                  sRdWr <= '1';
               elsif (sWrEn = '1') then
                  sNextState <= StWrite;
               end if;
              
            when StRead1 => --send command bytes
                fsm_state <= "0001";
                sCS_Fsm <= '0';
                sTxShift <= '1';
                sRdWr <= '1';
                sSPI_ClkRst <= '0'; 
                if (sTxCount = "10000") then
                    sDirFsm <= '1';
                    sNextState <= StRead2;
                end if;
                
            when StRead2 => --send last command byte; change three state buffer direction
                    fsm_state <= "0010";
                    sDirFsm <= '1';
                    sCS_Fsm <= '0';
                    sTxShift <= '1';
                    sRdWr <= '1';
                    sSPI_ClkRst <= '0'; 
                    if (sTxCount = "10001") then
                        sNextState <= StRead3;
                    end if;
                                    
            when StRead3 => --receive register read data
                fsm_state <= "0011";
                sDirFsm <= '1';
                sCS_Fsm <= '0';
                sRxShift <= '1';
                sRdWr <= '1';
                sSPI_ClkRst <= '0';
                if (sRxCount = sBitCount) then
                    sNextState <= StDone;
                end if;
                
            when StWrite => --send SPI command and register data
                fsm_state <= "0100";
                sCS_Fsm <= '0';
                sTxShift <= '1';
                sSPI_ClkRst <= '0';
                if (sTxCount = (sBitCount + "10001")) then
                    sNextState <= StDone;
                end if;
                
             when StDone => --signal SPI instruction complete
                fsm_state <= "0101";
                sCS_Fsm <= '0';
                sDoneFsm <= '1';
                sNextState <= StIdle;
                     
            when others =>
                fsm_state <= (others => '1');
                sNextState <= StIdle;
         end case;      
      end process;    

ProcRegCS: process (SysClk)
      begin
         if (SysClk'event and SysClk = '1') then
            if (sRst_n = '0') then
               sCS <= '0';
               fsm_state_r <= (others => '0');
            else
               sCS <= sCS_Fsm;
               fsm_state_r <= fsm_state;
            end if;        
         end if;
      end process;
 
ProcRegBitCount: process (SysClk)
     begin
        if (SysClk'event and SysClk = '1') then
           if (sRst_n = '0') then
              sBitCountR <= (others => '0');
           else
              sBitCountR <= sBitCount;
           end if;        
        end if;
     end process;
           
end Behavioral;      