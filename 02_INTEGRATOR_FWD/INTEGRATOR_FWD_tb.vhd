library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;

entity INTEGRATOR_FWD_tb is
end INTEGRATOR_FWD_tb;

architecture sim of INTEGRATOR_FWD_tb is
    component INTEGRATOR_FWD
        generic (
            DATA_Bit_Length: natural := 32
        );

        port (
            -- Input
            CLK_I  :   in  std_logic;
            DATA_I :  in  std_logic_vector (DATA_Bit_Length-1 downto 0);

            -- Output
            DATA_O :  buffer std_logic_vector (DATA_Bit_Length-1 downto 0);
            OFDET_O: out std_logic;
            UFDET_O: out std_logic
        );
    end component;

    signal CLK_I  : std_logic := '0';
    signal DATA_I : std_logic_vector (5 downto 0) := (others => '0');

    signal DATA_O : std_logic_vector(5 downto 0);
    signal OFDET_O: std_logic;
    signal UFDET_O: std_logic;

begin

    dut: INTEGRATOR_FWD 
    GENERIC map(
	DATA_Bit_Length => 6
    )
    PORT map(
        CLK_I => CLK_I,
        DATA_I => DATA_I,
        DATA_O => DATA_O,
        OFDET_O => OFDET_O,
        UFDET_O => UFDET_O
    );

    CLK_I <= not CLK_I after 10 ns;
    
    process begin
        wait for 2000 ns;
        DATA_I <= "000001";
        wait for 2000 ns;
        DATA_I <= "111111";
        wait for 2000 ns;
    end process;

end sim;