library IEEE;
use IEEE.STD_LOGIC_1164.all;

package tb_decl is

  -- Path of the source file
  constant SOURCE_FILE          : string := "in.txt"; 
  -- Path of the sink file
  constant SINK_FILE            : string := "out.txt"; 

  -- Number of frames to be played back from source
  constant PLAYBACK_LENGTH      : integer := 647; 
  -- Number of frames to be captured in sink
  constant CAPTURE_LENGTH       : integer := 801;
  -- "Quiet" time at the beginning of the simulation, sometime useful to let the firmware settle (?!?)
  constant WAIT_CYCLES_AT_START : integer := 0; 
  -- Playback offset, index of the first frame to be palyed back
  constant PLAYBACK_OFFSET      : integer := 0; 
  -- Capture offset, number of the first clock cycle to be captured
  constant CAPTURE_OFFSET       : integer := 77; 

  -- Toggle loop playback: continuously loop data
  constant PLAYBACK_LOOP        : boolean := false;
  -- Strip the heaer i.e. first valid frame of the packet before injecting the data into the algorithms
  constant STRIP_HEADER         : boolean := false;
  -- Insert the heaer i.e. attach 1 valid frame before the first frame in the packet
  constant INSERT_HEADER        : boolean := false;


end package;  -- tb_decl 