----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:09:13 11/07/2013 
-- Design Name: 
-- Module Name:    multiplexer_NbitsxMsignals_to_Nbits - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: Multiplexes 8 N-bits signals into 1 N-bit signal, through two multiplexing stages, and an intermediate registers stage.
-- Total delay is 3 clock cycles from input to output when this input is selected.
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity multiplexer_NbitsxMsignals_to_Nbits is
	Generic (
		N_bits_per_signal : integer := 17;
		N_bits_per_ref_signal : integer :=16
		);
    Port (
         
        clk : in  STD_LOGIC;
		
		-- The RAM write clock enable must be in the MSB
        in0_adc_0 : in  STD_LOGIC_VECTOR (N_bits_per_signal-1 downto 0);
        in1_adc_1 : in  STD_LOGIC_VECTOR (N_bits_per_signal-1 downto 0);
        in2_err_sig_0 : in  STD_LOGIC_VECTOR (N_bits_per_signal-1 downto 0);
        in3_err_sig_1 : in  STD_LOGIC_VECTOR (N_bits_per_signal-1 downto 0);
        in4_vna : in  STD_LOGIC_VECTOR (N_bits_per_signal-1 downto 0);
        in5 : in  STD_LOGIC_VECTOR (N_bits_per_signal-1 downto 0);
        in6_dac_0 : in  STD_LOGIC_VECTOR (N_bits_per_signal-1 downto 0);
        in7_dac_1 : in  STD_LOGIC_VECTOR (N_bits_per_signal-1 downto 0);
			  
		in8_err_sig_2 : in  STD_LOGIC_VECTOR (N_bits_per_signal-1 downto 0);
		in9 : in  STD_LOGIC_VECTOR (N_bits_per_signal-1 downto 0);
		in10 : in  STD_LOGIC_VECTOR (N_bits_per_signal-1 downto 0);
			  
        selector : in  STD_LOGIC_VECTOR (4 downto 0);
        selected_output : out  STD_LOGIC_VECTOR (N_bits_per_signal-1 downto 0);
        
        ref_cosine_0 : in  STD_LOGIC_VECTOR (N_bits_per_ref_signal-1 downto 0);
        ref_sine_0 : in  STD_LOGIC_VECTOR (N_bits_per_ref_signal-1 downto 0);
        ref_cosine_1 : in  STD_LOGIC_VECTOR (N_bits_per_ref_signal-1 downto 0);
        ref_sine_1 : in  STD_LOGIC_VECTOR (N_bits_per_ref_signal-1 downto 0);
        ref_sin_out : out  STD_LOGIC_VECTOR (N_bits_per_ref_signal-1 downto 0);
        ref_cos_out : out  STD_LOGIC_VECTOR (N_bits_per_ref_signal-1 downto 0)
			  
		);
end multiplexer_NbitsxMsignals_to_Nbits;

architecture Behavioral of multiplexer_NbitsxMsignals_to_Nbits is
	signal mux_out_reg : std_logic_vector(N_bits_per_signal-1 downto 0) := (others => '0');
	signal ref_sin_reg : std_logic_vector(N_bits_per_ref_signal-1 downto 0) := (others => '0');
	signal ref_cos_reg : std_logic_vector(N_bits_per_ref_signal-1 downto 0) := (others => '0');
	
begin

    process (clk)
	   variable write_mode : std_ulogic := '0';
	   variable write_mode_last : std_ulogic := '0';
	begin
	   if rising_edge(clk) then
	       -- Multiplexer
	       case selector is
	           when x"0" =>
	               mux_out_reg <= in0_adc_0;
	               -- Rising edge detector:
	               write_mode := in0_adc_0(N_bits_per_ref_signal-1);
	               if (write_mode = '1') and (write_mode_last = '0') then
	                   ref_sin_reg <= ref_sine_0;
	                   ref_cos_reg <= ref_cosine_0;
	               end if;
	               write_mode_last := write_mode;
	           when x"1" =>
	               mux_out_reg <= in1_adc_1;
	               -- Rising edge detector:
                   write_mode := in1_adc_1(N_bits_per_ref_signal-1);
                   if (write_mode = '1') and (write_mode_last = '0') then
                       ref_sin_reg <= ref_sine_1;
                       ref_cos_reg <= ref_cosine_1;
                   end if;
                   write_mode_last := write_mode;
	           when x"2" =>
	               mux_out_reg <= in2_err_sig_0;
	           when x"3" =>
	               mux_out_reg <= in3_err_sig_1;
	           when x"4" =>
	               mux_out_reg <= in4_vna;
	           when x"5" =>
	               mux_out_reg <= in5;
	           when x"6" =>
	               mux_out_reg <= in6_dac_0;
	           when x"7" =>
	               mux_out_reg <= in7_dac_1;
	           when x"8" =>
	               mux_out_reg <= in8_err_sig_2;
	           when x"9" =>
	               mux_out_reg <= in9;
	           when others =>
	               mux_out_reg <= in10;
	        end case;
	        selected_output <= mux_out_reg;
	        ref_sin_out <= ref_sin_reg;
	        ref_cos_out <= ref_cos_reg;
	     end if;
	  end process;	

end Behavioral;

