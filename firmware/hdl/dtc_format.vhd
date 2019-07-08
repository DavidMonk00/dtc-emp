library ieee;
use ieee.std_logic_1164.all;
use work.emp_data_types.all;
use work.config.all;
use work.dtc_stubs.all;

entity dtc_formatInput is
port (
    clk: in std_logic;
    formatInput_din: in ldata( modulesPerDTC - 1 downto 0 );
    formatInput_dout: out t_stubsFE( ModulesPerDTC - 1 downto 0 )
);
end;

architecture rtl of dtc_formatInput is

component dtc_formatInput_node
port (
    clk: in std_logic;
    node_din: in lword;
    node_dout: out t_stubFE
);
end component;

begin

g: for k in modulesPerDTC - 1 downto 0 generate

signal node_din: lword := ( ( others => '0' ), '0', '0', '1' );
signal node_dout: t_stubFE := nullStub;

begin

node_din <= formatInput_din( k );
formatInput_dout( k ) <= node_dout;

c: dtc_formatInput_node port map ( clk, node_din, node_dout );

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.emp_data_types.all;
use work.tools.all;
use work.config.all;
use work.dtc_stubs.all;
use work.dtc_config.all;

entity dtc_formatInput_node is
port (
    clk: in std_logic;
    node_din: in lword;
    node_dout: out t_stubFE
);
attribute ram_style: string;
end;

architecture rtl of dtc_formatInput_node is

constant widthRam: natural := widthBendCIC + widthColCIC + widthRow + widthBX;
type t_ram is array ( 2 ** widthCICstubs - 1 downto 0 ) of std_logic_vector( widthRam - 1 downto 0 );
signal ram: t_ram := ( others => ( others => '0' ) );
signal waddr, raddr: std_logic_vector( widthCICstubs - 1 downto 0 ) := ( others => '0' );

signal cicStubs: t_stubsCIC( numCIC - 1 downto 0 ) := ( others => nullStub );
signal stub, dout: t_stubFE := nullStub;
signal valid: std_logic := '0';
signal empty: std_logic := '1';

function lconv( s: t_stubCIC ) return std_logic_vector is
begin
    return  s.bx & s.row & s.col & s.bend;
end function;

function lconv( s: std_logic_vector ) return t_stubFE is
    variable stub: t_stubFE := nullStub;
    variable col, offset: std_logic_vector( widthColCIC - 1 downto 0 ) := stds( 2 ** width( widthColCIC ), widthColCIC );
begin
    stub.bx   := s( widthBX + widthRow + widthColCIC + widthBendCIC - 1 downto widthRow + widthColCIC + widthBendCIC );
    stub.row  := s(           widthRow + widthColCIC + widthBendCIC - 1 downto            widthColCIC + widthBendCIC );
         col  := s(                      widthColCIC + widthBendCIC - 1 downto                          widthBendCIC );
    stub.bend := s(                                    widthBendCIC - 1 downto                                     0 );
    stub.col  := col - offset;
    return stub;
end function;
function lconv( s: t_stubCIC ) return t_stubFE is begin return ( s.reset, s.valid, s.bx, s.row, s.col + stds( 2 ** width( widthColCIC ), widthColCIC ), s.bend ); end function;

begin

node_dout <= dout;

stub <= lconv( ram( uint( raddr ) ) );

process( clk ) is
begin
if rising_edge( clk ) then

    valid <= node_din.valid;
    cicStubs <= conv( node_din );

    dout <= nullStub;
    if cicStubs( 0 ).valid = '1' then
        dout <= lconv( cicStubs( 0 ) );
    elsif empty = '0' then
        dout <= stub;
        dout.valid <= '1';
        raddr <= incr( raddr );
        if incr( raddr ) = waddr then
            empty <= '1';
        end if;
    end if;
    ram( uint( waddr ) ) <= lconv( cicStubs( 1 ) );
    if node_din.valid = '1' and cicStubs( 1 ).valid = '1' then
        empty <= '0';
        waddr <= incr( waddr );
    end if;
    if valid = '0' and node_din.valid = '1' then
        dout <= nullStub;
        dout.reset <= '1';
        dout.bx( widthBX - 1 downto widthTMPfe ) <= node_din.data( widthBX + 1 - 1 downto widthTMPfe + 1 );
        empty <= '1';
        waddr <= ( others => '0' );
        raddr <= ( others => '0' );
    end if;

end if;
end process;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.emp_data_types.all;
use work.config.all;
use work.dtc_stubs.all;

entity dtc_formatOutput is
port (
    clk: in std_logic;
    formatOutput_din: in t_stubsDTC( numLinksDTC - 1 downto 0 );
    formatOutput_dout: out ldata( numLinksDTC - 1 downto 0 )
);
end;

architecture rtl of dtc_formatOutput is

component dtc_formatOutput_node
port (
    clk: in std_logic;
    node_din: in t_stubDTC;
    node_dout: out lword
);
end component;

begin

g: for k in numLinksDTC - 1 downto 0 generate

signal node_din: t_stubDTC := nullStub;
signal node_dout: lword := ( ( others => '0' ), '0', '0', '1' );

begin

node_din <= formatOutput_din( k );
formatOutput_dout( k ) <= node_dout;

c: dtc_formatOutput_node port map ( clk, node_din, node_dout );

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.emp_data_types.all;
use work.config.all;
use work.tools.all;
use work.dtc_stubs.all;
use work.dtc_config.all;

entity dtc_formatOutput_node is
port (
    clk: in std_logic;
    node_din: in t_stubDTC;
    node_dout: out lword
);
end;

architecture rtl of dtc_formatOutput_node is

signal din: t_stubDTC := nullStub;
signal dout: lword := ( ( others => '0' ), '0', '0', '1' );

signal reset: std_logic := '0';
signal counter: std_logic_vector( widthStubs - 1 downto 0 ) := ( others => '0' );


begin

node_dout <= dout;
din <= node_din;

process ( clk ) is
begin
if rising_edge( clk ) then

    if dout.valid = '1' then
        counter <= incr( counter );
        if uint( counter ) = numStubs - downTime - 1 then
            dout.valid <= '0';
        end if;
    end if;

    reset <= din.reset;
    dout.data <= ( others => '0' );
    if din.valid = '1' then
        dout.data <= conv( din );
    end if;
    if reset = '1' then
        dout.valid <= '1';
        counter <= ( others => '0' );
    end if;

end if;
end process;

end;