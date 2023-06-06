library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

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

architecture Behavioral of datapath is

    signal adder_s, imm_adder_s, pc_input_s, pc_output_s : std_logic_vector(31 downto 0); -- IF FAZA
    signal pc_output_s1, instr_id, rs1_data_s, rs2_data_s, rd_data_s, rd_data_mem, rd_data_wb : std_logic_vector(31 downto 0);
    signal rd_address_s : std_logic_vector(4 downto 0);
    signal rd_id, rd_ex, rd_mem : std_logic_vector(4 downto 0);
    signal mux1_wb, mux0_wb, immediate_s, muxa_id_s, muxb_id_s, rd_data_mem_s : std_logic_vector(31 downto 0);
    signal alu_res_s, rs1_data_s1, rs2_data_s1, immediate_s1, rs2_data_ex_mem, mux_a, mux_b, mux_ex : std_logic_vector(31 downto 0);
begin

--IF faza
--Mux1_pc
MUX_PC: process(pc_next_sel_i, adder_s, imm_adder_s) is
begin
    if pc_next_sel_i = '0' then
        pc_input_s <= adder_s;
    else
        pc_input_s <= imm_adder_s;
    end if;
end process;

adder_s <= std_logic_vector(unsigned(pc_output_s) + 4);
instr_mem_address_o <= pc_output_s;

PC: process(clk) is
begin
    if(rising_edge(clk)) then
        if(reset = '0') then
            pc_output_s <= (others => '0');
        else
            if(pc_en_i = '1') then
                pc_output_s <= pc_input_s;
            end if;
        end if;
    end if;
end process;

IF_ID_REG: process(clk) is
begin
    if(rising_edge(clk)) then
        if(reset = '0') then
            instr_id <= (others => '0');
            pc_output_s1 <= (others => '0');
        else
            if(if_id_en_i = '1') then
                if(if_id_flush_i = '1') then
                    instr_id <= (others => '0');
                    pc_output_s1 <= (others => '0');
                else
                    instr_id <= instr_mem_read_i;
                    pc_output_s1 <= pc_output_s;
                end if;
            end if;
        end if;
    end if;
end process;

instruction_o <= instr_id;

Registarska_banka: entity work.Register_bank(Behavioral)
port map(
    clk => clk,
    reset => reset,
    rs1_address_i => instr_id(19 downto 15),
    rs1_data_o => rs1_data_s,
    rs2_address_i => instr_id(24 downto 20),
    rs2_data_o => rs2_data_s,
    rd_we_i => rd_we_i,
    rd_address_i => rd_address_s,
    rd_data_i => rd_data_s
);
rd_id <= instr_id(11 downto 7);

Immediate: entity work.Immediate(Behavioral)
port map(
    instruction_i => instr_id,
    immediate_extended_o => immediate_s
);

imm_adder_s <= std_logic_vector(unsigned(pc_output_s1) + unsigned(shift_left(unsigned(immediate_s), 1)));

muxa_id_s <= rs1_data_s when branch_forward_a_i = '0' else
             rd_data_mem_s;
muxb_id_s <= rs2_data_s when branch_forward_b_i = '0' else
             rd_data_mem_s;
branch_condition_o <= '0' when muxa_id_s /= muxb_id_s else
                      '1';

ID_EX: process(clk) is
begin
    if(rising_edge(clk)) then
        if(reset = '0') then
            rs1_data_s1 <= (others => '0');
            rs2_data_s1 <= (others => '0');
            immediate_s1 <= (others => '0');
            rd_ex <= (others => '0');
            rs2_data_ex_mem <= (others => '0');
        else
            rs1_data_s1 <= rs1_data_s;
            rs2_data_s1 <= rs2_data_s;
            immediate_s1 <= immediate_s;
            rd_ex <= rd_id;
            rs2_data_ex_mem <= rs2_data_s;
        end if;
    end if;
end process;

MUXA_ALU_EX: process(alu_forward_a_i, rs1_data_s1, rd_data_wb, rd_data_mem)
begin
    if(alu_forward_a_i = "00")then
        mux_a <= rs1_data_s1;
    elsif(alu_forward_a_i = "01") then
        mux_a <= rd_data_wb;
    elsif(alu_forward_a_i = "10") then
        mux_a <= rd_data_mem;
    else
        mux_a <= (others => '0');
    end if;
end process;

MUXB_EX: process(alu_forward_b_i, rs2_data_s1, rd_data_wb, rd_data_mem) is
begin
    if(alu_forward_b_i = "00")then
        mux_ex <= rs2_data_s1;
    elsif(alu_forward_b_i = "01") then
        mux_ex <= rd_data_wb;
    elsif(alu_forward_b_i = "10") then
        mux_ex <= rd_data_mem;
    else
        mux_ex <= (others => '0');
    end if;
end process;

mux_b <= mux_ex when alu_src_b_i = '0' else
         immediate_s1;

ALU: entity work.ALU(Behavioral)
port map(
    a_i => mux_a,
    b_i => mux_b,
    op_i => alu_op_i, 
    res_o => alu_res_s
);

EX_MEM: process(clk) is
begin
    if(rising_edge(clk)) then
        if(reset = '0') then
            rd_data_mem <= (others => '0');
            rd_mem <= (others => '0');
            data_mem_write_o <= (others => '0');
        else
            rd_data_mem <= alu_res_s;
            rd_mem <= rd_ex;
            data_mem_write_o <= rs2_data_ex_mem;
        end if;
    end if;
end process;

data_mem_address_o <= rd_data_mem;

MEM_WB: process(clk) is
begin
    if(rising_edge(clk)) then
        if(reset = '0') then
            mux1_wb <= (others => '0');
            mux0_wb <= (others => '0');
            rd_address_s <= (others => '0');
        else
            mux1_wb <= data_mem_read_i;
            mux0_wb <= rd_data_mem;
            rd_address_s <= rd_mem;
        end if;
    end if;
end process;

rd_data_wb <= mux0_wb when mem_to_reg_i = '0' else
              mux1_wb;
rd_data_s <= rd_data_wb;




end Behavioral;
