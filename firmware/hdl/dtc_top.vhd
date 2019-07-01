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


signal transform_ipbus: t_ipbuss( ModulesPerDTC - 1 downto 0 ) := ( others => nullBus );
signal transform_din: t_stubsFE( ModulesPerDTC - 1 downto 0 ) := ( others => nullStub );
signal transform_dout: t_stubsTransform( ModulesPerDTC - 1 downto 0 ) := ( others => nullStub );
component dtc_transform
port (
    clk: in std_logic;
    transform_ipbus: in t_ipbuss( ModulesPerDTC - 1 downto 0 );
    transform_din: in t_stubsFE( ModulesPerDTC - 1 downto 0 );
    transform_dout: out t_stubsTransform( ModulesPerDTC - 1 downto 0 )
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


begin

formatInput_din <= iLinkMapping( dtc_din );

transform_din <= formatInput_dout;

route_din <= transform_dout;

mux_din <= route_dout;

formatOutput_din <= mux_dout;

dtc_dout <= oLinkMapping( formatOutput_dout );


cI: dtc_formatInput port map ( clk, formatInput_din, formatInput_dout );

cT: dtc_transform port map ( clk, transform_ipbus, transform_din, transform_dout );

cR: dtc_route port map (  clk, route_din, route_dout );

cM: dtc_mux port map ( clk, mux_din, mux_dout );

cO: dtc_formatOutput port map ( clk, formatOutput_din, formatOutput_dout );

end;
