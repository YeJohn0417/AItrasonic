// `include "CPU.sv"
// `include "L1C_inst.sv"
// `include "L1C_data.sv"
// `include "./data_array_wrapper.sv"
// `include "./tag_array_wrapper.sv"
module CPU_wrapper (
  input                                 ACLK,
  input                                 ARESETn,
  input                                 intr_wdt,
  input                                 intr_dma,
  input                                 intr_epu,

  //WRITE ADDRESS
  output  logic  [`AXI_ID_BITS-1:0]     AWID_M1,
  output  logic  [`AXI_ADDR_BITS-1:0]   AWADDR_M1,
  output  logic  [`AXI_LEN_BITS-1:0]    AWLEN_M1,
  output  logic  [`AXI_SIZE_BITS-1:0]   AWSIZE_M1,
  output  logic  [1:0]                  AWBURST_M1,
  output  logic                         AWVALID_M1,
  input   logic                         AWREADY_M1,
  
  //WRITE DATA
  output  logic [`AXI_DATA_BITS-1:0]    WDATA_M1,
  output  logic [`AXI_STRB_BITS-1:0]    WSTRB_M1,
  output  logic                         WLAST_M1,
  output  logic                         WVALID_M1,
  input   logic                         WREADY_M1,
  
  //WRITE RESPONSE
  input   logic [`AXI_ID_BITS-1:0]      BID_M1,
  input   logic [1:0]                   BRESP_M1,
  input   logic                         BVALID_M1,
  output  logic                         BREADY_M1,

  //READ ADDRESS0
  output  logic [`AXI_ID_BITS-1:0]      ARID_M0,
  output  logic [`AXI_ADDR_BITS-1:0]    ARADDR_M0,
  output  logic [`AXI_LEN_BITS-1:0]     ARLEN_M0,   // burst length = ARLEN + 1
  output  logic [`AXI_SIZE_BITS-1:0]    ARSIZE_M0,
  output  logic [1:0]                   ARBURST_M0,
  output  logic                         ARVALID_M0,
  input   logic                         ARREADY_M0,
  
  //READ DATA0
  input   logic [`AXI_ID_BITS-1:0]      RID_M0,
  input   logic [`AXI_DATA_BITS-1:0]    RDATA_M0,
  input   logic [1:0]                   RRESP_M0,
  input   logic                         RLAST_M0,
  input   logic                         RVALID_M0,
  output  logic                         RREADY_M0,
  
  //READ ADDRESS1
  output  logic [`AXI_ID_BITS-1:0]      ARID_M1,
  output  logic [`AXI_ADDR_BITS-1:0]    ARADDR_M1,
  output  logic [`AXI_LEN_BITS-1:0]     ARLEN_M1,
  output  logic [`AXI_SIZE_BITS-1:0]    ARSIZE_M1,
  output  logic [1:0]                   ARBURST_M1,
  output  logic                         ARVALID_M1,
  input   logic                         ARREADY_M1,
  
  //READ DATA1
  input   logic [`AXI_ID_BITS-1:0]      RID_M1,
  input   logic [`AXI_DATA_BITS-1:0]    RDATA_M1,
  input   logic [1:0]                   RRESP_M1,
  input   logic                         RLAST_M1,
  input   logic                         RVALID_M1,
  output  logic                         RREADY_M1
);

logic         rst;
logic         CPU_o_IM1_CEB;
logic         CPU_o_IM1_WEB;
logic [31:0]  CPU_o_IM1_BWEB;
logic [29:0]  CPU_o_IM1_A;
logic [31:0]  CPU_o_IM1_DI;
logic         CPU_o_DM1_CEB;
logic         CPU_o_DM1_WEB;
logic [31:0]  CPU_o_DM1_BWEB;
logic [29:0]  CPU_o_DM1_A;
logic [31:0]  CPU_o_DM1_DI;
logic [31:0]  IM1_DO;
logic [31:0]  DM1_DO;

logic [3:0]   m0_state;
logic [3:0]   m0_next_state;
logic [4:0]   m1_state;
logic [4:0]   m1_next_state;

// latching signals for M0
logic [31:0]  CPU_o_IM1_A_latch;
logic [127:0] RDATA_M0_latch;
logic         RLAST_M0_latch;

// latching signals for M1
logic [31:0]  CPU_o_DM1_A_latch;
logic [31:0]  CPU_o_DM1_DI_latch;
logic [31:0]  CPU_o_DM1_BWEB_latch;
logic [127:0] RDATA_M1_latch;
logic         RLAST_M1_latch;
logic [1:0]   BRESP_M1_latch;

logic [1:0]   RDATA_M0_count;
logic [1:0]   RDATA_M1_count;
logic         L1C_inst_m0_hit;
logic [127:0] L1C_inst_DA_DO;
logic         L1C_data_m1_hit;
logic [127:0] L1C_data_DA_DO;

assign rst  = !ARESETn;

CPU u0_CPU (
  .clk            (ACLK           ),
  .rst            (rst            ),
  .intr_wdt       (intr_wdt       ),
  .intr_dma       (intr_dma       ),
  .intr_epu       (intr_epu       ),
  .o_IM1_CEB      (CPU_o_IM1_CEB  ),
  .o_IM1_WEB      (CPU_o_IM1_WEB  ),
  .o_IM1_BWEB     (CPU_o_IM1_BWEB ),
  .o_IM1_A        (CPU_o_IM1_A    ),
  .o_IM1_DI       (CPU_o_IM1_DI   ),
  .o_DM1_CEB      (CPU_o_DM1_CEB  ),
  .o_DM1_WEB      (CPU_o_DM1_WEB  ),
  .o_DM1_BWEB     (CPU_o_DM1_BWEB ),
  .o_DM1_A        (CPU_o_DM1_A    ),
  .o_DM1_DI       (CPU_o_DM1_DI   ),
  .i_IM1_DO       (IM1_DO         ),
  .i_DM1_DO       (DM1_DO         ),
  .i_m0_state     (m0_state       ),
  .i_m1_state     (m1_state       )
);

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



//****************************************//
//*************** MASTER 0 ***************//
//****************************************//



// FSM for IM
always_ff @(posedge ACLK or negedge ARESETn) begin
  if (!ARESETn)  m0_state <= M0_st_IDLE;
  else m0_state  <= m0_next_state;
end

always_comb begin
  case (m0_state)
    M0_st_IDLE:       m0_next_state = (!CPU_o_IM1_CEB)  ? M0_st_RDTAG : M0_st_IDLE;
    M0_st_RDTAG:      m0_next_state = M0_st_RDCHECK;
    M0_st_RDCHECK:    m0_next_state = L1C_inst_m0_hit ? M0_st_RDCACHE : M0_st_AR;
    M0_st_RDCACHE:    m0_next_state = M0_st_CACHETOCPU;
    M0_st_CACHETOCPU: m0_next_state = M0_st_IDLE;
    M0_st_AR:         m0_next_state = (ARVALID_M0 && ARREADY_M0) ? M0_st_R_wait  : M0_st_AR;
    M0_st_R_wait:     m0_next_state = RVALID_M0 ? M0_st_R_HS  : M0_st_R_wait;
    M0_st_R_HS:       m0_next_state = (RVALID_M0 && RREADY_M0) ? M0_st_R : M0_st_R_HS;
    M0_st_R:          m0_next_state = RLAST_M0_latch  ? M0_st_RDUPCACHE  : M0_st_R_HS;
    M0_st_RDUPCACHE:  m0_next_state = M0_st_SRAMTOCPU;
    M0_st_SRAMTOCPU:  m0_next_state = M0_st_IDLE;
    default:          m0_next_state = M0_st_IDLE;
  endcase
end

always_ff @(posedge ACLK or negedge ARESETn) begin : latch_IM1_signal
  if (!ARESETn) begin
    CPU_o_IM1_A_latch <= 32'd0;
    RDATA_M0_latch    <= 128'd0;
    RLAST_M0_latch    <= 1'b0;
    RDATA_M0_count    <= 2'd0;
  end
  else begin
    CPU_o_IM1_A_latch <= {CPU_o_IM1_A, 2'd0};
    if (RVALID_M0 & RREADY_M0) begin
      case (RDATA_M0_count)
        2'd0: RDATA_M0_latch[31:0]    <= RDATA_M0;
        2'd1: RDATA_M0_latch[63:32]   <= RDATA_M0;
        2'd2: RDATA_M0_latch[95:64]   <= RDATA_M0;
        2'd3: RDATA_M0_latch[127:96]  <= RDATA_M0;
      endcase
      RLAST_M0_latch  <= RLAST_M0;
      RDATA_M0_count  <= RDATA_M0_count + 2'd1;
    end
  end
end

assign  ARID_M0     = `AXI_ID_BITS'd0;
assign  ARADDR_M0   = (m0_state == M0_st_AR)  ? {CPU_o_IM1_A_latch[31:4], 4'd0} : 32'd0;
assign  ARLEN_M0    = `AXI_LEN_BITS'd3;
assign  ARSIZE_M0   = `AXI_SIZE_WORD;
assign  ARBURST_M0  = `AXI_BURST_INC;
assign  ARVALID_M0  = (m0_state == M0_st_AR);

assign  RREADY_M0   = (m0_state == M0_st_R_HS);

// to CPU
always_comb begin
  case ({CPU_o_IM1_A_latch[3:2], m0_state})
    {2'b00, M0_st_CACHETOCPU}:  IM1_DO  = L1C_inst_DA_DO[31:0];
    {2'b01, M0_st_CACHETOCPU}:  IM1_DO  = L1C_inst_DA_DO[63:32];
    {2'b10, M0_st_CACHETOCPU}:  IM1_DO  = L1C_inst_DA_DO[95:64];
    {2'b11, M0_st_CACHETOCPU}:  IM1_DO  = L1C_inst_DA_DO[127:96];
    {2'b00, M0_st_SRAMTOCPU}:   IM1_DO  = RDATA_M0_latch[31:0];
    {2'b01, M0_st_SRAMTOCPU}:   IM1_DO  = RDATA_M0_latch[63:32];
    {2'b10, M0_st_SRAMTOCPU}:   IM1_DO  = RDATA_M0_latch[95:64];
    {2'b11, M0_st_SRAMTOCPU}:   IM1_DO  = RDATA_M0_latch[127:96];
    default:                    IM1_DO  = 32'd0;
  endcase
end

L1C_inst u0_L1C_inst (
  .clk            (ACLK                 ),
  .rst            (rst                  ),
  .i_m0_state     (m0_state             ),
  .i_CPU_A        (CPU_o_IM1_A_latch    ),
  .i_CPUW_RDATA   (RDATA_M0_latch       ),
  .o_m0_hit       (L1C_inst_m0_hit      ),
  .o_DA_DO        (L1C_inst_DA_DO       )
);



//****************************************//
//*************** MASTER 1 ***************//
//****************************************//



// FSM for DM
always_ff @(posedge ACLK or negedge ARESETn) begin
  if (!ARESETn) m1_state  <= M1_st_IDLE;
  else m1_state <= m1_next_state;
end

always_comb begin
  case (m1_state)
    M1_st_IDLE:       m1_next_state = ((!CPU_o_DM1_WEB) && (!CPU_o_DM1_CEB))  ? M1_st_WRTAG :
                                      (CPU_o_DM1_WEB && (!CPU_o_DM1_CEB))     ? M1_st_RDTAG : M1_st_IDLE;
    M1_st_RDTAG:      m1_next_state = M1_st_RDCHECK;
    M1_st_RDCHECK:    m1_next_state = L1C_data_m1_hit ? M1_st_RDCACHE : M1_st_AR;
    M1_st_RDCACHE:    m1_next_state = M1_st_CACHETOCPU;
    M1_st_CACHETOCPU: m1_next_state = M1_st_IDLE;
    M1_st_AR:         m1_next_state = (ARVALID_M1 && ARREADY_M1) ? M1_st_R_wait  : M1_st_AR;
    M1_st_R_wait:     m1_next_state = RVALID_M1 ? M1_st_R_HS  : M1_st_R_wait;
    M1_st_R_HS:       m1_next_state = (RVALID_M1 && RREADY_M1) ? M1_st_R : M1_st_R_HS;
    M1_st_R:          m1_next_state = RLAST_M1_latch  ? M1_st_RDUPCACHE  : M1_st_R_HS;
    M1_st_RDUPCACHE:  m1_next_state = M1_st_SRAMTOCPU;
    M1_st_SRAMTOCPU:  m1_next_state = M1_st_IDLE;
    M1_st_WRTAG:      m1_next_state = M1_st_WRCHECK;
    M1_st_WRCHECK:    m1_next_state = L1C_data_m1_hit ? M1_st_WRCACHE : M1_st_AW;
    M1_st_WRCACHE:    m1_next_state = M1_st_AW;
    M1_st_AW:         m1_next_state = (AWVALID_M1 && AWREADY_M1) ? M1_st_W : M1_st_AW;
    M1_st_W:          m1_next_state = (WVALID_M1 && WREADY_M1) ? M1_st_B_HS  : M1_st_W;
    M1_st_B_HS:       m1_next_state = (BVALID_M1 && BREADY_M1) ? M1_st_B : M1_st_B_HS;
    M1_st_B:          m1_next_state = M1_st_IDLE;
    default:          m1_next_state = M1_st_IDLE;
  endcase
end

always_ff @(posedge ACLK or negedge ARESETn) begin
  if      (!ARESETn)        CPU_o_DM1_A_latch <= 32'd0;
  else if (!CPU_o_DM1_CEB)  CPU_o_DM1_A_latch <= {CPU_o_DM1_A, 2'd0};
end

always_ff @(posedge ACLK or negedge ARESETn) begin
  if (!ARESETn) begin
    CPU_o_DM1_DI_latch    <= 32'd0;
    CPU_o_DM1_BWEB_latch  <= 32'd0;
  end
  else if (!CPU_o_DM1_WEB) begin
    CPU_o_DM1_DI_latch    <= CPU_o_DM1_DI;
    CPU_o_DM1_BWEB_latch  <= CPU_o_DM1_BWEB;
  end
end

always_ff @(posedge ACLK or negedge ARESETn) begin
  if (!ARESETn) begin
    RDATA_M1_latch  <= 128'd0;
    RLAST_M1_latch  <= 1'b0;
    RDATA_M1_count     <= 2'd0;
  end
  else if (RVALID_M1 && RREADY_M1) begin
    case (RDATA_M1_count)
      2'd0: RDATA_M1_latch[31:0]    <= RDATA_M1;
      2'd1: RDATA_M1_latch[63:32]   <= RDATA_M1;
      2'd2: RDATA_M1_latch[95:64]   <= RDATA_M1;
      2'd3: RDATA_M1_latch[127:96]  <= RDATA_M1;
    endcase
    RLAST_M1_latch  <= RLAST_M1;
    RDATA_M1_count  <= RDATA_M1_count + 2'd1;
  end
end

always_ff @(posedge ACLK or negedge ARESETn) begin
  if      (!ARESETn)                BRESP_M1_latch  <= 2'd0;
  else if (BVALID_M1 && BREADY_M1)  BRESP_M1_latch  <= BRESP_M1;
end

// AXI interface
assign  AWID_M1     = `AXI_ID_BITS'd0;
assign  AWADDR_M1   = (m1_state == M1_st_AW)  ? CPU_o_DM1_A_latch  : `AXI_ADDR_BITS'd0;
assign  AWLEN_M1    = `AXI_LEN_BITS'd0;
assign  AWSIZE_M1   = `AXI_SIZE_WORD;
assign  AWBURST_M1  = `AXI_BURST_INC;
assign  AWVALID_M1  = (m1_state == M1_st_AW);

assign  WDATA_M1    = (m1_state == M1_st_W) ? CPU_o_DM1_DI_latch  : `AXI_DATA_BITS'd0;
assign  WSTRB_M1[0] = (m1_state == M1_st_W) ? (&CPU_o_DM1_BWEB_latch[7:0])    : 1'b1;
assign  WSTRB_M1[1] = (m1_state == M1_st_W) ? (&CPU_o_DM1_BWEB_latch[15:8])   : 1'b1;
assign  WSTRB_M1[2] = (m1_state == M1_st_W) ? (&CPU_o_DM1_BWEB_latch[23:16])  : 1'b1;
assign  WSTRB_M1[3] = (m1_state == M1_st_W) ? (&CPU_o_DM1_BWEB_latch[31:24])  : 1'b1;
assign  WLAST_M1    = (m1_state == M1_st_W);
assign  WVALID_M1   = (m1_state == M1_st_W);

assign  BREADY_M1   = (m1_state == M1_st_B_HS);

assign  ARID_M1     = `AXI_ID_BITS'd0;
assign  ARADDR_M1   = (m1_state == M1_st_AR)  ? {CPU_o_DM1_A_latch[31:4], 4'd0}  : 32'd0;
assign  ARLEN_M1    = `AXI_LEN_BITS'd3;
assign  ARSIZE_M1   = `AXI_SIZE_WORD;
assign  ARBURST_M1  = `AXI_BURST_INC;
assign  ARVALID_M1  = (m1_state == M1_st_AR);

assign  RREADY_M1   = (m1_state == M1_st_R_HS);

// to CPU
always_comb begin
  case ({CPU_o_DM1_A_latch[3:2], m1_state})
    {2'b00, M1_st_CACHETOCPU}:  DM1_DO  = L1C_data_DA_DO[31:0];
    {2'b01, M1_st_CACHETOCPU}:  DM1_DO  = L1C_data_DA_DO[63:32];
    {2'b10, M1_st_CACHETOCPU}:  DM1_DO  = L1C_data_DA_DO[95:64];
    {2'b11, M1_st_CACHETOCPU}:  DM1_DO  = L1C_data_DA_DO[127:96];
    {2'b00, M1_st_SRAMTOCPU}:   DM1_DO  = RDATA_M1_latch[31:0];
    {2'b01, M1_st_SRAMTOCPU}:   DM1_DO  = RDATA_M1_latch[63:32];
    {2'b10, M1_st_SRAMTOCPU}:   DM1_DO  = RDATA_M1_latch[95:64];
    {2'b11, M1_st_SRAMTOCPU}:   DM1_DO  = RDATA_M1_latch[127:96];
    default:                    DM1_DO  = 32'd0;
  endcase
end

L1C_data u0_L1C_data (
  .clk            (ACLK                 ),
  .rst            (rst                  ),
  .i_m1_state     (m1_state             ),
  .i_CPU_A        (CPU_o_DM1_A_latch    ),
  .i_CPU_DI       (CPU_o_DM1_DI_latch   ),
  .i_CPU_BWEB     (CPU_o_DM1_BWEB_latch ),
  .i_CPUW_RDATA   (RDATA_M1_latch       ),
  .o_m1_hit       (L1C_data_m1_hit      ),
  .o_DA_DO        (L1C_data_DA_DO       )
);

endmodule
