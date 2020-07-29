module R64_Reg # (parameter WIDTH = 32) (
        //Input
        input  wire [WIDTH-1:0] DLo,
        input  wire [WIDTH-1:0] DHi,
        //Output
        output reg  [WIDTH-1:0] QLo,
        output reg  [WIDTH-1:0] QHi,
        //Misc
        input  wire             EN,
        input  wire             CLK,
        input  wire             RST
    );

    always @ (posedge CLK, posedge RST) begin
        if (RST) begin
            QLo <= 0;
            QHi <= 0;
        end
        else if(EN) begin
            QLo <= DLo;
            QHi = DHi;
        end
        else begin
            QLo <= QLo;
            QHi <= QHi;
        end
    end
endmodule