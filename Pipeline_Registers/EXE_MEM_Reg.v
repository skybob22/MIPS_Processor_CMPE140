module EXE_MEM_Reg(
        //Input
        input wire  [31:0]  PC_Plus_4_In,
        input wire  [31:0]  WD_DM_In,
        input wire  [31:0]  ALU_Res_In,
        input wire  [4:0]   RF_WA_In,
        input wire  [31:0]  R64_Lo_In,
        input wire  [31:0]  R64_Hi_In,
        input wire  [2:0]   RF_WD_Src_In,
        input wire          WE_Reg_In,
        input wire          WE_DM_In,
        input wire  [4:0]   RA2_In,
        //Output
        output wire [31:0]  PC_Plus_4_Out,
        output wire [31:0]  WD_DM_Out,
        output wire [31:0]  ALU_Res_Out,
        output wire [4:0]   RF_WA_Out,
        output wire [31:0]  R64_Lo_Out,
        output wire [31:0]  R64_Hi_Out,
        output wire [2:0]   RF_WD_Src_Out,
        output wire         WE_Reg_Out,
        output wire         WE_DM_Out,
        output wire [4:0]   RA2_Out,
        //Misc
        input wire          CLK,
        input wire          RST
    );

    wire [174:0] InSignals;
    reg [174:0] OutSignals;
    
    assign InSignals = {PC_Plus_4_In,WD_DM_In,ALU_Res_In,RF_WA_In,R64_Lo_In,R64_Hi_In,RF_WD_Src_In,WE_Reg_In,WE_DM_In,RA2_In};
    assign {PC_Plus_4_Out,WD_DM_Out,ALU_Res_Out,RF_WA_Out,R64_Lo_Out,R64_Hi_Out,RF_WD_Src_Out,WE_Reg_Out,WE_DM_Out,RA2_Out} = OutSignals;

    always @ (posedge CLK or posedge RST) begin
        if(RST) OutSignals <= 175'b0;
        else OutSignals <= InSignals;
    end

endmodule