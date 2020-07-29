module Maindec(
        input   wire [5:0]  OpCode,
        output  wire [2:0]  Operation,
        output  wire        JAL,
        output  wire        ALU_Src,
        output  wire        Branch,
        output  wire        Jump,
        output  wire [1:0]  RF_WA_Sel,
        output  wire        WE_DM
    );
    
    reg [9:0] Ctrl;
    assign {Operation,JAL,Branch,Jump,RF_WA_Sel,ALU_Src,WE_DM} = Ctrl;

    always @(OpCode) begin
        case (OpCode)
            6'b00_0000: Ctrl = 10'b010_0_0_0_01_0_0; //R-Type
            6'b00_0100: Ctrl = 10'b001_0_1_0_xx_0_0; //Beq
            6'b00_1000: Ctrl = 10'b000_0_0_0_00_1_0; //Addi
            6'b10_0011: Ctrl = 10'b100_0_0_0_00_1_0; //LW
            6'b10_1011: Ctrl = 10'b101_0_0_0_xx_1_1; //SW
            6'b00_0010: Ctrl = 10'b111_0_0_1_xx_x_0; //J
            6'b00_0011: Ctrl = 10'b111_1_0_1_10_x_0; //Jal
            default: Ctrl = 10'bxxx_x_x_x_xx_x_x; //Unknown Operand
        endcase
    end

endmodule