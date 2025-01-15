//////////////////////////////////////////////////////////////////////
//          ██╗       ██████╗   ██╗  ██╗    ██████╗                 //
//          ██║       ██╔══█║   ██║  ██║    ██╔══█║                 //
//          ██║       ██████║   ███████║    ██████║                 //
//          ██║       ██╔═══╝   ██╔══██║    ██╔═══╝                 //
//          ███████╗  ██║       ██║  ██║    ██║                     //
//          ╚══════╝  ╚═╝       ╚═╝  ╚═╝    ╚═╝                     //
//                                                                  //
//      2024 Advanced VLSI System Design, advisor: Lih-Yih, Chiou   //
//                                                                  //
//////////////////////////////////////////////////////////////////////
//                                                                  //
//      Autor:          HONG-WEI, LIN (N26130524)                   //
//      Filename:       AXI.sv                                      //
//      Description:    Top module of AXI for final project         //
//      Version:        1.0                                         //
//                                                                  //
//////////////////////////////////////////////////////////////////////
// `include "../../include/AXI_define.svh"

module AXI(
        input ACLK,
        input ARESETn,

        ////////SLAVE INTERFACE FOR MASTER0(CPU_M0)////////
        //READ ADDRESS0
        input        [`AXI_ID_BITS-1:0]         ARID_M0,
        input        [`AXI_ADDR_BITS-1:0]       ARADDR_M0,
        input        [`AXI_LEN_BITS-1:0]        ARLEN_M0,
        input        [`AXI_SIZE_BITS-1:0]       ARSIZE_M0,
        input        [1:0]                      ARBURST_M0,
        input                                   ARVALID_M0,
        output logic                            ARREADY_M0,
        //READ DATA0
        output logic [`AXI_ID_BITS-1:0]         RID_M0,
        output logic [`AXI_DATA_BITS-1:0]       RDATA_M0,
        output logic [1:0]                      RRESP_M0,
        output logic                            RLAST_M0,
        output logic                            RVALID_M0,
        input                                   RREADY_M0,

        ////////SLAVE INTERFACE FOR MASTER1(CPU_M1)////////
        //WRITE ADDRESS1
        input        [`AXI_ID_BITS-1:0]         AWID_M1,
        input        [`AXI_ADDR_BITS-1:0]       AWADDR_M1,
        input        [`AXI_LEN_BITS-1:0]        AWLEN_M1,
        input        [`AXI_SIZE_BITS-1:0]       AWSIZE_M1,
        input        [1:0]                      AWBURST_M1,
        input                                   AWVALID_M1,
        output logic                            AWREADY_M1,
        //WRITE DATA1
        input        [`AXI_DATA_BITS-1:0]       WDATA_M1,
        input        [`AXI_STRB_BITS-1:0]       WSTRB_M1,
        input                                   WLAST_M1,
        input                                   WVALID_M1,
        output logic                            WREADY_M1,
        //WRITE RESPONSE1
        output logic [`AXI_ID_BITS-1:0]         BID_M1,
        output logic [1:0]                      BRESP_M1,
        output logic                            BVALID_M1,
        input                                   BREADY_M1,
        //READ ADDRESS1
        input        [`AXI_ID_BITS-1:0]         ARID_M1,
        input        [`AXI_ADDR_BITS-1:0]       ARADDR_M1,
        input        [`AXI_LEN_BITS-1:0]        ARLEN_M1,
        input        [`AXI_SIZE_BITS-1:0]       ARSIZE_M1,
        input        [1:0]                      ARBURST_M1,
        input                                   ARVALID_M1,
        output logic                            ARREADY_M1,
        //READ DATA1
        output logic [`AXI_ID_BITS-1:0]         RID_M1,
        output logic [`AXI_DATA_BITS-1:0]       RDATA_M1,
        output logic [1:0]                      RRESP_M1,
        output logic                            RLAST_M1,
        output logic                            RVALID_M1,
        input                                   RREADY_M1,

        ////////SLAVE INTERFACE FOR MASTER2(DMA)////////
        //WRITE ADDRESS2
        input        [`AXI_ID_BITS-1:0]         AWID_M2,
        input        [`AXI_ADDR_BITS-1:0]       AWADDR_M2,
        input        [`AXI_LEN_BITS-1:0]        AWLEN_M2,
        input        [`AXI_SIZE_BITS-1:0]       AWSIZE_M2,
        input        [1:0]                      AWBURST_M2,
        input                                   AWVALID_M2,
        output logic                            AWREADY_M2,
        //WRITE DATA2
        input        [`AXI_DATA_BITS-1:0]       WDATA_M2,
        input        [`AXI_STRB_BITS-1:0]       WSTRB_M2,
        input                                   WLAST_M2,
        input                                   WVALID_M2,
        output logic                            WREADY_M2,
        //WRITE RESPONSE2
        output logic [`AXI_ID_BITS-1:0]         BID_M2,
        output logic [1:0]                      BRESP_M2,
        output logic                            BVALID_M2,
        input                                   BREADY_M2,
        //READ ADDRESS2
        input        [`AXI_ID_BITS-1:0]         ARID_M2,
        input        [`AXI_ADDR_BITS-1:0]       ARADDR_M2,
        input        [`AXI_LEN_BITS-1:0]        ARLEN_M2,
        input        [`AXI_SIZE_BITS-1:0]       ARSIZE_M2,
        input        [1:0]                      ARBURST_M2,
        input                                   ARVALID_M2,
        output logic                            ARREADY_M2,
        //READ DATA2
        output logic [`AXI_ID_BITS-1:0]         RID_M2,
        output logic [`AXI_DATA_BITS-1:0]       RDATA_M2,
        output logic [1:0]                      RRESP_M2,
        output logic                            RLAST_M2,
        output logic                            RVALID_M2,
        input                                   RREADY_M2,

        ////////MASTER INTERFACE FOR SLAVES0(ROM)////////
        //READ ADDRESS0
        output logic [`AXI_IDS_BITS-1:0]        ARID_S0,
        output logic [`AXI_ADDR_BITS-1:0]       ARADDR_S0,
        output logic [`AXI_LEN_BITS-1:0]        ARLEN_S0,
        output logic [`AXI_SIZE_BITS-1:0]       ARSIZE_S0,
        output logic [1:0]                      ARBURST_S0,
        output logic                            ARVALID_S0,
        input                                   ARREADY_S0,
        //READ DATA0
        input        [`AXI_IDS_BITS-1:0]        RID_S0,
        input        [`AXI_DATA_BITS-1:0]       RDATA_S0,
        input        [1:0]                      RRESP_S0,
        input                                   RLAST_S0,
        input                                   RVALID_S0,
        output logic                            RREADY_S0,

        ////////MASTER INTERFACE FOR SLAVES1(IM)////////
        //WRITE ADDRESS1
        output logic [`AXI_IDS_BITS-1:0]        AWID_S1,
        output logic [`AXI_ADDR_BITS-1:0]       AWADDR_S1,
        output logic [`AXI_LEN_BITS-1:0]        AWLEN_S1,
        output logic [`AXI_SIZE_BITS-1:0]       AWSIZE_S1,
        output logic [1:0]                      AWBURST_S1,
        output logic                            AWVALID_S1,
        input                                   AWREADY_S1,
        //WRITE DATA1
        output logic [`AXI_DATA_BITS-1:0]       WDATA_S1,
        output logic [`AXI_STRB_BITS-1:0]       WSTRB_S1,
        output logic                            WLAST_S1,
        output logic                            WVALID_S1,
        input                                   WREADY_S1,
        //WRITE RESPONSE1
        input        [`AXI_IDS_BITS-1:0]        BID_S1,
        input        [1:0]                      BRESP_S1,
        input                                   BVALID_S1,
        output logic                            BREADY_S1,
        //READ ADDRESS1
        output logic [`AXI_IDS_BITS-1:0]        ARID_S1,
        output logic [`AXI_ADDR_BITS-1:0]       ARADDR_S1,
        output logic [`AXI_LEN_BITS-1:0]        ARLEN_S1,
        output logic [`AXI_SIZE_BITS-1:0]       ARSIZE_S1,
        output logic [1:0]                      ARBURST_S1,
        output logic                            ARVALID_S1,
        input                                   ARREADY_S1,
        //READ DATA1
        input        [`AXI_IDS_BITS-1:0]        RID_S1,
        input        [`AXI_DATA_BITS-1:0]       RDATA_S1,
        input        [1:0]                      RRESP_S1,
        input                                   RLAST_S1,
        input                                   RVALID_S1,
        output logic                            RREADY_S1,

        ////////MASTER INTERFACE FOR SLAVES2(DM)////////
        //WRITE ADDRESS2
        output logic [`AXI_IDS_BITS-1:0]        AWID_S2,
        output logic [`AXI_ADDR_BITS-1:0]       AWADDR_S2,
        output logic [`AXI_LEN_BITS-1:0]        AWLEN_S2,
        output logic [`AXI_SIZE_BITS-1:0]       AWSIZE_S2,
        output logic [1:0]                      AWBURST_S2,
        output logic                            AWVALID_S2,
        input                                   AWREADY_S2,
        //WRITE DATA2
        output logic [`AXI_DATA_BITS-1:0]       WDATA_S2,
        output logic [`AXI_STRB_BITS-1:0]       WSTRB_S2,
        output logic                            WLAST_S2,
        output logic                            WVALID_S2,
        input                                   WREADY_S2,
        //WRITE RESPONSE2
        input        [`AXI_IDS_BITS-1:0]        BID_S2,
        input        [1:0]                      BRESP_S2,
        input                                   BVALID_S2,
        output logic                            BREADY_S2,
        //READ ADDRESS2
        output logic [`AXI_IDS_BITS-1:0]        ARID_S2,
        output logic [`AXI_ADDR_BITS-1:0]       ARADDR_S2,
        output logic [`AXI_LEN_BITS-1:0]        ARLEN_S2,
        output logic [`AXI_SIZE_BITS-1:0]       ARSIZE_S2,
        output logic [1:0]                      ARBURST_S2,
        output logic                            ARVALID_S2,
        input                                   ARREADY_S2,
        //READ DATA2
        input        [`AXI_IDS_BITS-1:0]        RID_S2,
        input        [`AXI_DATA_BITS-1:0]       RDATA_S2,
        input        [1:0]                      RRESP_S2,
        input                                   RLAST_S2,
        input                                   RVALID_S2,
        output logic                            RREADY_S2,

        ////////MASTER INTERFACE FOR SLAVES3(DMA)////////
        //WRITE ADDRESS3
        output logic [`AXI_IDS_BITS-1:0]        AWID_S3,
        output logic [`AXI_ADDR_BITS-1:0]       AWADDR_S3,
        output logic [`AXI_LEN_BITS-1:0]        AWLEN_S3,
        output logic [`AXI_SIZE_BITS-1:0]       AWSIZE_S3,
        output logic [1:0]                      AWBURST_S3,
        output logic                            AWVALID_S3,
        input                                   AWREADY_S3,
        //WRITE DATA3
        output logic [`AXI_DATA_BITS-1:0]       WDATA_S3,
        output logic [`AXI_STRB_BITS-1:0]       WSTRB_S3,
        output logic                            WLAST_S3,
        output logic                            WVALID_S3,
        input                                   WREADY_S3,
        //WRITE RESPONSE1
        input        [`AXI_IDS_BITS-1:0]        BID_S3,
        input        [1:0]                      BRESP_S3,
        input                                   BVALID_S3,
        output logic                            BREADY_S3,
        //READ ADDRESS3
        output logic [`AXI_IDS_BITS-1:0]        ARID_S3,
        output logic [`AXI_ADDR_BITS-1:0]       ARADDR_S3,
        output logic [`AXI_LEN_BITS-1:0]        ARLEN_S3,
        output logic [`AXI_SIZE_BITS-1:0]       ARSIZE_S3,
        output logic [1:0]                      ARBURST_S3,
        output logic                            ARVALID_S3,
        input                                   ARREADY_S3,
        //READ DATA3
        input        [`AXI_IDS_BITS-1:0]        RID_S3,
        input        [`AXI_DATA_BITS-1:0]       RDATA_S3,
        input        [1:0]                      RRESP_S3,
        input                                   RLAST_S3,
        input                                   RVALID_S3,
        output logic                            RREADY_S3,

        ////////MASTER INTERFACE FOR SLAVES4(WDT)////////
        //WRITE ADDRESS4
        output logic [`AXI_IDS_BITS-1:0]        AWID_S4,
        output logic [`AXI_ADDR_BITS-1:0]       AWADDR_S4,
        output logic [`AXI_LEN_BITS-1:0]        AWLEN_S4,
        output logic [`AXI_SIZE_BITS-1:0]       AWSIZE_S4,
        output logic [1:0]                      AWBURST_S4,
        output logic                            AWVALID_S4,
        input                                   AWREADY_S4,
        //WRITE DATA4
        output logic [`AXI_DATA_BITS-1:0]       WDATA_S4,
        output logic [`AXI_STRB_BITS-1:0]       WSTRB_S4,
        output logic                            WLAST_S4,
        output logic                            WVALID_S4,
        input                                   WREADY_S4,
        //WRITE RESPONSE4
        input        [`AXI_IDS_BITS-1:0]        BID_S4,
        input        [1:0]                      BRESP_S4,
        input                                   BVALID_S4,
        output logic                            BREADY_S4,

        ////////MASTER INTERFACE FOR SLAVES5(DRAM)////////
        //WRITE ADDRESS5
        output logic [`AXI_IDS_BITS-1:0]        AWID_S5,
        output logic [`AXI_ADDR_BITS-1:0]       AWADDR_S5,
        output logic [`AXI_LEN_BITS-1:0]        AWLEN_S5,
        output logic [`AXI_SIZE_BITS-1:0]       AWSIZE_S5,
        output logic [1:0]                      AWBURST_S5,
        output logic                            AWVALID_S5,
        input                                   AWREADY_S5,
        //WRITE DATA5
        output logic [`AXI_DATA_BITS-1:0]       WDATA_S5,
        output logic [`AXI_STRB_BITS-1:0]       WSTRB_S5,
        output logic                            WLAST_S5,
        output logic                            WVALID_S5,
        input                                   WREADY_S5,
        //WRITE RESPONSE5
        input        [`AXI_IDS_BITS-1:0]        BID_S5,
        input        [1:0]                      BRESP_S5,
        input                                   BVALID_S5,
        output logic                            BREADY_S5,
        //READ ADDRESS5
        output logic [`AXI_IDS_BITS-1:0]        ARID_S5,
        output logic [`AXI_ADDR_BITS-1:0]       ARADDR_S5,
        output logic [`AXI_LEN_BITS-1:0]        ARLEN_S5,
        output logic [`AXI_SIZE_BITS-1:0]       ARSIZE_S5,
        output logic [1:0]                      ARBURST_S5,
        output logic                            ARVALID_S5,
        input                                   ARREADY_S5,
        //READ DATA5
        input        [`AXI_IDS_BITS-1:0]        RID_S5,
        input        [`AXI_DATA_BITS-1:0]       RDATA_S5,
        input        [1:0]                      RRESP_S5,
        input                                   RLAST_S5,
        input                                   RVALID_S5,
        output logic                            RREADY_S5,

        ////////MASTER INTERFACE FOR SLAVES5(EPU)////////
        //WRITE ADDRESS6
        output logic [`AXI_IDS_BITS-1:0]        AWID_S6,
        output logic [`AXI_ADDR_BITS-1:0]       AWADDR_S6,
        output logic [`AXI_LEN_BITS-1:0]        AWLEN_S6,
        output logic [`AXI_SIZE_BITS-1:0]       AWSIZE_S6,
        output logic [1:0]                      AWBURST_S6,
        output logic                            AWVALID_S6,
        input                                   AWREADY_S6,
        //WRITE DATA6
        output logic [`AXI_DATA_BITS-1:0]       WDATA_S6,
        output logic [`AXI_STRB_BITS-1:0]       WSTRB_S6,
        output logic                            WLAST_S6,
        output logic                            WVALID_S6,
        input                                   WREADY_S6,
        //WRITE RESPONSE6
        input        [`AXI_IDS_BITS-1:0]        BID_S6,
        input        [1:0]                      BRESP_S6,
        input                                   BVALID_S6,
        output logic                            BREADY_S6,
        //READ ADDRESS6
        output logic [`AXI_IDS_BITS-1:0]        ARID_S6,
        output logic [`AXI_ADDR_BITS-1:0]       ARADDR_S6,
        output logic [`AXI_LEN_BITS-1:0]        ARLEN_S6,
        output logic [`AXI_SIZE_BITS-1:0]       ARSIZE_S6,
        output logic [1:0]                      ARBURST_S6,
        output logic                            ARVALID_S6,
        input                                   ARREADY_S6,
        //READ DATA6
        input        [`AXI_IDS_BITS-1:0]        RID_S6,
        input        [`AXI_DATA_BITS-1:0]       RDATA_S6,
        input        [1:0]                      RRESP_S6,
        input                                   RLAST_S6,
        input                                   RVALID_S6,
        output logic                            RREADY_S6
);

