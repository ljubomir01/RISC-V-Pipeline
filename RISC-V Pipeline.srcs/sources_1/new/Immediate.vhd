library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity Immediate is
Port (
    instruction_i : in std_logic_vector(31 downto 0);
    immediate_extended_o : out std_logic_vector(31 downto 0)
);
end Immediate;

architecture Behavioral of Immediate is
    signal opcode : std_logic_vector(6 downto 0);
    signal ITypeImmediate, STypeImmediate, SBTypeImmediate, UTypeImmediate : std_logic_vector(31 downto 0);
    signal immediate_temp : std_logic_vector(31 downto 0);
begin
    opcode <= instruction_i(6 downto 0);
    
    process(opcode, STypeImmediate, ITypeImmediate, SBTypeImmediate)
    begin
        case opcode is
            when "0100011" => immediate_temp <= STypeImmediate;
            when "0000011" => immediate_temp <= ITypeImmediate;
            when "0010011" => immediate_temp <= SBTypeImmediate;
            when "0110111" => immediate_temp <= UTypeImmediate; --LUI
            when others => immediate_temp <= (others => '0');
        end case;
    end process;
    
    STypeImmediate <= X"00000" & instruction_i(31 downto 25) & instruction_i(11 downto 7) when instruction_i(31) = '0' else 
    (X"FFFFF" & instruction_i(31 downto 25) & instruction_i(11 downto 7));
    ITypeImmediate <= X"00000" & instruction_i(31 downto 20) when instruction_i(31) = '0' else (X"FFFFF" & instruction_i(31 downto 20));
    SBTypeImmediate <= X"00000" & instruction_i(31) & instruction_i(7) & instruction_i(30 downto 25) & instruction_i(11 downto 8) when instruction_i(31) = '0' else
    (X"FFFFF" & instruction_i(31) & instruction_i(7) & instruction_i(30 downto 25) & instruction_i(11 downto 8));
    UtypeImmediate  <= X"000" & instruction_i(31 downto 12) when instruction_i(31) = '0' else X"FFF" & instruction_i(31 downto 12);
    
    immediate_extended_o <= immediate_temp;
end Behavioral;
