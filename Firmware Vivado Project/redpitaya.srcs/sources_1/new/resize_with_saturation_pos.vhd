----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/24/2019 02:24:18 PM
-- Design Name: 
-- Module Name: resize_with_saturation_pos - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity resize_with_saturation_pos is
	Generic (
		N_INPUT : integer := 20;
		N_OUTPUT : integer := 16
	);
    Port (
        clk : in  STD_LOGIC;
        synchronous_clear : in std_logic;
        data_in : in  signed(N_INPUT-1 downto 0);
        railed_positive : out std_logic;
        railed_negative : out std_logic;
        data_out : out  signed(N_OUTPUT-1 downto 0)
    );
end resize_with_saturation_pos;

architecture Behavioral of resize_with_saturation_pos is
    -- Internal variables
	-----------------------------------------------------------------------
	constant MAX_VALUE : signed(N_OUTPUT-1 downto 0) := shift_left(to_signed(1, N_OUTPUT), N_OUTPUT-1)-1;  -- (2^(N_OUTPUT-1)-1)
	constant MIN_VALUE : signed(N_OUTPUT-1 downto 0) := shift_left(to_signed(0, N_OUTPUT), N_OUTPUT-1);	   -- (0), avoid negative numbers

	signal railed_positive_temp : std_logic := '0';
	signal railed_negative_temp : std_logic := '0';
	signal data_out_temp : signed(N_OUTPUT-1 downto 0) := (others => '0');

begin
    -- Resize with saturation and synchronous clear
	----------------------------------------------------------------
	-- ***describe***
	--
	-- data_out = saturate(data_in)
	-- 1 total clock cycle of delay
	process (clk)
	begin
		if rising_edge(clk) then
			if synchronous_clear = '1' then
				-- Reset state
				data_out_temp <= (others => '0');
				railed_positive_temp <= '0';
				railed_negative_temp <= '0';
			else
				if data_in > MAX_VALUE then
					-- Saturated positive
					data_out_temp <= MAX_VALUE(data_out'range);
					railed_positive_temp <= '1';
					railed_negative_temp <= '0';
				elsif data_in < MIN_VALUE then
					-- Saturated negative
					data_out_temp <= MIN_VALUE(data_out'range);
					railed_positive_temp <= '0';
					railed_negative_temp <= '1';
				else
					-- Linear range
					data_out_temp <= data_in(data_out'range);
					railed_positive_temp <= '0';
					railed_negative_temp <= '0';
				end if;
			end if;
		end if;
	end process;
	
	railed_positive <= railed_positive_temp;
	railed_negative <= railed_negative_temp;
	data_out <= data_out_temp;

end Behavioral;
