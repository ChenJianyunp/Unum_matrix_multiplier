module multiply_accumulator(
	input clk,
	input[31:0] unum1,
	input[31:0] unum2,
	input finish,
	input rst,
	input valid,
	
	output[31:0] sum,
	output isInf,
	output overflow,
	output finish_out
	);
	

///for csa1
wire[63:0] csa_frac_even;
wire[63:0] csa_frac_odd;
wire[1:0] csa_adr_even;
wire[1:0] csa_adr_odd;
wire csa_finish;
wire csa_finishadr;
wire csa_isInf; 
wire csa_sign_even,csa_sign_odd;
wire csa_rst_out;
wire csa_valid_out;
//for carry1
wire[79:0] carry1_frac_even;
wire[79:0] carry1_frac_odd;
wire[1:0] carry1_adr_even;
wire[1:0] carry1_adr_odd;
wire[2:0] carry1_block;
wire[127:0] carry1_frac_out;
wire carry1_clr_odd;
wire carry1_sign;
wire carry1_finish;

/////for ram
wire[79:0] ac0_even_q,ac0_odd_q;
wire[79:0] ac1_even_q,ac1_odd_q;

//////////
reg adr_select,carry_select;
reg ram_select;
reg isInf1,isInf2;
reg[13:0] isInf_delay;
wire carry1_enable;

///
reg carry1_clr_odd_buff;
reg csa_finishadr_delay,csa_finishadr_delay2;

initial
begin
	adr_select<=1'b0;
end
always@(posedge clk)begin
	if(csa_finishadr||csa_rst_out)begin 
		adr_select<=~adr_select; 
	end
	csa_finishadr_delay<=csa_finish;
	csa_finishadr_delay2<=csa_finishadr_delay;
	carry1_clr_odd_buff<=carry1_clr_odd;
	ram_select<=adr_select;
end

//solve infinit case
always@(posedge clk)begin
	if(ram_select)begin
		isInf1<=1'b0;
		isInf2<=isInf2||csa_isInf;
	end else
	begin
		isInf1<=isInf1||csa_isInf;
		isInf2<=1'b0;
	end
	
	isInf_delay[13:1]<=isInf_delay[12:0];
	isInf_delay[0]<=ram_select?isInf2:isInf1;
end

assign carry1_frac_odd=ram_select?ac0_odd_q:ac1_odd_q;
assign carry1_frac_even=ram_select?ac0_even_q:ac1_even_q;


assign carry1_enable=csa_finishadr_delay2;


reg select_buff,select_adr_buff,num_valid_buff,sign_even_buff,sign_odd_buff,clr_odd_buff;
reg[1:0] adr_even_csa_buff,adr_odd_csa_buff,adr_even_carry_buff,adr_odd_carry_buff;
reg[63:0] num_odd_buff,num_even_buff;

always@(posedge clk)begin
	select_buff			<=ram_select;
	select_adr_buff		<=adr_select;
	num_odd_buff		<=csa_frac_odd;
	num_even_buff		<=csa_frac_even;
	num_valid_buff		<=csa_valid_out;
	sign_even_buff		<=csa_sign_even;
	sign_odd_buff		<=csa_sign_odd;
	adr_even_csa_buff	<=csa_adr_even;
	adr_odd_csa_buff	<=csa_adr_odd;
	adr_even_carry_buff	<=carry1_adr_even;
	adr_odd_carry_buff	<=carry1_adr_odd;
	clr_odd_buff		<=carry1_clr_odd_buff;
end

addition_control ac0(
	.clk(clk),
	.select(~select_buff), ////if high, add number to ram
	.select_adr(~select_adr_buff),
	.num_odd(num_odd_buff),
	.num_even(num_even_buff),
	.num_valid(num_valid_buff),
	.sign_even(sign_even_buff),
	.sign_odd(sign_odd_buff),
	.adr_even_csa(adr_even_csa_buff),
	.adr_odd_csa(adr_odd_csa_buff),
	.adr_even_carry(carry1_adr_even),
	.adr_odd_carry(carry1_adr_odd),
	.clr_odd(carry1_clr_odd_buff),
	
	.even_q(ac0_even_q),
	.odd_q(ac0_odd_q)
);

