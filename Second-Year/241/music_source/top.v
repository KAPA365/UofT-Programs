module top(
    input           clk,        //系统时钟
    input           sys_rst_n,      //复位信号
    input           key1,      
// Bidirectionals
//////////// PS2 //////////
inout		          		PS2_CLK,
inout		          		PS2_DAT,
inout		          		PS2_CLK2,
inout		          		PS2_DAT2,

//////////// Audio //////////
input		          		AUD_ADCDAT,
inout		          		AUD_ADCLRCK,
inout		          		AUD_BCLK,
output		        		AUD_DACDAT,
inout		          		AUD_DACLRCK,
output		        		AUD_XCK,

//////////// I2C for Audio and Tv-Decode //////////
output		        		I2C_SCLK,
inout		          		I2C_SDAT,
output		        		LEDR,  //点亮播放 熄灭暂停

	output	[6:0] HEX0,
	output	[6:0] HEX1,
	output	[6:0] HEX5,		
    //VGA接口         
	output          vga_clk,             //25Mhz时钟	                     
    output          VGA_SYNC_N,     
    output          VGA_BLANK_N,    	
    output          vga_hs,       //行同步信号
    output          vga_vs,       //场同步信号
    output  [ 7:0]  VGA_R,   //
    output  [ 7:0]  VGA_G,    //  
    output  [ 7:0]  VGA_B    //  


    ); 
 //wire define

wire         locked;              //PLL输出稳定信号
wire         rst_n_w;               //内部复位信号
wire [15:0]  vga_data0;          //像素点数据0
wire [15:0]  vga_data1;          //像素点数据1
wire [15:0]  vga_data2;          //像素点数据2
wire [15:0]  vga_data3;          //像素点数据3
wire [3:0]           o_hex_Data  ;              //hex	
wire [ 9:0]  vga_xpos_w;          //像素点横坐标
wire [ 9:0]  vga_ypos_w;          //像素点纵坐标    
// fsm_ctl Outputs
wire  [15:0]  o_vga_data;       
 wire  frq;
  //待PLL输出稳定之后，停止复位
assign rst_n_w = sys_rst_n && locked;
  assign PS2_DAT2 = 1'b1;	
assign PS2_CLK2 = 1'b1; 

//wire    AUD_CTRL_CLK;


		pll   pll_inst (
		.refclk   (clk),   //  refclk.clk
		.rst      (~sys_rst_n),      //   reset.reset
		.outclk_0 (vga_clk), // outclk0.clk
		.outclk_1 (), // outclk1.clk
		.locked   (locked)    //  locked.export
	);
	
 //  assign vga_clk = clk;	
//	assign rst_n_w = sys_rst_n ;

wire	[7:0]	dout;
wire		 	data_vaild;

PS2_Controller  u_PS2_Controller (
    .CLOCK_50                       ( clk                        ),
    .reset                          ( ~sys_rst_n                           ),
    .the_command                    (                      ),
    .send_command                   (                     ),

    .command_was_sent               (                 ),
    .error_communication_timed_out  (    ),

     .data_vaild                  (  data_vaild                  ),
    .dout                         (        dout         ),   
    .received_data                  (                    ),
    .received_data_en               (                 ),

    .PS2_CLK                        ( PS2_CLK                         ),
    .PS2_DAT                        ( PS2_DAT                         )
);

  wire          bt_d;
bt_debounce  u_bt_debounce(
    .clk                     (  clk       ),  
   .rst_n                   ( sys_rst_n      ),

    .bt                   ( key1   ),
    .bt_d             ( bt_d   )	
	
);
  	
	
wire next_song ;
wire pre_song  ;
wire vol_add   ;
wire vol_sub   ;
wire stop      ;
wire start     ;

