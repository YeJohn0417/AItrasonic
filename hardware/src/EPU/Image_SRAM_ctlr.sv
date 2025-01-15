module Image_SRAM_ctlr (
input                 clk,
input                 rst,
// from CONTROL
input                 i_read_25,        // for convolution
input                 i_read_5,         // for convolution
input                 i_read_16,        // for gap & dense2
input                 i_read_8,         // for dense1
input                 i_image_new,
input         [2:0]   i_layer,          // layer0 == convoluation layer 1
input         [4:0]   i_if_channel,     // channel=0 means 1st channel
input                 i_layer1_done,
input                 i_layer2_done,
input                 i_layer3_done,
input                 i_layer4_done,
input                 i_layer5_done,
input                 i_layer6_done,
input                 i_system_load,
input                 i_system_CEB0,
input                 i_system_CEB1,
input                 i_system_WEB,
input         [31:0]  i_system_DI,
input         [13:0]  i_system_A,
// from psum buffer
input                 i_psum_new,
input         [7:0]   i_psum,
// from gap_unit
input                 i_gap_new,
input         [7:0]   i_gap,
// to CONTROL
output  logic         o_read_25_done,
output  logic         o_read_5_done,
output  logic         o_read_16_done,
output  logic         o_read_8_done,
output  logic         o_conv_2row_done,    // 2 rows of convolution are finished, data after max-pool and quantized are saved
output  logic         o_gap_saved,
output  logic         o_fc_saved,
output  logic [31:0]  o_SRAM_DO,
// to image_buf
output  logic         o_image_new_25,
output  logic         o_image_new_5,
output  logic         o_image_new_16,
output  logic         o_image_new_8,
output  logic [7:0]   o_image
);

////////////////////////////////////////latch data
logic [2:0]   layer_d;
logic [4:0]   if_channel_d;
logic         read_25_d;
logic         image_new_d;
logic         read_5_d;
logic [7:0]   psum_d;
logic         psum_new_d;
logic [7:0]   gap_d;
logic         gap_new_d;
logic         layer_done;
////////////////////////////////////////latch data

////////////////////////////////////////state
logic [4:0]   rd_state;
logic [4:0]   rd_next_state;
logic [3:0]   wr_state;
logic [3:0]   wr_next_state;
////////////////////////////////////////state

////////////////////////////////////////counter
logic [6:0]   col_cnt;
logic         conv1_row_empty;
logic         conv2_row_empty;
logic         conv3_row_empty;
logic         conv4_row_empty;
logic [13:0]  C0_TLA, C1_TLA, C2_TLA, C3_TLA, C4_TLA, C5_TLA, C6_TLA, C7_TLA;
logic [13:0]  PSUM_A;
logic [6:0]   conv_PSUM_saved;
logic [4:0]   cnt_16;
logic [13:0]  rd16_addr;
logic [13:0]  GAP_A;
logic [3:0]   GAP_saved;
logic [4:0]   cnt_8;
logic [13:0]  rd8_addr;
////////////////////////////////////////counter

////////////////////////////////////////output & control
logic         tobuf_state_25;
logic         tobuf_state_5;
logic [13:0]  image_SRAM_A_conv;
logic         addr_state_25;
logic         addr_state_5;
////////////////////////////////////////output & control

///////////////////////////////////////SRAM signals
logic         image_SRAM0_CEB;
logic         image_SRAM0_WEB;
logic [13:0]  image_SRAM0_A;
logic [31:0]  image_SRAM0_DI;
logic [31:0]  image_SRAM0_DO;
logic         image_SRAM1_CEB;
logic         image_SRAM1_WEB;
logic [13:0]  image_SRAM1_A;
logic [31:0]  image_SRAM1_DI;
logic [31:0]  image_SRAM1_DO;
///////////////////////////////////////SRAM signals

localparam  rdst_IDLE             = 5'd0;

localparam  rdst_RD25             = 5'd1;
localparam  rdst_RD25_RC00        = 5'd2;
localparam  rdst_RD25_RC10        = 5'd3;
localparam  rdst_RD25_RC20        = 5'd4;
localparam  rdst_RD25_RC30        = 5'd5;
localparam  rdst_RD25_RC40        = 5'd6;
localparam  rdst_RD25_TOBUF       = 5'd7;

localparam  rdst_RD5              = 5'd8;
localparam  rdst_RD5_RC00         = 5'd9;
localparam  rdst_RD5_RC10         = 5'd10;
localparam  rdst_RD5_RC20         = 5'd11;
localparam  rdst_RD5_RC30         = 5'd12;
localparam  rdst_RD5_RC40         = 5'd13;
localparam  rdst_RD5_TOBUF        = 5'd14;

localparam  rdst_RD16             = 5'd15;
localparam  rdst_RD16_ADDR        = 5'd16;
localparam  rdst_RD16_ADDR_TOBUF  = 5'd17;
localparam  rdst_RD16_TOBUF       = 5'd18;

localparam  rdst_RD8              = 5'd19;
localparam  rdst_RD8_ADDR         = 5'd20;
localparam  rdst_RD8_ADDR_TOBUF   = 5'd21;
localparam  rdst_RD8_TOBUF        = 5'd22;

localparam  wrst_IDLE       = 4'd0;
localparam  wrst_L1_WRPSUM  = 4'd1;
localparam  wrst_L2_WRPSUM  = 4'd2;
localparam  wrst_L3_WRPSUM  = 4'd3;
localparam  wrst_L4_WRPSUM  = 4'd4;
localparam  wrst_WRGAP      = 4'd5;
localparam  wrst_WRFC1      = 4'd6;
localparam  wrst_WRFC2      = 4'd7;
////////////////////////////////////////latch data
always_ff @(posedge clk or posedge rst) begin
  if (rst) begin
    layer_d       <= 3'd0;
    if_channel_d  <= 5'd0;
