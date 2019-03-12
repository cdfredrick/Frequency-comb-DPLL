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

entity quantizer is
    generic (
        DI_WIDTH : integer := 16;
        DO_WIDTH : integer := 10
    );
    port (
        clk : in  std_logic;
        di  : in  signed(DI_WIDTH-1 downto 0);
        do  : out signed(DO_WIDTH-1 downto 0)
    );
end entity;

architecture behavioral of quantizer is

    signal   di_ireg               : signed(DI_WIDTH-1 downto 0) := (others => '0');

	signal   shift_register        : std_logic_vector(10-1 downto 0) := (others => '1');
	signal   shift_register_input  : std_logic := '0';
	signal   shift_register_output : std_logic := '0';
    signal   prbs_out              : std_logic := '0';
    
    constant HALF_STEP_UP          : signed(DI_WIDTH-1 downto 0) := to_signed(+2**(DI_WIDTH-DO_WIDTH-1), DI_WIDTH);
    constant HALF_STEP_DOWN        : signed(DI_WIDTH-1 downto 0) := to_signed(-2**(DI_WIDTH-DO_WIDTH-1), DI_WIDTH);
    signal   noise                 : signed(DI_WIDTH-1 downto 0) := (others => '0');
    
    signal feedback : signed(DI_WIDTH-1 downto 0) := (others => '0');
    signal qerr     : signed(DI_WIDTH-1 downto 0) := (others => '0');
    signal qi       : signed(DI_WIDTH-1 downto 0) := (others => '0');
    signal qi_frac  : signed(DI_WIDTH-1 downto 0) := (others => '0');
    signal qo       : signed(DI_WIDTH-1 downto 0) := (others => '0');
    signal qi_quant : signed(DO_WIDTH-1 downto 0) := (others => '0');
    
    signal do_oreg  : signed(DO_WIDTH-1 downto 0) := (others => '0');
begin
    ----------------------------------------------------------------------------------
    -- Input Registers
    ----------------------------------------------------------------------------------
	input_registers : process(clk)
	begin
		if rising_edge(clk) then
            di_ireg <= di;
		end if;
	end process;
    
    ----------------------------------------------------------------------------------
    -- PRBS
    ----------------------------------------------------------------------------------

	shift_register_input  <= shift_register(7) xor shift_register(0);
	shift_register_output <= shift_register(0);

	PRBS : process(clk)
	begin
		if rising_edge(clk) then
			shift_register <= shift_register_input & shift_register(shift_register'left downto 1);
		end if;
	end process;
	prbs_out <= shift_register_output;

    ----------------------------------------------------------------------------------
    -- Create noise to decorrelate quantization noise
    ----------------------------------------------------------------------------------
	decorr : process(clk)
	begin
		if rising_edge(clk) then
            if prbs_out = '0' then
                noise <= HALF_STEP_UP;
            else
                noise <= HALF_STEP_DOWN;
            end if;
		end if;
	end process;
    
    ----------------------------------------------------------------------------------
    -- Quantization
    ----------------------------------------------------------------------------------
	quant : process(clk)
	begin
		if rising_edge(clk) then
            feedback <= signed(feedback) + signed(qerr);
		end if;
	end process;
    qi <= signed(di_ireg) + signed(noise) + signed(feedback);
    qi_frac <= resize(signed(qi(DI_WIDTH-DO_WIDTH-1 downto 0)), DI_WIDTH);
    qo <= signed(qi) - signed(qi_frac);
    qerr <= signed(di_ireg) - signed(qo);
    qi_quant <= qo(DI_WIDTH-1 downto DI_WIDTH-DO_WIDTH);
    
    ----------------------------------------------------------------------------------
    -- Output Registers
    ----------------------------------------------------------------------------------
	output_registers : process(clk)
	begin
		if rising_edge(clk) then
            do_oreg <= qi_quant;
		end if;
	end process;
    do <= do_oreg;
    
end architecture;