//---------- you should put your design here ----------//

// localparameter declaration
localparam READ_IDLE   = 5'd0;
localparam READ_M0S0   = 5'd1;
localparam READ_M0S1   = 5'd2;
localparam READ_M0S2   = 5'd3;
localparam READ_M0S3   = 5'd4;
//localparam READ_M0S4   = 5'd5;  // not uesd
localparam READ_M0S5   = 5'd6;
localparam READ_M1S0   = 5'd7;
localparam READ_M1S1   = 5'd8;
localparam READ_M1S2   = 5'd9;
localparam READ_M1S3   = 5'd10;
//localparam READ_M1S4   = 5'd11; // not uesd
localparam READ_M1S5   = 5'd12;
localparam READ_M2S0   = 5'd13;
localparam READ_M2S1   = 5'd14;
localparam READ_M2S2   = 5'd15;
localparam READ_M2S3   = 5'd16;
//localparam READ_M2S4   = 5'd17; // not uesd
localparam READ_M2S5   = 5'd18;
//********** final **********//
localparam READ_M0S6   = 5'd19;
localparam READ_M1S6   = 5'd20;
localparam READ_M2S6   = 5'd21;

localparam WRITE_IDLE  = 5'd0;
//localparam WRITE_M1S0  = 5'd1;  // not uesd
localparam WRITE_M1S1  = 5'd2;
localparam WRITE_M1S2  = 5'd3;
localparam WRITE_M1S3  = 5'd4;
localparam WRITE_M1S4  = 5'd5;
localparam WRITE_M1S5  = 5'd6;
//localparam WRITE_M2S0  = 5'd7;  // not uesd
localparam WRITE_M2S1  = 5'd8;
localparam WRITE_M2S2  = 5'd9;
localparam WRITE_M2S3  = 5'd10;
localparam WRITE_M2S4  = 5'd11;
localparam WRITE_M2S5  = 5'd12;
//********** final **********//
localparam WRITE_M1S6  = 5'd13;
localparam WRITE_M2S6  = 5'd14;

