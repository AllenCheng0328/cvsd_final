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
    X_n_r[36:32] = {5{aNNx_sat[47]}};

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

module GSIM (                       //Don't modify interface
	input          i_clk,
	input          i_reset,
	input          i_module_en,
	input  [  4:0] i_matrix_num,
	output         o_proc_done,

	// matrix memory
	output         o_mem_rreq,
	output [  9:0] o_mem_addr,
	input          i_mem_rrdy,
	input  [255:0] i_mem_dout,
	input          i_mem_dout_vld,
	
	// output result
	output         o_x_wen,
	output [  8:0] o_x_addr,
	output [ 31:0] o_x_data  
);

parameter INIT = 1'b0;
parameter ITER = 1'b1;

wire [15:0] aNN, a[0:14];
wire [15:0] b;
wire [36:0] x_old, x_new; //for mult_aNNx
wire [31:0] x_in, x_out[0:14]; //for mult_ax:same input for different output;
wire [31:0] x_init; //for mult_baNN
wire b_enable;
wire x_enable;
wire out_enable;

multaNNx aNNx(.aNN(aNN), .X_r(x_old), .X_n(x_new));
multax ax0(.a(a[0]), .x_in(x_in), .x_out(x_out[0]));
multax ax1(.a(a[1]), .x_in(x_in), .x_out(x_out[1]));
multax ax2(.a(a[2]), .x_in(x_in), .x_out(x_out[2]));
multax ax3(.a(a[3]), .x_in(x_in), .x_out(x_out[3]));
multax ax4(.a(a[4]), .x_in(x_in), .x_out(x_out[4]));
multax ax5(.a(a[5]), .x_in(x_in), .x_out(x_out[5]));
multax ax6(.a(a[6]), .x_in(x_in), .x_out(x_out[6]));
multax ax7(.a(a[7]), .x_in(x_in), .x_out(x_out[7]));
multax ax8(.a(a[8]), .x_in(x_in), .x_out(x_out[8]));
multax ax9(.a(a[9]), .x_in(x_in), .x_out(x_out[9]));
multax ax10(.a(a[10]), .x_in(x_in), .x_out(x_out[10]));
multax ax11(.a(a[11]), .x_in(x_in), .x_out(x_out[11]));
multax ax12(.a(a[12]), .x_in(x_in), .x_out(x_out[12]));
multax ax13(.a(a[13]), .x_in(x_in), .x_out(x_out[13]));
multax ax14(.a(a[14]), .x_in(x_in), .x_out(x_out[14]));
multbaNN baNN(.aNN(aNN), .b(b), .x_init(x_init));

reg [15:0] aNN_w, a_w[0:14]; 
reg [15:0] b_w;
reg [36:0] x_old_w;
reg [31:0] x_in_w;

assign aNN = aNN_w;
assign a[0] = a_w[0];
assign a[1] = a_w[1];
assign a[2] = a_w[2];
assign a[3] = a_w[3];
assign a[4] = a_w[4];
assign a[5] = a_w[5];
assign a[6] = a_w[6];
assign a[7] = a_w[7];
assign a[8] = a_w[8];
assign a[9] = a_w[9];
assign a[10] = a_w[10];
assign a[11] = a_w[11];
assign a[12] = a_w[12];
assign a[13] = a_w[13];
assign a[14] = a_w[14];
assign b = b_w;
assign x_old = x_old_w;
assign x_in = x_in_w;
 
reg [15:0] matrix_b_r[1:16], matrix_b_w[1:16]; 
reg [36:0] matrix_x_r[1:16], matrix_x_w[1:16];

reg [6:0] mem_addr;
reg [6:0] mem_addr_r;
reg state_r, state_w;

reg [5:0] data_cnt_r, data_cnt_w;
reg [4:0] recur_cnt_r, recur_cnt_w;
reg [4:0] matrix_cnt_r, matrix_cnt_w;  // need solve ?? how many matrix ????????

reg x_wen_r, x_wen_w;
reg [8:0] x_addr_r, x_addr_w;
reg [31:0] x_data_r, x_data_w;
reg done_r, done_w;

