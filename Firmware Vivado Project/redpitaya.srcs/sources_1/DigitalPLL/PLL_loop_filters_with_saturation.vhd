----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:29:12 11/29/2013 
-- Design Name: 
-- Module Name:    PLL_loop_filters_with_saturation - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description:  Implements a PIID filter, according to the following equation:
-- data_out = (gain_p/2^N_DIVIDE_P)*data_in + (gain_i/2^N_DIVIDE_I)*cumsum(data_in) + (gain_ii/2^N_DIVIDE_II)*cumsum(cumsum(data_in)) + (gain_d/2^N_DIVIDE_D)*diff(exp_avg(data_in, coef_d_filter))
-- Note that this equation does not include the delays, quantization and the saturation.
-- Each branch is saturated independently, and the sum is also saturated.
-- The quantization happens before the output summing block.
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



entity PLL_loop_filters_with_saturation is
	Generic (
		-- Constants which control the scaling:
		-- Each branch's output is divided by 2^N
		N_DIVIDE_P 	: integer := 10;      -- log2(max_freq_err * min_p_gain), minimum output with maximum error and minimum gain
		N_DIVIDE_I 	: integer := 33;      -- log2(max_freq_err * max_i_gain * 1us * 125MHz) - 16, saturation in 1us with maximum error and maximum gain
		N_DIVIDE_II : integer := 59;      -- log2(max_freq_err * max_ii_gain * 0.5*(1ms * 125MHz)**2) - 16, saturation in 1ms with maximum error and maximum gain
        N_DIVIDE_D  : integer := 11;      -- log2(max_freq_err_derivative * min_d_gain) - (18 + 3), minimum output with maximum error and minimum gain
		N_OUTPUT 	: integer := 16
	);
    Port (
		clk             : in  std_logic;
		lock            : in  std_logic;
		gain_changed    : in  std_logic;
		data_in         : in  signed(10-1 downto 0);
		gain_p          : in  signed(32-1 downto 0);
		gain_i          : in  signed(32-1 downto 0);
		gain_ii         : in  signed(32-1 downto 0);
		gain_d          : in  signed(32-1 downto 0);
		coef_d_filter   : in  signed(18-1 downto 0);
		phase_residuals : out signed(32-1 downto 0);
		data_out        : out signed(N_OUTPUT-1 downto 0);
		saturated_low   : out std_logic;
		saturated_high  : out std_logic
    );
end PLL_loop_filters_with_saturation;


