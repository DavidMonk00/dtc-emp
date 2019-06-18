library ieee, std;
use std.textio.all;
use ieee.std_logic_1164.all;
use work.emp_device_decl.all;
use work.emp_data_types.all;
use work.tools.all;
use work.config.all;
use work.dtc_stubs.all;


package dtc_config is


--constant dtcId: integer := dtcId;
constant maxModId: natural := 49;

constant latency: natural := 87;

constant routeBlocks: natural := 4;
constant routeStubs: natural := routeBlocks * TMPtfp;
constant routeNodeInputs: natural := CICsPerDTC / routeBlocks;
constant numCICstubs: natural := 35;
constant widthCICstubs: natural := width( numCICstubs );

constant iLinks: naturals( modulesPerDTC - 1 downto 0 ) := ( 74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,
                                                             56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,
                                                             55,54,53,52,51,50,49,48,47,46,45,44,43,42,41,40,39,38,
                                                             37,36,35,34,33,32,31,30,29,28,27,26,25,24,23,22,21,20  );
constant oLinks: naturals( numLinksDTC - 1 downto 0 ) := ( 094,095,096,097,098,099,100,101,102,103,104,105,106,107,108,109,110,111,
                                                           017,016,015,014,013,012,011,010,009,008,007,006,005,004,003,002,001,000 );

function iLinkMapping( l: ldata ) return ldata;
function oLinkMapping( l: ldata ) return ldata;

constant widthRowB: natural := 5;
constant widthRowC: natural := 4;

type t_ramA is array ( 0 to 2 **   widthCol                   - 1 ) of std_logic_vector( widthZ                                                 - 1 downto 0 );
type t_ramB is array ( 0 to 2 ** ( widthCol  + widthRowB    ) - 1 ) of std_logic_vector( widthR + widthPhiDTC + widthSectorEta + widthSectorEta - 1 downto 0 );
type t_ramC is array ( 0 to 2 ** ( widthRowC + widthBendCIC ) - 1 ) of std_logic_vector( widthMBin + widthMBin + numOverlap                     - 1 downto 0 );

function init_A( modId, cicId: natural ) return t_ramA;
function init_B( modId, cicId: natural ) return t_ramB;
function init_C( modId, cicId: natural ) return t_ramC;

impure function init_ramA( modId, cicId: natural ) return t_ramA;
impure function init_ramB( modId, cicId: natural ) return t_ramB;
impure function init_ramC( modId, cicId: natural ) return t_ramC;

type t_layers is array ( 0 to modulesPerDTC - 1 ) of std_logic_vector( widthLayer - 1 downto 0 );
impure function init_layers return t_layers;
constant layers: t_layers;

end;



package body dtc_config is


function iLinkMapping( l: ldata ) return ldata is
    variable r: ldata( iLinks'range );
begin
    for k in iLinks'range loop
        r( k ) := l( iLinks( k ) );
    end loop;
    return r;
end function;

function oLinkMapping( l: ldata ) return ldata is
    variable r: ldata( 4 * N_REGION - 1 downto 0 ) := ( others => ( ( others => '0' ), '0', '0', '1' ) );
begin
    for k in oLinks'range loop
        r( oLinks( k ) ) := l( k );
    end loop;
    return r;
end function;

function init_A( modId, cicId: natural ) return t_ramA is begin if modId > maxModId then return ( others => ( others => '0' ) ); end if; return init_ramA( modId, cicId ); end function;
function init_B( modId, cicId: natural ) return t_ramB is begin if modId > maxModId then return ( others => ( others => '0' ) ); end if; return init_ramB( modId, cicId ); end function;
function init_C( modId, cicId: natural ) return t_ramC is begin if modId > maxModId then return ( others => ( others => '0' ) ); end if; return init_ramC( modId, cicId ); end function;

impure function init_ramA( modId, cicId: natural ) return t_ramA is
    file f: text open read_mode is "/scratch/tschuh/work/src/dtc/firmware/cfg/luts/dtc_" & natural'image( dtcId ) & "/mod_" & natural'image( modId ) & "/a_" & natural'image( cicId ) & ".txt";
    variable l: line;
    variable w: bit_vector( widthZ - 1 downto 0 );
    variable ram: t_ramA := ( others => ( others => '0' ) );
begin
    for k in t_ramA'range loop
        readline( f, l );
        read( l, w );
        ram( k ) := To_StdLogicVector( w );
    end loop;
    return ram;
end function;

impure function init_ramB( modId, cicId: natural ) return t_ramB is
    file f: text open read_mode is "/scratch/tschuh/work/src/dtc/firmware/cfg/luts/dtc_" & natural'image( dtcId ) & "/mod_" & natural'image( modId ) & "/b_" & natural'image( cicId ) & ".txt";
    variable l: line;
    variable w: bit_vector( widthR + widthPhiDTC + widthSectorEta + widthSectorEta - 1 downto 0 );
    variable ram: t_ramB := ( others => ( others => '0' ) );
begin
    for k in t_ramB'range loop
        readline( f, l );
        read( l, w );
        ram( k ) := To_StdLogicVector( w );
    end loop;
    return ram;
end function;

impure function init_ramC( modId, cicId: natural ) return t_ramC is
    file f: text open read_mode is "/scratch/tschuh/work/src/dtc/firmware/cfg/luts/dtc_" & natural'image( dtcId ) & "/mod_" & natural'image( modId ) & "/c_" & natural'image( cicId ) & ".txt";
    variable l: line;
    variable w: bit_vector( widthMBin + widthMBin + numOverlap - 1 downto 0 );
    variable ram: t_ramC := ( others => ( others => '0' ) );
begin
    for k in t_ramC'range loop
        readline( f, l );
        read( l, w );
        ram( k ) := To_StdLogicVector( w );
    end loop;
    return ram;
end function;

impure function init_layers return t_layers is
    file f: text open read_mode is "/scratch/tschuh/work/src/dtc/firmware/cfg/luts/dtc_" & natural'image( dtcId ) & "/layers.txt";
    variable l: line;
    variable w: bit_vector( widthLayer - 1 downto 0 );
    variable layers: t_layers := ( others => ( others => '0' ) );
begin
    for k in t_layers'range loop
        readline( f, l );
        read( l, w );
        layers( k ) := To_StdLogicVector( w );
    end loop;
    return layers;
end function;

constant layers: t_layers := init_layers;

end;