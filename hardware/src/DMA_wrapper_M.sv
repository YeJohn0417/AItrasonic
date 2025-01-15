module DMA_wrapper_M (
  input                                 ACLK,
  input                                 ARESETn,

  // outputs to DMA
  output  logic                         o_AR_HS,
  output  logic                         o_AW_HS,
  output  logic                         o_W_HS,
  output  logic                         o_DMA_RNEW,
  output  logic [`AXI_DATA_BITS-1:0]    o_DMA_RDATA,
  output  logic                         o_DMA_wr_idle,
  // inputs from DMA
  input                                 i_DMA_READ,
  input         [`AXI_ADDR_BITS-1:0]    i_DMA_ARADDR,
  input         [`AXI_LEN_BITS-1:0]     i_DMA_ARLEN,

  input                                 i_DMA_WRITE,      // control DMA_wrapper_M to start writing
  input         [`AXI_ADDR_BITS-1:0]    i_DMA_AWADDR,
  input         [`AXI_LEN_BITS-1:0]     i_DMA_AWLEN,

  input                                 i_DMA_WNEW,
  input         [`AXI_DATA_BITS-1:0]    i_DMA_WDATA,
  input                                 i_DMA_WLAST,

  //WRITE ADDRESS
  output  logic [`AXI_ID_BITS-1:0]      AWID_M,
  output  logic [`AXI_ADDR_BITS-1:0]    AWADDR_M,
  output  logic [`AXI_LEN_BITS-1:0]     AWLEN_M,
  output  logic [`AXI_SIZE_BITS-1:0]    AWSIZE_M,
  output  logic [1:0]                   AWBURST_M,
  output  logic                         AWVALID_M,
  input   logic                         AWREADY_M,
  
  //WRITE DATA
  output  logic [`AXI_DATA_BITS-1:0]    WDATA_M,
  output  logic [`AXI_STRB_BITS-1:0]    WSTRB_M,
  output  logic                         WLAST_M,
  output  logic                         WVALID_M,
  input   logic                         WREADY_M,
  
  //WRITE RESPONSE
  input   logic [`AXI_ID_BITS-1:0]      BID_M,
  input   logic [1:0]                   BRESP_M,
  input   logic                         BVALID_M,
  output  logic                         BREADY_M,

  //READ ADDRESS1
  output  logic [`AXI_ID_BITS-1:0]      ARID_M,
  output  logic [`AXI_ADDR_BITS-1:0]    ARADDR_M,
  output  logic [`AXI_LEN_BITS-1:0]     ARLEN_M,
  output  logic [`AXI_SIZE_BITS-1:0]    ARSIZE_M,
  output  logic [1:0]                   ARBURST_M,
  output  logic                         ARVALID_M,
  input   logic                         ARREADY_M,
  
  //READ DATA1
  input   logic [`AXI_ID_BITS-1:0]      RID_M,
  input   logic [`AXI_DATA_BITS-1:0]    RDATA_M,
  input   logic [1:0]                   RRESP_M,
  input   logic                         RLAST_M,
  input   logic                         RVALID_M,
  output  logic                         RREADY_M
);

logic [`AXI_ADDR_BITS-1:0]  DMA_AWADDR_latch;
logic [`AXI_LEN_BITS-1:0]   DMA_AWLEN_latch;
logic [`AXI_DATA_BITS-1:0]  DMA_WDATA_latch;
logic                       DMA_WNEW_latch;
logic [`AXI_ADDR_BITS-1:0]  DMA_ARADDR_latch;
logic [`AXI_LEN_BITS-1:0]   DMA_ARLEN_latch;
logic [`AXI_DATA_BITS-1:0]  RDATA_M_latch;
logic                       RLAST_M_latch;
logic [1:0]                 BRESP_M_latch;

logic [3:0]                 rd_state;
logic [3:0]                 rd_next_state;
logic [3:0]                 wr_state;
logic [3:0]                 wr_next_state;

localparam  rd_st_IDLE    = 4'd0;
localparam  rd_st_AR      = 4'd1;
localparam  rd_st_R_wait  = 4'd2;
localparam  rd_st_R_HS    = 4'd3;
localparam  rd_st_R       = 4'd4;

localparam  wr_st_IDLE    = 4'd0;
localparam  wr_st_AW      = 4'd1;
localparam  wr_st_W       = 4'd2;
localparam  wr_st_W_wait  = 4'd3;
localparam  wr_st_B_HS    = 4'd4;
localparam  wr_st_B       = 4'd5;

always_ff @(posedge ACLK or negedge ARESETn) begin
  if (!ARESETn) rd_state  <= rd_st_IDLE;
  else rd_state <= rd_next_state;
end

always_comb begin
  case (rd_state)
    rd_st_IDLE:   rd_next_state = i_DMA_READ  ? rd_st_AR  : rd_st_IDLE;
    rd_st_AR:     rd_next_state = (ARVALID_M && ARREADY_M)  ? rd_st_R_wait  : rd_st_AR;
    rd_st_R_wait: rd_next_state = RVALID_M ? rd_st_R_HS  : rd_st_R_wait;
    rd_st_R_HS:   rd_next_state = (RVALID_M && RREADY_M) ? rd_st_R : rd_st_R_HS;
    rd_st_R:      rd_next_state = RLAST_M_latch ? rd_st_IDLE  : rd_st_R_HS;
    default:      rd_next_state = rd_st_IDLE;
  endcase
end

always_ff @(posedge ACLK or negedge ARESETn) begin
  if (!ARESETn) wr_state  <= wr_st_IDLE;
  else wr_state <= wr_next_state;
end

always_comb begin
  case (wr_state)
    wr_st_IDLE:   wr_next_state = i_DMA_WRITE ? wr_st_AW  : wr_st_IDLE;
//    wr_st_AW:     wr_next_state = (AWVALID_M && AWREADY_M)  ? wr_st_W_wait  : wr_st_AW;
    wr_st_AW:     wr_next_state = (AWVALID_M && AWREADY_M)  ? wr_st_W  : wr_st_AW;
    wr_st_W:      wr_next_state = (WVALID_M && WREADY_M && i_DMA_WLAST) ? wr_st_B_HS  : wr_st_W;
    wr_st_B_HS:   wr_next_state = (BVALID_M && BREADY_M)  ? wr_st_B : wr_st_B_HS;
    wr_st_B:      wr_next_state = wr_st_IDLE;
    default:      wr_next_state = wr_st_IDLE;
  endcase
end

always_ff @(posedge ACLK or negedge ARESETn) begin
  if (!ARESETn) begin
    DMA_AWADDR_latch  <= `AXI_ADDR_BITS'd0;
    DMA_AWLEN_latch   <= `AXI_LEN_BITS'd0;
    DMA_ARADDR_latch  <= `AXI_ADDR_BITS'd0;
    DMA_ARLEN_latch   <= `AXI_LEN_BITS'd0;
    RDATA_M_latch     <= `AXI_DATA_BITS'd0;
    RLAST_M_latch     <= 1'b0;
    BRESP_M_latch     <= 2'd0;
  end
  else begin
    if (i_DMA_WRITE) begin
      DMA_AWADDR_latch <= i_DMA_AWADDR;
      DMA_AWLEN_latch  <= i_DMA_AWLEN;
    end
    if (i_DMA_READ) begin
      DMA_ARADDR_latch <= i_DMA_ARADDR;
      DMA_ARLEN_latch  <= i_DMA_ARLEN;
    end
    if (RVALID_M && RREADY_M) begin
      RDATA_M_latch  <= RDATA_M;
      RLAST_M_latch  <= RLAST_M;
    end
    if (BVALID_M & BREADY_M)  BRESP_M_latch  <= BRESP_M;
  end
end

always_ff @(posedge ACLK or negedge ARESETn) begin
  if (!ARESETn) begin
    DMA_WDATA_latch   <= `AXI_DATA_BITS'd0;     // no drive
    DMA_WNEW_latch    <= 1'b0;
  end
  else begin
    if (i_DMA_WNEW) begin
      DMA_WDATA_latch <= i_DMA_WDATA;
      DMA_WNEW_latch  <= i_DMA_WNEW;
    end
    else if (o_W_HS) begin
      DMA_WDATA_latch <= `AXI_DATA_BITS'd0;
      DMA_WNEW_latch  <= 1'b0;
    end
  end
end

assign  o_AR_HS = (ARVALID_M  && ARREADY_M);
assign  o_AW_HS = (AWVALID_M  && AWREADY_M);
assign  o_W_HS  = (WVALID_M   && WREADY_M);

assign  AWID_M        = `AXI_ID_BITS'd0;
assign  AWADDR_M      = (wr_state == wr_st_AW)  ? DMA_AWADDR_latch  : `AXI_ADDR_BITS'd0;
assign  AWLEN_M       = DMA_AWLEN_latch;
assign  AWSIZE_M      = `AXI_SIZE_WORD;
assign  AWBURST_M     = `AXI_BURST_INC;
assign  AWVALID_M     = (wr_state == wr_st_AW);

//assign  WDATA_M       = (wr_state == wr_st_W) ? DMA_WDATA_latch  : `AXI_DATA_BITS'd0;
assign  WDATA_M       = (wr_state == wr_st_W) ? i_DMA_WDATA  : `AXI_DATA_BITS'd0;
assign  WSTRB_M       = 4'h0;
assign  WLAST_M       = (wr_state == wr_st_W) && i_DMA_WNEW && i_DMA_WLAST;
//assign  WVALID_M      = (wr_state == wr_st_W) && DMA_WNEW_latch;
assign  WVALID_M      = (wr_state == wr_st_W) && i_DMA_WNEW;

assign  BREADY_M      = (wr_state == wr_st_B_HS);

assign  ARID_M        = `AXI_ID_BITS'd0;
assign  ARADDR_M      = (rd_state == rd_st_AR)  ? DMA_ARADDR_latch : `AXI_ADDR_BITS'd0;
assign  ARLEN_M       = DMA_ARLEN_latch;
assign  ARSIZE_M      = `AXI_SIZE_WORD;
assign  ARBURST_M     = `AXI_BURST_INC;
assign  ARVALID_M     = (rd_state == rd_st_AR);

assign  RREADY_M      = (rd_state == rd_st_R_HS);

assign  o_DMA_RDATA   = (rd_state == rd_st_R) ? RDATA_M_latch  : 32'd0;
assign  o_DMA_RNEW    = (rd_state == rd_st_R);
assign  o_DMA_wr_idle = (wr_state == wr_st_IDLE);

endmodule