library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity comparator is
Port (
    input_a : in std_logic_vector(31 downto 0);
    input_b : in std_logic_vector(31 downto 0);
    is_equal : out std_logic
);
end comparator;

architecture Behavioral of comparator is

begin
process(input_a, input_b)
begin
    if input_a = input_b then
        is_equal <= '1';
    else
        is_equal <= '0';
    end if;
end process;

end Behavioral;
