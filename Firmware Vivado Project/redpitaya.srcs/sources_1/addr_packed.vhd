library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity addr_packed is
	port(
			clk 		: in std_logic;
			rst 		: in std_logic;
			sys_addr	: in std_logic_vector (32-1 downto 0);
			sys_wdata	: in std_logic_vector (32-1 downto 0);
			sys_wen 	: in std_logic;
			sys_ren		: in std_logic;
			sys_rdata   : out std_logic_vector(32-1 downto 0);  -- bus read data
			sys_err		: out std_logic;						-- Error indicator
			sys_ack		: out std_logic;  -- bus acknowledge signal
			out_empty 	: out std_logic;
			out_full 	: out std_logic
		);
end addr_packed;

architecture Behavioral of addr_packed is

component FIFO_addr_packed is
	port (
		    clk : IN STD_LOGIC;
		    srst : IN STD_LOGIC;
		    din : IN STD_LOGIC_VECTOR(64-1 DOWNTO 0);
		    wr_en : IN STD_LOGIC;
		    rd_en : IN STD_LOGIC;
		    dout : OUT STD_LOGIC_VECTOR(64-1 DOWNTO 0);
		    full : OUT STD_LOGIC;
		    wr_ack : OUT STD_LOGIC;
		    empty : OUT STD_LOGIC
	  );
end component;

signal read_fifo : STD_LOGIC := '0';
signal data_exchange : std_logic_vector (64-1 downto 0) := (others => '0');
signal fifo_empty : STD_LOGIC := '1';

signal nrst : STD_LOGIC := '0';
signal data_in : std_logic_vector (64-1 downto 0) := (others => '0');

begin

nrst <= not(rst);
data_in <= sys_addr & sys_wdata;

FIFO_inst : FIFO_addr_packed
port map (
			clk 	=> clk,
		    srst 	=> nrst,
		    din 	=> data_in,
		    wr_en 	=> sys_wen,
		    rd_en 	=> read_fifo,
		    dout 	=> data_exchange,
		    full 	=> out_full,
		    wr_ack 	=> open,
		    empty 	=> fifo_empty
	);


FSM_inst : entity work.FSM_addr_packed
port map (
			clk 		=> clk,
			rst 		=> rst,
            read_fifo 	=> read_fifo,
            data_in 	=> data_exchange,
            sys_ren		=> sys_ren,
            addrAsk 	=> sys_addr,
            FIFO_empty 	=> fifo_empty,
            data_out 	=> sys_rdata,
            sys_err 	=> sys_err,
            ack 		=> sys_ack
	);

out_empty <= fifo_empty;


end;