----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:   
-- Design Name: 
-- Module Name:    
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



entity IIR_LPF_14to32 is
    generic (
        N_DATA : integer := 14;
        N_COEF : integer := 18
    );
    port (
        clk      : in  std_logic;
        coef     : in  signed(N_COEF-1 downto 0);
        data_in  : in  signed(N_DATA-1 downto 0);
        data_out : out signed((N_DATA+N_COEF)-1 downto 0)
    );
end entity;

architecture behavioral of IIR_LPF_14to32 is
    --CoreGen declarations
	-----------------------------------------------------------------------
	-- Multiplier, 14x18 input bits, 32 output bits
	component IIR_LPF_14x18_mult
	port (
		clk  : in std_logic;
		a    : in signed(N_DATA-1 downto 0);
		b    : in signed(N_COEF-1 downto 0);
		p    : out signed((N_DATA+N_COEF)-1 downto 0));
	end component;
	
		
	-- Internal variables
	-----------------------------------------------------------------------
	signal delta : signed(N_DATA-1 downto 0) := (others => '0');
	signal iir_lpf_mult_out : signed((N_DATA+N_COEF)-1 downto 0) := (others => '0');
    signal data_out_32 : signed((N_DATA+N_COEF)-1 downto 0) := (others => '0');
    signal data_out_14 : signed(N_DATA-1 downto 0) := (others => '0');


begin
    -- Exponential Avgerage: Low Pass Filter
	----------------------------------------------------------------
	-- ***describe***
	--
	-- data_out = data_out + coef * (data_in - data_out)
	-- 4 total clock cycles of delay
	
	-- Difference of data_in and data_out_14:
	-- Output is 14 bits
	-- delta = data_in - data_out_14
	-- 0 clock cycles of delay
    delta <= data_in - data_out_14;
    
    -- Multiplication of delta by coef:
    -- 14x18 multiplier, output is 32 bits
    -- iir_lpf_mult_out = delta * coef
    -- 3 clock cycles of delay
    IIR_LPF_mult : IIR_LPF_14x18_mult
	port map (
		clk               => clk,
		a                 => delta,
		b                 => coef,
		p                 => iir_lpf_mult_out
	);
	
	-- Add iir_lpf_mult_out to the running average:
	-- Output is 32 bits
	-- data_out_32 = data_out_32 + iir_lpf_mult_out
	-- 1 clock cycle of delay
    process (clk) is
    begin
        if rising_edge(clk) then
            data_out_32 <= data_out_32 + iir_lpf_mult_out;
        end if;
    end process;
    data_out_14 <= resize(shift_right(data_out_32, 18), data_out_14'length);
    data_out <= data_out_32;

end architecture;
