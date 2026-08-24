library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ExecutionUnit is
    Port (
        PCinc    : in  STD_LOGIC_VECTOR(31 downto 0);
        RD1      : in  STD_LOGIC_VECTOR(31 downto 0);
        RD2      : in  STD_LOGIC_VECTOR(31 downto 0);
        Ext_Imm  : in  STD_LOGIC_VECTOR(31 downto 0);
        func     : in  STD_LOGIC_VECTOR(5 downto 0);
        sa       : in  STD_LOGIC_VECTOR(4 downto 0);
        ALUSrc   : in  STD_LOGIC;
        ALUOp    : in  STD_LOGIC_VECTOR(2 downto 0);
        BranchAddress : out STD_LOGIC_VECTOR(31 downto 0);
        ALURes   : out STD_LOGIC_VECTOR(31 downto 0);
        Zero     : out STD_LOGIC
    );
end ExecutionUnit;

architecture Behavioral of ExecutionUnit is
    signal ALUCtrl: std_logic_vector(2 downto 0);
    signal ALUIn2: std_logic_vector(31 downto 0);
    signal ALUResInt: std_logic_vector(31 downto 0);
begin

    process(ALUOp, func)
    begin
        case ALUOp is
            when "111" => -- Tip R
                case func is
                    when "100000" => ALUCtrl <= "000"; -- ADD
                    when "100010" => ALUCtrl <= "001"; -- SUB
                    when "101010" => ALUCtrl <= "111"; -- SLT
                    when "011000" => ALUCtrl <= "010"; -- MULT
                    when others => ALUCtrl <= "000";
                end case;
            when "000" => ALUCtrl <= "000"; -- +
            when "001" => ALUCtrl <= "001"; -- -
            when "010" => ALUCtrl <= "100"; -- &
            when "011" => ALUCtrl <= "111"; -- SLTI
            when others => ALUCtrl <= (others => 'X');
        end case;
    end process;

    ALUIn2 <= RD2 when ALUSrc = '0' else
              Ext_Imm when ALUSrc = '1' else 
              (others => 'X');

    process (ALUCtrl, RD1, ALUIn2, sa)
    begin
        case ALUCtrl is
            when "000" => -- ADD
                ALUResInt <= RD1 + ALUIn2;
            when "001" => -- SUB
                ALUResInt <= RD1 - ALUIn2;
            
            when "010" => -- MULT (limitari de operatie)
                ALUResInt <= RD1(15 downto 0) * ALUIn2(15 downto 0);

            when "100" => -- AND
                ALUResInt <= RD1 and ALUIn2;
            -- when "101" => -- OR
            --     ALUResInt <= RD1 or ALUIn2; 
            -- when "110" => -- XOR
            --     ALUResInt <= RD1 xor ALUIn2; 
            when "111" => -- SLT
                if RD1 < ALUIn2 then
                    ALUResInt <= x"0000_0001";
                else
                    ALUResInt <= x"0000_0000";
                end if;
            when others => ALUResInt <= (others => 'X');
        end case;
    end process;

    Zero <= '1' when ALUResInt = x"0000_0000" else '0';

    -- BranchAddress <= PCinc + (Ext_Imm(29 downto 0) & "00");
    BranchAddress <= PCinc + Ext_Imm;
    
    ALURes <= ALUResInt;
end Behavioral;
