
-- --------------------------------------------------------------------------------
--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;

--! Using the data-types
use work.data_types.all;

--! @brief An entity providing a StubPipe
--! @details Detailed description
ENTITY StubPipe IS
  PORT(
    clk      : IN STD_LOGIC               := '0'; --! The algorithm clock
    StubsIn  : IN tStubArray := NullStubArray;
    StubPipe : OUT tStubPipe
  );
END StubPipe;

--! @brief Architecture definition for entity StubPipe
--! @details Detailed description
ARCHITECTURE behavioral OF StubPipe IS
    SIGNAL StubPipeInternal : tStubPipe( stubPipe'RANGE ) := ( OTHERS => NullStubArray );
BEGIN

  StubPipeInternal( 0 ) <= StubsIn; -- since the data is clocked out , no need to clock it in as well...

  gStubPipe : FOR i IN 1 TO StubPipe'HIGH GENERATE
    StubPipeInternal( i ) <= StubPipeInternal( i-1 ) WHEN RISING_EDGE( clk );
  END GENERATE gStubPipe;

  StubPipe <= StubPipeInternal;

END ARCHITECTURE behavioral;
