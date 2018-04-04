module addition_control(
	input clk,
	input select, ////if high, add number to ram
	input select_adr,
	input[63:0] num_odd,
	input[63:0] num_even,
	input num_valid,
	input sign_even,
	input sign_odd,
	input[1:0] adr_even_csa,
	input[1:0] adr_odd_csa,
	input[1:0] adr_even_carry,
	input[1:0] adr_odd_carry,
	input clr_odd,
	
	output[79:0] even_q,
	output[79:0] odd_q
);
/*reg select_buff,num_valid_buff,sign_even_buff,sign_odd_buff,clr_odd_buff;
reg[1:0] adr_even_csa_buff,adr_odd_csa_buff,adr_even_carry_buff,adr_odd_carry_buff;
reg[63:0] num_odd_buff,num_even_buff;

always@(posedge clk)begin
	select_buff			<=select;
	num_odd_buff		<=num_odd;
	num_even_buff		<=num_even;
	num_valid_buff		<=num_valid;
	sign_even_buff		<=sign_even;
	sign_odd_buff		<=sign_odd;
	adr_even_csa_buff	<=adr_even_csa;
	adr_odd_csa_buff	<=adr_odd_csa;
	adr_even_carry_buff	<=adr_even_carry;
	adr_odd_carry_buff	<=adr_odd_carry;
	clr_odd_buff		<=clr_odd;
end
*/
wire[1:0] odd_rdadr,even_rdadr,odd_wradr,even_wradr;
wire odd_enable,even_enable;
wire[79:0] odd_data,even_data;
reg select_delay;

assign odd_data=select?({{16{sign_odd}},num_odd}+odd_q):80'b0;
assign even_data=select?({{16{sign_even}},num_even}+even_q):80'b0;

assign odd_wradr=select?adr_odd_csa:adr_odd_carry;
assign even_wradr=select?adr_even_csa:adr_even_carry;

assign odd_rdadr=select_adr?adr_odd_csa:adr_odd_carry;
assign even_rdadr=select_adr?adr_even_csa:adr_even_carry;

assign even_enable=select?num_valid:1'b1;
assign odd_enable =select?num_valid:clr_odd;

always@(posedge clk)begin
	select_delay<=select;
end

RAM_control odd(
	.clk(clk),
	.data(odd_data),
	.wraddress(odd_wradr),
	.rdaddress(odd_rdadr),
	.wren(odd_enable),
	.q(odd_q)
);

RAM_control even(
	.clk(clk),
	.data(even_data),
	.wraddress(even_wradr),
	.rdaddress(even_rdadr),
	.wren(even_enable),
	.q(even_q)
);


endmodule 