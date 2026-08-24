library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MainControl is
    port(
        Instr     : in  STD_LOGIC_VECTOR(31 downto 0);
        RegDst    : out STD_LOGIC;
        ExtOp     : out STD_LOGIC;
        ALUSrc    : out STD_LOGIC;
        BranchEQ  : out STD_LOGIC;
        BranchNE  : out STD_LOGIC;
        Jump      : out STD_LOGIC;
        ALUOp     : out STD_LOGIC_VECTOR(2 downto 0);
        MemWrite  : out STD_LOGIC;
        MemtoReg  : out STD_LOGIC;
        RegWrite  : out STD_LOGIC
    );
end MainControl;

architecture Behavioral of MainControl is
    signal opcode: std_logic_vector(5 downto 0);
begin

    opcode <= Instr(31 downto 26);

    process(opcode)
    begin
        RegDst   <= '0';
        ExtOp    <= '0';
        ALUSrc   <= '0';
        BranchEQ <= '0';
        BranchNE <= '0';
        Jump     <= '0';
        MemWrite <= '0';
        MemtoReg <= '0';
        RegWrite <= '0';
        ALUOp    <= "000";

        case opcode is
            -- Tip R
            when "000000" =>
                RegDst   <= '1';
                RegWrite <= '1';
                ALUOp    <= "111";

            -- ADDI
            when "001000" =>
                ExtOp    <= '1';
                ALUSrc   <= '1';
                RegWrite <= '1';
                ALUOp    <= "000"; -- +

            -- ANDI
            when "001100" =>
                ExtOp    <= '0';
                ALUSrc   <= '1';
                RegWrite <= '1';
                ALUOp    <= "010"; -- &

            -- SLTI
            when "001010" =>
                ExtOp    <= '1';
                ALUSrc   <= '1';
                RegWrite <= '1';
                ALUOp    <= "011";

            -- LW
            when "100011" =>
                ExtOp    <= '1';
                ALUSrc   <= '1';
                MemtoReg <= '1';
                RegWrite <= '1';
                ALUOp    <= "000"; -- +

            -- SW
            when "101011" =>
                ExtOp    <= '1';
                ALUSrc   <= '1';
                MemWrite <= '1';
                ALUOp    <= "000"; -- +

            -- BEQ
            when "000100" =>
                ExtOp    <= '1';
                BranchEQ <= '1';
                ALUOp    <= "001"; -- -

            -- BNE
            when "000101" =>
                ExtOp    <= '1';
                BranchNE <= '1';
                ALUOp    <= "001"; -- -

            -- J
            when "000010" =>
                Jump     <= '1';

            when others =>
                null;
        end case;
    end process;

end Behavioral;
