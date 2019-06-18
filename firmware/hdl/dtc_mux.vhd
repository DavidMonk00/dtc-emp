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
use work.tools.all;
use work.dtc_stubs.all;
use work.dtc_config.all;

entity dtc_mux_node is
port (
    clk: in std_logic;
    node_din: in t_stubsRoute( routeBlocks - 1 downto 0 );
    node_dout: out t_stubsDTC( numOverlap - 1 downto 0 )
);
attribute ram_style: string;
end;

architecture rtl of dtc_mux_node is

constant widthStub: natural := widthR + widthPhiDTC + widthZ + widthMBin + widthMBin + widthSectorEta + widthSectorEta + widthLayer;
constant widthPattern: natural := numOverlap;
constant widthRam: natural := widthPattern + widthStub;
subtype rangeStub is natural range widthStub - 1 downto 0;
subtype rangePattern is natural range widthPattern + widthStub - 1 downto widthStub;
type t_pattern is array ( natural range <> ) of std_logic_vector( widthPattern - 1 downto 0 );
type t_ram is array ( natural range <> ) of std_logic_vector( widthRam - 1 downto 0 );
type t_vStubs is array ( natural range <> ) of std_logic_vector( widthStub - 1 downto 0 );

signal patterns: t_pattern( routeBlocks - 1 downto 0 ) := ( others => ( others => '0' ) );
signal stubs: t_vStubs( routeBlocks - 1 downto 0 ) := ( others => ( others => '0' ) );
signal enablesOut: t_pattern( routeBlocks - 1 downto 0 ) := ( others => ( others => '0' ) );

function set_enables( patterns: t_pattern ) return t_pattern is
    variable enables: t_pattern( routeBlocks - 1 downto 0 ) := ( others => ( others => '0' ) );
begin
    for k in numOverlap - 1 downto 0 loop
        for l in routeBlocks - 1 downto 0 loop
            if patterns( l )( k ) = '1' then
                enables( l )( k ) := '1';
                exit;
            end if;
        end loop;
    end loop;
    return enables;
end function;

function lconv( s: t_stubRoute ) return std_logic_vector is begin return s.r & s.phi & s.z & s.mMin & s.mMax & s.etaMin & s.etaMax & s.layer; end function;

function lconv( s: std_logic_vector ) return t_stubDTC is
    variable stub: t_stubDTC := nullStub;
begin
    stub.r      := s( widthR + widthPhiDTC + widthZ + widthMBin + widthMBin + widthSectorEta + widthSectorEta + widthLayer - 1 downto widthPhiDTC + widthZ + widthMBin + widthMBin + widthSectorEta + widthSectorEta + widthLayer );
    stub.phi    := s(          widthPhiDTC + widthZ + widthMBin + widthMBin + widthSectorEta + widthSectorEta + widthLayer - 1 downto               widthZ + widthMBin + widthMBin + widthSectorEta + widthSectorEta + widthLayer );
    stub.z      := s(                        widthZ + widthMBin + widthMBin + widthSectorEta + widthSectorEta + widthLayer - 1 downto                        widthMBin + widthMBin + widthSectorEta + widthSectorEta + widthLayer );
    stub.mMin   := s(                                 widthMBin + widthMBin + widthSectorEta + widthSectorEta + widthLayer - 1 downto                                    widthMBin + widthSectorEta + widthSectorEta + widthLayer );
    stub.mMax   := s(                                             widthMBin + widthSectorEta + widthSectorEta + widthLayer - 1 downto                                                widthSectorEta + widthSectorEta + widthLayer );
    stub.etaMin := s(                                                         widthSectorEta + widthSectorEta + widthLayer - 1 downto                                                                 widthSectorEta + widthLayer );
    stub.etaMax := s(                                                                          widthSectorEta + widthLayer - 1 downto                                                                                  widthLayer );
    stub.layer  := s(                                                                                           widthLayer - 1 downto                                                                                           0 );
    return stub;
end function;

begin

enablesOut <= set_enables( patterns );


gOuts: for k in numOverlap - 1 downto 0 generate

signal stub: t_stubDTC := nullStub;
signal reset: std_logic_vector( 3 downto 0 ) := ( others => '0' );

begin

