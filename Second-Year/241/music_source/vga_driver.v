module vga_driver(
    input           vga_clk,      //VGA驱动时钟
    input           rst_n,    //复位信号
    //VGA接口                       
    output          VGA_SYNC_N,     
    output          VGA_BLANK_N,    	
    output          vga_hs,       //行同步信号
    output          vga_vs,       //场同步信号
    output  [ 7:0]  VGA_R,   //
    output  [ 7:0]  VGA_G,    //  
    output  [ 7:0]  VGA_B,    //  
	
    input   [15:0]  vga_data,   //像素点数据
    output  [ 9:0]  vga_xpos,   //像素点横坐标
    output  [ 9:0]  vga_ypos    //像素点纵坐标    
    );                             
                                                        

parameter  H_SYNC   =  10'd96;    //行同步
parameter  H_BACK   =  10'd48;    //行显示后沿
parameter  H_DISP   =  10'd640;   //行有效数据
parameter  H_FRONT  =  10'd16;    //行显示前沿
parameter  H_TOTAL  =  10'd800;   //行扫描周期

parameter  V_SYNC   =  10'd2;     //场同步
parameter  V_BACK   =  10'd33;    //场显示后沿
parameter  V_DISP   =  10'd480;   //场有效数据
parameter  V_FRONT  =  10'd10;    //场显示前沿
parameter  V_TOTAL  =  10'd525;   //场扫描周期
          
		  
wire  [15:0]  vga_rgb;      //红绿蓝三原色输出  
//reg define                                     
reg  [9:0] hs_cnter;
reg  [9:0] vs_cnter;

//wire define
wire       vga_req;
wire       pix_req_en; 

assign VGA_R  = {   {3{vga_rgb[15]}}  ,vga_rgb[15:11]};
assign VGA_G  = {   {2{vga_rgb[10]}}  ,vga_rgb[10:5] };
assign VGA_B  = {   {3{vga_rgb[4]} } ,vga_rgb[4:0]};

/*
assign VGA_R  =   vga_rgb[23:16];
assign VGA_G  =   vga_rgb[15:8] ;
assign VGA_B  =   vga_rgb[7:0];
*/

assign VGA_SYNC_N   = vga_req;
assign VGA_BLANK_N  = vga_req;


//VGA行场同步信号
assign vga_hs  = (hs_cnter <= H_SYNC - 1'b1) ? 1'b0 : 1'b1;
assign vga_vs  = (vs_cnter <= V_SYNC - 1'b1) ? 1'b0 : 1'b1;

//使能RGB565数据输出
assign vga_req  = (((hs_cnter >= H_SYNC+H_BACK) && (hs_cnter < H_SYNC+H_BACK+H_DISP))
                 &&((vs_cnter >= V_SYNC+V_BACK) && (vs_cnter < V_SYNC+V_BACK+V_DISP)))
                 ?  1'b1 : 1'b0;
                 
//RGB565数据输出                 
assign vga_rgb = vga_req ? vga_data : 16'd0;

//请求像素点颜色数据输入                
assign pix_req_en = (((hs_cnter >= H_SYNC+H_BACK-1'b1) && (hs_cnter < H_SYNC+H_BACK+H_DISP-1'b1))
                  && ((vs_cnter >= V_SYNC+V_BACK) && (vs_cnter < V_SYNC+V_BACK+V_DISP)))
                  ?  1'b1 : 1'b0;

//像素点坐标                
assign vga_xpos = pix_req_en ? (hs_cnter - (H_SYNC + H_BACK - 1'b1)) : 10'd0;
assign vga_ypos = pix_req_en ? (vs_cnter - (V_SYNC + V_BACK - 1'b1)) : 10'd0;

//行计数器对像素时钟计数
always @(posedge vga_clk or negedge rst_n) begin         
    if (!rst_n)
        hs_cnter <= 10'd0;                                  
    else begin
        if(hs_cnter < H_TOTAL - 1'b1)                                               
            hs_cnter <= hs_cnter + 1'b1;                               
        else 
            hs_cnter <= 10'd0;  
    end
end

//场计数器对行计数
always @(posedge vga_clk or negedge rst_n) begin         
    if (!rst_n)
        vs_cnter <= 10'd0;                                  
    else if(hs_cnter == H_TOTAL - 1'b1) begin
        if(vs_cnter < V_TOTAL - 1'b1)                                               
            vs_cnter <= vs_cnter + 1'b1;                               
        else 
            vs_cnter <= 10'd0;  
    end
end

endmodule 