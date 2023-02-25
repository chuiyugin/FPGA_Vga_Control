`timescale  1ns/1ns

module my_vga
(
    input wire            key_in      ,   //鎸夐敭杈撳叆淇″彿
	 input wire            sys_clk    ,
    input wire            sys_rst_n  ,
    input wire            rx         ,


    output wire  [15:0]   rgb        ,
    output wire           hsync      ,
    output wire           vsync      ,

    //SD鍗℃帴鍙              
    input                 sd_miso     ,  //SD鍗PI涓茶杈撳叆鏁版嵁淇″彿
    output                sd_clk      ,  //SD鍗PI鏃堕挓淇″彿
    output                sd_cs       ,  //SD鍗PI鐗囬€変俊鍙
    output                sd_mosi     ,  //SD鍗PI涓茶杈撳嚭鏁版嵁淇″彿
    //SDRAM鎺ュ彛
    output                sdram_clk   ,  //SDRAM 鏃堕挓
    output                sdram_cke   ,  //SDRAM 鏃堕挓鏈夋晥
    output                sdram_cs_n  ,  //SDRAM 鐗囬€
    output                sdram_ras_n ,  //SDRAM 琛屾湁鏁
    output                sdram_cas_n ,  //SDRAM 鍒楁湁鏁
    output                sdram_we_n  ,  //SDRAM 鍐欐湁鏁
    output       [1:0]    sdram_ba    ,  //SDRAM Bank鍦板潃
    output       [1:0]    sdram_dqm   ,  //SDRAM 鏁版嵁鎺╃爜
    output       [12:0]   sdram_addr  ,  //SDRAM 鍦板潃
    inout        [15:0]   sdram_data    //SDRAM 鏁版嵁    

);

//parameter define
parameter  PHOTO_H_PIXEL = 24'd640     ;  //璁剧疆SDRAM缂撳瓨澶у皬
parameter  PHOTO_V_PIXEL = 24'd480     ;  //璁剧疆SDRAM缂撳瓨澶у皬

wire            clk_100M        ;  //100mhz鏃堕挓,SDRAM鎿嶄綔鏃堕挓
wire            clk_100M_shift  ;  //100mhz鏃堕挓,SDRAM鐩镐綅鍋忕Щ鏃堕挓
wire            clk_50M_180deg  ;

wire            clk_50M;
wire            vga_clk;
wire            locked;
wire            rst_n;
wire            po_flag     ;   //涓插彛鎷兼帴濂界殑鍥剧墖鏁版嵁
wire    [7:0]   po_data     ;   //鏁版嵁鏍囧織淇″彿
wire    [9:0]   pix_x       ;   //VGA鏈夋晥鏄剧ず鍖哄煙X杞村潗鏍
wire    [9:0]   pix_y       ;   //VGA鏈夋晥鏄剧ず鍖哄煙Y杞村潗鏍
wire    [15:0]  pix_data    ;   //VGA鍍忕礌鐐硅壊褰╀俊鎭
wire            key_flag    ;
//wire            catch_valid ;
wire            data_req    ;
wire            catch_finish;
wire            wr_start_en ;
wire    [31:0]  wr_sec_addr ;
wire            sys_init_done   ;  //绯荤粺鍒濆鍖栧畬鎴
wire            sdram_init_done ;  //SDRAM鍒濆鍖栧畬鎴
wire            sd_wr_busy      ;  //璇诲繖淇″彿
wire            wr_req;
wire   [15:0]   rd_data         ;  //sdram_ctrl妯″潡璇绘暟鎹
wire   [15:0]   wr_data         ;  //sdram_ctrl妯″潡鍐欐暟鎹
wire            sd_init_done    ;

assign rst_n = (sys_rst_n & locked);
assign  wr_data = pix_data;
assign  sys_init_done = sd_init_done & sdram_init_done;  //SD鍗″拰SDRAM閮藉垵濮嬪寲瀹屾垚
assign  wr_en = data_req;

//parameter define
parameter   UART_BPS    =   14'd9600        ,   //姣旂壒鐜
            CLK_FREQ    =   26'd50_000_000  ;   //鏃堕挓棰戠巼


//------------- clk_gen_inst -------------
clk_gen	clk_gen_inst (
	.areset ( ~sys_rst_n      ),
	.inclk0 ( sys_clk         ),
	.c0     ( vga_clk         ),
	.c1     ( clk_50M         ),
	.c2     ( clk_50M_180deg  ),
	.c3     ( clk_100M        ),
	.c4     ( clk_100M_shift  ),
	.locked ( locked          )
	);

//------------- key_filter_inst -------------
key_filter  key_filter_inst(
    .sys_clk     (clk_50M  ),   //杈撳叆宸ヤ綔鏃堕挓,棰戠巼50MHz,1bit
    .sys_rst_n   (rst_n    ),   //杈撳叆澶嶄綅淇″彿,浣庣數骞虫湁鏁1bit
    .key_in      (key_in   ),
	 
	 .key_flag    (key_flag )
);

	
//-------------uart_rx_inst-------------
uart_rx
#(
    .UART_BPS    (UART_BPS),         //涓插彛娉㈢壒鐜
    .CLK_FREQ    (CLK_FREQ)          //鏃堕挓棰戠巼
)
uart_rx_inst
(
    .sys_clk     (clk_50M  ),   //杈撳叆宸ヤ綔鏃堕挓,棰戠巼50MHz,1bit
    .sys_rst_n   (rst_n    ),   //杈撳叆澶嶄綅淇″彿,浣庣數骞虫湁鏁1bit
    .rx          (rx       ),   //杈撳叆涓插彛鐨勫浘鐗囨暟鎹1bit

    .po_data     (po_data  ),   //杈撳嚭鎷兼帴濂界殑鍥剧墖鏁版嵁
    .po_flag     (po_flag  )    //杈撳嚭鏁版嵁鏍囧織淇″彿
);

//------------- vga_ctrl_inst -------------
vga_ctrl    vga_ctrl_inst
(
    .sys_clk     (clk_50M    ),  //杈撳叆宸ヤ綔鏃堕挓,棰戠巼25MHz,1bit
	 .vga_clk     (vga_clk    ),  //杈撳叆宸ヤ綔鏃堕挓,棰戠巼25MHz,1bit
    .sys_rst_n   (rst_n      ),  //杈撳叆澶嶄綅淇″彿,浣庣數骞虫湁鏁1bit
    .pix_data    (pix_data   ),  //杈撳叆鍍忕礌鐐硅壊褰╀俊鎭15bit
    .click       (key_flag   ),
	  
	 .catch_finish(catch_finish),
	 //.catch_valid (catch_valid),
	 .data_req    (data_req   ),
    .pix_x       (pix_x      ),  //杈撳嚭VGA鏈夋晥鏄剧ず鍖哄煙鍍忕礌鐐筙杞村潗鏍10bit
    .pix_y       (pix_y      ),  //杈撳嚭VGA鏈夋晥鏄剧ず鍖哄煙鍍忕礌鐐筜杞村潗鏍10bit
    .hsync       (hsync      ),  //杈撳嚭琛屽悓姝ヤ俊鍙1bit
    .vsync       (vsync      ),  //杈撳嚭鍦哄悓姝ヤ俊鍙1bit
    .vga_rgb     (rgb        )   //杈撳嚭鍍忕礌鐐硅壊褰╀俊鎭16bit
);

//------------- vga_pic_inst -------------
vga_pic     vga_pic_inst
(
    .vga_clk        (vga_clk    ),  //杈撳叆宸ヤ綔鏃堕挓,棰戠巼25MHz,1bit
    .sys_clk        (clk_50M    ),  //杈撳叆RAM鍐欐椂閽1bit
    .sys_rst_n      (rst_n      ),  //杈撳叆澶嶄綅淇″彿,浣庣數骞虫湁鏁1bit
    .pi_flag        (po_flag    ),  //杈撳叆RAM鍐欎娇鑳1bit
    .pi_data        (po_data    ),  //杈撳叆RAM鍐欐暟鎹8bit
    .pix_x          (pix_x      ),  //杈撳叆VGA鏈夋晥鏄剧ず鍖哄煙鍍忕礌鐐筙杞村潗鏍10bit
    .pix_y          (pix_y      ),  //杈撳叆VGA鏈夋晥鏄剧ず鍖哄煙鍍忕礌鐐筜杞村潗鏍10bit

    .pix_data_out   (pix_data   )   //杈撳嚭鍍忕礌鐐硅壊褰╀俊鎭8bit

);

//------------- data_ctrl_inst -------------
data_ctrl data_ctrl_inst(
	 .clk              (clk_50M),    
	 .rst_n            (rst_n & sys_init_done),
	 .sd_init_done     (sd_init_done),
	 //sd鍗
	 .wr_busy          (sd_wr_busy),
	 .catch_finish     (catch_finish),
	 
	 
	 
	 .wr_start_en      (wr_start_en),
	 .wr_sec_addr      (wr_sec_addr)
);


//SD鍗￠《灞傛帶鍒舵ā鍧
sd_ctrl_top u_sd_ctrl_top(
    .clk_ref           (clk_50M),
    .clk_ref_180deg    (clk_50M_180deg),
    .rst_n             (rst_n),
    //SD鍗℃帴鍙
    .sd_miso           (sd_miso),
    .sd_clk            (sd_clk),
    .sd_cs             (sd_cs),
    .sd_mosi           (sd_mosi),
    //鐢ㄦ埛鍐橲D鍗℃帴鍙
    .wr_start_en       (wr_start_en),               //涓嶉渶瑕佸啓鍏ユ暟鎹鍐欏叆鎺ュ彛璧嬪€间负0
    .wr_sec_addr       (wr_sec_addr),
    .wr_data           (rd_data),
    .wr_busy           (sd_wr_busy),
    .wr_req            (wr_req),
    //鐢ㄦ埛璇籗D鍗℃帴鍙
    .rd_start_en       (1'b0),
    .rd_sec_addr       (32'b0),
    .rd_busy           (),
    .rd_val_en         (),
    .rd_val_data       (),    
    
    .sd_init_done      (sd_init_done)
    );  

	 
//SDRAM 鎺у埗鍣ㄩ《灞傛ā鍧灏佽鎴怓IFO鎺ュ彛
//SDRAM 鎺у埗鍣ㄥ湴鍧€缁勬垚: {bank_addr[1:0],row_addr[12:0],col_addr[8:0]}
sdram_top u_sdram_top(
 .ref_clk      (clk_100M),                   //sdram 鎺у埗鍣ㄥ弬鑰冩椂閽
 .out_clk      (clk_100M_shift),             //鐢ㄤ簬杈撳嚭鐨勭浉浣嶅亸绉绘椂閽
 .rst_n        (rst_n),                      //绯荤粺澶嶄綅
                                             
  //鐢ㄦ埛鍐欑鍙                                  
 .wr_clk       (vga_clk),                    //鍐欑鍙IFO: 鍐欐椂閽
 .wr_en        (wr_en),                      //鍐欑鍙IFO: 鍐欎娇鑳
 .wr_data      (wr_data),                    //鍐欑鍙IFO: 鍐欐暟鎹
 .wr_min_addr  (24'd0),                      //鍐橲DRAM鐨勮捣濮嬪湴鍧€
 .wr_max_addr  (PHOTO_H_PIXEL*PHOTO_V_PIXEL),//鍐橲DRAM鐨勭粨鏉熷湴鍧€
 .wr_len       (10'd512),                    //鍐橲DRAM鏃剁殑鏁版嵁绐佸彂闀垮害
 .wr_load      (~rst_n),                     //鍐欑鍙ｅ浣 澶嶄綅鍐欏湴鍧€,娓呯┖鍐橣IFO
                                             
  //鐢ㄦ埛璇荤鍙                                 
 .rd_clk       (clk_50M),                    //璇荤鍙IFO: 璇绘椂閽
 .rd_en        (wr_req),                      //璇荤鍙IFO: 璇讳娇鑳
 .rd_data      (rd_data),                    //璇荤鍙IFO: 璇绘暟鎹
 .rd_min_addr  (24'd0),                      //璇籗DRAM鐨勮捣濮嬪湴鍧€
 .rd_max_addr  (PHOTO_H_PIXEL*PHOTO_V_PIXEL),//璇籗DRAM鐨勭粨鏉熷湴鍧€
 .rd_len       (10'd512),                    //浠嶴DRAM涓鏁版嵁鏃剁殑绐佸彂闀垮害
 .rd_load      (~rst_n),                     //璇荤鍙ｅ浣 澶嶄綅璇诲湴鍧€,娓呯┖璇籉IFO
                                             
 //鐢ㄦ埛鎺у埗绔彛                                
 .sdram_read_valid  (1'b1),                  //SDRAM 璇讳娇鑳
 .sdram_pingpang_en (1'b0),                  //SDRAM 涔掍箵鎿嶄綔浣胯兘
 .sdram_init_done (sdram_init_done),         //SDRAM 鍒濆鍖栧畬鎴愭爣蹇
                                             
 //SDRAM 鑺墖鎺ュ彛                                
 .sdram_clk    (sdram_clk),                  //SDRAM 鑺墖鏃堕挓
 .sdram_cke    (sdram_cke),                  //SDRAM 鏃堕挓鏈夋晥
 .sdram_cs_n   (sdram_cs_n),                 //SDRAM 鐗囬€
 .sdram_ras_n  (sdram_ras_n),                //SDRAM 琛屾湁鏁
 .sdram_cas_n  (sdram_cas_n),                //SDRAM 鍒楁湁鏁
 .sdram_we_n   (sdram_we_n),                 //SDRAM 鍐欐湁鏁
 .sdram_ba     (sdram_ba),                   //SDRAM Bank鍦板潃
 .sdram_addr   (sdram_addr),                 //SDRAM 琛鍒楀湴鍧€
 .sdram_data   (sdram_data),                 //SDRAM 鏁版嵁
 .sdram_dqm    (sdram_dqm)                   //SDRAM 鏁版嵁鎺╃爜
    
);
	 
	 
	 
endmodule