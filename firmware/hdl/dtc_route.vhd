library ieee;
use ieee.std_logic_1164.all;
use work.config.all;
use work.dtc_stubs.all;
use work.dtc_config.all;

entity dtc_route is
port (
    clk: in std_logic;
    route_din: in t_stubsTransform( ModulesPerDTC - 1 downto 0 );
    route_dout: out t_stubsRoute( routeStubs - 1 downto 0 )
);
end;

architecture rtl of dtc_route is

component dtc_route_block
port (
    clk: in std_logic;
    block_din: in t_stubsTransform( routeNodeInputs - 1 downto 0 );
    block_dout: out t_stubsRoute( TMPtfp - 1 downto 0 )
);
end component;

begin

g: for k in routeBlocks - 1 downto 0 generate

signal block_din: t_stubsTransform( routeNodeInputs - 1 downto 0 ) := ( others => nullStub );
signal block_dout: t_stubsRoute( TMPtfp - 1 downto 0 ) := ( others => nullStub );

begin

block_din <= route_din( routeNodeInputs * ( k + 1  ) - 1 downto routeNodeInputs * k );
route_dout( TMPtfp * ( k + 1  ) - 1 downto TMPtfp * k ) <= block_dout;

c: dtc_route_block port map ( clk, block_din, block_dout );

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.config.all;
use work.dtc_stubs.all;
use work.dtc_config.all;

entity dtc_route_block is
port (
    clk: in std_logic;
    block_din: in t_stubsTransform( routeNodeInputs - 1 downto 0 );
    block_dout: out t_stubsRoute( TMPtfp - 1 downto 0 )
);
end;

architecture rtl of dtc_route_block is

signal desync_din: t_stubsTransform( routeNodeInputs - 1 downto 0 ) := ( others => nullStub );
signal desync_dout: t_stubsTransform( routeNodeInputs - 1 downto 0 ) := ( others => nullStub );
component dtc_route_desync
port (
    clk: in std_logic;
    desync_din: in t_stubsTransform( routeNodeInputs - 1 downto 0 );
    desync_dout: out t_stubsTransform( routeNodeInputs - 1 downto 0 )
);
end component;

signal reset_din: t_stubTransform := nullStub;
signal reset_dout: t_stubsRoute( TMPtfp - 1 downto 0 ) := ( others => nullStub );
component dtc_route_reset
port (
    clk: in std_logic;
    reset_din: in t_stubTransform;
    reset_dout: out t_stubsRoute( TMPtfp - 1 downto 0 )
);
end component;

signal array_din: t_stubsTransform( routeNodeInputs - 1 downto 0 ) := ( others => nullStub );
signal array_reset: t_stubsRoute( TMPtfp - 1 downto 0 ) := ( others => nullStub );
signal array_dout: t_stubsRoute( TMPtfp - 1 downto 0 ) := ( others => nullStub );
component dtc_route_array
port (
    clk: in std_logic;
    array_din: in t_stubsTransform( routeNodeInputs - 1 downto 0 );
    array_reset: in t_stubsRoute( TMPtfp - 1 downto 0 );
    array_dout: out t_stubsRoute( TMPtfp - 1 downto 0 )
);
end component;

begin

desync_din <= block_din;

process( clk ) is begin if rising_edge( clk ) then
    reset_din <= block_din( routeNodeInputs - 1 );
end if; end process;

array_din <= desync_dout;
array_reset <= reset_dout;

block_dout <= array_dout;

cD: dtc_route_desync port map ( clk, desync_din, desync_dout );

cR: dtc_route_reset port map ( clk, reset_din, reset_dout );

cA: dtc_route_array port map ( clk, array_din, array_reset, array_dout );

end;


library ieee;
use ieee.std_logic_1164.all;
use work.config.all;
use work.tools.all;
use work.dtc_stubs.all;
use work.dtc_config.all;

entity dtc_route_desync is
port (
    clk: in std_logic;
    desync_din: in t_stubsTransform( routeNodeInputs - 1 downto 0 );
    desync_dout: out t_stubsTransform( routeNodeInputs - 1 downto 0 )
);
end;

architecture rtl of dtc_route_desync is

component dtc_route_desync_node
generic (
    latency: natural
);
port (
    clk: in std_logic;
    node_din: in t_stubTransform;
    node_dout: out t_stubTransform
);
end component;

begin

g: for k in routeNodeInputs - 1 downto 0 generate

signal node_din: t_stubTransform := nullStub;
signal node_dout: t_stubTransform := nullStub;

begin

node_din <= desync_din( k );
desync_dout( k ) <= node_dout;

c: dtc_route_desync_node generic map ( routeNodeInputs - k ) port map ( clk, node_din, node_dout );

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.config.all;
use work.tools.all;
use work.dtc_stubs.all;
use work.dtc_config.all;

