//`include "../include/AXI_define.svh"
//`include "DMA_wrapper_S.sv"
//`include "DMA.sv"
//`include "DMA_wrapper_M.sv"
module DMA_wrapper(
  input                               ACLK,
  input                               ARESETn,
  output  logic                       INTR,

//**********DMA_wrapper_S
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
  input   logic                       RREADY_S,

//**************DMA_wrapper_M
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

// Outputs from DMA_wrapper_S
logic [`AXI_DATA_BITS-1:0]  DMA_wrapper_S_o_DMAEN;
logic [`AXI_DATA_BITS-1:0]  DMA_wrapper_S_o_DMASRC;
logic [`AXI_DATA_BITS-1:0]  DMA_wrapper_S_o_DMADST;
logic [`AXI_DATA_BITS-1:0]  DMA_wrapper_S_o_DMALEN;

// Outputs from DMA
logic                       DMA_o_READ;
logic [`AXI_ADDR_BITS-1:0]  DMA_o_ARADDR;
logic [`AXI_LEN_BITS-1:0]   DMA_o_ARLEN;
logic                       DMA_o_WRITE;
logic [`AXI_ADDR_BITS-1:0]  DMA_o_AWADDR;
logic [`AXI_LEN_BITS-1:0]   DMA_o_AWLEN;
logic                       DMA_o_WNEW;
logic [`AXI_DATA_BITS-1:0]  DMA_o_WDATA;
logic                       DMA_o_WLAST;

// Outputs from DMA_wrapper_M
logic                       DMA_wrapper_M_o_AR_HS;
logic                       DMA_wrapper_M_o_AW_HS;
logic                       DMA_wrapper_M_o_W_HS;
logic                       DMA_wrapper_M_o_RNEW;
logic [`AXI_DATA_BITS-1:0]  DMA_wrapper_M_o_RDATA;
logic                       DMA_wrapper_M_o_wr_idle;

// DMA_wrapper_S is for setting register value
DMA_wrapper_S u0_DMA_wrapper_S (
  .ACLK         (ACLK                           ),
  .ARESETn      (ARESETn                        ),
  .INTR         (INTR                           ),
  //WRITE ADDRESS
  .AWID_S       (AWID_S                         ),
  .AWADDR_S     (AWADDR_S                       ),
  .AWLEN_S      (AWLEN_S                        ),
  .AWSIZE_S     (AWSIZE_S                       ),
  .AWBURST_S    (AWBURST_S                      ),
  .AWVALID_S    (AWVALID_S                      ),
  .AWREADY_S    (AWREADY_S                      ),
  //WRITE DATA
  .WDATA_S      (WDATA_S                        ),
  .WSTRB_S      (WSTRB_S                        ),
  .WLAST_S      (WLAST_S                        ),
  .WVALID_S     (WVALID_S                       ),
  .WREADY_S     (WREADY_S                       ),
  //WRITE RESPONSE
  .BID_S        (BID_S                          ),
  .BRESP_S      (BRESP_S                        ),
  .BVALID_S     (BVALID_S                       ),
  .BREADY_S     (BREADY_S                       ),
  //READ ADDRESS
  .ARID_S       (ARID_S                         ),
  .ARADDR_S     (ARADDR_S                       ),
  .ARLEN_S      (ARLEN_S                        ),
  .ARSIZE_S     (ARSIZE_S                       ),
  .ARBURST_S    (ARBURST_S                      ),
  .ARVALID_S    (ARVALID_S                      ),
  .ARREADY_S    (ARREADY_S                      ),
  //READ DATA
  .RID_S        (RID_S                          ),
  .RDATA_S      (RDATA_S                        ),
  .RRESP_S      (RRESP_S                        ),
  .RLAST_S      (RLAST_S                        ),
  .RVALID_S     (RVALID_S                       ),
  .RREADY_S     (RREADY_S                       ),
  // Registers
  .DMAEN        (DMA_wrapper_S_o_DMAEN          ),
  .DMASRC       (DMA_wrapper_S_o_DMASRC         ),
  .DMADST       (DMA_wrapper_S_o_DMADST         ),
  .DMALEN       (DMA_wrapper_S_o_DMALEN         )
);

// DMA acts depends on register value
DMA u0_DMA (
  .ACLK         (ACLK                           ),
  .ARESETn      (ARESETn                        ),
  .INTR         (INTR                           ),
  // inputs from wrapper_s
  .i_DMAEN      (DMA_wrapper_S_o_DMAEN          ),
  .i_DMASRC     (DMA_wrapper_S_o_DMASRC         ),
  .i_DMADST     (DMA_wrapper_S_o_DMADST         ),
  .i_DMALEN     (DMA_wrapper_S_o_DMALEN         ),
  // inputs from wrapper_m
  .i_M_AR_HS    (DMA_wrapper_M_o_AR_HS          ),
  .i_M_AW_HS    (DMA_wrapper_M_o_AW_HS          ),
  .i_M_W_HS     (DMA_wrapper_M_o_W_HS           ),
  .i_RNEW       (DMA_wrapper_M_o_RNEW           ),
  .i_RDATA      (DMA_wrapper_M_o_RDATA          ),
  .i_wr_idle    (DMA_wrapper_M_o_wr_idle        ),
  // outputs for wrapper_m reading
  .o_READ       (DMA_o_READ                     ),
  .o_ARADDR     (DMA_o_ARADDR                   ),
  .o_ARLEN      (DMA_o_ARLEN                    ),
  // outputs for wrapper_m writing
  .o_WRITE      (DMA_o_WRITE                    ),
  .o_AWADDR     (DMA_o_AWADDR                   ),
  .o_AWLEN      (DMA_o_AWLEN                    ),
  // write data phase
  .o_WNEW       (DMA_o_WNEW                     ),
  .o_WDATA      (DMA_o_WDATA                    ),
  .o_WLAST      (DMA_o_WLAST                    )
);

// DMA_wrapper_M is for reading and writing DRAM/SRAM
DMA_wrapper_M u0_DMA_wrapper_M (
  .ACLK            (ACLK                        ),
  .ARESETn         (ARESETn                     ),
  // outputs to DMA
  .o_AR_HS         (DMA_wrapper_M_o_AR_HS       ),
  .o_AW_HS         (DMA_wrapper_M_o_AW_HS       ),
  .o_W_HS          (DMA_wrapper_M_o_W_HS        ),
  .o_DMA_RNEW      (DMA_wrapper_M_o_RNEW        ),
  .o_DMA_RDATA     (DMA_wrapper_M_o_RDATA       ),
  .o_DMA_wr_idle   (DMA_wrapper_M_o_wr_idle     ),
  // inputs from DMA
  .i_DMA_READ      (DMA_o_READ                  ),
  .i_DMA_ARADDR    (DMA_o_ARADDR                ),
  .i_DMA_ARLEN     (DMA_o_ARLEN                 ),
  .i_DMA_WRITE     (DMA_o_WRITE                 ),
  .i_DMA_AWADDR    (DMA_o_AWADDR                ),
  .i_DMA_AWLEN     (DMA_o_AWLEN                 ),
  .i_DMA_WNEW      (DMA_o_WNEW                  ),
  .i_DMA_WDATA     (DMA_o_WDATA                 ),
  .i_DMA_WLAST     (DMA_o_WLAST                 ),
  //WRITE ADDRESS
  .AWID_M          (AWID_M                      ),
  .AWADDR_M        (AWADDR_M                    ),
  .AWLEN_M         (AWLEN_M                     ),
  .AWSIZE_M        (AWSIZE_M                    ),
  .AWBURST_M       (AWBURST_M                   ),
  .AWVALID_M       (AWVALID_M                   ),
  .AWREADY_M       (AWREADY_M                   ),
  //WRITE DATA
  .WDATA_M         (WDATA_M                     ),
  .WSTRB_M         (WSTRB_M                     ),
  .WLAST_M         (WLAST_M                     ),
  .WVALID_M        (WVALID_M                    ),
  .WREADY_M        (WREADY_M                    ),
  //WRITE RESPONSE
  .BID_M           (BID_M                       ),
  .BRESP_M         (BRESP_M                     ),
  .BVALID_M        (BVALID_M                    ),
  .BREADY_M        (BREADY_M                    ),
  //READ ADDRESS1
  .ARID_M          (ARID_M                      ),
  .ARADDR_M        (ARADDR_M                    ),
  .ARLEN_M         (ARLEN_M                     ),
  .ARSIZE_M        (ARSIZE_M                    ),
  .ARBURST_M       (ARBURST_M                   ),
  .ARVALID_M       (ARVALID_M                   ),
  .ARREADY_M       (ARREADY_M                   ),
  //READ DATA1
  .RID_M           (RID_M                       ),
  .RDATA_M         (RDATA_M                     ),
  .RRESP_M         (RRESP_M                     ),
  .RLAST_M         (RLAST_M                     ),
  .RVALID_M        (RVALID_M                    ),
  .RREADY_M        (RREADY_M                    )
);

endmodule