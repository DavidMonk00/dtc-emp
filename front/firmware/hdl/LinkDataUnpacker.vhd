-- Standard library imports
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

-- Project specific imports
use work.data_types.all;
use work.emp_data_types.all;


entity LinkDataUnpacker is
    port (
        --- Input Ports ---
        clk : in std_logic;
        data_in : in std_logic_vector(stub_width - 1 downto 0);
        valid : in std_logic;
        framing_counter : in integer;

        --- Output Ports ---
        stub_out : out tCICStubPipe(0 to pipe_depth)
    );
end entity;

architecture Behavorial of LinkDataUnpacker is
    signal stub : tCICStub := NullCICStub;

begin
    pHeaderSeparation : process(clk)
    begin
        if rising_edge(clk) then
            if framing_counter < header_frames then
                stub.payload <= NullCICPayload;

            else
                stub.payload.valid         <= valid;
                stub.payload.bx            <= unsigned(data_in(6 downto 0));
                stub.payload.fe_module     <= unsigned(data_in(9 downto 7));
                stub.payload.strip         <= signed(data_in(17 downto 10));
                stub.payload.column        <= signed(data_in(22 downto 18));
                stub.payload.bend          <= signed(data_in(26 downto 23));
            end if;
        end if;
    end process pHeaderSeparation;


    CICStubPipeInstance : ENTITY work.CICStubPipe
    PORT MAP(clk, stub, stub_out);

end architecture;
