-------------------------------------------------------------------------------
-- INTEGRATOR_FWD.vhd
--
-- Forward Eular Method Integrator (w/ Saturation) Module
--
-- Transfer Function:
--    z^(-1)          1
-- ------------ or -------
--  1 - z^(-1)      z - 1
--
-- Designer: AUDIY
-- Date    : 22/09/27 (YY/MM/DD)
-- Version : 0.01
--
-- Description
--   Parameter
--   DATA_Bit_Length: Input/Output Data Bit Length
--
--   Input
--   CLK_I  : Latch Clock Input
--   DATA_I : Data Input
--
--   Output
--   DATA_O : Integrated Data Output
--   OFDET_O: Overflow Detection Signal
--   UFDET_O: Underflow Detection Signal
-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;

entity INTEGRATOR_FWD is
    -- Parameter Definition
    generic(
        DATA_Bit_Length: natural := 32
    );

    -- Port Definition
    port(
        -- Input
        CLK_I:   in  std_logic;
        DATA_I:  in  std_logic_vector (DATA_Bit_Length-1 downto 0);

        -- Output
        DATA_O:  buffer std_logic_vector (DATA_Bit_Length-1 downto 0) := (others => '0');
        OFDET_O: out std_logic;
        UFDET_O: out std_logic
    );
end INTEGRATOR_FWD;
    
architecture RTL of INTEGRATOR_FWD is
    -- Internal Wire/Register Definition
        -- Register
        signal DATA_REG_POS : std_logic_vector (DATA_Bit_Length-1 downto 0) := (others => '0');
        signal DATA_REG_NEG : std_logic_vector (DATA_Bit_Length-1 downto 0) := (others => '0');
        signal UFDET_REG    : std_logic := '0';
        signal OFDET_REG    : std_logic := '0';

        -- Wire
        signal SUM_DATA     : std_logic_vector (DATA_Bit_Length downto 0) := (others => '0');
	    signal SUM_DATA_MSB2: std_logic_vector (1 downto 0):= "00";
begin
    SUM_DATA <= (DATA_I(DATA_Bit_Length-1) & DATA_I(DATA_Bit_Length-1 downto 0)) + (DATA_O(DATA_Bit_Length-1) & DATA_O(DATA_Bit_Length-1 downto 0));
    SUM_DATA_MSB2 <= SUM_DATA(DATA_Bit_Length downto DATA_Bit_Length-1);

    process (CLK_I)
    begin
        -- Saturation Process
        if (CLK_I'event and CLK_I = '1') then
            case SUM_DATA_MSB2 is
                when "01"   =>
                    -- Positive Overflow
                    -- Ex. "01111" + "00001" = "01111" ("010000")
                    DATA_REG_POS <= '0' & (DATA_Bit_Length-2 downto 0 => '1');
                    OFDET_REG <= '1';
                    UFDET_REG <= '0';
                when "10"   =>
                    -- Negative Overflow
                    -- Ex. "10000" + "11110" = "10000" ("101111")
                    DATA_REG_POS <= '1' & (DATA_Bit_Length-2 downto 0 => '0');
                    OFDET_REG <= '0';
                    UFDET_REG <= '1';
                when others =>
                    -- Normal Oparation
                    DATA_REG_POS <= SUM_DATA(DATA_Bit_Length) & SUM_DATA(DATA_Bit_Length-2 downto 0);
                    OFDET_REG <= '0';
                    UFDET_REG <= '0';
            end case;
        elsif (CLK_I'event and CLK_I = '0') then
            -- Assign Outputs
            DATA_REG_NEG <= DATA_REG_POS;
            OFDET_O <= OFDET_REG;
            UFDET_O <= UFDET_REG;
        end if;

    end process;

    DATA_O <= DATA_REG_NEG;

end RTL;