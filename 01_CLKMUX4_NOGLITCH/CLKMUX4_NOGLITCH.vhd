-------------------------------------------------------------------------------
-- CLKMUX4_NOGLITCH.v
--
-- Glitch-free Clock Multiplexer Module w/o ALTCLKCTRL IP.
--
-- Designer: AUDIY
-- Date    : 22/10/16 (YY/MM/DD)
-- Version : 1.00
--
-- Description
--   Input
--   DATA3_I: Clock Input 3
--   DATA2_I: Clock Input 2
--   DATA1_I: Clock Input 1
--   DATA0_I: Clock Input 0
--   SEL_I  : Clock Select
--            2'b11: DATA3_I
--            2'b10: DATA2_I
--            2'b01: DATA1_I
--            2'b00: DATA0_I
--   EN_I   : Output Enable
--            1'b1: Enable
--            1'b0: Disable
--
--   Output
--   DATA_O: Selected Clock Output
--
-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity CLKMUX4_NOGLITCH is
    -- Port Definition
    port(
        -- Input
        DATA3_I: in std_logic;
        DATA2_I: in std_logic;
        DATA1_I: in std_logic;
        DATA0_I: in std_logic;
        SEL_I  : in std_logic_vector (1 downto 0);
        EN_I   : in std_logic;

        -- Output
        DATA_O : out std_logic
    );
end CLKMUX4_NOGLITCH;

architecture RTL of CLKMUX4_NOGLITCH is
    signal DATA_WIRE:              std_logic_vector (3 downto 0);
    signal SELECT_ENABLE_WIRE_XOR: std_logic_vector (1 downto 0);
    signal SELECT_ENABLE_WIRE_OR:  std_logic;
    signal TRUE_EN:                std_logic;
    signal DATACTRL:               std_logic;

    signal SEL_REG:                std_logic_vector (1 downto 0) := (others => '0');
    signal ENA_REG:                std_logic := '0';

    -- Clock Select Function
    function datasel (
        a: in std_logic_vector(3 downto 0); 
        b: in std_logic_vector(1 downto 0)
    ) return std_logic is
        
        variable datasel_o: std_logic;
    begin
        case b is
            when "11" =>
                datasel_o := a(3);
            when "10" =>
                datasel_o := a(2);
            when "01" =>
                datasel_o := a(1);
            when others =>
                datasel_o := a(0);
        end case;

        return datasel_o;
    end datasel;
begin
    -- RTL
    -- Bus Input Wire
    DATA_WIRE(3 downto 0) <= DATA3_I & DATA2_I & DATA1_I & DATA0_I;

    -- Multiplex Clock
    DATACTRL <= datasel(DATA_WIRE, SEL_REG);

    -- Enable & Select signal
    process (DATACTRL) begin
        if (DATACTRL'event and DATACTRL = '0') then
            if (ENA_REG = '0') then
                SEL_REG(1 downto 0) <= SEL_I(1 downto 0);
            end if;
            ENA_REG <= TRUE_EN;
        end if;
    end process;

    -- Logic Calcuration
    SELECT_ENABLE_WIRE_XOR(1 downto 0) <= (SEL_REG(1) xor SEL_I(1)) & (SEL_REG(0) xor SEL_I(0));
    SELECT_ENABLE_WIRE_OR              <= SELECT_ENABLE_WIRE_XOR(1) or SELECT_ENABLE_WIRE_XOR(0);
    TRUE_EN                            <= (not SELECT_ENABLE_WIRE_OR) and EN_I;

    -- Assign Clock Output
    DATA_O <= ENA_REG and DATACTRL;

end RTL;