module multaNNx (
    input [15:0] aNN, // 1/aNN
    input [36:0] X_r, //input X_old
    output [36:0] X_n //output X_new
);

parameter pos_max = 32'b01111111111111111111111111111111;
parameter neg_max = 32'b10000000000000000000000000000000;
parameter HIGH = 5'b11111;
parameter HI = 2'b11;

reg [31:0] xr_sat;
reg [47:0] aNNx_sat;
reg [36:0] X_n_r;

assign X_n = X_n_r;

always @(*) begin
    if (X_r[36]) begin
        if (X_r[35:31] != HIGH) begin
            xr_sat = neg_max;
        end
        else begin
            xr_sat[31] = 1;
            xr_sat[30:0] = X_r[30:0]; 
        end
    end
    else begin
        if (X_r[35:31] != 0) begin
            xr_sat = pos_max;
        end
        else begin
            xr_sat[31] = 0;
            xr_sat[30:0] = X_r[30:0];
        end
    end

    aNNx_sat = $signed(xr_sat) * $signed(aNN);
    X_n_r[36:32] = 0;

    if (aNNx_sat[47]) begin
        if (aNNx_sat[46:45] != HI) begin
            X_n_r[31:0] = neg_max;
        end
        else begin
            X_n_r[31] = 1;
            X_n_r[30:0] = aNNx_sat[44:14];
        end
    end
    else begin
        if (aNNx_sat[46:45] != 0) begin
            X_n_r[31:0] = pos_max;
        end
        else begin
            X_n_r[31] = 0;
            X_n_r[30:0] = aNNx_sat[44:14];
        end
    end
end
    
endmodule