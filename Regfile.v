module Regfile #(parameter WIDTH=32)(  
        input wire  [4:0]       RA1,
        input wire  [4:0]       RA2,
        input wire  [4:0]       RA3,
        input wire  [4:0]       WA,
        input wire  [WIDTH-1:0] WD,
        input wire              WE,
        output wire [WIDTH-1:0] RD1,
        output wire [WIDTH-1:0] RD2,
        output wire [WIDTH-1:0] RD3,
        input wire             CLK,
        input wire             RST
    );
    
    reg [31:0] RF [0:31];

    integer n;
    
    initial begin
        for (n = 0; n < 32; n = n + 1) RF[n] = 32'h0;
        RF[29] = 32'h100; // Initialze $sp
    end
    
    always @ (negedge CLK or posedge RST) begin
        if(RST) begin
            for (n = 0; n < 32; n = n + 1) RF[n] = 32'h0;
            RF[29] = 32'h100; // Initialze $sp
        end
        else if (WE && WA != 0) RF[WA] <= WD;
    end

    assign RD1 = (RA1 == 0) ? 0 : RF[RA1];
    assign RD2 = (RA2 == 0) ? 0 : RF[RA2];
    assign RD3 = (RA3 == 0) ? 0 : RF[RA3];

endmodule