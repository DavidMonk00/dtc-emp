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
        MatrixIn : in tCorrectionMatrix;

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
    signal vector, vector_buff, vector_buff_second : tCoordVector := (others => 0);
    signal Stub : tStub := NullStub;
begin
    pMultiplication : process(clk)
    begin
        if rising_edge(clk) then
            vector_buff.r_1 <= to_integer(StubPipeIn(initial_offset + 0).intrinsic.column) * MatrixIn.sinbeta;
            vector_buff.r_2 <= to_integer(StubPipeIn(initial_offset + 0).intrinsic.strip) * MatrixIn.sintheta;
            vector_buff.z <= to_integer(StubPipeIn(initial_offset + 0).intrinsic.column) * MatrixIn.cosbeta;
            vector_buff.phi <= to_integer(StubPipeIn(initial_offset + 0).intrinsic.strip) * MatrixIn.rinv;
            vector_buff.xz <= StubPipeIn(initial_offset + 0).intrinsic.crossterm * MatrixIn.sinbeta_rsquared;
        end if;
    end process;

    pAddition : process(clk)
    begin
        if rising_edge(clk) then
            vector_buff_second.z <= StubPipeIn(initial_offset + 1).payload.z + vector_buff.z;
            vector_buff_second.phi <= StubPipeIn(initial_offset + 1).payload.phi + vector_buff.phi;
            vector_buff_second.xz <= vector_buff.xz;
            vector_buff_second.r_1 <= vector_buff.r_1 + vector_buff.r_2;

            vector.r_1 <= StubPipeIn(initial_offset + 2).payload.r + vector_buff_second.r_1;
            vector.z <= vector_buff_second.z;
            vector.phi <= vector_buff_second.phi + vector_buff_second.xz;
        end if;
    end process;

    pOutput : process(clk)
    begin
        if rising_edge(clk) then
            Stub.header <= StubPipeIn(initial_offset + 3).header;
            Stub.payload.r <= vector.r_1;
            Stub.payload.z <= vector.z;
            Stub.payload.phi <= vector.phi;
            Stub.payload.alpha <= StubPipeIn(initial_offset + 3).payload.alpha;
            Stub.payload.layer <= StubPipeIn(initial_offset + 3).payload.layer;
            Stub.payload.barrel <= StubPipeIn(initial_offset + 3).payload.barrel;
            Stub.payload.module <= StubPipeIn(initial_offset + 3).payload.module;
            Stub.payload.valid <= StubPipeIn(initial_offset + 3).payload.valid;
            Stub.payload.bend <= StubPipeIn(initial_offset + 3).payload.bend;
        end if;
    end process;

    StubPipeInstance : ENTITY work.StubPipe
    PORT MAP(clk, Stub, StubPipeOut);

end Behavioral;
