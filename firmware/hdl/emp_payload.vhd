library ieee;
use ieee.std_logic_1164.all;
use work.ipbus.all;
use work.emp_data_types.all;
use work.emp_device_decl.all;
use work.mp7_ttc_decl.all;


entity emp_payload is
port (
    clk: in std_logic;
    rst: in std_logic;
    ipb_in: in ipb_wbus;
    clk_payload: in std_logic_vector( 2 downto 0 );
    rst_payload: in std_logic_vector( 2 downto 0 );
    clk_p: in std_logic;
    rst_loc: in std_logic_vector( N_REGION - 1 downto 0 );
    clken_loc: in std_logic_vector( N_REGION - 1 downto 0 );
    ctrs: in ttc_stuff_array;
    d: in ldata( 4 * N_REGION - 1 downto 0 );
    ipb_out: out ipb_rbus;
    bc0: out std_logic;
    q: out ldata( 4 * N_REGION - 1 downto 0 );
    gpio: out std_logic_vector( 29 downto 0 );
    gpio_en: out std_logic_vector( 29 downto 0 )
);
end;


architecture rtl of emp_payload is


component dtc_top
port (
    clk: in std_logic;
    dtc_din: in ldata( 4 * N_REGION - 1 downto 0 );
    dtc_dout: out ldata( 4 * N_REGION - 1 downto 0 )
);
end component;


begin

DTC: dtc_top port map ( clk_p, d, q );

gpio <= ( others => '0' );
gpio_en <= ( others => '0' );


end;
