library ieee;
use ieee.std_logic_1164.all;
use work.emp_data_types.all;
use work.config.all;
use work.dtc_config.all;
use work.dtc_stubs.all;

entity interface_in is
port (
    clk:in std_logic;
    in_packet: in std_logic_vector( ModulesPerDTC - 1 downto 0 );
    in_din: in t_stubsFE( ModulesPerDTC - 1 downto 0 );
    in_dout: out ldata( ModulesPerDTC - 1 downto 0 )
);
end;

architecture rtl of interface_in is

component node_in
port (
    clk:in std_logic;
    node_packet: in std_logic;
    node_din: in t_stubFE;
    node_dout: out lword
);
end component;

begin

g: for k in 0 to ModulesPerDTC - 1 generate

signal node_packet: std_logic := '0';
signal node_din: t_stubFE := nullStub;
signal node_dout: lword := ( ( others => '0' ), '0', '0', '1' );

begin

node_packet <= in_packet( k );
node_din <= in_din( k );
in_dout( k ) <= node_dout;

c: node_in port map ( clk, node_packet, node_din, node_dout );

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.emp_data_types.all;
use work.config.all;
use work.dtc_stubs.all;
use work.dtc_config.all;
use work.tools.all;

entity node_in is
port (
    clk:in std_logic;
    node_packet: in std_logic;
    node_din: in t_stubFE;
    node_dout: out lword
);
end;

architecture rtl of node_in is

signal packet: std_logic := '0';
signal din: t_stubFE := nullStub;
signal dout: lword := ( ( others => '0' ), '0', '0', '1' );
signal sr: std_logic_vector( 2 - 1 downto 0 ) := ( others => '0' );

begin

packet <= node_packet;
din <= node_din;
node_dout <= dout; 

process( clk ) is
begin
if rising_edge( clk ) then

    sr <= sr( sr'high - 1 downto 0 ) & packet;

    dout.valid <= msb( sr );
    dout.data( widthBendCIC + widthCol + widthRow + widthBX + 1 - 1 downto 0 ) <=  din.bend & din.col & din.row & din.bx & din.valid;

end if;
end process;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.emp_data_types.all;
use work.config.all;
use work.dtc_config.all;
use work.data_types.all;
use work.utilities_pkg.all;

entity interface_transform is
port (
    clk: in std_logic;
    transform_din: in ldata( ModulesPerDTC - 1 downto 0 );
    transform_dout: out ldata( 2 * ModulesPerDTC - 1 downto 0 )
);
end;

architecture rtl of interface_transform is

component LinkConverter is
generic (
    index : in integer
);
port (
    clk : in std_logic;
    link_in : in lword;
    data_out : out ldata( 2*stubs_per_word - 1 downto 0 )
);
end component;

begin

g: for k in 0 to ModulesPerDTC - 1 generate

signal link_in : lword := ( ( others => '0' ), '0', '0', '1' );
signal data_out : ldata( 2*stubs_per_word - 1 downto 0 ) := ( others => ( ( others => '0' ), '0', '0', '1' ) );

begin

link_in <= transform_din( k );
transform_dout( 2 * ( k + 1 ) - 1 downto 2 * k ) <= data_out;

c: LinkConverter generic map ( k ) port map ( clk, link_in, data_out );

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.emp_data_types.all;
use work.config.all;
use work.dtc_config.all;
use work.dtc_stubs.all;

entity interface_out is
port (
    clk:in std_logic;
    out_din: in ldata( 2 * ModulesPerDTC - 1 downto 0 );
    out_dout: out t_stubsTransform( ModulesPerDTC - 1 downto 0 )
);
end;

architecture rtl of interface_out is

component node_out
port (
    clk:in std_logic;
    node_din: in ldata( 2 - 1 downto 0 );
    node_dout: out t_stubTransform
);
end component;

begin

g: for k in 0 to ModulesPerDTC - 1 generate

signal node_din: ldata( 2 - 1 downto 0 ) := ( others => ( ( others => '0' ), '0', '0', '1' ) );
signal node_dout: t_stubTransform := nullStub;

begin

node_din <= out_din( 2 * ( k + 1 ) - 1 downto 2 * k );
out_dout( k ) <= node_dout;

c: node_out port map ( clk, node_din, node_dout );

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.emp_data_types.all;
use work.config.all;
use work.dtc_config.all;
use work.dtc_stubs.all;

entity node_out is
port (
    clk:in std_logic;
    node_din: in ldata( 2 - 1 downto 0 );
    node_dout: out t_stubTransform
);
end;

architecture rtl of node_out is

signal din: ldata( 2 - 1 downto 0 ) := ( others => ( ( others => '0' ), '0', '0', '1' ) );
signal dout: t_stubTransform := nullStub;

begin

node_dout <= dout;

process( clk ) is
begin
if rising_edge( clk ) then

    din <= node_din;

    dout <= nullStub;
    if din( 1 ).data( 0 ) = '1' then
        dout.nonant <= din( 0 ).data( numOverlap + widthBX - 1 downto widthBX );
        dout.bx     <= din( 0 ).data(              widthBX - 1 downto       0 );
        dout.ps     <= din( 1 ).data( 1 + 1 + widthHybridLayer + widthHybridBend + widthHybridAlpha + widthHybridPhi + widthHybridZ + widthHybridR + 1 - 1 );
        dout.barrel <= din( 1 ).data(     1 + widthHybridLayer + widthHybridBend + widthHybridAlpha + widthHybridPhi + widthHybridZ + widthHybridR + 1 - 1 );
        dout.layer  <= din( 1 ).data(         widthHybridLayer + widthHybridBend + widthHybridAlpha + widthHybridPhi + widthHybridZ + widthHybridR + 1 - 1 downto widthHybridBend + widthHybridAlpha + widthHybridPhi + widthHybridZ + widthHybridR + 1 );
        dout.bend   <= din( 1 ).data(                            widthHybridBend + widthHybridAlpha + widthHybridPhi + widthHybridZ + widthHybridR + 1 - 1 downto                   widthHybridAlpha + widthHybridPhi + widthHybridZ + widthHybridR + 1 );
        dout.alpha  <= din( 1 ).data(                                              widthHybridAlpha + widthHybridPhi + widthHybridZ + widthHybridR + 1 - 1 downto                                      widthHybridPhi + widthHybridZ + widthHybridR + 1 );
        dout.phi    <= din( 1 ).data(                                                                 widthHybridPhi + widthHybridZ + widthHybridR + 1 - 1 downto                                                       widthHybridZ + widthHybridR + 1 );
        dout.z      <= din( 1 ).data(                                                                                  widthHybridZ + widthHybridR + 1 - 1 downto                                                                      widthHybridR + 1 );
        dout.r      <= din( 1 ).data(                                                                                                 widthHybridR + 1 - 1 downto                                                                                     1 );
        dout.valid  <= din( 1 ).data(                                                                                                                1 - 1 );
    end if;

    dout.reset <= '0';
    if din( 0 ).valid = '0' and node_din( 0 ).valid = '1' then
        dout <= nullStub;
        dout.bx( widthBX - 1 downto widthTMPfe ) <= din( 0 ).data( widthBX - 1 downto widthTMPfe );
        dout.reset <= '1';
    end if;

end if;
end process;

end;
