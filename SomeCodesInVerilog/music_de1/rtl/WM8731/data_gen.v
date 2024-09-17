module data_gen(
 input clock_ref, //wm8731 输入时钟,18.432Mhz; 
 input reset_n, 
 output reg dacclk, 
 output dacdat, 
 output reg  bclk 
);

 
 //reg dacclk; 
 reg [8:0]dacclk_cnt; 
 // bclk; 
 reg [3:0]bclk_cnt; 
 reg [3:0]data_num; 
 reg [15:0]sin_out; 
 reg [5:0]sin_index; 
 
 parameter CLOCK_REF=18432000; 
 parameter CLOCK_SAMPLE=48000; 
 
 always@(posedge clock_ref or negedge reset_n) //生产正弦波采样时钟 48khz 
 if(!reset_n) 
    dacclk_cnt<=0; 
 else if(dacclk_cnt>=(CLOCK_REF/(CLOCK_SAMPLE*2)-1)) 
    dacclk_cnt<=0; 
 else 
    dacclk_cnt<=dacclk_cnt+1'b1; 
 
 always@(posedge clock_ref or negedge reset_n) //生产正弦波采样时钟 48khz 
 if(!reset_n) 
    dacclk<=0; 
 else if(dacclk_cnt>=(CLOCK_REF/(CLOCK_SAMPLE*2)-1)) 
    dacclk<=~dacclk; 

    
 always@(posedge clock_ref or negedge reset_n) //生产 16 位数据传输时钟，正弦波采样时钟的 32 倍 
 if(!reset_n) 
    bclk_cnt<=0; 
 else if(bclk_cnt>=(CLOCK_REF/(CLOCK_SAMPLE*2*16*2)-1)) 
    bclk_cnt<=0; 
 else 
    bclk_cnt <= bclk_cnt + 1'b1; 

 always@(posedge clock_ref or negedge reset_n) //生产 16 位数据传输时钟，正弦波采样时钟的 32 倍
if(!reset_n) 
    bclk<=0; 
 else if(bclk_cnt>=(CLOCK_REF/(CLOCK_SAMPLE*2*16*2)-1)) 
    bclk<=~bclk; 
    

 always@(negedge bclk or negedge reset_n) 
    if(!reset_n) 
    data_num<=0; 
 else 
     data_num<=data_num + 1'b1; //0-16 
 
 always@(negedge dacclk or negedge reset_n) 
 if(!reset_n) 
    sin_index<=0; 
 else if(sin_index<47) 
    sin_index<=sin_index+1'b1; 
 else 
    sin_index<=0; 
 
 assign dacdat=sin_out[~data_num]; //产生 DA 转换器数字音频数据 
 
 always@(sin_index) 
 begin 
 case(sin_index) 
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