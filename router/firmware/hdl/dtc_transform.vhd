library ieee;
use ieee.std_logic_1164.all;
use work.config.all;
use work.dtc_stubs.all;
use work.dtc_config.all;

entity dtc_transform is
port (
    clk: in std_logic;
    transform_ipbus: in t_ipbuss( modulesPerDTC - 1 downto 0 );
    transform_din: in t_stubsFE( modulesPerDTC - 1 downto 0 );
    transform_dout: out t_stubsTransform( modulesPerDTC - 1 downto 0 )
);
end;


architecture rtl of dtc_transform is

component dtc_transform_node
generic (
    id: natural
);
port (
    clk: in std_logic;
    node_ipbus: in t_ipbus;
    node_din: in t_stubFE;
    node_dout: out t_stubTransform
);
end component;

begin

g: for k in modulesPerDTC - 1 downto 0 generate

signal node_ipbus: t_ipbus := nullBus;
signal node_din: t_stubFE := nullStub;
signal node_dout: t_stubTransform := nullStub;

begin

node_ipbus <= transform_ipbus( k );
node_din <= transform_din( k );
transform_dout( k ) <= node_dout;

c: dtc_transform_node generic map ( k ) port map ( clk, node_ipbus, node_din, node_dout );

end generate;

end;


library ieee, std;
use std.textio.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.config.all;
use work.tools.all;
use work.dtc_stubs.all;
use work.dtc_config.all;
use work.trackerGeometry.all;

entity dtc_transform_node is
generic (
    id: natural := 0
);
port (
    clk: in std_logic;
    node_ipbus: in t_ipbus;
    node_din: in t_stubFE;
    node_dout: out t_stubTransform
);
attribute ram_style: string;
attribute keep: string;
attribute use_dsp: string;
end;



architecture rtl of dtc_transform_node is

-- step 1

signal ipbus: t_ipbus := nullBus;
signal din: t_stubFE := nullStub;
signal reset: std_logic_vector( 6 - 1 downto 0 ) := ( others => '0' );
signal valid: std_logic_vector( 6 - 1 downto 0 ) := ( others => '0' );
signal bx: t_bxs( 6 - 1 downto 0 ) := ( others => ( others => '0' ) );
signal row: t_rows( 2 - 1 downto 0 ) := ( others => ( others => '0' ) );
signal ramPos: t_ramPos := init_ramPos( id );
signal ramBend: t_ramBend := init_ramBend( id );
signal regOptionalPos: t_wordPos := ( others => ( others => '0' ) );
signal regOptionalBend: t_wordBend := ( others => ( others => '0' ) );
attribute keep of ipbus: signal is "true";
attribute ram_style of ramPos, ramBend: signal is "block";

-- step 2

signal regPos: t_wordPos := ( others => ( others => '0' ) );
signal regBend: t_wordBend := ( others => ( others => '0' ) );

-- step 3

signal sr: t_sr( 4 - 1 downto 0 ) := ( others => ( others => ( others => '0' ) ) );

signal dspPhi: t_dspPhi := ( others => ( others => '0' ) );
signal dspPhiTmin, dspPhiTmax: t_dspPhiT := ( others => ( others => '0' ) );
attribute use_dsp of dspPhi, dspPhiTmin, dspPhiTmax: signal is "yes";

-- step 4

-- step 5

signal phi: std_logic_vector( widthPhiDTC - 1 downto 0 ) := ( others => '0' );
signal phis: t_phis( 2 - 1 downto 0 ) := ( others => ( others => '0' ) );

-- step 6

-- step 7

signal layer: std_logic_vector( work.config.widthLayer - 1 downto 0 ) := layers( id );
signal dout: t_stubTransform := nullStub;


begin

-- step 1
ipbus <= node_ipbus;
din <= node_din;

-- step 5
phi <= dspPhi.y( baseDiffPhiM + 2 + widthPhiDTC - 1 downto baseDiffPhiM + 2 );

--step 7
node_dout <= dout;


