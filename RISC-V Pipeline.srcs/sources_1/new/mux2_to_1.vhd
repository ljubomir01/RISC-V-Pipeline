library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mux2_to_1 is
Port (
    input_a : in std_logic_vector(31 downto 0);
    input_b : in std_logic_vector(31 downto 0);
    sel : in std_logic;
    output : out std_logic_vector(31 downto 0)
);
end mux2_to_1;

architecture Behavioral of mux2_to_1 is
begin
    with sel select
        output <= input_a when '0',
                  input_b when others;

end Behavioral;
