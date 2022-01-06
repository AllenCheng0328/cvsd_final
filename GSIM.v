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

reg [15:0] matrix_b_r[0:15], matrix_b_w[0:15]; 
reg [31:0] matrix_x_r[0:15], matrix_x_w[0:15];

reg [9:0] matrix_cnt_r, matrix_cnt_w; 
reg [8:0] data_cnt_r, data_cnt_w;
reg [4:0] recur_cnt_r, recur_cnt_w; 

reg o_mem_rreq_r, o_mem_rreq_w;
reg [9:0] o_mem_addr_r, o_mem_addr_w;
reg o_x_wen_r, o_x_wen_w;
reg [8:0] o_x_addr_r, o_x_addr_w;
reg [31:0] o_x_data_r, o_x_data_w;
reg o_proc_done_r, o_proc_done_w;

integer j;

assign o_mem_rreq = o_mem_rreq_r;
assign o_mem_addr = o_mem_addr_r;
assign o_x_wen = o_x_wen_r;
assign o_x_addr = o_x_addr_r;
assign o_x_data = o_x_data_r;
assign o_proc_done = o_proc_done_r;

always @(*) begin
	for (j = 0; j < 16; j = j+1) begin
		matrix_b_w[j] = matrix_b_r[j];
		matrix_x_w[j] = matrix_x_r[j];
	end
	recur_cnt_w = recur_cnt_r;
	matrix_cnt_w = matrix_cnt_r;

	o_x_data_w = o_x_data_r;
	o_x_addr_w = o_x_addr_r;

	if (i_module_en) begin 
		if (matrix_cnt_r >= i_matrix_num*17) begin
			o_proc_done_w = 1;
		end
		else begin
			o_proc_done_w = 0;
		end

		case (data_cnt_r) //o/p control
			259: begin
				o_x_data_w = matrix_x_r[0];
				o_x_wen_w = 1;
				o_x_addr_w = (matrix_cnt_r == 0)?0:o_x_addr_r + 1;
			end
			260: begin
				o_x_data_w = matrix_x_w[1];
				o_x_wen_w = 1;
				o_x_addr_w = o_x_addr_r + 1;
			end
			261: begin
				o_x_data_w = matrix_x_w[2];
				o_x_wen_w = 1;
				o_x_addr_w = o_x_addr_r + 1;
			end
			262: begin
				o_x_data_w = matrix_x_w[3];
				o_x_wen_w = 1;
				o_x_addr_w = o_x_addr_r + 1;
			end
			263: begin
				o_x_data_w = matrix_x_w[4];
				o_x_wen_w = 1;
				o_x_addr_w = o_x_addr_r + 1;
			end
			264: begin
				o_x_data_w = matrix_x_w[5];
				o_x_wen_w = 1;
				o_x_addr_w = o_x_addr_r + 1;
			end
			265: begin
				o_x_data_w = matrix_x_w[6];
				o_x_wen_w = 1;
				o_x_addr_w = o_x_addr_r + 1;
			end
			266: begin
				o_x_data_w = matrix_x_w[7];
				o_x_wen_w = 1;
				o_x_addr_w = o_x_addr_r + 1;
			end
			267: begin
				o_x_data_w = matrix_x_w[8];
				o_x_wen_w = 1;
				o_x_addr_w = o_x_addr_r + 1;
			end
			268: begin
				o_x_data_w = matrix_x_w[9];
				o_x_wen_w = 1;
				o_x_addr_w = o_x_addr_r + 1;
			end
			269: begin
				o_x_data_w = matrix_x_w[10];
				o_x_wen_w = 1;
				o_x_addr_w = o_x_addr_r + 1;
			end
			270: begin
				o_x_data_w = matrix_x_w[11];
				o_x_wen_w = 1;
				o_x_addr_w = o_x_addr_r + 1;
			end
			271: begin
				o_x_data_w = matrix_x_w[12];
				o_x_wen_w = 1;
				o_x_addr_w = o_x_addr_r + 1;
			end 
			272: begin
				o_x_data_w = matrix_x_w[13];
				o_x_wen_w = 1;
				o_x_addr_w = o_x_addr_r + 1;
			end
			273: begin 
				o_x_data_w = matrix_x_w[14];
				o_x_wen_w = 1;
				o_x_addr_w = o_x_addr_r + 1;
			end
			274: begin
				o_x_data_w = matrix_x_w[15];
				o_x_wen_w = 1;
				o_x_addr_w = o_x_addr_r + 1;
			end
			default: begin
				o_x_data_w = o_x_data_r;
				o_x_wen_w = 0;
				o_x_addr_w = o_x_addr_r;
			end 
		endcase

		if (i_mem_rrdy) begin //counter(i/p)&addr control
			data_cnt_w = data_cnt_r + 1;
			o_mem_addr_w = o_mem_addr_r + 1;
			if (recur_cnt_r >= 16) begin
				data_cnt_w = 0;
				matrix_cnt_w = matrix_cnt_r + 17;
				o_mem_addr_w = matrix_cnt_r + 17; 
			end
			else if (data_cnt_r == 16) begin
				o_mem_addr_w = matrix_cnt_r; 
			end
			else if ((o_mem_addr_r == matrix_cnt_r+15) && (data_cnt_r != 15)) begin
				o_mem_addr_w = matrix_cnt_r;
			end
		end
		else begin
			o_mem_addr_w = o_mem_addr_r;
			data_cnt_w = data_cnt_r;
		end


		if (i_mem_dout_vld) begin //matrix calculation
			if (data_cnt_r <= 17) begin
				if (data_cnt_r == 17) begin
					for (j = 0; j < 16; j = j+1) begin
						matrix_b_w[j] = i_mem_dout[j<<4 +: 16];
						matrix_x_w[j] = matrix_x_r[j] * i_mem_dout[j<<4 +: 16];
					end
				end
				else begin
					matrix_x_w[data_cnt_r-1] = i_mem_dout[data_cnt_r<<4-16 +: 16];
				end
			end
			else begin
				if (data_cnt_r[3:0] == 2) begin
					matrix_x_w[0] = i_mem_dout[15:0] * (matrix_b_r[0] - i_mem_dout[31:16]*matrix_x_r[1] - i_mem_dout[47:32]*matrix_x_r[2] - i_mem_dout[63:48]*matrix_x_r[3] - i_mem_dout[79:64]*matrix_x_r[4] - i_mem_dout[95:80]*matrix_x_r[5] - i_mem_dout[111:96]*matrix_x_r[6] - i_mem_dout[127:112]*matrix_x_r[7] - i_mem_dout[143:128]*matrix_x_r[8] - i_mem_dout[159:144]*matrix_x_r[9] - i_mem_dout[175:160]*matrix_x_r[10] - i_mem_dout[191:176]*matrix_x_r[11] - i_mem_dout[207:192]*matrix_x_r[12] - i_mem_dout[223:208]*matrix_x_r[13] - i_mem_dout[239:224]*matrix_x_r[14] - i_mem_dout[255:240]*matrix_x_r[15]);
					if (recur_cnt_r >= 16) begin
						recur_cnt_w = 0;
					end
					else begin
						recur_cnt_w = recur_cnt_r;
					end
				end
				else if (data_cnt_r[3:0] == 3) begin
					matrix_x_w[1] = i_mem_dout[31:16] * (matrix_b_r[1] - i_mem_dout[15:0]*matrix_x_r[0] - i_mem_dout[47:32]*matrix_x_r[2] - i_mem_dout[63:48]*matrix_x_r[3] - i_mem_dout[79:64]*matrix_x_r[4] - i_mem_dout[95:80]*matrix_x_r[5] - i_mem_dout[111:96]*matrix_x_r[6] - i_mem_dout[127:112]*matrix_x_r[7] - i_mem_dout[143:128]*matrix_x_r[8] - i_mem_dout[159:144]*matrix_x_r[9] - i_mem_dout[175:160]*matrix_x_r[10] - i_mem_dout[191:176]*matrix_x_r[11] - i_mem_dout[207:192]*matrix_x_r[12] - i_mem_dout[223:208]*matrix_x_r[13] - i_mem_dout[239:224]*matrix_x_r[14] - i_mem_dout[255:240]*matrix_x_r[15]);
				end
				else if (data_cnt_r[3:0] == 4) begin
					matrix_x_w[2] = i_mem_dout[47:32] * (matrix_b_r[2] - i_mem_dout[15:0]*matrix_x_r[0] - i_mem_dout[31:15]*matrix_x_r[1] - i_mem_dout[63:48]*matrix_x_r[3] - i_mem_dout[79:64]*matrix_x_r[4] - i_mem_dout[95:80]*matrix_x_r[5] - i_mem_dout[111:96]*matrix_x_r[6] - i_mem_dout[127:112]*matrix_x_r[7] - i_mem_dout[143:128]*matrix_x_r[8] - i_mem_dout[159:144]*matrix_x_r[9] - i_mem_dout[175:160]*matrix_x_r[10] - i_mem_dout[191:176]*matrix_x_r[11] - i_mem_dout[207:192]*matrix_x_r[12] - i_mem_dout[223:208]*matrix_x_r[13] - i_mem_dout[239:224]*matrix_x_r[14] - i_mem_dout[255:240]*matrix_x_r[15]);
				end
				else if (data_cnt_r[3:0] == 5) begin
					matrix_x_w[3] = i_mem_dout[63:48] * (matrix_b_r[3] - i_mem_dout[15:0]*matrix_x_r[0] - i_mem_dout[31:15]*matrix_x_r[1] - i_mem_dout[47:32]*matrix_x_r[2] - i_mem_dout[79:64]*matrix_x_r[4] - i_mem_dout[95:80]*matrix_x_r[5] - i_mem_dout[111:96]*matrix_x_r[6] - i_mem_dout[127:112]*matrix_x_r[7] - i_mem_dout[143:128]*matrix_x_r[8] - i_mem_dout[159:144]*matrix_x_r[9] - i_mem_dout[175:160]*matrix_x_r[10] - i_mem_dout[191:176]*matrix_x_r[11] - i_mem_dout[207:192]*matrix_x_r[12] - i_mem_dout[223:208]*matrix_x_r[13] - i_mem_dout[239:224]*matrix_x_r[14] - i_mem_dout[255:240]*matrix_x_r[15]);
				end
				else if (data_cnt_r[3:0] == 6) begin
					matrix_x_w[4] = i_mem_dout[79:64] * (matrix_b_r[4] - i_mem_dout[15:0]*matrix_x_r[0] - i_mem_dout[31:15]*matrix_x_r[1] - i_mem_dout[47:32]*matrix_x_r[2] - i_mem_dout[63:48]*matrix_x_r[3] - i_mem_dout[95:80]*matrix_x_r[5] - i_mem_dout[111:96]*matrix_x_r[6] - i_mem_dout[127:112]*matrix_x_r[7] - i_mem_dout[143:128]*matrix_x_r[8] - i_mem_dout[159:144]*matrix_x_r[9] - i_mem_dout[175:160]*matrix_x_r[10] - i_mem_dout[191:176]*matrix_x_r[11] - i_mem_dout[207:192]*matrix_x_r[12] - i_mem_dout[223:208]*matrix_x_r[13] - i_mem_dout[239:224]*matrix_x_r[14] - i_mem_dout[255:240]*matrix_x_r[15]);
				end
				else if (data_cnt_r[3:0] == 7) begin
					matrix_x_w[5] = i_mem_dout[95:80] * (matrix_b_r[5] - i_mem_dout[15:0]*matrix_x_r[0] - i_mem_dout[31:15]*matrix_x_r[1] - i_mem_dout[47:32]*matrix_x_r[2] - i_mem_dout[63:48]*matrix_x_r[3] - i_mem_dout[79:64]*matrix_x_r[4] - i_mem_dout[111:96]*matrix_x_r[6] - i_mem_dout[127:112]*matrix_x_r[7] - i_mem_dout[143:128]*matrix_x_r[8] - i_mem_dout[159:144]*matrix_x_r[9] - i_mem_dout[175:160]*matrix_x_r[10] - i_mem_dout[191:176]*matrix_x_r[11] - i_mem_dout[207:192]*matrix_x_r[12] - i_mem_dout[223:208]*matrix_x_r[13] - i_mem_dout[239:224]*matrix_x_r[14] - i_mem_dout[255:240]*matrix_x_r[15]);
				end
				else if (data_cnt_r[3:0] == 8) begin
					matrix_x_w[6] = i_mem_dout[111:96] * (matrix_b_r[6] - i_mem_dout[15:0]*matrix_x_r[0] - i_mem_dout[31:15]*matrix_x_r[1] - i_mem_dout[47:32]*matrix_x_r[2] - i_mem_dout[63:48]*matrix_x_r[3] - i_mem_dout[79:64]*matrix_x_r[4] - i_mem_dout[95:80]*matrix_x_r[5] - i_mem_dout[127:112]*matrix_x_r[7] - i_mem_dout[143:128]*matrix_x_r[8] - i_mem_dout[159:144]*matrix_x_r[9] - i_mem_dout[175:160]*matrix_x_r[10] - i_mem_dout[191:176]*matrix_x_r[11] - i_mem_dout[207:192]*matrix_x_r[12] - i_mem_dout[223:208]*matrix_x_r[13] - i_mem_dout[239:224]*matrix_x_r[14] - i_mem_dout[255:240]*matrix_x_r[15]);
				end
				else if (data_cnt_r[3:0] == 9) begin
					matrix_x_w[7] = i_mem_dout[127:112] * (matrix_b_r[7] - i_mem_dout[15:0]*matrix_x_r[0] - i_mem_dout[31:15]*matrix_x_r[1] - i_mem_dout[47:32]*matrix_x_r[2] - i_mem_dout[63:48]*matrix_x_r[3] - i_mem_dout[79:64]*matrix_x_r[4] - i_mem_dout[95:80]*matrix_x_r[5] - i_mem_dout[111:96]*matrix_x_r[6] - i_mem_dout[143:128]*matrix_x_r[8] - i_mem_dout[159:144]*matrix_x_r[9] - i_mem_dout[175:160]*matrix_x_r[10] - i_mem_dout[191:176]*matrix_x_r[11] - i_mem_dout[207:192]*matrix_x_r[12] - i_mem_dout[223:208]*matrix_x_r[13] - i_mem_dout[239:224]*matrix_x_r[14] - i_mem_dout[255:240]*matrix_x_r[15]);
				end
				else if (data_cnt_r[3:0] == 10) begin
					matrix_x_w[8] = i_mem_dout[143:128] * (matrix_b_r[8] - i_mem_dout[15:0]*matrix_x_r[0] - i_mem_dout[31:15]*matrix_x_r[1] - i_mem_dout[47:32]*matrix_x_r[2] - i_mem_dout[63:48]*matrix_x_r[3] - i_mem_dout[79:64]*matrix_x_r[4] - i_mem_dout[95:80]*matrix_x_r[5] - i_mem_dout[111:96]*matrix_x_r[6] - i_mem_dout[127:112]*matrix_x_r[7] - i_mem_dout[159:144]*matrix_x_r[9] - i_mem_dout[175:160]*matrix_x_r[10] - i_mem_dout[191:176]*matrix_x_r[11] - i_mem_dout[207:192]*matrix_x_r[12] - i_mem_dout[223:208]*matrix_x_r[13] - i_mem_dout[239:224]*matrix_x_r[14] - i_mem_dout[255:240]*matrix_x_r[15]);
				end
				else if (data_cnt_r[3:0] == 11) begin
					matrix_x_w[9] = i_mem_dout[159:144] * (matrix_b_r[9] - i_mem_dout[15:0]*matrix_x_r[0] - i_mem_dout[31:15]*matrix_x_r[1] - i_mem_dout[47:32]*matrix_x_r[2] - i_mem_dout[63:48]*matrix_x_r[3] - i_mem_dout[79:64]*matrix_x_r[4] - i_mem_dout[95:80]*matrix_x_r[5] - i_mem_dout[111:96]*matrix_x_r[6] - i_mem_dout[127:112]*matrix_x_r[7] - i_mem_dout[143:128]*matrix_x_r[8] - i_mem_dout[175:160]*matrix_x_r[10] - i_mem_dout[191:176]*matrix_x_r[11] - i_mem_dout[207:192]*matrix_x_r[12] - i_mem_dout[223:208]*matrix_x_r[13] - i_mem_dout[239:224]*matrix_x_r[14] - i_mem_dout[255:240]*matrix_x_r[15]);
				end
				else if (data_cnt_r[3:0] == 12) begin
					matrix_x_w[10] = i_mem_dout[175:160] * (matrix_b_r[10] - i_mem_dout[15:0]*matrix_x_r[0] - i_mem_dout[31:15]*matrix_x_r[1] - i_mem_dout[47:32]*matrix_x_r[2] - i_mem_dout[63:48]*matrix_x_r[3] - i_mem_dout[79:64]*matrix_x_r[4] - i_mem_dout[95:80]*matrix_x_r[5] - i_mem_dout[111:96]*matrix_x_r[6] - i_mem_dout[127:112]*matrix_x_r[7] - i_mem_dout[143:128]*matrix_x_r[8] - i_mem_dout[159:144]*matrix_x_r[9] - i_mem_dout[191:176]*matrix_x_r[11] - i_mem_dout[207:192]*matrix_x_r[12] - i_mem_dout[223:208]*matrix_x_r[13] - i_mem_dout[239:224]*matrix_x_r[14] - i_mem_dout[255:240]*matrix_x_r[15]);
				end
				else if (data_cnt_r[3:0] == 13) begin
					matrix_x_w[11] = i_mem_dout[191:176] * (matrix_b_r[11] - i_mem_dout[15:0]*matrix_x_r[0] - i_mem_dout[31:15]*matrix_x_r[1] - i_mem_dout[47:32]*matrix_x_r[2] - i_mem_dout[63:48]*matrix_x_r[3] - i_mem_dout[79:64]*matrix_x_r[4] - i_mem_dout[95:80]*matrix_x_r[5] - i_mem_dout[111:96]*matrix_x_r[6] - i_mem_dout[127:112]*matrix_x_r[7] - i_mem_dout[143:128]*matrix_x_r[8] - i_mem_dout[159:144]*matrix_x_r[9] - i_mem_dout[175:160]*matrix_x_r[10] - i_mem_dout[207:192]*matrix_x_r[12] - i_mem_dout[223:208]*matrix_x_r[13] - i_mem_dout[239:224]*matrix_x_r[14] - i_mem_dout[255:240]*matrix_x_r[15]);
				end
				else if (data_cnt_r[3:0] == 14) begin
					matrix_x_w[12] = i_mem_dout[207:192] * (matrix_b_r[12] - i_mem_dout[15:0]*matrix_x_r[0] - i_mem_dout[31:15]*matrix_x_r[1] - i_mem_dout[47:32]*matrix_x_r[2] - i_mem_dout[63:48]*matrix_x_r[3] - i_mem_dout[79:64]*matrix_x_r[4] - i_mem_dout[95:80]*matrix_x_r[5] - i_mem_dout[111:96]*matrix_x_r[6] - i_mem_dout[127:112]*matrix_x_r[7] - i_mem_dout[143:128]*matrix_x_r[8] - i_mem_dout[159:144]*matrix_x_r[9] - i_mem_dout[175:160]*matrix_x_r[10] - i_mem_dout[191:176]*matrix_x_r[11] - i_mem_dout[223:208]*matrix_x_r[13] - i_mem_dout[239:224]*matrix_x_r[14] - i_mem_dout[255:240]*matrix_x_r[15]);
				end
				else if (data_cnt_r[3:0] == 15) begin
					matrix_x_w[13] = i_mem_dout[223:208] * (matrix_b_r[13] - i_mem_dout[15:0]*matrix_x_r[0] - i_mem_dout[31:15]*matrix_x_r[1] - i_mem_dout[47:32]*matrix_x_r[2] - i_mem_dout[63:48]*matrix_x_r[3] - i_mem_dout[79:64]*matrix_x_r[4] - i_mem_dout[95:80]*matrix_x_r[5] - i_mem_dout[111:96]*matrix_x_r[6] - i_mem_dout[127:112]*matrix_x_r[7] - i_mem_dout[143:128]*matrix_x_r[8] - i_mem_dout[159:144]*matrix_x_r[9] - i_mem_dout[175:160]*matrix_x_r[10] - i_mem_dout[191:176]*matrix_x_r[11] - i_mem_dout[207:192]*matrix_x_r[12] - i_mem_dout[239:224]*matrix_x_r[14] - i_mem_dout[255:240]*matrix_x_r[15]);
				end
				else if (data_cnt_r[3:0] == 0) begin
					matrix_x_w[14] = i_mem_dout[239:224] * (matrix_b_r[14] - i_mem_dout[15:0]*matrix_x_r[0] - i_mem_dout[31:15]*matrix_x_r[1] - i_mem_dout[47:32]*matrix_x_r[2] - i_mem_dout[63:48]*matrix_x_r[3] - i_mem_dout[79:64]*matrix_x_r[4] - i_mem_dout[95:80]*matrix_x_r[5] - i_mem_dout[111:96]*matrix_x_r[6] - i_mem_dout[127:112]*matrix_x_r[7] - i_mem_dout[143:128]*matrix_x_r[8] - i_mem_dout[159:144]*matrix_x_r[9] - i_mem_dout[175:160]*matrix_x_r[10] - i_mem_dout[191:176]*matrix_x_r[11] - i_mem_dout[207:192]*matrix_x_r[12] - i_mem_dout[223:208]*matrix_x_r[13] - i_mem_dout[255:240]*matrix_x_r[15]);
				end
				else begin
					matrix_x_w[15] = i_mem_dout[255:240] * (matrix_b_r[15] - i_mem_dout[15:0]*matrix_x_r[0] - i_mem_dout[31:15]*matrix_x_r[1] - i_mem_dout[47:32]*matrix_x_r[2] - i_mem_dout[63:48]*matrix_x_r[3] - i_mem_dout[79:64]*matrix_x_r[4] - i_mem_dout[95:80]*matrix_x_r[5] - i_mem_dout[111:96]*matrix_x_r[6] - i_mem_dout[127:112]*matrix_x_r[7] - i_mem_dout[143:128]*matrix_x_r[8] - i_mem_dout[159:144]*matrix_x_r[9] - i_mem_dout[175:160]*matrix_x_r[10] - i_mem_dout[191:176]*matrix_x_r[11] - i_mem_dout[207:192]*matrix_x_r[12] - i_mem_dout[223:208]*matrix_x_r[13] - i_mem_dout[239:224]*matrix_x_r[14]);
					recur_cnt_w = recur_cnt_r + 1;
				end
			end
		end
	end
	else begin
		o_proc_done_w = 0;
		recur_cnt_w = 0;
		o_mem_addr_w = 0;
		data_cnt_w = 0;
	end
end

always @(posedge i_clk or posedge i_reset) begin
	if (i_reset) begin		
		data_cnt_r <= 0;	
		matrix_cnt_r <= 0;
		recur_cnt_r <= 0;

		o_mem_addr_r <= 0;
		o_mem_rreq_r <= 0;
		o_proc_done_r <= 0;
		o_x_data_r <= 0;
		o_x_wen_r <= 0;
		o_x_addr_r <= 0;

		for (j = 0; j < 16; j = j+1) begin
			matrix_b_r[j] <= 0;
			matrix_x_r[j] <= 0;
		end
	end
	else begin
		data_cnt_r <= data_cnt_w;	
		matrix_cnt_r <= matrix_cnt_w;
		recur_cnt_r <= recur_cnt_w;

		o_mem_addr_r <= o_mem_addr_w;
		o_mem_rreq_r <= 1;
		o_proc_done_r <= o_proc_done_w;
		o_x_data_r <= o_x_data_w;
		o_x_wen_r <= o_x_wen_w;
		o_x_addr_r <= o_x_addr_w;

		for (j = 0; j < 16; j = j+1) begin
			matrix_b_r[j] <= matrix_b_w[j];
			matrix_x_r[j] <= matrix_x_w[j];
		end
	end
end
endmodule
