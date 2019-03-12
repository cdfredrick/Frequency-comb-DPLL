----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:48:26 12/09/2013 
-- Design Name: 
-- Module Name:    integrator_with_saturation - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: helper_functions.vhd, contains the max_local function: This is a copy-paste of the numeric_std.vhd max() function; I am not sure why the compiler doesn't want to use that one.
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

-- We need this because there is a problem that prevents from using numeric_std.vhd's max() function.
-- this is a copy paste of this function, we 
use work.helper_functions.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity integrator_with_saturation is
	Generic (
		N_INPUT : integer := 20;
		N_OUTPUT : integer := 16
	);
    Port (
        clk : in  STD_LOGIC;
        sclr : in  STD_LOGIC;
        railed_positive : in  STD_LOGIC;
        railed_negative : in  STD_LOGIC;
        data_in : in  signed(N_INPUT-1 downto 0);
        initial_offset : in signed(N_OUTPUT-1 downto 0);
        data_out : out  signed(N_OUTPUT-1 downto 0);
        railed_positive_out : out std_logic;
        railed_negative_out : out std_logic
    );
end integrator_with_saturation;

architecture Behavioral of integrator_with_saturation is
    -- Internal variables
	-----------------------------------------------------------------------
	constant N_BITS_TEMP : integer := MAX_local(N_INPUT, N_OUTPUT)+2;	-- the extra bits are to hold the full, unwrapped result
	signal accumulator : signed(N_OUTPUT-1 downto 0) := (others => '0');
	signal temp_sum : signed(N_BITS_TEMP-1 downto 0) := (others => '0');
	
	constant ACCUM_MAX : signed(N_BITS_TEMP-1 downto 0) := shift_left(to_signed(1, N_BITS_TEMP), N_OUTPUT-1)-1;	   -- (2^(N_OUTPUT-1)-1)
	constant ACCUM_MIN : signed(N_BITS_TEMP-1 downto 0) := shift_left(to_signed(-1, N_BITS_TEMP), N_OUTPUT-1)+1;   -- (-2**(N_OUTPUT-1)+1), avoid the "most negative number"

	-- for debug only:
	-- signal temp_sum_signal : signed(N_BITS_TEMP-1 downto 0) := (others => '0');

begin
    -- Integrator with saturation, anti-windup, and synchronous clear
	----------------------------------------------------------------
	-- A test integration is performed on the first clock cycle, and then that result is
	--     compared with the limits before assigning to the output on the second clock cycle.
	--
	-- data_out = saturate(cumsum(data_in))
	-- 2 total clock cycle of delay
	process (clk)
	begin
		if rising_edge(clk) then
			-- We have three posibilities:
				-- We integrate
				-- We leave the value untouched because we are railed (either internally or further downstream, as indicated by the "railed" flags)
				-- We reset the integrator
			if sclr = '1' then
				-- reset state:
				accumulator <= initial_offset;
				temp_sum <= resize(initial_offset, N_BITS_TEMP);
				railed_positive_out <= '0';
				railed_negative_out <= '0';
			else
			    -- Only assign the result if it won't cause overflow,
				-- and we also don't integrate if the signal chain is railed further downstream (anti-windup behavior)
				if temp_sum > ACCUM_MAX or (railed_positive = '1' and data_in>0) then
					-- Hold current output value
					railed_positive_out <= '1';
					railed_negative_out <= '0';
					-- The next integration contains the current input and the current output.
				    temp_sum <= resize(accumulator, N_BITS_TEMP) + resize(data_in, N_BITS_TEMP);
				elsif temp_sum < ACCUM_MIN or (railed_negative = '1' and data_in<0) then
					-- Hold current output value
					railed_positive_out <= '0';
					railed_negative_out <= '1';
					-- The next integration contains the current input and the current output.
				    temp_sum <= resize(accumulator, N_BITS_TEMP) + resize(data_in, N_BITS_TEMP);
				else
					-- Set new output value
					accumulator <= temp_sum(accumulator'range);
					railed_positive_out <= '0';
					railed_negative_out <= '0';
					-- The next integration contains the current input and the new output ("temp_sum" -> accumulator).
				    temp_sum <= temp_sum + resize(data_in, N_BITS_TEMP);
				end if;
			end if;
		end if;
	end process;
	-- assign output:
	data_out <= accumulator;
	
	-- Only for debug:
	-- temp_sum_signal <= resize(accumulator, N_BITS_TEMP) + resize(data_in, N_BITS_TEMP);	-- only for debug


end Behavioral;

