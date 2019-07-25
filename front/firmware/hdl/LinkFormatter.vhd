-- Standard library imports
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

-- Project specific imports
use work.data_types.all;



entity LinkFormatter2 is
    port (
        clk : in std_logic;
        LinksIn : in tLinksIn;
        StubPipeOut : out tCICStubPipe
    );
end LinkFormatter2;


architecture Behavioral of LinkFormatter2 is

    signal StubArray : tCICStubArray := NullCICStubArray;
    signal counter : integer range 0 to (frames - 1) := (frames - 1);

begin

    pCounter : process(clk)
    begin
        if rising_edge(clk) then
            if counter = (frames - 1) then
                counter <= 0;
            else
                counter <= counter + 1;
            end if;
        end if;
    end process pCounter;

    gLinksFormat : for i in 0 to link_count - 1 generate
    begin

        fStubAssignment : for j in 0 to stubs_per_word - 1 generate
            pHeaderSeparation : process(clk)
            begin
                if rising_edge(clk) then
                    -- Separate out header words from payload
                    if counter < header_frames then
                            StubArray(i * stubs_per_word + j).payload.valid <= '0';

                            StubArray(i * stubs_per_word + j).header.boxcar_number <= unsigned(LinksIn(i)(63 downto 52));
                            StubArray(i * stubs_per_word + j).header.stub_count <= unsigned(LinksIn(i)(51 downto 46));
                    else
                        -- Conversion to current DTC input word format

                            StubArray(i * stubs_per_word + j).header.boxcar_number  <= StubArray(i * stubs_per_word + j).header.boxcar_number;
                            StubArray(i * stubs_per_word + j).header.stub_count     <= StubArray(i * stubs_per_word + j).header.stub_count;

                            StubArray(i * stubs_per_word + j).payload.valid         <= LinksIn(i)(63 - j * stub_width);
                            StubArray(i * stubs_per_word + j).payload.bx            <= unsigned(LinksIn(i)(63 - (j * stub_width + 1) downto 63 - (j * stub_width + 7)));
                            StubArray(i * stubs_per_word + j).payload.row           <= signed(LinksIn(i)(63 - (j * stub_width + 8) downto 63 - (j * stub_width + 18)));
                            StubArray(i * stubs_per_word + j).payload.column        <= signed(LinksIn(i)(63 - (j * stub_width + 19) downto 63 - (j * stub_width + 23)));
                            StubArray(i * stubs_per_word + j).payload.bend          <= signed(LinksIn(i)(63 - (j * stub_width + 24) downto 63 - (j * stub_width + 27)));

                    end if;
                end if;
            end process;
        end generate;
    end generate;

    CICStubPipeInstance : ENTITY work.CICStubPipe
    PORT MAP( clk , StubArray , StubPipeOut );

end Behavioral;
