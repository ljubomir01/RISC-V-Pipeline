library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity reg32b_if_id is
Port (
    input : in std_logic_vector(31 downto 0);
    load, clk, clear, flush : in std_logic;
    output : out std_logic_vector(31 downto 0)
);
end reg32b_if_id;

architecture Behavioral of reg32b_if_id is
    signal reg_temp : std_logic_vector(31 downto 0) := X"00000000";
begin
process (clk)
	begin
	   if(clk'event and clk = '1') then
	       if(clear = '0' or flush = '1') then
	           reg_temp <= X"00000000";  
	       elsif load = '1' then
	           reg_temp <= input;
	       else
	           reg_temp <= reg_temp;
	       end if;
	       
	   end if;
	end process;

end Behavioral;
