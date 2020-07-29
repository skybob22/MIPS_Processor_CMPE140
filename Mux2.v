module Mux2 #(parameter WIDTH=32)(
        input wire  [WIDTH-1:0] In0,
        input wire  [WIDTH-1:0] In1,
        output wire [WIDTH-1:0] Out,
        input wire              Sel
    );
    
    assign Out = (Sel)?In1:In0;

endmodule