module ID_EXE_Reg(
        input wire  [31:0]  SExt_Imm_In,
        input wire  [31:0]  PC_Plus_4_In,
        input wire  [31:0]  RD1_In,
        input wire  [31:0]  RD2_In,
        input wire  [4:0]   RF_WA_In,
        input wire  [4:0]   RA1_In,
        input wire  [4:0]   RA2_In,
        input wire  [4:0]   Sh_Amt_In,
        input wire  [2:0]   RF_WD_Src_In,
        input wire          WE_Reg_In,
        input wire          ALU_Src_In,
        input wire  [2:0]   ALU_Ctrl_In,
        input wire          WE_R64_In,
        input wire          WE_DM_In,
        output wire [31:0]  PC_Plus_4_Out,
        output wire [31:0]  SExt_Imm_Out,
        output wire [31:0]  RD1_Out,
        output wire [31:0]  RD2_Out,
        output wire [4:0]   RF_WA_Out,
        output wire [4:0]   Sh_Amt_Out,
        output wire [2:0]   RF_WD_Src_Out,
        output wire         WE_Reg_Out,
        output wire         ALU_Src_Out,
        output wire [2:0]   ALU_Ctrl_Out,
        output wire         WE_R64_Out,
        output wire         WE_DM_Out,
        output wire [4:0]   RA1_Out,
        output wire [4:0]   RA2_Out,
        
        input wire          Ins_Nop,
        input wire          CLK,
        input wire          RST
    );
    
    wire [157:0] InSignals,Nop;
    reg [157:0] OutSignals;
    
    assign InSignals = {SExt_Imm_In,PC_Plus_4_In,RD1_In,RD2_In,RF_WA_In,RA1_In,RA2_In,Sh_Amt_In,RF_WD_Src_In,WE_Reg_In,ALU_Src_In,ALU_Ctrl_In,WE_R64_In,WE_DM_In};
    assign {SExt_Imm_Out,PC_Plus_4_Out,RD1_Out,RD2_Out,RF_WA_Out,RA1_Out,RA2_Out,Sh_Amt_Out,RF_WD_Src_Out,WE_Reg_Out,ALU_Src_Out,ALU_Ctrl_Out,WE_R64_Out,WE_DM_Out} = OutSignals;
    
    //Equivilent to control signals output from Control Unit for Nop operation
    assign Nop = {32'd0,PC_Plus_4_In,32'd0,32'd0,5'd0,5'd0,5'd0,5'd0,3'd0,1'b1,1'b0,3'b100,1'b0,1'b0};
    
    always @ (posedge CLK or posedge RST) begin
        if(RST) OutSignals <= 158'b0;
        else if(Ins_Nop) OutSignals <= Nop;
        else OutSignals <= InSignals;
    end
    
    

endmodule