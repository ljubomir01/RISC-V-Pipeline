library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.all;

entity datapath is
Port (
    --sinhronizacioni signali
    clk : in std_logic;
    reset : in std_logic;
    --interfejs ka memoriji za instrukcije
    instr_mem_address_o : out std_logic_vector(31 downto 0);
    instr_mem_read_i : in std_logic_vector(31 downto 0);
    instruction_o : out std_logic_vector(31 downto 0);
    --interfejs ka memoriji za podatke
    data_mem_address_o : out std_logic_vector(31 downto 0);
    data_mem_write_o : out std_logic_vector(31 downto 0);
    data_mem_read_i : in std_logic_vector(31 downto 0);
    --kontrolni signali
    mem_to_reg_i : in std_logic;
    alu_op_i : in std_logic_vector(4 downto 0);
    alu_src_b_i : in std_logic;
    pc_next_sel_i : in std_logic;
    rd_we_i : in std_logic;
    branch_condition_o : out std_logic;
    --kontrolni signali za prosledjivanje operanada u ranije faze protocne obrade
    alu_forward_a_i : in std_logic_vector(1 downto 0);
    alu_forward_b_i : in std_logic_vector(1 downto 0);
    branch_forward_a_i : in std_logic;
    branch_forward_b_i : in std_logic;
    --kontrolni signal za resetovanje if/id registra
    if_id_flush_i : in std_logic;
    --kontrolni signal za zaustavljanje protocne obrade
    pc_en_i : in std_logic;
    if_id_en_i : in std_logic
);
end datapath;

architecture Struct of datapath is
    signal next_instruction_s : std_logic_vector(31 downto 0);
    signal pc_register_s, pc_register_s_1 : std_logic_vector(31 downto 0);
    signal const : std_logic_vector(31 downto 0):= X"00000004";
    signal rs1_address_id_s, rs2_address_id_s, rd_address_id_s : std_logic_vector(4 downto 0);
    signal rd_data_s, rs1_data_s, rs2_data_s, rs1_data_s_1, rs2_data_s_1, rs2_data_s_2, rd_address_s : std_logic_vector(31 downto 0);
    signal pc_input_b_s, pc_input_b_s_1 : std_logic_vector(31 downto 0);
    signal instruction_o_s, instruction_o_s_1, instruction_o_s_2, instruction_o_s_3 : std_logic_vector(31 downto 0);
    signal immediate_shift, immediate_s, immediate_s_1 : std_logic_vector(31 downto 0);
    signal comparator_a, comparator_b : std_logic_vector(31 downto 0);
    signal alu_address_s, alu_input_a_s, alu_input_b_s, alu_input_b, alu_res, alu_address_s_1 : std_logic_vector(31 downto 0);
    signal data_mem_write_o_s, data_mem_write_o_s_1 : std_logic_vector(31 downto 0);
begin
    instruction_o_s <= instr_mem_read_i;
    instruction_o <= instruction_o_s_1;
Next_Instruction:
    entity work.adder(Behavioral)
        port map(
            input_a => pc_register_s,
            input_b => const,
            output => next_instruction_s
        );
Program_Counter:
    entity work.program_counter(Behavioral)
        port map(
            en => pc_en_i,
            clear => '0',
            clk => clk,
            sel => pc_next_sel_i,
            input_a => next_instruction_s,
            input_b => pc_input_b_s,
            output => pc_register_s
        );
    instr_mem_address_o <= pc_register_s;
IF_ID_REG1:
    entity work.reg32b_if_id(Behavioral)
        port map(
            load => if_id_en_i,
            clk => clk,
            input => instruction_o_s,
            flush => if_id_flush_i,
            clear => reset,
            output => instruction_o_s_1
        );
IF_ID_REG2: 
    entity work.reg32b_if_id(Behavioral)
        port map(
            load => if_id_en_i,
            clk => clk,
            flush => if_id_flush_i,
            input => pc_register_s,
            clear => reset,
            output => pc_register_s_1
        );
Register_Bank:
    entity work.register_bank(Behavioral)
    Generic map(WIDTH => 32)
    port map(
        clk => clk,
        reset => reset,
        rs1_address_i => instruction_o_s(19 downto 15),
        rs2_address_i => instruction_o_s(24 downto 20),
        rd_address_i => rd_address_s(11 downto 7),
        rd_data_i => rd_data_s,
        rd_we_i => rd_we_i,
        rs1_data_o => rs1_data_s,
        rs2_data_o => rs2_data_s
    );
