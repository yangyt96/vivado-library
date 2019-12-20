----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
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

entity DAC_SPI is
    Port (
           CLK : in STD_LOGIC;
           RST : in STD_LOGIC;
           SPI_CLK : out STD_LOGIC;
           SDIO : inout STD_LOGIC;
           CS : out STD_LOGIC;
           --TEST : out std_logic;
           
           START_TRANSFER : in std_logic;
           RD_DATA : out std_logic_vector(7 downto 0);
           WR_DATA : in std_logic_vector(7 downto 0);
           ADDRESS : in std_logic_vector(4 downto 0);
           WIDTH : in std_logic_vector(1 downto 0); --only one byte rx/tx supported
           RD_WR : in STD_LOGIC; 
           DONE : out STD_LOGIC
         );
end DAC_SPI;

architecture Behavioral of DAC_SPI is

type states is (ST_WRITE, ST_READ1,ST_READ3, ST_ERROR, StIdle, ST_DONE, ST_DLY_DIR_CS, ST_RST_DLY, ST_DLY_DIR, DECODE); 
signal spi_sCurrentState, spi_sNextState : states;
signal rx_data, tx_data, tx_shift, rx_shift, rst_dir, spi_clk_rst : std_logic;
signal rd_data_r : std_logic_vector(7 downto 0);
signal tx_vector : std_logic_vector (15 downto 0);
signal dir, dir_fsm : std_logic;
signal clk_counter : std_logic_vector(3 downto 0);
signal tx_count, rx_count, nr_bits, nr_bits_r : std_logic_vector(4 downto 0);
signal ld_rx_fsm, ld_rx_fsm_r, ld_rx_pulse, ld_rd_data : std_logic;
signal done_fsm, done_fsm_r, done_fsm_rr, CS_fsm : std_logic;
signal fsm_state, fsm_state_r : std_logic_vector(3 downto 0);
signal Start_Transfer_r, Start_Transfer_pulse : std_logic;

signal delay_cnt : std_logic_vector (5 downto 0);
signal delay_inc, delay_rst : std_logic;

signal read_en, write_en: std_logic;

--    attribute mark_debug : string;
--    attribute keep : string;
--    attribute mark_debug of fsm_state : signal is "true";
--    attribute keep of fsm_state : signal is "true";
--    attribute mark_debug of START_TRANSFER : signal is "true";
--    attribute keep of START_TRANSFER : signal is "true";
--    attribute mark_debug of Start_Transfer_pulse : signal is "true";
--    attribute keep of Start_Transfer_pulse : signal is "true";
--    attribute mark_debug of Start_Transfer_r : signal is "true";
--    attribute keep of Start_Transfer_r : signal is "true";
--    attribute mark_debug of rst_dir : signal is "true";
--    attribute keep of rst_dir : signal is "true";
--    attribute mark_debug of rd_data_r : signal is "true";
--    attribute keep of rd_data_r : signal is "true";
--    attribute mark_debug of tx_vector : signal is "true";
--    attribute keep of tx_vector : signal is "true";
--    attribute mark_debug of dir : signal is "true";
--    attribute keep of dir : signal is "true";
--    attribute mark_debug of CS : signal is "true";
--    attribute keep of CS : signal is "true";
--    attribute mark_debug of tx_count : signal is "true";
--    attribute keep of tx_count : signal is "true";
--    attribute mark_debug of rx_count : signal is "true";
--    attribute keep of rx_count : signal is "true";
--    attribute mark_debug of tx_shift : signal is "true";
--    attribute keep of tx_shift : signal is "true";
--    attribute mark_debug of rx_shift : signal is "true";
--    attribute keep of rx_shift : signal is "true";
--    attribute mark_debug of tx_data : signal is "true";
--    attribute keep of tx_data : signal is "true";
--    attribute mark_debug of rx_data : signal is "true";
--    attribute keep of rx_data : signal is "true";
--    attribute mark_debug of nr_bits_r : signal is "true";
--    attribute keep of nr_bits_r : signal is "true";
--    attribute mark_debug of RST : signal is "true";
--    attribute keep of RST : signal is "true";
--    attribute mark_debug of clk_counter : signal is "true";
--    attribute keep of clk_counter : signal is "true";
--    attribute mark_debug of SPI_CLK : signal is "true";
--    attribute keep of SPI_CLK : signal is "true";
--    attribute mark_debug of DONE : signal is "true";
--    attribute keep of DONE : signal is "true";
--    attribute mark_debug of RD_DATA : signal is "true";
--    attribute keep of RD_DATA : signal is "true";
--    attribute mark_debug of RD_WR : signal is "true";
--    attribute keep of RD_WR : signal is "true";
            
begin

