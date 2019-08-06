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

constant widthRamPos: natural := widthZ + widthR + widthPhiM + widthPhiDTC + widthSectorEta + widthSectorEta;
type t_wordPos is
record
    z:      std_logic_vector( widthZ         - 1 downto 0 );
    r:      std_logic_vector( widthR         - 1 downto 0 );
    phiM:   std_logic_vector( widthPhiM      - 1 downto 0 );
    phiC:   std_logic_vector( widthPhiDTC    - 1 downto 0 );
    etaMin: std_logic_vector( widthSectorEta - 1 downto 0 );
    etaMax: std_logic_vector( widthSectorEta - 1 downto 0 );
end record;
type t_ramPos is array ( 0 to 2 ** ( widthCol + widthRowLUT ) - 1 ) of std_logic_vector( widthRamPos - 1 downto 0 );
function init_ramPos ( id: natural ) return t_ramPos;
function conv_pos( w: t_wordPos ) return std_logic_vector;
function conv_pos( s: std_logic_vector ) return t_wordPos;


constant widthRamBend: natural := widthMDTC + widthMDTC;
type t_wordBend is
record
    mMin: std_logic_vector( widthMDTC - 1 downto 0 );
    mMax: std_logic_vector( widthMDTC - 1 downto 0 );
end record;
type t_ramBend is array ( 0 to 2 ** ( widthCol + widthBend ) - 1 ) of std_logic_vector( widthRamBend - 1 downto 0 );
function init_ramBend( id: natural ) return t_ramBend;
function conv_bend( w: t_wordBend ) return std_logic_vector;
function conv_bend( s: std_logic_vector ) return t_wordBend;

constant widthDSPphi: natural := max( ( max( baseDiffPhiM + 2, baseDiffPhiM + 2 ) + 1 ) + 1 + widthPhiM + 1 + 1, widthPhiDTC + baseDiffPhiM + 2 ) + 1;
type t_dspPhi is
record
    x: std_logic_vector( baseDiffPhiM + 2  - 1 downto 0 );
    d: std_logic_vector( baseDiffPhiM + 2  - 1 downto 0 );
    m: std_logic_vector( 1 + widthPhiM + 1 - 1 downto 0 );
    c: std_logic_vector( widthDSPphi - 1   - 1 downto 0 );
    y: std_logic_vector( widthDSPphi       - 1 downto 0 );
end record;

constant baseDiffPhiDTC: integer := baseDiffR + baseDiffMDTC - baseDiffPhi;
constant widthDSPphiT: natural := max( widthR + widthMDTC + 2, widthPhiDTC + baseDiffPhiDTC + 2 ) + 1;
type t_dspPhiT is
record
    x0: std_logic_vector( widthR + 1                       - 1 downto 0 );
    x1: std_logic_vector( widthR + 1                       - 1 downto 0 );
    m0: std_logic_vector( widthMDTC + 1                    - 1 downto 0 );
    m1: std_logic_vector( widthMDTC + 1                    - 1 downto 0 );
    xm: std_logic_vector( widthR + widthMDTC + 2           - 1 downto 0 );
    c:  std_logic_vector( widthPhiDTC + baseDiffPhiDTC + 2 - 1 downto 0 );
    y:  std_logic_vector( widthDSPphiT                     - 1 downto 0 );
end record;

type t_srWord is
record
    z:      std_logic_vector( widthZ         - 1 downto 0 );
    r:      std_logic_vector( widthR         - 1 downto 0 );
    etaMin: std_logic_vector( widthSectorEta - 1 downto 0 );
    etaMax: std_logic_vector( widthSectorEta - 1 downto 0 );
    mMin:   std_logic_vector( widthMBin      - 1 downto 0 );
    mMax:   std_logic_vector( widthMBin      - 1 downto 0 );
end record;
function conv( p: t_wordPos; b: t_wordBend ) return t_srWord;