// states
logic [4:0] R_cur_state;
logic [4:0] R_next_state;
logic [4:0] W_cur_state;
logic [4:0] W_next_state;

////////////////// ******** READ SIGNALS ******** //////////////////
always_ff@(posedge ACLK or negedge ARESETn)begin
        if(~ARESETn)    R_cur_state <= READ_IDLE;
        else            R_cur_state <= R_next_state;
end
// READ Finite State Machine
always_comb
begin
        case(R_cur_state)
        READ_IDLE:begin      
        if(ARVALID_M2)begin
                if(ARADDR_M2[31:28] == 4'h2)
                                  R_next_state = READ_M2S5;
                else begin
                        case(ARADDR_M2[31:16])
                        16'h0000: R_next_state = READ_M2S0;
                        16'h0001: R_next_state = READ_M2S1;
                        16'h0002: R_next_state = READ_M2S2;
                        16'h1002: R_next_state = READ_M2S3;
                        // 16'h1001: R_next_state = READ_M2S4; // not used
                        // 16'h2000: R_next_state = READ_M2S5;
                        16'h0003: R_next_state = READ_M2S6;
                        16'h0004: R_next_state = READ_M2S6;
                        16'h0005: R_next_state = READ_M2S6;
                        16'h0006: R_next_state = READ_M2S6;
                        default:  R_next_state = READ_IDLE;
                        endcase
                end
        end        
        else if(ARVALID_M1)begin
                if(ARADDR_M1[31:28] == 4'h2)
                                  R_next_state = READ_M1S5;
                else begin
                        case(ARADDR_M1[31:16])
                        16'h0000: R_next_state = READ_M1S0;
                        16'h0001: R_next_state = READ_M1S1;
                        16'h0002: R_next_state = READ_M1S2;
                        16'h1002: R_next_state = READ_M1S3;
                        // 16'h1001: R_next_state = READ_M1S4; // not used
                        // 16'h2000: R_next_state = READ_M1S5;
                        16'h0003: R_next_state = READ_M1S6;
                        16'h0004: R_next_state = READ_M1S6;
                        16'h0005: R_next_state = READ_M1S6;
                        16'h0006: R_next_state = READ_M1S6;
                        default:  R_next_state = READ_IDLE;
                        endcase
                end
        end
        else if(ARVALID_M0)begin
                if(ARADDR_M0[31:28] == 4'h2)
                                  R_next_state = READ_M0S5;
                else begin
                        case(ARADDR_M0[31:16])
                        16'h0000: R_next_state = READ_M0S0;
                        16'h0001: R_next_state = READ_M0S1;
                        16'h0002: R_next_state = READ_M0S2;
                        16'h1002: R_next_state = READ_M0S3;
                        // 16'h1001: R_next_state = READ_M0S4; // not used
                        // 16'h2000: R_next_state = READ_M0S5;
                        16'h0003: R_next_state = READ_M0S6;
                        16'h0004: R_next_state = READ_M0S6;
                        16'h0005: R_next_state = READ_M0S6;
                        16'h0006: R_next_state = READ_M0S6;
                        default:  R_next_state = READ_IDLE;
                        endcase
                end
        end
        else               R_next_state = READ_IDLE;
        end
        READ_M0S0:         R_next_state = (RREADY_M0 && RVALID_S0 && RLAST_S0) ? READ_IDLE : READ_M0S0;
        READ_M0S1:         R_next_state = (RREADY_M0 && RVALID_S1 && RLAST_S1) ? READ_IDLE : READ_M0S1;
        READ_M0S2:         R_next_state = (RREADY_M0 && RVALID_S2 && RLAST_S2) ? READ_IDLE : READ_M0S2;
        READ_M0S3:         R_next_state = (RREADY_M0 && RVALID_S3 && RLAST_S3) ? READ_IDLE : READ_M0S3;
        //READ_M0S4:       R_next_state = (RREADY_M0 && RVALID_S4 && RLAST_S4) ? READ_IDLE : READ_M0S4; // not used
        READ_M0S5:         R_next_state = (RREADY_M0 && RVALID_S5 && RLAST_S5) ? READ_IDLE : READ_M0S5;
        READ_M1S0:         R_next_state = (RREADY_M1 && RVALID_S0 && RLAST_S0) ? READ_IDLE : READ_M1S0;
        READ_M1S1:         R_next_state = (RREADY_M1 && RVALID_S1 && RLAST_S1) ? READ_IDLE : READ_M1S1;
        READ_M1S2:         R_next_state = (RREADY_M1 && RVALID_S2 && RLAST_S2) ? READ_IDLE : READ_M1S2;
        READ_M1S3:         R_next_state = (RREADY_M1 && RVALID_S3 && RLAST_S3) ? READ_IDLE : READ_M1S3;
        //READ_M1S4:       R_next_state = (RREADY_M1 && RVALID_S4 && RLAST_S4) ? READ_IDLE : READ_M1S4; // not used
        READ_M1S5:         R_next_state = (RREADY_M1 && RVALID_S5 && RLAST_S5) ? READ_IDLE : READ_M1S5;
        READ_M2S0:         R_next_state = (RREADY_M2 && RVALID_S0 && RLAST_S0) ? READ_IDLE : READ_M2S0;
        READ_M2S1:         R_next_state = (RREADY_M2 && RVALID_S1 && RLAST_S1) ? READ_IDLE : READ_M2S1;
        READ_M2S2:         R_next_state = (RREADY_M2 && RVALID_S2 && RLAST_S2) ? READ_IDLE : READ_M2S2;
        READ_M2S3:         R_next_state = (RREADY_M2 && RVALID_S3 && RLAST_S3) ? READ_IDLE : READ_M2S3;
        //READ_M2S4:       R_next_state = (RREADY_M2 && RVALID_S4 && RLAST_S4) ? READ_IDLE : READ_M2S4; // not used
        READ_M2S5:         R_next_state = (RREADY_M2 && RVALID_S5 && RLAST_S5) ? READ_IDLE : READ_M2S5;
        READ_M0S6:         R_next_state = (RREADY_M0 && RVALID_S6 && RLAST_S6) ? READ_IDLE : READ_M0S6;
        READ_M1S6:         R_next_state = (RREADY_M1 && RVALID_S6 && RLAST_S6) ? READ_IDLE : READ_M1S6;
        READ_M2S6:         R_next_state = (RREADY_M2 && RVALID_S6 && RLAST_S6) ? READ_IDLE : READ_M2S6;
        default:           R_next_state = READ_IDLE;
        endcase      
end  
// READ Master0
assign ARREADY_M0       = (R_cur_state == READ_M0S0) ? ARREADY_S0               :
                          (R_cur_state == READ_M0S1) ? ARREADY_S1               : 
                          (R_cur_state == READ_M0S2) ? ARREADY_S2               : 
                          (R_cur_state == READ_M0S3) ? ARREADY_S3               : 
                          //(R_cur_state == READ_M0S4) ? ARREADY_S4             : 
                          (R_cur_state == READ_M0S5) ? ARREADY_S5               : 
                          (R_cur_state == READ_M0S6) ? ARREADY_S6               : 1'b0;
assign RID_M0           = (R_cur_state == READ_M0S0) ? RID_S0[3:0]              :
                          (R_cur_state == READ_M0S1) ? RID_S1[3:0]              : 
                          (R_cur_state == READ_M0S2) ? RID_S2[3:0]              : 
                          (R_cur_state == READ_M0S3) ? RID_S3[3:0]              : 
                          //(R_cur_state == READ_M0S4) ? RID_S4[3:0]            : 
                          (R_cur_state == READ_M0S5) ? RID_S5[3:0]              : 
                          (R_cur_state == READ_M0S6) ? RID_S6[3:0]              : `AXI_ID_BITS'd0;
assign RDATA_M0         = (R_cur_state == READ_M0S0) ? RDATA_S0                 :
                          (R_cur_state == READ_M0S1) ? RDATA_S1                 : 
                          (R_cur_state == READ_M0S2) ? RDATA_S2                 : 
                          (R_cur_state == READ_M0S3) ? RDATA_S3                 : 
                          //(R_cur_state == READ_M0S4) ? RDATA_S4               : 
                          (R_cur_state == READ_M0S5) ? RDATA_S5                 : 
                          (R_cur_state == READ_M0S6) ? RDATA_S6                 : `AXI_DATA_BITS'd0;
assign RRESP_M0         = (R_cur_state == READ_M0S0) ? RRESP_S0                 :
                          (R_cur_state == READ_M0S1) ? RRESP_S1                 : 
                          (R_cur_state == READ_M0S2) ? RRESP_S2                 : 
                          (R_cur_state == READ_M0S3) ? RRESP_S3                 : 
                          //(R_cur_state == READ_M0S4) ? RRESP_S4               : 
                          (R_cur_state == READ_M0S5) ? RRESP_S5                 : 
                          (R_cur_state == READ_M0S6) ? RRESP_S6                 : 2'd0;
assign RLAST_M0         = (R_cur_state == READ_M0S0) ? RLAST_S0                 :
                          (R_cur_state == READ_M0S1) ? RLAST_S1                 : 
                          (R_cur_state == READ_M0S2) ? RLAST_S2                 : 
                          (R_cur_state == READ_M0S3) ? RLAST_S3                 : 
                          //(R_cur_state == READ_M0S4) ? RLAST_S4               : 
                          (R_cur_state == READ_M0S5) ? RLAST_S5                 : 
                          (R_cur_state == READ_M0S6) ? RLAST_S6                 : 1'b0;
assign RVALID_M0        = (R_cur_state == READ_M0S0) ? RVALID_S0                :
                          (R_cur_state == READ_M0S1) ? RVALID_S1                : 
                          (R_cur_state == READ_M0S2) ? RVALID_S2                : 
                          (R_cur_state == READ_M0S3) ? RVALID_S3                : 
                          //(R_cur_state == READ_M0S4) ? RVALID_S4              : 
                          (R_cur_state == READ_M0S5) ? RVALID_S5                :
                          (R_cur_state == READ_M0S6) ? RVALID_S6                : 1'b0;
// READ Master1
assign ARREADY_M1       = (R_cur_state == READ_M1S0) ? ARREADY_S0               :
                          (R_cur_state == READ_M1S1) ? ARREADY_S1               : 
                          (R_cur_state == READ_M1S2) ? ARREADY_S2               : 
                          (R_cur_state == READ_M1S3) ? ARREADY_S3               : 
                          //(R_cur_state == READ_M1S4) ? ARREADY_S4             : 
                          (R_cur_state == READ_M1S5) ? ARREADY_S5               : 
                          (R_cur_state == READ_M1S6) ? ARREADY_S6               : 1'b0;
assign RID_M1           = (R_cur_state == READ_M1S0) ? RID_S0[3:0]              :
                          (R_cur_state == READ_M1S1) ? RID_S1[3:0]              : 
                          (R_cur_state == READ_M1S2) ? RID_S2[3:0]              : 
                          (R_cur_state == READ_M1S3) ? RID_S3[3:0]              : 
                          //(R_cur_state == READ_M1S4) ? RID_S4[3:0]            : 
                          (R_cur_state == READ_M1S5) ? RID_S5[3:0]              : 
                          (R_cur_state == READ_M1S6) ? RID_S6[3:0]              : `AXI_ID_BITS'd0;
assign RDATA_M1         = (R_cur_state == READ_M1S0) ? RDATA_S0                 :
                          (R_cur_state == READ_M1S1) ? RDATA_S1                 : 
                          (R_cur_state == READ_M1S2) ? RDATA_S2                 : 
                          (R_cur_state == READ_M1S3) ? RDATA_S3                 : 
                          //(R_cur_state == READ_M1S4) ? RDATA_S4               : 
                          (R_cur_state == READ_M1S5) ? RDATA_S5                 : 
                          (R_cur_state == READ_M1S6) ? RDATA_S6                 : `AXI_DATA_BITS'd0;
assign RRESP_M1         = (R_cur_state == READ_M1S0) ? RRESP_S0                 :
                          (R_cur_state == READ_M1S1) ? RRESP_S1                 : 
                          (R_cur_state == READ_M1S2) ? RRESP_S2                 : 
                          (R_cur_state == READ_M1S3) ? RRESP_S3                 : 
                          //(R_cur_state == READ_M1S4) ? RRESP_S4               : 
                          (R_cur_state == READ_M1S5) ? RRESP_S5                 : 
                          (R_cur_state == READ_M1S6) ? RRESP_S6                 : 2'd0;
assign RLAST_M1         = (R_cur_state == READ_M1S0) ? RLAST_S0                 :
                          (R_cur_state == READ_M1S1) ? RLAST_S1                 : 
                          (R_cur_state == READ_M1S2) ? RLAST_S2                 : 
                          (R_cur_state == READ_M1S3) ? RLAST_S3                 : 
                          //(R_cur_state == READ_M1S4) ? RLAST_S4               : 
                          (R_cur_state == READ_M1S5) ? RLAST_S5                 :
                          (R_cur_state == READ_M1S6) ? RLAST_S6                 : 1'b0;
assign RVALID_M1        = (R_cur_state == READ_M1S0) ? RVALID_S0                :
                          (R_cur_state == READ_M1S1) ? RVALID_S1                : 
                          (R_cur_state == READ_M1S2) ? RVALID_S2                : 
                          (R_cur_state == READ_M1S3) ? RVALID_S3                : 
                          //(R_cur_state == READ_M1S4) ? RVALID_S4              : 
                          (R_cur_state == READ_M1S5) ? RVALID_S5                : 
                          (R_cur_state == READ_M1S6) ? RVALID_S6                : 1'b0;
// READ Master2
assign ARREADY_M2       = (R_cur_state == READ_M2S0) ? ARREADY_S0               :
                          (R_cur_state == READ_M2S1) ? ARREADY_S1               : 
                          (R_cur_state == READ_M2S2) ? ARREADY_S2               : 
                          (R_cur_state == READ_M2S3) ? ARREADY_S3               : 
                          //(R_cur_state == READ_M2S4) ? ARREADY_S4             : 
                          (R_cur_state == READ_M2S5) ? ARREADY_S5               : 
                          (R_cur_state == READ_M2S6) ? ARREADY_S6               : 1'b0;
assign RID_M2           = (R_cur_state == READ_M2S0) ? RID_S0[3:0]              :
                          (R_cur_state == READ_M2S1) ? RID_S1[3:0]              : 
                          (R_cur_state == READ_M2S2) ? RID_S2[3:0]              : 
                          (R_cur_state == READ_M2S3) ? RID_S3[3:0]              : 
                          //(R_cur_state == READ_M2S4) ? RID_S4[3:0]            : 
                          (R_cur_state == READ_M2S5) ? RID_S5[3:0]              :
                          (R_cur_state == READ_M2S6) ? RID_S6[3:0]              : `AXI_ID_BITS'd0;
assign RDATA_M2         = (R_cur_state == READ_M2S0) ? RDATA_S0                 :
                          (R_cur_state == READ_M2S1) ? RDATA_S1                 : 
                          (R_cur_state == READ_M2S2) ? RDATA_S2                 : 
                          (R_cur_state == READ_M2S3) ? RDATA_S3                 : 
                          //(R_cur_state == READ_M2S4) ? RDATA_S4               : 
                          (R_cur_state == READ_M2S5) ? RDATA_S5                 : 
                          (R_cur_state == READ_M2S6) ? RDATA_S6                 : `AXI_DATA_BITS'd0;
assign RRESP_M2         = (R_cur_state == READ_M2S0) ? RRESP_S0                 :
                          (R_cur_state == READ_M2S1) ? RRESP_S1                 : 
                          (R_cur_state == READ_M2S2) ? RRESP_S2                 : 
                          (R_cur_state == READ_M2S3) ? RRESP_S3                 : 
                          //(R_cur_state == READ_M2S4) ? RRESP_S4               : 
                          (R_cur_state == READ_M2S5) ? RRESP_S5                 : 
                          (R_cur_state == READ_M2S6) ? RRESP_S6                 : 2'd0;
assign RLAST_M2         = (R_cur_state == READ_M2S0) ? RLAST_S0                 :
                          (R_cur_state == READ_M2S1) ? RLAST_S1                 : 
                          (R_cur_state == READ_M2S2) ? RLAST_S2                 : 
                          (R_cur_state == READ_M2S3) ? RLAST_S3                 : 
                          //(R_cur_state == READ_M2S4) ? RLAST_S4               : 
                          (R_cur_state == READ_M2S5) ? RLAST_S5                 : 
                          (R_cur_state == READ_M2S6) ? RLAST_S6                 : 1'b0;
assign RVALID_M2        = (R_cur_state == READ_M2S0) ? RVALID_S0                :
                          (R_cur_state == READ_M2S1) ? RVALID_S1                : 
                          (R_cur_state == READ_M2S2) ? RVALID_S2                : 
                          (R_cur_state == READ_M2S3) ? RVALID_S3                : 
                          //(R_cur_state == READ_M2S4) ? RVALID_S4              : 
                          (R_cur_state == READ_M2S5) ? RVALID_S5                : 
                          (R_cur_state == READ_M2S6) ? RVALID_S6                : 1'b0;
// READ Slave0
assign ARID_S0          = (R_cur_state == READ_M0S0) ? {4'd0,ARID_M0}           :
                          (R_cur_state == READ_M1S0) ? {4'd0,ARID_M1}           : 
                          (R_cur_state == READ_M2S0) ? {4'd0,ARID_M2}           : `AXI_IDS_BITS'd0;
assign ARADDR_S0        = (R_cur_state == READ_M0S0) ? ARADDR_M0                :
                          (R_cur_state == READ_M1S0) ? ARADDR_M1                : 
                          (R_cur_state == READ_M2S0) ? ARADDR_M2                : `AXI_ADDR_BITS'd0;
assign ARLEN_S0         = (R_cur_state == READ_M0S0) ? ARLEN_M0                 :
                          (R_cur_state == READ_M1S0) ? ARLEN_M1                 : 
                          (R_cur_state == READ_M2S0) ? ARLEN_M2                 : `AXI_LEN_BITS'd0;
assign ARSIZE_S0        = (R_cur_state == READ_M0S0) ? ARSIZE_M0                :
                          (R_cur_state == READ_M1S0) ? ARSIZE_M1                : 
                          (R_cur_state == READ_M2S0) ? ARSIZE_M2                : `AXI_SIZE_BITS'd0;
assign ARBURST_S0       = (R_cur_state == READ_M0S0) ? ARBURST_M0               :
                          (R_cur_state == READ_M1S0) ? ARBURST_M1               : 
                          (R_cur_state == READ_M2S0) ? ARBURST_M2               : 2'd0;
assign ARVALID_S0       = (R_cur_state == READ_M0S0) ? ARVALID_M0               :
                          (R_cur_state == READ_M1S0) ? ARVALID_M1               : 
                          (R_cur_state == READ_M2S0) ? ARVALID_M2               : 1'b0;
assign RREADY_S0        = (R_cur_state == READ_M0S0) ? RREADY_M0                :
                          (R_cur_state == READ_M1S0) ? RREADY_M1                : 
                          (R_cur_state == READ_M2S0) ? RREADY_M2                : 1'b0;
// READ Slave1
assign ARID_S1          = (R_cur_state == READ_M0S1) ? {4'd0,ARID_M0}           :
                          (R_cur_state == READ_M1S1) ? {4'd0,ARID_M1}           : 
                          (R_cur_state == READ_M2S1) ? {4'd0,ARID_M2}           : `AXI_IDS_BITS'd0;
assign ARADDR_S1        = (R_cur_state == READ_M0S1) ? ARADDR_M0                :
                          (R_cur_state == READ_M1S1) ? ARADDR_M1                : 
                          (R_cur_state == READ_M2S1) ? ARADDR_M2                : `AXI_ADDR_BITS'd0;
assign ARLEN_S1         = (R_cur_state == READ_M0S1) ? ARLEN_M0                 :
                          (R_cur_state == READ_M1S1) ? ARLEN_M1                 : 
                          (R_cur_state == READ_M2S1) ? ARLEN_M2                 : `AXI_LEN_BITS'd0;
assign ARSIZE_S1        = (R_cur_state == READ_M0S1) ? ARSIZE_M0                :
                          (R_cur_state == READ_M1S1) ? ARSIZE_M1                : 
                          (R_cur_state == READ_M2S1) ? ARSIZE_M2                : `AXI_SIZE_BITS'd0;
assign ARBURST_S1       = (R_cur_state == READ_M0S1) ? ARBURST_M0               :
                          (R_cur_state == READ_M1S1) ? ARBURST_M1               : 
                          (R_cur_state == READ_M2S1) ? ARBURST_M2               : 2'd0;
assign ARVALID_S1       = (R_cur_state == READ_M0S1) ? ARVALID_M0               :               
                          (R_cur_state == READ_M1S1) ? ARVALID_M1               : 
                          (R_cur_state == READ_M2S1) ? ARVALID_M2               : 1'b0;
assign RREADY_S1        = (R_cur_state == READ_M0S1) ? RREADY_M0                :
                          (R_cur_state == READ_M1S1) ? RREADY_M1                : 
                          (R_cur_state == READ_M2S1) ? RREADY_M2                : 1'b0;
// READ Slave2
assign ARID_S2          = (R_cur_state == READ_M0S2) ? {4'd0,ARID_M0}           :
                          (R_cur_state == READ_M1S2) ? {4'd0,ARID_M1}           : 
                          (R_cur_state == READ_M2S2) ? {4'd0,ARID_M2}           : `AXI_IDS_BITS'd0;
assign ARADDR_S2        = (R_cur_state == READ_M0S2) ? ARADDR_M0                :
                          (R_cur_state == READ_M1S2) ? ARADDR_M1                : 
                          (R_cur_state == READ_M2S2) ? ARADDR_M2                : `AXI_ADDR_BITS'd0;
assign ARLEN_S2         = (R_cur_state == READ_M0S2) ? ARLEN_M0                 :
                          (R_cur_state == READ_M1S2) ? ARLEN_M1                 : 
                          (R_cur_state == READ_M2S2) ? ARLEN_M2                 : `AXI_LEN_BITS'd0;
assign ARSIZE_S2        = (R_cur_state == READ_M0S2) ? ARSIZE_M0                :
                          (R_cur_state == READ_M1S2) ? ARSIZE_M1                : 
                          (R_cur_state == READ_M2S2) ? ARSIZE_M2                : `AXI_SIZE_BITS'd0;
assign ARBURST_S2       = (R_cur_state == READ_M0S2) ? ARBURST_M0               :
                          (R_cur_state == READ_M1S2) ? ARBURST_M1               : 
                          (R_cur_state == READ_M2S2) ? ARBURST_M2               : 2'd0;
assign ARVALID_S2       = (R_cur_state == READ_M0S2) ? ARVALID_M0               :               
                          (R_cur_state == READ_M1S2) ? ARVALID_M1               : 
                          (R_cur_state == READ_M2S2) ? ARVALID_M2               : 1'b0;
assign RREADY_S2        = (R_cur_state == READ_M0S2) ? RREADY_M0                :
                          (R_cur_state == READ_M1S2) ? RREADY_M1                : 
                          (R_cur_state == READ_M2S2) ? RREADY_M2                : 1'b0;
// READ Slave3
assign ARID_S3          = (R_cur_state == READ_M0S3) ? {4'd0,ARID_M0}           :
                          (R_cur_state == READ_M1S3) ? {4'd0,ARID_M1}           : 
                          (R_cur_state == READ_M2S3) ? {4'd0,ARID_M2}           : `AXI_IDS_BITS'd0;
assign ARADDR_S3        = (R_cur_state == READ_M0S3) ? ARADDR_M0                :
                          (R_cur_state == READ_M1S3) ? ARADDR_M1                : 
                          (R_cur_state == READ_M2S3) ? ARADDR_M2                : `AXI_ADDR_BITS'd0;
assign ARLEN_S3         = (R_cur_state == READ_M0S3) ? ARLEN_M0                 :
                          (R_cur_state == READ_M1S3) ? ARLEN_M1                 : 
                          (R_cur_state == READ_M2S3) ? ARLEN_M2                 : `AXI_LEN_BITS'd0;
assign ARSIZE_S3        = (R_cur_state == READ_M0S3) ? ARSIZE_M0                :
                          (R_cur_state == READ_M1S3) ? ARSIZE_M1                : 
                          (R_cur_state == READ_M2S3) ? ARSIZE_M2                : `AXI_SIZE_BITS'd0;
assign ARBURST_S3       = (R_cur_state == READ_M0S3) ? ARBURST_M0               :
                          (R_cur_state == READ_M1S3) ? ARBURST_M1               : 
                          (R_cur_state == READ_M2S3) ? ARBURST_M2               : 2'd0;
assign ARVALID_S3       = (R_cur_state == READ_M0S3) ? ARVALID_M0               :               
                          (R_cur_state == READ_M1S3) ? ARVALID_M1               : 
                          (R_cur_state == READ_M2S3) ? ARVALID_M2               : 1'b0;
assign RREADY_S3        = (R_cur_state == READ_M0S3) ? RREADY_M0                :
                          (R_cur_state == READ_M1S3) ? RREADY_M1                : 
                          (R_cur_state == READ_M2S3) ? RREADY_M2                : 1'b0;
// READ Slave5
assign ARID_S5          = (R_cur_state == READ_M0S5) ? {4'd0,ARID_M0}           :
                          (R_cur_state == READ_M1S5) ? {4'd0,ARID_M1}           : 
                          (R_cur_state == READ_M2S5) ? {4'd0,ARID_M2}           : `AXI_IDS_BITS'd0;
assign ARADDR_S5        = (R_cur_state == READ_M0S5) ? ARADDR_M0                :
                          (R_cur_state == READ_M1S5) ? ARADDR_M1                : 
                          (R_cur_state == READ_M2S5) ? ARADDR_M2                : `AXI_ADDR_BITS'd0;
assign ARLEN_S5         = (R_cur_state == READ_M0S5) ? ARLEN_M0                 :
                          (R_cur_state == READ_M1S5) ? ARLEN_M1                 : 
                          (R_cur_state == READ_M2S5) ? ARLEN_M2                 : `AXI_LEN_BITS'd0;
assign ARSIZE_S5        = (R_cur_state == READ_M0S5) ? ARSIZE_M0                :
                          (R_cur_state == READ_M1S5) ? ARSIZE_M1                : 
                          (R_cur_state == READ_M2S5) ? ARSIZE_M2                : `AXI_SIZE_BITS'd0;
assign ARBURST_S5       = (R_cur_state == READ_M0S5) ? ARBURST_M0               :
                          (R_cur_state == READ_M1S5) ? ARBURST_M1               : 
                          (R_cur_state == READ_M2S5) ? ARBURST_M2               : 2'd0;
assign ARVALID_S5       = (R_cur_state == READ_M0S5) ? ARVALID_M0               :               
                          (R_cur_state == READ_M1S5) ? ARVALID_M1               : 
                          (R_cur_state == READ_M2S5) ? ARVALID_M2               : 1'b0;
assign RREADY_S5        = (R_cur_state == READ_M0S5) ? RREADY_M0                :
                          (R_cur_state == READ_M1S5) ? RREADY_M1                : 
                          (R_cur_state == READ_M2S5) ? RREADY_M2                : 1'b0;
// READ Slave6
assign ARID_S6          = (R_cur_state == READ_M0S6) ? {4'd0,ARID_M0}           :
                          (R_cur_state == READ_M1S6) ? {4'd0,ARID_M1}           : 
                          (R_cur_state == READ_M2S6) ? {4'd0,ARID_M2}           : `AXI_IDS_BITS'd0;
assign ARADDR_S6        = (R_cur_state == READ_M0S6) ? ARADDR_M0                :
                          (R_cur_state == READ_M1S6) ? ARADDR_M1                : 
                          (R_cur_state == READ_M2S6) ? ARADDR_M2                : `AXI_ADDR_BITS'd0;
assign ARLEN_S6         = (R_cur_state == READ_M0S6) ? ARLEN_M0                 :
                          (R_cur_state == READ_M1S6) ? ARLEN_M1                 : 
                          (R_cur_state == READ_M2S6) ? ARLEN_M2                 : `AXI_LEN_BITS'd0;
assign ARSIZE_S6        = (R_cur_state == READ_M0S6) ? ARSIZE_M0                :
                          (R_cur_state == READ_M1S6) ? ARSIZE_M1                : 
                          (R_cur_state == READ_M2S6) ? ARSIZE_M2                : `AXI_SIZE_BITS'd0;
assign ARBURST_S6       = (R_cur_state == READ_M0S6) ? ARBURST_M0               :
                          (R_cur_state == READ_M1S6) ? ARBURST_M1               : 
                          (R_cur_state == READ_M2S6) ? ARBURST_M2               : 2'd0;
assign ARVALID_S6       = (R_cur_state == READ_M0S6) ? ARVALID_M0               :               
                          (R_cur_state == READ_M1S6) ? ARVALID_M1               : 
                          (R_cur_state == READ_M2S6) ? ARVALID_M2               : 1'b0;
assign RREADY_S6        = (R_cur_state == READ_M0S6) ? RREADY_M0                :
                          (R_cur_state == READ_M1S6) ? RREADY_M1                : 
                          (R_cur_state == READ_M2S6) ? RREADY_M2                : 1'b0;


////////////////// ******** WRITE SIGNALS ******** //////////////////
always_ff@(posedge ACLK or negedge ARESETn)begin
        if(~ARESETn)    W_cur_state <= WRITE_IDLE;
        else            W_cur_state <= W_next_state;
end
// WRITE Finite State Machine
always_comb
begin
        case(W_cur_state)
        WRITE_IDLE:begin
        if(AWVALID_M2)begin
                if(AWADDR_M2[31:28] == 4'h2)
                                  W_next_state = WRITE_M2S5;
                else begin
                        case(AWADDR_M2[31:16])
                        // 16'h0000: W_next_state = WRITE_M2S0;
                        16'h0001: W_next_state = WRITE_M2S1;
                        16'h0002: W_next_state = WRITE_M2S2;
                        16'h1002: W_next_state = WRITE_M2S3;
                        16'h1001: W_next_state = WRITE_M2S4;
                        // 16'h2000: W_next_state = WRITE_M2S5;
                        16'h0003: W_next_state = WRITE_M2S6;
                        16'h0004: W_next_state = WRITE_M2S6;
                        16'h0005: W_next_state = WRITE_M2S6;
                        16'h0006: W_next_state = WRITE_M2S6;
                        default:  W_next_state = WRITE_IDLE;
                        endcase
                end
        end
        else if(AWVALID_M1)begin
                if(AWADDR_M1[31:28] == 4'h2)
                        W_next_state = WRITE_M1S5;
                else begin
                        case(AWADDR_M1[31:16])
                        // 16'h0000: W_next_state = WRITE_M1S0;
                        16'h0001: W_next_state = WRITE_M1S1;
                        16'h0002: W_next_state = WRITE_M1S2;
                        16'h1002: W_next_state = WRITE_M1S3;
                        16'h1001: W_next_state = WRITE_M1S4;
                        // 16'h2000: W_next_state = WRITE_M1S5;
                        16'h0003: W_next_state = WRITE_M1S6;
                        16'h0004: W_next_state = WRITE_M1S6;
                        16'h0005: W_next_state = WRITE_M1S6;
                        16'h0006: W_next_state = WRITE_M1S6;
                        default:  W_next_state = WRITE_IDLE;
                        endcase
                end
        end
        else               W_next_state = WRITE_IDLE;   
        end     
        //WRITE_M1S0:      W_next_state = (BREADY_M1 && BVALID_S0) ? WRITE_IDLE : WRITE_M1S0;
        WRITE_M1S1:        W_next_state = (BREADY_M1 && BVALID_S1) ? WRITE_IDLE : WRITE_M1S1;
        WRITE_M1S2:        W_next_state = (BREADY_M1 && BVALID_S2) ? WRITE_IDLE : WRITE_M1S2;
        WRITE_M1S3:        W_next_state = (BREADY_M1 && BVALID_S3) ? WRITE_IDLE : WRITE_M1S3;
        WRITE_M1S4:        W_next_state = (BREADY_M1 && BVALID_S4) ? WRITE_IDLE : WRITE_M1S4;
        WRITE_M1S5:        W_next_state = (BREADY_M1 && BVALID_S5) ? WRITE_IDLE : WRITE_M1S5;
        //WRITE_M2S0:      W_next_state = (BREADY_M2 && BVALID_S0) ? WRITE_IDLE : WRITE_M2S0;
        WRITE_M2S1:        W_next_state = (BREADY_M2 && BVALID_S1) ? WRITE_IDLE : WRITE_M2S1;
        WRITE_M2S2:        W_next_state = (BREADY_M2 && BVALID_S2) ? WRITE_IDLE : WRITE_M2S2;
        WRITE_M2S3:        W_next_state = (BREADY_M2 && BVALID_S3) ? WRITE_IDLE : WRITE_M2S3;
        WRITE_M2S4:        W_next_state = (BREADY_M2 && BVALID_S4) ? WRITE_IDLE : WRITE_M2S4;
        WRITE_M2S5:        W_next_state = (BREADY_M2 && BVALID_S5) ? WRITE_IDLE : WRITE_M2S5;
        WRITE_M1S6:        W_next_state = (BREADY_M1 && BVALID_S6) ? WRITE_IDLE : WRITE_M1S6;
        WRITE_M2S6:        W_next_state = (BREADY_M2 && BVALID_S6) ? WRITE_IDLE : WRITE_M2S6;
        default:           W_next_state = WRITE_IDLE;
        endcase
end
//WRITE Master1
assign AWREADY_M1       = //(W_cur_state == WRITE_M1S0) ? AWREADY_S0            :
                          (W_cur_state == WRITE_M1S1) ? AWREADY_S1              : 
                          (W_cur_state == WRITE_M1S2) ? AWREADY_S2              : 
                          (W_cur_state == WRITE_M1S3) ? AWREADY_S3              : 
                          (W_cur_state == WRITE_M1S4) ? AWREADY_S4              : 
                          (W_cur_state == WRITE_M1S5) ? AWREADY_S5              : 
                          (W_cur_state == WRITE_M1S6) ? AWREADY_S6              : 1'b0;
assign WREADY_M1        = //(W_cur_state == WRITE_M1S0) ? WREADY_S0             :
                          (W_cur_state == WRITE_M1S1) ? WREADY_S1               : 
                          (W_cur_state == WRITE_M1S2) ? WREADY_S2               : 
                          (W_cur_state == WRITE_M1S3) ? WREADY_S3               : 
                          (W_cur_state == WRITE_M1S4) ? WREADY_S4               : 
                          (W_cur_state == WRITE_M1S5) ? WREADY_S5               : 
                          (W_cur_state == WRITE_M1S6) ? WREADY_S6               : 1'b0;
assign BID_M1           = //(W_cur_state == WRITE_M1S0) ? BID_S0[3:0]           :
                          (W_cur_state == WRITE_M1S1) ? BID_S1[3:0]             : 
                          (W_cur_state == WRITE_M1S2) ? BID_S2[3:0]             : 
                          (W_cur_state == WRITE_M1S3) ? BID_S3[3:0]             : 
                          (W_cur_state == WRITE_M1S4) ? BID_S4[3:0]             : 
                          (W_cur_state == WRITE_M1S5) ? BID_S5[3:0]             : 
                          (W_cur_state == WRITE_M1S6) ? BID_S6[3:0]             : 1'b0;
assign BRESP_M1         = //(W_cur_state == WRITE_M1S0) ? BRESP_S0              :
                          (W_cur_state == WRITE_M1S1) ? BRESP_S1                : 
                          (W_cur_state == WRITE_M1S2) ? BRESP_S2                : 
                          (W_cur_state == WRITE_M1S3) ? BRESP_S3                : 
                          (W_cur_state == WRITE_M1S4) ? BRESP_S4                : 
                          (W_cur_state == WRITE_M1S5) ? BRESP_S5                : 
                          (W_cur_state == WRITE_M1S6) ? BRESP_S6                : 1'b0;
assign BVALID_M1        = //(W_cur_state == WRITE_M1S0) ? BVALID_S0             :
                          (W_cur_state == WRITE_M1S1) ? BVALID_S1               : 
                          (W_cur_state == WRITE_M1S2) ? BVALID_S2               : 
                          (W_cur_state == WRITE_M1S3) ? BVALID_S3               : 
                          (W_cur_state == WRITE_M1S4) ? BVALID_S4               : 
                          (W_cur_state == WRITE_M1S5) ? BVALID_S5               : 
                          (W_cur_state == WRITE_M1S6) ? BVALID_S6               : 1'b0;
//WRITE Master2
assign AWREADY_M2       = //(W_cur_state == WRITE_M2S0) ? AWREADY_S0            :
                          (W_cur_state == WRITE_M2S1) ? AWREADY_S1              : 
                          (W_cur_state == WRITE_M2S2) ? AWREADY_S2              : 
                          (W_cur_state == WRITE_M2S3) ? AWREADY_S3              : 
                          (W_cur_state == WRITE_M2S4) ? AWREADY_S4              : 
                          (W_cur_state == WRITE_M2S5) ? AWREADY_S5              : 
                          (W_cur_state == WRITE_M2S6) ? AWREADY_S6              : 1'b0;
assign WREADY_M2        = //(W_cur_state == WRITE_M2S0) ? WREADY_S0             :
                          (W_cur_state == WRITE_M2S1) ? WREADY_S1               : 
                          (W_cur_state == WRITE_M2S2) ? WREADY_S2               : 
                          (W_cur_state == WRITE_M2S3) ? WREADY_S3               : 
                          (W_cur_state == WRITE_M2S4) ? WREADY_S4               : 
                          (W_cur_state == WRITE_M2S5) ? WREADY_S5               : 
                          (W_cur_state == WRITE_M2S6) ? WREADY_S6               : 1'b0;
assign BID_M2           = //(W_cur_state == WRITE_M2S0) ? BID_S0[3:0]           :
                          (W_cur_state == WRITE_M2S1) ? BID_S1[3:0]             : 
                          (W_cur_state == WRITE_M2S2) ? BID_S2[3:0]             : 
                          (W_cur_state == WRITE_M2S3) ? BID_S3[3:0]             : 
                          (W_cur_state == WRITE_M2S4) ? BID_S4[3:0]             : 
                          (W_cur_state == WRITE_M2S5) ? BID_S5[3:0]             : 
                          (W_cur_state == WRITE_M2S6) ? BID_S6[3:0]             : 1'b0;
assign BRESP_M2         = //(W_cur_state == WRITE_M2S0) ? BRESP_S0              :
                          (W_cur_state == WRITE_M2S1) ? BRESP_S1                : 
                          (W_cur_state == WRITE_M2S2) ? BRESP_S2                : 
                          (W_cur_state == WRITE_M2S3) ? BRESP_S3                : 
                          (W_cur_state == WRITE_M2S4) ? BRESP_S4                : 
                          (W_cur_state == WRITE_M2S5) ? BRESP_S5                : 
                          (W_cur_state == WRITE_M2S6) ? BRESP_S6                : 1'b0;
assign BVALID_M2        = //(W_cur_state == WRITE_M2S0) ? BVALID_S0             :
                          (W_cur_state == WRITE_M2S1) ? BVALID_S1               : 
                          (W_cur_state == WRITE_M2S2) ? BVALID_S2               : 
                          (W_cur_state == WRITE_M2S3) ? BVALID_S3               : 
                          (W_cur_state == WRITE_M2S4) ? BVALID_S4               : 
                          (W_cur_state == WRITE_M2S5) ? BVALID_S5               : 
                          (W_cur_state == WRITE_M2S6) ? BVALID_S6               : 1'b0;
// WRITE Slave0
//assign AWID_S0          = //(W_cur_state == WRITE_M1S0) ? {4'd0,AWID_M1}        : 
//                          (W_cur_state == WRITE_M2S0) ? {4'd0,AWID_M2}          : `AXI_ID_BITS'd0;
//assign AWADDR_S0        = //(W_cur_state == WRITE_M1S0) ? AWADDR_M1             : 
//                          (W_cur_state == WRITE_M2S0) ? AWADDR_M2               : `AXI_ADDR_BITS'd0;
//assign AWLEN_S0         = //W_cur_state == WRITE_M1S0) ? AWLEN_M1              : 
//                          (W_cur_state == WRITE_M2S0) ? AWLEN_M2                : `AXI_LEN_BITS'd0;
//assign AWSIZE_S0        = //(W_cur_state == WRITE_M1S0) ? AWSIZE_M1             : 
//                          (W_cur_state == WRITE_M2S0) ? AWSIZE_M2               : `AXI_SIZE_BITS'd0;
//assign AWBURST_S0       = //(W_cur_state == WRITE_M1S0) ? AWBURST_M1            : 
//                          (W_cur_state == WRITE_M2S0) ? AWBURST_M2              : 2'd0;
//assign AWVALID_S0       = //(W_cur_state == WRITE_M1S0) ? AWVALID_M1            : 
//                          (W_cur_state == WRITE_M2S0) ? AWVALID_M2              : 1'd0;
//assign WDATA_S0         = //(W_cur_state == WRITE_M1S0) ? WDATA_M1              : 
//                          (W_cur_state == WRITE_M2S0) ? WDATA_M2                : `AXI_DATA_BITS'd0;
//assign WSTRB_S0         = //(W_cur_state == WRITE_M1S0) ? WSTRB_M1              : 
//                          (W_cur_state == WRITE_M2S0) ? WSTRB_M2                : {`AXI_STRB_BITS{1'b1}};
//assign WLAST_S0         = //(W_cur_state == WRITE_M1S0) ? WLAST_M1              : 
//                          (W_cur_state == WRITE_M2S0) ? WLAST_M2                : 1'd0;
//assign WVALID_S0        = //(W_cur_state == WRITE_M1S0) ? WVALID_M1             : 
//                          (W_cur_state == WRITE_M2S0) ? WVALID_M2               : 1'd0;
//assign BREADY_S0        = //(W_cur_state == WRITE_M1S0) ? BREADY_M1             : 
//                          (W_cur_state == WRITE_M2S0) ? BREADY_M2               : 1'd0;

// WRITE Slave1
assign AWID_S1          = (W_cur_state == WRITE_M1S1) ? {4'd0,AWID_M1}          : 
                          (W_cur_state == WRITE_M2S1) ? {4'd0,AWID_M2}          : `AXI_ID_BITS'd0;
assign AWADDR_S1        = (W_cur_state == WRITE_M1S1) ? AWADDR_M1               : 
                          (W_cur_state == WRITE_M2S1) ? AWADDR_M2               : `AXI_ADDR_BITS'd0;
assign AWLEN_S1         = (W_cur_state == WRITE_M1S1) ? AWLEN_M1                : 
                          (W_cur_state == WRITE_M2S1) ? AWLEN_M2                : `AXI_LEN_BITS'd0;
assign AWSIZE_S1        = (W_cur_state == WRITE_M1S1) ? AWSIZE_M1               : 
                          (W_cur_state == WRITE_M2S1) ? AWSIZE_M2               : `AXI_SIZE_BITS'd0;
assign AWBURST_S1       = (W_cur_state == WRITE_M1S1) ? AWBURST_M1              : 
                          (W_cur_state == WRITE_M2S1) ? AWBURST_M2              : 2'd0;
assign AWVALID_S1       = (W_cur_state == WRITE_M1S1) ? AWVALID_M1              : 
                          (W_cur_state == WRITE_M2S1) ? AWVALID_M2              : 1'd0;
assign WDATA_S1         = (W_cur_state == WRITE_M1S1) ? WDATA_M1                : 
                          (W_cur_state == WRITE_M2S1) ? WDATA_M2                : `AXI_DATA_BITS'd0;
assign WSTRB_S1         = (W_cur_state == WRITE_M1S1) ? WSTRB_M1                : 
                          (W_cur_state == WRITE_M2S1) ? WSTRB_M2                : {`AXI_STRB_BITS{1'b1}};
assign WLAST_S1         = (W_cur_state == WRITE_M1S1) ? WLAST_M1                : 
                          (W_cur_state == WRITE_M2S1) ? WLAST_M2                : 1'd0;
assign WVALID_S1        = (W_cur_state == WRITE_M1S1) ? WVALID_M1               : 
                          (W_cur_state == WRITE_M2S1) ? WVALID_M2               : 1'd0;
assign BREADY_S1        = (W_cur_state == WRITE_M1S1) ? BREADY_M1               : 
                          (W_cur_state == WRITE_M2S1) ? BREADY_M2               : 1'd0;

// WRITE Slave2
assign AWID_S2          = (W_cur_state == WRITE_M1S2) ? {4'd0,AWID_M1}          : 
                          (W_cur_state == WRITE_M2S2) ? {4'd0,AWID_M2}          : `AXI_ID_BITS'd0;
assign AWADDR_S2        = (W_cur_state == WRITE_M1S2) ? AWADDR_M1               : 
                          (W_cur_state == WRITE_M2S2) ? AWADDR_M2               : `AXI_ADDR_BITS'd0;
assign AWLEN_S2         = (W_cur_state == WRITE_M1S2) ? AWLEN_M1                : 
                          (W_cur_state == WRITE_M2S2) ? AWLEN_M2                : `AXI_LEN_BITS'd0;
assign AWSIZE_S2        = (W_cur_state == WRITE_M1S2) ? AWSIZE_M1               : 
                          (W_cur_state == WRITE_M2S2) ? AWSIZE_M2               : `AXI_SIZE_BITS'd0;
assign AWBURST_S2       = (W_cur_state == WRITE_M1S2) ? AWBURST_M1              : 
                          (W_cur_state == WRITE_M2S2) ? AWBURST_M2              : 2'd0;
assign AWVALID_S2       = (W_cur_state == WRITE_M1S2) ? AWVALID_M1              : 
                          (W_cur_state == WRITE_M2S2) ? AWVALID_M2              : 1'd0;
assign WDATA_S2         = (W_cur_state == WRITE_M1S2) ? WDATA_M1                : 
                          (W_cur_state == WRITE_M2S2) ? WDATA_M2                : `AXI_DATA_BITS'd0;
assign WSTRB_S2         = (W_cur_state == WRITE_M1S2) ? WSTRB_M1                : 
                          (W_cur_state == WRITE_M2S2) ? WSTRB_M2                : {`AXI_STRB_BITS{1'b1}};
assign WLAST_S2         = (W_cur_state == WRITE_M1S2) ? WLAST_M1                : 
                          (W_cur_state == WRITE_M2S2) ? WLAST_M2                : 1'd0;
assign WVALID_S2        = (W_cur_state == WRITE_M1S2) ? WVALID_M1               : 
                          (W_cur_state == WRITE_M2S2) ? WVALID_M2               : 1'd0;
assign BREADY_S2        = (W_cur_state == WRITE_M1S2) ? BREADY_M1               : 
                          (W_cur_state == WRITE_M2S2) ? BREADY_M2               : 1'd0;

// WRITE Slave3
assign AWID_S3          = (W_cur_state == WRITE_M1S3) ? {4'd0,AWID_M1}          : 
                          (W_cur_state == WRITE_M2S3) ? {4'd0,AWID_M2}          : `AXI_ID_BITS'd0;
assign AWADDR_S3        = (W_cur_state == WRITE_M1S3) ? AWADDR_M1               : 
                          (W_cur_state == WRITE_M2S3) ? AWADDR_M2               : `AXI_ADDR_BITS'd0;
assign AWLEN_S3         = (W_cur_state == WRITE_M1S3) ? AWLEN_M1                : 
                          (W_cur_state == WRITE_M2S3) ? AWLEN_M2                : `AXI_LEN_BITS'd0;
assign AWSIZE_S3        = (W_cur_state == WRITE_M1S3) ? AWSIZE_M1               : 
                          (W_cur_state == WRITE_M2S3) ? AWSIZE_M2               : `AXI_SIZE_BITS'd0;
assign AWBURST_S3       = (W_cur_state == WRITE_M1S3) ? AWBURST_M1              : 
                          (W_cur_state == WRITE_M2S3) ? AWBURST_M2              : 2'd0;
assign AWVALID_S3       = (W_cur_state == WRITE_M1S3) ? AWVALID_M1              : 
                          (W_cur_state == WRITE_M2S3) ? AWVALID_M2              : 1'd0;
assign WDATA_S3         = (W_cur_state == WRITE_M1S3) ? WDATA_M1                : 
                          (W_cur_state == WRITE_M2S3) ? WDATA_M2                : `AXI_DATA_BITS'd0;
assign WSTRB_S3         = (W_cur_state == WRITE_M1S3) ? WSTRB_M1                : 
                          (W_cur_state == WRITE_M2S3) ? WSTRB_M2                : {`AXI_STRB_BITS{1'b1}};
assign WLAST_S3         = (W_cur_state == WRITE_M1S3) ? WLAST_M1                : 
                          (W_cur_state == WRITE_M2S3) ? WLAST_M2                : 1'd0;
assign WVALID_S3        = (W_cur_state == WRITE_M1S3) ? WVALID_M1               : 
                          (W_cur_state == WRITE_M2S3) ? WVALID_M2               : 1'd0;
assign BREADY_S3        = (W_cur_state == WRITE_M1S3) ? BREADY_M1               : 
                          (W_cur_state == WRITE_M2S3) ? BREADY_M2               : 1'd0;

// WRITE Slave4
assign AWID_S4          = (W_cur_state == WRITE_M1S4) ? {4'd0,AWID_M1}          : 
                          (W_cur_state == WRITE_M2S4) ? {4'd0,AWID_M2}          : `AXI_ID_BITS'd0;
assign AWADDR_S4        = (W_cur_state == WRITE_M1S4) ? AWADDR_M1               : 
                          (W_cur_state == WRITE_M2S4) ? AWADDR_M2               : `AXI_ADDR_BITS'd0;
assign AWLEN_S4         = (W_cur_state == WRITE_M1S4) ? AWLEN_M1                : 
                          (W_cur_state == WRITE_M2S4) ? AWLEN_M2                : `AXI_LEN_BITS'd0;
assign AWSIZE_S4        = (W_cur_state == WRITE_M1S4) ? AWSIZE_M1               : 
                          (W_cur_state == WRITE_M2S4) ? AWSIZE_M2               : `AXI_SIZE_BITS'd0;
assign AWBURST_S4       = (W_cur_state == WRITE_M1S4) ? AWBURST_M1              : 
                          (W_cur_state == WRITE_M2S4) ? AWBURST_M2              : 2'd0;
assign AWVALID_S4       = (W_cur_state == WRITE_M1S4) ? AWVALID_M1              : 
                          (W_cur_state == WRITE_M2S4) ? AWVALID_M2              : 1'd0;
assign WDATA_S4         = (W_cur_state == WRITE_M1S4) ? WDATA_M1                : 
                          (W_cur_state == WRITE_M2S4) ? WDATA_M2                : `AXI_DATA_BITS'd0;
assign WSTRB_S4         = (W_cur_state == WRITE_M1S4) ? WSTRB_M1                : 
                          (W_cur_state == WRITE_M2S4) ? WSTRB_M2                : {`AXI_STRB_BITS{1'b1}};
assign WLAST_S4         = (W_cur_state == WRITE_M1S4) ? WLAST_M1                : 
                          (W_cur_state == WRITE_M2S4) ? WLAST_M2                : 1'd0;
assign WVALID_S4        = (W_cur_state == WRITE_M1S4) ? WVALID_M1               : 
                          (W_cur_state == WRITE_M2S4) ? WVALID_M2               : 1'd0;
assign BREADY_S4        = (W_cur_state == WRITE_M1S4) ? BREADY_M1               : 
                          (W_cur_state == WRITE_M2S4) ? BREADY_M2               : 1'd0;

// WRITE Slave5
assign AWID_S5          = (W_cur_state == WRITE_M1S5) ? {4'd0,AWID_M1}          : 
                          (W_cur_state == WRITE_M2S5) ? {4'd0,AWID_M2}          : `AXI_ID_BITS'd0;
assign AWADDR_S5        = (W_cur_state == WRITE_M1S5) ? AWADDR_M1               : 
                          (W_cur_state == WRITE_M2S5) ? AWADDR_M2               : `AXI_ADDR_BITS'd0;
assign AWLEN_S5         = (W_cur_state == WRITE_M1S5) ? AWLEN_M1                : 
                          (W_cur_state == WRITE_M2S5) ? AWLEN_M2                : `AXI_LEN_BITS'd0;
assign AWSIZE_S5        = (W_cur_state == WRITE_M1S5) ? AWSIZE_M1               : 
                          (W_cur_state == WRITE_M2S5) ? AWSIZE_M2               : `AXI_SIZE_BITS'd0;
assign AWBURST_S5       = (W_cur_state == WRITE_M1S5) ? AWBURST_M1              : 
                          (W_cur_state == WRITE_M2S5) ? AWBURST_M2              : 2'd0;
assign AWVALID_S5       = (W_cur_state == WRITE_M1S5) ? AWVALID_M1              : 
                          (W_cur_state == WRITE_M2S5) ? AWVALID_M2              : 1'd0;
assign WDATA_S5         = (W_cur_state == WRITE_M1S5) ? WDATA_M1                : 
                          (W_cur_state == WRITE_M2S5) ? WDATA_M2                : `AXI_DATA_BITS'd0;
assign WSTRB_S5         = (W_cur_state == WRITE_M1S5) ? WSTRB_M1                : 
                          (W_cur_state == WRITE_M2S5) ? WSTRB_M2                : {`AXI_STRB_BITS{1'b1}};
assign WLAST_S5         = (W_cur_state == WRITE_M1S5) ? WLAST_M1                : 
                          (W_cur_state == WRITE_M2S5) ? WLAST_M2                : 1'd0;
assign WVALID_S5        = (W_cur_state == WRITE_M1S5) ? WVALID_M1               : 
                          (W_cur_state == WRITE_M2S5) ? WVALID_M2               : 1'd0;
assign BREADY_S5        = (W_cur_state == WRITE_M1S5) ? BREADY_M1               : 
                          (W_cur_state == WRITE_M2S5) ? BREADY_M2               : 1'd0;

// WRITE Slave6
assign AWID_S6          = (W_cur_state == WRITE_M1S6) ? {4'd0,AWID_M1}          : 
                          (W_cur_state == WRITE_M2S6) ? {4'd0,AWID_M2}          : `AXI_ID_BITS'd0;
assign AWADDR_S6        = (W_cur_state == WRITE_M1S6) ? AWADDR_M1               : 
                          (W_cur_state == WRITE_M2S6) ? AWADDR_M2               : `AXI_ADDR_BITS'd0;
assign AWLEN_S6         = (W_cur_state == WRITE_M1S6) ? AWLEN_M1                : 
                          (W_cur_state == WRITE_M2S6) ? AWLEN_M2                : `AXI_LEN_BITS'd0;
assign AWSIZE_S6        = (W_cur_state == WRITE_M1S6) ? AWSIZE_M1               : 
                          (W_cur_state == WRITE_M2S6) ? AWSIZE_M2               : `AXI_SIZE_BITS'd0;
assign AWBURST_S6       = (W_cur_state == WRITE_M1S6) ? AWBURST_M1              : 
                          (W_cur_state == WRITE_M2S6) ? AWBURST_M2              : 2'd0;
assign AWVALID_S6       = (W_cur_state == WRITE_M1S6) ? AWVALID_M1              : 
                          (W_cur_state == WRITE_M2S6) ? AWVALID_M2              : 1'd0;
assign WDATA_S6         = (W_cur_state == WRITE_M1S6) ? WDATA_M1                : 
                          (W_cur_state == WRITE_M2S6) ? WDATA_M2                : `AXI_DATA_BITS'd0;
assign WSTRB_S6         = (W_cur_state == WRITE_M1S6) ? WSTRB_M1                : 
                          (W_cur_state == WRITE_M2S6) ? WSTRB_M2                : {`AXI_STRB_BITS{1'b1}};
assign WLAST_S6         = (W_cur_state == WRITE_M1S6) ? WLAST_M1                : 
                          (W_cur_state == WRITE_M2S6) ? WLAST_M2                : 1'd0;
assign WVALID_S6        = (W_cur_state == WRITE_M1S6) ? WVALID_M1               : 
                          (W_cur_state == WRITE_M2S6) ? WVALID_M2               : 1'd0;
assign BREADY_S6        = (W_cur_state == WRITE_M1S6) ? BREADY_M1               : 
                          (W_cur_state == WRITE_M2S6) ? BREADY_M2               : 1'd0;
endmodule
