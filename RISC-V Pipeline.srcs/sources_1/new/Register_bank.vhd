library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Register_bank is
Generic(WIDTH : positive := 32);
Port (
    clk : in std_logic;
    reset : in std_logic;
    --Interfejs 1 za citanje podataka
    rs1_address_i : in std_logic_vector(4 downto 0);
    rs1_data_o : out std_logic_vector(WIDTH - 1 downto 0);
    --Interfejs 2 za citanje podataka
    rs2_address_i : in std_logic_vector(4 downto 0);
    rs2_data_o : out std_logic_vector(WIDTH - 1 downto 0);
    --Interfejs za upis podataka
    rd_we_i : in std_logic;
    rd_address_i : in std_logic_vector(4 downto 0);
    rd_data_i : in std_logic_vector(WIDTH - 1 downto 0)
);
end Register_bank;

architecture Behavioral of Register_bank is
    type instruction_memory is array(0 to 31) of std_logic_vector(WIDTH-1 downto 0);
    signal registers : instruction_memory := (others => (others => '0'));
begin

process(clk, reset)
begin
    if falling_edge(clk) then
        if reset = '0' then
            registers <= (others => (others => '0'));
        else
            if rd_we_i = '1' and rd_address_i /= "00000" then
                registers(TO_INTEGER(unsigned(rd_address_i))) <= rd_data_i;
            end if;
        end if;
    end if;
end process;

    rs1_data_o <= registers(TO_INTEGER(unsigned(rs1_address_i)));
    rs2_data_o <= registers(TO_INTEGER(unsigned(rs2_address_i)));

end Behavioral;
