module DMA (
  input                               ACLK,
  input                               ARESETn,
  output  logic                       INTR,

  // inputs from wrapper_s
  input         [`AXI_DATA_BITS-1:0]  i_DMAEN,
  input         [`AXI_DATA_BITS-1:0]  i_DMASRC,
  input         [`AXI_DATA_BITS-1:0]  i_DMADST,
  input         [`AXI_DATA_BITS-1:0]  i_DMALEN,

  // inputs from wrapper_m
  input                               i_M_AR_HS,
  input                               i_M_AW_HS,
  input                               i_M_W_HS,
  input                               i_RNEW,     // R channel handshake complete
  input         [`AXI_DATA_BITS-1:0]  i_RDATA,    // comes with i_RNEW
  input                               i_wr_idle,  // wr_state == wr_st_IDLE
  // outputs for wrapper_m reading
  output  logic                       o_READ,     // control DMA_wrapper_M to start reading
  output  logic [`AXI_ADDR_BITS-1:0]  o_ARADDR, 
  output  logic [`AXI_LEN_BITS-1:0]   o_ARLEN,    // control DMA_wrppaer_M ARLEN
  // outputs for wrapper_m writing
  output  logic                       o_WRITE,
  output  logic [`AXI_ADDR_BITS-1:0]  o_AWADDR,
  output  logic [`AXI_LEN_BITS-1:0]   o_AWLEN,
  // write data phase
  output  logic                       o_WNEW,
  output  logic [`AXI_DATA_BITS-1:0]  o_WDATA,
  output  logic                       o_WLAST
);

localparam  AXI_BURST_LEN = {`AXI_LEN_BITS{1'b1}};

localparam  st_IDLE           = 4'd0;
localparam  st_RW_16_ADDR     = 4'd1;             // output o_READ and o_ARADDR to activate AXI read
localparam  st_RW_16_AR_HS    = 4'd2;
localparam  st_RW_16_AW_HS    = 4'd3;
localparam  st_RW_16_DATA     = 4'd4;
localparam  st_RW_LAST_ADDR   = 4'd5;
localparam  st_RW_LAST_AR_HS  = 4'd6;
localparam  st_RW_LAST_AW_HS  = 4'd7;
localparam  st_RW_LAST_DATA   = 4'd8;

logic [3:0]                 state;
logic [3:0]                 next_state;

logic [`AXI_DATA_BITS-1:0]  DMASRC_latch;
logic [`AXI_DATA_BITS-1:0]  DMALEN_latch;
logic [`AXI_DATA_BITS-1:0]  DMADST_latch;
logic                       DMA_set;

