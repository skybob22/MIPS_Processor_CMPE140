module D_Reg #(parameter WIDTH=32)(
        input wire  [WIDTH-1:0] D,
        input wire              EN,
        input wire              CLK,
        input wire              RST,
        output reg [WIDTH-1:0] Q
    );
    
    always @(posedge CLK or posedge RST) begin
        if (RST) Q <= 0;
        else if (EN) Q <= D;
        else Q <= Q;
    end

endmodule