//    read_25_d     <= 1'b0;
    image_new_d   <= 1'b0;
  end
  else if (i_read_25 || i_read_16 || i_read_8) begin
    layer_d       <= i_layer;
    if_channel_d  <= i_if_channel;
//    read_25_d     <= i_read_25;
    image_new_d   <= i_image_new;
  end
end

always_ff @(posedge clk or posedge rst) begin
  if (rst)  read_25_d <= 1'b0;
  else      read_25_d <= i_read_25;
end

always_ff @(posedge clk or posedge rst) begin
  if (rst)  read_5_d  <= 1'b0;
  else      read_5_d  <= i_read_5;
end

always_ff @(posedge clk or posedge rst) begin
  if (rst) begin
    psum_d      <= 8'd0;
//    psum_new_d  <= 1'b0;
  end
  else if (i_psum_new) begin
    psum_d      <= i_psum;
//    psum_new_d  <= i_psum_new;
  end
end

always_ff @(posedge clk or posedge rst) begin
  if (rst)  psum_new_d  <= 1'b0;
  else      psum_new_d  <= i_psum_new;
end

always_ff @(posedge clk or posedge rst) begin
  if (rst)  gap_d       <= 8'd0;
  else      gap_d       <= i_gap;
end

always_ff @(posedge clk or posedge rst) begin
  if (rst)  gap_new_d   <= 1'b0;
  else      gap_new_d   <= i_gap_new;
end

assign  layer_done  = i_layer1_done || i_layer2_done || i_layer3_done || i_layer4_done || i_layer5_done || i_layer6_done;
////////////////////////////////////////latch data

////////////////////////////////////////state
always_ff @(posedge clk or posedge rst) begin
  if (rst)  rd_state <= rdst_IDLE;
  else      rd_state <= rd_next_state;
end

always_comb begin
  case (rd_state)
