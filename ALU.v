module ALU (
        input  wire [2:0]  OP,
        input  wire [31:0] A,
        input  wire [31:0] B,
        input  wire [4:0]  Sh_Amt,
        output wire        Zero,
        output reg  [31:0] Y,
        output reg  [63:0] R64
    );

    assign Zero = (Y == 0);

    //32-bit output
    always @ (OP, A, B, Sh_Amt) begin
        case (OP)
            3'b010: Y = A + B;
            3'b110: Y = A - B;
            3'b000: Y = A & B;
            3'b001: Y = A | B;          
            3'b111: Y = (A < B) ? 1 : 0;
            3'b100: Y = A << Sh_Amt;
            3'b101: Y = A >> Sh_Amt;
            default: Y = 3'bx;
        endcase
    end
    
    //64-bit output (HI/LO)
    always @ (OP, A, B) begin
        case (OP)
            3'b011: R64 = A*B;
            default: R64 = 64'bx;
        endcase
    end

endmodule