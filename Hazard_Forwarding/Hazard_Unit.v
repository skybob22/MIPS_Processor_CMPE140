module Hazard_Unit(
        input wire  [31:0]  Instr,
        input wire  [4:0]   RF_WA_EXE,
        input wire  [2:0]   RF_WD_Src_EXE,
        input wire          WE_Reg_EXE,
        input wire  [4:0]   RF_WA_MEM,
        input wire  [2:0]   RF_WD_Src_MEM,
        input wire          WE_Reg_MEM,
        output wire         PC_Enable,
        output wire         Ins_Nop
    );
    
    reg [1:0] OutSignals;
    assign {PC_Enable,Ins_Nop} = OutSignals;
    
    always @ (*) begin
        //BEQ Hazard (I) (Checking equility on register that is still being modified)
        if(Instr[31:26] == 6'b00_0100) begin
            //Check R1
            if( (WE_Reg_EXE && Instr[25:21] == RF_WA_EXE && Instr[25:21] != 0) || (WE_Reg_MEM && Instr[25:21] == RF_WA_MEM && RF_WD_Src_MEM == 3'b100) ) OutSignals = 2'b01;
            
            //Check R2
            else if( (WE_Reg_EXE && Instr[20:16] == RF_WA_EXE && Instr[20:16] != 0) || (WE_Reg_MEM && Instr[20:16] == RF_WA_MEM && RF_WD_Src_MEM == 3'b100) ) OutSignals = 2'b01;
            
            //No Hazard
            else OutSignals = 2'b10;
        end
            
        //JR Hazard (R) (Jumping to a register that is still being modified)
        else if(Instr[31:26] == 6'b00_0000 && Instr[5:0] == 6'b00_1000) begin
            //Check R1
            if( (WE_Reg_EXE && Instr[25:21] == RF_WA_EXE && Instr[25:21] != 0) || (WE_Reg_MEM && Instr[25:21] == RF_WA_MEM && RF_WD_Src_MEM == 3'b100) ) OutSignals = 2'b01;
            
            else OutSignals = 2'b10;
        end
        
        //Other/Use-After-Load Hazard
        else begin
            //R-Type, Check 2 registers. Omit Mflo and Mfhi since they don't rely on source registers
            if(Instr[31:26] == 6'b00_0000 && (Instr[5:0]!= 6'b01_0000 && Instr[5:0]!= 6'b01_0010)) begin
                //Check R1
                if( (WE_Reg_EXE && Instr[25:21] == RF_WA_EXE && RF_WD_Src_EXE == 3'b100 && Instr[25:21] != 0) ) OutSignals = 2'b01;
                
                //Check R2
                else if( (WE_Reg_EXE && Instr[20:16] == RF_WA_EXE && RF_WD_Src_EXE == 3'b100 && Instr[20:16] != 0) ) OutSignals = 2'b01;
                
                //No Hazard
                else OutSignals = 2'b10;
            end
            
            //I-Type, Check 1 register
            else if(Instr[31:26] == 6'b00_1000 || Instr[31:26] == 6'b10_0011 || Instr[31:26] == 6'b10_1011) begin
                if( (WE_Reg_EXE && Instr[25:21] == RF_WA_EXE && RF_WD_Src_EXE == 3'b100 && Instr[25:21] != 0) ) OutSignals = 2'b01;
                else OutSignals = 2'b10;
            end
            
            //J-Type, doesn't rely on source registers
            else OutSignals = 2'b10;
        end
    end
    
endmodule