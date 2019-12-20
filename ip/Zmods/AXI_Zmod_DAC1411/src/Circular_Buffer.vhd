----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/13/2019 12:38:29 PM
-- Design Name: 
-- Module Name: Circular_Buffer - Behavioral
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

entity Circular_Buffer is
    Generic 
    (
    kBufferSize: integer range 0 to 1024 := 14
    );
    Port ( SysClk : in STD_LOGIC;
           AxiStreamClk : in STD_LOGIC;
           AxiLiteClk : in std_logic;
           sRst_n : in STD_LOGIC;
           xsRst_n : in STD_LOGIC;
           sInitDone_n: in STD_LOGIC;
           sCh1Out : out STD_LOGIC_VECTOR (13 downto 0);
           sCh2Out : out STD_LOGIC_VECTOR (13 downto 0);
           
           s_axis_mm2s_tdata : in STD_LOGIC_VECTOR(31 DOWNTO 0);
           s_axis_mm2s_tkeep : in STD_LOGIC_VECTOR(3 DOWNTO 0);
           s_axis_mm2s_tvalid : in STD_LOGIC;
           s_axis_mm2s_tready : out STD_LOGIC;
           s_axis_mm2s_tlast : in STD_LOGIC;
           
           sDacEn: in STD_LOGIC;
           sTransferLength : in STD_LOGIC_VECTOR (kBufferSize-1 downto 0);
           xsTransferLength : in std_logic_vector (kBufferSize-1 downto 0); 
           sOutAddrCntRst : in std_logic;
           sDivRate : in std_logic_vector(13 downto 0);
           lBufferFull : out STD_LOGIC
          );
end Circular_Buffer;

architecture Behavioral of Circular_Buffer is