type t_bxs  is array ( natural range <> ) of std_logic_vector( widthBX      - 1 downto 0 );
type t_rows is array ( natural range <> ) of std_logic_vector( baseDiffPhiM - 1 downto 0 );
type t_phis is array ( natural range <> ) of std_logic_vector( widthPhiDTC  - 1 downto 0 );
type t_sr   is array ( natural range <> ) of t_srWord;

type t_layers is array ( 0 to work.config.modulesPerDTC - 1 ) of std_logic_vector( work.config.widthLayer - 1 downto 0 );
function init_layers return t_layers;
constant layers: t_layers;

function to_sector( cot: real ) return std_logic_vector;

function to_nonant( min, max: std_logic_vector ) return std_logic_vector;

type t_ipbus is
record
    enPos:    std_logic;
    enBend:   std_logic;
    enLayer:  std_logic;
    addrPos:  std_logic_vector( widthCol + widthRowLUT - 1 downto 0 );
    addrBend: std_logic_vector( widthCol + widthBend   - 1 downto 0 );
    wordPos:  std_logic_vector( widthRamPos            - 1 downto 0 );
    wordBend: std_logic_vector( widthRamBend           - 1 downto 0 );
    layer:    std_logic_vector( work.config.widthLayer - 1 downto 0 );
end record;
type t_ipbuss is array ( natural range <> ) of t_ipbus;
function nullBus return t_ipbus;

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

function conv_pos( w: t_wordPos ) return std_logic_vector is
begin
    return w.z & w.r & w.phiM & w.phiC & w.etaMin & w.etaMax;
end function;

function conv_pos( s: std_logic_vector ) return t_wordPos is
    variable w: t_wordPos;
begin
    w.z      := s( widthZ + widthR + widthPhiM + widthPhiDTC + widthSectorEta + widthSectorEta - 1 downto widthR + widthPhiM + widthPhiDTC + widthSectorEta + widthSectorEta );
    w.r      := s(          widthR + widthPhiM + widthPhiDTC + widthSectorEta + widthSectorEta - 1 downto          widthPhiM + widthPhiDTC + widthSectorEta + widthSectorEta );
    w.phiM   := s(                   widthPhiM + widthPhiDTC + widthSectorEta + widthSectorEta - 1 downto                      widthPhiDTC + widthSectorEta + widthSectorEta );
    w.phiC   := s(                               widthPhiDTC + widthSectorEta + widthSectorEta - 1 downto                                    widthSectorEta + widthSectorEta );
    w.etaMin := s(                                             widthSectorEta + widthSectorEta - 1 downto                                                     widthSectorEta );
    w.etaMax := s(                                                              widthSectorEta - 1 downto                                                                  0 );
    return w;
end function;

function conv_bend( w: t_wordBend ) return std_logic_vector is
begin
    return w.mMin & w.mMax;
end function;

function conv( p: t_wordPos; b: t_wordBend ) return t_srWord is
begin
    return ( p.z, p.r, p.etaMin, p.etaMax, b.mMin( widthMDTC - 1 downto baseDiffMDTC ), b.mMax( widthMDTC - 1 downto baseDiffMDTC ) );
end function;

function conv_bend( s: std_logic_vector ) return t_wordBend is
    variable r: t_wordBend;
begin
    r.mMin := s( widthMDTC + widthMDTC - 1 downto widthMDTC );
    r.mMax := s(             widthMDTC - 1 downto         0 );
    return r;
end function;

function to_sector( cot: real ) return std_logic_vector is
    variable s: std_logic_vector( widthSectorEta - 1 downto 0 );
    variable i: integer := confine( integer( floor( cot / baseCotTile ) ), numCotTiles / 2 ) + numCotTiles / 2;
begin
    return stdu( tileToEta( i ), widthSectorEta );
end function;

