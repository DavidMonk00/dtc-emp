
-- --------------------------------------------------------------------------------
--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;

--! Using the data-types
use work.data_types.all;

--! @brief An entity providing a CICStubPipe
--! @details Detailed description
ENTITY CICStubPipe IS
  PORT(
    clk      : IN STD_LOGIC               := '0'; --! The algorithm clock
    CICStubsIn  : IN tCICStubArray := NullCICStubArray;
    CICStubPipe : OUT tCICStubPipe
  );
END CICStubPipe;

--! @brief Architecture definition for entity CICStubPipe
--! @details Detailed description
ARCHITECTURE behavioral OF CICStubPipe IS
    SIGNAL CICStubPipeInternal : tCICStubPipe( CICStubPipe'RANGE ) := ( OTHERS => NullCICStubArray );
BEGIN

  CICStubPipeInternal( 0 ) <= CICStubsIn; -- since the data is clocked out , no need to clock it in as well...

  gHeaderPipe : FOR i IN 1 TO CICStubPipe'HIGH GENERATE
    CICStubPipeInternal( i ) <= CICStubPipeInternal( i-1 ) WHEN RISING_EDGE( clk );
  END GENERATE gHeaderPipe;

  CICStubPipe <= CICStubPipeInternal;

END ARCHITECTURE behavioral;