//    rdst_IDLE:        rd_next_state = (i_read_25 && (layer_d == 3'd0)) ? rdst_RD25 :
//                                      (i_read_5 && (layer_d == 3'd0))  ? rdst_RD5  : rdst_IDLE;
    rdst_IDLE:            rd_next_state = i_read_25 ? rdst_RD25 :
                                          i_read_5  ? rdst_RD5  :
                                          i_read_16 ? rdst_RD16 :
                                          i_read_8  ? rdst_RD8  : rdst_IDLE;
    rdst_RD25:            rd_next_state = rdst_RD25_RC00;
    rdst_RD25_RC00:       rd_next_state = rdst_RD25_RC10;
    rdst_RD25_RC10:       rd_next_state = rdst_RD25_RC20;
    rdst_RD25_RC20:       rd_next_state = rdst_RD25_RC30;
    rdst_RD25_RC30:       rd_next_state = rdst_RD25_RC40;
    rdst_RD25_RC40:       rd_next_state = rdst_RD25_TOBUF;
    rdst_RD25_TOBUF:      rd_next_state = (col_cnt < 3'd5)  ? rdst_RD25_RC00 : rdst_IDLE;

    rdst_RD5:             rd_next_state = rdst_RD5_RC00;
    rdst_RD5_RC00:        rd_next_state = rdst_RD5_RC10;
    rdst_RD5_RC10:        rd_next_state = rdst_RD5_RC20;
    rdst_RD5_RC20:        rd_next_state = rdst_RD5_RC30;
    rdst_RD5_RC30:        rd_next_state = rdst_RD5_RC40;
    rdst_RD5_RC40:        rd_next_state = rdst_RD5_TOBUF;
    rdst_RD5_TOBUF:       rd_next_state = rdst_IDLE;

    rdst_RD16:            rd_next_state = rdst_RD16_ADDR;
    rdst_RD16_ADDR:       rd_next_state = rdst_RD16_ADDR_TOBUF;
    rdst_RD16_ADDR_TOBUF: rd_next_state = (cnt_16 == 5'd16) ? rdst_RD16_TOBUF : rdst_RD16_ADDR_TOBUF;
    rdst_RD16_TOBUF:      rd_next_state = rdst_IDLE;

    rdst_RD8:             rd_next_state = rdst_RD8_ADDR;
    rdst_RD8_ADDR:        rd_next_state = rdst_RD8_ADDR_TOBUF;
    rdst_RD8_ADDR_TOBUF:  rd_next_state = (cnt_8 == 5'd8)   ? rdst_RD8_TOBUF  : rdst_RD8_ADDR_TOBUF;
    rdst_RD8_TOBUF:       rd_next_state = rdst_IDLE;
    default:              rd_next_state = rdst_IDLE;
  endcase
end

always_ff @(posedge clk or posedge rst) begin
  if (rst)  wr_state  <= wrst_IDLE;
  else      wr_state  <= wr_next_state;
end

always_comb begin
  case (wr_state)
    wrst_IDLE:        wr_next_state = (i_psum_new && (layer_d == 3'd0)) ? wrst_L1_WRPSUM  :
                                      (i_psum_new && (layer_d == 3'd1)) ? wrst_L2_WRPSUM  :
                                      (i_psum_new && (layer_d == 3'd2)) ? wrst_L3_WRPSUM  :
                                      (i_psum_new && (layer_d == 3'd3)) ? wrst_L4_WRPSUM  :
                                      i_gap_new                         ? wrst_WRGAP      : 
                                      (i_psum_new && (layer_d == 3'd5)) ? wrst_WRFC1      :
                                      (i_psum_new && (layer_d == 3'd6)) ? wrst_WRFC2      : rdst_IDLE;
    wrst_L1_WRPSUM:   wr_next_state = wrst_IDLE;
    wrst_L2_WRPSUM:   wr_next_state = wrst_IDLE;
    wrst_L3_WRPSUM:   wr_next_state = wrst_IDLE;
    wrst_L4_WRPSUM:   wr_next_state = wrst_IDLE;
    wrst_WRGAP:       wr_next_state = (GAP_saved == 4'd4) ? wrst_IDLE : wrst_WRGAP;
    wrst_WRFC1:       wr_next_state = wrst_IDLE;
    wrst_WRFC2:       wr_next_state = wrst_IDLE;
    default:          wr_next_state = wrst_IDLE;
  endcase
end
////////////////////////////////////////state

////////////////////////////////////////counter
// for read_25 and row_empty
always_ff @(posedge clk or posedge rst) begin
  if      (rst) col_cnt <= 7'd0;
  else if ((layer_d == 3'd0) && (col_cnt == 7'd99) && (rd_state == rdst_RD5_RC40))  col_cnt <= 7'd0;
  else if ((layer_d == 3'd1) && (col_cnt == 7'd43)) col_cnt <= 7'd0;
  else if ((rd_state == rdst_RD25_RC40) || (rd_state == rdst_RD5_RC40)) col_cnt <= col_cnt + 7'd1;
end
// con1_row_empty
always_ff @(posedge clk or posedge rst) begin
  if      (rst) conv1_row_empty <= 1'b0;
  else if ((layer_d == 3'd0) && (col_cnt == 7'd96)) conv1_row_empty <= 1'b1;
  else if (read_25_d) conv1_row_empty <= 1'b0;
end
// conv2_row_empty
always_ff @(posedge clk or posedge rst) begin
  if      (rst) conv2_row_empty <= 1'b0;
  else if ((layer_d == 3'd1) && (col_cnt == 7'd44)) conv2_row_empty <= 1'b1;
  else if (read_25_d) conv2_row_empty <= 1'b0;
end
// conv3_row_empty
always_ff @(posedge clk or posedge rst) begin
  if      (rst) conv3_row_empty <= 1'b0;
  else if ((layer_d == 3'd2) && (col_cnt == 7'd18)) conv3_row_empty <= 1'b1;
  else if (read_25_d) conv3_row_empty <= 1'b0;
end
// conv4_row_empty
always_ff @(posedge clk or posedge rst) begin
  if      (rst) conv4_row_empty <= 1'b0;
  else if ((layer_d == 3'd3) && (col_cnt == 7'd5)) conv4_row_empty <= 1'b1;
  else if (read_25_d) conv4_row_empty <= 1'b0;
end

// channel 0 image address
always_ff @(posedge clk or posedge rst) begin
  if      (rst)                                                                                     C0_TLA  <= 14'd0;
  else if ((read_25_d && image_new_d && (layer_d == 3'd0) && (if_channel_d == 5'd0)) || layer_done) C0_TLA  <= 14'd0;     // layer1
  else if ((read_25_d && image_new_d && (layer_d == 3'd1) && (if_channel_d == 5'd0)) || layer_done) C0_TLA  <= 14'd0;     // layer2
  else if ((read_25_d && image_new_d && (layer_d == 3'd2) && (if_channel_d == 5'd0)) || layer_done) C0_TLA  <= 14'd0;     // layer3
  else if ((read_25_d && image_new_d && (layer_d == 3'd3) && (if_channel_d == 5'd0)) || layer_done) C0_TLA  <= 14'd0;     // layer4
  else if ((if_channel_d == 5'd0) && ((rd_state == rdst_RD25_RC40) || (rd_state == rdst_RD5_RC40))) C0_TLA  <= C0_TLA + 14'd1;
end

// channel 1 image address
always_ff @(posedge clk or posedge rst) begin
  if      (rst)                                                                                     C1_TLA  <= 14'd0;
  else if (read_25_d && image_new_d && (layer_d == 3'd1) && (if_channel_d == 5'd1))                 C1_TLA  <= 14'd2304;  // layer2
  else if (read_25_d && image_new_d && (layer_d == 3'd2) && (if_channel_d == 5'd1))                 C1_TLA  <= 14'd484;   // layer3
  else if (read_25_d && image_new_d && (layer_d == 3'd3) && (if_channel_d == 5'd1))                 C1_TLA  <= 14'd81;    // layer4
  else if ((if_channel_d == 5'd1) && ((rd_state == rdst_RD25_RC40) || (rd_state == rdst_RD5_RC40))) C1_TLA  <= C1_TLA + 14'd1;
end

// channel 2 image address
always_ff @(posedge clk or posedge rst) begin
  if      (rst)                                                                                     C2_TLA  <= 14'd0;
  else if (read_25_d && image_new_d && (layer_d == 3'd1) && (if_channel_d == 5'd2))                 C2_TLA  <= 14'd4608;  // layer2
  else if (read_25_d && image_new_d && (layer_d == 3'd2) && (if_channel_d == 5'd2))                 C2_TLA  <= 14'd968;   // layer3
  else if (read_25_d && image_new_d && (layer_d == 3'd3) && (if_channel_d == 5'd2))                 C2_TLA  <= 14'd162;   // layer4
  else if ((if_channel_d == 5'd2) && ((rd_state == rdst_RD25_RC40) || (rd_state == rdst_RD5_RC40))) C2_TLA  <= C2_TLA + 14'd1;
end

// channel 3 image address
always_ff @(posedge clk or posedge rst) begin
  if      (rst)                                                                                     C3_TLA  <= 14'd0;
  else if (read_25_d && image_new_d && (layer_d == 3'd1) && (if_channel_d == 5'd3))                 C3_TLA  <= 14'd6912;  // layer2
  else if (read_25_d && image_new_d && (layer_d == 3'd2) && (if_channel_d == 5'd3))                 C3_TLA  <= 14'd1452;  // layer3
  else if (read_25_d && image_new_d && (layer_d == 3'd3) && (if_channel_d == 5'd3))                 C3_TLA  <= 14'd243;   // layer4
  else if ((if_channel_d == 5'd3) && ((rd_state == rdst_RD25_RC40) || (rd_state == rdst_RD5_RC40))) C3_TLA  <= C3_TLA + 14'd1;
end

// channel 4 image address
always_ff @(posedge clk or posedge rst) begin
  if      (rst)                                                                                     C4_TLA  <= 14'd0;
  else if (read_25_d && image_new_d && (layer_d == 3'd2) && (if_channel_d == 5'd4))                 C4_TLA  <= 14'd1936;  // layer3
  else if (read_25_d && image_new_d && (layer_d == 3'd3) && (if_channel_d == 5'd4))                 C4_TLA  <= 14'd324;   // layer4
  else if ((if_channel_d == 5'd4) && ((rd_state == rdst_RD25_RC40) || (rd_state == rdst_RD5_RC40))) C4_TLA  <= C4_TLA + 14'd1;
end

// channel 5 image address
always_ff @(posedge clk or posedge rst) begin
  if      (rst)                                                                                     C5_TLA  <= 14'd0;
  else if (read_25_d && image_new_d && (layer_d == 3'd2) && (if_channel_d == 5'd5))                 C5_TLA  <= 14'd2420;  // layer3
  else if (read_25_d && image_new_d && (layer_d == 3'd3) && (if_channel_d == 5'd5))                 C5_TLA  <= 14'd405;   // layer4
  else if ((if_channel_d == 5'd5) && ((rd_state == rdst_RD25_RC40) || (rd_state == rdst_RD5_RC40))) C5_TLA  <= C5_TLA + 14'd1;
end

// channel 6 image address
always_ff @(posedge clk or posedge rst) begin
  if      (rst)                                                                                     C6_TLA  <= 14'd0;
  else if (read_25_d && image_new_d && (layer_d == 3'd2) && (if_channel_d == 5'd5))                 C6_TLA  <= 14'd2904;  // layer3
  else if (read_25_d && image_new_d && (layer_d == 3'd3) && (if_channel_d == 5'd5))                 C6_TLA  <= 14'd486;   // layer4
  else if ((if_channel_d == 5'd5) && ((rd_state == rdst_RD25_RC40) || (rd_state == rdst_RD5_RC40))) C6_TLA  <= C6_TLA + 14'd1;
end

// channel 7 image address
always_ff @(posedge clk or posedge rst) begin
  if      (rst)                                                                                     C7_TLA  <= 14'd0;
  else if (read_25_d && image_new_d && (layer_d == 3'd2) && (if_channel_d == 5'd5))                 C7_TLA  <= 14'd3388;  // layer3
  else if (read_25_d && image_new_d && (layer_d == 3'd3) && (if_channel_d == 5'd5))                 C7_TLA  <= 14'd567;   // layer4
  else if ((if_channel_d == 5'd5) && ((rd_state == rdst_RD25_RC40) || (rd_state == rdst_RD5_RC40))) C7_TLA  <= C7_TLA + 14'd1;
end

// for psum storing address of convolution layers
always_ff @(posedge clk or posedge rst) begin
  if      (rst)           PSUM_A <= 14'd0;
  else if (layer_d != i_layer)   PSUM_A <= 14'd0;
  else if (psum_new_d)    PSUM_A <= PSUM_A + 14'd1;
end

assign  wrpsum_state  = (wr_state == wrst_L1_WRPSUM) || (wr_state == wrst_L2_WRPSUM) || (wr_state == wrst_L3_WRPSUM) || (wr_state == wrst_L4_WRPSUM);
// for calculating o_conv_2row_done 
always_ff @(posedge clk or posedge rst) begin
  if      (rst)                                               conv_PSUM_saved <= 7'd0;
  else if ((conv_PSUM_saved == 7'd48)  && (layer_d == 3'd0))  conv_PSUM_saved <= 7'd0;
  else if ((conv_PSUM_saved == 7'd22)  && (layer_d == 3'd1))  conv_PSUM_saved <= 7'd0;
  else if ((conv_PSUM_saved == 7'd9)   && (layer_d == 3'd2))  conv_PSUM_saved <= 7'd0;
  else if ((conv_PSUM_saved == 7'd2)   && (layer_d == 3'd3))  conv_PSUM_saved <= 7'd0;
  else if (wrpsum_state)                                      conv_PSUM_saved <= conv_PSUM_saved + 7'd1;
end

always_ff @(posedge clk or posedge rst) begin
  if      (rst)                               cnt_16  <= 5'd0;
  else if (rd_state == rdst_RD16_TOBUF)       cnt_16  <= 5'd0;
  else if (rd_state == rdst_RD16_ADDR_TOBUF)  cnt_16  <= cnt_16 + 5'd1;
end

// RD16 address
always_ff @(posedge clk or posedge rst) begin
  if      (rst)                                                                 rd16_addr <= 14'd0;
  else if ((rd_state == rdst_RD16_ADDR) || (rd_state == rdst_RD16_ADDR_TOBUF))  rd16_addr <= rd16_addr + 14'd1;
end

// gap_address
always_ff @(posedge clk or posedge rst) begin
  if      (rst)       GAP_A <= 14'd0;
  else if (gap_new_d) GAP_A <= GAP_A + 14'd1;
end

// count for o_gap_saved
always_ff @(posedge clk or posedge rst) begin
  if      (rst)                     GAP_saved <= 4'd0;
  else if (GAP_saved == 4'd4)       GAP_saved <= 4'd0;
  else if (wr_state == wrst_WRGAP)  GAP_saved <= GAP_saved + 4'd1;
end

always_ff @(posedge clk or posedge rst) begin
  if      (rst)                             cnt_8 <= 5'd0;
  else if (rd_state == rdst_RD8_TOBUF)      cnt_8 <= 5'd0;
  else if (rd_state == rdst_RD8_ADDR_TOBUF) cnt_8 <= cnt_8 + 5'd1;
end

// RD8 address
always_ff @(posedge clk or posedge rst) begin
  if      (rst)                                                               rd8_addr  <= 14'd0;
  else if ((rd_state == rdst_RD8_ADDR) || (rd_state == rdst_RD8_ADDR_TOBUF))  rd8_addr  <= rd8_addr + 14'd1;
end

////////////////////////////////////////counter

////////////////////////////////////////output & control
// to image_buf
assign  tobuf_state_25    = (rd_state == rdst_RD25_RC10) || (rd_state == rdst_RD25_RC20) || (rd_state == rdst_RD25_RC30) || (rd_state == rdst_RD25_RC40) || (rd_state == rdst_RD25_TOBUF);
assign  tobuf_state_5     = (rd_state == rdst_RD5_RC10)  || (rd_state == rdst_RD5_RC20)  || (rd_state == rdst_RD5_RC30)  || (rd_state == rdst_RD5_RC40)  || (rd_state == rdst_RD5_TOBUF);
assign  tobuf_state_16    = (rd_state == rdst_RD16_ADDR_TOBUF)  || (rd_state == rdst_RD16_TOBUF);
assign  tobuf_state_8     = (rd_state == rdst_RD8_ADDR_TOBUF)   || (rd_state == rdst_RD8_TOBUF);
assign  o_image           = (tobuf_state_25 || tobuf_state_5 || tobuf_state_16 || tobuf_state_8) ? image_SRAM0_DO[7:0]  : 8'd0;
assign  o_image_new_25    = tobuf_state_25;
assign  o_image_new_5     = tobuf_state_5;
assign  o_image_new_16    = tobuf_state_16;
assign  o_image_new_8     = tobuf_state_8;
// to CONTROL
assign  o_read_25_done    = (rd_state == rdst_RD25_TOBUF) && (rd_next_state == rdst_IDLE);
assign  o_read_5_done     = (rd_state == rdst_RD5_TOBUF)  && (rd_next_state == rdst_IDLE);
assign  o_read_16_done    = (rd_state == rdst_RD16_TOBUF) && (rd_next_state == rdst_IDLE);
assign  o_read_8_done     = (rd_state == rdst_RD8_TOBUF)  && (rd_next_state == rdst_IDLE);
assign  o_conv_2row_done  = (layer_d == 3'd0) ? (conv_PSUM_saved == 7'd48)  :
                            (layer_d == 3'd1) ? (conv_PSUM_saved == 7'd22)  :
                            (layer_d == 3'd2) ? (conv_PSUM_saved == 7'd9)   :
                            (layer_d == 3'd3) ? (conv_PSUM_saved == 7'd2)   : 1'b0;
assign  o_gap_saved       = (GAP_saved == 4'd4);
assign  o_SRAM_DO         = image_SRAM1_DO;
//assign  o_fc_saved        = 
// generate signals for SRAM
assign  RC00  = (rd_state == rdst_RD25_RC00) || (rd_state == rdst_RD5_RC00);
assign  RC10  = (rd_state == rdst_RD25_RC10) || (rd_state == rdst_RD5_RC10);
assign  RC20  = (rd_state == rdst_RD25_RC20) || (rd_state == rdst_RD5_RC20);
assign  RC30  = (rd_state == rdst_RD25_RC30) || (rd_state == rdst_RD5_RC30);
assign  RC40  = (rd_state == rdst_RD25_RC40) || (rd_state == rdst_RD5_RC40);
always_comb begin
  case ({RC40, RC30, RC20, RC10, RC00, layer_d, if_channel_d})
    {5'b00001, 3'd0, 5'd0}: image_SRAM_A_conv = C0_TLA;
    {5'b00010, 3'd0, 5'd0}: image_SRAM_A_conv = C0_TLA + 14'd100;
    {5'b00100, 3'd0, 5'd0}: image_SRAM_A_conv = C0_TLA + 14'd200;
    {5'b01000, 3'd0, 5'd0}: image_SRAM_A_conv = C0_TLA + 14'd300;
    {5'b10000, 3'd0, 5'd0}: image_SRAM_A_conv = C0_TLA + 14'd400;
    {5'b00001, 3'd1, 5'd0}: image_SRAM_A_conv = C0_TLA;
    {5'b00010, 3'd1, 5'd0}: image_SRAM_A_conv = C0_TLA + 14'd48;
    {5'b00100, 3'd1, 5'd0}: image_SRAM_A_conv = C0_TLA + 14'd96;
    {5'b01000, 3'd1, 5'd0}: image_SRAM_A_conv = C0_TLA + 14'd144;
    {5'b10000, 3'd1, 5'd0}: image_SRAM_A_conv = C0_TLA + 14'd192;
    {5'b00001, 3'd1, 5'd1}: image_SRAM_A_conv = C1_TLA;
    {5'b00010, 3'd1, 5'd1}: image_SRAM_A_conv = C1_TLA + 14'd48;
    {5'b00100, 3'd1, 5'd1}: image_SRAM_A_conv = C1_TLA + 14'd96;
    {5'b01000, 3'd1, 5'd1}: image_SRAM_A_conv = C1_TLA + 14'd144;
    {5'b10000, 3'd1, 5'd1}: image_SRAM_A_conv = C1_TLA + 14'd192;
    {5'b00001, 3'd1, 5'd2}: image_SRAM_A_conv = C2_TLA;
    {5'b00010, 3'd1, 5'd2}: image_SRAM_A_conv = C2_TLA + 14'd48;
    {5'b00100, 3'd1, 5'd2}: image_SRAM_A_conv = C2_TLA + 14'd96;
    {5'b01000, 3'd1, 5'd2}: image_SRAM_A_conv = C2_TLA + 14'd144;
    {5'b10000, 3'd1, 5'd2}: image_SRAM_A_conv = C2_TLA + 14'd192;
    {5'b00001, 3'd1, 5'd3}: image_SRAM_A_conv = C3_TLA;
    {5'b00010, 3'd1, 5'd3}: image_SRAM_A_conv = C3_TLA + 14'd48;
    {5'b00100, 3'd1, 5'd3}: image_SRAM_A_conv = C3_TLA + 14'd96;
    {5'b01000, 3'd1, 5'd3}: image_SRAM_A_conv = C3_TLA + 14'd144;
    {5'b10000, 3'd1, 5'd3}: image_SRAM_A_conv = C3_TLA + 14'd192;
    {5'b00001, 3'd2, 5'd0}: image_SRAM_A_conv = C0_TLA;
    {5'b00010, 3'd2, 5'd0}: image_SRAM_A_conv = C0_TLA + 14'd22;
    {5'b00100, 3'd2, 5'd0}: image_SRAM_A_conv = C0_TLA + 14'd44;
    {5'b01000, 3'd2, 5'd0}: image_SRAM_A_conv = C0_TLA + 14'd66;
    {5'b10000, 3'd2, 5'd0}: image_SRAM_A_conv = C0_TLA + 14'd88;
    {5'b00001, 3'd2, 5'd1}: image_SRAM_A_conv = C1_TLA;
    {5'b00010, 3'd2, 5'd1}: image_SRAM_A_conv = C1_TLA + 14'd22;
    {5'b00100, 3'd2, 5'd1}: image_SRAM_A_conv = C1_TLA + 14'd44;
    {5'b01000, 3'd2, 5'd1}: image_SRAM_A_conv = C1_TLA + 14'd66;
    {5'b10000, 3'd2, 5'd1}: image_SRAM_A_conv = C1_TLA + 14'd88;
    {5'b00001, 3'd2, 5'd2}: image_SRAM_A_conv = C2_TLA;
    {5'b00010, 3'd2, 5'd2}: image_SRAM_A_conv = C2_TLA + 14'd22;
    {5'b00100, 3'd2, 5'd2}: image_SRAM_A_conv = C2_TLA + 14'd44;
    {5'b01000, 3'd2, 5'd2}: image_SRAM_A_conv = C2_TLA + 14'd66;
    {5'b10000, 3'd2, 5'd2}: image_SRAM_A_conv = C2_TLA + 14'd88;
    {5'b00001, 3'd2, 5'd3}: image_SRAM_A_conv = C3_TLA;
    {5'b00010, 3'd2, 5'd3}: image_SRAM_A_conv = C3_TLA + 14'd22;
    {5'b00100, 3'd2, 5'd3}: image_SRAM_A_conv = C3_TLA + 14'd44;
    {5'b01000, 3'd2, 5'd3}: image_SRAM_A_conv = C3_TLA + 14'd66;
    {5'b10000, 3'd2, 5'd3}: image_SRAM_A_conv = C3_TLA + 14'd88;
    {5'b00001, 3'd2, 5'd4}: image_SRAM_A_conv = C4_TLA;
    {5'b00010, 3'd2, 5'd4}: image_SRAM_A_conv = C4_TLA + 14'd22;
    {5'b00100, 3'd2, 5'd4}: image_SRAM_A_conv = C4_TLA + 14'd44;
    {5'b01000, 3'd2, 5'd4}: image_SRAM_A_conv = C4_TLA + 14'd66;
    {5'b10000, 3'd2, 5'd4}: image_SRAM_A_conv = C4_TLA + 14'd88;
    {5'b00001, 3'd2, 5'd5}: image_SRAM_A_conv = C5_TLA;
    {5'b00010, 3'd2, 5'd5}: image_SRAM_A_conv = C5_TLA + 14'd22;
    {5'b00100, 3'd2, 5'd5}: image_SRAM_A_conv = C5_TLA + 14'd44;
    {5'b01000, 3'd2, 5'd5}: image_SRAM_A_conv = C5_TLA + 14'd66;
    {5'b10000, 3'd2, 5'd5}: image_SRAM_A_conv = C5_TLA + 14'd88;
    {5'b00001, 3'd2, 5'd6}: image_SRAM_A_conv = C6_TLA;
    {5'b00010, 3'd2, 5'd6}: image_SRAM_A_conv = C6_TLA + 14'd22;
    {5'b00100, 3'd2, 5'd6}: image_SRAM_A_conv = C6_TLA + 14'd44;
    {5'b01000, 3'd2, 5'd6}: image_SRAM_A_conv = C6_TLA + 14'd66;
    {5'b10000, 3'd2, 5'd6}: image_SRAM_A_conv = C6_TLA + 14'd88;
    {5'b00001, 3'd2, 5'd7}: image_SRAM_A_conv = C7_TLA;
    {5'b00010, 3'd2, 5'd7}: image_SRAM_A_conv = C7_TLA + 14'd22;
    {5'b00100, 3'd2, 5'd7}: image_SRAM_A_conv = C7_TLA + 14'd44;
    {5'b01000, 3'd2, 5'd7}: image_SRAM_A_conv = C7_TLA + 14'd66;
    {5'b10000, 3'd2, 5'd7}: image_SRAM_A_conv = C7_TLA + 14'd88;
    {5'b00001, 3'd3, 5'd0}: image_SRAM_A_conv = C0_TLA;
    {5'b00010, 3'd3, 5'd0}: image_SRAM_A_conv = C0_TLA + 14'd9;
    {5'b00100, 3'd3, 5'd0}: image_SRAM_A_conv = C0_TLA + 14'd18;
    {5'b01000, 3'd3, 5'd0}: image_SRAM_A_conv = C0_TLA + 14'd27;
    {5'b10000, 3'd3, 5'd0}: image_SRAM_A_conv = C0_TLA + 14'd36;
    {5'b00001, 3'd3, 5'd1}: image_SRAM_A_conv = C1_TLA;
    {5'b00010, 3'd3, 5'd1}: image_SRAM_A_conv = C1_TLA + 14'd9;
    {5'b00100, 3'd3, 5'd1}: image_SRAM_A_conv = C1_TLA + 14'd18;
    {5'b01000, 3'd3, 5'd1}: image_SRAM_A_conv = C1_TLA + 14'd27;
    {5'b10000, 3'd3, 5'd1}: image_SRAM_A_conv = C1_TLA + 14'd36;
    {5'b00001, 3'd3, 5'd2}: image_SRAM_A_conv = C2_TLA;
    {5'b00010, 3'd3, 5'd2}: image_SRAM_A_conv = C2_TLA + 14'd9;
    {5'b00100, 3'd3, 5'd2}: image_SRAM_A_conv = C2_TLA + 14'd18;
    {5'b01000, 3'd3, 5'd2}: image_SRAM_A_conv = C2_TLA + 14'd27;
    {5'b10000, 3'd3, 5'd2}: image_SRAM_A_conv = C2_TLA + 14'd36;
    {5'b00001, 3'd3, 5'd3}: image_SRAM_A_conv = C3_TLA;
    {5'b00010, 3'd3, 5'd3}: image_SRAM_A_conv = C3_TLA + 14'd9;
    {5'b00100, 3'd3, 5'd3}: image_SRAM_A_conv = C3_TLA + 14'd18;
    {5'b01000, 3'd3, 5'd3}: image_SRAM_A_conv = C3_TLA + 14'd27;
    {5'b10000, 3'd3, 5'd3}: image_SRAM_A_conv = C3_TLA + 14'd36;
    {5'b00001, 3'd3, 5'd4}: image_SRAM_A_conv = C4_TLA;
    {5'b00010, 3'd3, 5'd4}: image_SRAM_A_conv = C4_TLA + 14'd9;
    {5'b00100, 3'd3, 5'd4}: image_SRAM_A_conv = C4_TLA + 14'd18;
    {5'b01000, 3'd3, 5'd4}: image_SRAM_A_conv = C4_TLA + 14'd27;
    {5'b10000, 3'd3, 5'd4}: image_SRAM_A_conv = C4_TLA + 14'd36;
    {5'b00001, 3'd3, 5'd5}: image_SRAM_A_conv = C5_TLA;
    {5'b00010, 3'd3, 5'd5}: image_SRAM_A_conv = C5_TLA + 14'd9;
    {5'b00100, 3'd3, 5'd5}: image_SRAM_A_conv = C5_TLA + 14'd18;
    {5'b01000, 3'd3, 5'd5}: image_SRAM_A_conv = C5_TLA + 14'd27;
    {5'b10000, 3'd3, 5'd5}: image_SRAM_A_conv = C5_TLA + 14'd36;
    {5'b00001, 3'd3, 5'd6}: image_SRAM_A_conv = C6_TLA;
    {5'b00010, 3'd3, 5'd6}: image_SRAM_A_conv = C6_TLA + 14'd9;
    {5'b00100, 3'd3, 5'd6}: image_SRAM_A_conv = C6_TLA + 14'd18;
    {5'b01000, 3'd3, 5'd6}: image_SRAM_A_conv = C6_TLA + 14'd27;
    {5'b10000, 3'd3, 5'd6}: image_SRAM_A_conv = C6_TLA + 14'd36;
    {5'b00001, 3'd3, 5'd7}: image_SRAM_A_conv = C7_TLA;
    {5'b00010, 3'd3, 5'd7}: image_SRAM_A_conv = C7_TLA + 14'd9;
    {5'b00100, 3'd3, 5'd7}: image_SRAM_A_conv = C7_TLA + 14'd18;
    {5'b01000, 3'd3, 5'd7}: image_SRAM_A_conv = C7_TLA + 14'd27;
    {5'b10000, 3'd3, 5'd7}: image_SRAM_A_conv = C7_TLA + 14'd36;
    default:                image_SRAM_A_conv = 14'd0;
  endcase
end
assign  addr_state_25   = (rd_state == rdst_RD25_RC00) || (rd_state == rdst_RD25_RC10) || (rd_state == rdst_RD25_RC20) || (rd_state == rdst_RD25_RC30) || (rd_state == rdst_RD25_RC40);
assign  addr_state_5    = (rd_state == rdst_RD5_RC00)  || (rd_state == rdst_RD5_RC10)  || (rd_state == rdst_RD5_RC20)  || (rd_state == rdst_RD5_RC30)  || (rd_state == rdst_RD5_RC40);
assign  addr_state_16   = (rd_state == rdst_RD16_ADDR) || (rd_state == rdst_RD16_ADDR_TOBUF);
assign  addr_state_8    = (rd_state == rdst_RD8_ADDR)  || (rd_state == rdst_RD8_ADDR_TOBUF);
// to SRAM0
assign  image_SRAM0_CEB = i_system_load                                           ? i_system_CEB0     :
                          ((addr_state_25 || addr_state_5) && (layer_d == 3'd0))  ? 1'b0              :
                          (wr_state == wrst_L2_WRPSUM)                            ? 1'b0              :
                          ((addr_state_25 || addr_state_5) && (layer_d == 3'd2))  ? 1'b0              :
                          addr_state_16                                           ? 1'b0              :
                          (wr_state == wrst_WRFC1)                                ? 1'b0              : 1'b1;
assign  image_SRAM0_WEB = i_system_load                                           ? i_system_WEB      :
                          (wr_state == wrst_L2_WRPSUM)                            ? 1'b0              :
                          (wr_state == wrst_L4_WRPSUM)                            ? 1'b0              :
                          (wr_state == wrst_WRFC1)                                ? 1'b0              : 1'b1;
assign  image_SRAM0_A   = i_system_load                                           ? i_system_A        :
                          ((addr_state_25 || addr_state_5) && (layer_d == 3'd0))  ? image_SRAM_A_conv :
                          (wr_state == wrst_L2_WRPSUM)                            ? PSUM_A            :
                          ((addr_state_25 || addr_state_5) && (layer_d == 3'd2))  ? image_SRAM_A_conv :
                          (wr_state == wrst_L4_WRPSUM)                            ? PSUM_A            :
                          addr_state_16                                           ? rd16_addr         :     // for gap and fc2
                          (wr_state == wrst_WRFC1)                                ? GAP_A             : 14'd0;
assign  image_SRAM0_DI  = i_system_load                                           ? i_system_DI       :
                          (wr_state == wrst_L2_WRPSUM)                            ? {24'd0, psum_d}   : 
                          (wr_state == wrst_L4_WRPSUM)                            ? {24'd0, psum_d}   :
                          (wr_state == wrst_WRFC1)                                ? {24'd0, psum_d}   : 32'd0;
// to SRAM1
assign  image_SRAM1_CEB = i_system_load                                           ? i_system_CEB1     :
                          (wr_state == wrst_L1_WRPSUM)                            ? 1'b0              :
                          ((addr_state_25 || addr_state_5) && (layer_d == 3'd1))  ? 1'b0              :
                          (wr_state == wrst_L3_WRPSUM)                            ? 1'b0              :
                          ((addr_state_25 || addr_state_5) && (layer_d == 3'd3))  ? 1'b0              :
                          (wr_state == wrst_WRGAP)                                ? 1'b0              :
                          addr_state_8                                            ? 1'b0              :     // for fc1
                          (wr_state == wrst_WRFC2)                                ? 1'b0              : 1'b1;
assign  image_SRAM1_WEB = (wr_state == wrst_L1_WRPSUM)                            ? 1'b0              :
                          (wr_state == wrst_L3_WRPSUM)                            ? 1'b0              :
                          (wr_state == wrst_WRGAP)                                ? 1'b0              :
                          (wr_state == wrst_WRFC2)                                ? 1'b0              : 1'b1;
assign  image_SRAM1_A   = i_system_load                                           ? i_system_A        :
                          (wr_state == wrst_L1_WRPSUM)                            ? PSUM_A            :
                          ((addr_state_25 || addr_state_5) && (layer_d == 3'd1))  ? image_SRAM_A_conv :
                          (wr_state == wrst_L3_WRPSUM)                            ? PSUM_A            :
                          ((addr_state_25 || addr_state_5) && (layer_d == 3'd3))  ? image_SRAM_A_conv :
                          (wr_state == wrst_WRGAP)                                ? GAP_A             :
                          addr_state_8                                            ? rd8_addr          :     // for fc1
                          (wr_state == wrst_WRFC2)                                ? PSUM_A            : 14'd0;
assign  image_SRAM1_DI  = (wr_state == wrst_L1_WRPSUM)                            ? {24'd0, psum_d}   :
                          (wr_state == wrst_L3_WRPSUM)                            ? {24'd0, psum_d}   :
                          (wr_state == wrst_WRGAP)                                ? {24'd0, gap_d}    :
                          (wr_state == wrst_WRFC2)                                ? {24'd0, psum_d}   : 32'd0;
////////////////////////////////////////output & control

TS1N16ADFPCLLLVTA512X45M4SWSHOD Image_SRAM0 (
  .SLP      (1'b0             ),
  .DSLP     (1'b0             ),
  .SD       (1'b0             ),
  .PUDELAY  (                 ),
  .CLK      (clk              ),
  .CEB      (image_SRAM0_CEB  ),
  .WEB      (image_SRAM0_WEB  ),
  .A        (image_SRAM0_A    ),
  .D        (image_SRAM0_DI   ),
  .BWEB     (32'd0            ),
  .RTSEL    (2'b01            ),
  .WTSEL    (2'b01            ),
  .Q        (image_SRAM0_DO   )
);

TS1N16ADFPCLLLVTA512X45M4SWSHOD Image_SRAM1 (
  .SLP      (1'b0             ),
  .DSLP     (1'b0             ),
  .SD       (1'b0             ),
  .PUDELAY  (                 ),
  .CLK      (clk              ),
  .CEB      (image_SRAM1_CEB  ),
  .WEB      (image_SRAM1_WEB  ),
  .A        (image_SRAM1_A    ),
  .D        (image_SRAM1_DI   ),
  .BWEB     (32'd0            ),
  .RTSEL    (2'b01            ),
  .WTSEL    (2'b01            ),
  .Q        (image_SRAM1_DO   )
);

endmodule
