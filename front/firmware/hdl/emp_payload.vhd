-- null_algo
--
-- Do-nothing top level algo for testing
--
-- Dave Newbold, July 2013

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

use work.ipbus.all;
use work.emp_data_types.all;
use work.top_decl.all;

use work.emp_device_decl.all;
use work.mp7_ttc_decl.all;

entity emp_payload is
	port(
		clk: in std_logic; -- ipbus signals
		rst: in std_logic;
		ipb_in: in ipb_wbus;
		ipb_out: out ipb_rbus;
		clk_payload: in std_logic_vector(2 downto 0);
		rst_payload: in std_logic_vector(2 downto 0);
		clk_p: in std_logic; -- data clock
		rst_loc: in std_logic_vector(N_REGION - 1 downto 0);
		clken_loc: in std_logic_vector(N_REGION - 1 downto 0);
		ctrs: in ttc_stuff_array;
		bc0: out std_logic;
		d: in ldata(4 * N_REGION - 1 downto 0) := (others => LWORD_NULL); -- data in
		q: out ldata(4 * N_REGION - 1 downto 0) := (others => LWORD_NULL); -- data out
		gpio: out std_logic_vector(29 downto 0); -- IO to mezzanine connector
		gpio_en: out std_logic_vector(29 downto 0) -- IO to mezzanine connector (three-state enables)
	);

end emp_payload;

architecture rtl of emp_payload is
    constant PAYLOAD_LATENCY : integer := 5;
	signal dr: ldata(N_REGION * 4 - 1 downto 0);
    type t_payload_shiftreg is array(PAYLOAD_LATENCY downto 0) of ldata(N_REGION*4 - 1 downto 0);
    signal payload_shiftreg: t_payload_shiftreg;

begin
	ipb_out <= IPB_RBUS_NULL;
--    gen: for i in N_REGION*4 - 1 downto 0 generate
--	begin
--          dr(i).data <= std_logic_vector(unsigned(d(i).data) + to_unsigned(5,LWORD_WIDTH));
--          dr(i).valid <= d(i).valid;
--          dr(i).start <= d(i).start;
--          dr(i).strobe <= d(i).strobe;
--	end generate;
--        process(clk_p) -- Mother of all shift registers
--        begin
--          if rising_edge(clk_p) then
--            payload_shiftreg <= payload_shiftreg(PAYLOAD_LATENCY-1 downto 0) & dr;
--          end if;
--        end process;
--    q <= payload_shiftreg(PAYLOAD_LATENCY);
    algoInstance : entity work.algo
    port map (
        -- Input Ports --
        clk => clk_p,
        links_in => d,

        -- Output Ports --
		data_out(N_REGION * 4 - 1 downto 0) => q,
        data_out(2*2*N_REGION * 4 - 1 downto N_REGION * 4) => open
    );
	bc0 <= '0';
	gpio <= (others => '0');
	gpio_en <= (others => '0');
end rtl;