COMPONENT blk_mem_gen_0
  PORT (
    clka : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    clkb : IN STD_LOGIC;
    enb : IN STD_LOGIC;
    addrb : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(0 DOWNTO 0)
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

type BufferDataArray_t is array (27 downto 0) of std_logic_vector(0 downto 0);
type WeDataArray_t is array (27 downto 0) of std_logic_vector(0 downto 0);
type FsmStates_t is (StIdle, StArm, StWaitTrigger, StLoadBufferNormal, StLoadBufferNone, StBufferFullPush, StBufferFullAck, StSendBufferDummy, 
StSendBuffer, StSetStop, StSetStopAck, StOutAddrCntPush, StOutAddrCntAck, StWaitStop);
--Active high reset signal 
signal aRst_p : std_logic;
--Buffer write channel related signals
signal xsBufferInputData : std_logic_vector (27 downto 0);
signal xsEnaBuffer : std_logic_vector (27 downto 0);
signal xsBitValid : std_logic_vector (31 downto 0);
signal xsWeaBuffer : std_logic_vector (27 downto 0);
signal xsWeaArray : WeDataArray_t;
signal xsBufferInputArray : BufferDataArray_t;
signal xsInAddrCounter, xsInAddrCounterR : std_logic_vector (kBufferSize-1 downto 0); --conter used to generate the BRAM write port address
--Buffer read channel and BRAM to Axi Stream related signals
signal sBufferOutputData : std_logic_vector (27 downto 0);
signal sEnbBuffer : std_logic_vector (27 downto 0);
signal sBufferOutArray : BufferDataArray_t;
signal sOutAddrCntAux : std_logic_vector (13 downto 0);
signal sOutAddrCntEn : std_logic;
signal sOutAddrCounter, sOutAddrCounterR : std_logic_vector (kBufferSize-1 downto 0);
signal xsBufferFull : std_logic; --flag indicating that the buffer was loaded successfuly
signal sLoadOutCnt : std_logic_vector (0 downto 0); --signal that resets the BRAM read address port counter once the buffer is filled (in system clock domain)
signal xsLoadOutCnt : std_logic; --signal that resets the BRAM read address port counter once the buffer is filled (in system Axi Stream clock domain)
signal xsTvalidDisable : std_logic; --signal used to deassert s_axis_s2mm_tvalid once all requested bytes have been transfered
--Buffer control state machine related signals
signal sCurrentState, sNextState : FsmStates_t;
signal fsmcfg_state, fsmcfg_state_r : std_logic_vector(4 downto 0);
--Axi Stream interface related signals

--Control register and status register write strobe signals
signal sBufferFull : std_logic_vector(0 downto 0); --pulse indicating the buffer has aquired the requested amount of data
--Clock domain crossing related signals
signal sBufFullRdy, sBufFullPush, lBufFullValid : std_logic;
    
    attribute mark_debug : string;
    attribute keep : string;
    
--    attribute mark_debug of lBufferFull : signal is "true";
--    attribute keep of lBufferFull : signal is "true";
--    attribute mark_debug of sBufferOutputData : signal is "true";
--    attribute keep of sBufferOutputData : signal is "true";
--    attribute mark_debug of xsBufferInputData : signal is "true";
--    attribute keep of xsBufferInputData : signal is "true";
    attribute mark_debug of s_axis_mm2s_tdata : signal is "true";
    attribute keep of s_axis_mm2s_tdata : signal is "true";
    attribute mark_debug of s_axis_mm2s_tkeep : signal is "true";
    attribute keep of s_axis_mm2s_tkeep : signal is "true";
    attribute mark_debug of s_axis_mm2s_tlast : signal is "true";
    attribute keep of s_axis_mm2s_tlast : signal is "true";    
    attribute mark_debug of s_axis_mm2s_tvalid : signal is "true";
    attribute keep of s_axis_mm2s_tvalid : signal is "true"; 
    attribute mark_debug of xsInAddrCounter : signal is "true";
    attribute keep of xsInAddrCounter : signal is "true";
    attribute mark_debug of sOutAddrCounter : signal is "true";
    attribute keep of sOutAddrCounter : signal is "true";
    attribute mark_debug of sDacEn : signal is "true";
    attribute keep of sDacEn : signal is "true";
--    attribute mark_debug of sTransferLength : signal is "true";
--    attribute keep of sTransferLength : signal is "true";
    attribute mark_debug of sOutAddrCntEn : signal is "true";
    attribute keep of sOutAddrCntEn : signal is "true";
    attribute mark_debug of sOutAddrCntAux : signal is "true";
    attribute keep of sOutAddrCntAux : signal is "true";
    attribute mark_debug of sDivRate : signal is "true";
    attribute keep of sDivRate : signal is "true";
    attribute mark_debug of sOutAddrCntRst : signal is "true";
    attribute keep of sOutAddrCntRst : signal is "true";
    attribute mark_debug of sCh1Out : signal is "true";
    attribute keep of sCh1Out : signal is "true";
    attribute mark_debug of sCh2Out : signal is "true";
    attribute keep of sCh2Out : signal is "true";
                
begin

aRst_p <= not sRst_n;
s_axis_mm2s_tready <= '1';
xsBufferInputData <= s_axis_mm2s_tdata(31 downto 18) & s_axis_mm2s_tdata(15 downto 2);

--Tkeep: Null bytes are only used for signaling packet remainders.
--Leading or intermediate Null bytes are generally not
--supported.

--ProcBitValidAssign : process (s_axis_mm2s_tkeep, s_axis_mm2s_tvalid)
--begin
--    for IndexTkeep in 0 to 3 loop
--	    for Index in 0 to 7 loop
--            if ((s_axis_mm2s_tvalid = '1') and (s_axis_mm2s_tkeep(IndexTkeep) = '1')) then
--                xsBitValid(IndexTkeep*4 + Index) <= '1';
--            else
--                xsBitValid(IndexTkeep*4 + Index) <= '0';
--            end if;
--        end loop;    
--    end loop;
--end process;

--xsWeaBuffer <= xsBitValid(31 downto 18) & xsBitValid(17 downto 2);

ProcBufferPortAssign : process (xsWeaBuffer)
begin
	for Index in 0 to 27 loop
        xsWeaArray(Index)(0) <= s_axis_mm2s_tvalid; --assume tkeep = "1111" for all valid data;
        xsBufferInputArray(Index)(0) <= xsBufferInputData(Index);
        sBufferOutputData(Index) <= sBufferOutArray(Index)(0);
    end loop;
end process;
xsEnaBuffer <= (others => '1');
sEnbBuffer <= (others => '1');  

GenerateBuffer : for Index in 0 to 27 generate     
  
    InstBRAM_Buffer : blk_mem_gen_0
      PORT MAP (
        clka => AxiStreamClk,
        ena => xsEnaBuffer(Index),
        wea => xsWeaArray(Index),
        addra => xsInAddrCounter,
        dina => xsBufferInputArray(Index),
        clkb => SysClk,
        enb => sEnbBuffer(Index),
        addrb => sOutAddrCounter,
        doutb => sBufferOutArray(Index)
      );        
 end generate GenerateBuffer;
 
 sCh1Out <= sBufferOutputData(27 downto 14);
 sCh2Out <= sBufferOutputData(13 downto 0);
 
 --Input Buffer Address Counter
ProcInAddrCounter: process (AxiStreamClk)  
begin
    if (AxiStreamClk' event and AxiStreamClk = '1') then
        if ((xsRst_n = '0') or (s_axis_mm2s_tlast = '1'))then
            xsInAddrCounter <= (others => '0');
            xsInAddrCounterR <= (others => '0');
        else
            xsInAddrCounterR <= xsInAddrCounter;
            if(s_axis_mm2s_tvalid = '1') then
                xsInAddrCounter <= xsInAddrCounter + '1';
            end if;        
        end if;
    end if;
end process;

ProcBufferFull: process (AxiStreamClk)  
begin
    if (AxiStreamClk' event and AxiStreamClk = '1') then
        if (xsRst_n = '0') then
            xsBufferFull <= '0';
        else
            if ((s_axis_mm2s_tlast = '1') and (xsInAddrCounter = xsTransferLength - '1')) then
                xsBufferFull <= '1';    
            else
                xsBufferFull <= '0';
            end if;    
        end if;
    end if;
end process;

ProcOutAddrCntEn: process (SysClk)  
begin
    if (SysClk' event and SysClk = '1') then
        if (sRst_n = '0' or sOutAddrCntRst = '1') then
            sOutAddrCntAux <= (others => '0');
            sOutAddrCntEn <= '0';
        else
            if(sDacEn = '1') then
                if(sOutAddrCntAux = sDivRate) then
                    sOutAddrCntAux <= (others => '0');
                    sOutAddrCntEn <= '1';
                else
                    sOutAddrCntAux <= sOutAddrCntAux + '1';
                    sOutAddrCntEn <= '0';
                end if;
            end if;        
        end if;
    end if;
end process;

ProcOutAddrCounter: process (SysClk)  
begin
    if (SysClk' event and SysClk = '1') then
        if (sRst_n = '0' or sOutAddrCntRst = '1') then
            sOutAddrCounter <= (others => '0');
            sOutAddrCounterR <= (others => '0');
        else
            sOutAddrCounterR <= sOutAddrCounter;
            if((sDacEn = '1') and (sOutAddrCntEn = '1'))then
                if(sOutAddrCounter = (sTransferLength - '1')) then
                    sOutAddrCounter <= (others => '0');
                else
                    sOutAddrCounter <= sOutAddrCounter + '1';
                end if;
            end if;        
        end if;
    end if;
end process;
 
--ProcSyncFSM: process (SysClk, sRst_n)
--      begin
--         if (SysClk'event and SysClk = '1') then
--            if ((sInitDone_n = '1') or (sRst_n = '0'))then
--               sCurrentState <= StIdle;
--               fsmcfg_state_r <= fsmcfg_state;
--            else
--               sCurrentState <= sNextState;
--               fsmcfg_state_r <= fsmcfg_state;
--            end if;        
--         end if;
--      end process;
      
--ProcNextStateAndOutputDecode: process (sCurrentState)
--begin 
--    sNextState <= sCurrentState;  
--    fsmcfg_state <= "00000";  
--    sBufferFull <= "0";
--    sBufFullPush <= '0';
--    sLoadOutCnt <= "0";
    
--    case (sCurrentState) is
--        when StIdle =>
--        fsmcfg_state <= "00000";
               
--        when others =>
--            sNextState <= StIdle;
--        end case;      
--end process;      

----------------------------------------CLOCK DOMAIN CROSSING----------------------------------------------------------

InstBufFullHandShake : HandshakeData -- synchronization module for AXI LITE LENGTH register crossing to PROG_CLK clock domain 
generic map (
    kDataWidth	=> 1
    )
    Port map (
        InClk => AxiStreamClk,
        OutClk => AxiLiteClk,
        iData => "1",
        oData => open,   -- synchronized output
        iPush => xsBufferFull,
        iRdy => open,  
        oAck => '1',  
        oValid => lBufFullValid,   -- indicates valid synchronized data
        aReset => aRst_p
        );
lBufferFull <= lBufFullValid;
                
end Behavioral;
