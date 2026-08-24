library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MEM is
    port (
        clk: in std_logic;
        en : in std_logic;
        ALURes  : in std_logic_vector(31 downto 0);
        RD2     : in std_logic_vector(31 downto 0);
        MemWrite : in std_logic;
        MemData  : out std_logic_vector(31 downto 0)
    );
end MEM;

architecture Behavioral of MEM is
    type tRAM is array(0 to 255) of std_logic_vector(31 downto 0);

    signal RAM: tRAM := (
        x"0000_0011", -- 17 dec
        x"FFFF_FFFF", -- placeholder

        others => x"0000_0000"
    );
begin

    MemData <= RAM(conv_integer(ALURes(7 downto 0)));

    process (clk)
    begin
        if rising_edge(clk) then
            if en = '1' and MemWrite = '1' then
                RAM(conv_integer(ALURes(7 downto 0))) <= RD2;
            end if;
        end if;
    end process;
end Behavioral;
