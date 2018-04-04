module RAM_control(
		input clk,
		input[79:0] data,
		input[1:0] wraddress,
		input[1:0] rdaddress,
		input wren,
		
		output[79:0] q
		);

	
reg[79:0] dram[3:0];
reg[1:0] rdaddress_buff;
reg[79:0] output_buff;
//reg[1:0] wraddress_buff;
initial
begin
	dram[0]<=80'h0;
	dram[1]<=80'h0;
	dram[2]<=80'h0;
	dram[3]<=80'h0;
end
	
always@(posedge clk)begin
	if(wren)begin
		dram[rdaddress_buff]<=data;
	end
	if((rdaddress==rdaddress_buff)&wren)begin
		output_buff<=data;
	end else begin
		output_buff<=dram[rdaddress];
	end
	
	rdaddress_buff<=rdaddress;
end
assign q=output_buff;
			
endmodule 