library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU_decoder is
Port (
    --ControlPath ulazi
    alu_2bit_op_i : in std_logic_vector(1 downto 0);
    --polja instrukcije
    funct3_i : in std_logic_vector(2 downto 0);
    funct7_i : in std_logic_vector(6 downto 0);
    --Datapath izlazi
    alu_op_o : out std_logic_vector(4 downto 0)
);
end ALU_decoder;

architecture Behavioral of ALU_decoder is

begin

process(alu_2bit_op_i, funct3_i, funct7_i)
begin
    if alu_2bit_op_i(1) = '1' and funct7_i = "0000000" and funct3_i = "110" then
        alu_op_o <= "00001";
    elsif alu_2bit_op_i(1) = '1' and funct7_i = "0000000" and funct3_i = "111" then
        alu_op_o <= "00000";
    elsif alu_2bit_op_i(1) = '1' and funct7_i = "0100000" and funct3_i = "000" then
        alu_op_o <= "00110";
    elsif alu_2bit_op_i(1) = '1' and funct7_i = "0000000" and funct3_i = "000" then
        alu_op_o <= "00010";
    elsif alu_2bit_op_i(0) = '1' then
        alu_op_o <= "00110";
    elsif alu_2bit_op_i = "00" then
        alu_op_o <= "00010";
    else
    end if;
end process;

end Behavioral;
