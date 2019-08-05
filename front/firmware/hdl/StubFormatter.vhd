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


entity StubFormatter is
    generic (
        index : in integer := 0
    );
    port (
        -- Input Ports --
        clk : in std_logic;
        StubPipeIn : in tCICStubPipe;
        bus_in : in tFMBusArray;

        -- Output Ports --
        StubPipeOut : out tStubPipe;
        bus_out : out tFMBusArray
    );
end StubFormatter;

architecture Behavioral of StubFormatter is
    signal link_number : tLinkLUT := cLinkLUT;
    signal Stub : tStub := NullStub;
    signal clk_bus : std_logic := '0';
    -- Constants required for FunkyMiniBus
    constant x : integer := bus_out(0)'low + index;
    subtype A is natural range x + 0 to x + 0;

    signal xy : integer := 0;
    signal address : std_logic_vector(17 downto 0) := (others => '0');
    signal tmp_buff : tNonLUTBuf := NullNonLUTBuff;
    signal pos_lut_out : std_logic_vector(53 downto 0) := (others => '0');
begin
    -- Concatenate stub ID and stub strip to form 11 bit address
    address(7 downto 0) <= std_logic_vector(to_unsigned(link_number(index), 5)) & std_logic_vector(StubPipeIn(0).payload.fe_module);

    gPromClocked : for j in 0 to 2 generate
        PosLutInstance0 : ENTITY work.GenPromClocked
            GENERIC MAP(
              FileName => "modules_" & INTEGER'IMAGE(j) & ".mif",
              BusName  => "A/PosLutA" & INTEGER'IMAGE(index)
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

    -- pBuffer : process(clk)
    -- begin
    --     if rising_edge(clk) then
    --         -- Buffer data not needed for LUTs
    --         tmp_buff.valid <= StubPipeIn(i)(0).payload.valid;
    --         tmp_buff.bx <= (StubPipeIn(i)(0).header.boxcar_number(4 downto 0) + StubPipeIn(i)(0).payload.bx(2 downto 0)) mod 18;
    --         tmp_buff.bend <= StubPipeIn(i)(0).payload.bend;
    --         tmp_buff.strip <= StubPipeIn(i)(0).payload.strip;
    --         tmp_buff.column <= StubPipeIn(i)(0).payload.column;
    --     end if;
    -- end process;

    -- Process to use LUT data to produce r, phi, z coordinates to the stubs. This
    -- process should be a zero clock process as it is simply routing the output of
    -- the LUT. Output should be timed such that the stub is assosciated with the
    -- correct lookup.
    pFormat : process(clk)
    begin
        if rising_edge(clk) then
            if (StubPipeIn(1).payload.valid = '1') then
                -- Read delayed values
                Stub.payload.valid <= StubPipeIn(1).payload.valid;
                Stub.header.bx <= StubPipeIn(1).payload.bx(4 downto 0) mod 18;
                Stub.payload.bend <= StubPipeIn(1).payload.bend;
                Stub.intrinsic.strip <= StubPipeIn(1).payload.strip;
                Stub.intrinsic.column <= StubPipeIn(1).payload.column;
                Stub.intrinsic.crossterm <= xy;

                -- Require LUT
                Stub.payload.r <= to_integer(unsigned(pos_lut_out(11 downto 0)));
                Stub.payload.z <= to_integer(signed(pos_lut_out(23 downto 12)));
                Stub.payload.phi <= to_integer(signed(pos_lut_out(40 downto 24)));
                Stub.payload.alpha <= signed(pos_lut_out(44 downto 41));
                Stub.payload.layer <= unsigned(pos_lut_out(46 downto 45));
                Stub.payload.barrel <= pos_lut_out(47);
                Stub.payload.module <= pos_lut_out(48);


                --- THIS NEEDS TO BE SORTED ---
                Stub.header.nonant <= pos_lut_out(50 downto 49);

            else
                Stub <= NullStub;
            end if;
        end if;
    end process;

    pPreMultiplication : process(clk)
    begin
        if rising_edge(clk) then
            xy <= to_integer(StubPipeIn(0).payload.strip) * to_integer(StubPipeIn(0).payload.column);
        end if;
    end process;

    StubPipeInstance : ENTITY work.StubPipe
    PORT MAP(clk, Stub, StubPipeOut);

end Behavioral;
