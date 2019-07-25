----------------------------------------------------------------------------------
-- Company: Imperial College London
-- Engineer: David Monk
--
-- Create Date: 05/03/2019 02:27:09 PM
-- Design Name:
-- Module Name: LinkGenerator - Behavioral
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
-- Additional Comments:
--
----------------------------------------------------------------------------------

--Standard library imports
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;


entity LinkGenerator is
    PORT(
        -- Input Ports --
        clk : in std_logic;

        -- Output Ports --
        links_out : out std_logic_vector(63 downto 0) := (others => '0')
    );
end LinkGenerator;

architecture Behavioral of LinkGenerator is

begin

    -- Process that reads file and outputs a line each clock cycle as a logic
    -- vector. NOTE: Option to also write to file is commented out but kept for
    -- future reference.
    process is
        variable line_v : line;
        file read_file : text;
        -- file write_file : text;
        variable slv_v : std_logic_vector(63 downto 0);
    begin
        file_open(read_file, "source.txt", read_mode);
        -- file_open(write_file, "target.txt", write_mode);
        while not endfile(read_file) loop
            wait until clk = '1' and clk'event;
            readline(read_file, line_v);
            hread(line_v, slv_v);
            links_out <= slv_v;
            -- report "slv_v: " & to_hstring(slv_v);
            -- hwrite(line_v, slv_v);
            -- writeline(write_file, line_v);
        end loop;
        file_close(read_file);
        -- file_close(write_file);
        wait;
    end process;
end Behavioral;
