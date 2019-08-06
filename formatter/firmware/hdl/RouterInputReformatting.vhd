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
        WordsOut : out ldata(1 downto 0) := (others => LWORD_NULL)
    );
end RouterInputReformatting;

architecture Behavioral of RouterInputReformatting is

begin

    pFormat : process(clk)
    begin
        if rising_edge(clk) then
            WordsOut(0).valid <= StubPipeIn(0).payload.valid;
            WordsOut(0).strobe <= '1';
            WordsOut(0).data(4 downto 0) <= std_logic_vector(StubPipeIn(0).header.bx);
            WordsOut(0).data(6 downto 5) <= std_logic_vector(StubPipeIn(0).header.nonant);

            WordsOut(1).valid <= StubPipeIn(0).payload.valid;
            WordsOut(1).strobe <= '1';
            WordsOut(1).data(0) <= StubPipeIn(0).payload.valid;
            WordsOut(1).data(12 downto 1) <= std_logic_vector(to_unsigned(StubPipeIn(0).payload.r, 12));
            WordsOut(1).data(23 downto 13) <= std_logic_vector(to_signed(StubPipeIn(0).payload.z, 12));
            WordsOut(1).data(41 downto 25) <= std_logic_vector(to_signed(StubPipeIn(0).payload.phi, 17));
            WordsOut(1).data(45 downto 42) <= std_logic_vector(StubPipeIn(0).payload.alpha);
            WordsOut(1).data(49 downto 46) <= std_logic_vector(StubPipeIn(0).payload.bend);
            WordsOut(1).data(51 downto 50) <= std_logic_vector(StubPipeIn(0).payload.layer);
            WordsOut(1).data(52) <= StubPipeIn(0).payload.barrel;
            WordsOut(1).data(53) <= StubPipeIn(0).payload.module;
        end if;
    end process;

end Behavioral;
