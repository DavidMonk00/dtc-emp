library ieee, std;
use std.textio.all;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use work.emp_device_decl.all;
use work.emp_data_types.all;
use work.tools.all;
use work.config.all;
use work.dtc_stubs.all;


package dtc_config is

constant routeBlocks: natural := 2;
constant routeStubs: natural := routeBlocks * TMPtfp;
constant routeNodeInputs: natural := work.config.modulesPerDTC / routeBlocks;
constant numCICstubs: natural := 35;
constant widthCICstubs: natural := work.tools.width( numCICstubs );

constant iLinks: naturals( work.config.modulesPerDTC - 1 downto 0 ) := ( 56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,
                                                             74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,
                                                             55,54,53,52,51,50,49,48,47,46,45,44,43,42,41,40,39,38,
                                                             37,36,35,34,33,32,31,30,29,28,27,26,25,24,23,22,21,20  );
constant oLinks: naturals( numLinksDTC - 1 downto 0 ) := ( 001,000,003,002,005,004,007,006,009,008,011,010,013,012,015,014,017,016,019,018,
                                                           093,092,095,094,097,096,099,098,101,100,103,102,105,104,107,106 );

function iLinkMapping( l: ldata ) return ldata;
function oLinkMapping( l: ldata ) return ldata;

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


end;
