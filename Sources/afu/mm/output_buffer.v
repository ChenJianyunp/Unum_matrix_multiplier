module outputbuffer(
	input clk,
	input[2047:0] data,
	input rdreq,
	input wrreq,
	input rst,
	input start,
	input[31:0] row,
	input[31:0] column,
	input[31:0] row2,
	
	output rdempty,
	output[1023:0] q
);

reg empty_flag;
reg[9:0] rdaddress;
reg[8:0] wraddress,wr_step,repeat_cnt;
reg[15:0] row_buff,row_cnt;
reg rdempty_reg;
always@(posedge clk)begin
	if(start)begin
		rdaddress<=10'b0;
		wraddress<=9'b0;
		row_cnt=16'b0;
		repeat_cnt<=9'b1;
		empty_flag<=1'b1;
		
		wr_step<=row2[13:6];
		row_buff<=row[15:0]-16'b1;
	end
	else begin
		if(rdreq)begin
			rdaddress<=rdaddress+10'b1;
		end
		
		if(wrreq)begin
			if(row_cnt==row_buff)begin
				row_cnt<=16'b0;
				repeat_cnt<=repeat_cnt+9'b1;
				if(empty_flag)begin
					wraddress<=repeat_cnt;
				end else begin
					wraddress<=wraddress+9'b1;
				end
			end
			else begin
				wraddress<=wraddress+wr_step;
				row_cnt<=row_cnt+16'b1;
			end
		end
		
		if((repeat_cnt==wr_step))begin
			empty_flag<=1'b0;
		end
		
	end
	
	rdempty_reg<=(rdaddress==({wraddress,1'b0}-9'b1))||(rdaddress=={wraddress,1'b0})||empty_flag;
end

reg[9:0] rdaddress_i;
always@(*)begin
	if(rdreq)begin
		rdaddress_i<=rdaddress+10'b1;
	end else begin
		rdaddress_i<=rdaddress;
	end
end

assign rdempty=rdempty_reg;

ram_output output0(
	.addra(wraddress),
	.clka(clk),
	.dina(data),
	.wea(wrreq),
	
	.addrb(rdaddress_i),
	.clkb(clk),
	.doutb(q)
);



endmodule 