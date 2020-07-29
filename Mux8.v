module Mux8 #(parameter WIDTH=32)(
        input wire  [WIDTH-1:0] In0,
        input wire  [WIDTH-1:0] In1,
        input wire  [WIDTH-1:0] In2,
        input wire  [WIDTH-1:0] In3,
        input wire  [WIDTH-1:0] In4,
        input wire  [WIDTH-1:0] In5,
        input wire  [WIDTH-1:0] In6,
        input wire  [WIDTH-1:0] In7,
        output reg  [WIDTH-1:0] Out,
        input wire  [2:0]       Sel
    );
    
    always @ (*) begin
        case (Sel)
            3'b000: Out = In0;
            3'b001: Out = In1;
            3'b010: Out = In2;
            3'b011: Out = In3;
            3'b100: Out = In4;
            3'b101: Out = In5;
            3'b110: Out = In6;
            3'b111: Out = In7;
        endcase
    end

endmodule