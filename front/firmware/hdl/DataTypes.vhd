----------------------------------------------------------------------------------
-- Company: Imperial College London
-- Engineer: David Monk
--
-- Create Date: 05/07/2019 11:42:21 AM
-- Design Name:
-- Module Name: DataTypes - Behavioral
-- Project Name: DTC Front End
-- Target Devices: KU15P
-- Tool Versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Revision 0.1 - Added Documentation
-- Revision 0.2 - Code Review: 20190531
-- Additional Comments:
--
----------------------------------------------------------------------------------


-- Standard library imports
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Project specific imports
use work.FunkyMiniBus.all;
use work.utilities_pkg.all;

use work.emp_data_types.all;
use work.emp_device_decl.all;

package data_types is
    -- Number of optical links arriving from CICs
    constant link_count : integer :=  1;--4 * N_REGION;


    type tLinksIn is array(integer range 0 to link_count - 1) of std_logic_vector(63 downto 0);
    constant NullLinksIn : tLinksIn := (others => (others => '0'));


    -- Constants relating to CIC input word
    constant stubs_per_word : integer := 2;
    constant stub_width : integer := 32;
    constant frames : integer := 64;
    constant header_frames : integer := 6;


    -- Input CIC header format as described in most recent DTC Interface Document
    type tCICHeader is record
        boxcar_number : unsigned(11 downto 0);
        stub_count    : unsigned(5 downto 0);
    end record;
    constant NullCICHeader : tCICHeader := ((others => '0'), (others => '0'));


    -- Input CIC stub format as described in most recent DTC Interface Document
    type tCICPayload is record
        valid       : std_logic;
        bx          : unsigned(6 downto 0);
        strip       : signed(7 downto 0);
        fe_module   : unsigned(2 downto 0);
        column      : signed(4 downto 0);
        bend        : signed(3 downto 0);
    end record;
    constant NullCICPayload : tCICPayload := ('0',
                                       (others => '0'), (others => '0'),
                                       (others => '0'), (others => '0'),
                                       (others => '0'));



    type tCICStub is record
        header : tCICHeader;
        payload : tCICPayload;
    end record;
    constant NullCICStub : tCICStub := (NullCICHeader, NullCICPayload);

    type tUnconstrainedCICStubArray is array(integer range <>) of tCICStub;
    subtype tCICWordStubArray is tUnconstrainedCICStubArray(0 to stubs_per_word - 1);
    constant NullCICWordStubArray : tCICWordStubArray := (others => NullCICStub);
    subtype tCICStubArray is tUnconstrainedCICStubArray(0 to link_count*stubs_per_word - 1);
    constant NullCICStubArray : tCICStubArray := (others => NullCICStub);


    type tCICStubPipe is array( natural range <> ) of tCICStubArray;


    -- Stub format into DTC router, comprises of two lwords, one for header and
    -- one for payload
    type tStubHeader is record
        bx      : unsigned(4 downto 0);
        nonant  : std_logic_vector(1 downto 0);
    end record;
    constant NullStubHeader : tStubHeader := ((others => '0'), (others => '0'));


    type tStubIntrinsicCoordinates is record
        strip       : signed(7 downto 0);
        column      : signed(4 downto 0);
        crossterm   : integer;
    end record;
    constant NullStubIntrinsicCoordinates : tStubIntrinsicCoordinates := ((others => '0'), (others => '0'), 0);


    type tStubPayload is record
        valid   : std_logic;
        r       : integer;
        z       : integer;
        phi     : integer;
        alpha   : signed(3 downto 0);
        bend    : signed(3 downto 0);
        layer   : unsigned(1 downto 0);
        barrel  : std_logic;
        module  : std_logic;
    end record;
    constant NullStubPayload : tStubPayload :=  ('0', 0, 0, 0,(others => '0'),
                                                (others => '0'), (others => '0'),
                                                '0', '0');

    -- Stub format as described in most recent DTC Interface Document
    type tStub is record
        header      : tStubHeader;
        intrinsic   : tStubIntrinsicCoordinates;
        payload     : tStubPayload;
    end record;
    constant NullStub : tStub := (NullStubHeader, NullStubIntrinsicCoordinates, NullStubPayload);


    type tUnconstrainedStubArray is array(integer range <>) of tStub;
    subtype tStubArray is tUnconstrainedStubArray(0 to link_count*stubs_per_word - 1);
    constant NullStubArray : tStubArray := (others => NullStub);

    type tStubPipe is array( natural range <> ) of tStubArray;

    -- Array for buffering non-LUT data for the module lookup.
    type tNonLUTBuf is record
        valid   : std_logic;
        bx      : unsigned(4 downto 0);
        bend    : signed(3 downto 0);
        strip   : signed(7 downto 0);
        column  : signed(4 downto 0);
    end record;
    constant NullNonLUTBuff : tNonLUTBuf := ('0', (others => '0'), (others => '0'), (others => '0'),  (others => '0'));


    -- LUT for giving the link number as a port for the stub formatter.
    type tLinkLUT is array (0 to (stubs_per_word*link_count) - 1) of integer range 0 to stubs_per_word*link_count - 1;
    constant cLinkLUT : tLinkLUT := (
        0, 1-- 2, 3, 4, 5, 6, 7, 8, 9,
        -- 10, 11, 12, 13, 14, 15, 16, 17, 18, 19,
        -- 20, 21, 22, 23, 24, 25, 26, 27, 28, 29,
        -- 30, 31, 32, 33, 34, 35, 36, 37, 38, 39,
        -- 40, 41, 42, 43, 44, 45, 46, 47, 48, 49,
        -- 50, 51, 52, 53, 54, 55, 56, 57, 58, 59,
        -- 60, 61, 62, 63, 64, 65, 66, 67, 68, 69,
        -- 70, 71, 72, 73, 74, 75, 76, 77, 78, 79,
        -- 80, 81, 82, 83, 84, 85, 86, 87, 88, 89,
        -- 90, 91, 92, 93, 94, 95, 96, 97, 98, 99,
        -- 100, 101, 102, 103, 104, 105, 106, 107, 108, 109,
        -- 110, 111, 112, 113, 114, 115, 116, 117, 118, 119,
        -- 120, 121, 122, 123, 124, 125, 126, 127, 128, 129,
        -- 130, 131, 132, 133, 134, 135, 136, 137, 138, 139,
        -- 140, 141, 142, 143
    );


    -- Required for the parallel FMbuses used to read 54 bits per clock cycle
    -- for the module LUT
    type tUnconstrainedFMBusArray is array(integer range <>) of tFMBus(0 to stubs_per_word*link_count - 1);
    subtype tFMBusArray is tUnconstrainedFMBusArray(0 to 2);

    -- Correction matrix - exact format is still undecided as I do not know the
    -- range of values for the module dimensions.
    type tCorrectionMatrix is record
        sintheta            : integer;
        sinbeta             : integer;
        rinv                : integer;
        sinbeta_rsquared    : integer;
        cosbeta             : integer;
    end record;
    constant NullCorrectionMatrix : tCorrectionMatrix := (others => 0);

    type tUnconstrainedCorrectionMatrixArray is array(integer range <>) of tCorrectionMatrix;
    subtype tCorrectionMatrixArray is tUnconstrainedCorrectionMatrixArray(0 to link_count*stubs_per_word - 1);
    constant NullCorrectionMatrixArray : tCorrectionMatrixArray := (others => NullCorrectionMatrix);


    -- constant Nulllword : std_logic_vector(63 downto 0) := (others => '0');
    -- type tUnconstrainedlwordArray is array(integer range <>) of std_logic_vector(63 downto 0);
    -- subtype tRouterInputWord is tUnconstrainedlwordArray(0 to 1);
    -- constant NullRouterInputWord : tRouterInputWord := (others => Nulllword);
    -- subtype tRouterInputArray is tUnconstrainedlwordArray(0 to 2*link_count*stubs_per_word -1);
    -- constant NullRouterInputArray : tRouterInputArray := (others => Nulllword);

end package data_types;