Immediate:
    entity work.Immediate(Behavioral)
    port map(
        instruction_i => instruction_o_s,
        immediate_extended_o => immediate_s
    );
    immediate_shift <= immediate_s(30 downto 0) & '0';
Add_Immediate:
    entity work.adder(Behavioral)
    port map(
        input_a => immediate_shift,
        input_b => pc_register_s_1,
        output => pc_input_b_s
    );
comparator_a_input:
    entity work.mux2_to_1(Behavioral)
    port map(
        input_a => rs1_data_s,
        input_b => rd_data_s,
        output => comparator_a,
        sel => branch_forward_a_i
);
comparator_b_input:
    entity work.mux2_to_1(Behavioral)
    port map(
        input_a => rs2_data_s,
        input_b => rd_data_s,
        output => comparator_b,
        sel => branch_forward_b_i
);
comp:
    entity work.comparator(Behavioral)
    port map(
        input_a => comparator_a,
        input_b => comparator_b,
        is_equal => branch_condition_o
    );
ID_EX1:
    entity work.register32b(Behavioral)
    port map(
        load => '1',
        clk => clk,
        clear => reset,
        input => rs1_data_s,
        output => rs1_data_s_1
    );
ID_EX2:
    entity work.register32b(Behavioral)
    port map(
        load => '1',
        clk => clk,
        clear => reset,
        input => rs2_data_s,
        output => rs2_data_s_1
    );
ID_EX3:
    entity work.register32b(Behavioral)
    port map(
        load => '1',
        clk => clk,
        clear => reset,
        input => immediate_s,
        output => immediate_s_1
    );
ID_EX4:
    entity work.register32b(Behavioral)
    port map(
        load => '1',
        clk => clk,
        clear => reset,
        input => instruction_o_s_1,
        output => instruction_o_s_2
    );
Mux4_first:
    entity work.mux4_to_1(Behavioral)
    port map(
        sel => alu_forward_a_i,
        input_a => rs1_data_s_1,
        input_b => rd_data_s,
        input_c => alu_address_s,
        input_d => X"00000000",
        output => alu_input_a_s
    );
Mux4_second:
    entity work.mux4_to_1(Behavioral)
    port map(
        sel => alu_forward_b_i,
        input_a => rs2_data_s_1,
        input_b => rd_data_s,
        input_c => alu_address_s,
        input_d => X"00000000",
        output => alu_input_b
    );
mux2_alu:
    entity work.mux2_to_1(Behavioral)
    port map(
        input_a => alu_input_b,
        input_b => immediate_s_1,
        output => alu_input_b_s,
        sel => alu_src_b_i
    );
ALU:
    entity work.Alu(Behavioral)
    Generic map(WIDTH => 32)
    port map(
        a_i => alu_input_a_s,
        b_i => alu_input_b_s,
        op_i => alu_op_i,
        res_o => alu_res
    );
EX_MEM_REG1:
    entity work.register32b(Behavioral)
    port map(
        clk => clk,
        load => '1',
        clear => reset,
        input => alu_res,
        output => alu_address_s
    );
EX_MEM_REG2:
    entity work.register32b(Behavioral)
    port map(
        clk => clk,
        load => '1',
        clear => reset,
        input => rs2_data_s_1,
        output => rs2_data_s_2
    );
EX_MEM_REG3:
    entity work.register32b(Behavioral)
    port map(
        clk => clk,
        load => '1',
        clear => reset,
        input => instruction_o_s_2,
        output => instruction_o_s_3
    );
    data_mem_address_o <= alu_address_s;
    data_mem_write_o <= rs2_data_s_2;
MEM_WB_REG1:
    entity work.register32b(Behavioral)
    port map(
        clk => clk,
        clear => reset,
        load => '1',
        input => alu_address_s,
        output => alu_address_s_1
    );
MEM_WB_REG2:
    entity work.register32b(Behavioral)
    port map(
        clk => clk,
        clear => reset,
        load => '1',
        input => instruction_o_s_3,
        output => rd_address_s
    );
    data_mem_write_o_s <= data_mem_read_i;
MEM_WB_REG3:
    entity work.register32b(Behavioral)
    port map(
        clk => clk,
        clear => reset,
        load => '1',
        input => data_mem_write_o_s,
        output => data_mem_write_o_s_1
    );
MUX_MEM:
    entity work.mux2_to_1(Behavioral)
    port map(
        input_a => alu_address_s_1,
        input_b => data_mem_write_o_s_1,
        output => rd_data_s,
        sel => mem_to_reg_i
    );
end Struct;
