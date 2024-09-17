//状态机控制
module fsm_ctl(
		input					clk,
		input                	AUD_DACLRCK,		
		input                	rst_n,
		input                	stop,
		input                	start,		
		input                	next_song,
		input                	pre_song,

        input [15:0]            pixel_data0,                //像素点数据0
        input [15:0]            pixel_data1,                //像素点数据1		
        input [15:0]            pixel_data2,                //像素点数据2
        input [15:0]            pixel_data3,                //像素点数据2		
        output reg [15:0]           o_pixel_data,                //像素点数据
		output  reg              	frq,		
		output  reg  start_stop,  //开始暂停  接一个led灯 用于观察指示
        output reg [3:0]           o_hex_Data                //hex	
    );

	localparam			idle     = 3'd0; 	//状态0，	
	localparam			BAR0     = 3'd1; 	//状态0，
	localparam			BAR1     = 3'd2;    //状态1，
	localparam			BAR2     = 3'd3;    //状态2，
	localparam			BAR3     = 3'd4;    //状态3，	

reg		[2:0]		c_state  ;
reg		[2:0]		next_state;

wire  music_rst_n;
wire buzzer0;
wire buzzer1;
wire buzzer2;
wire buzzer3;

reg play_en0;
reg play_en1;
reg play_en2;
reg play_en3;

wire play_done0;
wire play_done1;
wire play_done2;
wire play_done3;


always@(posedge clk or negedge rst_n) begin
	if(!rst_n) 
		c_state <= idle;
	else 
		c_state  <= next_state;		
end

always@(*) begin
	case(c_state)
		idle: begin	 
				next_state = BAR0;		
			end		

		BAR0: begin
			if(next_song ) 	 
				next_state = BAR1;		
			else if(pre_song)	
				next_state = BAR3;				
			else  		
				next_state = BAR0;
			end		


		BAR1: begin
			if(next_song ) 	 
				next_state = BAR2;		
			else if(pre_song)	
				next_state = BAR0;				
			else  		
				next_state = BAR1;
			end	

		BAR2: begin
			if(next_song ) 	 
				next_state = BAR3;		
			else if(pre_song)	
				next_state = BAR1;				
			else  		
				next_state = BAR2;
			end	

		BAR3: begin
			if(next_song ) 	 
				next_state = BAR0;		
			else if(pre_song)	
				next_state = BAR2;				
			else  		
				next_state = BAR3;
			end	

			
		default: next_state = idle;
	endcase
end
reg  music_top0_rstn;
reg  music_top1_rstn;
reg  music_top2_rstn;
reg  music_top3_rstn;
always@(*) begin 
		
	 if(c_state == BAR0 )
		music_top0_rstn  <= 1'b1;
	else
		music_top0_rstn <= 1'b0;
end

always@(*) begin
	 if(c_state == BAR1 )
		music_top1_rstn  <= 1'b1;
	else
		music_top1_rstn <= 1'b0;
end

always@(*) begin
	 if(c_state == BAR2 )
		music_top2_rstn  <= 1'b1;
	else
		music_top2_rstn <= 1'b0;
end

always@(*) begin
	 if(c_state == BAR3 )
		music_top3_rstn  <= 1'b1;
	else
		music_top3_rstn <= 1'b0;
end

always@(*) begin
 if(c_state == BAR0 )
     o_pixel_data <= pixel_data0 ;
 else if(c_state == BAR1 )
     o_pixel_data <= pixel_data1 ;
  else if(c_state == BAR2 )
     o_pixel_data <= pixel_data2 ;  
  else if(c_state == BAR3 )
     o_pixel_data <= pixel_data3 ;  	 
 else
    o_pixel_data <= 16'b11111_000000_00000;     //RGB565 红色 
end

always@(*) begin
 if(c_state == BAR0 )
     o_hex_Data <= 4'h1 ;
 else if(c_state == BAR1 )
         o_hex_Data <= 4'h2 ;
  else if(c_state == BAR2 )
         o_hex_Data <= 4'h3 ;
  else if(c_state == BAR3 )
        o_hex_Data <= 4'h4 ;
 else
    o_hex_Data <= 4'd0;     
end


always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		play_en0 <= 1'b0;
		play_en1 <= 1'b0;
		play_en2 <= 1'b0;
		play_en3 <= 1'b0;				
	end
	else if(c_state == BAR0 )begin
    	play_en0 <= 1'b1;
		play_en1 <= 1'b0;
		play_en2 <= 1'b0;
		play_en3 <= 1'b0;	
	end
	else if(c_state == BAR1 )begin
    	play_en0 <= 1'b0;
		play_en1 <= 1'b1;
		play_en2 <= 1'b0;
		play_en3 <= 1'b0;	
	end
	else if(c_state == BAR2 )begin
    	play_en0 <= 1'b0;
		play_en1 <= 1'b0;
		play_en2 <= 1'b1;
		play_en3 <= 1'b0;	
	end
	else if(c_state == BAR3 )begin
    	play_en0 <= 1'b0;
		play_en1 <= 1'b0;
		play_en2 <= 1'b0;
		play_en3 <= 1'b1;	
	end
	else begin
		play_en0 <= 1'b0;
		play_en1 <= 1'b0;
		play_en2 <= 1'b0;
		play_en3 <= 1'b0;				
	end

end
	

assign  music_rst_n = rst_n & (~next_song )& (~pre_song );
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) 
		start_stop <= 1'b1;
	else if( stop == 1'b1 )
		start_stop  <=  1'b0;
	else if( start == 1'b1 )
		start_stop  <= 1'b1;		
end
 music_top0  music_top0_inst
(
	.clk		(clk			),
	.rst_n		( rst_n & music_top0_rstn			),
	.start_stop	    (start_stop		),
	.play_en	(	play_en0	),  //play_en0
	.play_done	(		),
	.buzzer		(buzzer0		)
) ;

 music_top1  music_top1_inst
(
	.clk		(clk			),
	.rst_n		(rst_n & music_top1_rstn			),
	.start_stop	    (start_stop		),	
	.play_en	(	play_en1	),  //play_en1
	.play_done	(		),
	.buzzer		(buzzer1		)
) ;

 music_top2  music_top2_inst
(
	.clk		(clk			),
	.rst_n		(rst_n & music_top2_rstn			),
	.start_stop (start_stop		),	
	.play_en	(	play_en2	), //play_en2
	.play_done	(		),
	.buzzer		(buzzer2		)
) ;


 music_top3  music_top3_inst
(
	.clk		(clk			),
	.rst_n		(rst_n & music_top3_rstn			),
	.start_stop	    (start_stop		),	
	.play_en	(	play_en3), //play_en3
	.play_done	(		),
	.buzzer		(buzzer3		)
) ;


//assign 	frq =  ~(buzzer0 &buzzer1 &buzzer2 &buzzer3);
	
//assign 	frq =  ~buzzer0 ;
//assign 	frq =  ~buzzer1 ;
//assign 	frq =  ~buzzer2 ;
//assign 	frq =  ~buzzer3 ;

always@(posedge clk or negedge rst_n) begin
	if(!rst_n) 
	 frq <= 1'd0;    
	else if (start_stop ==1'b1)  begin	 
		if(c_state == BAR0 )
			frq <= ~buzzer0;
		else if(c_state == BAR1 )
				frq <=  ~buzzer1 ;
		else if(c_state == BAR2 )
				frq <= ~buzzer2 ;
		else if(c_state == BAR3 )
			frq <=  ~buzzer3 ;
		else
		frq <= 1'd0;    
	end
	else  begin		
		frq <= 1'd0; 
	end
	
end

endmodule
