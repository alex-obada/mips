library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity IDecode is
    port(
        clk      : in  STD_LOGIC;
        en       : in  STD_LOGIC;
        Instr    : in  STD_LOGIC_VECTOR(31 downto 0);
        WD       : in  STD_LOGIC_VECTOR(31 downto 0);
        RegWrite : in  STD_LOGIC;
        RegDst   : in  STD_LOGIC;
        ExtOp    : in  STD_LOGIC;
        RD1      : out STD_LOGIC_VECTOR(31 downto 0);
        RD2      : out STD_LOGIC_VECTOR(31 downto 0);
        Ext_Imm  : out STD_LOGIC_VECTOR(31 downto 0);
        func     : out STD_LOGIC_VECTOR(5 downto 0);
        sa       : out STD_LOGIC_VECTOR(4 downto 0)
    );
end IDecode;

architecture Behavioral of IDecode is
    type tRAM is array(0 to 31) of std_logic_vector(31 downto 0);
    signal RF: tRAM := (
        x"0000_0000",
        others => x"0000_0000"
    );

    signal RA1, RA2, WA : std_logic_vector(4 downto 0);

begin

    -- rf
    RA1 <= Instr(25 downto 21); -- rs
    RA2 <= Instr(20 downto 16); -- rt

            --rd
    WA <= Instr(15 downto 11) when RegDst = '1' else 
          Instr(20 downto 16); -- rt
    
    RD1 <= RF(conv_integer(RA1));
    RD2 <= RF(conv_integer(RA2));
    
    process(clk)
    begin 
        if rising_edge(clk) then
            if RegWrite = '1' and en = '1' and WA /= "00000" then
                RF(conv_integer(WA)) <= WD;
            end if;
        end if;
    end process;


    -- ext_imm
    Ext_Imm(15 downto 0) <= Instr(15 downto 0);
    Ext_Imm(31 downto 16) <= (others => Instr(15)) when ExtOp = '1' else (others => '0');

    func <= Instr(5 downto 0);
    sa <= Instr(10 downto 6);

end Behavioral;
