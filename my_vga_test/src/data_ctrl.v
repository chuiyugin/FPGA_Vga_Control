`timescale  1ns/1ns
module data_ctrl(
    input                clk           ,  //时钟信号
    input                rst_n         ,  //复位信号,低电平有效
    input                sd_init_done  ,  //SD卡初始化完成信号
    //写SD卡接口
    input                wr_busy       ,  //写数据忙信号
    input                catch_finish  ,  //写数据请求信号



    output  reg          wr_start_en   ,  //开始写SD卡数据信号
    output  reg  [31:0]  wr_sec_addr     //写数据扇区地址

    );

//640*480/256 = 1200
parameter  RD_SECTION_NUM  = 11'd1200    ;  //单张图片总共写入的次数 

//reg define
reg              sd_init_done_d0  ;       //sd_init_done信号延时打拍
reg              sd_init_done_d1  ;       
reg              wr_busy_d0       ;       //wr_busy信号延时打拍
reg              wr_busy_d1       ;

//reg define
reg    [1:0]          wr_flow_cnt      ;    //读数据流程控制计数器
reg    [10:0]         wr_sec_cnt       ;    //读扇区次数计数器

//wire define
wire             pos_init_done    ;       //sd_init_done信号的上升沿,用于启动写入信号
wire             neg_wr_busy      ;       //wr_busy信号的下降沿,用于判断数据写入完成

//sd_init_done信号延时打拍
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        sd_init_done_d0 <= 1'b0;
        sd_init_done_d1 <= 1'b0;
    end
    else begin
        sd_init_done_d0 <= sd_init_done;
        sd_init_done_d1 <= sd_init_done_d0;
    end        
end

//wr_busy信号延时打拍
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        wr_busy_d0 <= 1'b0;
        wr_busy_d1 <= 1'b0;
    end    
    else begin
        wr_busy_d0 <= wr_busy;
        wr_busy_d1 <= wr_busy_d0;
    end
end 

assign  pos_init_done = (~sd_init_done_d1) & sd_init_done_d0;
assign  neg_wr_busy = wr_busy_d1 & (~wr_busy_d0);


//循环写入SD卡中
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        wr_flow_cnt <= 2'd0;
        wr_sec_cnt <= 11'd0;
        wr_start_en <= 1'b0;
        wr_sec_addr <= 32'd2000;         //任意指定一块扇区地址
    end
    else if(catch_finish) 
    begin
        wr_start_en <= 1'b0;
        case(wr_flow_cnt)
            2'd0 : begin
                //开始读取SD卡数据
                wr_flow_cnt <= wr_flow_cnt + 2'd1;
                wr_start_en <= 1'b1;
                wr_sec_addr <= 32'd2000;         //任意指定一块扇区地址
            end
            2'd1 : begin
                //读忙信号的下降沿代表读完一个扇区,开始读取下一扇区地址数据
                if(neg_wr_busy) begin                          
                    wr_sec_cnt <= wr_sec_cnt + 11'd1;
                    wr_sec_addr <= wr_sec_addr + 32'd1;
                    //单张图片读完
                    if(wr_sec_cnt == RD_SECTION_NUM - 11'b1) begin 
                        wr_sec_cnt <= 11'd0;
                        wr_flow_cnt <= 2'd0;
                    end    
                    else
                        wr_start_en <= 1'b1;                   
                end                    
            end

        endcase
        
    end    

end

endmodule