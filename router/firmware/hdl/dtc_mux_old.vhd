library ieee;
use ieee.std_logic_1164.all;
use work.config.all;
use work.dtc_stubs.all;
use work.dtc_config.all;

entity dtc_mux is
port (
    clk: in std_logic;
    mux_din: in t_stubsRoute( routeStubs - 1 downto 0 );
    mux_dout: out t_stubsDTC( numLinksDTC - 1 downto 0 )
);
end;

architecture rtl of dtc_mux is

component dtc_mux_node
port (
    clk: in std_logic;
    node_din: in t_stubsRoute( routeBlocks - 1 downto 0 );
    node_dout: out t_stubsDTC( numOverlap - 1 downto 0 )
);
end component;

begin

g: for k in TMPtfp - 1 downto 0 generate

signal node_din: t_stubsRoute( routeBlocks - 1 downto 0 ) := ( others => nullStub );
signal node_dout: t_stubsDTC( numOverlap - 1 downto 0 ) := ( others => nullStub );

function linkMapping( i: t_stubsRoute ) return t_stubsRoute is
    variable o: t_stubsRoute( routeBlocks - 1 downto 0 ) := ( others => nullStub );
begin
    for j in routeBlocks - 1 downto 0 loop
        o( j ) := i( j * TMPtfp + k );
    end loop;
    return o;
end function;

begin

node_din <= linkMapping( mux_din );
mux_dout( numOverlap * ( k + 1 ) - 1 downto numOverlap * k ) <= node_dout;

c: dtc_mux_node port map ( clk, node_din, node_dout );

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.config.all;
use work.dtc_stubs.all;
use work.dtc_config.all;

entity dtc_mux_node is
port (
    clk: in std_logic;
    node_din: in t_stubsRoute( routeBlocks - 1 downto 0 );
    node_dout: out t_stubsDTC( numOverlap - 1 downto 0 )
);
end;

architecture rtl of dtc_mux_node is

signal output_din: t_stubsRoute( routeBlocks - 1 downto 0 ) := ( others => nullStub );
signal output_empty: std_logic_vector( routeBlocks - 1 downto 0 ) := ( others => '1' );
signal output_enable: std_logic_vector( routeBlocks - 1 downto 0 ) := ( others => '0' );
signal output_dout: t_stubsDTC( numOverlap - 1 downto 0 ) := ( others => nullStub );
component dtc_mux_node_output
port (
    clk: in std_logic;
    output_din: in t_stubsRoute( routeBlocks - 1 downto 0 );
    output_empty: in std_logic_vector( routeBlocks - 1 downto 0 );
    output_enable: out std_logic_vector( routeBlocks - 1 downto 0 );
    output_dout: out t_stubsDTC( numOverlap - 1 downto 0 )
);
end component;

component dtc_mux_node_input
port (
    clk: in std_logic;
    input_din: in t_stubRoute;
    input_enable: in std_logic;
    input_empty: out std_logic;
    input_dout: out t_stubRoute
);
end component;

begin

node_dout <= output_dout;

c: dtc_mux_node_output port map ( clk, output_din, output_empty, output_enable, output_dout );

g: for k in routeBlocks - 1 downto 0 generate

signal input_din: t_stubRoute := nullStub;
signal input_enable: std_logic := '0';
signal input_empty: std_logic := '1';
signal input_dout: t_stubRoute := nullStub;

begin

input_din <= node_din( k );
input_enable <= output_enable( k );
output_empty( k ) <= input_empty;
output_din( k ) <= input_dout;

c: dtc_mux_node_input port map ( clk, input_din, input_enable, input_empty, input_dout );

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.config.all;
use work.tools.all;
use work.dtc_stubs.all;
use work.dtc_config.all;

entity dtc_mux_node_output is
port (
    clk: in std_logic;
    output_din: in t_stubsRoute( routeBlocks - 1 downto 0 );
    output_empty: in std_logic_vector( routeBlocks - 1 downto 0 );
    output_enable: out std_logic_vector( routeBlocks - 1 downto 0 );
    output_dout: out t_stubsDTC( numOverlap - 1 downto 0 )
);
end;

architecture rtl of dtc_mux_node_output is

signal din: t_stubsRoute( routeBlocks - 1 downto 0 ) := ( others => nullStub );
signal empty: std_logic_vector( routeBlocks - 1 downto 0 ) := ( others => '1' );
signal enable: std_logic_vector( routeBlocks - 1 downto 0 ) := ( others => '0' );
signal dout: t_stubsDTC( numOverlap - 1 downto 0 ) := ( others => nullStub );

signal stub: t_stubRoute := nullStub;

function lconv( s: t_stubRoute ) return t_stubsDTC is
    variable r: t_stubsDTC( numOverlap - 1 downto 0 ) := ( others => nullStub );
begin
    for k in numOverlap - 1 downto 0 loop
        r( k ) := ( s.reset, s.valid and s.nonant( k ), s.r, s.phi, s.z, s.mMin, s.mMax, s.etaMin, s.etaMax, s.layer );
    end loop;
    return r;
end function;

begin

din <= output_din;
empty <= output_empty;
output_enable <= enable;
output_dout <= dout;

