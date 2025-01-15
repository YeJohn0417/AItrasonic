module Weight_SRAM_ctlr (
input                 clk,
input                 rst,
// from CONTROL
input                 i_read,
input         [2:0]   i_layer,
input         [4:0]   i_if_channel,
input         [4:0]   i_of_channel,

input                 i_system_load,
input                 i_system_CEB,
input                 i_system_WEB,
input         [31:0]  i_system_DI,
input         [13:0]  i_system_A,

// to CONTROL
output  logic         o_read_done,
// to weight_buf
output  logic         o_weight_new,
output  logic         o_weight_new_16,
output  logic         o_weight_new_8,
output  logic [7:0]   o_weight,
output  logic         o_bias_new,
output  logic [7:0]   o_bias
);

////////////////////////////////////////latch data
logic         read_d;
logic [2:0]   layer_d;
logic [4:0]   if_channel_d;
logic [4:0]   of_channel_d;
logic [4:0]   of_channel_1t;
////////////////////////////////////////latch data

////////////////////////////////////////state
logic [2:0]   state;
logic [2:0]   next_state;
////////////////////////////////////////state

////////////////////////////////////////counter
logic [4:0]   w_cnt;
logic [13:0]  w_addr;
logic [13:0]  b_addr;
////////////////////////////////////////counter

////////////////////////////////////////outputs & control
logic         wtobuf_state;
logic         btobuf_state;
logic         waddr_state;
logic         baddr_state;
////////////////////////////////////////outputs & control

///////////////////////////////////////SRAM signals
logic         weight_SRAM_CEB;
logic         weight_SRAM_WEB;
logic [13:0]  weight_SRAM_A;
logic [31:0]  weight_SRAM_DI;
logic [31:0]  weight_SRAM_DO;
///////////////////////////////////////SRAM signals

localparam  st_IDLE         = 3'd0;
localparam  st_WADDR        = 3'd1;
localparam  st_WADDR_WTOBUF = 3'd2;
localparam  st_BADDR_WTOBUF = 3'd3;
localparam  st_WTOBUF       = 3'd4;
localparam  st_BTOBUF       = 3'd5;

////////////////////////////////////////latch data
always_ff @(posedge clk or posedge rst) begin
  if (rst) begin
//    read_d        <= 1'b0;
    layer_d       <= 3'd0;
    if_channel_d  <= 5'd0;
    of_channel_d  <= 5'd0;
  end
  else if (i_read) begin
//    read_d        <= i_read;
    layer_d       <= i_layer;
    if_channel_d  <= i_if_channel;
    of_channel_d  <= i_of_channel;
  end
end

always_ff @(posedge clk or posedge rst) begin
  if (rst)  read_d  <= 1'b0;
  else      read_d  <= i_read;
end

always_ff @(posedge clk or posedge rst) begin
  if (rst)  of_channel_1t <= 5'd0;
  else      of_channel_1t <= i_of_channel;
end
////////////////////////////////////////latch data


////////////////////////////////////////state
always_ff @(posedge clk or posedge rst) begin
  if (rst)  state <= st_IDLE;
  else      state <= next_state;
end

always_comb begin
  case (state)
    st_IDLE:          next_state  = read_d  ? st_WADDR : st_IDLE;
    st_WADDR:         next_state  = st_WADDR_WTOBUF;
    st_WADDR_WTOBUF:  next_state  = ((layer_d < 5'd4)  && (w_cnt == 5'd23)) ? st_BADDR_WTOBUF :
                                    ((layer_d == 5'd4) && (w_cnt == 5'd15)) ? st_WTOBUF      :
                                    ((layer_d == 5'd5) && (w_cnt == 5'd6))  ? st_BADDR_WTOBUF :
                                    ((layer_d == 5'd6) && (w_cnt == 5'd14)) ? st_BADDR_WTOBUF : st_WADDR_WTOBUF;
    st_BADDR_WTOBUF:  next_state  = st_BTOBUF;
    st_BTOBUF:        next_state  = st_IDLE;
    st_WTOBUF:        next_state  = st_IDLE;
    default:          next_state  = st_IDLE;
  endcase
