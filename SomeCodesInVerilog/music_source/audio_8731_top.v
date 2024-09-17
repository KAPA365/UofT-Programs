`timescale  1ns/1ns
module  audio_8731_top
(
    input   wire    sys_clk         ,   //系统时钟，频率50MHz
    input   wire    sys_rst_n       ,   //系统复位，低电平有效
	input			frq,	//频率值
 	input     vol_add,
 	input     vol_sub,
//////////// Audio //////////
input		          		AUD_ADCDAT,
inout		          		AUD_ADCLRCK,
inout		          		AUD_BCLK,
output		        		AUD_DACDAT,
inout		          		AUD_DACLRCK,
output		        		AUD_XCK,

//////////// I2C for Audio and Tv-Decode //////////
output		        		I2C_SCLK,
inout		          		I2C_SDAT

);
   wire    AUD_CTRL_CLK    ;
wire    I2C_END;

	clk_gen     clk_gen_inst	(	
							 .rst ( ~sys_rst_n ),
							 .refclk ( sys_clk ),
							 .outclk_0   ( AUD_CTRL_CLK )// （ 18.432Mhz                         
							);
	adio_codec ad1	(	
	        
					// AUDIO CODEC //
					.oAUD_BCK 	( AUD_BCLK ),
					.oAUD_DATA	( AUD_DACDAT ),
					.oAUD_LRCK	( AUD_DACLRCK ),																
					.iCLK_18_4	( AUD_CTRL_CLK ),
					
					.sys_rst_n	  	( sys_rst_n ),							
					.frq	  	( frq )		
					);

reg  [6:0]  SPK_VOL;
always@(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n) 
		SPK_VOL <= 7'b1111000;  //7B
	else if( vol_add == 1'b1 )
		SPK_VOL  <= SPK_VOL +  1'b1;
	else if( vol_sub == 1'b1 )
		SPK_VOL  <= SPK_VOL - 1'b1;		
end

wire   I2C_RST_N ;
assign   I2C_RST_N = sys_rst_n &(~vol_add)&(~vol_sub );
//  I2C
	I2C_AV_Config 		I2C_AV_Config_u	(	//	Host Side
								 .iCLK		( sys_clk),
								 .iRST_N		( I2C_RST_N  ),
								 .o_I2C_END	( I2C_END ),
								 .SPK_VOL	( SPK_VOL ),								 
								   //	I2C Side
								 .I2C_SCLK	( I2C_SCLK ),
								 .I2C_SDAT	( I2C_SDAT )	
								);



//	AUDIO SOUND

	assign	AUD_ADCLRCK	=	AUD_DACLRCK;
	assign	AUD_XCK	   =	AUD_CTRL_CLK;			



endmodule
