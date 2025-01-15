// `include "def.svh"
module L1C_inst(
  input                                 clk,
  input                                 rst,
  // CPU_wrapper FSM
  input         [3:0]                   i_m0_state,
  // inputs from CPU
  input         [31:0]                  i_CPU_A,
  // inputs from CPU_wrapper
  input         [127:0]                 i_CPUW_RDATA,
  output  logic                         o_m0_hit,
  output  logic [`CACHE_DATA_BITS-1:0]  o_DA_DO
);

logic [4:0]               DA_A;
logic [127:0]             DA_DO;
logic [127:0]             DA_DI;
logic                     DA_WEB;
logic [127:0]             DA_BWEB;
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

localparam  M0_st_IDLE        = 4'd0;
localparam  M0_st_RDTAG       = 4'd1;
localparam  M0_st_RDCHECK     = 4'd2;
localparam  M0_st_RDCACHE     = 4'd3;
localparam  M0_st_CACHETOCPU  = 4'd4;
localparam  M0_st_RDUPCACHE   = 4'd5;
localparam  M0_st_SRAMTOCPU   = 4'd6;
localparam  M0_st_AR          = 4'd7;
localparam  M0_st_R_wait      = 4'd8;
localparam  M0_st_R           = 4'd9;
localparam  M0_st_R_HS        = 4'd10;

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
  else if (i_m0_state == M0_st_RDUPCACHE) begin
    valid1[i_CPU_A[8:4]]  <= (!DA_WAY)  ? 1'b1  : valid1[i_CPU_A[8:4]];
    valid2[i_CPU_A[8:4]]  <= DA_WAY     ? 1'b1  : valid2[i_CPU_A[8:4]];
  end
end

assign  hit1      = (i_m0_state == M0_st_RDCHECK) && valid1[i_CPU_A[8:4]] && (i_CPU_A[31:9] == TA_TAG1);
assign  hit2      = (i_m0_state == M0_st_RDCHECK) && valid2[i_CPU_A[8:4]] && (i_CPU_A[31:9] == TA_TAG2);
assign  o_m0_hit  = hit1 || hit2;

assign  DA_A    = ((i_m0_state == M0_st_RDCACHE)    || (i_m0_state == M0_st_RDUPCACHE))  ? i_CPU_A[8:4]  : 5'd0;
assign  DA_DI   = (i_m0_state == M0_st_RDUPCACHE) ? i_CPUW_RDATA  : 128'd0;
assign  DA_WEB  = (i_m0_state == M0_st_RDUPCACHE) ? 1'b0  : 1'b1;
assign  DA_BWEB = (i_m0_state == M0_st_RDUPCACHE) ? 128'd0  : {128{1'b1}};
assign  DA_CEB  = ((i_m0_state == M0_st_RDCACHE) || (i_m0_state == M0_st_RDUPCACHE)) ? 1'b0  : 1'b1;
assign  DA_WAY  = (i_m0_state == M0_st_RDCACHE)   ? keep[i_CPU_A[8:4]]  :
                  (i_m0_state == M0_st_RDUPCACHE) ? !keep[i_CPU_A[8:4]] : 1'b0;

assign  TA_A    = ((i_m0_state == M0_st_RDTAG) || (i_m0_state == M0_st_RDUPCACHE))  ? i_CPU_A[8:4]  : 5'd0;
assign  TA_DI   = (i_m0_state == M0_st_RDUPCACHE) ? i_CPU_A[31:9] : 23'd0;
assign  TA_WEB  = (i_m0_state == M0_st_RDUPCACHE) ? 1'b0  : 1'b1;
assign  TA_CEB  = ((i_m0_state == M0_st_RDTAG) || (i_m0_state == M0_st_RDUPCACHE))  ? 1'b0  : 1'b1;
assign  TA_WAY  = (i_m0_state == M0_st_RDUPCACHE) ? !keep[i_CPU_A[8:4]] : 1'b0;

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