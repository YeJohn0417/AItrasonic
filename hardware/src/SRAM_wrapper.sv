module SRAM_wrapper (
  input   logic                       ACLK,
  input   logic                       ARESETn,

  //WRITE ADDRESS
  input   logic [`AXI_IDS_BITS-1:0]   AWID_S,
  input   logic [`AXI_ADDR_BITS-1:0]  AWADDR_S,
  input   logic [`AXI_LEN_BITS-1:0]   AWLEN_S,
  input   logic [`AXI_SIZE_BITS-1:0]  AWSIZE_S,   // 000:1byte, 001:2byte, 010:4byte, 011:8byte, 100:16byte, 101:32byte, 110:64byte, 111:128byte
  input   logic [1:0]                 AWBURST_S,  // fix to 2'b01, i.e. INCR
  input   logic                       AWVALID_S,
  output  logic                       AWREADY_S,
  
  //WRITE DATA
  input   logic [`AXI_DATA_BITS-1:0]  WDATA_S,
  input   logic [`AXI_STRB_BITS-1:0]  WSTRB_S,  // 4-bits, each bit controls a byte
  input   logic                       WLAST_S,
  input   logic                       WVALID_S,
  output  logic                       WREADY_S,
  
  //WRITE RESPONSE
  output  logic [`AXI_IDS_BITS-1:0]   BID_S,
  output  logic [1:0]                 BRESP_S,  // 00:OKAY, 01:EXOKAY, 10:SLVERR, 11:DECERR
  output  logic                       BVALID_S,
  input   logic                       BREADY_S,

  //READ ADDRESS
  input   logic [`AXI_IDS_BITS-1:0]   ARID_S,
  input   logic [`AXI_ADDR_BITS-1:0]  ARADDR_S,
  input   logic [`AXI_LEN_BITS-1:0]   ARLEN_S,
  input   logic [`AXI_SIZE_BITS-1:0]  ARSIZE_S,
  input   logic [1:0]                 ARBURST_S,
  input   logic                       ARVALID_S,
  output                              ARREADY_S,
  
  //READ DATA
  output  logic [`AXI_IDS_BITS-1:0]   RID_S,
  output  logic [`AXI_DATA_BITS-1:0]  RDATA_S,
  output  logic [1:0]                 RRESP_S,
  output  logic                       RLAST_S,
  output  logic                       RVALID_S,
  input   logic                       RREADY_S
);

logic [3:0]                 state;
logic [3:0]                 next_state;
logic [`AXI_LEN_BITS-1:0]   rd_burst_left;
//logic [`AXI_LEN_BITS-1:0]   wr_burst_left;
logic [`AXI_LEN_BITS:0]     wr_burst_left;
logic [`AXI_ADDR_BITS-1:0]  AWADDR_latch;
logic                       AWADDR_latch_first;
logic [`AXI_ADDR_BITS-1:0]  ARADDR_latch;
logic [`AXI_DATA_BITS-1:0]  WDATA_latch;
logic [`AXI_STRB_BITS-1:0]  WSTRB_latch;
logic [31:0]                MEM_BWEB;
logic                       CE_latch;
logic [31:0]                DO_latch;
logic [`AXI_IDS_BITS-1:0]   ARID_latch;
logic [`AXI_IDS_BITS-1:0]   BID_latch;

// Signals for SRAM
logic         CEB;
logic         WEB;
logic [13:0]  A;
logic [31:0]  DI;
logic [31:0]  BWEB;
logic [31:0]  DO;

localparam  st_IDLE     = 4'b0000;
localparam  st_AR_HS    = 4'b0001;
localparam  st_RD_ADDR  = 4'b0010;
localparam  st_RD_WAIT  = 4'b0011;
localparam  st_RD_DATA  = 4'b0100;
localparam  st_AW_HS    = 4'b0101;
localparam  st_WR_HS    = 4'b0110;
localparam  st_WR_DATA  = 4'b0111;
localparam  st_WR_RESP  = 4'b1000;

assign  ARREADY_S = (state == st_AR_HS);
assign  AWREADY_S = (state == st_AW_HS);
assign  WREADY_S  = (state == st_WR_HS);
assign  RID_S     = (state == st_RD_DATA) ? ARID_latch  : `AXI_IDS_BITS'd0;
assign  RDATA_S   = (state == st_RD_DATA) ? DO_latch  : `AXI_DATA_BITS'd0;
assign  RRESP_S   = (state == st_RD_DATA) ? `AXI_RESP_OKAY  : `AXI_RESP_OKAY;
assign  RLAST_S   = (state == st_RD_DATA) & (rd_burst_left == `AXI_LEN_BITS'd0);
assign  RVALID_S  = (state == st_RD_DATA);
assign  BID_S     = (state == st_WR_RESP) ? BID_latch : `AXI_IDS_BITS'd0;
assign  BRESP_S   = (state == st_WR_RESP) ? `AXI_RESP_OKAY  : `AXI_RESP_SLVERR;
assign  BVALID_S  = (state == st_WR_RESP);

// FSM for read data
always_ff @(posedge ACLK or negedge ARESETn) begin
  if (~ARESETn) state <= st_IDLE;
  else state  <= next_state;
end

always_comb begin
  case (state)
    st_IDLE:    next_state  = ARVALID_S ? st_AR_HS  :
                              AWVALID_S ? st_AW_HS  : st_IDLE;
    st_AR_HS:   next_state  = (ARVALID_S && ARREADY_S) ? st_RD_ADDR  : st_AR_HS;
    st_RD_ADDR: next_state  = st_RD_WAIT;
    st_RD_WAIT: next_state  = st_RD_DATA;
    st_RD_DATA: next_state  = ((RREADY_S && RVALID_S) & (rd_burst_left == `AXI_LEN_BITS'd0)) ? st_IDLE :
                              (RREADY_S && RVALID_S) ? st_RD_ADDR  : st_RD_DATA;
    st_AW_HS:   next_state  = (AWVALID_S && AWREADY_S) ? st_WR_HS  : st_AW_HS;
    st_WR_HS:   next_state  = (WVALID_S && WREADY_S) ? st_WR_DATA  : st_WR_HS;
    st_WR_DATA: next_state  = (wr_burst_left == 5'd0) ? st_WR_RESP  : st_WR_HS;
    st_WR_RESP: next_state  = (BVALID_S && BREADY_S) ? st_IDLE : st_WR_RESP;
    default:    next_state  = st_IDLE;
  endcase
end

always_ff @(posedge ACLK or negedge ARESETn) begin : counter_for_burst
  if (~ARESETn) begin
    wr_burst_left <= {`AXI_LEN_BITS'd0, 1'b0};
    rd_burst_left <= `AXI_LEN_BITS'd0;
  end
  else begin
    if (state == st_IDLE) begin
      wr_burst_left <= {`AXI_LEN_BITS'd0, 1'b0};
      rd_burst_left <= `AXI_LEN_BITS'd0;
    end
    else begin
      if ((AWVALID_S && AWREADY_S) & (AWLEN_S != `AXI_LEN_BITS'd0)) wr_burst_left  <= AWLEN_S + `AXI_LEN_BITS'd1;
      if ((ARVALID_S && ARREADY_S) & (ARLEN_S != `AXI_LEN_BITS'd0)) rd_burst_left  <= ARLEN_S;
      if ((WVALID_S && WREADY_S) & (wr_burst_left > {`AXI_LEN_BITS'd0, 1'b0})) wr_burst_left <= wr_burst_left - `AXI_LEN_BITS'd1;
      if ((RVALID_S && RREADY_S) & (rd_burst_left > `AXI_LEN_BITS'd0)) rd_burst_left <= rd_burst_left - `AXI_LEN_BITS'd1;
    end
  end
end

// always_ff @(posedge ACLK or negedge ARESETn) begin : latch_addr_and_data
//   if (~ARESETn) begin
//     AWADDR_latch  <= `AXI_ADDR_BITS'd0;
//     ARADDR_latch  <= `AXI_ADDR_BITS'd0;
//     ARID_latch    <= `AXI_IDS_BITS'd0;
//     WDATA_latch   <= `AXI_DATA_BITS'd0;
//     WSTRB_latch   <= `AXI_STRB_BITS'd0;
//     BID_latch     <= `AXI_IDS_BITS'd0;
//     CE_latch      <= 1'd0;
//     DO_latch      <= 32'd0;
//   end
//   else begin
//     if (AWREADY_S & AWVALID_S) begin
//       AWADDR_latch  <= AWADDR_S;
//       BID_latch     <= AWID_S;
//     end
//     else if ((WVALID_S & WREADY_S) & (wr_burst_left > {`AXI_LEN_BITS'd0, 1'b0})) AWADDR_latch <= AWADDR_latch + `AXI_ADDR_BITS'd4;
//     else if (ARREADY_S & ARVALID_S) begin
//       ARADDR_latch  <= ARADDR_S;
//       ARID_latch    <= ARID_S;
//     end
//     else if ((RVALID_S & RREADY_S) & (rd_burst_left > `AXI_LEN_BITS'd0)) ARADDR_latch <= ARADDR_latch + `AXI_ADDR_BITS'd4;
//     else if (WREADY_S & WVALID_S) begin
//       WDATA_latch   <= WDATA_S;
//       WSTRB_latch   <= WSTRB_S;
//     end
//     CE_latch  <= !CEB;
//     if (CE_latch) DO_latch  <= DO;
//   end
// end

always_ff @(posedge ACLK or negedge ARESETn) begin
  if (!ARESETn) begin
    AWADDR_latch        <= `AXI_ADDR_BITS'd0;
    BID_latch           <= `AXI_IDS_BITS'd0;
    AWADDR_latch_first  <= 1'b0;
  end
  else begin
    if (AWREADY_S && AWVALID_S) begin
      AWADDR_latch  <= AWADDR_S;
      BID_latch     <= AWID_S;
    end
    else if ((WVALID_S & WREADY_S) && (wr_burst_left > {`AXI_LEN_BITS'd0, 1'b0}) && !AWADDR_latch_first) begin
      AWADDR_latch <= AWADDR_latch;
      AWADDR_latch_first  <= 1'b1;
    end
    else if ((WVALID_S & WREADY_S) && (wr_burst_left > {`AXI_LEN_BITS'd0, 1'b0}) && AWADDR_latch_first && !WLAST_S) begin
      AWADDR_latch <= AWADDR_latch + `AXI_ADDR_BITS'd4;
    end
    else if ((WVALID_S & WREADY_S) && (wr_burst_left > {`AXI_LEN_BITS'd0, 1'b0}) && AWADDR_latch_first && WLAST_S) begin
      AWADDR_latch <= AWADDR_latch + `AXI_ADDR_BITS'd4;
      AWADDR_latch_first  <= 1'b0;
    end
  end
end

always_ff @(posedge ACLK or negedge ARESETn) begin
  if (!ARESETn) begin
    ARADDR_latch  <= `AXI_ADDR_BITS'd0;
    ARID_latch    <= `AXI_IDS_BITS'd0;
  end
  else begin
    if (ARREADY_S && ARVALID_S) begin
      ARADDR_latch  <= ARADDR_S;
      ARID_latch    <= ARID_S;
    end
    else if ((RVALID_S & RREADY_S) & (rd_burst_left > `AXI_LEN_BITS'd0)) begin
      ARADDR_latch <= ARADDR_latch + `AXI_ADDR_BITS'd4;
    end
  end
end

always_ff @(posedge ACLK or negedge ARESETn) begin
  if (!ARESETn) begin
    WDATA_latch   <= `AXI_DATA_BITS'd0;
    WSTRB_latch   <= `AXI_STRB_BITS'd0;
  end
  else begin
    if (WREADY_S && WVALID_S) begin
      WDATA_latch   <= WDATA_S;
      WSTRB_latch   <= WSTRB_S;
    end
  end
end

always_ff @(posedge ACLK or negedge ARESETn) begin
  if (!ARESETn) begin
    CE_latch      <= 1'b0;
    DO_latch      <= 32'd0;
  end
  else begin
    CE_latch      <= !CEB;
    if (CE_latch) DO_latch  <= DO;
  end
end

assign  MEM_BWEB[7:0]   = {8{WSTRB_latch[0]}};
assign  MEM_BWEB[15:8]  = {8{WSTRB_latch[1]}};
assign  MEM_BWEB[23:16] = {8{WSTRB_latch[2]}};
assign  MEM_BWEB[31:24] = {8{WSTRB_latch[3]}};

always_comb begin : mem_control_signals
  case (state)
    st_IDLE: begin
      A     = 14'd0;
      DI    = 32'd0;
      CEB   = 1'b1;
      WEB   = 1'b1;
      BWEB  = 32'hffff_ffff;
    end
    st_RD_ADDR: begin
      A     = ARADDR_latch[15:2];
      DI    = 32'd0;
      CEB   = 1'b0;
      WEB   = 1'b1;
      BWEB  = 32'hffff_ffff;
    end
    st_RD_WAIT: begin
      A     = ARADDR_latch[15:2];
      DI    = 32'd0;
      CEB   = 1'b1;
      WEB   = 1'b1;
      BWEB  = 32'hffff_ffff;
    end
    st_RD_DATA: begin
      A     = ARADDR_latch[15:2];
      DI    = 32'd0;
      CEB   = 1'b1;
      WEB   = 1'b1;
      BWEB  = 32'hffff_ffff;
    end
    st_WR_DATA:  begin
      A     = AWADDR_latch[15:2];
      DI    = WDATA_latch;
      CEB   = 1'b0;
      WEB   = 1'b0;
      BWEB  = MEM_BWEB;
    end
    default: begin
      A     = 14'd0;
      DI    = 32'd0;
      CEB   = 1'b1;
      WEB   = 1'b1;
      BWEB  = 32'hffff_ffff;
    end
  endcase
end

TS1N16ADFPCLLLVTA512X45M4SWSHOD i_SRAM (
  .SLP(1'b0),
  .DSLP(1'b0),
  .SD(1'b0),
  .PUDELAY(),
  .CLK(ACLK),
  .CEB(CEB),
  .WEB(WEB),
  .A(A),
  .D(DI),
  .BWEB(BWEB),
  .RTSEL(2'b01),
  .WTSEL(2'b01),
  .Q(DO)
);

endmodule