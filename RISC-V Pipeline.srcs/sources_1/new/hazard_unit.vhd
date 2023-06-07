library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity hazard_unit is
Port (
    --ulazni signali
    rs1_address_id_i : in std_logic_vector(4 downto 0);
    rs2_address_id_i : in std_logic_vector(4 downto 0);
    rs1_in_use_i : in std_logic;
    rs2_in_use_i : in std_logic;
    branch_id_i : in std_logic;
    rd_address_ex_i : in std_logic_vector(4 downto 0);
    mem_to_reg_ex_i : in std_logic;
    rd_we_ex_i : in std_logic;
    rd_address_mem_i : in std_logic_vector(4 downto 0);
    mem_to_reg_mem_i : in std_logic;
    --izlazni kontrolni signali
    pc_en_o : out std_logic; -- signal dozvole rada za pc registar
    if_id_en_o : out std_logic; -- signal dozvole rada za if/id registar
    control_pass_o : out std_logic --kontrolise hoce li u execute fazu biti prosledjeni kontrolni signali iz ctrl_decodera ili sve nule
);
end hazard_unit;

architecture Behavioral of hazard_unit is

begin

process(branch_id_i, rs1_address_id_i, rd_address_ex_i, rs1_in_use_i, rs2_address_id_i, rs2_in_use_i, mem_to_reg_ex_i, rd_we_ex_i, rd_address_mem_i, mem_to_reg_mem_i)
begin
    pc_en_o <= '1';
    if_id_en_o <= '1';
    control_pass_o <= '1';
    
    if branch_id_i = '0' then
        if(((rs1_address_id_i = rd_address_ex_i and rs1_in_use_i = '1') or (rs2_address_id_i = rd_address_ex_i and rs2_in_use_i = '1')) and (mem_to_reg_ex_i = '1' and rd_we_ex_i = '1')) then
            --load instrukcija je u EX fazi
            pc_en_o <= '0';
            if_id_en_o <= '0';
            control_pass_o <= '0';
        end if;
    elsif branch_id_i = '1' then
    --instrukcija u ID fazi je uslovni skok(branch)
        if((rs1_address_id_i = rd_address_ex_i or rs2_address_id_i = rd_address_ex_i) and rd_we_ex_i = '1') then
            --load ili R-tip u EX fazi 
            pc_en_o <= '0';
            if_id_en_o <= '0';
            control_pass_o <= '0';
        elsif((rs1_address_id_i = rd_address_mem_i or rs2_address_id_i = rd_address_mem_i) and mem_to_reg_mem_i = '1') then
            --load u MEM fazi
            pc_en_o <= '0';
            if_id_en_o <= '0';
            control_pass_o <= '0'; 
        end if;
    end if;
    
end process;

end Behavioral;























