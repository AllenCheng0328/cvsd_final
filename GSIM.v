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

parameter INIT = 4'b0000;
parameter ITER = 4'b0001;
parameter STOP = 4'b0010;

wire [15:0] aNN, a[0:14];
wire [15:0] b;
wire [36:0] x_old, x_new; //for mult_aNNx
wire [31:0] x_in, x_out[0:14]; //for mult_ax:same input for different output;
wire [31:0] x_init; //for mult_baNN

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
genvar i;
for (i = 0; i < 15; i = i+1) begin
	assign a[i] = a_w[i];
end
assign b = b_w;
assign x_old = x_old_w;
assign x_in = x_in_w;
 
reg [15:0] matrix_b_r[1:16], matrix_b_w[1:16]; 
reg [36:0] matrix_x_r[1:16], matrix_x_w[1:16];

reg [31:0] buffer_x_r, buffer_x_w;
reg [9:0] mem_addr;
reg [3:0] state_r, state_w;

reg [8:0] data_cnt_r, data_cnt_w;
reg [4:0] recur_cnt_r, recur_cnt_w;

integer j;

assign o_proc_done = 1'b0;
assign o_mem_rreq = 1'b1;
assign o_mem_addr = mem_addr;

always @(*) begin
	for (j = 1; j < 17; j = j+1) begin
		matrix_b_w[j] = matrix_b_r[j];
		matrix_x_w[j] = matrix_x_r[j];
	end
	buffer_x_w = buffer_x_r;
	data_cnt_w = data_cnt_r;
	recur_cnt_w = recur_cnt_r;
	state_w = state_r;
	mem_addr = 16;
	if (i_module_en) begin
		if (i_mem_dout_vld) begin
			case (state_r)
				INIT: begin
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
						matrix_x_w[16] = x_init; //X16,0
						data_cnt_w = 1;
						mem_addr = 0;
						recur_cnt_w = 1;
						state_w = ITER;
					end
					else begin
						aNN_w = i_mem_dout[(data_cnt_r<<4)-1-:16];
						b_w = matrix_b_r[data_cnt_r];
						matrix_x_w[data_cnt_r] = x_init; //X?,0
						data_cnt_w = data_cnt_r + 1;
						mem_addr = data_cnt_r;
					end
				end
				ITER: begin
					case (data_cnt_r)
						1: begin
							x_old_w = matrix_x_r[1];
							aNN_w = i_mem_dout[15:0];
							x_in_w = x_new;
							if (recur_cnt_r != 17) begin
								matrix_x_w[1] = matrix_b_r[1];	// diagonal
							end
							else begin
								matrix_x_w[1] = x_new;
							end
							if (recur_cnt_r != 1) begin	// Lower triangle
								for (j = 2; j < 17; j = j+1) begin
									a_w[j-2] = i_mem_dout[j*16-1-:16];
									matrix_x_w[j] = $signed(matrix_x_r[j]) - $signed(x_out[j-2]);
								end
							end
							data_cnt_w = data_cnt_r + 1;
							mem_addr = 1;
						end
						2: begin
							x_old_w = matrix_x_r[2];
							aNN_w = i_mem_dout[31:16];
							x_in_w = x_new;
							if (recur_cnt_r != 17) begin
								for (j = 1; j < 2; j = j+1) begin	// Upper triangle
									a_w[j-1] = i_mem_dout[j*16-1-:16];
									matrix_x_w[j] = $signed(matrix_x_r[j]) - $signed(x_out[j-1]);
								end
								matrix_x_w[2] = matrix_b_r[2];	// diagonal
							end
							else begin
								matrix_x_w[2] = x_new;
							end
							if (recur_cnt_r != 1) begin	// Lower triangle
								for (j = 3; j < 17; j = j+1) begin	
									a_w[j-2] = i_mem_dout[j*16-1-:16];
									matrix_x_w[j] = $signed(matrix_x_r[j]) - $signed(x_out[j-2]);
								end
							end
							data_cnt_w = data_cnt_r + 1;
							mem_addr = 2;
						end
						3: begin
							x_old_w = matrix_x_r[3];
							aNN_w = i_mem_dout[47:32];
							x_in_w = x_new;
							if (recur_cnt_r != 17) begin
								for (j = 1; j < 3; j = j+1) begin	// Upper triangle
									a_w[j-1] = i_mem_dout[j*16-1-:16];
									matrix_x_w[j] = $signed(matrix_x_r[j]) - $signed(x_out[j-1]);
								end
								matrix_x_w[3] = matrix_b_r[3];	// diagonal
							end
							else begin
								matrix_x_w[3] = x_new;
							end
							if (recur_cnt_r != 1) begin	// Lower triangle
								for (j = 4; j < 17; j = j+1) begin
									a_w[j-2] = i_mem_dout[j*16-1-:16];
									matrix_x_w[j] = $signed(matrix_x_r[j]) - $signed(x_out[j-2]);
								end
							end
							data_cnt_w = data_cnt_r + 1;
							mem_addr = 3;
						end
						4: begin
							x_old_w = matrix_x_r[4];
							aNN_w = i_mem_dout[63:48];
							x_in_w = x_new;
							if (recur_cnt_r != 17) begin
								for (j = 1; j < 4; j = j+1) begin	// Upper triangle
									a_w[j-1] = i_mem_dout[j*16-1-:16];
									matrix_x_w[j] = $signed(matrix_x_r[j]) - $signed(x_out[j-1]);
								end
								matrix_x_w[4] = matrix_b_r[4];	// diagonal
							end
							else begin
								matrix_x_w[4] = x_new;
							end
							if (recur_cnt_r != 1) begin	// Lower triangle
								for (j = 5; j < 17; j = j+1) begin
									a_w[j-2] = i_mem_dout[j*16-1-:16];
									matrix_x_w[j] = $signed(matrix_x_r[j]) - $signed(x_out[j-2]);
								end
							end
							data_cnt_w = data_cnt_r + 1;
							mem_addr = 4;
						end
						5: begin
							x_old_w = matrix_x_r[5];
							aNN_w = i_mem_dout[79:64];
							x_in_w = x_new;
							if (recur_cnt_r != 17) begin
								for (j = 1; j < 5; j = j+1) begin	// Upper triangle
									a_w[j-1] = i_mem_dout[j*16-1-:16];
									matrix_x_w[j] = $signed(matrix_x_r[j]) - $signed(x_out[j-1]);
								end
								matrix_x_w[5] = matrix_b_r[5];	// diagonal
							end
							else begin
								matrix_x_w[5] = x_new;
							end
							if (recur_cnt_r != 1) begin	// Lower triangle
								for (j = 6; j < 17; j = j+1) begin
									a_w[j-2] = i_mem_dout[j*16-1-:16];
									matrix_x_w[j] = $signed(matrix_x_r[j]) - $signed(x_out[j-2]);
								end
							end
							data_cnt_w = data_cnt_r + 1;
							mem_addr = 5;
						end
						6: begin
							x_old_w = matrix_x_r[6];
							aNN_w = i_mem_dout[95:80];
							x_in_w = x_new;
							if (recur_cnt_r != 17) begin
								for (j = 1; j < 6; j = j+1) begin
									a_w[j-1] = i_mem_dout[j*16-1-:16];
									matrix_x_w[j] = $signed(matrix_x_r[j]) - $signed(x_out[j-1]);
								end
								matrix_x_w[6] = matrix_b_r[6];
							end
							else begin
								matrix_x_w[6] = x_new;
							end
							if (recur_cnt_r != 1) begin
								for (j = 7; j < 17; j = j+1) begin
									a_w[j-2] = i_mem_dout[j*16-1-:16];
									matrix_x_w[j] = $signed(matrix_x_r[j]) - $signed(x_out[j-2]);
								end
							end
							data_cnt_w = data_cnt_r + 1;
							mem_addr = 6;
						end
						7: begin
							x_old_w = matrix_x_r[7];
							aNN_w = i_mem_dout[111:96];
							x_in_w = x_new;
							if (recur_cnt_r != 17) begin
								for (j = 1; j < 7; j = j+1) begin
									a_w[j-1] = i_mem_dout[j*16-1-:16];
									matrix_x_w[j] = $signed(matrix_x_r[j]) - $signed(x_out[j-1]);
								end
								matrix_x_w[7] = matrix_b_r[7];
							end
							else begin
								matrix_x_w[7] = x_new;
							end
							if (recur_cnt_r != 1) begin
								for (j = 8; j < 17; j = j+1) begin
									a_w[j-2] = i_mem_dout[j*16-1-:16];
									matrix_x_w[j] = $signed(matrix_x_r[j]) - $signed(x_out[j-2]);
								end
							end
							data_cnt_w = data_cnt_r + 1;
							mem_addr = 7;
						end
						8: begin
							x_old_w = matrix_x_r[8];
							aNN_w = i_mem_dout[127:112];
							x_in_w = x_new;
							if (recur_cnt_r != 17) begin
								for (j = 1; j < 8; j = j+1) begin
									a_w[j-1] = i_mem_dout[j*16-1-:16];
									matrix_x_w[j] = $signed(matrix_x_r[j]) - $signed(x_out[j-1]);
								end
								matrix_x_w[8] = matrix_b_r[8];
							end
							else begin
								matrix_x_w[8] = x_new;
							end
							if (recur_cnt_r != 1) begin
								for (j = 9; j < 17; j = j+1) begin
									a_w[j-2] = i_mem_dout[j*16-1-:16];
									matrix_x_w[j] = $signed(matrix_x_r[j]) - $signed(x_out[j-2]);
								end
							end
							data_cnt_w = data_cnt_r + 1;
							mem_addr = 8;
						end
						9: begin
							x_old_w = matrix_x_r[9];
							aNN_w = i_mem_dout[143:128];
							x_in_w = x_new;
							if (recur_cnt_r != 17) begin
								for (j = 1; j < 9; j = j+1) begin
									a_w[j-1] = i_mem_dout[j*16-1-:16];
									matrix_x_w[j] = $signed(matrix_x_r[j]) - $signed(x_out[j-1]);
								end
								matrix_x_w[9] = matrix_b_r[9];
							end
							else begin
								matrix_x_w[9] = x_new;
							end
							if (recur_cnt_r != 1) begin
								for (j = 10; j < 17; j = j+1) begin
									a_w[j-2] = i_mem_dout[j*16-1-:16];
									matrix_x_w[j] = $signed(matrix_x_r[j]) - $signed(x_out[j-2]);
								end
							end
							data_cnt_w = data_cnt_r + 1;
							mem_addr = 9;
						end
						10: begin
							x_old_w = matrix_x_r[10];
							aNN_w = i_mem_dout[159:144];
							x_in_w = x_new;
							if (recur_cnt_r != 17) begin
								for (j = 1; j < 10; j = j+1) begin
									a_w[j-1] = i_mem_dout[j*16-1-:16];
									matrix_x_w[j] = $signed(matrix_x_r[j]) - $signed(x_out[j-1]);
								end
								matrix_x_w[10] = matrix_b_r[10];
							end
							else begin
								matrix_x_w[10] = x_new;
							end
							if (recur_cnt_r != 1) begin
								for (j = 11; j < 17; j = j+1) begin
									a_w[j-2] = i_mem_dout[j*16-1-:16];
									matrix_x_w[j] = $signed(matrix_x_r[j]) - $signed(x_out[j-2]);
								end
							end
							data_cnt_w = data_cnt_r + 1;
							mem_addr = 10;
						end
						11: begin
							x_old_w = matrix_x_r[11];
							aNN_w = i_mem_dout[175:160];
							x_in_w = x_new;
							if (recur_cnt_r != 17) begin
								for (j = 1; j < 11; j = j+1) begin
									a_w[j-1] = i_mem_dout[j*16-1-:16];
									matrix_x_w[j] = $signed(matrix_x_r[j]) - $signed(x_out[j-1]);
								end
								matrix_x_w[11] = matrix_b_r[11];
							end
							else begin
								matrix_x_w[11] = x_new;
							end
							if (recur_cnt_r != 1) begin
								for (j = 12; j < 17; j = j+1) begin
									a_w[j-2] = i_mem_dout[j*16-1-:16];
									matrix_x_w[j] = $signed(matrix_x_r[j]) - $signed(x_out[j-2]);
								end
							end
							data_cnt_w = data_cnt_r + 1;
							mem_addr = 11;
						end
						12: begin
							x_old_w = matrix_x_r[12];
							aNN_w = i_mem_dout[191:176];
							x_in_w = x_new;
							if (recur_cnt_r != 17) begin
								for (j = 1; j < 12; j = j+1) begin
									a_w[j-1] = i_mem_dout[j*16-1-:16];
									matrix_x_w[j] = $signed(matrix_x_r[j]) - $signed(x_out[j-1]);
								end
								matrix_x_w[12] = matrix_b_r[12];
							end
							else begin
								matrix_x_w[12] = x_new;
							end
							if (recur_cnt_r != 1) begin
								for (j = 13; j < 17; j = j+1) begin
									a_w[j-2] = i_mem_dout[j*16-1-:16];
									matrix_x_w[j] = $signed(matrix_x_r[j]) - $signed(x_out[j-2]);
								end
							end
							data_cnt_w = data_cnt_r + 1;
							mem_addr = 12;
						end
						13: begin
							x_old_w = matrix_x_r[13];
							aNN_w = i_mem_dout[207:192];
							x_in_w = x_new;
							if (recur_cnt_r != 17) begin
								for (j = 1; j < 13; j = j+1) begin
									a_w[j-1] = i_mem_dout[j*16-1-:16];
									matrix_x_w[j] = $signed(matrix_x_r[j]) - $signed(x_out[j-1]);
								end
								matrix_x_w[13] = matrix_b_r[13];
							end
							else begin
								matrix_x_w[13] = x_new;
							end
							if (recur_cnt_r != 1) begin
								for (j = 14; j < 17; j = j+1) begin
									a_w[j-2] = i_mem_dout[j*16-1-:16];
									matrix_x_w[j] = $signed(matrix_x_r[j]) - $signed(x_out[j-2]);
								end
							end
							data_cnt_w = data_cnt_r + 1;
							mem_addr = 13;
						end
						14: begin
							x_old_w = matrix_x_r[14];
							aNN_w = i_mem_dout[223:208];
							x_in_w = x_new;
							if (recur_cnt_r != 17) begin
								for (j = 1; j < 14; j = j+1) begin
									a_w[j-1] = i_mem_dout[j*16-1-:16];
									matrix_x_w[j] = $signed(matrix_x_r[j]) - $signed(x_out[j-1]);
								end
								matrix_x_w[14] = matrix_b_r[14];
							end
							else begin
								matrix_x_w[14] = x_new;
							end
							if (recur_cnt_r != 1) begin
								for (j = 15; j < 17; j = j+1) begin
									a_w[j-2] = i_mem_dout[j*16-1-:16];
									matrix_x_w[j] = $signed(matrix_x_r[j]) - $signed(x_out[j-2]);
								end
							end
							data_cnt_w = data_cnt_r + 1;
							mem_addr = 14;
						end
						15: begin
							x_old_w = matrix_x_r[15];
							aNN_w = i_mem_dout[239:224];
							x_in_w = x_new;
							if (recur_cnt_r != 17) begin
								for (j = 1; j < 15; j = j+1) begin
									a_w[j-1] = i_mem_dout[j*16-1-:16];
									matrix_x_w[j] = $signed(matrix_x_r[j]) - $signed(x_out[j-1]);
								end
								matrix_x_w[15] = matrix_b_r[15];
							end
							else begin
								matrix_x_w[15] = x_new;
							end
							if (recur_cnt_r != 1) begin
								a_w[14] = i_mem_dout[255:240];
								matrix_x_w[16] = $signed(matrix_x_r[16]) - $signed(x_out[14]);
							end
							data_cnt_w = data_cnt_r + 1;
							mem_addr = 15;
						end
						16: begin
							x_old_w = matrix_x_r[16];
							aNN_w = i_mem_dout[255:240];
							x_in_w = x_new;
							if (recur_cnt_r != 17) begin
								for (j = 1; j < 16; j = j+1) begin
									a_w[j-1] = i_mem_dout[j*16-1-:16];
									matrix_x_w[j] = $signed(matrix_x_r[j]) - $signed(x_out[j-1]);
								end
								matrix_x_w[16] = matrix_b_r[16];
							end
							else begin
								matrix_x_w[16] = x_new;
							end
							data_cnt_w = 1;
							recur_cnt_w = recur_cnt_r + 1;
							if (recur_cnt_r == 17) begin
								state_w = STOP;
							end
							mem_addr = 0;
						end
						default: begin
						end
					endcase
				end
				STOP: begin
					
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
		buffer_x_r <= 0;
		data_cnt_r <= 0;
		recur_cnt_r <= 0;
		state_r <= 0;
	end
	else begin
		for (j = 1; j < 17; j = j+1) begin
			matrix_b_r[j] <= matrix_b_w[j];
			matrix_x_r[j] <= matrix_x_w[j];
		end
		buffer_x_r <= buffer_x_w;
		data_cnt_r <= data_cnt_w;
		recur_cnt_r <= recur_cnt_w;
		state_r <= state_w;
	end
end

endmodule
