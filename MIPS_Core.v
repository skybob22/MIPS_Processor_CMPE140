module MIPS_Core(
        //Instruction Access
        output wire [31:0]  PC_Current,
        input wire  [31:0]  Instr,
        
        //Memory Access
        output wire         WE_DM,
        output wire [31:0]  WD_DM,
        output wire [31:0]  ALU_Out,
        input wire  [31:0]  RD_DM,
        
        //Misc
        input wire  [4:0]   RA3,
        output wire [31:0]  RD3,
        input wire          CLK,
        input wire          RST
    );

    //Intermediate signals between Control Unit and Data Path
    wire [31:0] CU_Instr;
    wire [1:0] RF_WA_Sel;
    wire [2:0] RF_WD_Src,ALU_Ctrl;
    wire Jump,JR,Branch,WE_Reg,ALU_Src,WE_R64,WE_DM_Int;

    Control_Unit CU(
        .Function(CU_Instr[5:0]),
        .OpCode(CU_Instr[31:26]),
        .ALU_Ctrl(ALU_Ctrl),
        .JR(JR),
        .WE_R64(WE_R64),
        .RF_WD_Src(RF_WD_Src),
        .ALU_Src(ALU_Src),
        .Branch(Branch),
        .Jump(Jump),
        .RF_WA_Sel(RF_WA_Sel),
        .WE_DM(WE_DM_Int),
        .WE_Reg(WE_Reg)
    );
    
    Data_Path DP(
        //IF Stage
        .PC_Current(PC_Current),
        .Instr(Instr),
           
        //ID Stage
        .CU_Instr(CU_Instr),
        .Jump(Jump),
        .JR(JR),
        .Branch(Branch),
        .RF_WA_Sel(RF_WA_Sel),
        .RF_WD_Src(RF_WD_Src),
        .WE_Reg(WE_Reg),
        .ALU_Src(ALU_Src),
        .ALU_Ctrl(ALU_Ctrl),
        .WE_R64(WE_R64),
        .WE_DM_In(WE_DM_Int),
        
        //MEM Stage
        .WE_DM(WE_DM),
        .WD_DM(WD_DM),
        .ALU_Out(ALU_Out),
        .RD_DM(RD_DM),
        
        //Misc
        .RA3(RA3),
        .RD3(RD3),
        .CLK(CLK),
        .RST(RST)
    );
    
endmodule