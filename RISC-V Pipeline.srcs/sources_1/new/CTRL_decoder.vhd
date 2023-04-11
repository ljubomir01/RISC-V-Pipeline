library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity CTRL_decoder is
Port (
    --opcode instrukcije
    opcode_i : in std_logic_vector(6 downto 0);
    --kontrolni signali
    branch_o : out std_logic;
    mem_to_reg_o : out std_logic;
    data_mem_we_o : out std_logic;
    alu_src_b_o : out std_logic;
    rd_we_o : out std_logic;
    rs1_in_use_o : out std_logic;
    rs2_in_use_o : out std_logic;
    alu_2bit_op_o : out std_logic_vector(1 downto 0)
);
end CTRL_decoder;

architecture Behavioral of CTRL_decoder is

begin
process(opcode_i)
begin
    case opcode_i is
        when "0110011" =>
            alu_src_b_o <= '0';
            mem_to_reg_o <= '0';
            rd_we_o <= '1';
            data_mem_we_o <= '0';
            branch_o <= '0';
            alu_2bit_op_o <= "10";
            rs1_in_use_o <= '1';
            rs2_in_use_o <= '1';
        when "0000011" =>
            alu_src_b_o <= '1';
            mem_to_reg_o <= '1';
            rd_we_o <= '1';
            data_mem_we_o <= '0';
            branch_o <= '0';
            alu_2bit_op_o <= "00";
            rs1_in_use_o <= '1';
            rs2_in_use_o <= '0';
        when "0100011" =>
            alu_src_b_o <= '1';
            mem_to_reg_o <= '0';
            rd_we_o <= '0';
            data_mem_we_o <= '1';
            branch_o <= '0';
            alu_2bit_op_o <= "00";
            rs1_in_use_o <= '1';
            rs2_in_use_o <= '1';
        when "1100011" =>
            alu_src_b_o <= '0';
            mem_to_reg_o <= '0';
            rd_we_o <= '0';
            data_mem_we_o <= '0';
            branch_o <= '1';
            alu_2bit_op_o <= "01";
            rs1_in_use_o <= '1';
            rs2_in_use_o <= '1';
        when "0010011" =>
            alu_src_b_o <= '1';
            mem_to_reg_o <= '0';
            rd_we_o <= '1';
            data_mem_we_o <= '0';
            branch_o <= '0';
            alu_2bit_op_o <= "11";
            rs1_in_use_o <= '1';
            rs2_in_use_o <= '0';
        when "0110111" =>
            alu_src_b_o <= '1';
            mem_to_reg_o <= '1';
            rd_we_o <= '1';
            data_mem_we_o <= '0';
            branch_o <= '0';
            alu_2bit_op_o <= "00";
            rs1_in_use_o <= '0';
            rs2_in_use_o <= '0';
        when others =>
    end case;
end process;

end Behavioral;
