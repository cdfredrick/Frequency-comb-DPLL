----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/24/2019 11:56:37 AM
-- Design Name: 
-- Module Name: PLL_loop_filters_RF_to_optical - Behavioral
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



entity PLL_loop_filters_RF_to_optical is
	Generic (
		-- Constants which control the scaling:
		-- Each branch's output is divided by 2^N
		N_OUTPUT 	: integer := 48;
		N_DIVIDE_I 	: integer := 20;
		N_DIVIDE_II : integer := 38
	);
    Port (
		clk             : in  std_logic;
		lock            : in  std_logic;
		pll_changed     : in  std_logic;
		data_in         : in  signed(10-1 downto 0);
		gain_i          : in  signed(64-1 downto 0);
		gain_ii         : in  signed(64-1 downto 0);
		offset_in       : in  signed(N_OUTPUT-1 downto 0);
		phase_residuals : out signed(32-1 downto 0);
		data_out        : out signed(N_OUTPUT-1 downto 0);
		saturated_low   : out std_logic;
		saturated_high  : out std_logic
    );
end PLL_loop_filters_RF_to_optical;


architecture Behavioral of PLL_loop_filters_RF_to_optical is
	--CoreGen declarations
	-----------------------------------------------------------------------
	
	-- Multiplier, 10x64 input bits, 74 output bits, synchronous clear
	-- Uses LUTs instead of DSP slices.
	-- 6 clock cycles of delay
	COMPONENT pll_10x64_mult_LUT
    PORT (
        clk : IN STD_LOGIC;
        a : IN signed(10-1 DOWNTO 0);
        b : IN signed(64-1 DOWNTO 0);
        sclr : IN STD_LOGIC;
        p : OUT signed(74-1 DOWNTO 0)
      );
    END COMPONENT;
	
	
	-- Internal variables
	-----------------------------------------------------------------------
	constant no_clear : std_logic := '0';
	
	-- N Bits for each branch's output = N_OUTPUT+2
	-- The extra bits are to prevent any channel from saturating before the sum.
	constant N_OUTPUT_B : integer := N_OUTPUT + 2;
	
	-- Phase residuals monitor
	constant N_BITS_PHASE_RESULT   : integer := 32;
	signal phase_error_accumulator : signed(N_BITS_PHASE_RESULT-1 downto 0) := (others => '0');
	   -- the extra bit in these signals is to hold the full, unwrapped result
	constant PHASE_ACCUM_MAX : signed((N_BITS_PHASE_RESULT+1)-1 downto 0) := shift_left(to_signed(1, N_BITS_PHASE_RESULT+1), N_BITS_PHASE_RESULT-1)-1;	-- (2^(N_BITS_PHASE_RESULT-1)-1)
	constant PHASE_ACCUM_MIN : signed((N_BITS_PHASE_RESULT+1)-1 downto 0) := shift_left(to_signed(-1, N_BITS_PHASE_RESULT+1), N_BITS_PHASE_RESULT-1);	-- (-2**(N_BITS_PHASE_RESULT-1)

	
	-- I branch signals
	signal i_mult_out                              : signed(74-1 downto 0) := (others => '0');
	signal i_offset_in                             : signed((N_OUTPUT_B+N_DIVIDE_I)-1 downto 0) := (others => '0');
	signal i_accumulator_out                       : signed((N_OUTPUT_B+N_DIVIDE_I)-1 downto 0) := (others => '0');
	signal i_railed_positive, i_railed_negative    : std_logic := '0';
	signal i_out                                   : signed(N_OUTPUT_B-1 downto 0) := (others => '0');

	-- II branch signals
	signal ii_mult_out                                                 : signed(74-1 downto 0) := (others => '0');
	signal ii_1st_stage_offset_in                                      : signed((N_OUTPUT_B+N_DIVIDE_II)-1 downto 0) := (others => '0');
	signal ii_1st_stage_accumulator_out                                : signed((N_OUTPUT_B+N_DIVIDE_II)-1 downto 0) := (others => '0');
	signal ii_1st_stage_railed_positive, ii_1st_stage_railed_negative  : std_logic := '0';
	signal ii_2nd_stage_offset_in                                      : signed((N_OUTPUT_B+N_DIVIDE_II)-1 downto 0) := (others => '0');
	signal ii_2nd_stage_accumulator_out                                : signed((N_OUTPUT_B+N_DIVIDE_II)-1 downto 0) := (others => '0');
	signal ii_railed_positive, ii_railed_negative                      : std_logic := '0';
	signal ii_out                                                      : signed(N_OUTPUT_B-1 downto 0) := (others => '0');

	
	-- Summing node signals
	signal output_sum                                      : signed((N_OUTPUT_B+1)-1 downto 0) := (others => '0');   -- the extra bit is to handle the full range result without overflowing
	signal sum_railed_negative, sum_railed_positive        : std_logic := '0'; -- this is used for the anti-windup behavior (we stop integrating if the sum is railed, even if the integrator isn't)
	
	-- Flags which indicate internal state
	signal synchronous_clear                               : std_logic := '0'; -- resets everything, asserted when either or lock = '0'
	signal saturated_high_internal, saturated_low_internal : std_logic := '0'; -- indicates to the external world when one of the internal signal is saturated


begin
	-- Synchronous clear of the internal signals either when we are out of lock, or when the gains are changed:
	synchronous_clear <= pll_changed or not lock;
    
    
    -- Phase Residuals Monitor
	----------------------------------------------------------------
    -- This saturating accumulator integrates the frequency error to yield the phase error, and its result is used to monitor the lock state.
	-- We arbitrarily decide on using 32 bits for the result.
	-- The freq error has 10 fractional bits which means that there are 22 integer bits of phase error, or 2e6 * 2*pi radians of linear range.
	-- NO ANTI-WINDUP: this is by design because having anti-windup here would mean not integrating part of the error signal.
	--
	-- phase_residuals = saturate(cumsum(data_in))
	-- 1 total clock cycle of delay
	process (clk)
		variable temp_sum : signed((phase_error_accumulator'length+1)-1 downto 0) := (others => '0');
	begin
		if rising_edge(clk) then
			if synchronous_clear = '1' then
				phase_error_accumulator <= (others => '0');
			else
				-- This holds the full 33-bits result of the accumulation without saturation or overflow
				temp_sum := resize(phase_error_accumulator, temp_sum'length) + resize(data_in, temp_sum'length);
				if temp_sum > PHASE_ACCUM_MAX then
					-- Railed positive
					phase_error_accumulator <= PHASE_ACCUM_MAX(phase_error_accumulator'range);--to_signed(2**31-1, 32);
				elsif temp_sum < PHASE_ACCUM_MIN then
					-- Railed negative
					phase_error_accumulator <= PHASE_ACCUM_MIN(phase_error_accumulator'range);--to_signed(-2**31, 32);
				else
					-- Within the linear range
					phase_error_accumulator <= temp_sum(phase_error_accumulator'range);
				end if;
			end if;
		end if;
	end process;
	-- for monitoring the lock state:
	phase_residuals <= phase_error_accumulator;
   

	
	-- Integrator branch
	----------------------------------------------------------------
	-- The input frequency error is multiplied by the integral gain, cumulatively summed,
	--     and then scaled by the integral division factor to produce the correction term.
	--
	-- i_out = saturate(cumsum(data_in*gain_i))/2^N_DIVIDE_I
	-- 8 total clock cycles of delay
	
	-- Multiplication of data_in by gain_i:
	-- 10x64 multiplier, output is 74 bits
	-- i_mult_out = data_in*gain_i
	-- 6 clock cycles of delay
	pll_mult_i : pll_10x64_mult_LUT
	port map (
		clk               => clk,
		a                 => data_in,
		b                 => gain_i,
		sclr              => synchronous_clear,
		p                 => i_mult_out
	);
    
    -- Integration of i_mult_out with saturation and anti-windup:
    -- Output saturates at (N_OUTPUT_B+N_DIVIDE_I) bits
    -- i_accumulator_out = saturate(cumsum(i_mult_out))
    -- 2 clock cycle of delay
	i_integrator_saturation : entity work.integrator_with_saturation_pos
	generic map (
		N_INPUT => i_mult_out'length,
		N_OUTPUT => i_accumulator_out'length
	) port map (
		clk                 => clk,
		sclr                => synchronous_clear,
		railed_positive     => sum_railed_positive,
		railed_negative     => sum_railed_negative,
		data_in             => i_mult_out,
		initial_offset      => i_offset_in,
		data_out            => i_accumulator_out,
		railed_positive_out => i_railed_positive,
		railed_negative_out => i_railed_negative
	);
	
	-- Division of i_accumulator_out by 2^N_DIVIDE_I:
	-- Keeps i_accumulator_out's N_OUTPUT_B MSBs
	-- i_out = i_accumulator_out/2^N_DIVIDE_I
	-- 0 clock cycles of delay
	i_out <= i_accumulator_out(i_accumulator_out'length-1 downto N_DIVIDE_I);
    
    
	-- Double-Integrator branch
	----------------------------------------------------------------
	-- The input frequency error is multiplied by the double integral gain, successively
	--     passed through two cumulative summers, and then scaled by the double integral
	--     division factor to produce the correction term.
	--
	-- ii_out = saturate(cumsum(cumsum(gain_ii*data_in))/2^N_DIVIDE_II
	-- 10 total clock cycles of delay
	
	-- Multiplication of data_in by gain_ii:
	-- 10x64 multiplier, output is 74 bits
	-- ii_mult_out = data_in*gain_ii
	-- 6 clock cycles of delay
	pll_mult_ii : pll_10x64_mult_LUT
	port map (
		clk               => clk,
		a                 => data_in,
		b                 => gain_ii,
		sclr              => synchronous_clear,
		p                 => ii_mult_out
	);
    
    -- 1st stage integration of ii_mult_out with saturation and anti-windup:
    -- Output saturates at (N_OUTPUT_B+N_DIVIDE_II) bits
    -- ii_1st_stage_accumulator_out = saturate(cumsum(ii_mult_out))
    -- 2 clock cycle of delay
	ii_1st_stage_integrator_saturation : entity work.integrator_with_saturation_pos
	generic map (
		N_INPUT => ii_mult_out'length,
		N_OUTPUT => ii_1st_stage_accumulator_out'length
	) port map (
		clk                 => clk,
		sclr                => synchronous_clear,
		railed_positive     => sum_railed_positive,
		railed_negative     => sum_railed_negative,
		data_in             => ii_mult_out,
		initial_offset      => ii_1st_stage_offset_in,
		data_out            => ii_1st_stage_accumulator_out,
		railed_positive_out => ii_1st_stage_railed_positive,
		railed_negative_out => ii_1st_stage_railed_negative
	);
	
	-- 2nd stage integration of ii_mult_out with saturation and anti-windup:
    -- Output saturates at (N_OUTPUT_B+N_DIVIDE_II) bits
    -- ii_2nd_stage_accumulator_out = saturate(cumsum(ii_1st_stage_accumulator_out))
    -- 2 clock cycle of delay
    ii_2nd_stage_offset_in <= shift_left(resize(offset_in, ii_2nd_stage_accumulator_out'length), N_DIVIDE_II);
    
	ii_2nd_stage_integrator_saturation : entity work.integrator_with_saturation_pos
	generic map (
		N_INPUT => ii_1st_stage_accumulator_out'length,
		N_OUTPUT => ii_2nd_stage_accumulator_out'length
	) port map (
		clk                 => clk,
		sclr                => synchronous_clear,
		railed_positive     => sum_railed_positive,
		railed_negative     => sum_railed_negative,
		data_in             => ii_1st_stage_accumulator_out,
		initial_offset      => ii_2nd_stage_offset_in,
		data_out            => ii_2nd_stage_accumulator_out,
		railed_positive_out => ii_railed_positive,
		railed_negative_out => ii_railed_negative
	);
	
	-- Division of ii_2nd_stage_accumulator_out by 2^N_DIVIDE_II:
	-- Keeps ii_2nd_stage_accumulator_out's N_OUTPUT MSBs
	-- ii_out = ii_2nd_stage_accumulator_out/2^N_DIVIDE_II
	-- 0 clock cycles of delay
	ii_out <= ii_2nd_stage_accumulator_out(ii_2nd_stage_accumulator_out'length-1 downto N_DIVIDE_II);
    

	-- Output summing node
	----------------------------------------------------------------
    -- data_out = saturate(p_out + i_out + ii_out + d_out)
    -- X total clock cycles of delay
    
	-- Sum of the separate branches without overflow:
	-- This assumes that all three inputs have been properly saturated beforehand so we need only 2 extra bits to handle the full result.
	-- Output is (N_OUTPUT_B+1) bits
	-- output_sum = p_out + i_out + ii_out + d_out
	-- 0 clock cycles of delay
	output_sum <=	resize(i_out,      output_sum'length) +
	                resize(ii_out,     output_sum'length);
	
	-- Saturation for the output sum:
	-- Keeps output_sum's N_OUTPUT LSBs
	-- data_out = saturate(output_sum)
	-- 1 clock cycle of delay
    data_out_saturation: entity work.resize_with_saturation_pos
	GENERIC MAP (
		N_INPUT => output_sum'length,
		N_OUTPUT => N_OUTPUT
	)
	PORT MAP (
          clk => clk,
	      synchronous_clear => no_clear,
          data_in => output_sum,
          railed_positive => sum_railed_positive,
          railed_negative => sum_railed_negative,
          data_out => data_out
        );
	
	
	-- Indicate the internal saturation state:
	-- We add two registers to help with the routing:
	process (clk)
	begin
		if rising_edge(clk) then
			saturated_high_internal <= (sum_railed_positive or i_railed_positive or ii_railed_positive or ii_1st_stage_railed_positive);
			saturated_low_internal 	<= (sum_railed_negative or i_railed_negative or ii_railed_negative or ii_1st_stage_railed_negative);
			-- extra register stage:
			saturated_high	 <= saturated_high_internal;
			saturated_low	 <= saturated_low_internal;
		end if;
	end process;


end Behavioral;