node_dout( k ) <= stub;

process( clk ) is
begin
if rising_edge( clk ) then

    reset <= reset( reset'high - 1 downto 0 ) & node_din( 0 ).reset;
    stub <= nullStub;
    for l in routeBlocks - 1 downto 0 loop
        if enablesOut( l )( k ) = '1' then
            stub <= lconv( stubs( l ) );
            stub.valid <= '1';
            exit;
        end if;
    end loop;
    if reset( reset'high ) = '1' then
        stub <= nullStub;
        stub.reset <= '1';
    end if;

end if;
end process;

end generate;


gIn: for k in routeBlocks - 1 downto 0 generate

signal din: t_stubRoute := nullStub;

signal ram: t_ram( 2 ** widthStubs - 1 downto 0 ) := ( others => ( others => '0' ) );
signal ramReg: std_logic_vector( widthRam - 1 downto 0 ) := ( others => '0' );
signal waddr, raddr, addr: std_logic_vector( widthStubs - 1 downto 0 ) := ( others => '0' );
signal reset, enableIn, valid, validIn, protect, resetIn: std_logic := '0';
signal loaded: std_logic_vector( 1 downto 0 ) := ( others => '0' );
signal patternIn: std_logic_vector( widthPattern - 1 downto 0 ) := ( others => '0' );
signal ramPattern: std_logic_vector( widthPattern - 1 downto 0 ) := ( others => '0' );
signal ramStub: std_logic_vector( widthStub - 1 downto 0 ) := ( others => '0' );
signal ramStubStub, stubStub: t_stubDTC := nullStub;

signal stub: std_logic_vector( widthStub - 1 downto 0 ) := ( others => '0' );
signal pattern: std_logic_vector( widthPattern - 1 downto 0 ) := ( others => '0' );
signal enableOut: std_logic_vector( widthPattern - 1 downto 0 ) := ( others => '0' );

attribute ram_style of ram: signal is "block";

begin


enableOut <= enablesOut( k );
stubs( k ) <= stub;
patterns( k ) <= pattern;

patternIn <= din.nonant;
ramPattern <= ramReg( rangePattern );
ramStub <= ramReg( rangeStub );
ramStubStub <= lconv( ramStub );
stubStub <= lconv( stub );
enableIn <= '1' when uint( enableOut ) > 0 and enableOut = pattern else '0';
protect <= '1' when ( addr = waddr ) or ( incr( addr ) = waddr and valid = '1' ) else '0';
raddr <= incr( addr ) when ( enableIn = '1' or loaded( 1 ) = '0' or loaded( 0 ) = '0' ) and protect = '0' else addr;

process( clk ) is
begin
if rising_edge( clk ) then

    din <= node_din( k );

    reset <= din.reset;
    valid <= din.valid;
    ramReg <= ram( uint( raddr ) );
    ram( uint( waddr ) ) <= patternIn & lconv( din );
    if din.valid = '1' then
        waddr <= incr( waddr );
    end if;
    if din.reset = '1' then
        valid <= '0';
        waddr <= ( others => '0' );
    end if;

    validIn <= valid;
    pattern <= pattern xor enableOut;
    addr <= raddr;
    resetIn <= reset;
    if resetIn = '1' then
        pattern <= ( others => '0' );
    end if;
    if enableIn = '1' or loaded( 1 ) = '0' then
        loaded( 1 ) <= loaded( 0 );
        pattern <= ramPattern;
        stub <= ramStub;
    end if;
    if ( enableIn = '1' or loaded( 1 ) = '0' ) and ( ( validIn = '0' and addr = waddr ) or ( valid = '0' and incr( addr ) = waddr ) ) then
        loaded( 0 ) <= '0';
    end if;
    if ( validIn = '1' and addr = waddr ) or ( valid = '1' and incr( addr ) = waddr ) then
        loaded( 0 ) <= '1';
    end if;
    if enableIn = '1' and loaded( 0 ) = '0' then
        pattern <= ( others => '0' );
    end if;
    if reset = '1' then
        validIn <= '0';
        --pattern <= ( others => '0' );
        loaded <= ( others => '0' );
        addr <= ( others => '0' );
    end if;

end if;
end process;

end generate;

end;