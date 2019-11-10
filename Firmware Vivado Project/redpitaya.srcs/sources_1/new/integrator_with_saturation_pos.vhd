----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/24/2019 02:20:48 PM
-- Design Name: 
-- Module Name: integrator_with_saturation_pos - Behavioral
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

-- We need this because there is a problem that prevents from using numeric_std.vhd's max() function.
-- this is a copy paste of this function, we 
use work.helper_functions.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity integrator_with_saturation_pos is
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
end integrator_with_saturation_pos;

architecture Behavioral of integrator_with_saturation_pos is
    -- Internal variables
	-----------------------------------------------------------------------
	constant N_BITS_TEMP : integer := MAX_local(N_INPUT, N_OUTPUT)+2;	-- the extra bits are to hold the full, unwrapped result
	signal accumulator : signed(N_OUTPUT-1 downto 0) := (others => '0');
	signal temp_sum : signed(N_BITS_TEMP-1 downto 0) := (others => '0');
	
	constant ACCUM_MAX : signed(N_BITS_TEMP-1 downto 0) := shift_left(to_signed(1, N_BITS_TEMP), N_OUTPUT-1)-1;	   -- (2^(N_OUTPUT-1)-1)
	constant ACCUM_MIN : signed(N_BITS_TEMP-1 downto 0) := shift_left(to_signed(0, N_BITS_TEMP), N_OUTPUT-1);      -- (0), avoid negative numbers.

	-- for debug only:
	-- signal temp_sum_signal : signed(N_BITS_TEMP-1 downto 0) := (others => '0');

begin
    -- Integrator with saturation, anti-windup, and synchronous clear
	----------------------------------------------------------------
	-- The sum is clamped between the minimum and maximum values of the output bit size.
	-- To ease timing constraints the sum and clamping occur on adjacent clock cycles.
	--
	-- data_out = saturate(cumsum(data_in))
	-- 2 total clock cycle of delay
	process (clk)
	begin
		if rising_edge(clk) then
			-- We have three posibilities:
			    -- We reset the integrator
				-- We integrate (with saturation and anti-windup)
			if sclr = '1' then
				-- reset state:
				accumulator <= initial_offset;
				temp_sum <= resize(initial_offset, N_BITS_TEMP);
				railed_positive_out <= '0';
				railed_negative_out <= '0';
			else
			    -- Only assign the result if it won't cause overflow,
				-- and we also don't integrate if the signal chain is railed further downstream (anti-windup behavior)
				if (temp_sum > ACCUM_MAX) then
					-- Clamp the output value at the maximum
					accumulator <= ACCUM_MAX(accumulator'range);
					railed_positive_out <= '1';
					railed_negative_out <= '0';
					-- Integrate off of the maximum value
				    temp_sum <= ACCUM_MAX + resize(data_in, N_BITS_TEMP);
				elsif (temp_sum < ACCUM_MIN) then
					-- Clamp the output value at the minimum
					accumulator <= ACCUM_MIN(accumulator'range);
					railed_positive_out <= '0';
					railed_negative_out <= '1';
					-- Integrate off of the minimum value
				    temp_sum <= ACCUM_MIN + resize(data_in, N_BITS_TEMP);
				else
					-- Set new output value
					accumulator <= temp_sum(accumulator'range);
					railed_positive_out <= '0';
					railed_negative_out <= '0';
					if ((railed_positive = '1') and (data_in > 0)) or ((railed_negative = '1') and (data_in < 0)) then
					   -- Don't integrate if railed positive with positive input or railed negative with negative input
					else
					   -- Integrate
				        temp_sum <= temp_sum + resize(data_in, N_BITS_TEMP);
					end if;
				end if;
			end if;
		end if;
	end process;
	-- assign output:
	data_out <= accumulator;

end Behavioral;