process( clk ) is
begin
if rising_edge( clk ) then

    -- step 1

    reset <= reset( reset'high - 1 downto 0 ) & din.reset;
    valid <= valid( valid'high - 1 downto 0 ) & din.valid;
    bx <= bx( bx'high - 1 downto 0 ) & din.bx;
    row <= row( row'high - 1 downto 0 ) & din.row( baseDiffPhiM - 1 downto 0 );
    regOptionalPos <= conv_pos( ramPos( uint( din.col & din.row( widthRow - 1 downto widthRow - widthRowLUT ) ) ) );
    regOptionalbend <= conv_bend( ramBend( uint( din.col & din.bend ) ) );

    -- step 2

    regPos <= regOptionalPos;
    regBend <= regOptionalBend;

    -- step 3

    sr <= sr( sr'high - 1 downto 0 ) & conv( regPos, regBend );

    dspPhi.d <= '0' & stdu( 2 ** ( baseDiffPhiM - 1 ), baseDiffPhiM ) & '0';
    dspPhi.x <= '0' & row( row'high ) & '0';
    dspPhi.c <= resize( regPos.phiC & "10" & ( baseDiffPhiM - 1 downto 0 => '0' ), widthDSPPhi - 1 );
    dspPhi.m <= '0' & regPos.phiM & '1';

    dspPhiTmin.x0 <= regPos.r & '1';
    dspPhitmin.m0 <= regBend.mMin & '1';

    dspPhiTmax.x0 <= regPos.r & '1';
    dspPhitmax.m0 <= regBend.mMax & '1';

    -- step 4

    dspPhi.y <= ( dspPhi.x - dspPhi.d ) * dspPhi.m + dspPhi.c;

    dspPhiTmin.x1 <= dspPhiTmin.x0;
    dspPhiTmin.m1 <= dspPhiTmin.m0;

    dspPhiTmax.x1 <= dspPhiTmax.x0;
    dspPhiTmax.m1 <= dspPhiTmax.m0;

    -- step 5

    phis <= phis( phis'high - 1 downto 0 ) & phi;

    dspPhiTmin.xm <= dspPhiTmin.x1 * dspPhiTmin.m1;
    dspPhiTmin.c <= phi & '1' & ( baseDiffPhiDTC - 1 downto 0 => '0' ) & '0';

    dspPhiTmax.xm <= dspPhiTmax.x1 * dspPhiTmax.m1;
    dspPhiTmax.c <= phi & '1' & ( baseDiffPhiDTC - 1 downto 0 => '0' ) & '0';

    -- step 6

    dspPhiTmin.y <= dspPhiTmin.c + dspPhiTmin.xm;
    dspPhiTmax.y <= dspPhiTmax.c + dspPhiTmax.xm;

    -- step 7

    dout <= nullStub;
    if valid( valid'high ) = '1' then
        dout.valid  <= '1';
        dout.z      <= sr( sr'high ).z;
        dout.r      <= sr( sr'high ).r;
        dout.etaMin <= sr( sr'high ).etaMin;
        dout.etaMax <= sr( sr'high ).etaMax;
        dout.mMin   <= sr( sr'high ).mMin;
        dout.mMax   <= sr( sr'high ).mMax;
        dout.phi    <= phis( phis'high );
        dout.nonant <= to_nonant( dspPhiTmin.y, dspPhiTmax.y );
        dout.bx     <= bx( bx'high );
        dout.layer  <= layer;
    end if;
    if reset( reset'high ) = '1' then
        dout.reset <= '1';
    end if;
    dout.reset <= reset( reset'high );
    dout.bx( widthBX - 1 downto widthTMPfe ) <= bx( bx'high )( widthBX - 1 downto widthTMPfe );

    -- ipbus

    if ipbus.enPos = '1' then
        ramPos( uint( ipbus.addrPos ) ) <= ipbus.wordPos;
    end if;
    if ipbus.enBend = '1' then
        ramBend( uint( ipbus.addrBend ) ) <= ipbus.wordBend;
    end if;
    if ipbus.enLayer = '1' then
        layer <= ipbus.layer;
    end if;

end if;
end process;


end;
