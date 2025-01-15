// `include "def.svh"
module L1C_data(
  input                                 clk,
  input                                 rst,
  // CPU_wrapper FSM
  input         [4:0]                   i_m1_state,
  // inputs from CPU
  input         [31:0]                  i_CPU_A,
  input         [31:0]                  i_CPU_DI,
  input         [31:0]                  i_CPU_BWEB,
  // inputs from CPU_wrapper
  input         [127:0]                 i_CPUW_RDATA,
  output  logic                         o_m1_hit,
  output  logic [`CACHE_DATA_BITS-1:0]  o_DA_DO
);

logic [4:0]               DA_A;
logic [127:0]             DA_DO;
logic [127:0]             DA_DI;
logic [127:0]             DA_DI_CPU;
logic                     DA_WEB;
logic [127:0]             DA_BWEB;
logic [127:0]             DA_BWEB_CPU;
logic                     DA_CEB;
logic                     DA_WAY;

logic [4:0]               TA_A;
logic [22:0]              TA_TAG1;
logic [22:0]              TA_TAG2;
logic [22:0]              TA_DI;
logic                     TA_WEB;
logic                     TA_CEB;
logic                     TA_WAY;

logic                     hit1;
logic                     hit2;
logic [31:0]  valid1;
logic [31:0]  valid2;
logic [31:0]  keep;

localparam  M1_st_IDLE        = 5'd0;
localparam  M1_st_RDTAG       = 5'd1;
localparam  M1_st_RDCHECK     = 5'd2;
localparam  M1_st_RDCACHE     = 5'd3;
localparam  M1_st_CACHETOCPU  = 5'd4;
localparam  M1_st_AR          = 5'd5;
localparam  M1_st_R_wait      = 5'd6;
localparam  M1_st_R_HS        = 5'd7;
localparam  M1_st_R           = 5'd8;
localparam  M1_st_RDUPCACHE   = 5'd9;
localparam  M1_st_SRAMTOCPU   = 5'd10;
localparam  M1_st_WRTAG       = 5'd11;
localparam  M1_st_WRCHECK     = 5'd12;
localparam  M1_st_WRCACHE     = 5'd13;
localparam  M1_st_AW          = 5'd14;
localparam  M1_st_W           = 5'd15;
localparam  M1_st_B_HS        = 5'd16;
localparam  M1_st_B           = 5'd17;

// decide priority here
always_ff @(posedge clk or posedge rst) begin
  if (rst) begin
    keep  <= 32'd0;
  end
  else begin
    if      (hit1)  keep[i_CPU_A[8:4]]  <= 1'b0;
    else if (hit2)  keep[i_CPU_A[8:4]]  <= 1'b1;
  end
end

always_ff @(posedge clk or posedge rst) begin
  if (rst) begin
    valid1  <= 32'd0;
    valid2  <= 32'd0;
  end
  else if (i_m1_state == M1_st_RDUPCACHE) begin
    valid1[i_CPU_A[8:4]]  <= (!DA_WAY)  ? 1'b1  : valid1[i_CPU_A[8:4]];
    valid2[i_CPU_A[8:4]]  <= DA_WAY     ? 1'b1  : valid2[i_CPU_A[8:4]];
  end
end

assign  hit1      = ((i_m1_state == M1_st_RDCHECK)  || (i_m1_state == M1_st_WRCHECK)) && valid1[i_CPU_A[8:4]] && (i_CPU_A[31:9] == TA_TAG1);
assign  hit2      = ((i_m1_state == M1_st_RDCHECK)  || (i_m1_state == M1_st_WRCHECK)) && valid2[i_CPU_A[8:4]] && (i_CPU_A[31:9] == TA_TAG2);
assign  o_m1_hit  = hit1 || hit2;

assign  DA_A    = ((i_m1_state == M1_st_RDCACHE)    || (i_m1_state == M1_st_RDUPCACHE) || (i_m1_state == M1_st_WRCACHE))  ? i_CPU_A[8:4]  : 5'd0;
assign  DA_DI   = (i_m1_state == M1_st_WRCACHE)   ? DA_DI_CPU     :
                  (i_m1_state == M1_st_RDUPCACHE) ? i_CPUW_RDATA  : 128'd0;
always_comb begin
  if (i_m1_state == M1_st_WRCACHE) begin
    case (i_CPU_A[3:2])
      2'b00:  DA_DI_CPU = {{96{1'b1}}, i_CPU_DI};
      2'b01:  DA_DI_CPU = {{64{1'b1}}, i_CPU_DI, {32{1'b1}}};
      2'b10:  DA_DI_CPU = {{32{1'b1}}, i_CPU_DI, {64{1'b1}}};
      2'b11:  DA_DI_CPU = {i_CPU_DI, {96{1'b1}}};
    endcase
  end
  else DA_DI_CPU  = 128'b0;
end
assign  DA_WEB  = ((i_m1_state == M1_st_RDUPCACHE)  || (i_m1_state == M1_st_WRCACHE))  ? 1'b0  : 1'b1;
assign  DA_BWEB = (i_m1_state == M1_st_WRCACHE)   ? DA_BWEB_CPU :
                  (i_m1_state == M1_st_RDUPCACHE) ? 128'd0      : {128{1'b1}};
always_comb begin
  if (i_m1_state == M1_st_WRCACHE) begin
    case (i_CPU_A[3:2])
      2'b00:  DA_BWEB_CPU = {{96{1'b1}}, i_CPU_BWEB};
      2'b01:  DA_BWEB_CPU = {{64{1'b1}}, i_CPU_BWEB, {32{1'b1}}};
      2'b10:  DA_BWEB_CPU = {{32{1'b1}}, i_CPU_BWEB, {64{1'b1}}};
      2'b11:  DA_BWEB_CPU = {i_CPU_BWEB, {96{1'b1}}};
    endcase
  end
  else DA_BWEB_CPU  = {128{1'b1}};
end
assign  DA_CEB  = ((i_m1_state == M1_st_RDCACHE)  || (i_m1_state == M1_st_WRCACHE) || (i_m1_state == M1_st_RDUPCACHE)) ? 1'b0  : 1'b1;
assign  DA_WAY  = ((i_m1_state == M1_st_RDCACHE)  || (i_m1_state == M1_st_WRCACHE)) ? keep[i_CPU_A[8:4]]  :
                  (i_m1_state == M1_st_RDUPCACHE)                                   ? !keep[i_CPU_A[8:4]] : 1'b0;

assign  TA_A    = ((i_m1_state == M1_st_RDTAG) || (i_m1_state == M1_st_WRTAG) || (i_m1_state == M1_st_RDUPCACHE))  ? i_CPU_A[8:4]  : 5'd0;
assign  TA_DI   = (i_m1_state == M1_st_RDUPCACHE) ? i_CPU_A[31:9] : 23'd0;
assign  TA_WEB  = (i_m1_state == M1_st_RDUPCACHE) ? 1'b0  : 1'b1;
assign  TA_CEB  = ((i_m1_state == M1_st_RDTAG) || (i_m1_state == M1_st_WRTAG) || (i_m1_state == M1_st_RDUPCACHE))  ? 1'b0  : 1'b1;
assign  TA_WAY  = (i_m1_state == M1_st_RDUPCACHE) ? !keep[i_CPU_A[8:4]] : 1'b0;

assign  o_DA_DO = DA_DO;

  data_array_wrapper DA(
    .clk    (clk      ),
    .rst    (rst      ),
    .A      (DA_A     ),
    .DO     (DA_DO    ),
    .DI     (DA_DI    ),
    .WEB    (DA_WEB   ),
    .BWEB   (DA_BWEB  ),
    .CEB    (DA_CEB   ),
    .i_WAY  (DA_WAY   )
  );

  tag_array_wrapper  TA(
    .clk    (clk      ),
    .rst    (rst      ),
    .A      (TA_A     ),
    .TAG1   (TA_TAG1  ),
    .TAG2   (TA_TAG2  ),
    .DI     (TA_DI    ),
    .WEB    (TA_WEB   ),
    .CEB    (TA_CEB   ),
    .i_WAY  (TA_WAY   )
  );
  
endmodule