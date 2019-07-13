library ieee, std;
use std.textio.all;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use work.emp_device_decl.all;
use work.emp_data_types.all;
use work.tools.all;
use work.config.all;
use work.dtc_stubs.all;
use work.trackerGeometry.all;


package dtc_config is


--constant dtcId: integer := dtcId;
constant maxModId: natural := 49;

constant routeBlocks: natural := 2;
constant routeStubs: natural := routeBlocks * TMPtfp;
constant routeNodeInputs: natural := modulesPerDTC / routeBlocks;
constant numCICstubs: natural := 35;
constant widthCICstubs: natural := work.tools.width( numCICstubs );

constant iLinks: naturals( modulesPerDTC - 1 downto 0 ) := ( 56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,
                                                             74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,
                                                             55,54,53,52,51,50,49,48,47,46,45,44,43,42,41,40,39,38,
                                                             37,36,35,34,33,32,31,30,29,28,27,26,25,24,23,22,21,20  );
constant oLinks: naturals( numLinksDTC - 1 downto 0 ) := ( 001,000,003,002,005,004,007,006,009,008,011,010,013,012,015,014,017,016,019,018,
                                                           093,092,095,094,097,096,099,098,101,100,103,102,105,104,107,106 );

function iLinkMapping( l: ldata ) return ldata;
function oLinkMapping( l: ldata ) return ldata;

constant widthRowB: natural := 4;
constant widthRowC: natural := 4;

type t_ramA is array ( 0 to 2 **   widthCol                   - 1 ) of std_logic_vector( widthZ                                                 - 1 downto 0 );
type t_ramB is array ( 0 to 2 ** ( widthCol  + widthRowB    ) - 1 ) of std_logic_vector( widthR + widthPhiDTC + widthSectorEta + widthSectorEta - 1 downto 0 );
type t_ramC is array ( 0 to 2 ** ( widthRowC + widthBendCIC ) - 1 ) of std_logic_vector( widthMBin + widthMBin + numOverlap                     - 1 downto 0 );

function init_ramA( id: natural ) return t_ramA;
function init_ramB( id: natural ) return t_ramB;
function init_ramC( id: natural ) return t_ramC;

type t_layers is array ( 0 to modulesPerDTC - 1 ) of std_logic_vector( widthLayer - 1 downto 0 );
function init_layers return t_layers;
constant layers: t_layers;

function to_sector( cot: real ) return std_logic_vector;

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

function init_ramA( id: natural ) return t_ramA is
    variable ram: t_ramA := ( others => ( others => '0' ) );
    variable scol: integer;
    variable y, z: real;
    variable m: t_module := modules( id );
begin
    if m.valid then
        for ucol in 0 to 2 ** widthCol - 1 loop
            scol := ucol - 2 ** widthCol;
            if ucol < 2 ** ( widthCol - 1 ) then
                scol := ucol;
            end if;
            y := ( real( scol ) + 0.5 ) * baseCol * m.pitchCol ;
            z := m.z + y * m.cos;
            ram( ucol ) := stds( z / baseZ, widthZ );
        end loop;
    end if;
    return ram;
end function;

function to_sector( cot: real ) return std_logic_vector is
    variable s: std_logic_vector( widthSectorEta - 1 downto 0 );
    variable i: integer := confine( integer( floor( cot / baseCotTile ) ), numCotTiles / 2 ) + numCotTiles / 2;
begin
    return stdu( tileToEta( i ), widthSectorEta );
end function;

function init_ramB( id: natural ) return t_ramB is
    variable ram: t_ramB := ( others => ( others => '0' ) );
    variable scol, srow: integer;
    variable y, z, d, x, r, rT, phi, cot, cotRes, cotMin, cotMax: real;
    variable m: t_module := modules( id );
