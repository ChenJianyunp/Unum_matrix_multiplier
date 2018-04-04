module circular_buffer2(
	input[1023:0] data,
	input rdreq,
	input wrreq,
	input clk,
	input rst,
	input start,
	input[31:0] row,
	input[31:0] row2,
	input[31:0] column,
	
	output finish,
	output[2047:0] q,
	output wr_finish
);

reg[8:0] wraddress,cnt_wr;
reg[9:0] time_repeat;
reg[7:0] rdaddress,rd_return,block;///////block=row/NUM_MA
reg[15:0] column_cnt1,column_cnt2;        
reg wr_finish_reg,finish_reg;
//wire[15:0] cnt_wr_wire,page_wire,rd_return_wire;
//assign cnt_wr_wire=row[12:5]*column[7:0]-16'b1;
//assign rd_return_wire=row[13:6]*column[7:0]-{10'b0,row[11:6]};

reg[15:0] row_buff,column_buff,row2_buff;
reg start1;
always@(posedge clk)begin
	if(start)begin
		row_buff<=row[15:0];
		column_buff<=column[15:0];
		row2_buff<=row2[15:0];	
	end
	start1<=start;
end

reg[31:0] product;
reg start2;
always@(posedge clk)begin
	product<=row_buff*column_buff;
	start2<=start1;
end

reg[15:0] column_buff2,row_buff2,row2_buff2;
reg start3;
always@(posedge clk)begin
	column_buff2<=column_buff[15:0]-16'b1;
	row_buff2<=row_buff[15:0]-16'b1;
	start3<=start2;
	cnt_wr<=product[13:5]-9'b1;
	rd_return<=product[13:6]-row_buff[13:6];
	block<=row_buff[13:6];
	row2_buff2<=row2_buff[15:0];
end


always@(posedge clk)begin
	if(start3)begin
		wraddress<=9'b0;
		rdaddress<=8'b0;
		column_cnt1<=16'b0;
		column_cnt2<=16'b0;
		wr_finish_reg<=1'b0;
		finish_reg<=1'b0;
		time_repeat<=10'b1;
	end else begin
		if(rdreq)begin
			if(column_cnt1==column_buff2)begin
				if(column_cnt2==row_buff2)begin
					rdaddress<=time_repeat[7:0];
					if(time_repeat==row2_buff2)begin
						time_repeat<=10'b1;
					end
					else begin
						time_repeat<=time_repeat+10'b1;
					end
					column_cnt2<=16'b0;
				end else begin
					column_cnt2<=column_cnt2+16'b1;
					rdaddress<=rdaddress-rd_return;
				end
				column_cnt1<=16'b0;
				finish_reg<=1'b1;
			end else begin
				column_cnt1<=column_cnt1+16'b1;
				rdaddress<=rdaddress+block;
				finish_reg<=1'b0;
			end
		end
		else begin
			finish_reg<=1'b0;
		end
		
		if(wrreq)begin
			if(wraddress==cnt_wr)begin
				wr_finish_reg<=1'b1;
			end else begin
				wraddress<=wraddress+9'b1;
			end
		end
		
	end
	
end



reg[8:0] addra;
reg[7:0] addrb;
reg[1023:0] dina;
reg wea;
reg finish_buff;
always@(posedge clk)begin
	addra<=wraddress;
	addrb<=rdaddress;
	dina<=data;
	wea<=wrreq&&(~wr_finish_reg);
	finish_buff<=finish_reg;
end

reg[8:0] addra2;
reg[7:0] addrb2;
reg[1023:0] dina2;
reg wea2;
reg finish_buff2;
always@(posedge clk)begin
	addra2<=addra;
	addrb2<=addrb;
	dina2<=dina;
	wea2<=wea;
	finish_buff2<=finish_buff;
end

assign wr_finish=wr_finish_reg;
assign finish=finish_buff2;

ram_input2 ram0(
	.clka(clk),
	.clkb(clk),
	
	.addra(addra2),
	.dina(dina2),
	.wea(wea2),
	.addrb(addrb2),
	
	.doutb(q)
);

endmodule 