logic [`AXI_LEN_BITS-1:0]   AWLEN_latch;
logic [`AXI_LEN_BITS:0]     rptr;
logic [`AXI_LEN_BITS:0]     wptr;
logic [`AXI_DATA_BITS-1:0]  fifo [AXI_BURST_LEN:0];
// logic [AXI_BURST_LEN:0]     count;
logic [`AXI_LEN_BITS-1:0]     count;

always_ff @(posedge ACLK or negedge ARESETn) begin
  if (!ARESETn) begin
    DMASRC_latch  <= `AXI_DATA_BITS'd0;
    DMALEN_latch  <= `AXI_DATA_BITS'd0;
    DMADST_latch  <= `AXI_DATA_BITS'd0;
    DMA_set       <= 1'b0;
  end
  else begin
    if ((state == st_IDLE) && i_DMAEN[0] && !i_M_AR_HS && (!DMA_set)) begin
      DMASRC_latch  <= i_DMASRC;
      DMALEN_latch  <= i_DMALEN;
      DMADST_latch  <= i_DMADST;
      DMA_set       <= 1'b1;
    end
    else if ((state == st_RW_16_ADDR) && i_DMAEN[0] && (i_M_AR_HS || i_M_AW_HS)) begin
      DMASRC_latch  <= DMASRC_latch + `AXI_DATA_BITS'd64;
      DMALEN_latch  <= DMALEN_latch - `AXI_DATA_BITS'd16;
      DMADST_latch  <= DMADST_latch + `AXI_DATA_BITS'd64;
    end
//    else if ((state == st_RW_16_ADDR) && i_DMAEN[0] && i_M_AW_HS) begin
//      DMADST_latch  <= DMADST_latch + `AXI_DATA_BITS'd64;
//    end
    else if ((state == st_RW_LAST_ADDR) && i_DMAEN[0] && i_M_AR_HS) begin
      DMALEN_latch  <= `AXI_DATA_BITS'd0;
      DMA_set       <= 1'b0;
    end
  end
end

always_ff @(posedge ACLK or negedge ARESETn) begin
  if (!ARESETn) state <= st_IDLE;
  else state  <= next_state;
end

always_comb begin
  case (state)
    st_IDLE:          next_state  = (i_wr_idle && i_DMAEN[0] && (DMALEN_latch >= `AXI_DATA_BITS'd16)) ? st_RW_16_ADDR    :
                                    (i_wr_idle && i_DMAEN[0] && (DMALEN_latch != `AXI_DATA_BITS'd0))  ? st_RW_LAST_ADDR  : st_IDLE;
    st_RW_16_ADDR:    next_state  = (i_M_AR_HS && i_M_AW_HS)  ? st_RW_16_DATA   :
                                    i_M_AR_HS                 ? st_RW_16_AR_HS  :
                                    i_M_AW_HS                 ? st_RW_16_AW_HS  : st_RW_16_ADDR;
    st_RW_16_AR_HS:   next_state  = i_M_AW_HS ? st_RW_16_DATA : st_RW_16_AR_HS;
    st_RW_16_AW_HS:   next_state  = i_M_AR_HS ? st_RW_16_DATA : st_RW_16_AW_HS;
    st_RW_16_DATA:    next_state  = (o_WLAST && i_M_W_HS) ? st_IDLE : st_RW_16_DATA;
    st_RW_LAST_ADDR:  next_state  = (i_M_AR_HS && i_M_AW_HS)  ? st_RW_LAST_DATA   :
                                    i_M_AR_HS                 ? st_RW_LAST_AR_HS  :
                                    i_M_AW_HS                 ? st_RW_LAST_AW_HS  : st_RW_LAST_ADDR;
    st_RW_LAST_AR_HS: next_state  = i_M_AW_HS ? st_RW_LAST_DATA : st_RW_LAST_AR_HS;
    st_RW_LAST_AW_HS: next_state  = i_M_AR_HS ? st_RW_LAST_DATA : st_RW_LAST_AW_HS;
    st_RW_LAST_DATA:  next_state  = (o_WLAST && i_M_W_HS) ? st_IDLE : st_RW_LAST_DATA;
    default:          next_state  = st_IDLE;
  endcase
end

assign  empty   = (rptr == wptr);
assign  full    = (rptr[`AXI_LEN_BITS] != wptr[`AXI_LEN_BITS]) && (rptr[`AXI_LEN_BITS-1:0] == wptr[`AXI_LEN_BITS-1:0]);

always_ff @(posedge ACLK or negedge ARESETn) begin
  if (!ARESETn) begin
    wptr  <= 5'd0;
    for (int i = 0; i < AXI_BURST_LEN + 1; i++) fifo[i] <= `AXI_DATA_BITS'd0;
  end
  else if (i_RNEW && (!full)) begin
    wptr  <= wptr + `AXI_LEN_BITS'd1;
    fifo[wptr[3:0]]  <= i_RDATA;
  end
end

always_ff @(posedge ACLK or negedge ARESETn) begin
  if (!ARESETn) begin
    rptr  <= 5'd0;
    count <= `AXI_LEN_BITS'd0;
  end
  else begin
//    if (i_M_W_HS && (count != `AXI_LEN_BITS'd15)) begin
    if (i_M_W_HS && (count != AWLEN_latch)) begin
      rptr  <= rptr + `AXI_LEN_BITS'd1;
      count <= count + `AXI_LEN_BITS'd1;
    end
    else if (i_M_W_HS) begin
      rptr  <= rptr + `AXI_LEN_BITS'd1;
      count <=  `AXI_LEN_BITS'd0;
    end
  end
end

always_ff @(posedge ACLK or negedge ARESETn) begin
  if(!ARESETn)                      AWLEN_latch <= `AXI_LEN_BITS'd0;
  else if(state == st_RW_16_ADDR)   AWLEN_latch <= `AXI_LEN_BITS'hf;
  else if(state == st_RW_LAST_ADDR) AWLEN_latch <= DMALEN_latch[`AXI_LEN_BITS-1:0] - `AXI_LEN_BITS'd1;
//  else if(state == st_RW_LAST_ADDR) AWLEN_latch <= DMALEN_latch[`AXI_LEN_BITS-1:0];
  else if(state == st_IDLE)         AWLEN_latch <= `AXI_LEN_BITS'd0;
end

assign  INTR        = (DMALEN_latch == `AXI_DATA_BITS'd0) && i_M_W_HS && o_WLAST;

assign  Phase_ADDR  = (state == st_RW_16_ADDR) || (state == st_RW_LAST_ADDR);
assign  Phase_DATA  = (state == st_RW_16_DATA) || (state == st_RW_LAST_DATA);

assign  o_READ      = Phase_ADDR;
assign  o_ARADDR    = Phase_ADDR  ? DMASRC_latch  : `AXI_ADDR_BITS'd0;
assign  o_ARLEN     = (state == st_RW_16_ADDR)    ? `AXI_LEN_BITS'hf  :
                      (state == st_RW_LAST_ADDR)  ? DMALEN_latch[`AXI_LEN_BITS-1:0] - `AXI_LEN_BITS'd1  : `AXI_LEN_BITS'd0;
//                      (state == st_RW_LAST_ADDR)  ? DMALEN_latch[`AXI_LEN_BITS-1:0] : `AXI_LEN_BITS'd0;

assign  o_WRITE     = Phase_ADDR;
assign  o_AWADDR    = Phase_ADDR  ? DMADST_latch  : `AXI_ADDR_BITS'd0;
assign  o_AWLEN     = (state == st_RW_16_ADDR)    ? `AXI_LEN_BITS'hf  :
//                      (state == st_RW_LAST_ADDR)  ? DMALEN_latch[`AXI_LEN_BITS-1:0] : `AXI_LEN_BITS'd0;
                      (state == st_RW_LAST_ADDR)  ? DMALEN_latch[`AXI_LEN_BITS-1:0] - `AXI_LEN_BITS'd1: `AXI_LEN_BITS'd0;

assign  o_WNEW      = Phase_DATA  ? (!empty)  : 1'b0;
assign  o_WDATA     = (Phase_DATA && (!empty))  ? fifo[rptr[3:0]]  : `AXI_DATA_BITS'd0;
assign  o_WLAST     = Phase_DATA && (count == AWLEN_latch);

endmodule