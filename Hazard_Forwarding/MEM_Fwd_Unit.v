module MEM_Fwd_Unit(
        input wire  [4:0]   RA2,
        input wire  [4:0]   WA_MW,
        input wire          WE_MW,
        input wire  [2:0]   WS_MW,
        output reg          FW_Src
    );

    always @ (*) begin
        if(WE_MW && WA_MW == RA2 && RA2 != 0) FW_Src = 1'b1;
        else FW_Src = 1'b0;
    end


endmodule