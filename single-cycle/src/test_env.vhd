library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity test_env is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (4 downto 0);
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (7 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
end test_env;

architecture Behavioral of test_env is

    component MPG is
        Port ( BTN : in STD_LOGIC;
               CLK : in STD_LOGIC;
               EN : out STD_LOGIC);
    end component;

    component SSD is
        Port ( clk : in std_logic;
               digits : in STD_LOGIC_VECTOR (31 downto 0);
               an : out STD_LOGIC_VECTOR (7 downto 0);
               cat : out STD_LOGIC_VECTOR (6 downto 0));
    end component;

    component IFetch is
        Port ( clk : in STD_LOGIC;
              en : in STD_LOGIC;
              rst : in STD_LOGIC;
              jumpAddr : in STD_LOGIC_VECTOR (31 downto 0);
              branchAddr : in STD_LOGIC_VECTOR (31 downto 0);
              jumpFlag : in STD_LOGIC;
              PCSrc : in STD_LOGIC;
              PCinc : out STD_LOGIC_VECTOR (31 downto 0);
              instruction : out STD_LOGIC_VECTOR (31 downto 0));
    end component;

    component IDecode is
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
    end component;

    component MainControl is
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
    end component;
    

    component ExecutionUnit is
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
    end component;

    component MEM is
        port (
            clk: in std_logic;
            en : in std_logic;
            ALURes  : in std_logic_vector(31 downto 0);
            RD2     : in std_logic_vector(31 downto 0);
            MemWrite : in std_logic;
            MemData  : out std_logic_vector(31 downto 0);
            ALURes_out  : out std_logic_vector(31 downto 0)
        );
    end component;

    signal EN: std_logic;
    signal RST: std_logic;
    signal DIGITS: std_logic_vector(31 downto 0);
   
    -- data
    signal instr, PCinc, RD1, RD2, WD,
           Ext_Imm, Ext_func, Ext_sa, 
           jumpAddr, branchAddr,
           ALURes, ALURes1, MemData,
           sum: std_logic_vector(31 downto 0);

    signal sa: std_logic_vector(4 downto 0);
    signal func: std_logic_vector(5 downto 0);

    -- control
    signal RegWrite, RegDst, ExtOp,
           jumpFlag, PCSrc,
           ALUSrc, zeroFlag, 
           MemtoReg, MemWrite,
           BranchEQ, BranchNE: STD_LOGIC;

    signal ALUOp: std_logic_vector(2 downto 0); 
    
begin
    -- main comps
    u1: IFetch port map(CLK, EN, RST, jumpAddr, branchAddr, jumpFlag,PCSrc, PCinc, instr);
    u2: IDecode port map(CLK, EN, instr, WD, RegWrite, RegDst, ExtOp, RD1, RD2, Ext_Imm, func, sa);
    u3: MainControl port map(instr, RegDst, ExtOp, ALUSrc, BranchEQ, BranchNE, JumpFlag, ALUOp, MemWrite, MemtoReg, RegWrite);
    u4: ExecutionUnit port map(PCinc, RD1, RD2, Ext_imm, func, sa, ALUSrc, ALUOp, BranchAddr, AluRes, zeroFlag);
    u5: MEM port map(clk, en, ALURes, RD2, MemWrite, MemData, ALuRes1);

    -- write back
    with MemtoReg select
        WD <= MemData when '1',
              AluRes1 when '0',
              (others => 'X') when others;

    -- branch control
    PCSrc <= (zeroFlag and BranchEQ) or (not zeroFlag and BranchNE);
    
    -- jump addr
--    JumpAddr <= PCinc(31 downto 28) & instr(25 downto 0) & "00";
    JumpAddr <= PCinc(31 downto 26) & instr(25 downto 0);

    -- SSD select
    with sw(15 downto 13) select
        DIGITS <= instr when "000",
                  PCinc when "001",
                  RD1 when "010",
                  RD2 when "011",
                  EXt_imm when "100",
                  ALURes when "101",
                  MemData when "110",
                  WD when "111",
                  (others => 'X') when others;

    -- main control flags
    led(11 downto 0) <= ALUOp & RegDst & ExtOp & ALUSrc & BranchEQ & BranchNE & 
                        JumpFlag & MemWrite & MemtoReg & RegWrite;

    -- butons
    mono0: MPG port map(btn(0), CLK, EN);
    mono1: MPG port map(btn(1), CLK, RST);
    
    -- ssd
    ussd: SSD port map(clk, DIGITS, an, cat);

end Behavioral;
