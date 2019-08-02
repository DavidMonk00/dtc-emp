----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 06/07/2019 10:55:34 AM
-- Design Name:
-- Module Name: RouterInputReformatting - Behavioral
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------

-- Standard library imports
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Project specific imports
use work.data_types.all;
use work.emp_data_types.all;

entity RouterInputReformatting is
    port (
        -- Input Ports --
        clk : in std_logic;
        StubPipeIn : in tStubPipe;

        -- Output Ports --
        WordsOut : out ldata(2*link_count*stubs_per_word - 1 downto 0) := (others => LWORD_NULL)
    );
end RouterInputReformatting;

architecture Behavioral of RouterInputReformatting is

begin

    gRouterInputFormatter : for i in 0 to link_count*stubs_per_word - 1 generate
    begin
        pFormat : process(clk)
        begin
            if rising_edge(clk) then
                WordsOut(2 * i).valid <= StubPipeIn(0)(i).payload.valid;
                WordsOut(2 * i).strobe <= '1';
                WordsOut(2 * i).data(4 downto 0) <= std_logic_vector(StubPipeIn(0)(i).header.bx);
                WordsOut(2 * i).data(6 downto 5) <= std_logic_vector(StubPipeIn(0)(i).header.nonant);

                WordsOut(2 * i + 1).valid <= StubPipeIn(0)(i).payload.valid;
                WordsOut(2 * i + 1).strobe <= '1';
                WordsOut(2 * i + 1).data(11 downto 0) <= std_logic_vector(to_unsigned(StubPipeIn(0)(i).payload.r, 12));
                WordsOut(2 * i + 1).data(23 downto 12) <= std_logic_vector(to_signed(StubPipeIn(0)(i).payload.z, 12));
                WordsOut(2 * i + 1).data(40 downto 24) <= std_logic_vector(to_signed(StubPipeIn(0)(i).payload.phi, 17));
                WordsOut(2 * i + 1).data(44 downto 41) <= std_logic_vector(StubPipeIn(0)(i).payload.alpha);
                WordsOut(2 * i + 1).data(48 downto 45) <= std_logic_vector(StubPipeIn(0)(i).payload.bend);
                WordsOut(2 * i + 1).data(50 downto 49) <= std_logic_vector(StubPipeIn(0)(i).payload.layer);
                WordsOut(2 * i + 1).data(51) <= StubPipeIn(0)(i).payload.barrel;
                WordsOut(2 * i + 1).data(52) <= StubPipeIn(0)(i).payload.module;
            end if;
        end process;
    end generate;



end Behavioral;