entity dtc_route_desync_node is
generic (
    latency: natural
);
port (
    clk: in std_logic;
    node_din: in t_stubTransform;
    node_dout: out t_stubTransform
);
attribute ram_style: string;
end;

architecture rtl of dtc_route_desync_node is

constant widthRam: natural := 1 + 1 + widthBX + numOverlap + widthR + widthPhiDTC + widthZ + widthMBin + widthMBin + widthSectorEta + widthSectorEta + widthLayer;
type t_ram is array ( natural range <> ) of std_logic_vector( widthRam - 1 downto 0 );
signal ram: t_ram( 2 ** widthStubs - 1 downto 0 ) := ( others => ( others => '0' ) );
signal waddr: std_logic_vector( widthStubs - 1 downto 0 ) := ( others => '0' );
signal raddr: std_logic_vector( widthStubs - 1 downto 0 ) := ( others => '0' );
signal regOptional, reg: std_logic_vector( widthRam - 1 downto 0 ) := ( others => '0' );
attribute ram_style of ram: signal is "block";

function lconv( t: t_stubTransform ) return std_logic_vector is
    variable s: std_logic_vector( widthRam - 1 downto 0 ) := ( others => '0' );
begin
    s := t.reset & t.valid & t.bx & t.nonant & t.r & t.phi & t.z & t.mMin & t.mMax & t.etaMin & t.etaMax & t.layer;
    return s;
end function;

function lconv( s: std_logic_vector ) return t_stubTransform is
    variable t: t_stubTransform := nullStub;
begin
    t.reset  := s( 1 + 1 + widthBX + numOverlap + widthR + widthPhiDTC + widthZ + widthMBin + widthMBin + widthSectorEta + widthSectorEta + widthLayer - 1 );
    t.valid  := s(     1 + widthBX + numOverlap + widthR + widthPhiDTC + widthZ + widthMBin + widthMBin + widthSectorEta + widthSectorEta + widthLayer - 1 );
    t.bx     := s(         widthBX + numOverlap + widthR + widthPhiDTC + widthZ + widthMBin + widthMBin + widthSectorEta + widthSectorEta + widthLayer - 1 downto numOverlap + widthR + widthPhiDTC + widthZ + widthMBin + widthMBin + widthSectorEta + widthSectorEta + widthLayer );
    t.nonant := s(                   numOverlap + widthR + widthPhiDTC + widthZ + widthMBin + widthMBin + widthSectorEta + widthSectorEta + widthLayer - 1 downto              widthR + widthPhiDTC + widthZ + widthMBin + widthMBin + widthSectorEta + widthSectorEta + widthLayer );
    t.r      := s(                                widthR + widthPhiDTC + widthZ + widthMBin + widthMBin + widthSectorEta + widthSectorEta + widthLayer - 1 downto                       widthPhiDTC + widthZ + widthMBin + widthMBin + widthSectorEta + widthSectorEta + widthLayer );
    t.phi    := s(                                         widthPhiDTC + widthZ + widthMBin + widthMBin + widthSectorEta + widthSectorEta + widthLayer - 1 downto                                     widthZ + widthMBin + widthMBin + widthSectorEta + widthSectorEta + widthLayer );
    t.z      := s(                                                       widthZ + widthMBin + widthMBin + widthSectorEta + widthSectorEta + widthLayer - 1 downto                                              widthMBin + widthMBin + widthSectorEta + widthSectorEta + widthLayer );
    t.mMin   := s(                                                                widthMBin + widthMBin + widthSectorEta + widthSectorEta + widthLayer - 1 downto                                                          widthMBin + widthSectorEta + widthSectorEta + widthLayer );
    t.mMax   := s(                                                                            widthMBin + widthSectorEta + widthSectorEta + widthLayer - 1 downto                                                                      widthSectorEta + widthSectorEta + widthLayer );
    t.etaMin := s(                                                                                        widthSectorEta + widthSectorEta + widthLayer - 1 downto                                                                                       widthSectorEta + widthLayer );
    t.etaMax := s(                                                                                                         widthSectorEta + widthLayer - 1 downto                                                                                                        widthLayer );
    t.layer  := s(                                                                                                                          widthLayer - 1 downto                                                                                                                 0 );
    return t;
end function;

begin

node_dout <= lconv( reg );
waddr <= std_logic_vector( unsigned( raddr ) + latency );

process( clk ) is
begin
if rising_edge( clk ) then

    ram( uint( waddr ) ) <= lconv( node_din );
    regOptional <= ram( uint( raddr ) );
    reg <= regOptional;
    raddr <= incr( raddr );

end if;
end process;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.config.all;
use work.dtc_stubs.all;

