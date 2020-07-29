module IF_ID_Reg(
        input wire  [31:0]  PC_Plus_4_In,
        input wire  [31:0]  Instr_In,
        output reg  [31:0]  PC_Plus_4_Out,
        output reg  [31:0]  Instr_Out,
        input wire          EN,
        input wire          CLK,
        input wire          RST       
    );

    always @ (posedge CLK or posedge RST) begin
        if (RST) begin
            PC_Plus_4_Out <= 32'd0;
            Instr_Out <= 32'd0;
        end
        else if (EN) begin
            PC_Plus_4_Out <= PC_Plus_4_In;
            Instr_Out <= Instr_In;
        end
        else begin
            PC_Plus_4_Out <= PC_Plus_4_Out;
            Instr_Out <= Instr_Out;
        end
    end


endmodule