--TEST <= done_fsm;--Start_Transfer_pulse;
read_en <= '1' when RD_WR = '1' else '0';
write_en <= '0' when RD_WR = '1' else '1';

   IOBUF_inst : IOBUF
   generic map (
      DRIVE => 12,
      IOSTANDARD => "LVCMOS18",
      SLEW => "SLOW")
   port map (
      O => rx_data,     -- Buffer output
      IO => SDIO,   -- Buffer inout port (connect directly to top-level port)
      I => tx_data,     -- Buffer input
      T => dir      -- 3-state enable input, high=input, low=output 
   );

DELAY_COUNTER_PROC: process (CLK)  
      begin
          if (CLK' event and CLK = '1') then
              if ((RST = '0') or (delay_rst = '1')) then
                  delay_cnt <= (others => '0');
              else
                if (delay_inc = '1') then 
                    delay_cnt <= delay_cnt + '1';
                end if;    
              end if;
          end if;
      end process; 
   
START_TRANSFER_PROC: process (CLK)  
    begin
        if (CLK' event and CLK = '1') then
            if (RST = '0') then
                Start_Transfer_r <= '0';
                done_fsm_r <= '0';
                done_fsm_rr <= '0';
                ld_rx_fsm_r <= '0';
            else
                Start_Transfer_r <= START_TRANSFER;
                done_fsm_r  <= done_fsm;
                done_fsm_rr <= done_fsm_r;
                ld_rx_fsm_r <= ld_rx_fsm;
            end if;
        end if;
    end process;    

Start_Transfer_pulse <= (not Start_Transfer_r) and START_TRANSFER;
ld_rx_pulse <= (not ld_rx_fsm_r) and ld_rx_fsm;
   
CLK_COUNTER_PROC: process (CLK)  
      begin
          if (CLK' event and CLK = '1') then
              if (RST = '0') then
                  clk_counter <= (others => '0');
              else
                  if (spi_clk_rst = '0') then
                    clk_counter <= clk_counter + '1';
                  else
                    if (clk_counter > "1000") then --finish clock period
                        clk_counter <= clk_counter + '1';
                    else
                        clk_counter <= (others => '0');   
                    end if; 
                  end if;   
              end if;
          end if;
      end process; 

SPI_CLK <= clk_counter(3); --divide input clock by 16                   

nr_bits <= (WIDTH + '1') & "000";

SHIFT_TX_PROC: process (CLK)  -- SYS_CLK = 100MHz => AP_START=1MHz
      begin
          if (CLK' event and CLK = '1') then
              if ((RST = '0') or (Start_Transfer_pulse = '1')) then
                  tx_vector <= RD_WR & WIDTH & ADDRESS & WR_DATA;
                  tx_count <= (others => '0');
                  tx_data <= '0';
              else
                if(tx_shift = '1') then 
                    if (clk_counter = "0100") then
                      tx_vector(15 downto 0) <= tx_vector(14 downto 0) & '0';
                      tx_count <= tx_count + '1';
                      tx_data <= tx_vector(15);
                    end if;  
                end if;    
              end if;
          end if;
      end process;

DIR_PROC: process (CLK)  -- SYS_CLK = 100MHz => AP_START=1MHz
      begin
          if (CLK' event and CLK = '1') then
              if ((RST = '0') or (rst_dir = '1')) then
                  dir <= dir_fsm;
              else
                --if (clk_counter = "1111") then
                      dir <= dir_fsm;
                --end if;  
              end if;    
          end if;
      end process;
 
SHIFT_RX_PROC: process (CLK)  -- SYS_CLK = 100MHz => AP_START=1MHz
    begin
        if (CLK' event and CLK = '1') then
            if ((RST = '0') or (rx_shift = '0')) then
                rd_data_r <= (others =>'0');
                rx_count <= (others =>'0');
            else
                if (rx_shift = '1') then
                    if ((clk_counter = "1011") or (ld_rd_data = '1')) then
                        rd_data_r(7 downto 0) <= rd_data_r(6 downto 0) & rx_data;
                        rx_count <= rx_count + '1';
                    end if;    
                end if;  
            end if;
        end if;
    end process;
    
RD_DATA_PROC: process (CLK, rst)
      begin
         if (CLK'event and CLK = '1') then
            if (rst = '0') then
               RD_DATA <= (others => '0');
               DONE <= '0';
            else
                DONE <= (not done_fsm_rr) and done_fsm_r;
                if (ld_rx_pulse = '1') then
                    RD_DATA <= rd_data_r;
                end if;    
            end if;        
         end if;
      end process;
  
FSM_SYNC_PROC: process (CLK, rst)
      begin
         if (CLK'event and CLK = '1') then
            if (rst = '0') then
               spi_sCurrentState <= StIdle;
            else
               spi_sCurrentState <= spi_sNextState;
            end if;        
         end if;
      end process;
      
sNextState_DECODE: process (spi_sCurrentState, tx_count, rx_count, nr_bits, Start_Transfer_pulse, delay_cnt)
      begin         
         spi_sNextState <= spi_sCurrentState;  
         dir_fsm <= '0';
         CS_fsm <= '1';
         done_fsm <= '0';
         rx_shift <= '0';
         tx_shift <= '0';
         fsm_state <= (others => '0');
         rst_dir <= '0';
         spi_clk_rst <= '1';
         delay_rst <= '1';
         delay_inc <= '0';
         ld_rx_fsm <= '0';
         ld_rd_data <= '0';
         
         case (spi_sCurrentState) is
            when StIdle =>
               fsm_state <= "0000";
               dir_fsm <= '0';
               CS_fsm <= '1';
               done_fsm <= '0';
               rx_shift <= '0';
               tx_shift <= '0';
               rst_dir <= '1';
               spi_clk_rst <= '1';
               if (Start_Transfer_pulse = '1') then
                   if (read_en = '1') then
                       spi_sNextState <= ST_READ1;
                   elsif (write_en = '1') then
                       spi_sNextState <= ST_WRITE;
                   end if;
               end if;
               
            when DECODE =>
                fsm_state <= "0001";
                if (RD_WR = '0') then
                    spi_sNextState <= ST_WRITE;
                else
                    spi_sNextState <= ST_READ1;
                end if; 
              
            when ST_READ1 =>
                fsm_state <= "0010";
                dir_fsm <= '0';
                CS_fsm <= '0';
                done_fsm <= '0';
                rx_shift <= '0';
                tx_shift <= '1';
                spi_clk_rst <= '0'; 
                if (tx_count = "01000") then
                    --dir_fsm <= '1';
                    spi_sNextState <= ST_DLY_DIR; 
                end if;       

            when ST_DLY_DIR => 
                fsm_state <= "0100";
                delay_rst <= '0';
                delay_inc <= '1'; 
                dir_fsm <= '0';
                spi_clk_rst <= '0'; 
                CS_fsm <= '0';
                rx_shift <= '1';
                tx_shift <= '0';          
                if (delay_cnt = "000100") then --hold DIR low for another 1/4 period
                    spi_sNextState <= ST_READ3;
                end if;      
                                                  
            when ST_READ3 =>
                fsm_state <= "0101";
                dir_fsm <= '1';
                CS_fsm <= '0';
                done_fsm <= '0';
                rx_shift <= '1';
                tx_shift <= '0';
                spi_clk_rst <= '0';
                if (rx_count = "01000") then
                    spi_sNextState <= ST_DLY_DIR_CS;
                end if;
            
            when ST_DLY_DIR_CS =>
                fsm_state <= "0110";
                dir_fsm <= '1';
                CS_fsm <= '0';
                delay_rst <= '0';
                delay_inc <= '1';
                rx_shift <= '1';
                if (delay_cnt = "001000") then
                    spi_sNextState <= ST_RST_DLY;
                end if;
              
            when ST_RST_DLY =>
                fsm_state <= "0111";
                delay_rst <= '1';
                CS_fsm <= '1';
                spi_clk_rst <= '1';
                rx_shift <= '1';
                ld_rd_data <= '1';
                spi_sNextState <= ST_DONE;
                    
                
            when ST_WRITE =>
                fsm_state <= "1000";
                dir_fsm <= '0';
                CS_fsm <= '0';
                done_fsm <= '0';
                rx_shift <= '0';
                tx_shift <= '1';
                spi_clk_rst <= '0';
                if (tx_count = (nr_bits + "01001")) then
                    spi_sNextState <= ST_DONE;
                end if;
                
             when ST_DONE =>
                fsm_state <= "1001";
                dir_fsm <= '0';
                CS_fsm <= '1';
                rx_shift <= '1';
                tx_shift <= '0';
                spi_clk_rst <= '1';
                delay_rst <= '0';
                delay_inc <= '1';
                ld_rx_fsm <= '1';
                if (delay_cnt = "111111") then
                    spi_sNextState <= StIdle;
                    done_fsm <= '1';
                end if;    
                     
            when others =>
                fsm_state <= (others => '1');
                spi_sNextState <= StIdle;
         end case;      
      end process;    

FSM_OUT_PROC: process (CLK, rst)
      begin
         if (CLK'event and CLK = '1') then
            if (rst = '0') then
               CS <= '0';
               fsm_state_r <= (others => '0');
               nr_bits_r <= (others => '0');
            else
               CS <= CS_fsm;
               fsm_state_r <= fsm_state;
               nr_bits_r <= nr_bits;
            end if;        
         end if;
      end process;
      
end Behavioral;      