end
////////////////////////////////////////state

////////////////////////////////////////counter
// for state control
always_ff @(posedge clk or posedge rst) begin
  if      (rst)                       w_cnt <= 5'd0;
  else if (state == st_BADDR_WTOBUF)  w_cnt <= 5'd0;
  else if (state == st_WTOBUF)        w_cnt <= 5'd0;
  else if (state == st_WADDR_WTOBUF)  w_cnt <= w_cnt + 5'd1;
end
// for weight address, does not return to 0
always_ff @(posedge clk or posedge rst) begin
  if      (rst)                                                                             w_addr  <= 14'd0;
  else if (read_d && (layer_d == 3'd0) && (if_channel_d == 5'd0) && (of_channel_d == 5'd0)) w_addr  <= 14'd0;
  else if (read_d && (layer_d == 3'd1) && (if_channel_d == 5'd0) && (of_channel_d == 5'd0)) w_addr  <= 14'd100;
  else if (read_d && (layer_d == 3'd1) && (if_channel_d == 5'd0) && (of_channel_d == 5'd1)) w_addr  <= 14'd200;
  else if (read_d && (layer_d == 3'd1) && (if_channel_d == 5'd0) && (of_channel_d == 5'd2)) w_addr  <= 14'd300;
  else if (read_d && (layer_d == 3'd1) && (if_channel_d == 5'd0) && (of_channel_d == 5'd3)) w_addr  <= 14'd400;
  else if (read_d && (layer_d == 3'd1) && (if_channel_d == 5'd0) && (of_channel_d == 5'd4)) w_addr  <= 14'd500;
  else if (read_d && (layer_d == 3'd1) && (if_channel_d == 5'd0) && (of_channel_d == 5'd5)) w_addr  <= 14'd600;
  else if (read_d && (layer_d == 3'd1) && (if_channel_d == 5'd0) && (of_channel_d == 5'd6)) w_addr  <= 14'd700;
  else if (read_d && (layer_d == 3'd1) && (if_channel_d == 5'd0) && (of_channel_d == 5'd7)) w_addr  <= 14'd800;
  else if (read_d && (layer_d == 3'd2) && (if_channel_d == 5'd0) && (of_channel_d == 5'd0)) w_addr  <= 14'd900;
  else if (read_d && (layer_d == 3'd2) && (if_channel_d == 5'd0) && (of_channel_d == 5'd1)) w_addr  <= 14'd1100;
  else if (read_d && (layer_d == 3'd2) && (if_channel_d == 5'd0) && (of_channel_d == 5'd2)) w_addr  <= 14'd1300;
  else if (read_d && (layer_d == 3'd2) && (if_channel_d == 5'd0) && (of_channel_d == 5'd3)) w_addr  <= 14'd1500;
  else if (read_d && (layer_d == 3'd2) && (if_channel_d == 5'd0) && (of_channel_d == 5'd4)) w_addr  <= 14'd1700;
  else if (read_d && (layer_d == 3'd2) && (if_channel_d == 5'd0) && (of_channel_d == 5'd5)) w_addr  <= 14'd1900;
  else if (read_d && (layer_d == 3'd2) && (if_channel_d == 5'd0) && (of_channel_d == 5'd6)) w_addr  <= 14'd2100;
  else if (read_d && (layer_d == 3'd2) && (if_channel_d == 5'd0) && (of_channel_d == 5'd7)) w_addr  <= 14'd2300;
  else if (read_d && (layer_d == 3'd3) && (if_channel_d == 5'd0) && (of_channel_d == 5'd0)) w_addr  <= 14'd2500;
  else if (read_d && (layer_d == 3'd3) && (if_channel_d == 5'd0) && (of_channel_d == 5'd1)) w_addr  <= 14'd2700;
  else if (read_d && (layer_d == 3'd3) && (if_channel_d == 5'd0) && (of_channel_d == 5'd2)) w_addr  <= 14'd2900;
  else if (read_d && (layer_d == 3'd3) && (if_channel_d == 5'd0) && (of_channel_d == 5'd3)) w_addr  <= 14'd3100;
  else if (read_d && (layer_d == 3'd3) && (if_channel_d == 5'd0) && (of_channel_d == 5'd4)) w_addr  <= 14'd3300;
  else if (read_d && (layer_d == 3'd3) && (if_channel_d == 5'd0) && (of_channel_d == 5'd5)) w_addr  <= 14'd3500;
  else if (read_d && (layer_d == 3'd3) && (if_channel_d == 5'd0) && (of_channel_d == 5'd6)) w_addr  <= 14'd3700;
  else if (read_d && (layer_d == 3'd3) && (if_channel_d == 5'd0) && (of_channel_d == 5'd7)) w_addr  <= 14'd3900;
  else if (read_d && (layer_d == 3'd5) && (if_channel_d == 5'd0) && (of_channel_d == 5'd0)) w_addr  <= 14'd4100;
  else if (read_d && (layer_d == 3'd6) && (if_channel_d == 5'd0) && (of_channel_d == 5'd0)) w_addr  <= 14'd4228;
  else if ((state == st_WADDR) || (state == st_WADDR_WTOBUF))                               w_addr  <= w_addr + 14'd1;
end
// for bias address, does not return to 0
always_ff @(posedge clk or posedge rst) begin
  if (rst)  b_addr  <= 13'd0;
  else if (read_d && (layer_d == 3'd0) && (of_channel_d == 3'd0)) b_addr  <= 14'd5120;    // bias start address
  else if (read_d && (layer_d == 3'd1) && (if_channel_d == 3'd0) && (of_channel_d == 3'd0)) b_addr  <= 14'd5124;
//  else if (read_d && (layer_d == 3'd2) && (of_channel_d == 3'd2)) b_addr  <= 14'd5125;
//  else if (read_d && (layer_d == 3'd2) && (of_channel_d == 3'd3)) b_addr  <= 14'd5126;
//  else if (read_d && (layer_d == 3'd2) && (of_channel_d == 3'd4)) b_addr  <= 14'd5127;
//  else if (read_d && (layer_d == 3'd2) && (of_channel_d == 3'd5)) b_addr  <= 14'd5128;
//  else if (read_d && (layer_d == 3'd2) && (of_channel_d == 3'd6)) b_addr  <= 14'd5129;
//  else if (read_d && (layer_d == 3'd2) && (of_channel_d == 3'd7)) b_addr  <= 14'd5130;
//  else if (read_d && (layer_d == 3'd2) && (of_channel_d == 3'd8)) b_addr  <= 14'd5131;
  else if (read_d && (layer_d == 3'd2) && (if_channel_d == 3'd0) && (of_channel_d == 3'd0)) b_addr  <= 14'd5132;
//  else if (read_d && (layer_d == 3'd3) && (of_channel_d == 3'd2)) b_addr  <= 14'd5133;
//  else if (read_d && (layer_d == 3'd3) && (of_channel_d == 3'd3)) b_addr  <= 14'd5134;
//  else if (read_d && (layer_d == 3'd3) && (of_channel_d == 3'd4)) b_addr  <= 14'd5135;
//  else if (read_d && (layer_d == 3'd3) && (of_channel_d == 3'd5)) b_addr  <= 14'd5136;
//  else if (read_d && (layer_d == 3'd3) && (of_channel_d == 3'd6)) b_addr  <= 14'd5137;
//  else if (read_d && (layer_d == 3'd3) && (of_channel_d == 3'd7)) b_addr  <= 14'd5138;
//  else if (read_d && (layer_d == 3'd3) && (of_channel_d == 3'd8)) b_addr  <= 14'd5139;
  else if (read_d && (layer_d == 3'd3) && (if_channel_d == 3'd0) && (of_channel_d == 3'd0)) b_addr  <= 14'd5140;
//  else if (read_d && (layer_d == 3'd4) && (of_channel_d == 3'd2)) b_addr  <= 14'd5141;
//  else if (read_d && (layer_d == 3'd4) && (of_channel_d == 3'd3)) b_addr  <= 14'd5142;
//  else if (read_d && (layer_d == 3'd4) && (of_channel_d == 3'd4)) b_addr  <= 14'd5143;
//  else if (read_d && (layer_d == 3'd4) && (of_channel_d == 3'd5)) b_addr  <= 14'd5144;
//  else if (read_d && (layer_d == 3'd4) && (of_channel_d == 3'd6)) b_addr  <= 14'd5145;
//  else if (read_d && (layer_d == 3'd4) && (of_channel_d == 3'd7)) b_addr  <= 14'd5146;
//  else if (read_d && (layer_d == 3'd4) && (of_channel_d == 3'd8)) b_addr  <= 14'd5147;
  else if (read_d && (layer_d == 3'd5) && (if_channel_d == 3'd0) && (of_channel_d == 3'd0)) b_addr  <= 14'd5148;
  else if (read_d && (layer_d == 3'd6) && (if_channel_d == 3'd0) && (of_channel_d == 3'd0)) b_addr  <= 14'd5164;
//  else if (state == st_BADDR_WTOBUF)                              b_addr  <= b_addr + 14'd1;
//  else if (read_d)                                                b_addr  <= b_addr + 14'd1;
  else if (of_channel_1t != i_of_channel)                                                   b_addr  <= b_addr + 14'd1;
end
////////////////////////////////////////counter

////////////////////////////////////////outputs & control
// to weight_buf
assign  wtobuf_state    = (state == st_WADDR_WTOBUF) || (state == st_BADDR_WTOBUF) || (state == st_WTOBUF);
assign  btobuf_state    = (state == st_BTOBUF);
assign  o_weight        = wtobuf_state ? weight_SRAM_DO[7:0]  : 8'd0;
assign  o_weight_new    = wtobuf_state && (layer_d < 3'd4);   // convolution layers
assign  o_weight_new_16 = wtobuf_state && (layer_d == 3'd5);  // fully connect 1
assign  o_weight_new_8  = wtobuf_state && (layer_d == 3'd6);  // fully connect 2
assign  o_bias          = (btobuf_state && (if_channel_d == 5'd0)) ? weight_SRAM_DO[7:0] : 8'd0; // non-zero bias only at if_channel = 1
assign  o_bias_new      = btobuf_state;
// to CONTROL
assign  o_read_done     = (state == st_BTOBUF) && (next_state == st_IDLE);
// to SRAM0
assign  waddr_state     = (state == st_WADDR) || (state == st_WADDR_WTOBUF);
assign  baddr_state     = (state == st_BADDR_WTOBUF);
assign  weight_SRAM_CEB = i_system_load ? i_system_CEB  :
                          waddr_state   ? 1'b0          :
                          baddr_state   ? 1'b0          : 1'b1;
assign  weight_SRAM_WEB = i_system_load ? i_system_WEB  : 1'b1;
assign  weight_SRAM_A   = i_system_load ? i_system_A    :
                          waddr_state   ? w_addr        :
                          baddr_state   ? b_addr        : 14'd0;
assign  weight_SRAM_DI   = i_system_load ? i_system_DI  : 32'd0;
////////////////////////////////////////outputs & control

TS1N16ADFPCLLLVTA512X45M4SWSHOD Weight_SRAM0 (
  .SLP      (1'b0             ),
  .DSLP     (1'b0             ),
  .SD       (1'b0             ),
  .PUDELAY  (                 ),
  .CLK      (clk              ),
  .CEB      (weight_SRAM_CEB  ),
  .WEB      (weight_SRAM_WEB  ),
  .A        (weight_SRAM_A    ),
  .D        (weight_SRAM_DI   ),
  .BWEB     (32'd0            ),
  .RTSEL    (2'b01            ),
  .WTSEL    (2'b01            ),
  .Q        (weight_SRAM_DO   )
);

endmodule
