library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity adder is
Port (
    input_a : in std_logic_vector(31 downto 0);
    input_b : in std_logic_vector(31 downto 0);
    output : out std_logic_vector(31 downto 0)
);
end adder;

architecture Behavioral of adder is
    signal output_temp : std_logic_vector(32 downto 0) := (others => '0');
begin
    output_temp <= std_logic_vector(signed(input_a(31) & input_a) + signed(input_b(31) & input_b));
    output <= output_temp(31 downto 0);

end Behavioral;