function init_ramPos( id: natural ) return t_ramPos is
    variable ram: t_ramPos := ( others => ( others => '0' ) );
    variable scol, srow: integer;
    variable y, z, d, x, x0, x1, r, rT, phi0, phi1, phiC, phiM, cot, cotRes, cotMin, cotMax: real;
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
            for urow in 0 to 2 ** widthRowLUT - 1 loop
                srow := urow - 2 ** widthRowLUT;
                if urow < 2 ** ( widthRowLUT - 1 ) then
                    srow := urow;
                end if;
                x0 := real( srow ) * 2.0 ** baseDiffPhiM * baseRow * m.pitchRow;
                x1 := ( real( srow ) + 1.0 ) * 2.0 ** baseDiffPhiM * baseRow * m.pitchRow;
                phi0 := m.phi + arctan( x0, d );
                phi1 := m.phi + arctan( x1, d );
                phiC := ( phi0 + phi1 ) / 2.0;
                phiM := ( phi1 - phi0 ) * 2.0 ** ( -baseDiffPhiM );
                x := ( real( srow ) + 0.5 ) * 2.0 ** baseDiffPhiM * baseRow * m.pitchRow;
                r := sqrt( d ** 2 + x ** 2 );
                rT:= r - critR;
                cot := z / r;
                cotRes := beamWindowZ / critR * abs( 1.0 - critR / r );
                cotMin := cot - cotRes;
                cotMax := cot + cotRes;
                ram( ucol * 2 ** widthRowLUT + urow ) := stds( z / baseZ, widthZ ) & stds( rT / baseR, widthR ) &  stds( phiM / basePhiM, widthPhiM ) & stds( phiC / basePhi, widthPhiDTC ) & to_sector( cotMin ) & to_sector( cotMax );
            end loop;
        end loop;
    end if;
    return ram;
end function;

function init_ramBend( id: natural ) return t_ramBend is
    variable ram: t_ramBend := ( others => ( others => '0' ) );
    variable scol, sbend, min, max: integer;
    variable y, z, d, b, dr, MoB, m, mRes, mMin, mMax: real;
    variable module: t_module := modules( id );
begin
    if module.valid then
        for ucol in 0 to 2 ** widthCol - 1 loop
            scol := uCol - 2 ** widthCol;
            if ucol < 2 ** ( widthCol - 1 ) then
                scol := ucol;
            end if;
            y := ( real( scol ) + 0.5 ) * baseCol * module.pitchCol;
            z := module.z + y * module.cos;
            d := module.r + y * module.sin;
            for ubend in 0 to 2 ** widthBend - 1 loop
                sbend := ubend - 2 ** widthBend;
                if ubend < 2 ** ( widthBend - 1 ) then
                    sbend := ubend;
                end if;
                b := real( sbend ) * baseBend;
                dr := module.sep / ( module.cos - module.sin * z / d );
                mob := module.pitchRow / dr / d;
                m := b * MoB;
                mRes := bendRes * MoB;
                mMin := m - mRes;
                mMax := m + mRes;
                min := confine( integer( floor( ( m - mRes ) / baseMDTC ) ), numMBins * 2 ** ( baseDiffMDTC - 1 ) );
                max := confine( integer( floor( ( m + mRes ) / baseMDTC ) ), numMBins * 2 ** ( baseDiffMDTC - 1 ) );
                ram( ucol * 2 ** widthBend + ubend ) := stds( min, widthMDTC ) & stds( max, widthMDTC );
            end loop;
        end loop;
    end if;
    return ram;
end function;

function init_layers return t_layers is
    variable l: t_layers;
begin
    for k in t_layers'range loop
        l( k ) := stdu( modules( k ).layer, work.config.widthLayer );
    end loop;
    return l;
end function;

constant layers: t_layers := init_layers;

function to_nonant( min, max: std_logic_vector ) return std_logic_vector is
    variable nonant: std_logic_vector( numOverlap - 1 downto 0 ) := ( others => '0' );
begin
    if msb( min ) = '1' or msb( max ) = '1' then
        nonant( 1 ) := '1';
    end if;
    if msb( min ) = '0' or msb( max ) = '0' then
        nonant( 0 ) := '1';
    end if;
    return nonant;
end function;

function nullBus return t_ipbus is begin return ( '0', '0', '0', others => ( others => '0' ) ); end function;


end;
