library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MPG is
    Port ( BTN : in STD_LOGIC;
           CLK : in STD_LOGIC;
           EN : out STD_LOGIC);
end MPG;

architecture Behavioral of MPG is
    signal CNT: std_logic_vector(31 downto 0);
    signal enD1: std_logic;
    
    signal Q1: std_logic;
    signal Q2: std_logic;
    signal Q3: std_logic;
begin
    process(CLK) -- numarator
    begin
        if rising_edge(CLK) then
            CNT <= CNT + 1;
        end if;
     end process;

    enD1 <= '1' when CNT(15 downto 0) = x"ffff" else '0';
    
    process(CLK) -- D cu enable
    begin
        if rising_edge(CLK) then
            if enD1 = '1' then
                Q1 <= BTN;
            end if;
        end if;
    end process; 
    
    process(CLK) -- D fara enable
    begin
        if rising_edge(CLK) then
            Q2 <= Q1;
            Q3 <= Q2;
        end if;
    end process; 

            
    EN <= Q2 and not Q3;
end Behavioral;
