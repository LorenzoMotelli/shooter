----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.03.2022 12:02:22
-- Design Name: 
-- Module Name: packetizer - Behavioral
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
use IEEE.std_logic_unsigned.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity packetizer is

    Generic (
    HEADER_1 : std_logic_vector(7 downto 0) := x"FE";
    HEADER_2 : std_logic_vector(7 downto 0) := x"B0";
    FOOTER_1 : std_logic_vector(7 downto 0) := x"0B";
    FOOTER_2 : std_logic_vector(7 downto 0) := x"EF";
    DATA_BIT : positive := 8;
    JOY_BIT : positive := 10;
    RATE : positive := 20;
    CLOCK_FREQUENCY_MHZ : positive := 100
    );

    Port ( 
           clock : in STD_LOGIC;
           reset : in STD_LOGIC;
           in_valid : in STD_LOGIC;
           trigger : in STD_LOGIC;
           joy_x : in STD_LOGIC_VECTOR (JOY_BIT-1 downto 0);
           joy_y : in STD_LOGIC_VECTOR (JOY_BIT-1 downto 0);
           m00_axis_tready : in STD_LOGIC;
           m00_axis_tdata : out STD_LOGIC_VECTOR (DATA_BIT-1 downto 0); --input data
           m00_axis_tvalid : out STD_LOGIC --1 if data is valid, otherwise 0
           );
end packetizer;

architecture Behavioral of packetizer is

constant MAX_COUNT : integer := (CLOCK_FREQUENCY_MHZ*1000000)/RATE;
constant MAX_COUNT_SIM : integer := 3;

type state_type is (IDLE, LOAD_HEADER_1, WAIT_H1, LOAD_HEADER_2, WAIT_H2, LOAD_FOOTER_1, WAIT_F1, LOAD_FOOTER_2, WAIT_F2, LOAD_X, WAIT_X, LOAD_Y, WAIT_Y, LOAD_TRIGGER, WAIT_TRIGGER);

signal state : state_type;
signal count : integer range 0 to MAX_COUNT := 0;
signal x : std_logic_vector(JOY_BIT-1 downto 0);
signal y : std_logic_vector(JOY_BIT-1 downto 0);
signal t : std_logic;

begin
    process(clock, reset)
        begin
            if('1' = reset) then
                count <= 0;
                m00_axis_tvalid <= '0';
                state <= IDLE;
            elsif (rising_edge(clock)) then
                
                if('1' = in_valid) then
                    x <= joy_x;
                    y <= joy_y;
                    t <= trigger;
                    --state <= LOAD_FOOTER_1;
                end if;
                
                case state is
                    --IDLE state
                    when IDLE =>
                        if(count = MAX_COUNT-1) then
                            count <= 0;
                            state <= LOAD_HEADER_1;
                        else
                            count <= count+1;
                        end if;

                    when LOAD_HEADER_1 =>
                            m00_axis_tdata <= HEADER_1;
                            m00_axis_tvalid <= '1';
                            state <= WAIT_H1;
                            
                    when WAIT_H1 =>
                        if('1' = m00_axis_tready) then
                            m00_axis_tvalid <= '0';
                            state <= LOAD_HEADER_2;
                        end if;

                    when LOAD_HEADER_2 =>
                            m00_axis_tdata <= HEADER_2;
                            m00_axis_tvalid <= '1';
                            state <= WAIT_H2;
                    
                    when WAIT_H2 =>
                        if('1' = m00_axis_tready) then
                            m00_axis_tvalid <= '0';
                            state <= LOAD_X;
                        end if;
                    
                    when LOAD_X =>
                        m00_axis_tdata <= x(JOY_BIT-1 downto 2);
                        m00_axis_tvalid <= '1';
                        state <= WAIT_X;
                        
                    when WAIT_X =>
                        if('1' = m00_axis_tready) then
                            m00_axis_tvalid <= '0';
                            state <= LOAD_Y;
                        end if;
                        
                    when LOAD_Y =>
                        m00_axis_tdata <= y(JOY_BIT-1 downto 2);
                        m00_axis_tvalid <= '1';    
                        state <= WAIT_Y;
                        
                    when WAIT_Y =>
                        if('1' = m00_axis_tready) then
                            m00_axis_tvalid <= '0';
                            state <= LOAD_TRIGGER;
                        end if;     
                          
                    when LOAD_TRIGGER =>
                        m00_axis_tdata <= (0=>t, others=>'0');
                        m00_axis_tvalid <= '1';
                        state <= WAIT_TRIGGER;
                        
                    when WAIT_TRIGGER =>
                        if('1' = m00_axis_tready) then
                            m00_axis_tvalid <= '0';
                            state <= LOAD_FOOTER_1;
                         end if;
                    
                    when LOAD_FOOTER_1 =>
                        m00_axis_tdata <= FOOTER_1;
                        m00_axis_tvalid <= '1';
                        state <= WAIT_F1;
                        
                    when WAIT_F1 =>
                        if('1' = m00_axis_tready) then
                            m00_axis_tvalid <= '0';
                            state <= LOAD_FOOTER_2;
                         end if;    
                        
                    when LOAD_FOOTER_2 =>
                        m00_axis_tdata <= FOOTER_2;
                        m00_axis_tvalid <= '1';
                        state <= WAIT_F2;
                     
                    when WAIT_F2 =>
                        if('1' = m00_axis_tready) then
                            m00_axis_tvalid <= '0';
                            state <= IDLE;
                        end if;
                                    
                end case;           
            end if;
            
        end process;
end Behavioral;