entity dtc_route_reset is
port (
    clk: in std_logic;
    reset_din: in t_stubTransform;
    reset_dout: out t_stubsRoute( tmpTFP - 1 downto 0 )
);
end;

architecture rtl of dtc_route_reset is

signal stub: t_stubTransform := nullStub;
signal stubs: t_stubsTransform( tmpTFP downto 0 ) := ( others => nullStub );
component dtc_route_reset_node
generic (
    id: natural
);
port (
    clk: in std_logic;
    node_tin: in t_stubTransform;
    node_tout: out t_stubTransform;
    node_rout: out t_stubRoute
);
end component;

begin

process( clk ) is
begin
if rising_edge( clk ) then

    stub <= reset_din;
    stubs( tmpTFP ) <= stub;

end if;
end process;

g: for k in tmpTFP - 1 downto 0 generate

signal node_tin: t_stubTransform := nullStub;
signal node_tout: t_stubTransform := nullStub;
signal node_rout: t_stubRoute := nullStub;

begin

node_tin <= stubs( k + 1 );
stubs( k ) <= node_tout;
reset_dout( k ) <= node_rout;

c: dtc_route_reset_node generic map ( k ) port map ( clk, node_tin, node_tout, node_rout );

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.config.all;
use work.tools.all;
use work.dtc_stubs.all;

entity dtc_route_reset_node is
generic (
    id: natural
);
port (
    clk: in std_logic;
    node_tin: in t_stubTransform;
    node_tout: out t_stubTransform;
    node_rout: out t_stubRoute
);
end;

architecture rtl of dtc_route_reset_node is

function init_times return naturals is
    variable times: naturals( tfpPackets - 1 downto 0 ) := ( others => numBX );
begin
    for k in tfpPackets - 1 downto 0 loop
        times( k ) := tmpTFP - id - 1 + k * tmpTFP;
    end loop;
    return times;
end function;
constant times: naturals( tfpPackets - 1 downto 0 ) := init_times;

signal tin: t_stubTransform := nullStub;
signal tout: t_stubTransform := nullStub;
signal rout: t_stubRoute := ( '0', '0', stdu( numBX, widthBX ), others => ( others => '0' ) );
signal reset: std_logic := '0';
signal counterClks: std_logic_vector( widthStubs - 1 downto 0 ) := stdu( numStubs, widthStubs );
signal counterTFPtmps: std_logic_vector( widthTFPPackets - 1 downto 0 ) := ( others => '0' );
signal sr: t_stubsTransform( 1 + bxClks - 1 downto 0 ) := ( others => nullStub );

begin

