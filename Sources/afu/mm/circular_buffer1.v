module circular_buffer1(
	input[1023:0] data,
	input rdreq,
	input wrreq,
	input clk,
	input rst,
	input start,
	input[31:0] row,
	input[31:0] column,
	input[31:0] row2,
	
	output valid_out,
	output init_finish,
	output rdempty,
	output finish_out,
	output[31:0] q
);

reg[8:0] wraddress,wraddress_buff,max_wr;
reg[13:0] rdaddress,rdaddress_buff,max_rd;
reg[9:0] time_repeat;
reg finish,wr_finish;

//wire[255:0] data0,data1,data2,data3;


////pipeline initialization
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
	start2<=start1;
	product<=row_buff*column_buff;
end


wire[31:0] max_rd_wire;
wire[26:0] max_wr_wire;
assign max_rd_wire=product[31:0]-32'b1;
assign max_wr_wire=product[31:5]-27'b1;
reg start3;
always@(posedge clk)begin
	max_rd<=max_rd_wire[13:0];
	max_wr<=max_wr_wire[8:0];
	start3<=start2;
end

reg init_flag;
always@(posedge clk)begin
	if(rst)begin
		init_flag<=1'b1;
	end else
	if(start3)begin
		init_flag<=1'b0;
	end
end

always@(posedge clk)begin
	if(start3)begin
		wraddress<=9'b0;
		rdaddress<=14'b0;
		finish<=1'b0;
		wr_finish<=1'b0;
		time_repeat<=row2_buff[15:6]-10'b1;
	end
	else begin
		if(rdreq)begin
			if(rdaddress==max_rd)begin
				rdaddress<=14'b0;
				if(time_repeat==10'b0)begin
					finish<=1'b1;
				end else begin
					time_repeat<=time_repeat-10'b1;
				end
			end else begin
				rdaddress<=rdaddress+14'b1;
			end
		end
		
		if(wrreq)begin
			if(wraddress==max_wr)begin
				wr_finish<=1'b1;
			end else begin
				wraddress<=wraddress+9'b1;
			end
		end
	end
end
reg valid;
always@(posedge clk)begin
	wraddress_buff<=(wrreq&&(wraddress!=max_wr))?wraddress:(wraddress+9'b1);
	valid	<= rdreq;
end

//buffer the input and output
reg[8:0] addra;
reg[13:0] addrb;
reg wea;
reg[1023:0] dina;
//output
reg rdempty_buff;
reg finish_out_buff;
reg init_finish_buff; 
reg valid_buff;
always@(posedge clk)begin
	addra	<=wraddress;
	dina	<=data;
	wea		<=wrreq&&(~wr_finish);
	addrb	<=rdaddress;
	
	rdempty_buff<=(wraddress==(rdaddress[13:5]-9'b1))&&(wraddress==rdaddress[13:5])&&(~wr_finish)||(finish);
	finish_out_buff<=finish;
	init_finish_buff<=init_flag;
	valid_buff<=valid;
end
//buffer the input and output
reg[8:0] addra2;
reg[13:0] addrb2;
reg wea2;
reg[1023:0] dina2;
//output
reg rdempty_buff2;
reg finish_out_buff2; 
reg valid_buff2;
always@(posedge clk)begin
	addra2	<=addra;
	dina2	<=dina;
	wea2	<=wea;
	addrb2	<=addrb;
	
	rdempty_buff2<=rdaddress_buff;
	finish_out_buff2<=finish_out_buff;
	valid_buff2<=valid_buff;
end


assign rdempty=(wraddress==rdaddress[13:5])&&(~wr_finish)||(finish);
assign finish_out=finish_out_buff2;
assign init_finish=init_finish_buff;
assign valid_out=valid_buff2;

ram_input1 ram0(
	.clka(clk),
	.clkb(clk),
	
	.addra(addra2),
	.dina(dina2),
	.wea(wea2),
	.addrb(addrb2),
	
	.doutb(q)
);


endmodule 