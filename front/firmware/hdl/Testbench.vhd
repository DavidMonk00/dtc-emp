library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use work.data_types.all;
use work.emp_data_types.all;


entity Testbench is
end Testbench;

architecture Behavioral of Testbench is
    signal clk : std_logic := '0';
    signal counter : integer := 0; -- Counter to more easily calculate latency
    signal links_in : ldata(link_count - 1 downto 0) := (others => LWORD_NULL); -- Input word for CIC
    signal links_out : ldata(2* stubs_per_word*link_count - 1 downto 0) := (others => LWORD_NULL);

begin

    clk <= not clk after 12.5 ns;

    -- Process for increasing counter by one each clock cycle
    process(clk)
    begin
        if rising_edge(clk) then
            counter <= counter + 1;
        end if;
    end process;


    gLinksGen : for i in 0 to link_count - 1 generate
        -- Dummy instance to generate CIC words from file
         LinkGeneratorInstance : entity work.LinkGenerator
         port map (
            clk => clk,
            links_out => links_in(i)
         );

         LinkConverterInstance : entity work.LinkConverter
         generic map (
            index => i
         )
         PORT MAP(
             clk => clk,
             link_in => links_in(i),
             data_out => links_out(2*stubs_per_word*(i+1) - 1 downto 2*stubs_per_word*i)
         );
    end generate;

end Behavioral;
