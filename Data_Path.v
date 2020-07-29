module Data_Path(
        //IF Stage
        output wire [31:0]  PC_Current,
        input wire  [31:0]  Instr,
        
        //ID Stage
        output wire [31:0]  CU_Instr,
        input wire          Jump,
        input wire          JR,
        input wire          Branch,
        input wire  [1:0]   RF_WA_Sel,
        input wire  [2:0]   RF_WD_Src,
        input wire          WE_Reg,
        input wire          ALU_Src,
        input wire  [2:0]   ALU_Ctrl,
        input wire          WE_R64,
        input wire          WE_DM_In,
        
        //MEM Stage
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
    
    
    //=========================Intermediate Wires=========================
    //===IF Stage===//
    wire [31:0] PC_Current_Int,PC_Plus_4_IF,PC_Next,PC_Jump_Dest;
    wire [31:0] Instr_IF;
    wire PC_Enable,PC_Change;
    
    //===ID Stage===//
    wire [31:0] PC_Plus_4_ID;
    wire [31:0] Instr_ID;
    wire [31:0] PC_ID;//Not actually used by modules, exists for simulation waveform

    wire [2:0] RD1_Fwd_Sel_ID,RD2_Fwd_Sel_ID;
    wire [31:0] RD1_Fwd_Out_ID,RD2_Fwd_Out_ID;
    wire [31:0] SExt_Imm_ID;
    wire Comparitor_Res,Do_Branch;
    wire [31:0] Branch_Target_Addr;
    wire Ins_Nop;
    
    //===EXE Stage===//
    wire [31:0] PC_Plus_4_EXE;
    wire [31:0] SExt_Imm_EXE;
    wire [31:0] RD1_EXE,RD2_EXE;
    wire [4:0]  RF_WA_EXE;
    wire [4:0]  Sh_Amt_EXE;
    wire [2:0]  RF_WD_Src_EXE;
    wire        WE_Reg_EXE,ALU_Src_EXE;
    wire [2:0]  ALU_Ctrl_EXE;
    wire        WE_R64_EXE,WE_DM_EXE;
    wire [4:0]  RA1_EXE,RA2_EXE;
    
    wire [31:0] ALU_In_A,ALU_In_B,RD2_Fwd_Out_EXE;
    wire [2:0] RD1_Fwd_Sel_EXE,RD2_Fwd_Sel_EXE;
    wire [31:0] ALU_Res_EXE;
    wire [63:0] ALU_Res_R64_EXE;
    wire [31:0] R64_Hi_EXE,R64_Lo_EXE;
    
    //===MEM Stage===//
    wire [31:0] PC_Plus_4_MEM;
    wire [31:0] R64_Hi_MEM,R64_Lo_MEM;
    wire [31:0] ALU_Res_MEM;
    
    wire [2:0] RF_WD_Src_MEM;
    wire [4:0] RF_WA_MEM;
    wire WE_Reg_MEM;
    wire RA2_MEM;
    wire [31:0] WD_DM_MEM;
    wire RD2_Fwd_Sel_MEM;
    
    //===WB Stage===//
    wire [31:0] RF_WD;
    wire [4:0] RF_WA;
    wire RF_WE;
    
    wire [31:0] RD1_ID,RD2_ID;
    wire [4:0] RF_WA_ID;
    wire [2:0] RF_WD_Src_WB;
    wire [31:0] ALU_Res_WB,PC_Plus_4_WB,R64_Lo_WB,R64_Hi_WB,RD_DM_WB; 
    
    
    //=========================IF Stage=========================//
    //Contains current PC value
    D_Reg#(32) PC_Reg(
        .D(PC_Next),
        .EN(PC_Enable),
        .RST(RST),
        .CLK(CLK),
        .Q(PC_Current_Int)
    );
    assign PC_Current = PC_Current_Int;
    
    //Calculate next PC value w/o jump
    Adder#(32) PC_Plus_4(
        .A(32'd4),
        .B(PC_Current_Int),
        .Out(PC_Plus_4_IF)
    );
    
    //Selects whether next PC will be PC+4, or selection from jump mux
    Mux2#(32) PC_Src_Mux(
        .In0(PC_Plus_4_IF),
        .In1(PC_Jump_Dest),
        .Out(PC_Next),
        .Sel(PC_Change)
    );
    
    //Choose whether to flush instruction or not
    Mux2 #(32) Instr_Mux(
        .In0(Instr),
        .In1(32'd0), //Nop
        .Out(Instr_IF),
        .Sel(PC_Change)
    );
    
    
    //=========================IF/ID Reg=========================//
    IF_ID_Reg IF_ID(
        //Input
        .PC_Plus_4_In(PC_Plus_4_IF),
        .Instr_In(Instr_IF),
        //Output
        .PC_Plus_4_Out(PC_Plus_4_ID),
        .Instr_Out(Instr_ID),
        //Misc
        .EN(PC_Enable),
        .CLK(CLK),
        .RST(RST)
    );
    
    
    //=========================ID Stage=========================//
    assign PC_ID = PC_Plus_4_ID - 32'd4; //Used for display purposes during simulation 
    assign CU_Instr = Instr_ID;
    
    //Jump/Branch control
    assign Do_Branch = (Comparitor_Res & Branch);
    assign PC_Change = (Do_Branch | JR | Jump);
    
    //Decide which version of jump/branch to use
    Mux4 #(32) PC_Jump_Mux(
        .In0({PC_Plus_4_ID[31:28],Instr_ID[25:0],2'd0}),
        .In1(Branch_Target_Addr),
        .In2(RD1_Fwd_Out_ID),
        .Out(PC_Jump_Dest),
        .Sel({JR,Do_Branch})
    );
    
    //Calculate branch address
    Adder#(32) PC_Plus_BR(
        .A({SExt_Imm_ID[29:0],2'b00}),
        .B(PC_Plus_4_ID),
        .Out(Branch_Target_Addr)
    );
    
    //Compare registers for early branch determination
    Comparator Comp(
        .A(RD1_Fwd_Out_ID),
        .B(RD2_Fwd_Out_ID),
        .EQ(Comparitor_Res)
    );

    //Create sign extended immediate value for I-Type instructions
    Sign_Ext #(16,32)    SE(
        .In(Instr_ID[15:0]),
        .Out(SExt_Imm_ID)
    );   
    
    Regfile #(32) RF(
        .RA1(Instr_ID[25:21]),
        .RA2(Instr_ID[20:16]),
        .RA3(RA3),
        .WA(RF_WA),
        .WD(RF_WD),
        .WE(RF_WE),
        .RD1(RD1_ID),
        .RD2(RD2_ID),
        .RD3(RD3),
        .CLK(CLK),
        .RST(RST)
    );
    
    //Determine which address to write back to later
    Mux4 #(5) RF_WA_Mux(
        .In0(Instr_ID[20:16]),
        .In1(Instr_ID[15:11]),
        .In2(5'h1F), //0x1F = $RA register
        .Out(RF_WA_ID),
        .Sel(RF_WA_Sel)
    );

    //Forwarding for early branch determination
    Mux8 #(32) RD1_ID_Fwd_Mux(
        .In0(RD1_ID),
        .In1(ALU_Res_MEM),
        .In2(PC_Plus_4_MEM),
        .In3(R64_Lo_MEM),
        .In4(R64_Hi_MEM),
        .Out(RD1_Fwd_Out_ID),
        .Sel(RD1_Fwd_Sel_ID)
    );
    
    Mux8 #(32) RD2_ID_Fwd_Mux(
        .In0(RD2_ID),
        .In1(ALU_Res_MEM),
        .In2(PC_Plus_4_MEM),
        .In3(R64_Lo_MEM),
        .In4(R64_Hi_MEM),
        .Out(RD2_Fwd_Out_ID),
        .Sel(RD2_Fwd_Sel_ID)
    );  

    //Decide whether to forward or not
    ID_Fwd_Unit ID_Fwd(
        .RA1(Instr_ID[25:21]),
        .RA2(Instr_ID[20:16]),
        .WA_EM(RF_WA_MEM),
        .WE_EM(WE_Reg_MEM),
        .WS_EM(RF_WD_Src_MEM),
        .FW_Src_1(RD1_Fwd_Sel_ID),
        .FW_Src_2(RD2_Fwd_Sel_ID)
    );


    //=========================IF/EXE Reg=========================//
    ID_EXE_Reg ID_EXE(
        //Input
        .SExt_Imm_In(SExt_Imm_ID),
        .PC_Plus_4_In(PC_Plus_4_ID),
        .RD1_In(RD1_ID),
        .RD2_In(RD2_ID),
        .RF_WA_In(RF_WA_ID),
        .RA1_In(Instr_ID[25:21]),
        .RA2_In(Instr_ID[20:16]),
        .Sh_Amt_In(Instr_ID[10:6]),
        .RF_WD_Src_In(RF_WD_Src),
        .WE_Reg_In(WE_Reg),
        .ALU_Src_In(ALU_Src),
        .ALU_Ctrl_In(ALU_Ctrl),
        .WE_R64_In(WE_R64),
        .WE_DM_In(WE_DM_In),
        //Output
        .PC_Plus_4_Out(PC_Plus_4_EXE),
        .SExt_Imm_Out(SExt_Imm_EXE),
        .RD1_Out(RD1_EXE),
        .RD2_Out(RD2_EXE),
        .RF_WA_Out(RF_WA_EXE),
        .Sh_Amt_Out(Sh_Amt_EXE),
        .RF_WD_Src_Out(RF_WD_Src_EXE),
        .WE_Reg_Out(WE_Reg_EXE),
        .ALU_Src_Out(ALU_Src_EXE),
        .ALU_Ctrl_Out(ALU_Ctrl_EXE),
        .WE_R64_Out(WE_R64_EXE),
        .WE_DM_Out(WE_DM_EXE),
        .RA1_Out(RA1_EXE),
        .RA2_Out(RA2_EXE),   
        //Misc
        .Ins_Nop(Ins_Nop),
        .CLK(CLK),
        .RST(RST)
    );

    //=========================EXE Stage=========================//
    //Forwarding for EXE stage
    Mux8 #(32) RD1_EXE_Fwd_Mux(
        .In0(RD1_EXE),
        .In1(ALU_Res_MEM),
        .In2(PC_Plus_4_MEM),
        .In3(R64_Lo_MEM),
        .In4(R64_Hi_MEM),
        .In5(RF_WD),
        .Out(ALU_In_A),
        .Sel(RD1_Fwd_Sel_EXE)
    );
    
    Mux8 #(32) RD2_EXE_Fwd_Mux(
        .In0(RD2_EXE),
        .In1(ALU_Res_MEM),
        .In2(PC_Plus_4_MEM),
        .In3(R64_Lo_MEM),
        .In4(R64_Hi_MEM),
        .In5(RF_WD),
        .Out(RD2_Fwd_Out_EXE),
        .Sel(RD2_Fwd_Sel_EXE)
    );
    
    //Decide whether to forward or not
    EXE_Fwd_Unit EXE_Fwd(
        .RA1(RA1_EXE),
        .RA2(RA2_EXE),
        .WA_EM(RF_WA_MEM),
        .WE_EM(WE_Reg_MEM),
        .WS_EM(RF_WD_Src_MEM),
        .WA_MW(RF_WA),
        .WE_MW(RF_WE),
        .WS_MW(RF_WD_Src_WB),
        .FW_Src_1(RD1_Fwd_Sel_EXE),
        .FW_Src_2(RD2_Fwd_Sel_EXE)
    );
    
    //Select whether to use register value or immediate value as ALU input B
    Mux2 #(32)  ALU_Src_Mux(
        .In0(RD2_Fwd_Out_EXE),
        .In1(SExt_Imm_EXE),
        .Out(ALU_In_B),
        .Sel(ALU_Src_EXE)
    );
    
    ALU Alu(
        .OP(ALU_Ctrl_EXE),
        .A(ALU_In_A),
        .B(ALU_In_B),
        .Sh_Amt(Sh_Amt_EXE),
        .Y(ALU_Res_EXE),
        .R64(ALU_Res_R64_EXE)
    ); 
    
    R64_Reg #(32) R64(
        .DLo(ALU_Res_R64_EXE[31:0]),
        .DHi(ALU_Res_R64_EXE[63:32]),
        .QLo(R64_Lo_EXE),
        .QHi(R64_Hi_EXE),
        .EN(WE_R64_EXE),
        .CLK(CLK),
        .RST(RST)
    ); 


    //=========================EXE/MEM Reg=========================//    
    EXE_MEM_Reg EXE_MEM(
        .PC_Plus_4_In(PC_Plus_4_EXE),
        .WD_DM_In(RD2_Fwd_Out_EXE),
        .ALU_Res_In(ALU_Res_EXE),
        .RF_WA_In(RF_WA_EXE),
        .R64_Lo_In(R64_Lo_EXE),
        .R64_Hi_In(R64_Hi_EXE),
        .RF_WD_Src_In(RF_WD_Src_EXE),
        .WE_Reg_In(WE_Reg_EXE),
        .WE_DM_In(WE_DM_EXE),
        .RA2_In(RA2_EXE),
        //Output
        .PC_Plus_4_Out(PC_Plus_4_MEM),
        .WD_DM_Out(WD_DM_MEM),
        .ALU_Res_Out(ALU_Res_MEM),
        .RF_WA_Out(RF_WA_MEM),
        .R64_Lo_Out(R64_Lo_MEM),
        .R64_Hi_Out(R64_Hi_MEM),
        .RF_WD_Src_Out(RF_WD_Src_MEM),
        .WE_Reg_Out(WE_Reg_MEM),
        .WE_DM_Out(WE_DM),
        .RA2_Out(RA2_MEM),
        //Misc
        .CLK(CLK),
        .RST(RST)
    );
    
    
    //=========================MEM Stage=========================//
    assign ALU_Out = ALU_Res_MEM;

    //Forwarding
    Mux2 #(32) RD2_MEM_Fwd_Mux(
        .In0(WD_DM_MEM),
        .In1(RF_WD),
        .Out(WD_DM),
        .Sel(RD2_Fwd_Sel_MEM)
    );
    
    MEM_Fwd_Unit MEM_Fwd(
        .RA2(RA2_MEM),
        .WA_MW(RF_WA),
        .WE_MW(RF_WE),
        .WS_MW(RF_WD_Src_WB),
        .FW_Src(RD2_Fwd_Sel_MEM)
    );
    
    
    //=========================MEM/WB Reg=========================//   
    MEM_WB_Reg MEM_WB(
        //Input
        .PC_Plus_4_In(PC_Plus_4_MEM),
        .RF_WD_Src_In(RF_WD_Src_MEM),
        .WE_Reg_In(WE_Reg_MEM),
        .R64_Lo_In(R64_Lo_MEM),
        .R64_Hi_In(R64_Hi_MEM),
        .RF_WA_In(RF_WA_MEM),
        .ALU_Res_In(ALU_Res_MEM),
        .RD_DM_In(RD_DM),
        //Output
        .PC_Plus_4_Out(PC_Plus_4_WB),
        .RF_WD_Src_Out(RF_WD_Src_WB),
        .WE_Reg_Out(RF_WE),
        .R64_Lo_Out(R64_Lo_WB),
        .R64_Hi_Out(R64_Hi_WB),
        .RF_WA_Out(RF_WA),
        .ALU_Res_Out(ALU_Res_WB),
        .RD_DM_Out(RD_DM_WB),
        //Misc
        .CLK(CLK),
        .RST(RST)
    );
    
    Mux8 #(32) WB_Mux(
        .In0(ALU_Res_WB),
        .In1(PC_Plus_4_WB),
        .In2(R64_Lo_WB),
        .In3(R64_Hi_WB),
        .In4(RD_DM_WB),
        .Out(RF_WD),
        .Sel(RF_WD_Src_WB)
    );


    //=========================Hazard Unit=========================//
    Hazard_Unit HU(
        //Input
        .Instr(Instr_ID),
        .RF_WA_EXE(RF_WA_EXE),
        .RF_WD_Src_EXE(RF_WD_Src_EXE),
        .WE_Reg_EXE(WE_Reg_EXE),
        .RF_WA_MEM(RF_WA_MEM),
        .RF_WD_Src_MEM(RF_WD_Src_MEM),
        .WE_Reg_MEM(WE_Reg_MEM),
        //Output
        .PC_Enable(PC_Enable),
        .Ins_Nop(Ins_Nop)
    );


endmodule