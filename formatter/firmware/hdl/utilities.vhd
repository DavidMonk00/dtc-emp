----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/20/2019 01:53:39 PM
-- Design Name: 
-- Module Name: utilities - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;
--! Using NUMERIC TYPES
USE IEEE.NUMERIC_STD.ALL;

USE IEEE.MATH_REAL.ALL;

-- ----------------------------------------------
PACKAGE utilities_pkg IS

  CONSTANT for_synthesis : BOOLEAN := TRUE
-- pragma synthesis_off
  AND FALSE
-- pragma synthesis_on
;

  FUNCTION ToInteger( ARG                  : BOOLEAN ) RETURN INTEGER;
  FUNCTION ToStdLogic( ARG                 : BOOLEAN ) RETURN STD_LOGIC;
  FUNCTION ToStdLogicVector( ARG           : BOOLEAN ) RETURN STD_LOGIC_VECTOR;
  FUNCTION ToBoolean( ARG                  : STD_LOGIC ) RETURN BOOLEAN;
  FUNCTION ToStdLogicVector2( int          : INTEGER ) RETURN STD_LOGIC_VECTOR;
  FUNCTION ToStdLogicVector3( int          : INTEGER ) RETURN STD_LOGIC_VECTOR;
  FUNCTION ToStdLogicVector4( int          : INTEGER ) RETURN STD_LOGIC_VECTOR;
  FUNCTION ToStdLogicVector6( int          : INTEGER ) RETURN STD_LOGIC_VECTOR;

  PROCEDURE SET_RANDOM_SIG( VARIABLE SEED1 : INOUT POSITIVE ; SEED2 : INOUT POSITIVE ; SIGNAL RESULT : OUT UNSIGNED );

  FUNCTION count_ones( s                   : STD_LOGIC_VECTOR ) RETURN INTEGER;

END PACKAGE utilities_pkg;
-- ----------------------------------------------

-- ----------------------------------------------
PACKAGE BODY utilities_pkg IS

  FUNCTION ToInteger( ARG : BOOLEAN ) RETURN INTEGER IS
  BEGIN
      IF ARG THEN RETURN( 1 );
      ELSE RETURN( 0 );
      END IF;
  END FUNCTION ToInteger;

  FUNCTION ToStdLogic( ARG : BOOLEAN ) RETURN STD_LOGIC IS
  BEGIN
      IF ARG THEN RETURN( '1' );
      ELSE RETURN( '0' );
      END IF;
  END FUNCTION ToStdLogic;

  FUNCTION ToStdLogicVector( ARG : BOOLEAN ) RETURN STD_LOGIC_VECTOR IS
  BEGIN
      IF ARG THEN RETURN( "1" );
      ELSE RETURN( "0" );
      END IF;
  END FUNCTION ToStdLogicVector;

  FUNCTION ToBoolean( ARG : STD_LOGIC ) RETURN BOOLEAN IS
  BEGIN
      IF ARG='1' THEN RETURN( true );
      ELSE RETURN( false );
      END IF;
  END FUNCTION ToBoolean;

  FUNCTION ToStdLogicVector2( int : INTEGER ) RETURN STD_LOGIC_VECTOR IS
  BEGIN
    RETURN STD_LOGIC_VECTOR( TO_UNSIGNED( int , 2 ) );
  END FUNCTION ToStdLogicVector2;

  FUNCTION ToStdLogicVector3( int : INTEGER ) RETURN STD_LOGIC_VECTOR IS
  BEGIN
    RETURN STD_LOGIC_VECTOR( TO_UNSIGNED( int , 3 ) );
  END FUNCTION ToStdLogicVector3;

  FUNCTION ToStdLogicVector4( int : INTEGER ) RETURN STD_LOGIC_VECTOR IS
  BEGIN
    RETURN STD_LOGIC_VECTOR( TO_UNSIGNED( int , 4 ) );
  END FUNCTION ToStdLogicVector4;

  FUNCTION ToStdLogicVector6( int : INTEGER ) RETURN STD_LOGIC_VECTOR IS
  BEGIN
    RETURN STD_LOGIC_VECTOR( TO_UNSIGNED( int , 6 ) );
  END FUNCTION ToStdLogicVector6;

  PROCEDURE SET_RANDOM_SIG( VARIABLE SEED1 : INOUT POSITIVE ; SEED2 : INOUT POSITIVE ; SIGNAL RESULT : OUT UNSIGNED ) IS
    VARIABLE rand                          : REAL; -- Random real-number value in range 0 to 1.0
  BEGIN
    UNIFORM( seed1 , seed2 , rand ); -- generate random number
    RESULT <= TO_UNSIGNED( INTEGER( rand * REAL( 2 ** 30 ) ) , RESULT'LENGTH );
  END SET_RANDOM_SIG;

  FUNCTION count_ones( s : STD_LOGIC_VECTOR ) RETURN INTEGER IS
    VARIABLE temp        : INTEGER := 0;
  BEGIN
    FOR i IN s'RANGE LOOP
      IF s( i ) = '1' THEN
        temp := temp + 1;
      END IF;
    END LOOP;
    RETURN temp;
  END FUNCTION count_ones;

END PACKAGE BODY utilities_pkg;

