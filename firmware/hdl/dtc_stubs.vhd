library ieee;
use ieee.std_logic_1164.all;
use work.config.all;
use work.tools.all;
use work.emp_data_types.all;


package dtc_stubs is

constant widthStubCIC: natural := widthBendCIC + widthColCIC + widthRow + widthBX + 1;
constant gap         : natural := LWORD_WIDTH / numCIC - widthStubCIC;

type t_stubCIC is
record
    reset: std_logic;
    valid: std_logic;
    bx:    std_logic_vector( widthBX      - 1 downto 0 );
    row:   std_logic_vector( widthRow     - 1 downto 0 );
    col:   std_logic_vector( widthColCIC  - 1 downto 0 );
    bend:  std_logic_vector( widthBendCIC - 1 downto 0 );
end record;
type t_stubsCIC is array ( natural range <> ) of t_stubCIC;
function nullStub return t_stubCIC;
function conv( l: lword ) return t_stubsCIC;

type t_stubFE is
record
    reset: std_logic;
    valid: std_logic;
    bx:    std_logic_vector( widthBX   - 1 downto 0 );
    row:   std_logic_vector( widthRow  - 1 downto 0 );
    col:   std_logic_vector( widthCol  - 1 downto 0 );
    bend:  std_logic_vector( widthBend - 1 downto 0 );
end record;
type t_stubsFE is array ( natural range <> ) of t_stubFE;
function nullStub return t_stubFE;

type t_stubTransform is
record
    reset:  std_logic;
    valid:  std_logic;
    bx:     std_logic_vector( widthBX        - 1 downto 0 );
    nonant: std_logic_vector( numOverlap     - 1 downto 0 );
    r:      std_logic_vector( widthR         - 1 downto 0 );
    phi:    std_logic_vector( widthPhiDTC    - 1 downto 0 );
    z:      std_logic_vector( widthZ         - 1 downto 0 );
    mMin:   std_logic_vector( widthMBin      - 1 downto 0 );
    mMax:   std_logic_vector( widthMBin      - 1 downto 0 );
    etaMin: std_logic_vector( widthSectorEta - 1 downto 0 );
    etaMax: std_logic_vector( widthSectorEta - 1 downto 0 );
    layer:  std_logic_vector( widthLayer     - 1 downto 0 );
end record;
type t_stubsTransform is array ( natural range <> ) of t_stubTransform;
function nullStub return t_stubTransform;
function conv( t: t_stubTransform ) return std_logic_vector;


type t_stubRoute is
record
    reset:  std_logic;
    valid:  std_logic;
    bx:     std_logic_vector( widthBX        - 1 downto 0 );
    nonant: std_logic_vector( numOverlap     - 1 downto 0 );
    r:      std_logic_vector( widthR         - 1 downto 0 );
    phi:    std_logic_vector( widthPhiDTC    - 1 downto 0 );
    z:      std_logic_vector( widthZ         - 1 downto 0 );
    mMin:   std_logic_vector( widthMBin      - 1 downto 0 );
    mMax:   std_logic_vector( widthMBin      - 1 downto 0 );
    etaMin: std_logic_vector( widthSectorEta - 1 downto 0 );
    etaMax: std_logic_vector( widthSectorEta - 1 downto 0 );
    layer:  std_logic_vector( widthLayer     - 1 downto 0 );
end record;
type t_stubsRoute is array ( natural range <> ) of t_stubRoute;
function nullStub return t_stubRoute;
function conv( s: std_logic_vector ) return t_stubRoute;

constant widthStub: natural := 1 + widthR + widthPhiDTC + widthZ + widthMBin + widthMBin + widthSectorEta + widthSectorEta + widthLayer;
type t_stubDTC is
record
    reset:  std_logic;
    valid:  std_logic;
    r:      std_logic_vector( widthR         - 1 downto 0 );
    phi:    std_logic_vector( widthPhiDTC    - 1 downto 0 );
    z:      std_logic_vector( widthZ         - 1 downto 0 );
    mMin:   std_logic_vector( widthMBin      - 1 downto 0 );
    mMax:   std_logic_vector( widthMBin      - 1 downto 0 );
    etaMin: std_logic_vector( widthSectorEta - 1 downto 0 );
    etaMax: std_logic_vector( widthSectorEta - 1 downto 0 );
    layer:  std_logic_vector( widthLayer     - 1 downto 0 );
end record;
type t_stubsDTC is array ( natural range <> ) of t_stubDTC;
function nullStub return t_stubDTC;
function conv( s: t_stubDTC ) return std_logic_vector;


end;


package body dtc_stubs is


