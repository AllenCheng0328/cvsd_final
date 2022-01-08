module multbaNN (
    input [15:0] aNN,
    input [15:0] b,
    output [31:0] x_init
);

reg [31:0] ab_sat;
reg [31:0] x_init_w;
assign x_init = x_init_w;

parameter pos_max = 32'b01111111111111111111111111111111;
parameter neg_max = 32'b10000000000000000000000000000000;
parameter HIGH = 2'b11;

always @(*) begin
    ab_sat = $signed(aNN) * $signed(b);

    if (ab_sat[31]) begin
        if (ab_sat[30:29] != HIGH) begin
            x_init_w = neg_max;
        end
        else begin
            x_init_w[31] = 1;
            x_init_w[30:2] = ab_sat[28:0];
            x_init_w[1:0] = 0;
        end
    end
    else begin
        if (ab_sat[30:29] != 0) begin
            x_init_w = pos_max;
        end
        else begin
            x_init_w[31] = 0;
            x_init_w[30:2] = ab_sat[28:0];
            x_init_w[1:0] = 0;
        end
    end
end

    
endmodule