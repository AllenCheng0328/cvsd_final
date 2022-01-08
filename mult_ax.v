module multax (
    input [15:0] a,
    input [31:0] x_in,
    output [31:0] x_out
);

parameter pos_max = 32'b01111111111111111111111111111111;
parameter neg_max = 32'b10000000000000000000000000000000;
parameter high = 16'b1111111111111111;

reg [47:0] ax_sat;
reg [31:0] x_out_r;

assign x_out = x_out_r;

always @(*) begin
    ax_sat = $signed(a) * $signed(x_in);

    if (ax_sat[47]) begin
        if (ax_sat[46:31] != high) begin
            x_out_r = neg_max;
        end
        else begin
            x_out_r[31] = 1;
            x_out_r[30:0] = ax_sat[30:0];
        end
    end
    else begin
        if (ax_sat[46:31] != 0) begin
            x_out_r = pos_max;
        end
        else begin
            x_out_r[31] = 0;
            x_out_r[30:0] = ax_sat[30:0];
        end
    end
end

endmodule