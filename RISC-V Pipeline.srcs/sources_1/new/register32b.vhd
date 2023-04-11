library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity register32b is
Port (
    input : in std_logic_vector(31 downto 0);
    load, clk, clear : in std_logic;
    output : out std_logic_vector(31 downto 0)
);
end register32b;

architecture Behavioral of register32b is
    signal reg_temp : std_logic_vector(31 downto 0) := X"00000000";
begin
process (clk)
	begin
	   if(clk'event and clk = '1') then
	       if(clear = '0') then
	           reg_temp <= X"00000000";       
	       elsif load = '1' then
	           reg_temp <= input;
	       else
	           reg_temp <= reg_temp;
	       end if;
	       
	   end if;
	end process;

end Behavioral;
