library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux4_to_1 is
Port (
    input_a : in std_logic_vector(31 downto 0);
    input_b : in std_logic_vector(31 downto 0);
    input_c : in std_logic_vector(31 downto 0);
    input_d : in std_logic_vector(31 downto 0);
    sel : in std_logic_vector(1 downto 0);
    output : out std_logic_vector(31 downto 0)
);
end mux4_to_1;

architecture Behavioral of mux4_to_1 is

begin
    with sel select
        output <= input_a when "00",
                  input_b when "01",
                  input_c when "10",
                  input_d when others;

end Behavioral;