architecture Behavioral of PLL_loop_filters_with_saturation is
	--CoreGen declarations
	-----------------------------------------------------------------------
	-- Multiplier, 10x32 input bits, 42 output bits, synchronous clear
	-- 4 clock cycles of delay
	component pll_10x32_mult
	port (
		clk  : in std_logic;
		a    : in signed(10-1 downto 0);
		b    : in signed(32-1 downto 0);
		sclr : in std_logic;
		p    : out signed(42-1 downto 0));
	end component;
	
	-- Multiplier, 32x32 input bits, 64 output bits, synchronous clear
	-- 6 clock cycles of delay
	component pll_32x32_mult
	port (
		clk  : in std_logic;
		a    : in signed(32-1 downto 0);
		b    : in signed(32-1 downto 0);
		sclr : in std_logic;
		p    : out signed(64-1 downto 0));
	end component;
	
	
	-- Internal variables
	-----------------------------------------------------------------------
	-- Phase residuals monitor
	constant N_BITS_PHASE_RESULT   : integer := 32;
	signal phase_error_accumulator : signed(N_BITS_PHASE_RESULT-1 downto 0) := (others => '0');
	   -- the extra bit in these signals is to hold the full, unwrapped result
	constant PHASE_ACCUM_MAX : signed((N_BITS_PHASE_RESULT+1)-1 downto 0) := shift_left(to_signed(1, N_BITS_PHASE_RESULT+1), N_BITS_PHASE_RESULT-1)-1;	-- (2^(N_BITS_PHASE_RESULT-1)-1)
	constant PHASE_ACCUM_MIN : signed((N_BITS_PHASE_RESULT+1)-1 downto 0) := shift_left(to_signed(-1, N_BITS_PHASE_RESULT+1), N_BITS_PHASE_RESULT-1);	-- (-2**(N_BITS_PHASE_RESULT-1))
	
	-- P branch signals
	signal p_mult_out                              : signed(42-1 downto 0) := (others => '0');
	signal p_mult_divided                          : signed((p_mult_out'length-N_DIVIDE_P)-1 downto 0) := (others => '0');
	signal p_out                                   : signed(N_OUTPUT-1 downto 0) := (others => '0');
	signal p_railed_positive, p_railed_negative    : std_logic := '0';
	
	-- I branch signals
	signal i_mult_out                              : signed(42-1 downto 0) := (others => '0');
	signal i_accumulator_out                       : signed((N_OUTPUT+N_DIVIDE_I)-1 downto 0) := (others => '0');
	signal i_railed_positive, i_railed_negative    : std_logic := '0';
	signal i_accumulator_divided                   : signed((i_accumulator_out'length-N_DIVIDE_I)-1 downto 0) := (others => '0');
	signal i_out                                   : signed(N_OUTPUT-1 downto 0) := (others => '0');

	-- II branch signals
	signal ii_mult_out                                                 : signed(42-1 downto 0) := (others => '0');
	signal ii_1st_stage_accumulator_out                                : signed((N_OUTPUT+N_DIVIDE_II)-1 downto 0) := (others => '0');
	signal ii_1st_stage_railed_positive, ii_1st_stage_railed_negative  : std_logic := '0';
	signal ii_2nd_stage_accumulator_out                                : signed((N_OUTPUT+N_DIVIDE_II)-1 downto 0) := (others => '0');
	signal ii_railed_positive, ii_railed_negative                      : std_logic := '0';
	signal ii_2nd_stage_accumulator_divided                            : signed((ii_2nd_stage_accumulator_out'length-N_DIVIDE_II)-1 downto 0) := (others => '0');
	signal ii_out                                                      : signed(N_OUTPUT-1 downto 0) := (others => '0');
	
    -- D branch signals
    -- signal data_in_dly : std_logic_vector(9 downto 0) := (others => '0');
	signal d_filt_in                               : signed(14-1 downto 0)       := (others => '0');
	signal d_filt_out                              : signed(32-1 downto 0)       := (others => '0');
	signal d_filt_out_dly                          : signed(32-1 downto 0)       := (others => '0');
	signal data_diff                               : signed(32-1 downto 0)       := (others => '0');
	signal d_mult_out                           : signed(64-1 downto 0)       := (others => '0');
	signal d_mult_divided                          : signed((64-18-3-N_DIVIDE_D)-1 downto 0)       := (others => '0');
	signal d_out                                   : signed(N_OUTPUT-1 downto 0) := (others => '0');
	signal d_railed_positive, d_railed_negative    : std_logic := '0';
	
	-- Summing node signals
	signal output_sum                                      : signed((N_OUTPUT+2)-1 downto 0) := (others => '0');   -- the extra two bits are to handle the full range result without overflowing
	signal sum_railed_negative, sum_railed_positive        : std_logic := '0'; -- this is used for the anti-windup behavior (we stop integrating if the sum is railed, even if the integrator isn't)
	
	-- Flags which indicate internal state
	signal synchronous_clear                               : std_logic := '0'; -- resets everything, asserted when either gain_changed = '1' or lock = '0'
	signal saturated_high_internal, saturated_low_internal : std_logic := '0'; -- indicates to the external world when one of the internal signal is saturated


begin
	-- Synchronous clear of the internal signals either when we are out of lock, or when the gains are changed:
	synchronous_clear <= gain_changed or not lock;
    
    
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
    
    
	-- Proportionnal branch
	----------------------------------------------------------------
	-- ***describe***
	--
	-- p_out = saturate((data_in*gain_p)/2^N_DIVIDE_P)
	-- 5 total clock cycles of delay
	
	-- Multiplication of data_in by gain_p:
	-- 10x32 multiplier, output is 42 bits
	-- p_mult_out = data_in*gain_p
	-- 4 clock cycles of delay
	pll_mult_p : pll_10x32_mult
	port map (
		clk               => clk,
		a                 => data_in,
		b                 => gain_p,
		sclr              => synchronous_clear,
		p                 => p_mult_out
	);
    
	-- Division of p_mult_out by 2^N_DIVIDE_P:
	-- Keeps p_mult_out's (42-N_DIVIDE_P) MSBs
	-- p_mult_divided = p_mult_out/2^N_DIVIDE_P
	-- 0 clock cycles of delay
	p_mult_divided <= p_mult_out(p_mult_out'length-1 downto N_DIVIDE_P);
	
	-- Saturation for P branch:
	-- Keeps p_mult_divided's N_OUTPUT LSBs
	-- p_out = saturate(p_mult_divided)
	-- 1 clock cycle of delay
	pll_p_saturation: entity work.resize_with_saturation
	GENERIC MAP (
		N_INPUT           => p_mult_divided'length,
		N_OUTPUT          => p_out'length
	)
	PORT MAP (
		clk               => clk,
		synchronous_clear => synchronous_clear,
		data_in           => p_mult_divided,
		railed_positive   => p_railed_positive,
		railed_negative   => p_railed_negative,
		data_out          => p_out
	);
    
	
	-- Integrator branch
	----------------------------------------------------------------
	-- ***describe***
	-- Multiplier, i_mult_output = gain_i * phase_error_accumulator (exact integer arithmetic, 32x32 = 64 bits result)
	--
	-- i_out = saturate(cumsum(data_in*gain_i))/2^N_DIVIDE_I
	-- 5 total clock cycles of delay
	
	-- Multiplication of data_in by gain_i:
	-- 10x32 multiplier, output is 42 bits
	-- i_mult_out = data_in*gain_i
	-- 4 clock cycles of delay
	pll_mult_i : pll_10x32_mult
	port map (
		clk               => clk,
		a                 => data_in,
		b                 => gain_i,
		sclr              => synchronous_clear,
		p                 => i_mult_out
	);
    
    -- Integration of i_mult_out with saturation and anti-windup:
    -- Output saturates at (N_OUTPUT+N_DIVIDE_I) bits
    -- i_accumulator_out = saturate(cumsum(i_mult_out))
    -- 1 clock cycle of delay
	i_integrator_saturation : entity work.integrator_with_saturation
	generic map (
		N_INPUT => i_mult_out'length,
		N_OUTPUT => i_accumulator_out'length
	) port map (
		clk                 => clk,
		sclr                => synchronous_clear,
		railed_positive     => sum_railed_positive,
		railed_negative     => sum_railed_negative,
		data_in             => i_mult_out,
		data_out            => i_accumulator_out,
		railed_positive_out => i_railed_positive,
		railed_negative_out => i_railed_negative
	);
	
	-- Division of i_accumulator_out by 2^N_DIVIDE_I:
	-- Keeps i_accumulator_out's N_OUTPUT MSBs
	-- i_out = i_accumulator_out/2^N_DIVIDE_I
	-- 0 clock cycles of delay
	i_out <= i_accumulator_out(i_accumulator_out'length-1 downto N_DIVIDE_I);
    
    
	-- Double-Integrator branch
	----------------------------------------------------------------
	-- ***describe***
	-- We use the phase_error_accumulator result, scale the result, then accumulate again, and finally divide by N_DIVIDE_II.
	--
	-- gain_ii/2^N_DIVIDE_II * cumsum(cumsum(data_in))
	-- 6 total clock cycles of delay
	
	-- Multiplication of data_in by gain_ii:
	-- 10x32 multiplier, output is 42 bits
	-- ii_mult_out = data_in*gain_ii
	-- 4 clock cycles of delay
	pll_mult_ii : pll_10x32_mult
	port map (
		clk               => clk,
		a                 => data_in,
		b                 => gain_ii,
		sclr              => synchronous_clear,
		p                 => ii_mult_out
	);
    
    -- 1st stage integration of ii_mult_out with saturation and anti-windup:
    -- Output saturates at (N_OUTPUT+N_DIVIDE_II) bits
    -- ii_1st_stage_accumulator_out = saturate(cumsum(ii_mult_out))
    -- 1 clock cycle of delay
	ii_1st_stage_integrator_saturation : entity work.integrator_with_saturation
	generic map (
		N_INPUT => ii_mult_out'length,
		N_OUTPUT => ii_1st_stage_accumulator_out'length
	) port map (
		clk                 => clk,
		sclr                => synchronous_clear,
		railed_positive     => ii_railed_positive,
		railed_negative     => ii_railed_negative,
		data_in             => ii_mult_out,
		data_out            => ii_1st_stage_accumulator_out,
		railed_positive_out => ii_1st_stage_railed_positive,
		railed_negative_out => ii_1st_stage_railed_negative
	);
	
	-- 2nd stage integration of ii_mult_out with saturation and anti-windup:
    -- Output saturates at (N_OUTPUT+N_DIVIDE_II) bits
    -- ii_2nd_stage_accumulator_out = saturate(cumsum(ii_1st_stage_accumulator_out))
    -- 1 clock cycle of delay
	ii_2nd_stage_integrator_saturation : entity work.integrator_with_saturation
	generic map (
		N_INPUT => ii_1st_stage_accumulator_out'length,
		N_OUTPUT => ii_2nd_stage_accumulator_out'length
	) port map (
		clk                 => clk,
		sclr                => synchronous_clear,
		railed_positive     => sum_railed_positive,
		railed_negative     => sum_railed_negative,
		data_in             => ii_1st_stage_accumulator_out,
		data_out            => ii_2nd_stage_accumulator_out,
		railed_positive_out => ii_railed_positive,
		railed_negative_out => ii_railed_negative
	);
	
	-- Division of ii_2nd_stage_accumulator_out by 2^N_DIVIDE_II:
	-- Keeps ii_2nd_stage_accumulator_out's N_OUTPUT MSBs
	-- ii_out = ii_2nd_stage_accumulator_out/2^N_DIVIDE_II
	-- 0 clock cycles of delay
	ii_out <= ii_2nd_stage_accumulator_out(ii_2nd_stage_accumulator_out'length-1 downto N_DIVIDE_II);
    
    
	-- Differentiator with filter branch
	----------------------------------------------------------------
    -- ***describe***
    --
    -- d_out = saturate((gain_d*diff(exp_avg(data_in, coef_d_filter)))/2^N_DIVIDE_D)
    -- 12 total clock cycles of delay
    
    -- Rescale data_in for input into the exponential filter:
    -- Output is 14 bits
    -- d_filt_in = data_in * 2^3
    -- 0 clock cycles of delay
    d_filt_in <= shift_left(resize(data_in, d_filt_in'length), 3);
    
    -- Exponential filter of data_in:
    -- Output is 32 bits
    -- d_filt_out = d_filt_out + coef_d_filter * (d_filt_in - d_filt_out)
    -- 4 clock cycles of delay
    IIR_LPF_inst : entity work.IIR_LPF_14to32
    port map (
        clk      => clk,
        coef     => coef_d_filter,
        data_in  => d_filt_in,
        data_out => d_filt_out
    );
    
    -- Differentiate d_filt_out:
    -- Output is 32 bits
    -- data_diff = d_filt_out - d_filt_out_dly
    -- 1 clock cycle of delay
    process (clk) is
    begin
        if rising_edge(clk) then
            d_filt_out_dly <= d_filt_out;
            data_diff <= d_filt_out - d_filt_out_dly;
        end if;
    end process;
    
    -- Multiplication of data_diff by gain_d:
    -- 32x32 multiplier, output is 64 bits
    -- d_mult_out = data_diff * gain_d
    -- 6 clock cycle of delay
    pll_mult_d : pll_32x32_mult
    port map (
        clk  => clk,
        a    => data_diff,
        b    => gain_d,
        sclr => synchronous_clear,
        p    => d_mult_out
    );
    
    -- Division of d_mult_out by 2^(N_DIVIDE_D+18+3):
    -- In addition to N_DIVIDE_D, there is also a factor of 18+3 to cancel the effective gain of the exponential filter 
	-- Keeps d_mult_out's (64-(N_DIVIDE_D+18+3)) MSBs
	-- d_mult_divided = d_mult_out/2^(N_DIVIDE_P+18+3)
	-- 0 clock cycles of delay
	d_mult_divided <= d_mult_out(d_mult_out'length-1 downto (N_DIVIDE_D+18+3));
	
	-- Saturation for D branch:
	-- Keeps d_mult_divided's N_OUTPUT LSBs
	-- d_out = saturate(d_mult_divided)
	-- 1 clock cycle of delay
    d_saturation_inst: entity work.resize_with_saturation
    GENERIC MAP (
        N_INPUT  => d_mult_divided'length,
        N_OUTPUT => d_out'length
    )
    PORT MAP (
        clk => clk,
        synchronous_clear => synchronous_clear,
        data_in           => d_mult_divided,
        railed_positive   => d_railed_positive,
        railed_negative   => d_railed_negative,
        data_out          => d_out
    );
    
    
	-- Output summing node
	----------------------------------------------------------------
	-- ***describe***
    --
    -- data_out = saturate(p_out + i_out + ii_out + d_out)
    -- X total clock cycles of delay
    
	-- Sum of the separate branches without overflow:
	-- This assumes that all three inputs have been properly saturated beforehand so we need only 2 extra bits to handle the full result.
	-- Output is (N_OUTPUT+2) bits
	-- output_sum = p_out + i_out + ii_out + d_out
	-- 0 clock cycles of delay
	output_sum <=	resize(p_out,			N_OUTPUT+2) +
	                resize(i_out,			N_OUTPUT+2) +
	                resize(ii_out,			N_OUTPUT+2) +
	                resize(d_out,			N_OUTPUT+2);
	
	-- Saturation for the output sum:
	-- Keeps output_sum's N_OUTPUT LSBs
	-- data_out = saturate(output_sum)
	-- 1 clock cycle of delay
    data_out_saturation: entity work.resize_with_saturation
	GENERIC MAP (
		N_INPUT => N_OUTPUT+2,
		N_OUTPUT => N_OUTPUT
	)
	PORT MAP (
          clk => clk,
	      synchronous_clear => synchronous_clear,
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
			saturated_high_internal <= (sum_railed_positive or p_railed_positive or i_railed_positive
			                            or ii_railed_positive or d_railed_positive or ii_1st_stage_railed_positive);
			saturated_low_internal 	<= (sum_railed_negative or p_railed_negative or i_railed_negative
			                            or ii_railed_negative or d_railed_negative or ii_1st_stage_railed_negative);
			-- extra register stage:
			saturated_high	 <= saturated_high_internal;
			saturated_low	 <= saturated_low_internal;
		end if;
	end process;
	

	
end Behavioral;