begin
    if m.valid then
        for ucol in 0 to 2 ** widthCol - 1 loop
            scol := uCol - 2 ** widthCol;
            if ucol < 2 ** ( widthCol - 1 ) then
                scol := ucol;
            end if;
            y := ( real( scol ) + 0.5 ) * baseCol * m.pitchCol;
            z := m.z + y * m.cos;
            d := m.r + y * m.sin;
            for urow in 0 to 2 ** widthRowB - 1 loop
                srow := urow - 2 ** widthRowB;
                if urow < 2 ** ( widthRowB - 1 ) then
                    srow := urow;
                end if;
                x := ( real( srow ) + 0.5 ) * 2.0 ** ( widthRow - widthRowB ) * baseRow * m.pitchRow;
                r := sqrt( d ** 2 + x ** 2 );
                rT:= r - chosenRofPhi;
                phi := m.phi + arctan( x, d );
                cot := z / r;
                cotRes := beamWindowZ / chosenRofZ * abs( 1.0 - chosenRofZ / r );
                cotMin := cot - cotRes;
                cotMax := cot + cotRes;
                ram( ucol * 2 ** widthRowB + urow ) := stds( rT / baseR, widthR ) &  stds( phi / basePhi, widthPhiDTC ) &  to_sector( cotMin ) &  to_sector( cotMax );
                assert ucol * 2 ** widthRowB + urow /= 312 report real'image( y ) & " " & real'image( d ) & " " & real'image( x ) & " " & real'image( phi ) & " " & real'image( m.r ) & " " & real'image( m.sin ) & " " & real'image( phi / basePhi ) & " " & real'image( floor( phi / basePhi ) ) & " " & integer'image( integer( floor( phi / basePhi ) ) ) & " " & real'image( basePhi );
            end loop;
        end loop;
    end if;
    return ram;
end function;

function init_ramC( id: natural ) return t_ramC is
    variable ram: t_ramC := ( others => ( others => '0' ) );
    variable srow, sbend, mMin, mMax: integer;
    variable x, r, phi, dr, MoB, ptMin, ptMax, rT, phiTMin, phiTMax: real;
    variable m: t_module := modules( id );
    variable nonant: std_logic_vector( numOverlap - 1 downto 0 ) := ( others => '0' );
begin
    if m.valid then
        for urow in 0 to 2 ** widthRowC - 1 loop
            srow := urow - 2 ** widthRowC;
            if urow < 2 ** ( widthRowC - 1 ) then
                srow := urow;
            end if;
            x := ( real( srow ) + 0.5 ) * baseRow * m.pitchRow * 2.0 ** ( widthRow - widthRowC );
            r := sqrt( m.r ** 2 + x ** 2 );
            phi := m.phi + arctan( x, m.r );
            rT := r - chosenRofPhi;
            for ubend in 0 to 2 ** widthBendCIC - 1 loop
                sbend := ubend - 2 ** widthBendCIC;
                if ubend < 2 ** ( widthBendCIC - 1 ) then
                    sbend := ubend;
                end if;
                dr := m.sep / ( m.cos - m.sin * m.z / r );
                MoB := m.pitchRow / r / dr;
                ptMin := confine( ( real( sBend ) * baseBend - bendRes ) * MoB, invPtToDphi / houghMinPt );
                ptMax := confine( ( real( sBend ) * baseBend + bendRes ) * MoB, invPtToDphi / houghMinPt );
                phiTMin := phi + rT * ptMin;
                phiTMax := phi + rT * ptMax;
                nonant := ( others => '0' );
                if phiTMax >= 0.0 or phiTMin >= 0.0 then
                    nonant( 0 ) := '1';
                end if;
                if phiTMin < 0.0 or phiTMax < 0.0 then
                    nonant( 1 ) := '1';
                end if;
                mMin := confine( integer( floor( ptMin / baseM ) ), numMBins / 2 );
                mMax := confine( integer( floor( ptMax / baseM ) ), numMBins / 2 );
                ram( urow * 2 ** widthBendCIC + ubend ) := stds( mMin, widthMBin ) & stds( mMax, widthMBin ) & nonant;
            end loop;
        end loop;
    end if;
    return ram;
end function;

function init_layers return t_layers is
    variable l: t_layers;
begin
    for k in t_layers'range loop
        l( k ) := stdu( modules( k ).layer, widthLayer );
    end loop;
    return l;
end function;

constant layers: t_layers := init_layers;


end;
