module Sign_Ext #(parameter IN_WIDTH=16,parameter OUT_WIDTH=32)(
        input wire  [IN_WIDTH-1:0]   In,
        output wire [OUT_WIDTH-1:0]  Out
    );
    
    assign Out = {{OUT_WIDTH-IN_WIDTH{In[IN_WIDTH-1]}}, In};

endmodule