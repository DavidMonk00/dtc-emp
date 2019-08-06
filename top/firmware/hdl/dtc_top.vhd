library ieee;
use ieee.std_logic_1164.all;
use work.emp_device_decl.all;
use work.emp_data_types.all;
use work.config.all;
use work.dtc_stubs.all;
use work.dtc_config.all;


entity dtc_top is
port (
    clk: in std_logic;
    dtc_din: in ldata( 4 * N_REGION - 1 downto 0 );
    dtc_dout: out ldata( 4 * N_REGION - 1 downto 0 )
);
end;


architecture rtl of dtc_top is


signal formatInput_din: ldata( modulesPerDTC - 1 downto 0 ) := ( others => ( ( others => '0' ), '0', '0', '1' ) );
signal formatInput_dout: t_stubsFE( ModulesPerDTC - 1 downto 0 ) := ( others => nullStub );
component dtc_formatInput
port (
    clk: in std_logic;
    formatInput_din: in ldata( modulesPerDTC - 1 downto 0 );
    formatInput_dout: out t_stubsFE( ModulesPerDTC - 1 downto 0 )
);
end component;


signal in_packet: std_logic_vector( ModulesPerDTC - 1 downto 0 ) := ( others => '0' );
signal in_din: t_stubsFE( ModulesPerDTC - 1 downto 0 ) := ( others => nullStub );
signal in_dout: ldata( ModulesPerDTC - 1 downto 0 ) := ( others => ( ( others => '0' ), '0', '0', '1' ) );
component interface_in
port (
    clk:in std_logic;
    in_packet: in std_logic_vector( ModulesPerDTC - 1 downto 0 );
    in_din: in t_stubsFE( ModulesPerDTC - 1 downto 0 );
    in_dout: out ldata( ModulesPerDTC - 1 downto 0 )
);
end component;

signal transform_din: ldata( ModulesPerDTC - 1 downto 0 ) := ( others => ( ( others => '0' ), '0', '0', '1' ) );
signal transform_dout: ldata( 2 * ModulesPerDTC - 1 downto 0 ) := ( others => ( ( others => '0' ), '0', '0', '1' ) );
component interface_transform
port (
    clk: in std_logic;
    transform_din: in ldata( ModulesPerDTC - 1 downto 0 );
    transform_dout: out ldata( 2 * ModulesPerDTC - 1 downto 0 )
);
end component;

signal out_din: ldata( 2 * ModulesPerDTC - 1 downto 0 ) := ( others => ( ( others => '0' ), '0', '0', '1' ) );
signal out_dout: t_stubsTransform( ModulesPerDTC - 1 downto 0 ) := ( others => nullStub );
component interface_out
port (
    clk:in std_logic;
    out_din: in ldata( 2 * ModulesPerDTC - 1 downto 0 );
    out_dout: out t_stubsTransform( ModulesPerDTC - 1 downto 0 )
);
end component;


signal route_din: t_stubsTransform( ModulesPerDTC - 1 downto 0 ) := ( others => nullStub );
signal route_dout: t_stubsRoute( routeStubs - 1 downto 0 ) := ( others => nullStub );
component dtc_route
port (
    clk: in std_logic;
    route_din: in t_stubsTransform( ModulesPerDTC - 1 downto 0 );
    route_dout: out t_stubsRoute( routeStubs - 1 downto 0 )
);
end component;


signal mux_din: t_stubsRoute( routeStubs - 1 downto 0 ) := ( others => nullStub );
signal mux_dout: t_stubsDTC( numLinksDTC - 1 downto 0 ) := ( others => nullStub );
component dtc_mux
port (
    clk: in std_logic;
    mux_din: in t_stubsRoute( routeStubs - 1 downto 0 );
    mux_dout: out t_stubsDTC( numLinksDTC - 1 downto 0 )
);
end component;


signal formatOutput_din: t_stubsDTC( numLinksDTC - 1 downto 0 ) := ( others => nullStub );
signal formatOutput_dout: ldata( numLinksDTC - 1 downto 0 ) := ( others => ( ( others => '0' ), '0', '0', '1' ) );
component dtc_formatOutput
port (
    clk: in std_logic;
    formatOutput_din: in t_stubsDTC( numLinksDTC - 1 downto 0 );
    formatOutput_dout: out ldata( numLinksDTC - 1 downto 0 )
);
end component;

function lconv( l: ldata ) return std_logic_vector is
    variable s: std_logic_vector( l'range ) := ( others => '0' );
begin
    for k in l'range loop
        s( k ) := l( k ).valid;
    end loop;
    return s;
end function;

begin

formatInput_din <= iLinkMapping( dtc_din );

in_packet <= lconv( formatInput_din );
in_din <= formatInput_dout;

transform_din <= in_dout;

out_din <= transform_dout;

route_din <= out_dout;

mux_din <= route_dout;

formatOutput_din <= mux_dout;

dtc_dout <= oLinkMapping( formatOutput_dout );


cI: dtc_formatInput port map ( clk, formatInput_din, formatInput_dout );

cMI: interface_in port map ( clk, in_packet, in_din, in_dout );

cT: interface_transform port map ( clk, transform_din, transform_dout );

cMO: interface_out port map ( clk, out_din, out_dout );

cR: dtc_route port map (  clk, route_din, route_dout );

cM: dtc_mux port map ( clk, mux_din, mux_dout );

cO: dtc_formatOutput port map ( clk, formatOutput_din, formatOutput_dout );

end;