addition_control ac1(
	.clk(clk),
	.select(select_buff), ////if high, add number to ram
	.select_adr(select_adr_buff),
	.num_odd(num_odd_buff),
	.num_even(num_even_buff),
	.num_valid(num_valid_buff),
	.sign_even(sign_even_buff),
	.sign_odd(sign_odd_buff),
	.adr_even_csa(adr_even_csa_buff),
	.adr_odd_csa(adr_odd_csa_buff),
	.adr_even_carry(carry1_adr_even),
	.adr_odd_carry(carry1_adr_odd),
	.clr_odd(carry1_clr_odd_buff),
	
	.even_q(ac1_even_q),
	.odd_q(ac1_odd_q)
);


CSA_carry carry1(
	.clk(clk),
	.enable(carry1_enable),
	.frac_even(carry1_frac_even),
	.frac_odd(carry1_frac_odd),
	
	.adr_even(carry1_adr_even),
	.adr_odd(carry1_adr_odd),
	.blk(carry1_block),
	.frac_out(carry1_frac_out),
	.clr_odd(carry1_clr_odd),
	.sign(carry1_sign),
	.finish(carry1_finish)
					);

					
unum_CSA unum_csa1(
	.clk(clk),
	.unum1(unum1),
	.unum2(unum2),
	.finish_in(finish),
	.rst(rst),
	.valid(valid),
	
	.frac_even(csa_frac_even),
	.frac_odd(csa_frac_odd),
	.adr_even(csa_adr_even),
	.adr_odd(csa_adr_odd),
	.finish_o(csa_finish),
	.finish_adr(csa_finishadr),
	.isInf(csa_isInf),
	.sign_even(csa_sign_even),
	.sign_odd(csa_sign_odd),
	.rst_out(csa_rst_out),
	.valid_out(csa_valid_out)
);


normalization normal1(
	.isInf(isInf_delay[13]),
	.clk(clk),
	.blk(carry1_block),
	.frac_in(carry1_frac_out),
	.sign(carry1_sign),
	.finish_in(carry1_finish),
	.rst(rst),
	
	.unum(sum),
	.isInf_out(isInf),
	.overflow(overflow),
	.finish_out(finish_out)
);
endmodule
 
module multiply_accumulator_buffer(
	input clk,
	//////
	input[31:0] unum1_in,
	input[31:0] unum2_in,
	input finish_in,
	input rst_in,
	input valid_in,
	//////
	output[31:0] unum1_out,
	output[31:0] unum2_out,
	output finish_out,
	output rst_out,
	output valid_out,
	/////
	input[31:0] sum_in,
	input isInf_in,
	input overflow_in,
	input finish_out_in,
	//////
	output[31:0] sum_out,
	output isInf_out,
	output overflow_out,
	output finish_out_out
	);
////input buffer
reg[31:0] unum1_buff,unum2_buff;
reg finish_buff,rst_buff,valid_buff;
always@(posedge clk)begin
	unum1_buff<=unum1_in;
	unum2_buff<=unum2_in;
	finish_buff<=finish_in;
	rst_buff<=rst_in;
	valid_buff<=valid_in;
end
assign unum1_out=unum1_buff;
assign unum2_out=unum2_buff;
assign finish_out=finish_buff;
assign rst_out=rst_buff;
assign valid_out=valid_buff;
///output buffer
reg[31:0] sum_buff;
reg isInf_buff,overflow_buff, finish_out_buffer;
always@(posedge clk)begin
	sum_buff<=sum_in;
	isInf_buff<=isInf_in;
	overflow_buff<=overflow_in;
	finish_out_buffer<=finish_out_in;
end
assign sum_out=sum_buff;
assign isInf_out=isInf_buff;
assign overflow_out=overflow_buff;
assign finish_out_out=finish_out_buffer;
endmodule