assign  next_song  =  (dout == 8'h05) && data_vaild;   //  F1
assign  pre_song   =  (dout == 8'h06) && data_vaild;   //  F2
assign  vol_add    =  (dout == 8'h04) && data_vaild;   //  F3
assign  vol_sub    =  (dout == 8'h0c) && data_vaild;   //  F4
assign  stop       =  (dout == 8'h03) && data_vaild;   //  F5
assign  start      =  (dout == 8'h0B) && data_vaild;   //  F6
fsm_ctl  u_fsm_ctl (
    .clk                     (  clk       ),  
    .AUD_DACLRCK                     (  AUD_DACLRCK       ),  //AUD_DACLRCK = 48k  
   .rst_n                   ( sys_rst_n      ),
    .frq                   ( frq      ),
    .stop                   ( stop   ),
     .start                   ( start        ),   
    .next_song                 ( next_song          ), //bt_d
    .pre_song                 (pre_song         ),   
    .pixel_data0             ( vga_data0    ),
    .pixel_data1             ( vga_data1    ),
    .pixel_data2             ( vga_data2    ),
    .pixel_data3             ( vga_data3    ),
    .o_pixel_data            ( o_vga_data   ),
    .start_stop              ( LEDR   ),
    .o_hex_Data             ( o_hex_Data   )	
	
);
  


audio_8731_top  u_audio_8731_top (
    .sys_clk                 ( clk       ),
    .sys_rst_n               ( sys_rst_n     ),
    .frq                     ( frq     ),
    .vol_add( vol_add),
    .vol_sub( vol_sub),

    .AUD_ADCDAT              ( AUD_ADCDAT    ),

    .AUD_DACDAT              ( AUD_DACDAT    ),
    .AUD_XCK                 ( AUD_XCK       ),
    .I2C_SCLK                ( I2C_SCLK      ),

    .AUD_ADCLRCK             ( AUD_ADCLRCK   ),
    .AUD_BCLK                ( AUD_BCLK      ),
    .AUD_DACLRCK             ( AUD_DACLRCK   ),
    .I2C_SDAT                ( I2C_SDAT      )
);



vga_driver u_vga_driver(
    .vga_clk        (vga_clk),    
    .rst_n          (rst_n_w),    

    .VGA_SYNC_N         (VGA_SYNC_N),       
    .VGA_BLANK_N         (VGA_BLANK_N), 
    .vga_hs         (vga_hs),       
    .vga_vs         (vga_vs),       
    .VGA_R        (VGA_R),      
    .VGA_G        (VGA_G),  
    .VGA_B        (VGA_B),  


	
    .vga_data     (o_vga_data), 
    .vga_xpos     (vga_xpos_w), 
    .vga_ypos     (vga_ypos_w)
    ); 


vga_display0 vga_display_U0(
    .vga_clk        (vga_clk),
    .sys_rst_n      (rst_n_w),
    
    .pixel_xpos     (vga_xpos_w),
    .pixel_ypos     (vga_ypos_w),
    .pixel_data     (vga_data0)
    ); 
	
vga_display1 vga_display_U1(
    .vga_clk        (vga_clk),
    .sys_rst_n      (rst_n_w),
    
    .pixel_xpos     (vga_xpos_w),
    .pixel_ypos     (vga_ypos_w),
    .pixel_data     (vga_data1)
    ); 
	
	vga_display2 vga_display_U2(
    .vga_clk        (vga_clk),
    .sys_rst_n      (rst_n_w),
    
    .pixel_xpos     (vga_xpos_w),
    .pixel_ypos     (vga_ypos_w),
    .pixel_data     (vga_data2)
    ); 
	
vga_display3 vga_display_U3(
    .vga_clk        (vga_clk),
    .sys_rst_n      (rst_n_w),
    
    .pixel_xpos     (vga_xpos_w),
    .pixel_ypos     (vga_ypos_w),
    .pixel_data     (vga_data3)
    ); 
	
seg7	u0	(	.c(dout[3  : 0 ]	),   .display(HEX0)	);
seg7	u1	(	.c(dout[7  : 4 ]	),   .display(HEX1)	);
seg7	u5	(	.c(o_hex_Data  ),   .display(HEX5)	);   

endmodule 