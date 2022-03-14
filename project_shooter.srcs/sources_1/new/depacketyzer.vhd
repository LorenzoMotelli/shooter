----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.03.2022 16:12:15
-- Design Name: 
-- Module Name: depacketyzer - Behavioral
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

entity depacketyzer is

    Generic (
        HEADER_1 : std_logic_vector(7 downto 0) := x"FE";
        HEADER_2 : std_logic_vector(7 downto 0) := x"B0";
        FOOTER_1 : std_logic_vector(7 downto 0) := x"0B";
        FOOTER_2 : std_logic_vector(7 downto 0) := x"EF";
        N_BIT : positive := 8
        );

    Port ( clock : in STD_LOGIC;
           reset : in STD_LOGIC;
           i_data : in STD_LOGIC_VECTOR(N_BIT-1 downto 0);
           i_valid : in STD_LOGIC;
           channel_red : out STD_LOGIC_VECTOR (N_BIT-1 downto 0);
           channel_green : out STD_LOGIC_VECTOR (N_BIT-1 downto 0);
           channel_blue : out STD_LOGIC_VECTOR (N_BIT-1 downto 0);
           o_ready : out STD_LOGIC
           );
end depacketyzer;

architecture Behavioral of depacketyzer is

type state_type is (IDLE, CHECK_HEADER_1, CHECK_HEADER_2, TAKE_RED, TAKE_GREEN, TAKE_BLUE, CHECK_FOOTER_1, CHECK_FOOTER_2, MAKE_COLOR);

signal state : state_type;
signal r : std_logic_vector(N_BIT-1 downto 0);
signal g : std_logic_vector(N_BIT-1 downto 0);
signal b : std_logic_vector(N_BIT-1 downto 0);

begin
    process(clock, reset)
        begin
            if('1' = reset) then
                channel_red <= (others => '0');
                channel_green <= (others => '0');
                channel_blue <= (others => '0');
                o_ready <= '0';
                state <= IDLE;
            elsif (rising_edge(clock)) then
            
                case state is
                
                    when IDLE =>
                        o_ready <= '1';
                        state <= CHECK_HEADER_1;
                    
                    when CHECK_HEADER_1 =>
                        if('1' = i_valid) then
                            if(i_data = HEADER_1) then
                                state <= CHECK_HEADER_2;
                            else
                                state <= IDLE;
                            end if;
                        end if;

                    when CHECK_HEADER_2 =>
                        if('1' = i_valid) then
                            if(i_data = HEADER_2) then
                                state <= TAKE_RED;
                            else
                                state <= IDLE;
                            end if;
                        end if;
                    
                     when TAKE_RED =>
                           if('1' = i_valid) then
                               r <= i_data;
                               state <= TAKE_GREEN;
                           end if;
                           
                       when TAKE_GREEN =>
                           if('1' = i_valid) then  
                               g <= i_data;
                               state <= TAKE_BLUE;
                           end if;
                             
                       when TAKE_BLUE =>
                           if('1' = i_valid) then
                               b <= i_data;
                               state <= CHECK_FOOTER_1;
                           end if;
                    
                    when CHECK_FOOTER_1 =>
                        if('1' = i_valid) then
                            if(i_data = FOOTER_1) then
                                state <= CHECK_FOOTER_2;
                            else
                                state <= IDLE;
                            end if;
                        end if;    

                    when CHECK_FOOTER_2 =>
                        if('1' = i_valid) then
                            if(i_data = FOOTER_2) then
                                state <= MAKE_COLOR;
                                o_ready <= '0';
                            else
                                state <= IDLE;
                            end if;
                        end if;    
   
                    when MAKE_COLOR =>
                        channel_red <= r;
                        channel_green <= g;
                        channel_blue <= b;
                        state <= IDLE;

                end case;
            end if;        
        end process;                
end Behavioral;
