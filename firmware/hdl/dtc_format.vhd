library ieee;
use ieee.std_logic_1164.all;
use work.emp_data_types.all;
use work.config.all;
use work.dtc_stubs.all;

entity dtc_formatInput is
port (
    clk: in std_logic;
    formatInput_din: in ldata( modulesPerDTC - 1 downto 0 );
    formatInput_dout: out t_stubsCIC( CICsPerDTC - 1 downto 0 )
);
end;

architecture rtl of dtc_formatInput is

component dtc_formatInput_node
port (
    clk: in std_logic;
    node_din: in lword;
    node_dout: out t_stubsCIC( numCIC - 1 downto 0 )
);
end component;

begin

g: for k in modulesPerDTC - 1 downto 0 generate

signal node_din: lword := ( ( others => '0' ), '0', '0', '1' );
signal node_dout: t_stubsCIC( numCIC - 1 downto 0 ) := ( others => nullStub );

begin

node_din <= formatInput_din( k );
formatInput_dout( ( k + 1 ) * numCIC - 1 downto k * numCIC ) <= node_dout;

c: dtc_formatInput_node port map ( clk, node_din, node_dout );

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.emp_data_types.all;
use work.config.all;
use work.dtc_stubs.all;

entity dtc_formatInput_node is
port (
    clk: in std_logic;
    node_din: in lword;
    node_dout: out t_stubsCIC( numCIC - 1 downto 0 )
);
end;

architecture rtl of dtc_formatInput_node is

signal stub, dout, convStub: t_stubsCIC( numCIC - 1 downto 0 ) := ( others => nullStub );
signal valid: std_logic := '0';

begin

node_dout <= dout;
convStub <= conv( node_din );

process( clk ) is
begin
if rising_edge( clk ) then

    valid <= node_din.valid;
    stub <= convStub;

    dout <= ( others => nullStub );
    if valid = '1' then
        dout <= stub;
    elsif node_din.valid = '1' then
        for k in numCIC - 1 downto 0 loop
            dout( k ).reset <= '1';
            dout( k ).bx( widthBX - 1 downto widthTMPfe ) <= convStub( k ).bx( widthBX - 1 downto widthTMPfe );
        end loop;
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
attribute shreg_extract: string;
end;

architecture rtl of dtc_formatOutput_node is

signal sr: t_stubsDTC( 9 - 1 downto 0 ) := ( others => nullStub );
signal stub: t_stubDTC := nullStub;

signal reset: std_logic := '0';
signal counter: std_logic_vector( widthStubs - 1 downto 0 ) := ( others => '0' );
signal dout: lword := ( ( others => '0' ), '0', '0', '1' );

attribute shreg_extract of sr: signal is "no";

begin

node_dout <= dout;
stub <= sr( sr'high );

process ( clk ) is
begin
if rising_edge( clk ) then

    sr <= sr( sr'high - 1 downto 0 ) & node_din;

    if dout.valid = '1' then
        counter <= incr( counter );
        if uint( counter ) = numStubs - downTime - 1 then
            dout.valid <= '0';
        end if;
    end if;

    reset <= stub.reset;
    dout.data <= ( others => '0' );
    if stub.valid = '1' then
        dout.data <= conv( stub );
    end if;
    if reset = '1' then
        dout.valid <= '1';
        counter <= ( others => '0' );
    end if;

end if;
end process;

end;