integer j;

assign b_enable = ((state_r == 0) && (data_cnt_r == 0) && (i_mem_dout_vld));
assign x_enable = ((i_mem_dout_vld) && (i_module_en));
assign out_enable = (recur_cnt_r == 17);
assign o_proc_done = done_r & i_module_en;
assign o_mem_rreq = 1'b1;
assign o_mem_addr = mem_addr + (matrix_cnt_r << 4) + matrix_cnt_r;

assign o_x_wen = x_wen_r;
assign o_x_addr = x_addr_r;
assign o_x_data = x_data_r;

always @(*) begin
	for (j = 1; j < 17; j = j+1) begin
		matrix_b_w[j] = matrix_b_r[j];
		matrix_x_w[j] = matrix_x_r[j];
	end
	data_cnt_w = data_cnt_r;
	recur_cnt_w = recur_cnt_r;
	matrix_cnt_w = matrix_cnt_r;
	state_w = state_r;
	mem_addr = (data_cnt_r == 0)?16:mem_addr_r;
	x_wen_w = x_wen_r;
	x_addr_w = x_addr_r;
	x_data_w = x_data_r;
	done_w = done_r;

	x_old_w = 0;
	x_in_w = 0;
	aNN_w = 0;
	b_w = 0;
	for (j = 0; j < 15; j = j+1) begin
		a_w[j] = 0;
	end
	if (i_mem_rrdy) begin
	end
	if (i_module_en) begin
		if (i_mem_dout_vld) begin
			case (state_r)
				INIT: begin
					if (matrix_cnt_r == i_matrix_num) begin
						done_w = 1;
					end
					x_wen_w = 0;
					if (data_cnt_r == 0) begin //b1-16
						for (j = 1; j < 17; j = j+1) begin
							matrix_b_w[j][15:0] = i_mem_dout[j*16-1-:16];
						end
						data_cnt_w = data_cnt_r + 1;
						mem_addr = 0;
					end
					else if (data_cnt_r == 16) begin
						aNN_w = i_mem_dout[255:240];
						b_w = matrix_b_r[16];
						matrix_x_w[16] = {{5{x_init[31]}},x_init}; //X16,0
						data_cnt_w = 1;
						mem_addr = 0;
						recur_cnt_w = 1;
						state_w = ITER;
					end
					else begin
						aNN_w = i_mem_dout[(data_cnt_r<<4)-1-:16];
						b_w = matrix_b_r[data_cnt_r];
						matrix_x_w[data_cnt_r] = {{5{x_init[31]}},x_init}; //X?,0
						data_cnt_w = data_cnt_r + 1;
						mem_addr = {1'b0, data_cnt_r};
					end
				end
				ITER: begin
					case (data_cnt_r)
						1: begin
							x_old_w = matrix_x_r[1];
							aNN_w = i_mem_dout[15:0];
							x_in_w = (recur_cnt_r == 1) ? matrix_x_r[1][31:0] : x_new[31:0];
							if (recur_cnt_r != 17) begin
								matrix_x_w[1][31:0] = matrix_b_r[1] << 16;	// diagonal
								matrix_x_w[1][36:32] = {5{matrix_b_r[1][15]}};
							end
							else begin
								x_data_w = x_new[31:0];
								x_addr_w = x_addr_r + 1;
								x_wen_w = 1;
							end
							if (recur_cnt_r != 1) begin	// Lower triangle
								for (j = 2; j < 17; j = j+1) begin
									a_w[j-2] = i_mem_dout[j*16-1-:16];
									matrix_x_w[j] = $signed(matrix_x_r[j][35:0]) - $signed(x_out[j-2]);
								end
							end
							data_cnt_w = data_cnt_r + 1;
							mem_addr = 1;
						end
						2: begin
							x_old_w = matrix_x_r[2];
							aNN_w = i_mem_dout[31:16];
							x_in_w = (recur_cnt_r == 1) ? matrix_x_r[2][31:0] : x_new[31:0];
							if (recur_cnt_r != 17) begin
								for (j = 1; j < 2; j = j+1) begin	// Upper triangle
									a_w[j-1] = i_mem_dout[j*16-1-:16];
									matrix_x_w[j] = $signed(matrix_x_r[j][35:0]) - $signed(x_out[j-1]);
								end
								matrix_x_w[2][31:0] = matrix_b_r[2] << 16;	// diagonal
								matrix_x_w[2][36:32] = {5{matrix_b_r[2][15]}};
							end
							else begin
								x_data_w = x_new[31:0];
								x_addr_w = x_addr_r + 1;
								x_wen_w = 1;
							end
							if (recur_cnt_r != 1) begin	// Lower triangle
								for (j = 3; j < 17; j = j+1) begin	
									a_w[j-2] = i_mem_dout[j*16-1-:16];
									matrix_x_w[j] = $signed(matrix_x_r[j][35:0]) - $signed(x_out[j-2]);
								end
							end
							data_cnt_w = data_cnt_r + 1;
							mem_addr = 2;
						end
						3: begin
							x_old_w = matrix_x_r[3];
							aNN_w = i_mem_dout[47:32];
							x_in_w = (recur_cnt_r == 1) ? matrix_x_r[3][31:0] : x_new[31:0];
							if (recur_cnt_r != 17) begin
								for (j = 1; j < 3; j = j+1) begin	// Upper triangle
									a_w[j-1] = i_mem_dout[j*16-1-:16];
									matrix_x_w[j] = $signed(matrix_x_r[j][35:0]) - $signed(x_out[j-1]);
								end
								matrix_x_w[3][31:0] = matrix_b_r[3] << 16;	// diagonal
								matrix_x_w[3][36:32] = {5{matrix_b_r[3][15]}};
							end
							else begin
								x_data_w = x_new[31:0];
								x_addr_w = x_addr_r + 1;
								x_wen_w = 1;
							end
							if (recur_cnt_r != 1) begin	// Lower triangle
								for (j = 4; j < 17; j = j+1) begin
									a_w[j-2] = i_mem_dout[j*16-1-:16];
									matrix_x_w[j] = $signed(matrix_x_r[j][35:0]) - $signed(x_out[j-2]);
								end
							end
							data_cnt_w = data_cnt_r + 1;
							mem_addr = 3;
						end
						4: begin
							x_old_w = matrix_x_r[4];
							aNN_w = i_mem_dout[63:48];
							x_in_w = (recur_cnt_r == 1) ? matrix_x_r[4][31:0] : x_new[31:0];
							if (recur_cnt_r != 17) begin
								for (j = 1; j < 4; j = j+1) begin	// Upper triangle
									a_w[j-1] = i_mem_dout[j*16-1-:16];
									matrix_x_w[j] = $signed(matrix_x_r[j][35:0]) - $signed(x_out[j-1]);
								end
								matrix_x_w[4][31:0] = matrix_b_r[4] << 16;	// diagonal
								matrix_x_w[4][36:32] = {5{matrix_b_r[4][15]}};
							end
							else begin
								x_data_w = x_new[31:0];
								x_addr_w = x_addr_r + 1;
								x_wen_w = 1;
							end
							if (recur_cnt_r != 1) begin	// Lower triangle
								for (j = 5; j < 17; j = j+1) begin
									a_w[j-2] = i_mem_dout[j*16-1-:16];
									matrix_x_w[j] = $signed(matrix_x_r[j][35:0]) - $signed(x_out[j-2]);
								end
							end
							data_cnt_w = data_cnt_r + 1;
							mem_addr = 4;
						end
						5: begin
							x_old_w = matrix_x_r[5];
							aNN_w = i_mem_dout[79:64];
							x_in_w = (recur_cnt_r == 1) ? matrix_x_r[5][31:0] : x_new[31:0];
							if (recur_cnt_r != 17) begin
								for (j = 1; j < 5; j = j+1) begin	// Upper triangle
									a_w[j-1] = i_mem_dout[j*16-1-:16];
									matrix_x_w[j] = $signed(matrix_x_r[j][35:0]) - $signed(x_out[j-1]);
								end
								matrix_x_w[5][31:0] = matrix_b_r[5] << 16;	// diagonal
								matrix_x_w[5][36:32] = {5{matrix_b_r[5][15]}};
							end
							else begin
								x_data_w = x_new[31:0];
								x_addr_w = x_addr_r + 1;
								x_wen_w = 1;
							end
							if (recur_cnt_r != 1) begin	// Lower triangle
								for (j = 6; j < 17; j = j+1) begin
									a_w[j-2] = i_mem_dout[j*16-1-:16];
									matrix_x_w[j] = $signed(matrix_x_r[j][35:0]) - $signed(x_out[j-2]);
								end
							end
							data_cnt_w = data_cnt_r + 1;
							mem_addr = 5;
						end
						6: begin
							x_old_w = matrix_x_r[6];
							aNN_w = i_mem_dout[95:80];
							x_in_w = (recur_cnt_r == 1) ? matrix_x_r[6][31:0] : x_new[31:0];
							if (recur_cnt_r != 17) begin
								for (j = 1; j < 6; j = j+1) begin
									a_w[j-1] = i_mem_dout[j*16-1-:16];
									matrix_x_w[j] = $signed(matrix_x_r[j][35:0]) - $signed(x_out[j-1]);
								end
								matrix_x_w[6][31:0] = matrix_b_r[6] << 16;	// diagonal
								matrix_x_w[6][36:32] = {5{matrix_b_r[6][15]}};
							end
							else begin
								x_data_w = x_new[31:0];
								x_addr_w = x_addr_r + 1;
								x_wen_w = 1;
							end
							if (recur_cnt_r != 1) begin
								for (j = 7; j < 17; j = j+1) begin
									a_w[j-2] = i_mem_dout[j*16-1-:16];
									matrix_x_w[j] = $signed(matrix_x_r[j][35:0]) - $signed(x_out[j-2]);
								end
							end
							data_cnt_w = data_cnt_r + 1;
							mem_addr = 6;
						end
						7: begin
							x_old_w = matrix_x_r[7];
							aNN_w = i_mem_dout[111:96];
							x_in_w = (recur_cnt_r == 1) ? matrix_x_r[7][31:0] : x_new[31:0];
							if (recur_cnt_r != 17) begin
								for (j = 1; j < 7; j = j+1) begin
									a_w[j-1] = i_mem_dout[j*16-1-:16];
									matrix_x_w[j] = $signed(matrix_x_r[j][35:0]) - $signed(x_out[j-1]);
								end
								matrix_x_w[7][31:0] = matrix_b_r[7] << 16;	// diagonal
								matrix_x_w[7][36:32] = {5{matrix_b_r[7][15]}};
							end
							else begin
								x_data_w = x_new[31:0];
								x_addr_w = x_addr_r + 1;
								x_wen_w = 1;
							end
							if (recur_cnt_r != 1) begin
								for (j = 8; j < 17; j = j+1) begin
									a_w[j-2] = i_mem_dout[j*16-1-:16];
									matrix_x_w[j] = $signed(matrix_x_r[j][35:0]) - $signed(x_out[j-2]);
								end
							end
							data_cnt_w = data_cnt_r + 1;
							mem_addr = 7;
						end
						8: begin
							x_old_w = matrix_x_r[8];
							aNN_w = i_mem_dout[127:112];
							x_in_w = (recur_cnt_r == 1) ? matrix_x_r[8][31:0] : x_new[31:0];
							if (recur_cnt_r != 17) begin
								for (j = 1; j < 8; j = j+1) begin
									a_w[j-1] = i_mem_dout[j*16-1-:16];
									matrix_x_w[j] = $signed(matrix_x_r[j][35:0]) - $signed(x_out[j-1]);
								end
								matrix_x_w[8][31:0] = matrix_b_r[8] << 16;	// diagonal
								matrix_x_w[8][36:32] = {5{matrix_b_r[8][15]}};
							end
							else begin
								x_data_w = x_new[31:0];
								x_addr_w = x_addr_r + 1;
								x_wen_w = 1;
							end
							if (recur_cnt_r != 1) begin
								for (j = 9; j < 17; j = j+1) begin
									a_w[j-2] = i_mem_dout[j*16-1-:16];
									matrix_x_w[j] = $signed(matrix_x_r[j][35:0]) - $signed(x_out[j-2]);
								end
							end
							data_cnt_w = data_cnt_r + 1;
							mem_addr = 8;
						end
						9: begin
							x_old_w = matrix_x_r[9];
							aNN_w = i_mem_dout[143:128];
							x_in_w = (recur_cnt_r == 1) ? matrix_x_r[9][31:0] : x_new[31:0];
							if (recur_cnt_r != 17) begin
								for (j = 1; j < 9; j = j+1) begin
									a_w[j-1] = i_mem_dout[j*16-1-:16];
									matrix_x_w[j] = $signed(matrix_x_r[j][35:0]) - $signed(x_out[j-1]);
								end
								matrix_x_w[9][31:0] = matrix_b_r[9] << 16;	// diagonal
								matrix_x_w[9][36:32] = {5{matrix_b_r[9][15]}};
							end
							else begin
								x_data_w = x_new[31:0];
								x_addr_w = x_addr_r + 1;
								x_wen_w = 1;
							end
							if (recur_cnt_r != 1) begin
								for (j = 10; j < 17; j = j+1) begin
									a_w[j-2] = i_mem_dout[j*16-1-:16];
									matrix_x_w[j] = $signed(matrix_x_r[j][35:0]) - $signed(x_out[j-2]);
								end
							end
							data_cnt_w = data_cnt_r + 1;
							mem_addr = 9;
						end
						10: begin
							x_old_w = matrix_x_r[10];
							aNN_w = i_mem_dout[159:144];
							x_in_w = (recur_cnt_r == 1) ? matrix_x_r[10][31:0] : x_new[31:0];
							if (recur_cnt_r != 17) begin
								for (j = 1; j < 10; j = j+1) begin
									a_w[j-1] = i_mem_dout[j*16-1-:16];
									matrix_x_w[j] = $signed(matrix_x_r[j][35:0]) - $signed(x_out[j-1]);
								end
								matrix_x_w[10][31:0] = matrix_b_r[10] << 16;	// diagonal
								matrix_x_w[10][36:32] = {5{matrix_b_r[10][15]}};
							end
							else begin
								x_data_w = x_new[31:0];
								x_addr_w = x_addr_r + 1;
								x_wen_w = 1;
							end
							if (recur_cnt_r != 1) begin
								for (j = 11; j < 17; j = j+1) begin
									a_w[j-2] = i_mem_dout[j*16-1-:16];
									matrix_x_w[j] = $signed(matrix_x_r[j][35:0]) - $signed(x_out[j-2]);
								end
							end
							data_cnt_w = data_cnt_r + 1;
							mem_addr = 10;
						end
						11: begin
							x_old_w = matrix_x_r[11];
							aNN_w = i_mem_dout[175:160];
							x_in_w = (recur_cnt_r == 1) ? matrix_x_r[11][31:0] : x_new[31:0];
							if (recur_cnt_r != 17) begin
								for (j = 1; j < 11; j = j+1) begin
									a_w[j-1] = i_mem_dout[j*16-1-:16];
									matrix_x_w[j] = $signed(matrix_x_r[j][35:0]) - $signed(x_out[j-1]);
								end
								matrix_x_w[11][31:0] = matrix_b_r[11] << 16;	// diagonal
								matrix_x_w[11][36:32] = {5{matrix_b_r[11][15]}};
							end
							else begin
								x_data_w = x_new[31:0];
								x_addr_w = x_addr_r + 1;
								x_wen_w = 1;
							end
							if (recur_cnt_r != 1) begin
								for (j = 12; j < 17; j = j+1) begin
									a_w[j-2] = i_mem_dout[j*16-1-:16];
									matrix_x_w[j] = $signed(matrix_x_r[j][35:0]) - $signed(x_out[j-2]);
								end
							end
							data_cnt_w = data_cnt_r + 1;
							mem_addr = 11;
						end
						12: begin
							x_old_w = matrix_x_r[12];
							aNN_w = i_mem_dout[191:176];
							x_in_w = (recur_cnt_r == 1) ? matrix_x_r[12][31:0] : x_new[31:0];
							if (recur_cnt_r != 17) begin
								for (j = 1; j < 12; j = j+1) begin
									a_w[j-1] = i_mem_dout[j*16-1-:16];
									matrix_x_w[j] = $signed(matrix_x_r[j][35:0]) - $signed(x_out[j-1]);
								end
								matrix_x_w[12][31:0] = matrix_b_r[12] << 16;	// diagonal
								matrix_x_w[12][36:32] = {5{matrix_b_r[12][15]}};
							end
							else begin
								x_data_w = x_new[31:0];
								x_addr_w = x_addr_r + 1;
								x_wen_w = 1;
							end
							if (recur_cnt_r != 1) begin
								for (j = 13; j < 17; j = j+1) begin
									a_w[j-2] = i_mem_dout[j*16-1-:16];
									matrix_x_w[j] = $signed(matrix_x_r[j][35:0]) - $signed(x_out[j-2]);
								end
							end
							data_cnt_w = data_cnt_r + 1;
							mem_addr = 12;
						end
						13: begin
							x_old_w = matrix_x_r[13];
							aNN_w = i_mem_dout[207:192];
							x_in_w = (recur_cnt_r == 1) ? matrix_x_r[13][31:0] : x_new[31:0];
							if (recur_cnt_r != 17) begin
								for (j = 1; j < 13; j = j+1) begin
									a_w[j-1] = i_mem_dout[j*16-1-:16];
									matrix_x_w[j] = $signed(matrix_x_r[j][35:0]) - $signed(x_out[j-1]);
								end
								matrix_x_w[13][31:0] = matrix_b_r[13] << 16;	// diagonal
								matrix_x_w[13][36:32] = {5{matrix_b_r[13][15]}};
							end
							else begin
								x_data_w = x_new[31:0];
								x_addr_w = x_addr_r + 1;
								x_wen_w = 1;
							end
							if (recur_cnt_r != 1) begin
								for (j = 14; j < 17; j = j+1) begin
									a_w[j-2] = i_mem_dout[j*16-1-:16];
									matrix_x_w[j] = $signed(matrix_x_r[j][35:0]) - $signed(x_out[j-2]);
								end
							end
							data_cnt_w = data_cnt_r + 1;
							mem_addr = 13;
						end
						14: begin
							x_old_w = matrix_x_r[14];
							aNN_w = i_mem_dout[223:208];
							x_in_w = (recur_cnt_r == 1) ? matrix_x_r[14][31:0] : x_new[31:0];
							if (recur_cnt_r != 17) begin
								for (j = 1; j < 14; j = j+1) begin
									a_w[j-1] = i_mem_dout[j*16-1-:16];
									matrix_x_w[j] = $signed(matrix_x_r[j][35:0]) - $signed(x_out[j-1]);
								end
								matrix_x_w[14][31:0] = matrix_b_r[14] << 16;	// diagonal
								matrix_x_w[14][36:32] = {5{matrix_b_r[14][15]}};
							end
							else begin
								x_data_w = x_new[31:0];
								x_addr_w = x_addr_r + 1;
								x_wen_w = 1;
							end
							if (recur_cnt_r != 1) begin
								for (j = 15; j < 17; j = j+1) begin
									a_w[j-2] = i_mem_dout[j*16-1-:16];
									matrix_x_w[j] = $signed(matrix_x_r[j][35:0]) - $signed(x_out[j-2]);
								end
							end
							data_cnt_w = data_cnt_r + 1;
							mem_addr = 14;
						end
						15: begin
							x_old_w = matrix_x_r[15];
							aNN_w = i_mem_dout[239:224];
							x_in_w = (recur_cnt_r == 1) ? matrix_x_r[15][31:0] : x_new[31:0];
							if (recur_cnt_r != 17) begin
								for (j = 1; j < 15; j = j+1) begin
									a_w[j-1] = i_mem_dout[j*16-1-:16];
									matrix_x_w[j] = $signed(matrix_x_r[j][35:0]) - $signed(x_out[j-1]);
								end
								matrix_x_w[15][31:0] = matrix_b_r[15] << 16;	// diagonal
								matrix_x_w[15][36:32] = {5{matrix_b_r[15][15]}};
							end
							else begin
								x_data_w = x_new[31:0];
								x_addr_w = x_addr_r + 1;
								x_wen_w = 1;
								//matrix_cnt_w = matrix_cnt_r + 1;
							end
							if (recur_cnt_r != 1) begin
								a_w[14] = i_mem_dout[255:240];
								matrix_x_w[16] = $signed(matrix_x_r[16][35:0]) - $signed(x_out[14]);
							end
							data_cnt_w = data_cnt_r + 1;
							mem_addr = 15;
						end
						16: begin
							x_old_w = matrix_x_r[16];
							aNN_w = i_mem_dout[255:240];
							x_in_w = (recur_cnt_r == 1) ? matrix_x_r[16][31:0] : x_new[31:0];
							data_cnt_w = 1;
							recur_cnt_w = recur_cnt_r + 1;
							mem_addr = 0;
							if (recur_cnt_r != 17) begin
								for (j = 1; j < 16; j = j+1) begin
									a_w[j-1] = i_mem_dout[j*16-1-:16];
									matrix_x_w[j] = $signed(matrix_x_r[j][35:0]) - $signed(x_out[j-1]);
								end
								matrix_x_w[16][31:0] = matrix_b_r[16] << 16;	// diagonal
								matrix_x_w[16][36:32] = {5{matrix_b_r[16][15]}};
							end
							else begin
								state_w = INIT;
								x_data_w = x_new[31:0];
								x_addr_w = x_addr_r + 1;
								x_wen_w = 1;
								mem_addr = 32+1;
								matrix_cnt_w = matrix_cnt_r + 1;
								data_cnt_w = 0;
								recur_cnt_w = 0;
							end
						end
						default: begin
						end
					endcase
				end
				default: begin
				end
			endcase
		end
	end
end

always @(posedge i_clk or posedge i_reset) begin
	if (i_reset) begin
		for (j = 1; j < 17; j = j+1) begin
			matrix_b_r[j] <= 0;
			matrix_x_r[j] <= 0;
		end
		mem_addr_r <= 16;
		data_cnt_r <= 0;
		recur_cnt_r <= 0;
		matrix_cnt_r <= 0;
		state_r <= 0;
		x_wen_r <= 0;
		x_addr_r <= 9'b111111111;
		x_data_r <= 0;
		done_r <= 0;
	end
	else begin
		if (b_enable) begin
			for (j = 1; j < 17; j = j+1) begin
				matrix_b_r[j] <= matrix_b_w[j];
			end
		end
		else begin
			for (j = 1; j < 17; j = j+1) begin
				matrix_b_r[j] <= matrix_b_r[j];
			end
		end
		if (x_enable) begin
			for (j = 1; j < 17; j = j+1) begin
				matrix_x_r[j] <= matrix_x_w[j];
			end
		end
		else begin
			for (j = 1; j < 17; j = j+1) begin
				matrix_x_r[j] <= matrix_x_r[j];
			end
		end
		if (out_enable) begin
			x_data_r <= x_data_w;
		end
		else begin
			x_data_r <= x_data_r;
		end		
		mem_addr_r <= mem_addr;
		data_cnt_r <= data_cnt_w;
		recur_cnt_r <= recur_cnt_w;
		matrix_cnt_r <= matrix_cnt_w;
		state_r <= state_w;
		x_wen_r <= x_wen_w;
		x_addr_r <= x_addr_w;		
		done_r <= done_w;
	end
end

endmodule
