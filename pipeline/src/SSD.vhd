library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity SSD is
    Port ( clk : in std_logic;
           digits : in STD_LOGIC_VECTOR (31 downto 0);
           an : out STD_LOGIC_VECTOR (7 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
end SSD;

architecture Behavioral of SSD is
    signal CNT: std_logic_vector(16 downto 0) := (others => '0');
    signal HEX: std_logic_vector(3 downto 0);
begin
    
    process(clk)     -- counter
    begin
        if rising_edge(clk) then
            CNT <= CNT + 1;
        end if;
    end process;
    
    with HEX select  -- hex to 7-segment
    cat <=  "1111001" when "0001",   --1
            "0100100" when "0010",   --2
            "0110000" when "0011",   --3
            "0011001" when "0100",   --4
            "0010010" when "0101",   --5
            "0000010" when "0110",   --6
            "1111000" when "0111",   --7
            "0000000" when "1000",   --8
            "0010000" when "1001",   --9
            "0001000" when "1010",   --A
            "0000011" when "1011",   --b
            "1000110" when "1100",   --C
            "0100001" when "1101",   --d
            "0000110" when "1110",   --E
            "0001110" when "1111",   --F
            "1000000" when others;   --0

    with CNT(16 downto 14) select -- MUX digits
    HEX <= digits( 3 downto  0) when "000", 
           digits( 7 downto  4) when "001", 
           digits(11 downto  8) when "010", 
           digits(15 downto 12) when "011", 
           digits(19 downto 16) when "100", 
           digits(23 downto 20) when "101", 
           digits(27 downto 24) when "110", 
           digits(31 downto 28) when others; 
    
    with CNT(16 downto 14) select -- MUX an
    an <= "11111110" when "000", 
          "11111101" when "001", 
          "11111011" when "010", 
          "11110111" when "011", 
          "11101111" when "100", 
          "11011111" when "101", 
          "10111111" when "110", 
          "01111111" when others; 
    
end Behavioral;