tin <= node_tin;
node_tout <= tout;
node_rout <= rout;
reset <= '1' when tin.reset = '1' and uint( tin.bx( widthBX - 1 downto widthTMPfe ) ) = 0 else '0';
tout <= sr( sr'high );

process( clk ) is
begin
if rising_edge( clk ) then

    sr <= sr( sr'high - 1 downto 0 ) & tin;
    counterClks <= incr( counterClks );
    rout.reset <= '0';
    if uint( counterClks ) = numStubs - 1 and uint( counterTFPtmps ) < tfpPackets - 1 then
        counterClks <= ( others => '0' );
        counterTFPtmps <= incr( counterTFPtmps );
        rout.bx <= stdu( times( uint( incr( counterTFPtmps ) ) ), widthBX );
        rout.reset <= '1';
    end if;
    if reset = '1' then
        counterTFPtmps <= ( others => '0' );
        counterClks <= ( others => '0' );
        rout.bx <= stdu( times( 0 ), widthBX );
        rout.reset <= '1';
    end if;

end if;
end process;

end;

library ieee;
use ieee.std_logic_1164.all;
use work.config.all;
use work.dtc_stubs.all;
use work.dtc_config.all;

entity dtc_route_array is
port (
    clk: in std_logic;
    array_din: in t_stubsTransform( routeNodeInputs - 1 downto 0 );
    array_reset: in t_stubsRoute( TMPtfp - 1 downto 0 );
    array_dout: out t_stubsRoute( TMPtfp - 1 downto 0 )
);
end;

architecture rtl of dtc_route_array is

type t_blockStubs is array( routeNodeInputs downto 0 ) of t_stubsRoute( TMPtfp - 1 downto 0 );
signal bockStubs: t_blockStubs := ( others => ( others => nullStub ) );
component dtc_route_row
port (
    clk: in std_logic;
    row_tin: in t_stubTransform;
    row_rin: in t_stubsRoute( TMPtfp - 1 downto 0 );
    row_rout: out t_stubsRoute( TMPtfp - 1 downto 0 )
);
end component;

begin

bockStubs( routeNodeInputs ) <= array_reset;
array_dout <= bockStubs( 0 );

g: for k in routeNodeInputs - 1 downto 0 generate

signal row_tin: t_stubTransform := nullStub;
signal row_rin: t_stubsRoute( TMPtfp - 1 downto 0 ) := ( others => nullStub );
signal row_rout: t_stubsRoute( TMPtfp - 1 downto 0 ) := ( others => nullStub );

begin

row_tin <= array_din( k );
row_rin <= bockStubs( k + 1 );
bockStubs( k ) <= row_rout;

c: dtc_route_row port map ( clk, row_tin, row_rin, row_rout );

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.config.all;
use work.dtc_stubs.all;
use work.dtc_config.all;

entity dtc_route_row is
port (
    clk: in std_logic;
    row_tin: in t_stubTransform;
    row_rin: in t_stubsRoute( TMPtfp - 1 downto 0 );
    row_rout: out t_stubsRoute( TMPtfp - 1 downto 0 )
);
end;

architecture rtl of dtc_route_row is

signal stubsTransform: t_stubsTransform( TMPtfp downto 0 ) := ( others => nullStub );
component dtc_route_cell
generic (
    bx: natural
);
port (
    clk: in std_logic;
    cell_tin: in t_stubTransform;
    cell_rin: in t_stubRoute;
    cell_rout: out t_stubRoute;
    cell_tout: out t_stubTransform
);
end component;

begin

stubsTransform( TMPtfp ) <= row_tin;

g: for k in TMPtfp - 1 downto 0 generate

signal cell_tin: t_stubTransform := nullStub;
signal cell_rin: t_stubRoute := nullStub;
signal cell_rout: t_stubRoute := nullStub;
signal cell_tout: t_stubTransform := nullStub;

begin

cell_tin <= stubsTransform( k + 1 );
stubsTransform( k ) <= cell_tout;
cell_rin <= row_rin( k );
row_rout( k ) <= cell_rout;

c: dtc_route_cell generic map ( TMPtfp - k - 1 ) port map ( clk, cell_tin, cell_rin, cell_rout, cell_tout );

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.config.all;
use work.tools.all;
use work.dtc_stubs.all;
use work.dtc_config.all;

entity dtc_route_cell is
generic (
    bx: natural
);
port (
    clk: in std_logic;
    cell_tin: in t_stubTransform;
    cell_rin: in t_stubRoute;
    cell_rout: out t_stubRoute;
    cell_tout: out t_stubTransform
);
attribute ram_style: string;
end;

architecture rtl of dtc_route_cell is

function bxs_init return naturals is
    variable r: naturals( tfpPackets - 1 downto 0 ) := ( others => 0 );
begin
    for k in tfpPackets - 1 downto 0 loop
        r( k ) := k * tmpTFP + bx;
    end loop;
    return r;
end function;
constant bxs: naturals( tfpPackets - 1 downto 0 ) := bxs_init;

signal tin, tout: t_stubTransform := nullStub;
signal rin, rout: t_stubRoute := nullStub;

signal stub: t_stubRoute := nullStub;
constant widthRam: natural := numOverlap + widthR + widthPhiDTC + widthZ + widthMBin + widthMBin + widthSectorEta + widthSectorEta + widthLayer;
type t_ram is array ( natural range <> ) of std_logic_vector( widthRam - 1 downto 0 );
signal ram: t_ram( 2 ** widthCICstubs - 1 downto 0 ) := ( others => ( others => '0' ) );
signal raddr, waddr, laddr: std_logic_vector( widthCICstubs - 1 downto 0 ) := ( others => '0' );
attribute ram_style of ram: signal is "distributed";

function bxCheck( sbx: std_logic_vector ) return boolean is
begin
    for k in bxs'range loop
        if bxs( k ) = uint( sbx ) then
            return  true;
        end if;
    end loop;
    return false;
end function;

begin

tin <= cell_tin;
rin <= cell_rin;
cell_tout <= tout;
cell_rout <= rout;

stub <= conv( ram( uint( raddr ) ) );

process( clk ) is
begin
if rising_edge( clk ) then

    tout <= tin;
    rout <= rin;
    ram( uint( waddr ) ) <= conv( tin );
    if rin.valid = '0' and rin.reset = '0' and raddr < laddr then
        rout <= stub;
        rout.valid <= '1';
        raddr <= incr( raddr );
    end if;
    if rin.reset = '1' then
        raddr <= laddr;
        laddr <= waddr;
    end if;
    rout.bx <= rin.bx;

    if tin.valid = '1'then
        if bxCheck( tin.bx ) then
            waddr <= incr( waddr );
        end if;
        if rin.bx = tin.bx then
            laddr <= incr( waddr );
        end if;
    end if;

end if;
end process;

end;
