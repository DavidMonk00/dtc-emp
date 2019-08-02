----------------------------------------------------------------------------------
-- Company: Imperial College London
-- Engineer: David Monk
--
-- Create Date: 05/01/2019 03:16:15 PM
-- Design Name:
-- Module Name: algo - Behavioral
-- Project Name:
-- Target Devices: KU15P
-- Tool Versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Revision 0.1 - Documentation added
-- Revision 0.2 - Code Review: 20190531
-- Additional Comments:
--
----------------------------------------------------------------------------------

-- Standard library imports
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

-- Project specific imports
use work.data_types.all;
use work.FunkyMiniBus.all;
use work.utilities_pkg.all;

use work.emp_data_types.all;
use work.emp_device_decl.all;


entity algo is
    PORT (
        -- Input Ports --
        clk : in std_logic;
        links_in : in ldata(link_count - 1 downto 0) := (others => LWORD_NULL);

        -- Output Ports --
        data_out : out ldata(4*link_count - 1 downto 0) := (others => LWORD_NULL)
    );
end algo;

architecture Behavioral of algo is
    signal bus_out, bus_in : tFMBusArray;
    -- signal header : tHeaderArray := NullHeaderArray; -- Header of CIC word
    -- signal CIC_stubs : tCICStubArray; -- Array of CIC stubs formed from CIC word

    signal CICStubPipe : tCICStubPipe( 0 to 10 ) := (OTHERS=>NullCICStubArray);
    signal FormattedStubPipe : tStubPipe( 0 to 10 ) := (OTHERS=>NullStubArray);
    signal CorrectedStubPipe : tStubPipe( 0 to 10 ) := (OTHERS=>NullStubArray);


    -- signal pre_stubs : tStubArray; -- Array of converted stubs
    -- signal stubs : tStubArray;
    signal matrices : tCorrectionMatrixArray := NullCorrectionMatrixArray;
    signal matrix_bus_out, matrix_bus_in : tFMBusArray;
    signal sData_out : ldata(4*link_count - 1 downto 0) := (others => LWORD_NULL);
    signal sData_in : ldata(link_count - 1 downto 0) := (others => LWORD_NULL);
    signal probe_valid_in, probe_valid_out : std_logic_vector(0 downto 0) := (others => '0');

begin
    
    data_out <= sData_out;
    sData_in <= links_in;
    
    probe_valid_in(0) <= sData_in(0).valid;
    probe_valid_out(0) <= sData_out(0).valid;
    


    ilaInstance : entity work.ila_0
    PORT MAP (
        clk => clk,
        probe0 => sData_in(0).data, 
	    probe1 => sData_out(0).data,
	    probe2 => probe_valid_in,
	    probe3 => probe_valid_out
    );

    LinkFormatterInstance : entity work.LinkFormatter2
    port map (
        clk => clk,
        LinksIn => links_in,
        StubPipeOut => CICStubPipe
    );

    StubFormatterInstance : entity work.StubFormatter2
    port map (
        clk => clk,
        bus_in => bus_in,
        bus_out => bus_out,
        StubPipeIn => CICStubPipe,
        StubPipeOut => FormattedStubPipe
    );

    GetCorrectionMatrixInstance : entity work.GetCorrectionMatrix
    port map (
        clk => clk,
        bus_in => matrix_bus_in,
        -- bus_out => bus_out
        StubPipeIn => CICStubPipe,
        MatricesOut => matrices
    );

    CoordinateCorrectorInstance : entity work.CoordinateCorrector2
    port map (
        clk => clk,
        StubPipeIn => FormattedStubPipe,
        MatricesIn => matrices,

        -- Output Ports --
        StubPipeOut => CorrectedStubPipe
    );

    RouterInputReformattingInstance : entity work.RouterInputReformatting
    port map (
        clk => clk,
        StubPipeIn => CorrectedStubPipe,
        WordsOut => sData_out
    );

end Behavioral;
