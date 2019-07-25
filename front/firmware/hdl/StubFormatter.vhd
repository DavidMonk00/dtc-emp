-- ----------------------------------------------------------------------------------
-- -- Company: Imperial College London
-- -- Engineer: David Monk
-- --
-- -- Create Date: 05/07/2019 02:16:21 PM
-- -- Design Name:
-- -- Module Name: StubFormatter - Behavioral
-- -- Project Name: DTC Front End
-- -- Target Devices: KU15P
-- -- Tool Versions:
-- -- Description:
-- --
-- -- Dependencies:
-- --
-- -- Revision:
-- -- Revision 0.01 - File Created
-- -- Revision 0.1 - Added Documentation
-- -- REvision 0.2 - Code Review: 20190531
-- -- Additional Comments:
-- --
-- ----------------------------------------------------------------------------------


-- Standard library imports
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Project specific imports
use work.data_types.all;
use work.FunkyMiniBus.all;
use work.utilities_pkg.all;


entity StubFormatter2 is
    PORT(
        -- Input Ports --
        clk : in std_logic;
        StubPipeIn : in tCICStubPipe;
        bus_in : in tFMBusArray;

        -- Output Ports --
        StubPipeOut : out tStubPipe;
        bus_out : out tFMBusArray
    );
end StubFormatter2;

architecture Behavioral of StubFormatter2 is
    signal link_number : tLinkLUT := cLinkLUT;
    signal StubArray : tStubArray := NullStubArray;
begin


    gStubFormatter : for i in 0 to link_count*stubs_per_word - 1 generate
        signal clk_bus : std_logic := '0';
        -- Constants required for FunkyMiniBus
        constant x : integer := bus_out(0)'low + i;
        subtype A is natural range x + 0 to x + 0;

        signal xy : integer := 0;
        signal address : std_logic_vector(17 downto 0) := (others => '0');
        signal tmp_buff : tNonLUTBuf := NullNonLUTBuff;
        signal pos_lut_out : std_logic_vector(53 downto 0) := (others => '0');
    begin
        -- Concatenate stub ID and stub strip to form 11 bit address
        address(7 downto 0) <= std_logic_vector(to_unsigned(link_number(i), 5)) & std_logic_vector(StubPipeIn(0)(i).payload.row(10 downto 8)); -- Highest 3 bits are assumed to be the FE ID - No idea if this is correct as I didn't make the specifications

        gPromClocked : for j in 0 to 2 generate
            PosLutInstance0 : ENTITY work.GenPromClocked
                GENERIC MAP(
                  FileName => "random_" & INTEGER'IMAGE(j) & ".mif",
                  BusName  => "A/PosLutA" & INTEGER'IMAGE(i)
                )
                PORT MAP(
                    -- Input Ports --
                    clk => clk ,
                    AddressIn => address(10 downto 0),
                    BusIn => bus_in(j)(A),
                    BusClk => clk_bus,

                    -- Output Ports --
                    DataOut => pos_lut_out(18*j + 17 downto 18*j),
                    BusOut => bus_out(j)(A)
                );
        end generate;

        pBuffer : process(clk)
        begin
            if rising_edge(clk) then
                -- Buffer data not needed for LUTs
                tmp_buff.valid <= StubPipeIn(0)(i).payload.valid;
                tmp_buff.bx <= (StubPipeIn(0)(i).header.boxcar_number(4 downto 0) + StubPipeIn(0)(i).payload.bx(2 downto 0)) mod 18;
                tmp_buff.bend <= StubPipeIn(0)(i).payload.bend;
                tmp_buff.strip <= StubPipeIn(0)(i).payload.row(7 downto 0);
                tmp_buff.column <= StubPipeIn(0)(i).payload.column;
            end if;
        end process;

        -- Process to use LUT data to produce r, phi, z coordinates to the stubs. This
        -- process should be a zero clock process as it is simply routing the output of
        -- the LUT. Output should be timed such that the stub is assosciated with the
        -- correct lookup.
        pFormat : process(clk)
        begin
            if rising_edge(clk) then
                if (tmp_buff.valid = '1') then
                    -- Read buffer values
                    StubArray(i).header.bx <= tmp_buff.bx;
                    StubArray(i).payload.valid <= tmp_buff.valid;
                    StubArray(i).payload.bend <= tmp_buff.bend;
                    StubArray(i).intrinsic.strip <= tmp_buff.strip;
                    StubArray(i).intrinsic.column <= tmp_buff.column;
                    StubArray(i).intrinsic.crossterm <= xy;

                    -- Require LUT
                    StubArray(i).header.nonant <= pos_lut_out(1 downto 0);
                    StubArray(i).payload.r <= to_integer(unsigned(pos_lut_out(13 downto 2)));
                    StubArray(i).payload.z <= to_integer(signed(pos_lut_out(25 downto 14)));
                    StubArray(i).payload.phi <= to_integer(signed(pos_lut_out(42 downto 26)));
                    StubArray(i).payload.alpha <= signed(pos_lut_out(45 downto 42));
                    StubArray(i).payload.layer <= unsigned(pos_lut_out(47 downto 46));
                    StubArray(i).payload.barrel <= pos_lut_out(48);
                    StubArray(i).payload.module <= pos_lut_out(49);

                else
                    StubArray(i) <= NullStub;
                end if;
            end if;
        end process;

        pPreMultiplication : process(clk)
        begin
            if rising_edge(clk) then
                xy <= to_integer(StubPipeIn(0)(i).payload.row(7 downto 0)) * to_integer(StubPipeIn(0)(i).payload.column);
            end if;
        end process;

    end generate;

    StubPipeInstance : ENTITY work.StubPipe
    PORT MAP( clk , StubArray , StubPipeOut );

end Behavioral;
