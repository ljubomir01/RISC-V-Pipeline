library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;

entity Alu is
Generic(WIDTH : positive:= 32);
Port (
    a_i : in std_logic_vector(WIDTH-1 downto 0);--prvi operand
    b_i : in std_logic_vector(WIDTH-1 downto 0);--drugi operand
    op_i : in std_logic_vector(4 downto 0);--port za izbor operacije
    res_o : out std_logic_vector(WIDTH-1 downto 0)--rezultat
);
end Alu;

architecture Behavioral of Alu is
    signal addition, subtraction : std_logic_vector(WIDTH downto 0);
begin
    addition <= ('0' & a_i) + ('0' & b_i);
    subtraction <= ('0' & a_i) - ('0' & b_i);
process(op_i, a_i, b_i, addition, subtraction)
begin
    case(op_i) is
        when "00000" => res_o <= a_i and b_i;--and operation
        when "00001" => res_o <= a_i or b_i;--or operation
        when "00010" => res_o <= addition(31 downto 0);--add
        when "00110" => res_o <= subtraction(31 downto 0);--sub
        when others => res_o <= (others => '0');
    end case;
end process;

end Behavioral;
