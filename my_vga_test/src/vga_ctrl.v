`timescale  1ns/1ns

module vga_ctrl (
    input wire             sys_clk,
	 input wire             vga_clk,
    input wire             sys_rst_n,
    input wire   [15:0]    pix_data,
    input wire             click,

    //output reg             catch_valid,
	 output reg             catch_finish,//截图完成状态指示
    output wire            data_req,   //请求像素点颜色数据写入
    output wire  [9:0]     pix_x,
    output wire  [9:0]     pix_y,
    output wire            hsync,
    output wire            vsync,
    output wire  [15:0]    vga_rgb
);


//parameter define
parameter H_SYNC    =   10'd96  ,   //琛屽悓姝
          H_BACK    =   10'd40  ,   //琛屾椂搴忓悗娌
          H_LEFT    =   10'd8   ,   //琛屾椂搴忓乏杈规
          H_VALID   =   10'd640 ,   //琛屾湁鏁堟暟鎹
          H_RIGHT   =   10'd8   ,   //琛屾椂搴忓彸杈规
          H_FRONT   =   10'd8   ,   //琛屾椂搴忓墠娌
          H_TOTAL   =   10'd800 ;   //琛屾壂鎻忓懆鏈

parameter V_SYNC    =   10'd2   ,   //鍦哄悓姝
          V_BACK    =   10'd25  ,   //鍦烘椂搴忓悗娌
          V_TOP     =   10'd8   ,   //鍦烘椂搴忎笂杈规
          V_VALID   =   10'd480 ,   //鍦烘湁鏁堟暟鎹
          V_BOTTOM  =   10'd8   ,   //鍦烘椂搴忎笅杈规
          V_FRONT   =   10'd2   ,   //鍦烘椂搴忓墠娌
          V_TOTAL   =   10'd525 ;   //鍦烘壂鎻忓懆鏈

   
//wire  define
wire            rgb_valid       ;   //VGA鏈夋晥鏄剧ず鍖哄煙
wire            pix_data_req    ;   //鍍忕礌鐐硅壊褰╀俊鎭姹備俊鍙
       

//reg   define
reg    [9:0]    cnt_h;              //琛屽悓姝ヤ俊鍙疯鏁板櫒
reg    [9:0]    cnt_v;              //鍦哄悓姝ヤ俊鍙疯鏁板櫒
reg             my_click;           //按键按下状态指示
reg             catch;              //截图状态指示
reg             catch_valid;

//按键按下后
//always@(posedge sys_clk or negedge sys_rst_n)
//    if(sys_rst_n == 1'b0)
//        my_click <= 1'd0;
//    else if(click==1'b1)
//        my_click <= 1'd1;

//截图有效使能状态
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            catch_valid <= 1'd0;
            catch <= 1'd0;
				my_click <= 1'd0;
				catch_finish <= 1'd0;
        end
	 else if(click==1'b1)
        my_click <= 1'd1;	  
    else if(my_click==1'b1 && cnt_h==1'b0 && cnt_v==1'b0)
        begin
            catch_valid <= 1'd1;
            catch <= 1'd1;
        end
    else if(my_click==1'b1 && cnt_h==H_TOTAL - 2'd2 && cnt_v==V_TOTAL - 2'd2 && catch==1'b1 )
        begin
            catch_valid <= 1'd0;
            catch <= 1'd0;
            my_click <= 1'd0;
				catch_finish <= 1'd1;
        end

		  
		  
//写入数据使能信号
assign data_req = catch_valid ? pix_data_req : 1'b0;


//琛岃鏁板櫒浠ｇ爜
always@(posedge vga_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_h <= 10'd0;
    else if(cnt_h == H_TOTAL - 1'b1)
        cnt_h <= 10'd0;
    else
        cnt_h <= cnt_h + 1'b1;

//鍦鸿鏁板櫒浠ｇ爜
always@(posedge vga_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_v <= 10'd0;
    else    if((cnt_v == V_TOTAL - 1'd1) &&  (cnt_h == H_TOTAL-1'd1))
        cnt_v   <=  10'd0 ;
    else    if(cnt_h == H_TOTAL - 1'd1)
        cnt_v   <=  cnt_v + 1'd1 ;
    else
        cnt_v   <=  cnt_v ;

//rgb_valid:VGA鏈夋晥鏄剧ず鍖哄煙
assign  rgb_valid = (((cnt_h >= H_SYNC + H_BACK + H_LEFT)
                    && (cnt_h < H_SYNC + H_BACK + H_LEFT + H_VALID))
                    &&((cnt_v >= V_SYNC + V_BACK + V_TOP)
                    && (cnt_v < V_SYNC + V_BACK + V_TOP + V_VALID)))
                    ? 1'b1 : 1'b0;

						  
assign  pix_data_req = (((cnt_h >= H_SYNC + H_BACK + H_LEFT - 1'b1)
                    && (cnt_h < H_SYNC + H_BACK + H_LEFT + H_VALID - 1'b1))
                    &&((cnt_v >= V_SYNC + V_BACK + V_TOP)
                    && (cnt_v < V_SYNC + V_BACK + V_TOP + V_VALID)))
                    ? 1'b1 : 1'b0;

assign pix_x = (pix_data_req == 1'b1) ? (cnt_h - (H_SYNC + H_BACK + H_LEFT - 1'b1)) : 10'h3ff;

assign pix_y = (pix_data_req == 1'b1) ? (cnt_v - (V_SYNC + V_BACK + V_TOP)) : 10'h3ff;

//hsync:琛屽悓姝ヤ俊鍙
assign  hsync = (cnt_h  <=  H_SYNC - 1'd1) ? 1'b1 : 1'b0  ;

//vsync:鍦哄悓姝ヤ俊鍙
assign  vsync = (cnt_v  <=  V_SYNC - 1'd1) ? 1'b1 : 1'b0  ;

//rgb:杈撳嚭鍍忕礌鐐硅壊褰╀俊鎭
assign  vga_rgb = (rgb_valid == 1'b1) ? pix_data : 16'b0 ;



endmodule