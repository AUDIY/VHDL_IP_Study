library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity CLKMUX4_NOGLITCH_tb is
end CLKMUX4_NOGLITCH_tb;

architecture sim of CLKMUX4_NOGLITCH_tb is
    component CLKMUX4_NOGLITCH
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
    end component;

    signal DATA3_I: std_logic := '0';
    signal DATA2_I: std_logic := '0';
    signal DATA1_I: std_logic := '0';
    signal DATA0_I: std_logic := '0';

    signal SEL_I: std_logic_vector (1 downto 0) := (others => '0');
    signal EN_I : std_logic := '1';

    signal DATA_O: std_logic;
begin
    
    dut: CLKMUX4_NOGLITCH
    port map(
        DATA3_I => DATA3_I,
        DATA2_I => DATA2_I,
        DATA1_I => DATA1_I,
        DATA0_I => DATA0_I,
        SEL_I => SEL_I,
        EN_I => EN_I,
        DATA_O => DATA_O
    );

    DATA3_I <= not DATA3_I after 1 ns;
    DATA2_I <= not DATA2_I after 3 ns;
    DATA1_I <= not DATA1_I after 5 ns;
    DATA0_I <= not DATA0_I after 7 ns;

    SEL_I <= SEL_I + "01" after 211 ns;

    process begin
        wait for 197 ns;
        EN_I <= not EN_I;
        wait for 16 ns;
        EN_I <= not EN_I;
    end process;

end sim;