function nullStub return t_stubCIC       is begin return ( '0', '0', others => ( others => '0' ) ); end function;
function nullStub return t_stubFE        is begin return ( '0', '0', others => ( others => '0' ) ); end function;
function nullStub return t_stubTransform is begin return ( '0', '0', others => ( others => '0' ) ); end function;
function nullStub return t_stubRoute     is begin return ( '0', '0', others => ( others => '0' ) ); end function;
function nullStub return t_stubDTC       is begin return ( '0', '0', others => ( others => '0' ) ); end function;

function conv( l: lword ) return t_stubsCIC is
    variable r: t_stubsCIC( numCIC - 1 downto 0 ) := ( others => nullStub );
begin
    for k in numCIC - 1 downto 0 loop
        r( k ).bend  := l.data( widthBend + widthColCIC + widthRow + widthBX + 1 + k * LWORD_WIDTH / numCIC - 1 downto widthColCIC + widthRow + widthBX + 1 + k * LWORD_WIDTH / numCIC );
        r( k ).col   := l.data(             widthColCIC + widthRow + widthBX + 1 + k * LWORD_WIDTH / numCIC - 1 downto               widthRow + widthBX + 1 + k * LWORD_WIDTH / numCIC );
        r( k ).row   := l.data(                           widthRow + widthBX + 1 + k * LWORD_WIDTH / numCIC - 1 downto                          widthBX + 1 + k * LWORD_WIDTH / numCIC );
        r( k ).bx    := l.data(                                      widthBX + 1 + k * LWORD_WIDTH / numCIC - 1 downto                                    1 + k * LWORD_WIDTH / numCIC );
        r( k ).valid := l.data(                                                1 + k * LWORD_WIDTH / numCIC - 1 );   
    end loop;
    return r;
end function;

function conv( t: t_stubTransform ) return std_logic_vector is
    variable s: std_logic_vector( numOverlap + widthR + widthPhiDTC + widthZ + widthMBin + widthMBin + widthSectorEta + widthSectorEta + widthLayer - 1 downto 0 ) := ( others => '0' );
begin
    s := t.nonant & t.r & t.phi & t.z & t.mMin & t.mMax & t.etaMin & t.etaMax & t.layer;
    return s;
end function;

function conv( s: std_logic_vector ) return t_stubRoute is
    variable r: t_stubRoute := nullStub;
begin
    r.nonant := s( numOverlap + widthR + widthPhiDTC + widthZ + widthMBin + widthMBin + widthSectorEta + widthSectorEta + widthLayer - 1 downto widthR + widthPhiDTC + widthZ + widthMBin + widthMBin + widthSectorEta + widthSectorEta + widthLayer );
    r.r      := s(              widthR + widthPhiDTC + widthZ + widthMBin + widthMBin + widthSectorEta + widthSectorEta + widthLayer - 1 downto          widthPhiDTC + widthZ + widthMBin + widthMBin + widthSectorEta + widthSectorEta + widthLayer );
    r.phi    := s(                       widthPhiDTC + widthZ + widthMBin + widthMBin + widthSectorEta + widthSectorEta + widthLayer - 1 downto                        widthZ + widthMBin + widthMBin + widthSectorEta + widthSectorEta + widthLayer );
    r.z      := s(                                     widthZ + widthMBin + widthMBin + widthSectorEta + widthSectorEta + widthLayer - 1 downto                                 widthMBin + widthMBin + widthSectorEta + widthSectorEta + widthLayer );
    r.mMin   := s(                                              widthMBin + widthMBin + widthSectorEta + widthSectorEta + widthLayer - 1 downto                                             widthMBin + widthSectorEta + widthSectorEta + widthLayer );
    r.mMax   := s(                                                          widthMBin + widthSectorEta + widthSectorEta + widthLayer - 1 downto                                                         widthSectorEta + widthSectorEta + widthLayer );
    r.etaMin := s(                                                                      widthSectorEta + widthSectorEta + widthLayer - 1 downto                                                                          widthSectorEta + widthLayer );
    r.etaMax := s(                                                                                       widthSectorEta + widthLayer - 1 downto                                                                                           widthLayer );
    r.layer  := s(                                                                                                        widthLayer - 1 downto                                                                                                    0 );
    return r;
end function;

function conv( s: t_stubDTC ) return std_logic_vector is
    variable r: std_logic_vector( LWORD_WIDTH - 1 downto 0 ) := ( others => '0' );
begin
    r( widthStub - 1 downto 0 ) := s.valid & s.r & s.phi & s.z & s.mMin & s.mMax & s.etaMin & s.etaMax & s.layer;
    return r;
end function;

end package body;