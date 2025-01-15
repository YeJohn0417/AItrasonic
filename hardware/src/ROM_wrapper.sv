// `include "../include/AXI_define.svh"

module ROM_wrapper (
    input                             ACLK,
    input                             ARESETn,

    // read address signals
    input [`AXI_IDS_BITS-1:0]         ARID_S,
    input [`AXI_ADDR_BITS-1:0]        ARADDR_S,
    input [`AXI_LEN_BITS-1:0]         ARLEN_S,
    input [`AXI_SIZE_BITS-1:0]        ARSIZE_S,
    input [1:0]                       ARBURST_S,
    input                             ARVALID_S,
    output logic                      ARREADY_S,

    // read data signals
    output logic [`AXI_IDS_BITS-1:0]  RID_S,
    output logic [`AXI_DATA_BITS-1:0] RDATA_S,
    output logic [1:0]                RRESP_S,
    output logic                      RLAST_S,
    output logic                      RVALID_S,
    input                             RREADY_S,

    // outside ROM signals
    input        [`AXI_DATA_BITS-1:0]   ROM_out,
    output logic                        ROM_read,
    output logic                        ROM_enable,
    output logic [11:0]                 ROM_address
);

localparam IDLE             = 4'b0000;
localparam AR_HANDSHAKE     = 4'b0001;
localparam READ_ADDR        = 4'b0010;
localparam WAITS            = 4'b0011;
localparam READ_DATA        = 4'b0100;

// states
logic [3:0]                 cur_state;
logic [3:0]                 next_state;
// AR Latch     
logic [`AXI_IDS_BITS-1:0]   Latch_ARID_S;
logic [`AXI_ADDR_BITS-1:0]  Latch_READ_addr;
logic [`AXI_LEN_BITS-1:0]   Latch_ARLEN_S;

logic [`AXI_LEN_BITS-1:0]   READ_counter;
logic [`AXI_DATA_BITS-1:0]  Latch_READ_data;

always_ff@(posedge ACLK or negedge ARESETn)
begin
    if(~ARESETn)  cur_state <= IDLE;
    else          cur_state <= next_state;
end

// Finite State Machine
always_comb
begin
    case(cur_state)
    IDLE:          next_state  =   (ARVALID_S) ? AR_HANDSHAKE : IDLE;
    AR_HANDSHAKE:  next_state  =   READ_ADDR;
    READ_ADDR:     next_state  =   WAITS;
    WAITS:         next_state  =   READ_DATA;
    READ_DATA:     next_state  =   (RREADY_S) ? ((READ_counter == Latch_ARLEN_S) ? IDLE : READ_ADDR) : READ_DATA;
    default:       next_state  =   IDLE;
    endcase
end

// outputs 
always_comb
begin
    ARREADY_S   = (cur_state == AR_HANDSHAKE)     ? 1'b1             : 1'b0;
    RID_S       = (cur_state == READ_DATA)        ? Latch_ARID_S     : `AXI_IDS_BITS'd0;
    RDATA_S     = (cur_state == READ_DATA)        ? Latch_READ_data  : `AXI_DATA_BITS'd0;
    RRESP_S     = `AXI_RESP_OKAY;
    RLAST_S     = (READ_counter == Latch_ARLEN_S) ? 1'b1             : 1'b0;
    RVALID_S    = (cur_state == READ_DATA)        ? 1'b1             : 1'b0;
end

// ROM signals
always_comb
begin
    case(cur_state)
    READ_ADDR:begin
        ROM_enable  = 1'b1;
        ROM_read    = 1'b0;
        ROM_address = Latch_READ_addr[13:2] + {8'd0,READ_counter};
    end
    WAITS:begin
        ROM_enable  = 1'b0;
        ROM_read    = 1'b1;
        ROM_address = 12'd0;
    end   
    default:begin
        ROM_enable  = 1'b0;
        ROM_read    = 1'b0;
        ROM_address = 12'd0;
    end
    endcase
end

// AR Latch
always_ff@(posedge ACLK or negedge ARESETn)
begin
    if(~ARESETn)begin
        Latch_ARID_S        <= `AXI_IDS_BITS'd0;
        Latch_READ_addr     <= `AXI_ADDR_BITS'd0;
        Latch_ARLEN_S       <= `AXI_LEN_BITS'd0;
    end
    else if(cur_state == IDLE)begin
        Latch_ARID_S        <= `AXI_IDS_BITS'd0;
        Latch_READ_addr     <= `AXI_ADDR_BITS'd0;
        Latch_ARLEN_S       <= `AXI_LEN_BITS'd0;
    end
    else if(ARVALID_S && ARREADY_S)begin
        Latch_ARID_S        <= ARID_S;
        Latch_READ_addr     <= ARADDR_S;
        Latch_ARLEN_S       <= ARLEN_S;
    end
    else begin
        Latch_ARID_S        <= Latch_ARID_S;
        Latch_READ_addr     <= Latch_READ_addr;
        Latch_ARLEN_S       <= Latch_ARLEN_S;
    end
end

// Read data Latch
always_ff@(posedge ACLK or negedge ARESETn)
begin
    if(~ARESETn)                    Latch_READ_data <= `AXI_DATA_BITS'd0;
    else if(cur_state == IDLE)      Latch_READ_data <= `AXI_DATA_BITS'd0;
    else if(cur_state == WAITS)     Latch_READ_data <= ROM_out;
    else                            Latch_READ_data <= Latch_READ_data;
end

// Read BURST
always_ff@(posedge ACLK or negedge ARESETn)
begin
    if(~ARESETn)                    READ_counter <= 4'd0;
    else if(cur_state == IDLE)      READ_counter <= 4'd0;
    else if(RVALID_S && RREADY_S)   READ_counter <= READ_counter + 4'd1;
    else                            READ_counter <= READ_counter;
end

endmodule
