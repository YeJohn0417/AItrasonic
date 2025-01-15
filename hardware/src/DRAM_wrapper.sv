//`include "../sim/DRAM/DRAM.sv"
module DRAM_wrapper (
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
  output  logic                       ARREADY_S,
  
  //READ DATA
  output  logic [`AXI_IDS_BITS-1:0]   RID_S,
  output  logic [`AXI_DATA_BITS-1:0]  RDATA_S,
  output  logic [1:0]                 RRESP_S,
  output  logic                       RLAST_S,
  output  logic                       RVALID_S,
  input   logic                       RREADY_S,

  // outside DRAM signals
  input        [`AXI_DATA_BITS-1:0]   DRAM_Q,
  input                               DRAM_valid,
  output  logic                       DRAM_CSn,
  output  logic [3:0]                 DRAM_WEn,
  output  logic                       DRAM_RASn,
  output  logic                       DRAM_CASn,
  output  logic [10:0]                DRAM_A,
  output  logic [`AXI_DATA_BITS-1:0]  DRAM_D
);

logic [3:0]                 state;
logic [3:0]                 next_state;
logic [`AXI_LEN_BITS-1:0]   rd_burst_left;
logic [`AXI_LEN_BITS-1:0]   wr_burst_left;
logic [`AXI_ADDR_BITS-1:0]  AWADDR_latch;
logic [`AXI_ADDR_BITS-1:0]  ARADDR_latch;
logic [`AXI_DATA_BITS-1:0]  WDATA_latch;
logic [`AXI_STRB_BITS-1:0]  WSTRB_latch;
logic                       CE_latch;
logic [31:0]                DO_latch;
logic [`AXI_IDS_BITS-1:0]   ARID_latch;
logic [`AXI_IDS_BITS-1:0]   BID_latch;

