module adio_codec (
	output			oAUD_DATA,
	output			oAUD_LRCK,
	output	reg		oAUD_BCK,////生产 16 位数据传输时钟，正弦波采样时钟的 32 倍
	input			iCLK_18_4,

	input			frq,	//频率值
	input			sys_rst_n

						);				

parameter	REF_CLK			=	18432000;	//	18.432	MHz
parameter	SAMPLE_RATE		=	48000;		//	48		KHz
parameter	DATA_WIDTH		=	16;			//	16		Bits
parameter	CHANNEL_NUM		=	2;			//	Dual Channel

parameter	SIN_SAMPLE_DATA	=	48;

//////////////////////////////////////////////////
//	Internal Registers and Wires
reg		[3:0]	BCK_DIV;
reg		[8:0]	LRCK_1X_DIV;
reg		[7:0]	LRCK_2X_DIV;
reg		[6:0]	LRCK_4X_DIV;
reg		[3:0]	SEL_Cont;
////////	DATA Counter	////////
reg		[5:0]	SIN_Cont;
reg [15:0]sin_out;
wire [15:0]  fangbo;

////////////////////////////////////
reg							LRCK_1X;
reg							LRCK_2X;
reg							LRCK_4X;

////////////	AUD_BCK Generator	//////////////
always@(posedge iCLK_18_4 or negedge sys_rst_n)
begin
	if(!sys_rst_n)
	begin
		BCK_DIV		<=	0;
		oAUD_BCK	<=	0;
	end
	else
	begin
		if(BCK_DIV >= REF_CLK/(SAMPLE_RATE*DATA_WIDTH*CHANNEL_NUM*2)-1 )
		begin
			BCK_DIV		<=	0;
			oAUD_BCK	<=	~oAUD_BCK; 
		end
		else
		BCK_DIV		<=	BCK_DIV+1;
	end
end
//////////////////////////////////////////////////
////////////	AUD_LRCK Generator	//////////////
always@(posedge iCLK_18_4 or negedge sys_rst_n)
begin
	if(!sys_rst_n)
	begin
		LRCK_1X_DIV	<=	0;
		LRCK_2X_DIV	<=	0;
		LRCK_4X_DIV	<=	0;
		LRCK_1X		<=	0;
		LRCK_2X		<=	0;
		LRCK_4X		<=	0;
	end
	else
	begin
		//	LRCK 1X
		if(LRCK_1X_DIV >= REF_CLK/(SAMPLE_RATE*2)-1 )
		begin
			LRCK_1X_DIV	<=	0;
			LRCK_1X	<=	~LRCK_1X;
		end
		else
		LRCK_1X_DIV		<=	LRCK_1X_DIV+1;
		//	LRCK 2X
		if(LRCK_2X_DIV >= REF_CLK/(SAMPLE_RATE*4)-1 ) 
		begin
			LRCK_2X_DIV	<=	0;
			LRCK_2X	<=	~LRCK_2X;
		end
		else
		LRCK_2X_DIV		<=	LRCK_2X_DIV+1;		
		//	LRCK 4X
		if(LRCK_4X_DIV >= REF_CLK/(SAMPLE_RATE*8)-1 )
		begin
			LRCK_4X_DIV	<=	0;
			LRCK_4X	<=	~LRCK_4X;
		end
		else
		LRCK_4X_DIV		<=	LRCK_4X_DIV+1;		
	end
end
assign	oAUD_LRCK	=	LRCK_1X; //////生产正弦波采样时钟 48khz

//////////////////////////////////////////////////
//////////	Sin LUT ADDR Generator	//////////////
always@(negedge LRCK_1X or negedge sys_rst_n)
begin
	if(!sys_rst_n)
	SIN_Cont	<=	0;
	else
	begin
		if(SIN_Cont < SIN_SAMPLE_DATA-1 )
		SIN_Cont	<=	SIN_Cont+1;
		else
		SIN_Cont	<=	0;
	end
end

	always@(negedge oAUD_BCK or negedge sys_rst_n)begin
		if(!sys_rst_n)
			SEL_Cont	<=	0;
		else
			SEL_Cont	<=	SEL_Cont+1;
	end

	reg  frq0;
	always@(negedge oAUD_LRCK or negedge sys_rst_n)begin
		if(!sys_rst_n)
			frq0	<=	1'b0;
		else
			frq0	<=  frq;
	end
	reg  frq1;
	always@(negedge oAUD_LRCK or negedge sys_rst_n)begin
		if(!sys_rst_n)
			frq1	<=	1'b0;
		else
			frq1	<=  frq0;
	end

assign  fangbo = {  1'b0  ,frq1,frq1,frq1,frq1,frq1,frq1,frq1
				   ,frq1,frq1,frq1,frq1,frq1,frq1,frq1,frq1
};
//	assign	oAUD_DATA	=  sin_out[~SEL_Cont];  ////产生 DA 转换器数字音频数据
	assign	oAUD_DATA	=  fangbo[~SEL_Cont];  ////产生 DA 转换器数字音频数据




always@(*) 
 begin 
 case(SIN_Cont) 
 0 : sin_out = 0 ; //32767*sin0 
 1 : sin_out = 4276 ; //32767*sin7.5（角度） 
 2 : sin_out = 8480 ; //32767*sin15（角度） 
 3 : sin_out = 12539 ; 
 4 : sin_out = 16383 ; 
 5 : sin_out = 19947 ; 
 6 : sin_out = 23169 ; 
 7 : sin_out = 25995 ; 
 8 : sin_out = 28377 ; 
 9 : sin_out = 30272 ; 
 10 : sin_out = 31650 ; 
 11 : sin_out = 32486 ; 
 12 : sin_out = 32767 ; 
 13 : sin_out = 32486 ; 
 14 : sin_out = 31650 ; 
 15 : sin_out = 30272 ; 
 16 : sin_out = 28377 ; 
 17 : sin_out = 25995 ; 
 18 : sin_out = 23169 ;
 19 : sin_out = 19947 ; 
 20 : sin_out = 16383 ; 
 21 : sin_out = 12539 ; 
 22 : sin_out = 8480 ; 
 23 : sin_out = 4276 ; 
 24 : sin_out = 0 ; 
 25 : sin_out = 61259 ; 
 26 : sin_out = 57056 ; 
 27 : sin_out = 52997 ; 
 28 : sin_out = 49153 ; 
 29 : sin_out = 45589 ; 
 30 : sin_out = 42366 ; 
 31 : sin_out = 39540 ; 
 32 : sin_out = 37159 ; 
 33 : sin_out = 35263 ; 
 34 : sin_out = 33885 ; 
 35 : sin_out = 33049 ; 
 36 : sin_out = 32768 ; 
 37 : sin_out = 33049 ; 
 38 : sin_out = 33885 ; 
 39 : sin_out = 35263 ; 
 40 : sin_out = 37159 ; 
 41 : sin_out = 39540 ; 
 42 : sin_out = 42366 ; 
 43 : sin_out = 45589 ; 
 44 : sin_out = 49152 ; 
 45 : sin_out = 52997 ; 
 46 : sin_out = 57056 ; 
 47 : sin_out = 61259 ;
 default:sin_out = 0 ;
 endcase 
 end

endmodule