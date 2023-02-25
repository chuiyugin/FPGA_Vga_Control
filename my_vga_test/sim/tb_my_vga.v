`timescale  1ns/1ns

module  tb_my_vga();


//wire define
wire                hsync ;
wire                vsync ;
wire  [15:0]        rgb   ;
        
wire                sd_miso    ;
wire                sd_clk     ;
wire                sd_cs      ;
wire                sd_mosi    ;
        
wire                sdram_clk  ;
wire                sdram_cke  ;
wire                sdram_cs_n ;
wire                sdram_ras_n;
wire                sdram_cas_n;
wire                sdram_we_n ;
wire   [1:0]        sdram_ba   ;
wire   [1:0]        sdram_dqm  ;
wire   [12:0]       sdram_addr ;
wire   [15:0]       sdram_data ;


//reg define
reg             sys_clk     ;
reg             sys_rst_n   ;
reg             rx          ;
reg     [7:0]   data_mem [7:0] ;  //data_mem是一个存储器，相当于一个ram
reg             key_in;


//读取sim文件夹下面的data.txt文件，并把读出的数据定义为data_mem
initial
    $readmemh("E:/Quartus_FPGA_learning/my_vga/sim/test.txt",data_mem);

//时钟、复位信号
initial
  begin
    sys_clk     <=   1'b1  ;
    sys_rst_n   <=  1'b0  ;
    key_in      <=  1'b1;
    #200
    sys_rst_n   <=  1'b1  ;
  
  end

always  #10 sys_clk = ~sys_clk;

//按键
initial                                                
begin
    #1000000  key_in <=1'b0;
    #1500    key_in <=1'b1;

end

//rx
initial
    begin
        rx  <=  1'b1;
        #200
        rx_byte();
    end

//rx_byte
task    rx_byte();
    integer j;
    for(j=0;j<8;j=j+1)
        rx_bit(data_mem[j]);
endtask

//rx_bit
task    rx_bit(input[7:0] data);  //data是data_mem[j]的值。
    integer i;
        for(i=0;i<10;i=i+1)
        begin
            case(i)
                0:  rx  <=  1'b0   ;    //起始位
                1:  rx  <=  data[0];
                2:  rx  <=  data[1];
                3:  rx  <=  data[2];
                4:  rx  <=  data[3];
                5:  rx  <=  data[4];
                6:  rx  <=  data[5];
                7:  rx  <=  data[6];
                8:  rx  <=  data[7];    //上面8个发送的是数据位
                9:  rx  <=  1'b1   ;    //停止位
            endcase
            #1040;                      //一个波特时间=sys_clk周期*波特计数器
        end
endtask

//重定义defparam,用于修改参数,缩短仿真时间
defparam    my_vga_inst.uart_rx_inst.CLK_FREQ      = 50_000_0;
//defparam    my_vga_inst.uart_rx_inst.BAUD_CNT_END_HALF = 26;


//------------- vga_uart_pic_jump -------------
my_vga  my_vga_inst
(
    .sys_clk      (sys_clk    ),  //输入工作时钟,频率50MHz,1bit
    .sys_rst_n    (sys_rst_n  ),  //输入复位信号,低电平有效,1bit
    .rx           (rx         ),  //输入串口的图片数据,1bit
    .key_in       (key_in     ),

    .hsync        (hsync      ),  //输出行同步信号,1bit
    .vsync        (vsync      ),  //输出场同步信号,1bit
    .rgb          (rgb        ),  //输出像素信息,16bit
  
    //SD卡
    .sd_miso      (sd_miso    ),
    .sd_clk       (sd_clk     ),
    .sd_cs        (sd_cs      ),
    .sd_mosi      (sd_mosi    ),
    
    //SDRAM
    .sdram_clk    (sdram_clk  ),    
    .sdram_cke    (sdram_cke  ),
    .sdram_cs_n   (sdram_cs_n ),
    .sdram_ras_n  (sdram_ras_n),
    .sdram_cas_n  (sdram_cas_n),
    .sdram_we_n   (sdram_we_n ),
    .sdram_ba     (sdram_ba   ),
    .sdram_dqm    (sdram_dqm  ),
    .sdram_addr   (sdram_addr ),
    .sdram_data   (sdram_data )


);

endmodule