logic                       count_done;
logic [31:0]                DRAM_Q_latch;
logic [4:0]                 r_burst_count;
logic [`AXI_LEN_BITS:0]     ARLEN_latch;
logic                       DRAM_valid_latch;
logic [`AXI_IDS_BITS-1:0]   AWID_latch;
logic [`AXI_ADDR_BITS-1:0]  ADDR_cur;
logic [2:0]                 count;
logic                       AR_HS;
logic                       AR_HS_d;    
logic                       AW_HS;
logic                       AW_HS_d;
logic                       R_HS;
logic                       R_HS_d;
logic                       W_HS;
logic                       W_HS_d;
logic                       R_ROW_HIT;
logic                       W_ROW_HIT;
logic [4:0]                 w_burst_count;
logic [`AXI_LEN_BITS-1:0]   AWLEN_latch;
logic [`AXI_ADDR_BITS-1:0]  ADDR_last;
logic                       state_act;

localparam  st_IDLE   = 4'd0;
localparam  st_ACT_R  = 4'd1;
localparam  st_ACT_W  = 4'd2;
localparam  st_READ   = 4'd3;
localparam  st_WRITE  = 4'd4;
localparam  st_B      = 4'd5;
localparam  st_PRE_R  = 4'd6;
localparam  st_PRE_W  = 4'd7;

assign  ARREADY_S = (state == st_IDLE);
assign  AWREADY_S = (state == st_IDLE);
assign  WREADY_S  = ((state == st_ACT_W) && count_done) || ((state == st_WRITE) && count_done);
assign  RID_S     = (state == st_READ)  ? ARID_latch      : `AXI_IDS_BITS'd0;
assign  RDATA_S   = (state == st_READ)  ? DRAM_Q_latch   : `AXI_DATA_BITS'd0;
assign  RRESP_S   = `AXI_RESP_OKAY;
//assign  RLAST_S   = (state == st_READ) && (r_burst_count == (ARLEN_latch + `AXI_LEN_BITS'd1)) && DRAM_valid_latch;
assign  RLAST_S   = (state == st_READ) && (r_burst_count == ARLEN_latch) && DRAM_valid_latch;
assign  RVALID_S  = (state == st_READ)  ? DRAM_valid_latch  : 1'b0;
assign  BID_S     = (state == st_B) ? AWID_latch  : `AXI_IDS_BITS'd0;
assign  BRESP_S   = `AXI_RESP_OKAY;
assign  BVALID_S  = (state == st_B) ? 1'b1  : 1'b0;

always_ff @(posedge ACLK or negedge ARESETn) begin
  if (!ARESETn) state <= st_IDLE;
  else          state <= next_state;
end

assign  AR_HS       = ARVALID_S && ARREADY_S;
assign  AW_HS       = AWVALID_S && AWREADY_S;
assign  R_HS        = RVALID_S  && RREADY_S;
assign  W_HS        = WVALID_S  && WREADY_S;
assign  B_HS        = BVALID_S  && BREADY_S;
//assign  R_ROW_HIT   = (ARADDR_latch[22:12] == ADDR_cur[22:12]);
//assign  R_ROW_HIT   = (ARADDR_latch[22:12] == ADDR_cur[22:12]) || (ADDR_last[22:12] == ADDR_cur[22:12]);
assign  R_ROW_HIT   = (ADDR_last[22:12] == ADDR_cur[22:12]);
//assign  W_ROW_HIT   = (AWADDR_latch[22:12] == ADDR_cur[22:12]);
assign  W_ROW_HIT   = (ADDR_last[22:12] == ADDR_cur[22:12]);
assign  count_done  = (count == 3'd5);

always_comb begin
  case (state)
    st_IDLE:  next_state  = (AR_HS_d && R_ROW_HIT)    ? st_ACT_R  :
                            (AR_HS_d && (!R_ROW_HIT)) ? st_PRE_R  :
                            (AW_HS_d && W_ROW_HIT)    ? st_ACT_W  :
                            (AW_HS_d && (!W_ROW_HIT)) ? st_PRE_W  : st_IDLE;
    st_ACT_R: next_state  = count_done  ? st_READ   : st_ACT_R;
    st_ACT_W: next_state  = (count_done && W_HS)    ? st_WRITE  : st_ACT_W;
//    st_READ:  next_state  = (R_HS_d && R_ROW_HIT && (r_burst_count != (ARLEN_latch + `AXI_LEN_BITS'd1)))  ? st_READ   :
    st_READ:  next_state  = (R_HS_d && R_ROW_HIT && (r_burst_count != ARLEN_latch))  ? st_READ   :
                            (R_HS_d && (!R_ROW_HIT))                    ? st_PRE_R  :
//                            (R_HS_d && (r_burst_count == (ARLEN_latch + `AXI_LEN_BITS'd1)))  ? st_IDLE   : st_READ;
                            (R_HS_d && (r_burst_count == ARLEN_latch))  ? st_IDLE   : st_READ;
    st_WRITE: next_state  = (count_done && W_HS_d && W_ROW_HIT && (w_burst_count != (AWLEN_latch + `AXI_LEN_BITS'd1)))             ? st_WRITE  :
                            (count_done && W_HS_d && (!W_ROW_HIT))          ? st_PRE_W  :
                            (count_done && (w_burst_count == (AWLEN_latch + `AXI_LEN_BITS'd1)))  ? st_B      : st_WRITE;
    st_B:     next_state  = B_HS        ? st_IDLE   : st_B;
    st_PRE_R: next_state  = count_done  ? st_ACT_R  : st_PRE_R;
    st_PRE_W: next_state  = count_done  ? st_ACT_W  : st_PRE_W;
    default:  next_state  = st_IDLE;
  endcase
end

always_ff @(posedge ACLK or negedge ARESETn) begin
  if (!ARESETn) begin
    AR_HS_d <= 1'b0;
    AW_HS_d <= 1'b0;
    W_HS_d  <= 1'b0;
    R_HS_d  <= 1'b0;
  end
  else begin
    AR_HS_d <= AR_HS;
    AW_HS_d <= AW_HS;
    W_HS_d  <= W_HS;
    R_HS_d  <= R_HS;
  end
end

always_ff @(posedge ACLK or negedge ARESETn) begin
  if (!ARESETn) begin
    ADDR_cur  <= `AXI_ADDR_BITS'd0;
  end
  else begin
    if      (AR_HS) ADDR_cur  <= ARADDR_S;
    else if (AW_HS) ADDR_cur  <= AWADDR_S;
    else if (R_HS && (state == st_READ))  ADDR_cur  <= ADDR_cur + `AXI_ADDR_BITS'd4;
    else if (W_HS && (state == st_WRITE)) ADDR_cur  <= ADDR_cur + `AXI_ADDR_BITS'd4;
  end
end

assign  ret2idle  = ((state == st_READ) && (next_state == st_IDLE)) || ((state == st_WRITE) && (next_state == st_B));
assign  state_act = ((state == st_ACT_R) || (state == st_ACT_W));

// last write or read address
// to determine if row-hit or not
always_ff @(posedge ACLK or negedge ARESETn) begin
  if (!ARESETn) begin
    ADDR_last <= `AXI_ADDR_BITS'd0;
  end
  else begin
//    if (ret2idle) ADDR_last <= ADDR_cur;
    if (state_act) ADDR_last <= ADDR_cur;
  end
end

always_ff @(posedge ACLK or negedge ARESETn) begin
  if (!ARESETn) begin
    ARADDR_latch    <= `AXI_ADDR_BITS'd0;   // new row
    ARLEN_latch     <= {`AXI_LEN_BITS'd0, 1'b0};
    ARID_latch      <= `AXI_IDS_BITS'd0;
  end
  else begin
    if (AR_HS) begin
      ARADDR_latch  <= ARADDR_S;
      ARLEN_latch   <= {1'b0,ARLEN_S};
      ARID_latch    <= ARID_S;
    end
  end
end

always_ff @(posedge ACLK or negedge ARESETn) begin
  if (!ARESETn) begin
    AWADDR_latch    <= `AXI_ADDR_BITS'd0;
    AWLEN_latch     <= `AXI_LEN_BITS'd0;
    AWID_latch      <= `AXI_IDS_BITS'd0;
  end
  else begin
    if (AW_HS) begin
      AWADDR_latch  <= AWADDR_S;
      AWLEN_latch   <= AWLEN_S;
      AWID_latch    <= AWID_S;
    end
  end
end

always_ff @(posedge ACLK or negedge ARESETn) begin
  if (!ARESETn) begin
    WDATA_latch     <= `AXI_DATA_BITS'd0;
    WSTRB_latch     <= `AXI_STRB_BITS'd0;
  end
  else begin
    if (W_HS) begin
      WDATA_latch   <= WDATA_S;
      WSTRB_latch   <= WSTRB_S;
    end
  end
end

always_ff @(posedge ACLK or negedge ARESETn) begin
  if (!ARESETn) begin
    count <= 3'd0;
  end
  else begin
    if ((state != next_state) || W_HS_d || R_HS)  count <= 3'd0;
    else if (count == 3'd5)   count <= count;
    else                      count <= count + 3'd1;
  end
end

// count for burst number
always_ff @(posedge ACLK or negedge ARESETn) begin
  if (!ARESETn) begin
    r_burst_count <= 5'd0;
  end
  else begin
    if (r_burst_count == (ARLEN_latch + `AXI_LEN_BITS'd1)) r_burst_count <= r_burst_count;
//    else if (R_HS_d)    r_burst_count <= r_burst_count  + 5'd1;
    else if (ret2idle)  r_burst_count <= 5'd0;
    else if (R_HS_d)    r_burst_count <= r_burst_count  + 5'd1;
  end
end
// count for burst number
always_ff @(posedge ACLK or negedge ARESETn) begin
  if (!ARESETn) begin
    w_burst_count  <= 5'd0;
  end
  else begin
    if (w_burst_count == (AWLEN_latch + `AXI_LEN_BITS'd1)) w_burst_count  <= w_burst_count;
    else if (W_HS)      w_burst_count <= w_burst_count + 5'd1;
    else if (ret2idle)  w_burst_count <= 5'd0;
  end
end
// store DRAM output
always_ff @(posedge ACLK or negedge ARESETn) begin
  if (!ARESETn) begin
    DRAM_Q_latch     <= 32'd0;
    DRAM_valid_latch  <= 1'b0;
  end
  else begin
    if (DRAM_valid) begin
      DRAM_Q_latch     <= DRAM_Q;
      DRAM_valid_latch  <= DRAM_valid;
    end
    else if (R_HS) begin
      DRAM_Q_latch     <= 32'd0;
      DRAM_valid_latch  <= 1'b0;
    end
  end
end

always_comb begin
  case (state)
    st_IDLE:  begin
      DRAM_CSn  = 1'b0;
      DRAM_WEn  = 4'hf;
      DRAM_RASn = 1'b1;
      DRAM_CASn = 1'b1;
      DRAM_A    = 11'd0;
      DRAM_D    = WDATA_latch;
    end
    st_ACT_R: begin
      if (count == 3'd1) begin
        DRAM_CSn  = 1'b0;
        DRAM_WEn  = 4'hf;
        DRAM_RASn = 1'b0;
        DRAM_CASn = 1'b1;
        DRAM_A    = ADDR_cur[22:12];
        DRAM_D    = WDATA_latch;
      end
      else begin
        DRAM_CSn  = 1'b0;
        DRAM_WEn  = 4'hf;
        DRAM_RASn = 1'b1;
        DRAM_CASn = 1'b1;
        DRAM_A    = ADDR_cur[22:12];
        DRAM_D    = WDATA_latch;
      end
    end
    st_ACT_W: begin
      if (count == 3'd1) begin
        DRAM_CSn  = 1'b0;
        DRAM_WEn  = 4'hf;
        DRAM_RASn = 1'b0;
        DRAM_CASn = 1'b1;
        DRAM_A    = ADDR_cur[22:12];
        DRAM_D    = WDATA_latch;
      end
      else begin
        DRAM_CSn  = 1'b0;
        DRAM_WEn  = 4'hf;
        DRAM_RASn = 1'b1;
        DRAM_CASn = 1'b1;
        DRAM_A    = ADDR_cur[22:12];
        DRAM_D    = WDATA_latch;
      end
    end
    st_READ: begin
      if (count == 3'd1) begin
        DRAM_CSn  = 1'b0;
        DRAM_WEn  = 4'hf;
        DRAM_RASn = 1'b1;
        DRAM_CASn = 1'b0;
        DRAM_A    = ADDR_cur[12:2];
        DRAM_D    = WDATA_latch;
      end
      else begin
        DRAM_CSn  = 1'b0;
        DRAM_WEn  = 4'hf;
        DRAM_RASn = 1'b1;
        DRAM_CASn = 1'b1;
        DRAM_A    = ADDR_cur[12:2];
        DRAM_D    = WDATA_latch;
      end
    end
    st_WRITE: begin
      if (count == 3'd1) begin
        DRAM_CSn  = 1'b0;
//        DRAM_WEn  = 4'h0;
        DRAM_WEn  = WSTRB_latch;
        DRAM_RASn = 1'b1;
        DRAM_CASn = 1'b0;
        DRAM_A    = ADDR_cur[12:2];
        DRAM_D    = WDATA_latch;
      end
      else begin
        DRAM_CSn  = 1'b0;
        DRAM_WEn  = 4'hf;
        DRAM_RASn = 1'b1;
        DRAM_CASn = 1'b1;
        DRAM_A    = ADDR_cur[12:2];
        DRAM_D    = WDATA_latch;
      end
    end
    st_PRE_R: begin
      if (count == 3'd1) begin
        DRAM_CSn  = 1'b0;
        DRAM_WEn  = 4'h0;
        DRAM_RASn = 1'b0;
        DRAM_CASn = 1'b1;
        DRAM_A    = ADDR_last[22:12];
        DRAM_D    = WDATA_latch;
      end
      else begin
        DRAM_CSn  = 1'b0;
        DRAM_WEn  = 4'hf;
        DRAM_RASn = 1'b1;
        DRAM_CASn = 1'b1;
        DRAM_A    = ADDR_last[22:12];
        DRAM_D    = WDATA_latch;
      end
    end
    st_PRE_W: begin
      if (count == 3'd1) begin
        DRAM_CSn  = 1'b0;
        DRAM_WEn  = 4'h0;
        DRAM_RASn = 1'b0;
        DRAM_CASn = 1'b1;
        DRAM_A    = ADDR_last[22:12];
        DRAM_D    = WDATA_latch;
      end
      else begin
        DRAM_CSn  = 1'b0;
        DRAM_WEn  = 4'hf;
        DRAM_RASn = 1'b1;
        DRAM_CASn = 1'b1;
        DRAM_A    = ADDR_last[22:12];
        DRAM_D    = WDATA_latch;
      end
    end
    default: begin
      DRAM_CSn  = 1'b1;
      DRAM_WEn  = 4'hf;
      DRAM_RASn = 1'b1;
      DRAM_CASn = 1'b1;
      DRAM_A    = 11'd0;
      DRAM_D    = `AXI_DATA_BITS'd0;
    end
  endcase
end

// assign  DRAM_RST  = !ARESETn;

endmodule