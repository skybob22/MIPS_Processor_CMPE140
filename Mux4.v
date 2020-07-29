module Mux4 #(parameter WIDTH=32)(
        input wire  [WIDTH-1:0] In0,
        input wire  [WIDTH-1:0] In1,
        input wire  [WIDTH-1:0] In2,
        input wire  [WIDTH-1:0] In3,
        output reg  [WIDTH-1:0] Out,
        input wire  [1:0]       Sel
    );
    
    always @ (*) begin
        case (Sel)
            2'b00: Out = In0;
            2'b01: Out = In1;
            2'b10: Out = In2;
            2'b11: Out = In3;
        endcase
    end

endmodule