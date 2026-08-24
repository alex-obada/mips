library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity IFetch is
    Port ( clk : in STD_LOGIC;
           en : in STD_LOGIC;
           rst : in STD_LOGIC;
           jumpAddr : in STD_LOGIC_VECTOR (31 downto 0);
           branchAddr : in STD_LOGIC_VECTOR (31 downto 0);
           jumpFlag : in STD_LOGIC;
           PCSrc : in STD_LOGIC;
           PCinc : out STD_LOGIC_VECTOR (31 downto 0);
           instruction : out STD_LOGIC_VECTOR (31 downto 0));
end IFetch;

architecture Behavioral of IFetch is
    type tROM is array(0 to 255) of std_logic_vector(31 downto 0);

    constant ROM: tROM := (
        B"100011_00000_00001_0000000000000000", -- X"8C010000" -- lw $1, 0($0)
        B"001010_00001_00011_0000000000000010", -- X"28230002" -- slti $3, $1, 2
        B"000101_00011_00000_0000000000010010", -- X"14600012" -- bne $3, $0, 18
        B"001000_00000_00100_0000000000000010", -- X"20040002" -- addi $4, $0, 2
        B"000100_00001_00100_0000000000001110", -- X"1024000E" -- beq $1, $4, 14
        B"001100_00001_00011_0000000000000001", -- X"30230001" -- andi $3, $1, 1
        B"000100_00011_00000_0000000000001110", -- X"1060000E" -- beq $3, $0, 14
        B"001000_00000_00101_0000000000000011", -- X"20050003" -- addi $5, $0, 3
        B"000000_00101_00101_00110_00000_011000", -- X"00A53018" -- mult $6, $5, $5
        B"000000_00001_00110_00011_00000_101010", -- X"0026182A" -- slt $3, $1, $6
        B"000101_00011_00000_0000000000001000", -- X"14600008" -- bne $3, $0, 8
        B"000000_00000_00001_00111_00000_100000", -- X"00013820" -- add $7, $0, $1
        B"000000_00111_00101_00011_00000_101010", -- X"00E5182A" -- slt $3, $7, $5
        B"000101_00011_00000_0000000000000010", -- X"14600002" -- bne $3, $0, 2
        B"000000_00111_00101_00111_00000_100010", -- X"00E53822" -- sub $7, $7, $5
        B"000010_00000000000000000000001100", -- X"0800000C" -- j 12
        B"000100_00111_00000_0000000000000100", -- X"10E00004" -- beq $7, $0, 4
        B"001000_00101_00101_0000000000000010", -- X"20A50002" -- addi $5, $5, 2
        B"000010_00000000000000000000001000", -- X"08000008" -- j 8
        B"001000_00000_00010_0000000000000001", -- X"20020001" -- addi $2, $0, 1
        B"000010_00000000000000000000010110", -- X"08000016" -- j 22
        B"000000_00000_00000_00010_00000_100000", -- X"00001020" -- add $2, $0, $0
        B"101011_00000_00010_0000000000000100", -- X"AC020004" -- sw $2, 4($0)
        B"100011_00000_00010_0000000000000100", -- X"8C020004" -- lw $2, 4($0)
        B"000010_00000000000000000000011000", -- X"08000018" -- j 24
        others => x"0000_0000"
    );

    signal PC : std_logic_vector(31 downto 0);
    signal PCNext : std_logic_vector(31 downto 0);

    signal MUX1_OUT : std_logic_vector(31 downto 0);
begin

    process(clk, rst)
    begin
        if rst = '1' then
            PC <= x"0000_0000";
        elsif rising_edge(clk) then
            if en = '1' then
                PC <= PCNext;
            end if;
        end if;
    end process;

    instruction <= ROM(conv_integer(PC(7 downto 0)));

    PCinc <= PC + 1;

    MUX1_OUT <= PC + 1 when PCSrc = '0' else branchAddr;
    PCNext <= MUX1_OUT when jumpFlag = '0' else jumpAddr;

end Behavioral;
