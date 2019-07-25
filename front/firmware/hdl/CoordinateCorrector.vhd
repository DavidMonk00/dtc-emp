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


entity CoordinateCorrector is
    PORT(
        -- Input Ports --
        clk : in std_logic;
        StubPipeIn : in tStubPipe;
        MatricesIn : in tCorrectionMatrixArray;

        -- Output Ports --
        StubPipeOut : out tStubPipe
    );
end CoordinateCorrector;

architecture Behavioral of CoordinateCorrector is
    type tCoordVector is record
        r : integer;
        phi : integer;
        z : integer;
    end record;

    signal StubArray : tStubArray := NullStubArray;
begin

    gCoordinateCorrector : for i in 0 to link_count*stubs_per_word - 1 generate
        signal multiplied_matrix : tCorrectionMatrix := NullCorrectionMatrix;
        signal vector, vector_buff : tCoordVector := (others => 0);
    begin

        pMultiplication : process(clk)
        begin
            if rising_edge(clk) then
                lMultiplication : for j in 0 to 5 loop
                    if (j mod 2) = 0 then
                        multiplied_matrix(j) <= MatricesIn(i)(j)*to_integer(StubPipeIn(0)(i).intrinsic.strip);
                    else
                        multiplied_matrix(j) <= MatricesIn(i)(j)*to_integer(StubPipeIn(0)(i).intrinsic.column);
                    end if;
                end loop;
            end if;
        end process;

        pAddition : process(clk)
        begin
            if rising_edge(clk) then
                vector_buff.r <= multiplied_matrix(0) + multiplied_matrix(1);
                vector_buff.z <= multiplied_matrix(2) + multiplied_matrix(3);
                vector_buff.phi <= multiplied_matrix(4) + multiplied_matrix(5);

                vector.r <= StubPipeIn(2)(i).payload.r + vector_buff.r;
                vector.z <= StubPipeIn(2)(i).payload.z + vector_buff.z;
                vector.phi <= StubPipeIn(2)(i).payload.phi + vector_buff.phi;
            end if;
        end process;

        pOutput : process(clk)
        begin
            if rising_edge(clk) then
                StubArray(i).header <= StubPipeIn(3)(i).header;
                StubArray(i).payload.r <= vector.r;
                StubArray(i).payload.z <= vector.z;
                StubArray(i).payload.phi <= vector.phi;
                StubArray(i).payload.alpha <= StubPipeIn(3)(i).payload.alpha;
                StubArray(i).payload.layer <= StubPipeIn(3)(i).payload.layer;
                StubArray(i).payload.barrel <= StubPipeIn(3)(i).payload.barrel;
                StubArray(i).payload.module <= StubPipeIn(3)(i).payload.module;
                StubArray(i).payload.valid <= StubPipeIn(3)(i).payload.valid;
                StubArray(i).payload.bend <= StubPipeIn(3)(i).payload.bend;
            end if;
        end process;

    end generate;

    StubPipeInstance : ENTITY work.StubPipe
    PORT MAP( clk , StubArray , StubPipeOut );

end Behavioral;