process( clk ) is
begin
if rising_edge( clk ) then

    enable <= incr( empty ) and not empty;

    stub <= nullStub;
    for k in routeBlocks - 1 downto 0 loop
        if din( k ).valid = '1' then
            stub <= din( k );
        end if;
    end loop;
    for k in routeBlocks - 1 downto 0 loop
        if din( k ).reset = '1' then
            stub <= nullStub;
            stub.reset <= '1';
        end if;
    end loop;

    for k in numOverlap - 1 downto 0 loop
        dout( k ) <= ( stub.reset, stub.valid and stub.nonant( k ), stub.r, stub.phi, stub.z, stub.mMin, stub.mMax, stub.etaMin, stub.etaMax, stub.layer );
    end loop;

end if;
end process;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.config.all;
use work.tools.all;
use work.dtc_stubs.all;
use work.dtc_config.all;

entity dtc_mux_node_input is
port (
    clk: in std_logic;
    input_din: in t_stubRoute;
    input_enable: in std_logic;
    input_empty: out std_logic;
    input_dout: out t_stubRoute
);
attribute ram_style: string;
end;

architecture rtl of dtc_mux_node_input is

signal din: t_stubRoute := nullStub;
signal enable, reset: std_logic := '0';
signal empty: std_logic := '1';
signal dout: t_stubRoute := nullStub;

constant widthRam: natural := numOverlap + widthR + widthPhiDTC + widthZ + widthMBin + widthMBin + widthSectorEta + widthSectorEta + widthLayer;
type t_ram is array ( natural range <> ) of std_logic_vector( widthRam - 1 downto 0 );
signal ram: t_ram( 2 ** widthStubs - 1 downto 0 ) := ( others => ( others => '0' ) );
signal raddr, waddr: std_logic_vector( widthStubs - 1 downto 0 ) := ( others => '0' );
signal regOptional: t_stubRoute := nullStub;
attribute ram_style of ram: signal is "block";

function lconv( s: t_stubRoute ) return std_logic_vector is
    variable r: std_logic_vector( widthRam  - 1 downto 0 ) := ( others => '0' );
begin
    r := s.nonant & s.r & s.phi & s.z & s.mMin & s.mMax & s.etaMin & s.etaMax & s.layer;
    return r;
end function;

function lconv( s: std_logic_vector ) return t_stubRoute is
    variable r: t_stubRoute := nullStub;
begin
    r.nonant := s( numOverlap + widthR + widthPhiDTC + widthZ + widthMBin + widthMBin + widthSectorEta + widthSectorEta + widthLayer - 1 downto widthR + widthPhiDTC + widthZ + widthMBin + widthMBin + widthSectorEta + widthSectorEta + widthLayer );
    r.r      := s(              widthR + widthPhiDTC + widthZ + widthMBin + widthMBin + widthSectorEta + widthSectorEta + widthLayer - 1 downto          widthPhiDTC + widthZ + widthMBin + widthMBin + widthSectorEta + widthSectorEta + widthLayer );
    r.phi    := s(                       widthPhiDTC + widthZ + widthMBin + widthMBin + widthSectorEta + widthSectorEta + widthLayer - 1 downto                        widthZ + widthMBin + widthMBin + widthSectorEta + widthSectorEta + widthLayer );
    r.z      := s(                                     widthZ + widthMBin + widthMBin + widthSectorEta + widthSectorEta + widthLayer - 1 downto                                 widthMBin + widthMBin + widthSectorEta + widthSectorEta + widthLayer );
    r.mMin   := s(                                              widthMBin + widthMBin + widthSectorEta + widthSectorEta + widthLayer - 1 downto                                             widthMBin + widthSectorEta + widthSectorEta + widthLayer );
    r.mMax   := s(                                                          widthMBin + widthSectorEta + widthSectorEta + widthLayer - 1 downto                                                         widthSectorEta + widthSectorEta + widthLayer );
    r.etaMin := s(                                                                      widthSectorEta + widthSectorEta + widthLayer - 1 downto                                                                          widthSectorEta + widthLayer );
    r.etaMax := s(                                                                                       widthSectorEta + widthLayer - 1 downto                                                                                           widthLayer );
    r.layer  := s(                                                                                                        widthLayer - 1 downto                                                                                                    0 );
    return r;
end function;

begin

din <= input_din;
enable <= input_enable;
input_empty <= empty;
input_dout <= dout;

process( clk ) is
begin
if rising_edge( clk ) then

    reset <= din.reset;
    regOptional <= lconv( ram( uint( raddr ) ) );
    ram( uint( waddr ) ) <= lconv( din );
    if enable = '1' then
        raddr <= incr( raddr );
        if incr( raddr ) = waddr then
            empty <= '1';
        end if;
    end if;
    if din.valid = '1' then
        waddr <= incr( waddr );
        empty <= '0';
    end if;
    if din.reset = '1' then
        waddr <= ( others => '0' );
        raddr <= ( others => '0' );
        empty <= '1';
    end if;

    dout <= regOptional;
    if enable = '1' then
        dout.valid <= '1';
    end if;
    if reset = '1' then
        dout.reset <= '1';
    end if;

end if;
end process;

end;