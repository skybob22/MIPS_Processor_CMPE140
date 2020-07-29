module Control_Unit(
        input wire  [5:0]   Function,
        input wire  [5:0]   OpCode,
        output wire [2:0]   ALU_Ctrl,
        output wire         JR,
        output wire         WE_R64,
        output wire [2:0]   RF_WD_Src,
        output wire         ALU_Src,
        output wire         Branch,
        output wire         Jump,
        output wire [1:0]   RF_WA_Sel,
        output wire         WE_DM,
        output wire         WE_Reg
    );
    
    wire [2:0] Operation;
    wire JAL,Branch_Int,Jump_Int;
    
    Maindec md(
        .OpCode(OpCode),
        .Operation(Operation),
        .JAL(JAL),
        .ALU_Src(ALU_Src),
        .Branch(Branch_Int),
        .Jump(Jump_Int),
        .RF_WA_Sel(RF_WA_Sel),
        .WE_DM(WE_DM)
    );
    
    Auxdec ad(
        .Operation(Operation),
        .Function(Function),
        .JAL(JAL),
        .Branch(Branch_Int),
        .Jump(Jump_Int),
        .ALU_Ctrl(ALU_Ctrl),
        .JR(JR),
        .WE_R64(WE_R64),
        .RF_WD_Src(RF_WD_Src),
        .WE_Reg(WE_Reg)
    );
    
    assign Branch = Branch_Int;
    assign Jump = Jump_Int;

endmodule