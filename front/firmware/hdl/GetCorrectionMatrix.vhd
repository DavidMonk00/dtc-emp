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
    Port (
        -- Input Ports --
        clk : in std_logic;
        StubPipeIn : in tCICStubPipe;
        bus_in : in tFMBusArray;

        -- Output Ports --
        MatricesOut : out tCorrectionMatrixArray := NullCorrectionMatrixArray;
        bus_out : out tFMBusArray
    );
end GetCorrectionMatrix;

architecture Behavioral of GetCorrectionMatrix is
    signal link_number : tLinkLUT := cLinkLUT;
begin
    gGetCorrectionMatrix : for i in 0 to link_count*stubs_per_word - 1 generate
        signal address, data_0, data_1 : std_logic_vector(17 downto 0) := (others => '0');
        signal data : std_logic_vector(35 downto 0) := (others => '0');
        signal clk_bus : std_logic := '0';

        -- Constants required for FunkyMiniBus
        constant x : integer := bus_out'low + i;
        subtype A is natural range x + 0 to x + 0;
    begin

        -- Highest 3 bits are assumed to be the FE ID - No idea if this is correct as I didn't make the specifications
        address(4 downto 0) <= std_logic_vector(to_unsigned(link_number(i), 5));
        data <= data_0 & data_1;
        MatrixLutInstance1 : ENTITY work.GenPromClocked
            GENERIC MAP(
              FileName => "correction_0.mif",
              BusName  => "A/MatrixA" & INTEGER'IMAGE(i)
            )
            PORT MAP(
                -- Input Ports --
                clk => clk ,
                AddressIn => address(10 downto 0),
                BusIn => bus_in(0)(A),
                BusClk => clk_bus,

                -- Output Ports --
                DataOut => data_0,
                BusOut => bus_out(0)(A)
            );

        MatrixLutInstance2 : ENTITY work.GenPromClocked
            GENERIC MAP(
              FileName => "correction_1.mif",
              BusName  => "A/MatrixA" & INTEGER'IMAGE(i)
            )
            PORT MAP(
                -- Input Ports --
                clk => clk ,
                AddressIn => address(10 downto 0),
                BusIn => bus_in(1)(A),
                BusClk => clk_bus,

                -- Output Ports --
                DataOut => data_1,
                BusOut => bus_out(1)(A)
            );

        MatricesOut(i).sintheta <= to_integer(signed(data(5 downto 0)));
        MatricesOut(i).sinbeta <= to_integer(signed(data(11 downto 6)));
        MatricesOut(i).rinv <= to_integer(signed(data(17 downto 12)));
        MatricesOut(i).sinbeta_rsquared <= to_integer(signed(data(23 downto 18)));
        MatricesOut(i).cosbeta <= to_integer(signed(data(29 downto 24)));
    end generate;

end Behavioral;
