----------------------------------------------------------------------------------
-- Company: Imperial College London
-- Engineer: David Monk
--
-- Create Date: 05/29/2019 11:12:08 AM
-- Design Name:
-- Module Name: GetArray - Behavioral
-- Project Name: DTC Front End
-- Target Devices: KU15P
-- Tool Versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Revision 0.1 - Code Review: 20190531
-- Additional Comments:
--
----------------------------------------------------------------------------------


-- Standard library imports
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Project specific imports
use work.data_types.all;
use work.FunkyMiniBus.all;
use work.utilities_pkg.all;


entity GetCorrectionMatrix is
    generic (
        index : in integer := 0
    );
    port (
        -- Input Ports --
        clk : in std_logic;
        StubPipeIn : in tCICStubPipe;
        bus_in : in tFMBusArray;

        -- Output Ports --
        MatrixOut : out tCorrectionMatrix := NullCorrectionMatrix;
        bus_out : out tFMBusArray
    );
end GetCorrectionMatrix;

architecture Behavioral of GetCorrectionMatrix is
    signal link_number : tLinkLUT := cLinkLUT;
    type tdata is array(integer range 0 to 1) of std_logic_vector(17 downto 0);
    signal data_array : tdata := (others => (others => '0'));
    signal address : std_logic_vector(17 downto 0) := (others => '0');
    signal data : std_logic_vector(35 downto 0) := (others => '0');
    signal clk_bus : std_logic := '0';

    -- Constants required for FunkyMiniBus
    constant x : integer := bus_out'low + index;
    subtype A is natural range x + 0 to x + 0;
begin
    address(7 downto 0) <= std_logic_vector(to_unsigned(link_number(index), 5)) & std_logic_vector(StubPipeIn(0).payload.fe_module);
    data <= data_array(1) & data_array(0);

    gPromClocked : for j in 0 to 1 generate
        MatrixLutInstance : ENTITY work.GenPromClocked
            GENERIC MAP(
              FileName => "correction_" & INTEGER'IMAGE(j) & ".mif",
              BusName  => "A/PosLutA" & INTEGER'IMAGE(index)
            )
            PORT MAP(
                -- Input Ports --
                clk => clk ,
                AddressIn => address(10 downto 0),
                BusIn => bus_in(j)(A),
                BusClk => clk_bus,

                -- Output Ports --
                DataOut => data_array(j),
                BusOut => bus_out(j)(A)
            );
    end generate;

    pBuffer : process(clk)
    begin
        if rising_edge(clk) then
            MatrixOut.sintheta <= to_integer(signed(data(5 downto 0)));
            MatrixOut.sinbeta <= to_integer(signed(data(11 downto 6)));
            MatrixOut.rinv <= to_integer(signed(data(17 downto 12)));
            MatrixOut.sinbeta_rsquared <= to_integer(signed(data(23 downto 18)));
            MatrixOut.cosbeta <= to_integer(signed(data(29 downto 24)));
        end if;
    end process;

end Behavioral;
