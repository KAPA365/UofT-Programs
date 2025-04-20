module music_top3
(
 input clk,
 input rst_n,
 input play_en,
  	input start_stop,               //开始暂停
 output  play_done,
 output reg buzzer
) ;

parameter CLK_FRE   = 50_000_000 ;
parameter music_len = 32'd24 ;

wire [19:0]    cycle ;
reg  [31:0]    play_cnt ;
reg  [31:0]    music_cnt ;
reg  [19:0]    hz_cnt ;
wire [4:0]     hz_sel ;
wire [7:0]     rom_hz_data ;
wire [7:0]     rom_time_data ;
reg  [31:0]    music_time ;


parameter IDLE      = 2'd0 ;
parameter PLAY      = 2'd1 ;
parameter PLAY_WAIT = 2'd2 ;
parameter PLAY_END  = 2'd3 ;

reg [1:0]  state ;
reg [1:0]  next_state ;

always @(posedge clk or negedge rst_n)
begin
  if (~rst_n)
    state <= IDLE ;
  else
    state <= next_state ;
end

always @(*)
begin
  case(state)
  IDLE      : begin
                if (play_en)
                 next_state <= PLAY ;
					 else
					  next_state <= IDLE ; 
		        end
  PLAY      : begin
              if (play_cnt == music_time)  
				    next_state <= PLAY_WAIT  ;
				  else
				    next_state <= PLAY  ;
			     end
  PLAY_WAIT : begin
               if (music_cnt == music_len )
				     next_state <= PLAY_END  ;
				   else
				     next_state <= PLAY  ;
			     end
  PLAY_END  : next_state <= IDLE ;
  default   : next_state <= IDLE ;
  endcase
end

assign play_done= (state==PLAY_END ) ? 1'b1 :  1'b0 ;

//play counter
always @(posedge clk or negedge rst_n) 
begin
  if (~rst_n)
    music_time <= 32'hffff_ffff ;  
  else
    music_time <= rom_time_data*(CLK_FRE/8) ;
end

//counter in every step, maximum value is cycle
always @(posedge clk or negedge rst_n)
begin
  if (~rst_n)
    hz_cnt <= 20'd0 ;  
  else if (state == PLAY || state == PLAY_WAIT)
  begin
    if (hz_cnt == cycle - 1)
	   hz_cnt <= 20'd0 ;
	 else
      hz_cnt <= hz_cnt + 1'b1 ;
  end
  else 
    hz_cnt <= 20'd0 ;
end	
//buzzer out
always @(posedge clk or negedge rst_n)
begin
  if (~rst_n)
    buzzer <= 1'b1 ;  
  else if (state == PLAY || state == PLAY_WAIT)
  begin
    if (hz_cnt < cycle/2)                     //duty cycle to adjust buzzer volume
      buzzer <= 1'b0	;
	 else
	   buzzer <= 1'b1	;
  end
  else if (state == IDLE || state == PLAY_END)
    buzzer <= 1'b1 ;
end


//play counter
always @(posedge clk or negedge rst_n)
begin
  if (~rst_n)
    play_cnt <= 32'd0 ;  
   
     else if (state == PLAY)begin
          if (start_stop ==1'b1)  begin
             play_cnt <= play_cnt + 1'b1 ;
           end  
           else begin
               play_cnt <= play_cnt ;
           end 
      end        
     else  begin
         play_cnt <= 32'd0 ;
    end
end


//music step counter
always @(posedge clk or negedge rst_n)
begin
  if (~rst_n)
    music_cnt <= 32'd0 ;  

  else if (state == PLAY_WAIT)begin
     if (start_stop ==1'b1)  begin
         music_cnt <= music_cnt + 1'b1 ;
      end   
      else begin
        music_cnt <= music_cnt;
      end  
     end  
  else if (state == IDLE || state == PLAY_END)
    music_cnt <= 32'd0 ;
end



//根据数值输出不同频率值
music_hz  #(
	.CLK_FRE(CLK_FRE)
)hz0
(
 .hz_sel(rom_hz_data),
 .cycle(cycle) 
) ;


//音调
music_rom3 hz_rom
(
	.address(music_cnt[8:0]),
	.clock(clk),
	.q(rom_hz_data)
	);

//播放时长
rom_time3 rom_time1_u
(
	.address(music_cnt[8:0]),
	.clock(clk),
	.q(rom_time_data)
	);



endmodule
