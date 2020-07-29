module Auxdec (
        input wire  [2:0]   Operation,
        input wire  [5:0]   Function,
        input wire          JAL,
        input wire          Branch,
        input wire          Jump,
        output wire [2:0]   ALU_Ctrl,
        output wire         JR,
        output wire         WE_R64,
        output wire [2:0]   RF_WD_Src,
        output wire         WE_Reg
    );

    wire [5:0] InSignals;
    reg [8:0] Ctrl;
    
    assign InSignals = {Operation,JAL,Branch,Jump};
    //assign {ALU_Ctrl,JR,WE_R64,RF_WD_Src,WE_Reg} = Ctrl;
    assign {JR,ALU_Ctrl,WE_R64,RF_WD_Src,WE_Reg} = Ctrl;

    always @ (*) begin
        case (InSignals)
            6'b001_0_1_0: Ctrl = 9'b0_xxx_0_xxx_0; //Beq
            6'b000_0_0_0: Ctrl = 9'b0_010_0_000_1; //Addi
            6'b100_0_0_0: Ctrl = 9'b0_010_0_100_1; //LW
            6'b101_0_0_0: Ctrl = 9'b0_010_0_xxx_0; //SW
            6'b111_0_0_1: Ctrl = 9'b0_xxx_0_xxx_0; //J
            6'b111_1_0_1: Ctrl = 9'b0_xxx_0_001_1; //JAL
        
            //R-Type
            default: case(Function)
                6'b10_0000: Ctrl = 9'b0_010_0_000_1; //Add
                6'b10_0010: Ctrl = 9'b0_110_0_000_1; //Sub
                6'b10_0100: Ctrl = 9'b0_000_0_000_1; //And
                6'b10_0101: Ctrl = 9'b0_001_0_000_1; //Or
                6'b10_1010: Ctrl = 9'b0_111_0_000_1; //Slt
                6'b00_1000: Ctrl = 9'b1_xxx_0_xxx_0; //JR
                6'b01_1001: Ctrl = 9'b0_011_1_xxx_0; //MultU
                6'b01_0000: Ctrl = 9'b0_xxx_0_011_1; //Mfhi
                6'b01_0010: Ctrl = 9'b0_xxx_0_010_1; //Mflow
                6'b00_0000: Ctrl = 9'b0_100_0_000_1; //Sll
                6'b00_0010: Ctrl = 9'b0_101_0_000_1; //Slr
                default: Ctrl = 9'bx_xxx_x_xxx; //Unknown Operand
            endcase  
        endcase
    end

endmodule