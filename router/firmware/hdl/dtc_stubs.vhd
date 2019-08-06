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

constant widthHybridStub: natural := 1 + 1 + widthHybridLayer + widthHybridBend + widthHybridAlpha + widthHybridPhi + widthHybridZ + widthHybridR;
constant widthTransformStub: natural := 1 + 1 + widthBX + numOverlap + widthHybridLayer + widthHybridBend + widthHybridAlpha + widthHybridPhi + widthHybridZ + widthHybridR;
type t_stubTransform is
record
    reset:  std_logic;
    valid:  std_logic;
    ps:     std_logic;
    barrel: std_logic;
    bx:     std_logic_vector( widthBX          - 1 downto 0 );
    nonant: std_logic_vector( numOverlap       - 1 downto 0 );
    r:      std_logic_vector( widthHybridR     - 1 downto 0 );
    phi:    std_logic_vector( widthHybridPhi   - 1 downto 0 );
    z:      std_logic_vector( widthHybridZ     - 1 downto 0 );
    alpha:  std_logic_vector( widthHybridAlpha - 1 downto 0 );
    bend:   std_logic_vector( widthHybridBend  - 1 downto 0 );
    layer:  std_logic_vector( widthHybridLayer - 1 downto 0 );
end record;
type t_stubsTransform is array ( natural range <> ) of t_stubTransform;
function nullStub return t_stubTransform;
function conv( t: t_stubTransform ) return std_logic_vector;


type t_stubRoute is
record
    reset:  std_logic;
    valid:  std_logic;
    ps:     std_logic;
    barrel: std_logic;
    bx:     std_logic_vector( widthBX          - 1 downto 0 );
    nonant: std_logic_vector( numOverlap       - 1 downto 0 );
    r:      std_logic_vector( widthHybridR     - 1 downto 0 );
    phi:    std_logic_vector( widthHybridPhi   - 1 downto 0 );
    z:      std_logic_vector( widthHybridZ     - 1 downto 0 );
    alpha:  std_logic_vector( widthHybridAlpha - 1 downto 0 );
    bend:   std_logic_vector( widthHybridBend  - 1 downto 0 );
    layer:  std_logic_vector( widthHybridLayer - 1 downto 0 );
end record;
type t_stubsRoute is array ( natural range <> ) of t_stubRoute;
function nullStub return t_stubRoute;
function conv( s: std_logic_vector ) return t_stubRoute;

constant widthStub: natural := 1 + 1 + 1 + widthHybridLayer + widthHybridBend + widthHybridAlpha + widthHybridPhi + widthHybridZ + widthHybridR;
type t_stubDTC is
record
    reset:  std_logic;
    valid:  std_logic;
    ps:     std_logic;
    barrel: std_logic;
    r:      std_logic_vector( widthHybridR     - 1 downto 0 );
    phi:    std_logic_vector( widthHybridPhi   - 1 downto 0 );
    z:      std_logic_vector( widthHybridZ     - 1 downto 0 );
    alpha:  std_logic_vector( widthHybridAlpha - 1 downto 0 );
    bend:   std_logic_vector( widthHybridBend  - 1 downto 0 );
    layer:  std_logic_vector( widthHybridLayer - 1 downto 0 );
end record;
type t_stubsDTC is array ( natural range <> ) of t_stubDTC;
function nullStub return t_stubDTC;
function conv( s: t_stubDTC ) return std_logic_vector;


end;


package body dtc_stubs is


function nullStub return t_stubCIC       is begin return ( '0', '0', others => ( others => '0' ) ); end function;
function nullStub return t_stubFE        is begin return ( '0', '0', others => ( others => '0' ) ); end function;
function nullStub return t_stubTransform is begin return ( '0', '0', '0', '0', others => ( others => '0' ) ); end function;
function nullStub return t_stubRoute     is begin return ( '0', '0', '0', '0', others => ( others => '0' ) ); end function;
function nullStub return t_stubDTC       is begin return ( '0', '0', '0', '0', others => ( others => '0' ) ); end function;

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
    variable s: std_logic_vector( 1 + 1 + numOverlap + widthHybridLayer + widthHybridBend + widthHybridAlpha + widthHybridPhi + widthHybridZ + widthHybridR - 1 downto 0 ) := ( others => '0' );
begin
    s := t.ps & t.barrel & t.nonant & t.layer & t.bend & t.alpha & t.phi & t.z & t.r;
    return s;
end function;

function conv( s: std_logic_vector ) return t_stubRoute is
    variable r: t_stubRoute := nullStub;
begin
    r.ps     := s( 1 + 1 + numOverlap + widthHybridLayer + widthHybridBend + widthHybridAlpha + widthHybridPhi + widthHybridZ + widthHybridR - 1 );                                                                                         
    r.barrel := s(     1 + numOverlap + widthHybridLayer + widthHybridBend + widthHybridAlpha + widthHybridPhi + widthHybridZ + widthHybridR - 1 );
    r.nonant := s(         numOverlap + widthHybridLayer + widthHybridBend + widthHybridAlpha + widthHybridPhi + widthHybridZ + widthHybridR - 1 downto widthHybridLayer + widthHybridBend + widthHybridAlpha + widthHybridPhi + widthHybridZ + widthHybridR );
    r.layer  := s(                      widthHybridLayer + widthHybridBend + widthHybridAlpha + widthHybridPhi + widthHybridZ + widthHybridR - 1 downto                    widthHybridBend + widthHybridAlpha + widthHybridPhi + widthHybridZ + widthHybridR );
    r.bend   := s(                                         widthHybridBend + widthHybridAlpha + widthHybridPhi + widthHybridZ + widthHybridR - 1 downto                                      widthHybridAlpha + widthHybridPhi + widthHybridZ + widthHybridR );
    r.alpha  := s(                                                           widthHybridAlpha + widthHybridPhi + widthHybridZ + widthHybridR - 1 downto                                                         widthHybridPhi + widthHybridZ + widthHybridR );
    r.phi    := s(                                                                              widthHybridPhi + widthHybridZ + widthHybridR - 1 downto                                                                          widthHybridZ + widthHybridR );
    r.z      := s(                                                                                               widthHybridZ + widthHybridR - 1 downto                                                                                         widthHybridR );
    r.r      := s(                                                                                                              widthHybridR - 1 downto                                                                                                    0 );
    return r;
end function;

function conv( s: t_stubDTC ) return std_logic_vector is
    variable r: std_logic_vector( LWORD_WIDTH - 1 downto 0 ) := ( others => '0' );
begin
    r( widthStub - 1 downto 0 ) := s.valid & s.ps & s.barrel & s.layer & s.bend & s.alpha & s.phi & s.z & s.r;
    return r;
end function;

end package body;