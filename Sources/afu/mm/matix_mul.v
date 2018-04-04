module matix_mul(
	input[1023:0] data,
	input rst,
	input start,
	input[63:0] size1, /// size of the matrix
	input[63:0] size2,
	input valid,
	input clk,
	input pull,
	
	output[1023:0] data_out,
	output finish,
	///////
	
	output empty,
	output full
	);


/////input_buffer1
wire buffer1_empty;
/////input_buffer2
wire buffer2_wr_finish;
wire buffer2_finish;
wire fifo3_rdempty;

/////multiply_accumulators
wire[2047:0] input2,output1;
wire[31:0] input1;
wire[63:0] ma_finish_out;
wire ma_valid;



generate
genvar i;
for(i=0;i<8;i=i+1)begin:generate_magroup
	ma_group mag(
	.clk(clk),
	.unum1(input1),
	.unum2(input2[i*256+255:i*256]),
	.finish(buffer2_finish),
	.rst(rst),
	.valid(ma_valid),
	
	.sum(output1[i*256+255:i*256]),
	.isInf(),
	.overflow(),
	.finish_out(ma_finish_out[i*8+7:i*8])
	);
end

endgenerate


circular_buffer1 input_buffer1(
	.data(data),
	.rdreq(~buffer1_empty),
	.wrreq(valid&&buffer2_wr_finish),
	.clk(clk),
	.rst(rst),
	.start(start),
	.row(size1[31:0]),
	.column(size1[63:32]),
	.row2(size2[31:0]),
	
	.valid_out(ma_valid),
	.init_finish(full),
	.rdempty(buffer1_empty),
	.finish_out(finish),
	.q(input1)
);

circular_buffer2 input_buffer2(
	.data(data),
	.rdreq(~buffer1_empty),
	.wrreq(valid),
	.clk(clk),
	.rst(rst),
	.start(start),
	.row(size2[31:0]),
	.column(size1[63:32]),
	.row2(size1[31:0]),
	
//	output rdempty,
	.q(input2),
	.finish(buffer2_finish),
	.wr_finish(buffer2_wr_finish)
);

outputbuffer output_buffer1(
	.clk(clk),
	.data(output1),
	.rdreq(pull),
	.wrreq(ma_finish_out[0]),
	.rst(rst),
	.start(start),
	.row(size1[31:0]),
	.column(size1[63:32]),
	.row2(size2[31:0]),
	
	.rdempty(empty),
	.q(data_out)
);
endmodule

module mm_buff(
	input clk,
	input[1023:0] data_in,
	input rst_in,
	input start_in,
	input[63:0] size1_in, /// size of the matrix
	input[63:0] size2_in,
	input valid_in,
	input pull_in,
	
	output[1023:0] data_out,
	output rst_out,
	output start_out,
	output[63:0] size1_out, /// size of the matrix
	output[63:0] size2_out,
	output valid_out,
	output pull_out
);
reg[1023:0] data_buff;
reg rst_buff,start_buff,valid_buff,pull_buff;
reg[63:0] size1_buff,size2_buff; /// size of the matrix
always@(posedge clk)begin
	data_buff<=data_in;
	rst_buff<=rst_in;
	start_buff<=start_in;
	size1_buff<=size1_in;
	size2_buff<=size2_in;
	valid_buff<=valid_in;
//	pull_buff<=pull_in;
end
assign data_out=data_buff;
assign rst_out=rst_buff;
assign start_out=start_buff;
assign size1_out=size1_buff;
assign size2_out=size2_buff;
assign valid_out=valid_buff;
assign pull_out=pull_in;

endmodule 