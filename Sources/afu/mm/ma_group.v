module ma_group(
	input clk,
	input[31:0] unum1,
	input[255:0] unum2,
	input finish,
	input rst,
	input valid,
	
	output[255:0] sum,
	output[7:0] isInf,
	output[7:0] overflow,
	output[7:0] finish_out
	);
////input buffer1
reg[31:0] unum1_buff;
reg[255:0] unum2_buff;
reg finish_buff;
reg rst_buff;
reg valid_buff;

////output buffer
reg[255:0] sum_buff;
reg[7:0] isInf_buff;
reg[7:0] overflow_buff;
reg[7:0] finish_out_buff;
wire[255:0] sum_wire;
wire[7:0] isInf_wire;
wire[7:0] overflow_wire;
wire[7:0] finish_out_wire;

generate
genvar i;
for(i=0;i<8;i=i+1)begin:generate_ma
	////input buffer2
	wire[31:0] unum1_buff2;
	wire[31:0] unum2_buff2;
	wire finish_buff2;
	wire rst_buff2;
	wire valid_buff2;
	
	multiply_accumulator ma(
	.clk(clk),
	.unum1(unum1_buff2),
	.unum2(unum2_buff2),
	.finish(finish_buff2),
	.rst(rst_buff2),
	.valid(valid_buff2),
	
	.sum(sum_wire[i*32+31:i*32]),
	.isInf(isInf_wire[i]),
	.overflow(overflow_wire[i]),
	.finish_out(finish_out_wire[i])
	);
	
	mm_buffer mm_buffer0(
	.clk(clk),
	.unum1_in(unum1_buff),
	.unum2_in(unum2_buff[i*32+31:i*32]),
	.finish_in(finish_buff),
	.rst_in(rst_buff),
	.valid_in(valid_buff),
	
	.unum1_out(unum1_buff2),
	.unum2_out(unum2_buff2),
	.finish_out(finish_buff2),
	.rst_out(rst_buff2),
	.valid_out(valid_buff2)
	);
end
endgenerate
////input buffer
always@(posedge clk)begin
	unum1_buff<=unum1;
	unum2_buff<=unum2;
	finish_buff<=finish;
	rst_buff<=rst;
	valid_buff<=valid;
end


////output buffer
always@(posedge clk)begin
	sum_buff<=sum_wire;
	isInf_buff<=isInf_wire;
	overflow_buff<=overflow_wire;
	finish_out_buff<=finish_out_wire;
end
assign sum=sum_buff;
assign isInf=isInf_buff;
assign overflow=overflow_buff;
assign finish_out=finish_out_buff;

endmodule

module mm_buffer(
	input clk,
	input[31:0]	unum1_in,
	input[31:0] unum2_in,
	input finish_in,
	input rst_in,
	input valid_in,
	
	output[31:0] unum1_out,
	output[31:0] unum2_out,
	output finish_out,
	output rst_out,
	output valid_out
);
reg[31:0] unum1_buff, unum2_buff;
reg finish_buff,rst_buff,valid_buff;
always@(posedge clk)begin
	unum1_buff<=unum1_in;
	unum2_buff<=unum2_in;
	finish_buff<=finish_in;
	rst_buff<=rst_in;
	valid_buff<=valid_in;
end

assign unum1_out=unum1_in;
assign unum2_out=unum2_in;
assign finish_out=finish_in;
assign rst_out=rst_in;
assign valid_out=valid_in;

endmodule
