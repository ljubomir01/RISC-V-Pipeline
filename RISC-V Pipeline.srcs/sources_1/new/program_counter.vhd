library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity program_counter is
Port (
    clear : in std_logic;
    clk : in std_logic;
    sel : in std_logic;
    en : in std_logic;
    input_a, input_b : in std_logic_vector(31 downto 0);
    output : out std_logic_vector(31 downto 0)
);
end program_counter;

architecture Behavioral of program_counter is
    signal address_temp : std_logic_vector(31 downto 0) := X"00000000";
begin
pc_mux: entity work.mux2_to_1(Behavioral)
    port map(
        input_a => input_a,--next_instruction_s
        input_b => input_b,--from IF_ID_reg
        sel => sel, 
        output => address_temp
    );
pc_reg: entity work.register32b(Behavioral)
    port map(
        clk => clk,
        clear => clear,
        load => en,
        input => address_temp, 
        output => output
    );
end Behavioral;
