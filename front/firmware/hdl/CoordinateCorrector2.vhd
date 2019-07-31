----------------------------------------------------------------------------------
-- Company: Imperial College London
-- Engineer: David Monk
--
-- Create Date: 05/17/2019 02:12:35 PM
-- Design Name:
-- Module Name: CoordinateCorrector - Behavioral
-- Project Name: DTC Front End
-- Target Devices: KU15P
-- Tool Versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Revision 0.1 - Code Review: 20190631
--
-- Additional Comments:
--
----------------------------------------------------------------------------------

-- Standard library imports
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Project specific imports
use work.data_types.all;


entity CoordinateCorrector2 is
    PORT(
        -- Input Ports --
        clk : in std_logic;
        StubPipeIn : in tStubPipe;
        MatricesIn : in tCorrectionMatrixArray;

        -- Output Ports --
        StubPipeOut : out tStubPipe
    );
end CoordinateCorrector2;

architecture Behavioral of CoordinateCorrector2 is
    type tCoordVector is record
        xz  : integer;
        phi : integer;
        z   : integer;
        r_1 : integer;
        r_2 : integer;
    end record;

    constant initial_offset : integer := 0;

    signal StubArray : tStubArray := NullStubArray;
begin

    gCoordinateCorrector : for i in 0 to link_count*stubs_per_word - 1 generate
        signal vector, vector_buff, vector_buff_second : tCoordVector := (others => 0);
    begin

        pMultiplication : process(clk)
        begin
            if rising_edge(clk) then
                vector_buff.r_1 <= to_integer(StubPipeIn(initial_offset + 0)(i).intrinsic.column) * MatricesIn(i).sinbeta;
                vector_buff.r_2 <= to_integer(StubPipeIn(initial_offset + 0)(i).intrinsic.strip) * MatricesIn(i).sintheta;
                vector_buff.z <= to_integer(StubPipeIn(initial_offset + 0)(i).intrinsic.column) * MatricesIn(i).cosbeta;
                vector_buff.phi <= to_integer(StubPipeIn(initial_offset + 0)(i).intrinsic.strip) * MatricesIn(i).rinv;
                vector_buff.xz <= StubPipeIn(initial_offset + 0)(i).intrinsic.crossterm * MatricesIn(i).sinbeta_rsquared;
            end if;
        end process;

        pAddition : process(clk)
        begin
            if rising_edge(clk) then
                vector_buff_second.z <= StubPipeIn(initial_offset + 1)(i).payload.z + vector_buff.z;
                vector_buff_second.phi <= StubPipeIn(initial_offset + 1)(i).payload.phi + vector_buff.phi;
                vector_buff_second.xz <= vector_buff.xz;
                vector_buff_second.r_1 <= vector_buff.r_1 + vector_buff.r_2;

                vector.r_1 <= StubPipeIn(initial_offset + 2)(i).payload.r + vector_buff_second.r_1;
                vector.z <= vector_buff_second.z;
                vector.phi <= vector_buff_second.phi + vector_buff_second.xz;
            end if;
        end process;

        pOutput : process(clk)
        begin
            if rising_edge(clk) then
                StubArray(i).header <= StubPipeIn(initial_offset + 3)(i).header;
                StubArray(i).payload.r <= vector.r_1;
                StubArray(i).payload.z <= vector.z;
                StubArray(i).payload.phi <= vector.phi;
                StubArray(i).payload.alpha <= StubPipeIn(initial_offset + 3)(i).payload.alpha;
                StubArray(i).payload.layer <= StubPipeIn(initial_offset + 3)(i).payload.layer;
                StubArray(i).payload.barrel <= StubPipeIn(initial_offset + 3)(i).payload.barrel;
                StubArray(i).payload.module <= StubPipeIn(initial_offset + 3)(i).payload.module;
                StubArray(i).payload.valid <= StubPipeIn(initial_offset + 3)(i).payload.valid;
                StubArray(i).payload.bend <= StubPipeIn(initial_offset + 3)(i).payload.bend;
            end if;
        end process;

    end generate;

    StubPipeInstance : ENTITY work.StubPipe
    PORT MAP( clk , StubArray , StubPipeOut );

end Behavioral;
