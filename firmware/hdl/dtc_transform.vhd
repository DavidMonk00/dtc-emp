library ieee;
use ieee.std_logic_1164.all;
use work.config.all;
use work.dtc_stubs.all;

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
use work.config.all;
use work.tools.all;
use work.dtc_stubs.all;
use work.dtc_config.all;

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
end;



architecture rtl of dtc_transform_node is

-- step 1

signal layer: std_logic_vector( widthLayer - 1 downto 0 ) := layers( id );
signal ipbus: t_ipbus := nullBus;
signal din: t_stubFE := nullStub;
signal valid, reset: std_logic := '0';
signal bx: std_logic_vector( widthBX - 1 downto 0 ) := ( others => '0' );
attribute keep of ipbus: signal is "true";

signal ramA: t_ramA := init_A( id );
signal ramB: t_ramB := init_B( id );
signal ramC: t_ramC := init_C( id );
signal addrA: std_logic_vector( widthCol - 1 downto 0 ) := ( others => '0' );
signal addrB: std_logic_vector( widthCol + widthRowB - 1 downto 0 ) := ( others => '0' );
signal addrC: std_logic_vector( widthRowC + widthBendCIC - 1 downto 0 ) := ( others => '0' );
signal regA: std_logic_vector( widthZ - 1 downto 0 ) := ( others => '0' );
signal regB: std_logic_vector( widthR + widthPhiDTC + widthSectorEta + widthSectorEta - 1 downto 0 ) := ( others => '0' );
signal regC: std_logic_vector( widthMBin + widthMBin + numOverlap - 1 downto 0 ) := ( others => '0' );
attribute ram_style of ramB, ramC: signal is "block";
attribute ram_style of ramA: signal is "distributed";

-- step 2

signal dout: t_stubTransform := nullStub;

begin


-- step 1
ipbus <= node_ipbus;
din <= node_din;
addrA <= din.col;
addrB <= din.col & din.row( widthRow - 1 downto widthRow - widthRowB );
addrC <= din.row( widthRow - 1 downto widthRow - widthRowC ) & din.bend;

--step 2
node_dout <= dout;


process( clk ) is
begin
if rising_edge( clk ) then

    -- step 1

    reset <= din.reset;
    valid <= din.valid;
    bx <= din.bx;
    regA <= ramA( uint( addrA ) );
    regB <= ramB( uint( addrB ) );
    regC <= ramC( uint( addrC ) );

    -- step 2

    dout <= nullStub;
    if valid = '1' then
        dout.valid  <= '1';
        dout.z      <= regA;
        dout.r      <= regB( widthR + widthPhiDTC + widthSectorEta + widthSectorEta - 1 downto widthPhiDTC + widthSectorEta + widthSectorEta );
        dout.phi    <= regB(          widthPhiDTC + widthSectorEta + widthSectorEta - 1 downto               widthSectorEta + widthSectorEta );
        dout.etaMin <= regB(                        widthSectorEta + widthSectorEta - 1 downto                                widthSectorEta );
        dout.etaMax <= regB(                                         widthSectorEta - 1 downto                                             0 );
        dout.mMin   <= regC( widthMBin + widthMBin + numOverlap - 1 downto widthMBin + numOverlap );
        dout.mMax   <= regC(             widthMBin + numOverlap - 1 downto             numOverlap );
        dout.nonant <= regC(                         numOverlap - 1 downto                      0 );
        dout.bx     <= bx;
        dout.layer  <= layer;
    end if;
    if reset = '1' then
        dout.reset <= '1';
    end if;
    dout.bx( widthBX - 1 downto widthTMPfe ) <= bx( widthBX - 1 downto widthTMPfe );

    -- ipbus

    if ipbus.enA = '1' then
        ramA( uint( ipbus.addrA ) ) <= ipbus.wordA;
    end if;
    if ipbus.enB = '1' then
        ramB( uint( ipbus.addrB ) ) <= ipbus.wordB;
    end if;
    if ipbus.enC = '1' then
        ramC( uint( ipbus.addrC ) ) <= ipbus.wordC;
    end if;
    if ipbus.enLayer = '1' then
        layer <= ipbus.layer;
    end if;

end if;
end process;


end;