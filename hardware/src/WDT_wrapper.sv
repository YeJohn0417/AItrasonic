module WDT_wrapper(
  input                             ACLK,
  input                             ARESETn,

  // write address signals
  input [`AXI_IDS_BITS-1:0]         AWID_S,
  input [`AXI_ADDR_BITS-1:0]        AWADDR_S,
  input [`AXI_LEN_BITS-1:0]         AWLEN_S,
  input [`AXI_SIZE_BITS-1:0]        AWSIZE_S,
  input [1:0]                       AWBURST_S,
  input                             AWVALID_S,
  output logic                      AWREADY_S,

  // write data signals
  input [`AXI_DATA_BITS-1:0]        WDATA_S,
  input [`AXI_STRB_BITS-1:0]        WSTRB_S,
  input                             WLAST_S,
  input                             WVALID_S,
  output logic                      WREADY_S,

  // write respond signals
  output logic [`AXI_IDS_BITS-1:0]  BID_S,
  output logic [1:0]                BRESP_S,
  output logic                      BVALID_S,
  input                             BREADY_S,

  // WDT timeout
  output logic                      WTO
);

localparam IDLE             = 4'b0000;
localparam AW_HANDSHAKE     = 4'b0101;
localparam W_HANDSHAKE      = 4'b0110;
localparam WRITE_DATA       = 4'b0111;
localparam WRITE_RESPOND    = 4'b1000;

logic                      rst;
// WDT signals
logic                      WDEN;
logic                      WDLIVE;
logic [`AXI_DATA_BITS-1:0] WTOCNT;
//logic                    WTO;
// states
logic [3:0]                cur_state;
logic [3:0]                next_state;
// AW Latch
logic [`AXI_IDS_BITS-1:0]  Latch_AWID_S;
logic [`AXI_ADDR_BITS-1:0] Latch_WRITE_addr;
logic [`AXI_LEN_BITS-1:0]  Latch_AWLEN_S;
// W Latch
logic [`AXI_DATA_BITS-1:0] Latch_WRITE_data;
logic [`AXI_STRB_BITS-1:0] Latch_WSTRB_S;
logic                      Latch_WLAST_S;

logic [`AXI_LEN_BITS-1:0]  WRITE_counter;

logic                      WDEN_cdc;
logic                      WDLIVE_cdc;
logic                      WTOCNT_en;
logic                      WTOCNT_en_cdc;
logic [`AXI_DATA_BITS-1:0] WTOCNT_cdc;
logic                      WTO_cdc;

assign rst  = ~ARESETn;

always_ff@(posedge ACLK or negedge ARESETn)
begin
    if(~ARESETn)  cur_state <= IDLE;
    else          cur_state <= next_state;
end

// Finite State Machine
always_comb
begin
    case(cur_state)
    IDLE:          next_state  =   (AWVALID_S)      ? AW_HANDSHAKE  : IDLE;
    AW_HANDSHAKE:  next_state  =   W_HANDSHAKE;
    W_HANDSHAKE:   next_state  =   (WVALID_S)       ? WRITE_DATA    : W_HANDSHAKE;
    WRITE_DATA:    next_state  =   (Latch_WLAST_S)  ? WRITE_RESPOND : W_HANDSHAKE;
    WRITE_RESPOND: next_state  =   (BREADY_S)       ? IDLE          : WRITE_RESPOND;
    default:       next_state  =   IDLE;
    endcase
end

// outputs 
always_comb
begin
    AWREADY_S   = (cur_state == AW_HANDSHAKE)     ? 1'b1             : 1'b0;
    WREADY_S    = (cur_state == W_HANDSHAKE)      ? 1'b1             : 1'b0;
    BID_S       = (cur_state == WRITE_RESPOND)    ? Latch_AWID_S     : `AXI_IDS_BITS'd0;
    BRESP_S     = `AXI_RESP_OKAY;
    BVALID_S    = (cur_state == WRITE_RESPOND)    ? 1'b1             : 1'b0;
end

// WDT signals
always_ff@(posedge ACLK or negedge ARESETn)
begin
    if(!ARESETn)begin
        WDEN    <= 1'b0;
        WDLIVE  <= 1'b0;
        WTOCNT  <= `AXI_DATA_BITS'd0;
        WTOCNT_en <= 1'b0;
    end
    // else if(WTO)begin
    //     WDEN    <= 1'b0;
    //     WDLIVE  <= 1'b0;
    //     WTOCNT  <= `AXI_DATA_BITS'd0;
    // end
    else if(cur_state == WRITE_DATA)begin
        case(Latch_WRITE_addr)
        32'h1001_0100:begin
            WDEN    <= (| Latch_WRITE_data);
            WDLIVE  <= WDLIVE;
            WTOCNT  <= WTOCNT;
            WTOCNT_en <= 1'b0;
        end
        32'h1001_0200:begin
            WDEN    <= WDEN;
            WDLIVE  <= (| Latch_WRITE_data);
            WTOCNT  <= WTOCNT;
            WTOCNT_en <= 1'b0;
        end
        32'h1001_0300:begin
            WDEN    <= WDEN;
            WDLIVE  <= WDLIVE;
            WTOCNT  <= Latch_WRITE_data;
            WTOCNT_en <= 1'b1;
        end
        default:begin
            WDEN    <= 1'b0;
            WDLIVE  <= 1'b0;
            WTOCNT  <= 32'd0;
            WTOCNT_en <= 1'b0;
        end
        endcase
    end
    else begin
        WDEN    <= 1'b0;
        WDLIVE  <= 1'b0;
        WTOCNT  <= 32'd0;
        WTOCNT_en <= 1'b0;
    end
end

// assign WTOCNT_en = (cur_state == WRITE_DATA) && (Latch_WRITE_addr == 32'h1001_0300);

// AW Latch
always_ff@(posedge ACLK or negedge ARESETn)
begin
    if(~ARESETn)begin      
        Latch_AWID_S        <= `AXI_IDS_BITS'd0;
        Latch_WRITE_addr    <= `AXI_ADDR_BITS'd0;
        Latch_AWLEN_S       <= `AXI_LEN_BITS'd0;
    end
    else if(cur_state == IDLE)begin
        Latch_AWID_S        <= `AXI_IDS_BITS'd0;
        Latch_WRITE_addr    <= `AXI_ADDR_BITS'd0;
        Latch_AWLEN_S       <= `AXI_LEN_BITS'd0;
    end
    else if(AWVALID_S && AWREADY_S)begin
        Latch_AWID_S        <= AWID_S;
        Latch_WRITE_addr    <= AWADDR_S;
        Latch_AWLEN_S       <= AWLEN_S;
    end
    else begin
        Latch_AWID_S        <= Latch_AWID_S;
        Latch_WRITE_addr    <= Latch_WRITE_addr;
        Latch_AWLEN_S       <= Latch_AWLEN_S;
    end
end

// W Latch
always_ff@(posedge ACLK or negedge ARESETn)
begin
    if(~ARESETn)begin      
        Latch_WRITE_data    <= `AXI_DATA_BITS'd0;
        Latch_WSTRB_S       <= {`AXI_STRB_BITS{1'b0}};
        Latch_WLAST_S       <= 1'b0;
    end
    else if(cur_state == IDLE)begin
        Latch_WRITE_data    <= `AXI_DATA_BITS'd0;
        Latch_WSTRB_S       <= {`AXI_STRB_BITS{1'b1}};
        Latch_WLAST_S       <= 1'b0;
    end
    else if(WVALID_S && WREADY_S)begin
        Latch_WRITE_data    <= WDATA_S;
        Latch_WSTRB_S       <= WSTRB_S;
        Latch_WLAST_S       <= WLAST_S;
    end
    else begin
        Latch_WRITE_data    <= Latch_WRITE_data;
        Latch_WSTRB_S       <= Latch_WSTRB_S;
        Latch_WLAST_S       <= Latch_WLAST_S;
    end
end

// Write BURST
always_ff@(posedge ACLK or negedge ARESETn)
begin
    if(~ARESETn)                    WRITE_counter <= 4'd0;
    else if(cur_state == IDLE)      WRITE_counter <= 4'd0;
    else if(WVALID_S && WREADY_S)   WRITE_counter <= WRITE_counter + 4'd1;
    else                            WRITE_counter <= WRITE_counter;
end

WDT WDT(
    .clk        (ACLK),
    .rst        (rst),
    .WDEN       (WDEN),
    .WDLIVE     (WDLIVE),
    .WTOCNT     (WTOCNT),

    .WTO        (WTO)
);

endmodule