module top(
    //system signals
    input  logic                        cpu_clk,
    input  logic                        axi_clk,
    input  logic                        rom_clk,
    input  logic                        dram_clk,
    input  logic                        cpu_rst,
    input  logic                        axi_rst,
    input  logic                        rom_rst,
    input  logic                        dram_rst,
    // Connect with ROM
    input  logic [`AXI_DATA_BITS-1:0]   ROM_out,
    output logic                        ROM_read,
    output logic                        ROM_enable,
    output logic [11:0]                 ROM_address,
    // Connect with DRAM
    input  logic [`AXI_DATA_BITS-1:0]   DRAM_Q,
    input  logic                        DRAM_valid,
    output logic                        DRAM_CSn,
    output logic [3:0]                  DRAM_WEn,
    output logic                        DRAM_RASn,
    output logic                        DRAM_CASn,
    output logic [10:0]                 DRAM_A,
    output logic [`AXI_DATA_BITS-1:0]   DRAM_D,
    output logic                        layer_done
//	output logic 						layer1_done,
//	output logic 						layer2_done,
//	output logic 						layer3_done,
//	output logic 						layer4_done,
//	output logic 						layer5_done,
//	output logic 						layer6_done
);

logic                               intr_wdt;
logic                               intr_dma;
logic                               intr_epu;
logic                               cpu_rstn;
logic                               axi_rstn;
logic                               rom_rstn;
logic                               dram_rstn;
logic                               WTO;

//////// SLAVE INTERFACE FOR MASTER0(CPU_M0) ////////
//READ ADDRESS0
logic [`AXI_ID_BITS-1:0]            ARID_M0;
logic [`AXI_ADDR_BITS-1:0]          ARADDR_M0;
logic [`AXI_LEN_BITS-1:0]           ARLEN_M0;
logic [`AXI_SIZE_BITS-1:0]          ARSIZE_M0;
logic [1:0]                         ARBURST_M0;
logic                               ARVALID_M0;
logic                               ARREADY_M0;
//READ DATA0
logic [`AXI_ID_BITS-1:0]            RID_M0;
logic [`AXI_DATA_BITS-1:0]          RDATA_M0;
logic [1:0]                         RRESP_M0;
logic                               RLAST_M0;
logic                               RVALID_M0;
logic                               RREADY_M0;

//////// SLAVE INTERFACE FOR MASTER1(CPU_M1) ////////
//WRITE ADDRESS1
logic [`AXI_ID_BITS-1:0]            AWID_M1;
logic [`AXI_ADDR_BITS-1:0]          AWADDR_M1;
logic [`AXI_LEN_BITS-1:0]           AWLEN_M1;
logic [`AXI_SIZE_BITS-1:0]          AWSIZE_M1;
logic [1:0]                         AWBURST_M1;
logic                               AWVALID_M1;
logic                               AWREADY_M1;
//WRITE DATA1
logic [`AXI_DATA_BITS-1:0]          WDATA_M1;
logic [`AXI_STRB_BITS-1:0]          WSTRB_M1;
logic                               WLAST_M1;
logic                               WVALID_M1;
logic                               WREADY_M1;
//WRITE RESPONSE1
logic [`AXI_ID_BITS-1:0]            BID_M1;
logic [1:0]                         BRESP_M1;
logic                               BVALID_M1;
logic                               BREADY_M1;
//READ ADDRESS1
logic [`AXI_ID_BITS-1:0]            ARID_M1;
logic [`AXI_ADDR_BITS-1:0]          ARADDR_M1;
logic [`AXI_LEN_BITS-1:0]           ARLEN_M1;
logic [`AXI_SIZE_BITS-1:0]          ARSIZE_M1;
logic [1:0]                         ARBURST_M1;
logic                               ARVALID_M1;
logic                               ARREADY_M1;
//READ DATA1
logic [`AXI_ID_BITS-1:0]            RID_M1;
logic [`AXI_DATA_BITS-1:0]          RDATA_M1;
logic [1:0]                         RRESP_M1;
logic                               RLAST_M1;
logic                               RVALID_M1;
logic                               RREADY_M1;

//////// SLAVE INTERFACE FOR MASTER2(DMA) ////////
//WRITE ADDRESS2 
logic [`AXI_ID_BITS-1:0]            AWID_M2;
logic [`AXI_ADDR_BITS-1:0]          AWADDR_M2;
logic [`AXI_LEN_BITS-1:0]           AWLEN_M2;
logic [`AXI_SIZE_BITS-1:0]          AWSIZE_M2;
logic [1:0]                         AWBURST_M2;
logic                               AWVALID_M2;
logic                               AWREADY_M2;
//WRITE DATA2 
logic [`AXI_DATA_BITS-1:0]          WDATA_M2;
logic [`AXI_STRB_BITS-1:0]          WSTRB_M2;
logic                               WLAST_M2;
logic                               WVALID_M2;
logic                               WREADY_M2;
//WRITE RESPONSE2 
logic [`AXI_ID_BITS-1:0]            BID_M2;
logic [1:0]                         BRESP_M2;
logic                               BVALID_M2;
logic                               BREADY_M2;
//READ ADDRESS2 
logic [`AXI_ID_BITS-1:0]            ARID_M2;
logic [`AXI_ADDR_BITS-1:0]          ARADDR_M2;
logic [`AXI_LEN_BITS-1:0]           ARLEN_M2;
logic [`AXI_SIZE_BITS-1:0]          ARSIZE_M2;
logic [1:0]                         ARBURST_M2;
logic                               ARVALID_M2;
logic                               ARREADY_M2;
//READ DATA2 
logic [`AXI_ID_BITS-1:0]            RID_M2;
logic [`AXI_DATA_BITS-1:0]          RDATA_M2;
logic [1:0]                         RRESP_M2;
logic                               RLAST_M2;
logic                               RVALID_M2;
logic                               RREADY_M2;

//////// MASTER INTERFACE FOR SLAVES0(ROM) ////////
//WRITE ADDRESS0
//READ ADDRESS0
logic [`AXI_IDS_BITS-1:0]           ARID_S0;
logic [`AXI_ADDR_BITS-1:0]          ARADDR_S0;
logic [`AXI_LEN_BITS-1:0]           ARLEN_S0;
logic [`AXI_SIZE_BITS-1:0]          ARSIZE_S0;
logic [1:0]                         ARBURST_S0;
logic                               ARVALID_S0;
logic                               ARREADY_S0;
//READ DATA0
logic [`AXI_IDS_BITS-1:0]           RID_S0;
logic [`AXI_DATA_BITS-1:0]          RDATA_S0;
logic [1:0]                         RRESP_S0;
logic                               RLAST_S0;
logic                               RVALID_S0;
logic                               RREADY_S0;

//////// MASTER INTERFACE FOR SLAVES1(IM) ////////
//WRITE ADDRESS1
logic [`AXI_IDS_BITS-1:0]           AWID_S1;
logic [`AXI_ADDR_BITS-1:0]          AWADDR_S1;
logic [`AXI_LEN_BITS-1:0]           AWLEN_S1;
logic [`AXI_SIZE_BITS-1:0]          AWSIZE_S1;
logic [1:0]                         AWBURST_S1;
logic                               AWVALID_S1;
logic                               AWREADY_S1;
//WRITE DATA1
logic [`AXI_DATA_BITS-1:0]          WDATA_S1;
logic [`AXI_STRB_BITS-1:0]          WSTRB_S1;
logic                               WLAST_S1;
logic                               WVALID_S1;
logic                               WREADY_S1;
//WRITE RESPONSE1
logic [`AXI_IDS_BITS-1:0]           BID_S1;
logic [1:0]                         BRESP_S1;
logic                               BVALID_S1;
logic                               BREADY_S1;
//READ ADDRESS1
logic [`AXI_IDS_BITS-1:0]           ARID_S1;
logic [`AXI_ADDR_BITS-1:0]          ARADDR_S1;
logic [`AXI_LEN_BITS-1:0]           ARLEN_S1;
logic [`AXI_SIZE_BITS-1:0]          ARSIZE_S1;
logic [1:0]                         ARBURST_S1;
logic                               ARVALID_S1;
logic                               ARREADY_S1;
//READ DATA1
logic [`AXI_IDS_BITS-1:0]           RID_S1;
logic [`AXI_DATA_BITS-1:0]          RDATA_S1;
logic [1:0]                         RRESP_S1;
logic                               RLAST_S1;
logic                               RVALID_S1;
logic                               RREADY_S1;

//////// MASTER INTERFACE FOR SLAVES2(DM) ////////
//WRITE ADDRESS2 
logic [`AXI_IDS_BITS-1:0]           AWID_S2;
logic [`AXI_ADDR_BITS-1:0]          AWADDR_S2;
logic [`AXI_LEN_BITS-1:0]           AWLEN_S2;
logic [`AXI_SIZE_BITS-1:0]          AWSIZE_S2;
logic [1:0]                         AWBURST_S2;
logic                               AWVALID_S2;
logic                               AWREADY_S2;
//WRITE DATA2 
logic [`AXI_DATA_BITS-1:0]          WDATA_S2;
logic [`AXI_STRB_BITS-1:0]          WSTRB_S2;
logic                               WLAST_S2;
logic                               WVALID_S2;
logic                               WREADY_S2;
//WRITE RESPONSE2 
logic [`AXI_IDS_BITS-1:0]           BID_S2;
logic [1:0]                         BRESP_S2;
logic                               BVALID_S2;
logic                               BREADY_S2;
//READ ADDRESS2 
logic [`AXI_IDS_BITS-1:0]           ARID_S2;
logic [`AXI_ADDR_BITS-1:0]          ARADDR_S2;
logic [`AXI_LEN_BITS-1:0]           ARLEN_S2;
logic [`AXI_SIZE_BITS-1:0]          ARSIZE_S2;
logic [1:0]                         ARBURST_S2;
logic                               ARVALID_S2;
logic                               ARREADY_S2;
//READ DATA2
logic [`AXI_IDS_BITS-1:0]           RID_S2;
logic [`AXI_DATA_BITS-1:0]          RDATA_S2;
logic [1:0]                         RRESP_S2;
logic                               RLAST_S2;
logic                               RVALID_S2;
logic                               RREADY_S2;

//////// MASTER INTERFACE FOR SLAVES3(DMA) ////////
//WRITE ADDRESS3 
logic [`AXI_IDS_BITS-1:0]           AWID_S3;
logic [`AXI_ADDR_BITS-1:0]          AWADDR_S3;
logic [`AXI_LEN_BITS-1:0]           AWLEN_S3;
logic [`AXI_SIZE_BITS-1:0]          AWSIZE_S3;
logic [1:0]                         AWBURST_S3;
logic                               AWVALID_S3;
logic                               AWREADY_S3;
//WRITE DATA3 
logic [`AXI_DATA_BITS-1:0]          WDATA_S3;
logic [`AXI_STRB_BITS-1:0]          WSTRB_S3;
logic                               WLAST_S3;
logic                               WVALID_S3;
logic                               WREADY_S3;
//WRITE RESPONSE3 
logic [`AXI_IDS_BITS-1:0]           BID_S3;
logic [1:0]                         BRESP_S3;
logic                               BVALID_S3;
logic                               BREADY_S3;
//READ ADDRESS3 
logic [`AXI_IDS_BITS-1:0]           ARID_S3;
logic [`AXI_ADDR_BITS-1:0]          ARADDR_S3;
logic [`AXI_LEN_BITS-1:0]           ARLEN_S3;
logic [`AXI_SIZE_BITS-1:0]          ARSIZE_S3;
logic [1:0]                         ARBURST_S3;
logic                               ARVALID_S3;
logic                               ARREADY_S3;
//READ DATA3
logic [`AXI_IDS_BITS-1:0]           RID_S3;
logic [`AXI_DATA_BITS-1:0]          RDATA_S3;
logic [1:0]                         RRESP_S3;
logic                               RLAST_S3;
logic                               RVALID_S3;
logic                               RREADY_S3;

//////// MASTER INTERFACE FOR SLAVES4(WDT) ////////
//WRITE ADDRESS4 
logic [`AXI_IDS_BITS-1:0]           AWID_S4;
logic [`AXI_ADDR_BITS-1:0]          AWADDR_S4;
logic [`AXI_LEN_BITS-1:0]           AWLEN_S4;
logic [`AXI_SIZE_BITS-1:0]          AWSIZE_S4;
logic [1:0]                         AWBURST_S4;
logic                               AWVALID_S4;
logic                               AWREADY_S4;
//WRITE DATA4 
logic [`AXI_DATA_BITS-1:0]          WDATA_S4;
logic [`AXI_STRB_BITS-1:0]          WSTRB_S4;
logic                               WLAST_S4;
logic                               WVALID_S4;
logic                               WREADY_S4;
//WRITE RESPONSE4 
logic [`AXI_IDS_BITS-1:0]           BID_S4;
logic [1:0]                         BRESP_S4;
logic                               BVALID_S4;
logic                               BREADY_S4;

//////// MASTER INTERFACE FOR SLAVES5(DRAM) ////////
//WRITE ADDRESS5 
logic [`AXI_IDS_BITS-1:0]           AWID_S5;
logic [`AXI_ADDR_BITS-1:0]          AWADDR_S5;
logic [`AXI_LEN_BITS-1:0]           AWLEN_S5;
logic [`AXI_SIZE_BITS-1:0]          AWSIZE_S5;
logic [1:0]                         AWBURST_S5;
logic                               AWVALID_S5;
logic                               AWREADY_S5;
//WRITE DATA5 
logic [`AXI_DATA_BITS-1:0]          WDATA_S5;
logic [`AXI_STRB_BITS-1:0]          WSTRB_S5;
logic                               WLAST_S5;
logic                               WVALID_S5;
logic                               WREADY_S5;
//WRITE RESPONSE5 
logic [`AXI_IDS_BITS-1:0]           BID_S5;
logic [1:0]                         BRESP_S5;
logic                               BVALID_S5;
logic                               BREADY_S5;
//READ ADDRESS5 
logic [`AXI_IDS_BITS-1:0]           ARID_S5;
logic [`AXI_ADDR_BITS-1:0]          ARADDR_S5;
logic [`AXI_LEN_BITS-1:0]           ARLEN_S5;
logic [`AXI_SIZE_BITS-1:0]          ARSIZE_S5;
logic [1:0]                         ARBURST_S5;
logic                               ARVALID_S5;
logic                               ARREADY_S5;
//READ DATA5
logic [`AXI_IDS_BITS-1:0]           RID_S5;
logic [`AXI_DATA_BITS-1:0]          RDATA_S5;
logic [1:0]                         RRESP_S5;
logic                               RLAST_S5;
logic                               RVALID_S5;
logic                               RREADY_S5;

//////// MASTER INTERFACE FOR SLAVES6(EPU) ////////
//WRITE ADDRESS6 
logic [`AXI_IDS_BITS-1:0]           AWID_S6;
logic [`AXI_ADDR_BITS-1:0]          AWADDR_S6;
logic [`AXI_LEN_BITS-1:0]           AWLEN_S6;
logic [`AXI_SIZE_BITS-1:0]          AWSIZE_S6;
logic [1:0]                         AWBURST_S6;
logic                               AWVALID_S6;
logic                               AWREADY_S6;
//WRITE DATA6 
logic [`AXI_DATA_BITS-1:0]          WDATA_S6;
logic [`AXI_STRB_BITS-1:0]          WSTRB_S6;
logic                               WLAST_S6;
logic                               WVALID_S6;
logic                               WREADY_S6;
//WRITE RESPONSE6 
logic [`AXI_IDS_BITS-1:0]           BID_S6;
logic [1:0]                         BRESP_S6;
logic                               BVALID_S6;
logic                               BREADY_S6;
//READ ADDRESS6 
logic [`AXI_IDS_BITS-1:0]           ARID_S6;
logic [`AXI_ADDR_BITS-1:0]          ARADDR_S6;
logic [`AXI_LEN_BITS-1:0]           ARLEN_S6;
logic [`AXI_SIZE_BITS-1:0]          ARSIZE_S6;
logic [1:0]                         ARBURST_S6;
logic                               ARVALID_S6;
logic                               ARREADY_S6;
//READ DATA6
logic [`AXI_IDS_BITS-1:0]           RID_S6;
logic [`AXI_DATA_BITS-1:0]          RDATA_S6;
logic [1:0]                         RRESP_S6;
logic                               RLAST_S6;
logic                               RVALID_S6;
logic                               RREADY_S6;

//////// MASTER/SLAVE INTERFACE FOR AXI ////////
// AXI READ ADDRESS
logic AXI_ARVALID_M0, AXI_ARVALID_M1, AXI_ARVALID_M2;
logic AXI_ARVALID_S0, AXI_ARVALID_S1, AXI_ARVALID_S2, AXI_ARVALID_S3, AXI_ARVALID_S5, AXI_ARVALID_S6; 
logic AXI_ARREADY_M0, AXI_ARREADY_M1, AXI_ARREADY_M2;
logic AXI_ARREADY_S0, AXI_ARREADY_S1, AXI_ARREADY_S2, AXI_ARREADY_S3, AXI_ARREADY_S5, AXI_ARREADY_S6;
// AXI READ DATA
logic AXI_RVALID_M0, AXI_RVALID_M1, AXI_RVALID_M2;
logic AXI_RVALID_S0, AXI_RVALID_S1, AXI_RVALID_S2, AXI_RVALID_S3, AXI_RVALID_S5, AXI_RVALID_S6; 
logic AXI_RREADY_M0, AXI_RREADY_M1, AXI_RREADY_M2;
logic AXI_RREADY_S0, AXI_RREADY_S1, AXI_RREADY_S2, AXI_RREADY_S3, AXI_RREADY_S5, AXI_RREADY_S6;
// AXI WRITE ADDRESS
logic AXI_AWVALID_M1, AXI_AWVALID_M2;
logic AXI_AWVALID_S1, AXI_AWVALID_S2, AXI_AWVALID_S3, AXI_AWVALID_S4, AXI_AWVALID_S5, AXI_AWVALID_S6; 
logic AXI_AWREADY_M1, AXI_AWREADY_M2;
logic AXI_AWREADY_S1, AXI_AWREADY_S2, AXI_AWREADY_S3, AXI_AWREADY_S4, AXI_AWREADY_S5, AXI_AWREADY_S6;
// AXI WRITE DATA
logic AXI_WVALID_M1, AXI_WVALID_M2;
logic AXI_WVALID_S1, AXI_WVALID_S2, AXI_WVALID_S3, AXI_WVALID_S4, AXI_WVALID_S5, AXI_WVALID_S6; 
logic AXI_WREADY_M1, AXI_WREADY_M2;
logic AXI_WREADY_S1, AXI_WREADY_S2, AXI_WREADY_S3, AXI_WREADY_S4, AXI_WREADY_S5, AXI_WREADY_S6;
// AXI WRITE RESPONSE
logic AXI_BVALID_M1, AXI_BWVALID_M2;
logic AXI_BVALID_S1, AXI_BWVALID_S2, AXI_BVALID_S3, AXI_BVALID_S4, AXI_BVALID_S5, AXI_BVALID_S6; 
logic AXI_BREADY_M1, AXI_BWREADY_M2;
logic AXI_BREADY_S1, AXI_BWREADY_S2, AXI_BREADY_S3, AXI_BREADY_S4, AXI_BREADY_S5, AXI_BREADY_S6;

//////////////   CDC signals   //////////////
// FIFO_M0_AXI
logic [48:0]                        ARFIFO_M0 , ARFIFO_M0_AXI;
logic [42:0]                        RFIFO_M0  , RFIFO_M0_AXI;
// FIFO_M1_AXI
logic [48:0]                        ARFIFO_M1 , ARFIFO_M1_AXI;
logic [42:0]                        RFIFO_M1  , RFIFO_M1_AXI;
logic [48:0]                        AWFIFO_M1 , AWFIFO_M1_AXI;
logic [36:0]                        WFIFO_M1  , WFIFO_M1_AXI;
logic [ 9:0]                        BFIFO_M1  , BFIFO_M1_AXI;
// FIFO_M2_AXI
logic [48:0]                        ARFIFO_M2 , ARFIFO_M2_AXI;
logic [42:0]                        RFIFO_M2  , RFIFO_M2_AXI;
logic [48:0]                        AWFIFO_M2 , AWFIFO_M2_AXI;
logic [36:0]                        WFIFO_M2  , WFIFO_M2_AXI;
logic [ 9:0]                        BFIFO_M2  , BFIFO_M2_AXI;
// FIFO_AXI_S0
logic [48:0]                        ARFIFO_S0 , ARFIFO_AXI_S0;
logic [42:0]                        RFIFO_S0  , RFIFO_AXI_S0;
// FIFO_AXI_S1
logic [48:0]                        ARFIFO_S1 , ARFIFO_AXI_S1;
logic [42:0]                        RFIFO_S1  , RFIFO_AXI_S1;
logic [48:0]                        AWFIFO_S1 , AWFIFO_AXI_S1;
logic [36:0]                        WFIFO_S1  , WFIFO_AXI_S1;
logic [ 9:0]                        BFIFO_S1  , BFIFO_AXI_S1;
// FIFO_AXI_S2
logic [48:0]                        ARFIFO_S2 , ARFIFO_AXI_S2;
logic [42:0]                        RFIFO_S2  , RFIFO_AXI_S2;
logic [48:0]                        AWFIFO_S2 , AWFIFO_AXI_S2;
logic [36:0]                        WFIFO_S2  , WFIFO_AXI_S2;
logic [ 9:0]                        BFIFO_S2  , BFIFO_AXI_S2;
// FIFO_AXI_S3
logic [48:0]                        ARFIFO_S3 , ARFIFO_AXI_S3;
logic [42:0]                        RFIFO_S3  , RFIFO_AXI_S3;
logic [48:0]                        AWFIFO_S3 , AWFIFO_AXI_S3;
logic [36:0]                        WFIFO_S3  , WFIFO_AXI_S3;
logic [ 9:0]                        BFIFO_S3  , BFIFO_AXI_S3;
// FIFO_AXI_S4
logic [48:0]                        AWFIFO_S4 , AWFIFO_AXI_S4;
logic [36:0]                        WFIFO_S4  , WFIFO_AXI_S4;
logic [ 9:0]                        BFIFO_S4  , BFIFO_AXI_S4;
// FIFO_AXI_S5
logic [48:0]                        ARFIFO_S5 , ARFIFO_AXI_S5;
logic [42:0]                        RFIFO_S5  , RFIFO_AXI_S5;
logic [48:0]                        AWFIFO_S5 , AWFIFO_AXI_S5;
logic [36:0]                        WFIFO_S5  , WFIFO_AXI_S5;
logic [ 9:0]                        BFIFO_S5  , BFIFO_AXI_S5;
// FIFO_AXI_S6
logic [48:0]                        ARFIFO_S6 , ARFIFO_AXI_S6;
logic [42:0]                        RFIFO_S6  , RFIFO_AXI_S6;
logic [48:0]                        AWFIFO_S6 , AWFIFO_AXI_S6;
logic [36:0]                        WFIFO_S6  , WFIFO_AXI_S6;
logic [ 9:0]                        BFIFO_S6  , BFIFO_AXI_S6;

// system negedge reset
assign cpu_rstn  = !cpu_rst;
assign axi_rstn  = !axi_rst;
assign rom_rstn  = !rom_rst;
assign dram_rstn = !dram_rst;
// FIFO_M0_AXI
assign ARFIFO_M0     = {4'd0,ARID_M0,ARADDR_M0,ARLEN_M0,ARSIZE_M0,ARBURST_M0};
assign RFIFO_M0_AXI  = {4'd0,RID_M0,RDATA_M0,RRESP_M0,RLAST_M0};
// FIFO_M1_AXI
assign ARFIFO_M1     = {4'd0,ARID_M1,ARADDR_M1,ARLEN_M1,ARSIZE_M1,ARBURST_M1};
assign RFIFO_M1_AXI  = {4'd0,RID_M1,RDATA_M1,RRESP_M1,RLAST_M1};
assign AWFIFO_M1     = {4'd0,AWID_M1,AWADDR_M1,AWLEN_M1,AWSIZE_M1,AWBURST_M1};
assign WFIFO_M1      = {WDATA_M1,WSTRB_M1,WLAST_M1};
assign BFIFO_M1_AXI  = {4'd0,BID_M1, BRESP_M1};
// FIFO_M2_AXI
assign ARFIFO_M2     = {4'd0,ARID_M2,ARADDR_M2,ARLEN_M2,ARSIZE_M2,ARBURST_M2};
assign RFIFO_M2_AXI  = {4'd0,RID_M2,RDATA_M2,RRESP_M2,RLAST_M2};
assign AWFIFO_M2     = {4'd0,AWID_M2,AWADDR_M2,AWLEN_M2,AWSIZE_M2,AWBURST_M2};
assign WFIFO_M2      = {WDATA_M2,WSTRB_M2,WLAST_M2};
assign BFIFO_M2_AXI  = {4'd0,BID_M2, BRESP_M2};
// FIFO_AXI_S0
assign ARFIFO_AXI_S0 = {ARID_S0,ARADDR_S0,ARLEN_S0,ARSIZE_S0,ARBURST_S0};
assign RFIFO_S0      = {RID_S0,RDATA_S0,RRESP_S0,RLAST_S0};
// FIFO_AXI_S1
assign ARFIFO_AXI_S1 = {ARID_S1,ARADDR_S1,ARLEN_S1,ARSIZE_S1,ARBURST_S1};
assign RFIFO_S1      = {RID_S1,RDATA_S1,RRESP_S1,RLAST_S1};
assign AWFIFO_AXI_S1 = {AWID_S1,AWADDR_S1,AWLEN_S1,AWSIZE_S1,AWBURST_S1};
assign WFIFO_AXI_S1  = {WDATA_S1,WSTRB_S1,WLAST_S1};
assign BFIFO_S1      = {BID_S1, BRESP_S1};
// FIFO_AXI_S2
assign ARFIFO_AXI_S2 = {ARID_S2,ARADDR_S2,ARLEN_S2,ARSIZE_S2,ARBURST_S2};
assign RFIFO_S2      = {RID_S2,RDATA_S2,RRESP_S2,RLAST_S2};
assign AWFIFO_AXI_S2 = {AWID_S2,AWADDR_S2,AWLEN_S2,AWSIZE_S2,AWBURST_S2};
assign WFIFO_AXI_S2  = {WDATA_S2,WSTRB_S2,WLAST_S2};
assign BFIFO_S2      = {BID_S2, BRESP_S2};
// FIFO_AXI_S3
assign ARFIFO_AXI_S3 = {ARID_S3,ARADDR_S3,ARLEN_S3,ARSIZE_S3,ARBURST_S3};
assign RFIFO_S3      = {RID_S3,RDATA_S3,RRESP_S3,RLAST_S3};
assign AWFIFO_AXI_S3 = {AWID_S3,AWADDR_S3,AWLEN_S3,AWSIZE_S3,AWBURST_S3};
assign WFIFO_AXI_S3  = {WDATA_S3,WSTRB_S3,WLAST_S3};
assign BFIFO_S3      = {BID_S3, BRESP_S3};
// FIFO_AXI_S4
assign AWFIFO_AXI_S4 = {AWID_S4,AWADDR_S4,AWLEN_S4,AWSIZE_S4,AWBURST_S4};
assign WFIFO_AXI_S4  = {WDATA_S4,WSTRB_S4,WLAST_S4};
assign BFIFO_S4      = {BID_S4, BRESP_S4};
// FIFO_AXI_S5
assign ARFIFO_AXI_S5 = {ARID_S5,ARADDR_S5,ARLEN_S5,ARSIZE_S5,ARBURST_S5};
assign RFIFO_S5      = {RID_S5,RDATA_S5,RRESP_S5,RLAST_S5};
assign AWFIFO_AXI_S5 = {AWID_S5,AWADDR_S5,AWLEN_S5,AWSIZE_S5,AWBURST_S5};
assign WFIFO_AXI_S5  = {WDATA_S5,WSTRB_S5,WLAST_S5};
assign BFIFO_S5      = {BID_S5, BRESP_S5};
// FIFO_AXI_S6
assign ARFIFO_AXI_S6 = {ARID_S6,ARADDR_S6,ARLEN_S6,ARSIZE_S6,ARBURST_S6};
assign RFIFO_S6      = {RID_S6,RDATA_S6,RRESP_S6,RLAST_S6};
assign AWFIFO_AXI_S6 = {AWID_S6,AWADDR_S6,AWLEN_S6,AWSIZE_S6,AWBURST_S6};
assign WFIFO_AXI_S6  = {WDATA_S6,WSTRB_S6,WLAST_S6};
assign BFIFO_S6      = {BID_S6, BRESP_S6};

//////// ======== CDC ======== ////////
//-------- Master0 to AXI --------//
R_CDC M0_AXI(
    .clk            (cpu_clk),
    .rst            (cpu_rst),
    .clk2           (axi_clk),
    .rst2           (axi_rst),
    .AR_rd_en       (AXI_ARREADY_M0),
    .AR_wr_en       (ARVALID_M0),
    .AR_w_data      (ARFIFO_M0),
    .R_rd_en        (RREADY_M0),
    .R_wr_en        (AXI_RVALID_M0),
    .R_w_data       (RFIFO_M0_AXI),

    .AR_not_empty   (AXI_ARVALID_M0),
    .AR_not_full    (ARREADY_M0),
    .AR_r_data      (ARFIFO_M0_AXI),
    .R_not_empty    (RVALID_M0),
    .R_not_full     (AXI_RREADY_M0),
    .R_r_data       (RFIFO_M0)
);
//-------- Master1 to AXI --------//
RW_CDC M1_AXI(
    .clk            (cpu_clk),
    .rst            (cpu_rst),
    .clk2           (axi_clk),
    .rst2           (axi_rst),
    .AR_rd_en       (AXI_ARREADY_M1),
    .AR_wr_en       (ARVALID_M1),
    .AR_w_data      (ARFIFO_M1),
    .R_rd_en        (RREADY_M1),
    .R_wr_en        (AXI_RVALID_M1),
    .R_w_data       (RFIFO_M1_AXI),
    .AW_rd_en       (AXI_AWREADY_M1),
    .AW_wr_en       (AWVALID_M1),
    .AW_w_data      (AWFIFO_M1),
    .W_rd_en        (AXI_WREADY_M1),
    .W_wr_en        (WVALID_M1),
    .W_w_data       (WFIFO_M1),
    .B_rd_en        (BREADY_M1),
    .B_wr_en        (AXI_BVALID_M1),
    .B_w_data       (BFIFO_M1_AXI),

    .AR_not_empty   (AXI_ARVALID_M1),
    .AR_not_full    (ARREADY_M1),
    .AR_r_data      (ARFIFO_M1_AXI),
    .R_not_empty    (RVALID_M1),
    .R_not_full     (AXI_RREADY_M1),
    .R_r_data       (RFIFO_M1),
    .AW_not_empty   (AXI_AWVALID_M1),
    .AW_not_full    (AWREADY_M1),
    .AW_r_data      (AWFIFO_M1_AXI),
    .W_not_empty    (AXI_WVALID_M1),
    .W_not_full     (WREADY_M1),
    .W_r_data       (WFIFO_M1_AXI),
    .B_not_empty    (BVALID_M1),
    .B_not_full     (AXI_BREADY_M1),
    .B_r_data       (BFIFO_M1)
);
//-------- Master2 to AXI --------//
RW_CDC M2_AXI(
    .clk            (cpu_clk),
    .rst            (cpu_rst),
    .clk2           (axi_clk),
    .rst2           (axi_rst),
    .AR_rd_en       (AXI_ARREADY_M2),
    .AR_wr_en       (ARVALID_M2),
    .AR_w_data      (ARFIFO_M2),
    .R_rd_en        (RREADY_M2),
    .R_wr_en        (AXI_RVALID_M2),
    .R_w_data       (RFIFO_M2_AXI),
    .AW_rd_en       (AXI_AWREADY_M2),
    .AW_wr_en       (AWVALID_M2),
    .AW_w_data      (AWFIFO_M2),
    .W_rd_en        (AXI_WREADY_M2),
    .W_wr_en        (WVALID_M2),
    .W_w_data       (WFIFO_M2),
    .B_rd_en        (BREADY_M2),
    .B_wr_en        (AXI_BVALID_M2),
    .B_w_data       (BFIFO_M2_AXI),

    .AR_not_empty   (AXI_ARVALID_M2),
    .AR_not_full    (ARREADY_M2),
    .AR_r_data      (ARFIFO_M2_AXI),
    .R_not_empty    (RVALID_M2),
    .R_not_full     (AXI_RREADY_M2),
    .R_r_data       (RFIFO_M2),
    .AW_not_empty   (AXI_AWVALID_M2),
    .AW_not_full    (AWREADY_M2),
    .AW_r_data      (AWFIFO_M2_AXI),
    .W_not_empty    (AXI_WVALID_M2),
    .W_not_full     (WREADY_M2),
    .W_r_data       (WFIFO_M2_AXI),
    .B_not_empty    (BVALID_M2),
    .B_not_full     (AXI_BREADY_M2),
    .B_r_data       (BFIFO_M2)
);
//-------- AXI to Slave0 --------//
R_CDC AXI_S0(
    .clk            (axi_clk),
    .rst            (axi_rst),
    .clk2           (rom_clk),
    .rst2           (rom_rst),
    .AR_rd_en       (ARREADY_S0),
    .AR_wr_en       (AXI_ARVALID_S0),
    .AR_w_data      (ARFIFO_AXI_S0),
    .R_rd_en        (AXI_RREADY_S0),
    .R_wr_en        (RVALID_S0),
    .R_w_data       (RFIFO_S0),

    .AR_not_empty   (ARVALID_S0),
    .AR_not_full    (AXI_ARREADY_S0),
    .AR_r_data      (ARFIFO_S0),
    .R_not_empty    (AXI_RVALID_S0),
    .R_not_full     (RREADY_S0),
    .R_r_data       (RFIFO_AXI_S0)
);
//-------- AXI to Slave1 --------//
RW_CDC AXI_S1(
    .clk            (axi_clk),
    .rst            (axi_rst),
    .clk2           (cpu_clk),
    .rst2           (cpu_rst),
    .AR_rd_en       (ARREADY_S1),
    .AR_wr_en       (AXI_ARVALID_S1),
    .AR_w_data      (ARFIFO_AXI_S1),
    .R_rd_en        (AXI_RREADY_S1),
    .R_wr_en        (RVALID_S1),
    .R_w_data       (RFIFO_S1),
    .AW_rd_en       (AWREADY_S1),
    .AW_wr_en       (AXI_AWVALID_S1),
    .AW_w_data      (AWFIFO_AXI_S1),
    .W_rd_en        (WREADY_S1),
    .W_wr_en        (AXI_WVALID_S1),
    .W_w_data       (WFIFO_AXI_S1),
    .B_rd_en        (AXI_BREADY_S1),
    .B_wr_en        (BVALID_S1),
    .B_w_data       (BFIFO_S1),

    .AR_not_empty   (ARVALID_S1),
    .AR_not_full    (AXI_ARREADY_S1),
    .AR_r_data      (ARFIFO_S1),
    .R_not_empty    (AXI_RVALID_S1),
    .R_not_full     (RREADY_S1),
    .R_r_data       (RFIFO_AXI_S1),
    .AW_not_empty   (AWVALID_S1),
    .AW_not_full    (AXI_AWREADY_S1),
    .AW_r_data      (AWFIFO_S1),
    .W_not_empty    (WVALID_S1),
    .W_not_full     (AXI_WREADY_S1),
    .W_r_data       (WFIFO_S1),
    .B_not_empty    (AXI_BVALID_S1),
    .B_not_full     (BREADY_S1),
    .B_r_data       (BFIFO_AXI_S1)
);
//-------- AXI to Slave2 --------//
RW_CDC AXI_S2(
    .clk            (axi_clk),
    .rst            (axi_rst),
    .clk2           (cpu_clk),
    .rst2           (cpu_rst),
    .AR_rd_en       (ARREADY_S2),
    .AR_wr_en       (AXI_ARVALID_S2),
    .AR_w_data      (ARFIFO_AXI_S2),
    .R_rd_en        (AXI_RREADY_S2),
    .R_wr_en        (RVALID_S2),
    .R_w_data       (RFIFO_S2),
    .AW_rd_en       (AWREADY_S2),
    .AW_wr_en       (AXI_AWVALID_S2),
    .AW_w_data      (AWFIFO_AXI_S2),
    .W_rd_en        (WREADY_S2),
    .W_wr_en        (AXI_WVALID_S2),
    .W_w_data       (WFIFO_AXI_S2),
    .B_rd_en        (AXI_BREADY_S2),
    .B_wr_en        (BVALID_S2),
    .B_w_data       (BFIFO_S2),

    .AR_not_empty   (ARVALID_S2),
    .AR_not_full    (AXI_ARREADY_S2),
    .AR_r_data      (ARFIFO_S2),
    .R_not_empty    (AXI_RVALID_S2),
    .R_not_full     (RREADY_S2),
    .R_r_data       (RFIFO_AXI_S2),
    .AW_not_empty   (AWVALID_S2),
    .AW_not_full    (AXI_AWREADY_S2),
    .AW_r_data      (AWFIFO_S2),
    .W_not_empty    (WVALID_S2),
    .W_not_full     (AXI_WREADY_S2),
    .W_r_data       (WFIFO_S2),
    .B_not_empty    (AXI_BVALID_S2),
    .B_not_full     (BREADY_S2),
    .B_r_data       (BFIFO_AXI_S2)
);
//-------- AXI to Slave3 --------//
RW_CDC AXI_S3(
    .clk            (axi_clk),
    .rst            (axi_rst),
    .clk2           (cpu_clk),
    .rst2           (cpu_rst),
    .AR_rd_en       (ARREADY_S3),
    .AR_wr_en       (AXI_ARVALID_S3),
    .AR_w_data      (ARFIFO_AXI_S3),
    .R_rd_en        (AXI_RREADY_S3),
    .R_wr_en        (RVALID_S3),
    .R_w_data       (RFIFO_S3),
    .AW_rd_en       (AWREADY_S3),
    .AW_wr_en       (AXI_AWVALID_S3),
    .AW_w_data      (AWFIFO_AXI_S3),
    .W_rd_en        (WREADY_S3),
    .W_wr_en        (AXI_WVALID_S3),
    .W_w_data       (WFIFO_AXI_S3),
    .B_rd_en        (AXI_BREADY_S3),
    .B_wr_en        (BVALID_S3),
    .B_w_data       (BFIFO_S3),

    .AR_not_empty   (ARVALID_S3),
    .AR_not_full    (AXI_ARREADY_S3),
    .AR_r_data      (ARFIFO_S3),
    .R_not_empty    (AXI_RVALID_S3),
    .R_not_full     (RREADY_S3),
    .R_r_data       (RFIFO_AXI_S3),
    .AW_not_empty   (AWVALID_S3),
    .AW_not_full    (AXI_AWREADY_S3),
    .AW_r_data      (AWFIFO_S3),
    .W_not_empty    (WVALID_S3),
    .W_not_full     (AXI_WREADY_S3),
    .W_r_data       (WFIFO_S3),
    .B_not_empty    (AXI_BVALID_S3),
    .B_not_full     (BREADY_S3),
    .B_r_data       (BFIFO_AXI_S3)
);
//-------- AXI to Slave4 --------//
W_CDC AXI_S4(
    .clk            (axi_clk),
    .rst            (axi_rst),
    .clk2           (rom_clk),
    .rst2           (rom_rst),
    .AW_rd_en       (AWREADY_S4),
    .AW_wr_en       (AXI_AWVALID_S4),
    .AW_w_data      (AWFIFO_AXI_S4),
    .W_rd_en        (WREADY_S4),
    .W_wr_en        (AXI_WVALID_S4),
    .W_w_data       (WFIFO_AXI_S4),
    .B_rd_en        (AXI_BREADY_S4),
    .B_wr_en        (BVALID_S4),
    .B_w_data       (BFIFO_S4),

    .AW_not_empty   (AWVALID_S4),
    .AW_not_full    (AXI_AWREADY_S4),
    .AW_r_data      (AWFIFO_S4),
    .W_not_empty    (WVALID_S4),
    .W_not_full     (AXI_WREADY_S4),
    .W_r_data       (WFIFO_S4),
    .B_not_empty    (AXI_BVALID_S4),
    .B_not_full     (BREADY_S4),
    .B_r_data       (BFIFO_AXI_S4)
);
//-------- AXI to Slave5 --------//
RW_CDC AXI_S5(
    .clk            (axi_clk),
    .rst            (axi_rst),
    .clk2           (dram_clk),
    .rst2           (dram_rst),
    .AR_rd_en       (ARREADY_S5),
    .AR_wr_en       (AXI_ARVALID_S5),
    .AR_w_data      (ARFIFO_AXI_S5),
    .R_rd_en        (AXI_RREADY_S5),
    .R_wr_en        (RVALID_S5),
    .R_w_data       (RFIFO_S5),
    .AW_rd_en       (AWREADY_S5),
    .AW_wr_en       (AXI_AWVALID_S5),
    .AW_w_data      (AWFIFO_AXI_S5),
    .W_rd_en        (WREADY_S5),
    .W_wr_en        (AXI_WVALID_S5),
    .W_w_data       (WFIFO_AXI_S5),
    .B_rd_en        (AXI_BREADY_S5),
    .B_wr_en        (BVALID_S5),
    .B_w_data       (BFIFO_S5),

    .AR_not_empty   (ARVALID_S5),
    .AR_not_full    (AXI_ARREADY_S5),
    .AR_r_data      (ARFIFO_S5),
    .R_not_empty    (AXI_RVALID_S5),
    .R_not_full     (RREADY_S5),
    .R_r_data       (RFIFO_AXI_S5),
    .AW_not_empty   (AWVALID_S5),
    .AW_not_full    (AXI_AWREADY_S5),
    .AW_r_data      (AWFIFO_S5),
    .W_not_empty    (WVALID_S5),
    .W_not_full     (AXI_WREADY_S5),
    .W_r_data       (WFIFO_S5),
    .B_not_empty    (AXI_BVALID_S5),
    .B_not_full     (BREADY_S5),
    .B_r_data       (BFIFO_AXI_S5)
);
//-------- AXI to Slave6 --------//
RW_CDC AXI_S6(
    .clk            (axi_clk),
    .rst            (axi_rst),
    .clk2           (cpu_clk),
    .rst2           (cpu_rst),
    .AR_rd_en       (ARREADY_S6),
    .AR_wr_en       (AXI_ARVALID_S6),
    .AR_w_data      (ARFIFO_AXI_S6),
    .R_rd_en        (AXI_RREADY_S6),
    .R_wr_en        (RVALID_S6),
    .R_w_data       (RFIFO_S6),
    .AW_rd_en       (AWREADY_S6),
    .AW_wr_en       (AXI_AWVALID_S6),
    .AW_w_data      (AWFIFO_AXI_S6),
    .W_rd_en        (WREADY_S6),
    .W_wr_en        (AXI_WVALID_S6),
    .W_w_data       (WFIFO_AXI_S6),
    .B_rd_en        (AXI_BREADY_S6),
    .B_wr_en        (BVALID_S6),
    .B_w_data       (BFIFO_S6),

    .AR_not_empty   (ARVALID_S6),
    .AR_not_full    (AXI_ARREADY_S6),
    .AR_r_data      (ARFIFO_S6),
    .R_not_empty    (AXI_RVALID_S6),
    .R_not_full     (RREADY_S6),
    .R_r_data       (RFIFO_AXI_S6),
    .AW_not_empty   (AWVALID_S6),
    .AW_not_full    (AXI_AWREADY_S6),
    .AW_r_data      (AWFIFO_S6),
    .W_not_empty    (WVALID_S6),
    .W_not_full     (AXI_WREADY_S6),
    .W_r_data       (WFIFO_S6),
    .B_not_empty    (AXI_BVALID_S6),
    .B_not_full     (BREADY_S6),
    .B_r_data       (BFIFO_AXI_S6)
);

WTO_CDC WTO_CDC(
    .clk            (rom_clk),
    .rst            (rom_rst),
    .clk2           (cpu_clk),
    .rst2           (cpu_rst),
    .cdc_in         (WTO),

    .cdc_out        (intr_wdt)
);

//////// ======== Master ======== ////////
//-------- Master0 & Master1 --------//
CPU_wrapper CPU_wrapper(
    .ACLK           (cpu_clk),
    .ARESETn        (cpu_rstn),
    .intr_wdt       (intr_wdt),
    .intr_dma       (intr_dma),
	.intr_epu		(intr_epu),
    
    // write address signals M1
    .AWID_M1        (AWID_M1),
    .AWADDR_M1      (AWADDR_M1),
    .AWLEN_M1       (AWLEN_M1),
    .AWSIZE_M1      (AWSIZE_M1),
    .AWBURST_M1     (AWBURST_M1),
    .AWVALID_M1     (AWVALID_M1),
    .AWREADY_M1     (AWREADY_M1),
    
    // write data signals M1
    .WDATA_M1       (WDATA_M1),
    .WSTRB_M1       (WSTRB_M1),
    .WLAST_M1       (WLAST_M1),
    .WVALID_M1      (WVALID_M1),
    .WREADY_M1      (WREADY_M1),
    
    // write respond signals M1
    .BID_M1         (BFIFO_M1[ 5: 2]),
    .BRESP_M1       (BFIFO_M1[ 1: 0]),
    .BVALID_M1      (BVALID_M1),
    .BREADY_M1      (BREADY_M1),
    
    // read address signals M0
    .ARID_M0        (ARID_M0),
    .ARADDR_M0      (ARADDR_M0),
    .ARLEN_M0       (ARLEN_M0),
    .ARSIZE_M0      (ARSIZE_M0),
    .ARBURST_M0     (ARBURST_M0),
    .ARVALID_M0     (ARVALID_M0),
    .ARREADY_M0     (ARREADY_M0),
    
    // read data signals M0
    .RID_M0         (RFIFO_M0[38:35]),
    .RDATA_M0       (RFIFO_M0[34: 3]),
    .RRESP_M0       (RFIFO_M0[ 2: 1]),
    .RLAST_M0       (RFIFO_M0[    0]),
    .RVALID_M0      (RVALID_M0),
    .RREADY_M0      (RREADY_M0),
    
    // read address signals M1
    .ARID_M1        (ARID_M1),
    .ARADDR_M1      (ARADDR_M1),
    .ARLEN_M1       (ARLEN_M1),
    .ARSIZE_M1      (ARSIZE_M1),
    .ARBURST_M1     (ARBURST_M1),
    .ARVALID_M1     (ARVALID_M1),
    .ARREADY_M1     (ARREADY_M1),
    
    // read data signals M1
    .RID_M1         (RFIFO_M1[38:35]),
    .RDATA_M1       (RFIFO_M1[34: 3]),
    .RRESP_M1       (RFIFO_M1[ 2: 1]),
    .RLAST_M1       (RFIFO_M1[    0]),
    .RVALID_M1      (RVALID_M1),
    .RREADY_M1      (RREADY_M1)
);

//////// ======== Bridge ======== ////////
AXI AXI(
    .ACLK           (axi_clk),
    .ARESETn        (axi_rstn),

    //**** SLAVE INTERFACE FOR MASTERS ****//
    //-------- Master0 --------//
    //READ ADDRESS0
    .ARID_M0        (ARFIFO_M0_AXI[44:41]),
    .ARADDR_M0      (ARFIFO_M0_AXI[40: 9]),
    .ARLEN_M0       (ARFIFO_M0_AXI[ 8: 5]),
    .ARSIZE_M0      (ARFIFO_M0_AXI[ 4: 2]),
    .ARBURST_M0     (ARFIFO_M0_AXI[ 1: 0]),
    .ARVALID_M0     (AXI_ARVALID_M0),
    .ARREADY_M0     (AXI_ARREADY_M0),
    //READ DATA0
    .RID_M0         (RID_M0),
    .RDATA_M0       (RDATA_M0),
    .RRESP_M0       (RRESP_M0),
    .RLAST_M0       (RLAST_M0),
    .RVALID_M0      (AXI_RVALID_M0),
    .RREADY_M0      (AXI_RREADY_M0),

    //-------- Master1 --------//
    //WRITE ADDRESS1
    .AWID_M1        (AWFIFO_M1_AXI[44:41]),
    .AWADDR_M1      (AWFIFO_M1_AXI[40: 9]),
    .AWLEN_M1       (AWFIFO_M1_AXI[ 8: 5]),
    .AWSIZE_M1      (AWFIFO_M1_AXI[ 4: 2]),
    .AWBURST_M1     (AWFIFO_M1_AXI[ 1: 0]),
    .AWVALID_M1     (AXI_AWVALID_M1),
    .AWREADY_M1     (AXI_AWREADY_M1),
    //WRITE DATA1
    .WDATA_M1       (WFIFO_M1_AXI[36: 5]),
    .WSTRB_M1       (WFIFO_M1_AXI[ 4: 1]),
    .WLAST_M1       (WFIFO_M1_AXI[    0]),
    .WVALID_M1      (AXI_WVALID_M1),
    .WREADY_M1      (AXI_WREADY_M1),
    //WRITE RESPONSE1
    .BID_M1         (BID_M1),
    .BRESP_M1       (BRESP_M1),
    .BVALID_M1      (AXI_BVALID_M1),
    .BREADY_M1      (AXI_BREADY_M1),
    //READ ADDRESS1
    .ARID_M1        (ARFIFO_M1_AXI[44:41]),
    .ARADDR_M1      (ARFIFO_M1_AXI[40: 9]),
    .ARLEN_M1       (ARFIFO_M1_AXI[ 8: 5]),
    .ARSIZE_M1      (ARFIFO_M1_AXI[ 4: 2]),
    .ARBURST_M1     (ARFIFO_M1_AXI[ 1: 0]),
    .ARVALID_M1     (AXI_ARVALID_M1),
    .ARREADY_M1     (AXI_ARREADY_M1),
    //READ DATA1
    .RID_M1         (RID_M1),
    .RDATA_M1       (RDATA_M1),
    .RRESP_M1       (RRESP_M1),
    .RLAST_M1       (RLAST_M1),
    .RVALID_M1      (AXI_RVALID_M1),
    .RREADY_M1      (AXI_RREADY_M1),

    //-------- Master2 --------//
    //WRITE ADDRESS2
    .AWID_M2        (AWFIFO_M2_AXI[44:41]),
    .AWADDR_M2      (AWFIFO_M2_AXI[40: 9]),
    .AWLEN_M2       (AWFIFO_M2_AXI[ 8: 5]),
    .AWSIZE_M2      (AWFIFO_M2_AXI[ 4: 2]),
    .AWBURST_M2     (AWFIFO_M2_AXI[ 1: 0]),
    .AWVALID_M2     (AXI_AWVALID_M2),
    .AWREADY_M2     (AXI_AWREADY_M2),
    //WRITE DATA2
    .WDATA_M2       (WFIFO_M2_AXI[36: 5]),
    .WSTRB_M2       (WFIFO_M2_AXI[ 4: 1]),
    .WLAST_M2       (WFIFO_M2_AXI[    0]),
    .WVALID_M2      (AXI_WVALID_M2),
    .WREADY_M2      (AXI_WREADY_M2),
    //WRITE RESPONSE2
    .BID_M2         (BID_M2),
    .BRESP_M2       (BRESP_M2),
    .BVALID_M2      (AXI_BVALID_M2),
    .BREADY_M2      (AXI_BREADY_M2),
    //READ ADDRESS2
    .ARID_M2        (ARFIFO_M2_AXI[44:41]),
    .ARADDR_M2      (ARFIFO_M2_AXI[40: 9]),
    .ARLEN_M2       (ARFIFO_M2_AXI[ 8: 5]),
    .ARSIZE_M2      (ARFIFO_M2_AXI[ 4: 2]),
    .ARBURST_M2     (ARFIFO_M2_AXI[ 1: 0]),
    .ARVALID_M2     (AXI_ARVALID_M2),
    .ARREADY_M2     (AXI_ARREADY_M2),
    //READ DATA2
    .RID_M2         (RID_M2),
    .RDATA_M2       (RDATA_M2),
    .RRESP_M2       (RRESP_M2),
    .RLAST_M2       (RLAST_M2),
    .RVALID_M2      (AXI_RVALID_M2),
    .RREADY_M2      (AXI_RREADY_M2),

    //**** MASTER INTERFACE FOR SLAVES ****//
    //-------- Slave0 --------//
    //READ ADDRESS0
    .ARID_S0        (ARID_S0),
    .ARADDR_S0      (ARADDR_S0),
    .ARLEN_S0       (ARLEN_S0),
    .ARSIZE_S0      (ARSIZE_S0),
    .ARBURST_S0     (ARBURST_S0),
    .ARVALID_S0     (AXI_ARVALID_S0),
    .ARREADY_S0     (AXI_ARREADY_S0),
    //READ DATA0
    .RID_S0         (RFIFO_AXI_S0[42:35]),
    .RDATA_S0       (RFIFO_AXI_S0[34: 3]),
    .RRESP_S0       (RFIFO_AXI_S0[ 2: 1]),
    .RLAST_S0       (RFIFO_AXI_S0[    0]),
    .RVALID_S0      (AXI_RVALID_S0),
    .RREADY_S0      (AXI_RREADY_S0),

    //-------- Slave1 --------//
    //WRITE ADDRESS1
    .AWID_S1        (AWID_S1),
    .AWADDR_S1      (AWADDR_S1),
    .AWLEN_S1       (AWLEN_S1),
    .AWSIZE_S1      (AWSIZE_S1),
    .AWBURST_S1     (AWBURST_S1),
    .AWVALID_S1     (AXI_AWVALID_S1),
    .AWREADY_S1     (AXI_AWREADY_S1),
    //WRITE DATA1
    .WDATA_S1       (WDATA_S1),
    .WSTRB_S1       (WSTRB_S1),
    .WLAST_S1       (WLAST_S1),
    .WVALID_S1      (AXI_WVALID_S1),
    .WREADY_S1      (AXI_WREADY_S1),
    //WRITE RESPONSE1
    .BID_S1         (BFIFO_AXI_S1[ 9: 2]),
    .BRESP_S1       (BFIFO_AXI_S1[ 1: 0]),
    .BVALID_S1      (AXI_BVALID_S1),
    .BREADY_S1      (AXI_BREADY_S1),
    //READ ADDRESS1
    .ARID_S1        (ARID_S1),
    .ARADDR_S1      (ARADDR_S1),
    .ARLEN_S1       (ARLEN_S1),
    .ARSIZE_S1      (ARSIZE_S1),
    .ARBURST_S1     (ARBURST_S1),
    .ARVALID_S1     (AXI_ARVALID_S1),
    .ARREADY_S1     (AXI_ARREADY_S1),
    //READ DATA1
    .RID_S1         (RFIFO_AXI_S1[42:35]),
    .RDATA_S1       (RFIFO_AXI_S1[34: 3]),
    .RRESP_S1       (RFIFO_AXI_S1[ 2: 1]),
    .RLAST_S1       (RFIFO_AXI_S1[    0]),
    .RVALID_S1      (AXI_RVALID_S1),
    .RREADY_S1      (AXI_RREADY_S1),

    //-------- Slave2 --------//
    //WRITE ADDRESS2
    .AWID_S2        (AWID_S2),
    .AWADDR_S2      (AWADDR_S2),
    .AWLEN_S2       (AWLEN_S2),
    .AWSIZE_S2      (AWSIZE_S2),
    .AWBURST_S2     (AWBURST_S2),
    .AWVALID_S2     (AXI_AWVALID_S2),
    .AWREADY_S2     (AXI_AWREADY_S2),
    //WRITE DATA2
    .WDATA_S2       (WDATA_S2),
    .WSTRB_S2       (WSTRB_S2),
    .WLAST_S2       (WLAST_S2),
    .WVALID_S2      (AXI_WVALID_S2),
    .WREADY_S2      (AXI_WREADY_S2),
    //WRITE RESPONSE2
    .BID_S2         (BFIFO_AXI_S2[ 9: 2]),
    .BRESP_S2       (BFIFO_AXI_S2[ 1: 0]),
    .BVALID_S2      (AXI_BVALID_S2),
    .BREADY_S2      (AXI_BREADY_S2),
    //READ ADDRESS2
    .ARID_S2        (ARID_S2),
    .ARADDR_S2      (ARADDR_S2),
    .ARLEN_S2       (ARLEN_S2),
    .ARSIZE_S2      (ARSIZE_S2),
    .ARBURST_S2     (ARBURST_S2),
    .ARVALID_S2     (AXI_ARVALID_S2),
    .ARREADY_S2     (AXI_ARREADY_S2),
    //READ DATA2
    .RID_S2         (RFIFO_AXI_S2[42:35]),
    .RDATA_S2       (RFIFO_AXI_S2[34: 3]),
    .RRESP_S2       (RFIFO_AXI_S2[ 2: 1]),
    .RLAST_S2       (RFIFO_AXI_S2[    0]),
    .RVALID_S2      (AXI_RVALID_S2),
    .RREADY_S2      (AXI_RREADY_S2),

    //-------- Slave3 --------//
    //WRITE ADDRESS3
    .AWID_S3        (AWID_S3),
    .AWADDR_S3      (AWADDR_S3),
    .AWLEN_S3       (AWLEN_S3),
    .AWSIZE_S3      (AWSIZE_S3),
    .AWBURST_S3     (AWBURST_S3),
    .AWVALID_S3     (AXI_AWVALID_S3),
    .AWREADY_S3     (AXI_AWREADY_S3),
    //WRITE DATA3
    .WDATA_S3       (WDATA_S3),
    .WSTRB_S3       (WSTRB_S3),
    .WLAST_S3       (WLAST_S3),
    .WVALID_S3      (AXI_WVALID_S3),
    .WREADY_S3      (AXI_WREADY_S3),
    //WRITE RESPONSE3
    .BID_S3         (BFIFO_AXI_S3[ 9: 2]),
    .BRESP_S3       (BFIFO_AXI_S3[ 1: 0]),
    .BVALID_S3      (AXI_BVALID_S3),
    .BREADY_S3      (AXI_BREADY_S3),
    //READ ADDRESS3
    .ARID_S3        (ARID_S3),
    .ARADDR_S3      (ARADDR_S3),
    .ARLEN_S3       (ARLEN_S3),
    .ARSIZE_S3      (ARSIZE_S3),
    .ARBURST_S3     (ARBURST_S3),
    .ARVALID_S3     (AXI_ARVALID_S3),
    .ARREADY_S3     (AXI_ARREADY_S3),
    //READ DATA3
    .RID_S3         (RFIFO_AXI_S3[42:35]),
    .RDATA_S3       (RFIFO_AXI_S3[34: 3]),
    .RRESP_S3       (RFIFO_AXI_S3[ 2: 1]),
    .RLAST_S3       (RFIFO_AXI_S3[    0]),
    .RVALID_S3      (AXI_RVALID_S3),
    .RREADY_S3      (AXI_RREADY_S3),

    //-------- Slave4 --------//
    //WRITE ADDRESS4
    .AWID_S4        (AWID_S4),
    .AWADDR_S4      (AWADDR_S4),
    .AWLEN_S4       (AWLEN_S4),
    .AWSIZE_S4      (AWSIZE_S4),
    .AWBURST_S4     (AWBURST_S4),
    .AWVALID_S4     (AXI_AWVALID_S4),
    .AWREADY_S4     (AXI_AWREADY_S4),
    //WRITE DATA4
    .WDATA_S4       (WDATA_S4),
    .WSTRB_S4       (WSTRB_S4),
    .WLAST_S4       (WLAST_S4),
    .WVALID_S4      (AXI_WVALID_S4),
    .WREADY_S4      (AXI_WREADY_S4),
    //WRITE RESPONSE4
    .BID_S4         (BFIFO_AXI_S4[ 9: 2]),
    .BRESP_S4       (BFIFO_AXI_S4[ 1: 0]),
    .BVALID_S4      (AXI_BVALID_S4),
    .BREADY_S4      (AXI_BREADY_S4),

    //-------- Slave5 --------//
    //WRITE ADDRESS5
    .AWID_S5        (AWID_S5),
    .AWADDR_S5      (AWADDR_S5),
    .AWLEN_S5       (AWLEN_S5),
    .AWSIZE_S5      (AWSIZE_S5),
    .AWBURST_S5     (AWBURST_S5),
    .AWVALID_S5     (AXI_AWVALID_S5),
    .AWREADY_S5     (AXI_AWREADY_S5),
    //WRITE DATA5
    .WDATA_S5       (WDATA_S5),
    .WSTRB_S5       (WSTRB_S5),
    .WLAST_S5       (WLAST_S5),
    .WVALID_S5      (AXI_WVALID_S5),
    .WREADY_S5      (AXI_WREADY_S5),
    //WRITE RESPONSE5
    .BID_S5         (BFIFO_AXI_S5[ 9: 2]),
    .BRESP_S5       (BFIFO_AXI_S5[ 1: 0]),
    .BVALID_S5      (AXI_BVALID_S5),
    .BREADY_S5      (AXI_BREADY_S5),
    //READ ADDRESS5
    .ARID_S5        (ARID_S5),
    .ARADDR_S5      (ARADDR_S5),
    .ARLEN_S5       (ARLEN_S5),
    .ARSIZE_S5      (ARSIZE_S5),
    .ARBURST_S5     (ARBURST_S5),
    .ARVALID_S5     (AXI_ARVALID_S5),
    .ARREADY_S5     (AXI_ARREADY_S5),
    //READ DATA5
    .RID_S5         (RFIFO_AXI_S5[42:35]),
    .RDATA_S5       (RFIFO_AXI_S5[34: 3]),
    .RRESP_S5       (RFIFO_AXI_S5[ 2: 1]),
    .RLAST_S5       (RFIFO_AXI_S5[    0]),
    .RVALID_S5      (AXI_RVALID_S5),
    .RREADY_S5      (AXI_RREADY_S5),

    //-------- Slave5 --------//
    //WRITE ADDRESS5
    .AWID_S6        (AWID_S6),
    .AWADDR_S6      (AWADDR_S6),
    .AWLEN_S6       (AWLEN_S6),
    .AWSIZE_S6      (AWSIZE_S6),
    .AWBURST_S6     (AWBURST_S6),
    .AWVALID_S6     (AXI_AWVALID_S6),
    .AWREADY_S6     (AXI_AWREADY_S6),
    //WRITE DATA5
    .WDATA_S6       (WDATA_S6),
    .WSTRB_S6       (WSTRB_S6),
    .WLAST_S6       (WLAST_S6),
    .WVALID_S6      (AXI_WVALID_S6),
    .WREADY_S6      (AXI_WREADY_S6),
    //WRITE RESPONSE5
    .BID_S6         (BFIFO_AXI_S6[ 9: 2]),
    .BRESP_S6       (BFIFO_AXI_S6[ 1: 0]),
    .BVALID_S6      (AXI_BVALID_S6),
    .BREADY_S6      (AXI_BREADY_S6),
    //READ ADDRESS5
    .ARID_S6        (ARID_S6),
    .ARADDR_S6      (ARADDR_S6),
    .ARLEN_S6       (ARLEN_S6),
    .ARSIZE_S6      (ARSIZE_S6),
    .ARBURST_S6     (ARBURST_S6),
    .ARVALID_S6     (AXI_ARVALID_S6),
    .ARREADY_S6     (AXI_ARREADY_S6),
    //READ DATA5
    .RID_S6         (RFIFO_AXI_S6[42:35]),
    .RDATA_S6       (RFIFO_AXI_S6[34: 3]),
    .RRESP_S6       (RFIFO_AXI_S6[ 2: 1]),
    .RLAST_S6       (RFIFO_AXI_S6[    0]),
    .RVALID_S6      (AXI_RVALID_S6),
    .RREADY_S6      (AXI_RREADY_S6)
);

//////// ======== Slave ======== ////////
//-------- Slave0 --------//
ROM_wrapper i_ROM(
    .ACLK           (rom_clk),
    .ARESETn        (rom_rstn),
    // read address signals
    .ARID_S         (ARFIFO_S0[48:41]),
    .ARADDR_S       (ARFIFO_S0[40: 9]),
    .ARLEN_S        (ARFIFO_S0[ 8: 5]),
    .ARSIZE_S       (ARFIFO_S0[ 4: 2]),
    .ARBURST_S      (ARFIFO_S0[ 1: 0]),
    .ARVALID_S      (ARVALID_S0),
    .ARREADY_S      (ARREADY_S0),
    // read data signals
    .RID_S          (RID_S0),
    .RDATA_S        (RDATA_S0),
    .RRESP_S        (RRESP_S0),
    .RLAST_S        (RLAST_S0),
    .RVALID_S       (RVALID_S0),
    .RREADY_S       (RREADY_S0),
    // outside ROM signals
    .ROM_out        (ROM_out),
    .ROM_read       (ROM_read),
    .ROM_enable     (ROM_enable),
    .ROM_address    (ROM_address)
);

//-------- Slave1 --------//
SRAM_wrapper IM1(
    .ACLK           (cpu_clk),
    .ARESETn        (cpu_rstn),
    // write address signals
    .AWID_S         (AWFIFO_S1[48:41]),
    .AWADDR_S       (AWFIFO_S1[40: 9]),
    .AWLEN_S        (AWFIFO_S1[ 8: 5]),
    .AWSIZE_S       (AWFIFO_S1[ 4: 2]),
    .AWBURST_S      (AWFIFO_S1[ 1: 0]),
    .AWVALID_S      (AWVALID_S1),
    .AWREADY_S      (AWREADY_S1),
    // write data signals
    .WDATA_S        (WFIFO_S1[36: 5]),
    .WSTRB_S        (WFIFO_S1[ 4: 1]),
    .WLAST_S        (WFIFO_S1[    0]),
    .WVALID_S       (WVALID_S1),
    .WREADY_S       (WREADY_S1),
    // write respond signals
    .BID_S          (BID_S1),
    .BRESP_S        (BRESP_S1),
    .BVALID_S       (BVALID_S1),
    .BREADY_S       (BREADY_S1),
    // read address signals
    .ARID_S         (ARFIFO_S1[48:41]),
    .ARADDR_S       (ARFIFO_S1[40: 9]),
    .ARLEN_S        (ARFIFO_S1[ 8: 5]),
    .ARSIZE_S       (ARFIFO_S1[ 4: 2]),
    .ARBURST_S      (ARFIFO_S1[ 1: 0]),
    .ARVALID_S      (ARVALID_S1),
    .ARREADY_S      (ARREADY_S1),
    // read data signals
    .RID_S          (RID_S1),
    .RDATA_S        (RDATA_S1),
    .RRESP_S        (RRESP_S1),
    .RLAST_S        (RLAST_S1),
    .RVALID_S       (RVALID_S1),
    .RREADY_S       (RREADY_S1)
);

//-------- Slave2 --------//
SRAM_wrapper DM1(
    .ACLK           (cpu_clk),
    .ARESETn        (cpu_rstn),
    // write address signals
    .AWID_S         (AWFIFO_S2[48:41]),
    .AWADDR_S       (AWFIFO_S2[40: 9]),
    .AWLEN_S        (AWFIFO_S2[ 8: 5]),
    .AWSIZE_S       (AWFIFO_S2[ 4: 2]),
    .AWBURST_S      (AWFIFO_S2[ 1: 0]),
    .AWVALID_S      (AWVALID_S2),
    .AWREADY_S      (AWREADY_S2),
    // write data signals
    .WDATA_S        (WFIFO_S2[36: 5]),
    .WSTRB_S        (WFIFO_S2[ 4: 1]),
    .WLAST_S        (WFIFO_S2[    0]),
    .WVALID_S       (WVALID_S2),
    .WREADY_S       (WREADY_S2),
    // write respond signals
    .BID_S          (BID_S2),
    .BRESP_S        (BRESP_S2),
    .BVALID_S       (BVALID_S2),
    .BREADY_S       (BREADY_S2),
    // read address signals
    .ARID_S         (ARFIFO_S2[48:41]),
    .ARADDR_S       (ARFIFO_S2[40: 9]),
    .ARLEN_S        (ARFIFO_S2[ 8: 5]),
    .ARSIZE_S       (ARFIFO_S2[ 4: 2]),
    .ARBURST_S      (ARFIFO_S2[ 1: 0]),
    .ARVALID_S      (ARVALID_S2),
    .ARREADY_S      (ARREADY_S2),
    // read data signals
    .RID_S          (RID_S2),
    .RDATA_S        (RDATA_S2),
    .RRESP_S        (RRESP_S2),
    .RLAST_S        (RLAST_S2),
    .RVALID_S       (RVALID_S2),
    .RREADY_S       (RREADY_S2)
);

//-------- Slave4 --------//
WDT_wrapper Slave4_WDT(
    .ACLK           (rom_clk),
    .ARESETn        (rom_rstn),
    // write address signals
    .AWID_S         (AWFIFO_S4[48:41]),
    .AWADDR_S       (AWFIFO_S4[40: 9]),
    .AWLEN_S        (AWFIFO_S4[ 8: 5]),
    .AWSIZE_S       (AWFIFO_S4[ 4: 2]),
    .AWBURST_S      (AWFIFO_S4[ 1: 0]),
    .AWVALID_S      (AWVALID_S4),
    .AWREADY_S      (AWREADY_S4),
    // write data signals
    .WDATA_S        (WFIFO_S4[36: 5]),
    .WSTRB_S        (WFIFO_S4[ 4: 1]),
    .WLAST_S        (WFIFO_S4[    0]),
    .WVALID_S       (WVALID_S4),
    .WREADY_S       (WREADY_S4),
    // write respond signals
    .BID_S          (BID_S4),
    .BRESP_S        (BRESP_S4),
    .BVALID_S       (BVALID_S4),
    .BREADY_S       (BREADY_S4),
    // WDT timeout
    .WTO            (WTO)
);

//-------- Slave5 --------//
DRAM_wrapper Slave5_DRAM(
    .ACLK           (dram_clk),
    .ARESETn        (dram_rstn),
    // write address signals
    .AWID_S         (AWFIFO_S5[48:41]),
    .AWADDR_S       (AWFIFO_S5[40: 9]),
    .AWLEN_S        (AWFIFO_S5[ 8: 5]),
    .AWSIZE_S       (AWFIFO_S5[ 4: 2]),
    .AWBURST_S      (AWFIFO_S5[ 1: 0]),
    .AWVALID_S      (AWVALID_S5),
    .AWREADY_S      (AWREADY_S5),
    // write data signals
    .WDATA_S        (WFIFO_S5[36: 5]),
    .WSTRB_S        (WFIFO_S5[ 4: 1]),
    .WLAST_S        (WFIFO_S5[    0]),
    .WVALID_S       (WVALID_S5),
    .WREADY_S       (WREADY_S5),
    // write respond signals
    .BID_S          (BID_S5),
    .BRESP_S        (BRESP_S5),
    .BVALID_S       (BVALID_S5),
    .BREADY_S       (BREADY_S5),
    // read address signals
    .ARID_S         (ARFIFO_S5[48:41]),
    .ARADDR_S       (ARFIFO_S5[40: 9]),
    .ARLEN_S        (ARFIFO_S5[ 8: 5]),
    .ARSIZE_S       (ARFIFO_S5[ 4: 2]),
    .ARBURST_S      (ARFIFO_S5[ 1: 0]),
    .ARVALID_S      (ARVALID_S5),
    .ARREADY_S      (ARREADY_S5),
    // read data signals
    .RID_S          (RID_S5),
    .RDATA_S        (RDATA_S5),
    .RRESP_S        (RRESP_S5),
    .RLAST_S        (RLAST_S5),
    .RVALID_S       (RVALID_S5),
    .RREADY_S       (RREADY_S5),
    // outside DRAM signals
    .DRAM_Q         (DRAM_Q),
    .DRAM_valid     (DRAM_valid),
    .DRAM_CSn       (DRAM_CSn),
    .DRAM_WEn       (DRAM_WEn),
    .DRAM_RASn      (DRAM_RASn),
    .DRAM_CASn      (DRAM_CASn),
    .DRAM_A         (DRAM_A),
    .DRAM_D         (DRAM_D)
);

//-------- Slave6 --------//
EPU_Wrapper slave6_EPU(
	.ACLK           (cpu_clk),
    .ARESETn        (cpu_rstn),
    // write address signals
    .AWID           (AWFIFO_S6[48:41]),
    .AWADDR         (AWFIFO_S6[40: 9]),
    .AWLEN          (AWFIFO_S6[ 8: 5]),
    .AWSIZE         (AWFIFO_S6[ 4: 2]),
    .AWBURST        (AWFIFO_S6[ 1: 0]),
    .AWVALID        (AWVALID_S6),
    .AWREADY        (AWREADY_S6),
    // write data signals
    .WDATA          (WFIFO_S6[36: 5]),
    .WSTRB          (WFIFO_S6[ 4: 1]),
    .WLAST          (WFIFO_S6[    0]),
    .WVALID         (WVALID_S6),
    .WREADY         (WREADY_S6),
    // write respond signals
    .BID            (BID_S6),
    .BRESP          (BRESP_S6),
    .BVALID         (BVALID_S6),
    .BREADY         (BREADY_S6),
    // read address signals
    .ARID           (ARFIFO_S6[48:41]),
    .ARADDR         (ARFIFO_S6[40: 9]),
    .ARLEN          (ARFIFO_S6[ 8: 5]),
    .ARSIZE         (ARFIFO_S6[ 4: 2]),
    .ARBURST        (ARFIFO_S6[ 1: 0]),
    .ARVALID        (ARVALID_S6),
    .ARREADY        (ARREADY_S6),
    // read data signals
    .RID            (RID_S6),
    .RDATA          (RDATA_S6),
    .RRESP          (RRESP_S6),
    .RLAST          (RLAST_S6),
    .RVALID         (RVALID_S6),
    .RREADY         (RREADY_S6),
	///layer done
    .layer_done     (layer_done),
//	.layer1_done	(layer1_done),
//	.layer2_done	(layer2_done),
//	.layer3_done	(layer3_done),
//	.layer4_done	(layer4_done),
//	.layer5_done	(layer5_done),
//	.layer6_done	(layer6_done),
	.epu_interrupt	(intr_epu)
);

//-------- Master2 & Slave3 --------//
DMA_wrapper Master2_Slave3_DMA(
    .ACLK           (cpu_clk),
    .ARESETn        (cpu_rstn),
    .INTR           (intr_dma),
    // Slave3(DMA)
    // write address signals
    .AWID_S         (AWFIFO_S3[48:41]),
    .AWADDR_S       (AWFIFO_S3[40: 9]),
    .AWLEN_S        (AWFIFO_S3[ 8: 5]),
    .AWSIZE_S       (AWFIFO_S3[ 4: 2]),
    .AWBURST_S      (AWFIFO_S3[ 1: 0]),
    .AWVALID_S      (AWVALID_S3),
    .AWREADY_S      (AWREADY_S3),
    // write data signals
    .WDATA_S        (WFIFO_S3[36: 5]),
    .WSTRB_S        (WFIFO_S3[ 4: 1]),
    .WLAST_S        (WFIFO_S3[    0]),
    .WVALID_S       (WVALID_S3),
    .WREADY_S       (WREADY_S3),
    // write respond signals
    .BID_S          (BID_S3),
    .BRESP_S        (BRESP_S3),
    .BVALID_S       (BVALID_S3),
    .BREADY_S       (BREADY_S3),
    // read address signals
    .ARID_S         (ARFIFO_S3[48:41]),
    .ARADDR_S       (ARFIFO_S3[40: 9]),
    .ARLEN_S        (ARFIFO_S3[ 8: 5]),
    .ARSIZE_S       (ARFIFO_S3[ 4: 2]),
    .ARBURST_S      (ARFIFO_S3[ 1: 0]),
    .ARVALID_S      (ARVALID_S3),
    .ARREADY_S      (ARREADY_S3),
    // read data signals
    .RID_S          (RID_S3),
    .RDATA_S        (RDATA_S3),
    .RRESP_S        (RRESP_S3),
    .RLAST_S        (RLAST_S3),
    .RVALID_S       (RVALID_S3),
    .RREADY_S       (RREADY_S3),
    
    //Master2(DMA)
    //WRITE ADDRESS2
    .AWID_M         (AWID_M2),
    .AWADDR_M       (AWADDR_M2),
    .AWLEN_M        (AWLEN_M2),
    .AWSIZE_M       (AWSIZE_M2),
    .AWBURST_M      (AWBURST_M2),
    .AWVALID_M      (AWVALID_M2),
    .AWREADY_M      (AWREADY_M2),
    //WRITE DATA2
    .WDATA_M        (WDATA_M2),
    .WSTRB_M        (WSTRB_M2),
    .WLAST_M        (WLAST_M2),
    .WVALID_M       (WVALID_M2),
    .WREADY_M       (WREADY_M2),
    //WRITE RESPONSE2
    .BID_M          (BFIFO_M2[ 5: 2]),
    .BRESP_M        (BFIFO_M2[ 1: 0]),
    .BVALID_M       (BVALID_M2),
    .BREADY_M       (BREADY_M2),
    //READ ADDRESS2
    .ARID_M         (ARID_M2),
    .ARADDR_M       (ARADDR_M2),
    .ARLEN_M        (ARLEN_M2),
    .ARSIZE_M       (ARSIZE_M2),
    .ARBURST_M      (ARBURST_M2),
    .ARVALID_M      (ARVALID_M2),
    .ARREADY_M      (ARREADY_M2),
    //READ DATA2
    .RID_M          (RFIFO_M2[38:35]),
    .RDATA_M        (RFIFO_M2[34: 3]),
    .RRESP_M        (RFIFO_M2[ 2: 1]),
    .RLAST_M        (RFIFO_M2[    0]),
    .RVALID_M       (RVALID_M2),
    .RREADY_M       (RREADY_M2)
);

endmodule
