`timescale 1ns / 1ps
module fsm_ctl_tb(
    );
	
reg    			clk;
reg    			rst_n;
		reg                	stop;
		reg                	start;		
		reg                	next_song;
		reg                	pre_song;
// top Outputs
       wire [15:0]           o_pixel_data;                //像素点数据
		wire               	frq;		
		wire   start_stop;  //开始暂停  接一个led灯 用于观察指示
       wire [3:0]           o_hex_Data  ;              //hex	
	   


defparam DUT.music_top0_inst.CLK_FRE   = 50_000_000;	
defparam DUT.music_top1_inst.CLK_FRE   = 50_000_000;
defparam DUT.music_top2_inst.CLK_FRE   = 50_000_000;
defparam DUT.music_top3_inst.CLK_FRE   = 50_000_000;


parameter CLK_PERIOD=20 ;  //20ns ==>50mhz
always # (CLK_PERIOD/2)  clk = ~ clk;	

initial begin
clk = 0 ;
rst_n = 0;
stop  =0	;
start=0	;
next_song=0	;
pre_song=0	;


#50
	rst_n = 1 ;		//复位失效，开始工作
#100	

//=======case1========	
#50000

//#20000000   press_next_song;   





#500000 	 //直到结束
	$stop;
end



fsm_ctl  DUT (
    .clk                     ( clk         ),
    .rst_n                   ( rst_n       ),
    .AUD_DACLRCK                     ( AUD_DACLRCK         ),
    .stop                     ( stop         ),
    .start                     ( start         ),	
    .next_song                     ( next_song         ),
    .pre_song                     ( pre_song         ),	
    .pixel_data0                     ( 0         ),
    .pixel_data1                     ( 0         ),
    .pixel_data2                     ( 0         ),
    .pixel_data3                     ( 0         ),

    .o_pixel_data                ( o_pixel_data    ),
    .frq                     ( frq         ),
    .o_hex_Data               ( o_hex_Data   )
);


task press_stop;
	begin
		#500;
			@ (posedge clk);		
		stop  =1 ;
			@ (posedge clk);
		stop  =0 ;
		#500;
	end
endtask
task press_next_song;
	begin
		#500;
			@ (posedge clk);		
		next_song  =1 ;
			@ (posedge clk);
		next_song  =0 ;
		#500;
	end
endtask



endmodule
