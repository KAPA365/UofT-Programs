
module vga_display3(
    input             vga_clk,                  //VGA驱动时钟
    input             sys_rst_n,                //复位信号
    
    input      [ 9:0] pixel_xpos,               //像素点横坐标
    input      [ 9:0] pixel_ypos,               //像素点纵坐标    
    output reg [15:0] pixel_data                //像素点数据
    );    

//parameter define    
parameter  H_DISP  = 10'd640;                   //分辨率——行
parameter  V_DISP  = 10'd480;                   //分辨率——列
parameter HEART_SIZE = 10'd40; 

localparam SIDE_W  = 10'd40;                    //边框宽度
localparam BLOCK_W = 10'd60;                    //方块宽度
localparam BLUE    = 16'b00000_000000_11111;    //边框颜色 蓝色
localparam WHITE   = 16'b11111_111111_11111;    //背景颜色 白色
localparam BLACK   = 16'b00000_000000_00000;    //方块颜色 黑色
localparam RED     = 16'b11111_000000_00000;    //方块颜色
localparam GREEN   = 16'b00000_111111_00000;    //方块颜色
//reg define
reg [ 9:0] block_x;                             //方块左上角横坐标
reg [ 9:0] block_y;                             //方块左上角纵坐标
reg [21:0] div_cnt;                             //时钟分频计数器
reg        h_direct;                            //方块水平移动方向，1：右移，0：左移
reg        v_direct;                            //方块竖直移动方向，1：向下，0：向上

//wire define   
wire move_en;                                   //方块移动使能信号，频率为100hz

assign move_en = (div_cnt == 22'd250000 - 1'b1) ? 1'b1 : 1'b0;

//通过对vga驱动时钟计数，实现时钟分频
always @(posedge vga_clk or negedge sys_rst_n) begin         
    if (!sys_rst_n)
        div_cnt <= 22'd0;
    else begin
        if(div_cnt < 22'd250000 - 1'b1) 
            div_cnt <= div_cnt + 1'b1;
        else
            div_cnt <= 22'd0;                   //计数达10ms后清零
    end
end

//当方块移动到边界时，改变移动方向
always @(posedge vga_clk or negedge sys_rst_n) begin         
    if (!sys_rst_n) begin
        h_direct <= 1'b1;                       //方块初始水平向右移动
        v_direct <= 1'b1;                       //方块初始竖直向下移动
    end
    else begin
        if(block_x == (BLOCK_W + SIDE_W - 1'b1))            //到达左边界时，水平向右
            h_direct <= 1'b1;               
        else                                    //到达右边界时，水平向左
        if(block_x == (H_DISP - SIDE_W - BLOCK_W))
            h_direct <= 1'b0;               
        else
            h_direct <= h_direct;
            
        if(block_y == (BLOCK_W + SIDE_W - 1'b1)  )            //到达上边界时，竖直向下
            v_direct <= 1'b1;                
        else                                    //到达下边界时，竖直向上
        if(block_y == (V_DISP - SIDE_W - BLOCK_W)  )
            v_direct <= 1'b0;               
        else
            v_direct <= v_direct;
    end
end

//根据方块移动方向，改变其纵横坐标
always @(posedge vga_clk or negedge sys_rst_n) begin         
    if (!sys_rst_n) begin
        block_x <= 22'd100;                     //方块初始位置横坐标
        block_y <= 22'd100;                     //方块初始位置纵坐标
    end
    else if(move_en) begin
        if(h_direct) 
            block_x <= block_x + 1'b1;          //方块向右移动
        else
            block_x <= block_x - 1'b1;          //方块向左移动
            
        if(v_direct) 
            block_y <= block_y + 1'b1;          //方块向下移动
        else
            block_y <= block_y - 1'b1;          //方块向上移动
    end
    else begin
        block_x <= block_x;
        block_y <= block_y;
    end
end

function is_heart_pixel;
    input [9:0] x, y, heart_x, heart_y;
    begin
        // Define the heart shape logic here
        // For example, a simple placeholder condition:
        is_heart_pixel = (x - heart_x) ** 2 + (y - heart_y) ** 2 < HEART_SIZE ** 2;
    end
endfunction

always @(posedge vga_clk or negedge sys_rst_n) begin         
    if (!sys_rst_n) 
        pixel_data <= BLACK;
    else begin
        if((pixel_xpos < SIDE_W) || (pixel_xpos >= H_DISP - SIDE_W)
          || (pixel_ypos < SIDE_W) || (pixel_ypos >= V_DISP - SIDE_W))
            pixel_data <= BLUE;                 // 绘制边框为蓝色
        else if(is_heart_pixel(pixel_xpos, pixel_ypos, block_x, block_y))
            pixel_data <= RED;                  // 绘制心形为红色
        else
            pixel_data <= WHITE;                // 绘制背景为白色
    end
end


endmodule 