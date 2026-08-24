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
            WA       : in  STD_LOGIC_VECTOR(4 downto 0);
            WD       : in  STD_LOGIC_VECTOR(31 downto 0);
            RegWrite : in  STD_LOGIC;
            RegDst   : in  STD_LOGIC;
            ExtOp    : in  STD_LOGIC;
            rWA      : out STD_LOGIC_VECTOR(4 downto 0);
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
            MemData  : out std_logic_vector(31 downto 0)
        );
    end component;

    signal EN: std_logic;
    signal EN_btn,
           isNop, isEnd: std_logic;
    signal RST: std_logic;
    signal DIGITS: std_logic_vector(31 downto 0);
   
    -- data
    signal instr, PCinc, RD1, RD2, WD,
           Ext_Imm, 
           jumpAddr, branchAddr,
           ALURes, MemData
           : std_logic_vector(31 downto 0);

    signal rWA: std_logic_vector(4 downto 0);
    
    signal sa: std_logic_vector(4 downto 0);
    signal func: std_logic_vector(5 downto 0);

    -- control
    signal RegWrite, RegDst, ExtOp,
           jumpFlag, PCSrc,
           ALUSrc, zeroFlag, 
           MemtoReg, MemWrite,
           BranchEQ, BranchNE: STD_LOGIC;

    signal ALUOp: std_logic_vector(2 downto 0);


    -- regs
    signal IF_ID: std_logic_vector(63 downto 0);    
    signal ID_EX: std_logic_vector(152 downto 0);
    signal EX_MEM: std_logic_vector(106 downto 0);
    signal MEM_WB: std_logic_vector(70 downto 0);

begin
    -- main comps
    --  IFetch port map(CLK, EN, RST, jumpAddr,            branchAddr, jumpFlag, PCSrc, PCinc, instr);
    u1: IFetch port map(CLK, EN, RST, jumpAddr, EX_MEM(100 downto 69), jumpFlag, PCSrc, PCinc, instr);
    
    --  IDecode port map(CLK, EN,               instr,                 WA, WD,   RegWrite, RegDst, ExtOp, rWA, RD1, RD2, Ext_Imm, func, sa);
    u2: IDecode port map(CLK, EN, IF_ID(31 downto  0), MEM_WB(4 downto 0), WD, MEM_WB(69), RegDst, ExtOp, rWA, RD1, RD2, Ext_Imm, func, sa);

                                 -- instr
    u3: MainControl port map(IF_ID(31 downto 0), RegDst, ExtOp, ALUSrc, BranchEQ, BranchNE, JumpFlag, ALUOp, MemWrite, MemtoReg, RegWrite);

    --  ExecutionUnit port map(             PCinc,                   RD1,                  RD2,             Ext_imm,                func,                  sa,     ALUSrc,                 ALUOp, BranchAddr, AluRes, zeroFlag);
    u4: ExecutionUnit port map(ID_EX(31 downto 0), ID_EX(143 downto 112), ID_EX(111 downto 80), ID_EX(79 downto 48), ID_EX(47 downto 42), ID_EX(41 downto 37), ID_EX(144), ID_EX(147 downto 145), BranchAddr, AluRes, zeroFlag);

    --  MEM port map(clk, en,               ALURes,                 RD2,    MemWrite, MemData);
    u5: MEM port map(clk, en, EX_MEM(68 downto 37), EX_MEM(36 downto 5), EX_MEM(106), MemData);

    -- registers
    process(clk, en, rst)
    begin
        if rst = '1' then
            IF_ID <= (others => '0');
            ID_EX <= (others => '0');
            EX_MEM <= (others => '0');
            MEM_WB <= (others => '0');
        elsif rising_edge(clk) then
            if en = '1' then
                -- IF_ID
                IF_ID(63 downto 32) <= PCinc;
                IF_ID(31 downto  0) <= instr;

                -- ID_EX
                -- ID_EX() <= RegDst; -- l am lasat in ID
                ID_EX(152) <= MemToReg;
                ID_EX(151) <= RegWrite;
                ID_EX(150) <= MemWrite;
                ID_EX(149) <= BranchEQ;
                ID_EX(148) <= BranchNE;
                ID_EX(147 downto 145) <= ALUOp; --3
                ID_EX(144) <= ALUSrc;

                ID_EX(143 downto 112) <= RD1;
                ID_EX(111 downto  80) <= RD2;
                ID_EX( 79 downto  48) <= Ext_imm;
                ID_EX( 47 downto  42) <= func; -- 6
                ID_EX( 41 downto  37) <= sa;  -- 5
                ID_EX( 36 downto  32) <= rWA; --5
                ID_EX( 31 downto   0) <= IF_ID(63 downto 32); -- PCinc


                -- EX_MEM
                EX_MEM(106) <= ID_EX(152); --MemToReg;
                EX_MEM(105) <= ID_EX(151); --RegWrite;
                EX_MEM(104) <= ID_EX(150); --MemWrite;
                EX_MEM(103) <= ID_EX(149); --BranchEQ;
                EX_MEM(102) <= ID_EX(148); --BranchNE;
                EX_MEM(101) <= zeroFlag;

                EX_MEM(100 downto 69) <= branchAddr; -- PCinc + ext(imm)
                EX_MEM( 68 downto 37) <= ALURes;
                EX_MEM( 36 downto  5) <= ID_EX(111 downto 80); -- RD2
                EX_MEM(  4 downto  0) <= ID_EX( 36 downto 32); -- rWA

                -- MEM_WR
                MEM_WB(70) <= EX_MEM(106); --MemToReg;
                MEM_WB(69) <= EX_MEM(105); --RegWrite;
                MEM_WB(68 downto 37) <= MemData;
                MEM_WB(36 downto  5) <= EX_MEM(68 downto 37); --ALURes
                MEM_WB( 4 downto  0) <= EX_MEM( 4 downto  0); --rWA

            end if;
        end if;
            
    end process;

    -- write back
    with MEM_WB(70) select -- MemtoReg
        WD <= MEM_WB(68 downto 37) when '1', -- MemData
              MEM_WB(36 downto  5) when '0', -- AluRes1
              (others => 'X') when others;

    -- branch control
    -- PCSrc <= (zeroFlag and BranchEQ) or (not zeroFlag and BranchNE);
    PCSrc <= (EX_MEM(101) and EX_MEM(103)) or (not EX_MEM(101) and EX_MEM(102));
    
    -- jump addr
    -- JumpAddr <= PCinc(31 downto 28) & instr(25 downto 0) & "00";
    -- JumpAddr <= PCinc(31 downto 26) & instr(25 downto 0);
    JumpAddr <= IF_ID(63 downto 32)(31 downto 26) & IF_ID(31 downto 0)(25 downto 0);

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

    isNop <= '1' when instr = x"00000000" else '0';
    isEnd <= '1' when instr(31 downto 24) = x"AC" else '0';
    en <= en_btn or 
          (sw(1) and isNop) or
          (sw(0) and not isEnd);

    -- main control flags
    led(11 downto 0) <= ALUOp & RegDst & ExtOp & ALUSrc & BranchEQ & BranchNE & 
                        JumpFlag & MemWrite & MemtoReg & RegWrite;

    -- butons
    mono0: MPG port map(btn(0), CLK, EN_btn);
    mono1: MPG port map(btn(1), CLK, RST);
    
    -- ssd
    ussd: SSD port map(clk, DIGITS, an, cat);

end Behavioral;
