module EXE_Fwd_Unit(
        input wire [4:0]    RA1,
        input wire [4:0]    RA2,
        input wire [4:0]    WA_EM,
        input wire          WE_EM,
        input wire [2:0]    WS_EM,
        input wire [4:0]    WA_MW,
        input wire          WE_MW,
        input wire [2:0]    WS_MW,
        output reg [2:0]    FW_Src_1,
        output reg [2:0]    FW_Src_2
    );
    
    //Forwarding for RD1
    always @ (*) begin
        if(WE_EM && WA_EM == RA1 && RA1 != 0) begin
            FW_Src_1 = WS_EM + 3'b1; //Forward data by selecting mux input
        end
        else if(WE_MW && WA_MW == RA1 && RA1 != 0) begin
            FW_Src_1 = 3'b101; //Forward data from WB stage by selecting mux input
        end
        
        else FW_Src_1 = 3'b000; //Not writing back, don't forward
    end
    
    //Fowarding for RD2
    always @ (*) begin
        if(WE_EM && WA_EM == RA2 && RA2 != 0) begin
            FW_Src_2 = WS_EM + 3'b1; //Forward data by selecting mux input
        end
        else if(WE_MW==1 && WA_MW == RA2 && RA2 != 0) begin
            FW_Src_2 = 3'b101; //Forward data from WB stage by selecting mux input
        end
        else FW_Src_2 = 3'b000; //Not writing back, don't forward
    end

endmodule