// `include    "Reg_PC.sv"
// `include    "Reg_ID.sv"
// `include    "Decoder.sv"
// `include    "imm_gen.sv"
// `include    "RegFile.sv"
// `include    "FP_RegFile.sv"
// `include    "Reg_EX.sv"
// `include    "CSR.sv"
// `include    "ALU_DATA_ctlr.sv"
// `include    "ALU.sv"
// `include    "JB_unit.sv"
// `include    "Reg_MEM.sv"
// `include    "Reg_WB.sv"
// `include    "WB_DATA_ctlr.sv"
module CPU (
    input   logic           clk,
    input   logic           rst,
    input   logic           intr_wdt,
    input   logic           intr_dma,
    input   logic           intr_epu,
    input   logic   [31:0]  i_IM1_DO,
    input   logic   [31:0]  i_DM1_DO,
    input   logic   [3:0]   i_m0_state,
    input   logic   [4:0]   i_m1_state,

    output  logic           o_IM1_CEB,
    output  logic           o_IM1_WEB,
    output  logic   [31:0]  o_IM1_BWEB,
    output  logic   [29:0]  o_IM1_A,
    output  logic   [31:0]  o_IM1_DI,
    output  logic           o_DM1_CEB,
    output  logic           o_DM1_WEB,
    output  logic   [31:0]  o_DM1_BWEB,
    output  logic   [29:0]  o_DM1_A,
    output  logic   [31:0]  o_DM1_DI
);

// Outputs from Reg_PC
logic   [31:0]  Reg_PC_o_addr;
logic   [31:0]  Reg_PC_o_pc;
logic           Reg_PC_o_rst_1;
logic           Reg_PC_o_flush;
// Outputs from Reg_ID
logic   [31:0]  Reg_ID_o_pc;
logic   [31:0]  Reg_ID_o_inst;
// Outputs from Decoder
logic   [4:0]   Decoder_o_aluoperation;
logic   [4:0]   Decoder_o_rs1_index;
logic   [4:0]   Decoder_o_rs2_index;
logic   [4:0]   Decoder_o_rd_index;
logic           Decoder_o_wb_en;
logic           Decoder_o_wb_en_f;
logic           Decoder_o_alu_src2_imm;
logic   [1:0]   Decoder_o_ftype;
logic   [1:0]   Decoder_o_DM_write;
logic   [2:0]   Decoder_o_DM_read;
logic           Decoder_o_jalr;
logic           Decoder_o_jal;
logic           Decoder_o_branch;
logic   [2:0]   Decoder_o_wb_sel;
logic   [2:0]   Decoder_o_csr_sel;
logic   [11:0]  Decoder_o_csr_addr;
// Outputs from imm_gen
logic   [31:0]  imm_gen_o_imm;
// Outputs from RegFile
logic   [31:0]  RegFile_o_rs1_data;
logic   [31:0]  RegFile_o_rs2_data;
// Outputs from FP_RegFile
logic   [31:0]  FP_RegFile_o_frs1_data;
logic   [31:0]  FP_RegFile_o_frs2_data;
// STALL
logic           stall;
// Outputs from Reg_EX
//logic 	[31:0]	;
logic   [31:0]  Reg_EX_o_pc;
logic   [4:0]   Reg_EX_o_aluoperation;
logic   [4:0]   Reg_EX_o_rs1_index;
logic   [4:0]   Reg_EX_o_rs2_index;
logic   [31:0]  Reg_EX_o_rs1_data;
logic   [31:0]  Reg_EX_o_rs2_data;
logic   [31:0]  Reg_EX_o_frs1_data;
logic   [31:0]  Reg_EX_o_frs2_data;
logic   [31:0]  Reg_EX_o_imm;
logic   [4:0]   Reg_EX_o_rd_index;
logic           Reg_EX_o_wb_en;
logic           Reg_EX_o_wb_en_f;
logic           Reg_EX_o_alu_src2_imm;
logic   [1:0]   Reg_EX_o_ftype;
logic   [1:0]   Reg_EX_o_DM_write;
logic   [2:0]   Reg_EX_o_DM_read;
logic           Reg_EX_o_jalr;
logic           Reg_EX_o_jal;
logic           Reg_EX_o_branch;
logic   [2:0]   Reg_EX_o_wb_sel;
logic   [2:0]   Reg_EX_o_csr_sel;
logic   [11:0]  Reg_EX_o_csr_addr;
logic   [31:0]  Reg_EX_o_inst;
// Outputs from CSR
logic   [31:0]  CSR_o_csr_result;
logic           CSR_o_mret;
logic           CSR_o_intr;
logic   [31:0]  CSR_o_pc_mret;
logic   [31:0]  CSR_o_pc_intr;
logic           CSR_o_wait_WFI;
// Outputs from ALU_DATA_ctlr
logic   [31:0]  ALU_DATA_ctlr_o_src1;
logic   [31:0]  ALU_DATA_ctlr_o_src2;
logic   [31:0]  ALU_DATA_ctlr_o_rs2_data;
// Outputs from ALU
logic   [31:0]  ALU_o_aluresult;
// Outputs from JB_unit
logic   [31:0]  JB_unit_o_jb_pc;
logic           JB_unit_o_next_pc_sel;
logic   [31:0]  JB_unit_o_pc_4;
logic   [31:0]  JB_unit_o_pc_imm;
// Outputs from Reg_MEM
logic   [31:0]  Reg_MEM_o_aluresult;
logic   [4:0]   Reg_MEM_o_rd_index;
logic   [31:0]  Reg_MEM_o_rs2_data;
logic   [31:0]  Reg_MEM_o_imm;
logic           Reg_MEM_o_wb_en;
logic           Reg_MEM_o_wb_en_f;
logic   [1:0]   Reg_MEM_o_DM_write;
logic   [2:0]   Reg_MEM_o_DM_read;
logic   [2:0]   Reg_MEM_o_wb_sel;
logic   [31:0]  Reg_MEM_o_pc_4;
logic   [31:0]  Reg_MEM_o_pc_imm;
logic   [31:0]  Reg_MEM_o_csr_result;
// Outputs from Reg_WB
logic   [31:0]  Reg_WB_o_aluresult;
logic   [31:0]  Reg_WB_o_DM_out;
logic   [4:0]   Reg_WB_o_rd_index;
logic   [31:0]  Reg_WB_o_imm;
logic           Reg_WB_o_wb_en;
logic           Reg_WB_o_wb_en_f;
logic   [1:0]   Reg_WB_o_DM_write;
logic   [2:0]   Reg_WB_o_DM_read;
logic   [2:0]   Reg_WB_o_wb_sel;
logic   [31:0]  Reg_WB_o_pc_4;
logic   [31:0]  Reg_WB_o_pc_imm;
logic   [31:0]  Reg_WB_o_csr_result;
// Outputs from WB_DATA_ctlr
logic   [31:0]  WB_DATA_ctlr_o_wb_data;

logic           wait_IM1_read;
logic           wait_DM1;
logic           wait_DM1_read;
logic           wait_DM1_write;

///BPU
logic 			stall_IF;
logic 			BPU_o_pred_jump;
logic 			[31:0]BPU_o_pc_pred;
logic 			BPU_o_t_pnt;
logic			BPU_o_nt_pt;

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

Reg_PC u0_Reg_PC (
    .clk                    (clk                            ),
    .rst                    (rst                            ),
    .flush                  (Reg_PC_o_flush                 ),
    .stall                  (stall                          ),
    .i_wait_DM1             (wait_DM1                       ),
    .i_wait_WFI             (CSR_o_wait_WFI                 ),
    .i_wait_IM1_read        (wait_IM1_read                  ),
    .i_jb_pc                (JB_unit_o_jb_pc                ),
    .i_next_pc_sel          (JB_unit_o_next_pc_sel          ),
	.i_pred_jump			(BPU_o_pred_jump				),
	.i_pred_pc				(BPU_o_pc_pred					),
	.i_nt_pt				(BPU_o_nt_pt					),
	.i_t_pnt				(BPU_o_t_pnt					),
    .o_addr                 (Reg_PC_o_addr                  ),
    .o_pc                   (Reg_PC_o_pc                    ),
    .o_rst_1                (Reg_PC_o_rst_1                 )
);

BPU BPU(
    .clk					(clk							),
    .rst					(rst							),
    .stall_IF				(stall_IF						),
    .stall					(stall							),
    .E_op					(Reg_EX_o_inst[6:2]				),
    .E_real_jump			(ALU_o_aluresult[0] 			),
    .inst					(i_IM1_DO    					),
    .pc						({2'd0,o_IM1_A}					),
    .pred_jump				(BPU_o_pred_jump				),
    .pc_pred				(BPU_o_pc_pred					),
    .t_pnt					(BPU_o_t_pnt					),
    .nt_pt					(BPU_o_nt_pt					)
);

assign  stall_IF	= (wait_DM1 || wait_IM1_read)? 1'b1 : 1'b0;
assign  o_IM1_CEB   = !(i_m0_state == M0_st_IDLE);
assign  o_IM1_WEB   = 1'b1;
assign  o_IM1_BWEB  = 32'hffff_ffff;
assign  o_IM1_A     = Reg_PC_o_addr[29:0];
assign  o_IM1_DI    = 32'd0;

//assign  wait_IM1_read   = (!o_IM1_CEB) || (i_m0_state == M0_st_RDTAG) || (i_m0_state == M0_st_RDCHECK) || (i_m0_state == M0_st_RDCACHE) || (i_m0_state == M0_st_AR) || (i_m0_state == M0_st_R_wait) || (i_m0_state == M0_st_R_HS) || (i_m0_state == M0_st_R) || (i_m0_state == M0_st_SRAMTOCPU);
always_comb begin
    case (i_m0_state)
        M0_st_IDLE:         wait_IM1_read   = (!o_IM1_CEB)  ? 1'b1  : 1'b0;
        M0_st_RDTAG:        wait_IM1_read   = 1'b1;
        M0_st_RDCHECK:      wait_IM1_read   = 1'b1;
        M0_st_RDCACHE:      wait_IM1_read   = 1'b1;
        M0_st_CACHETOCPU:   wait_IM1_read   = 1'b0;
        M0_st_AR:           wait_IM1_read   = 1'b1;
        M0_st_R_wait:       wait_IM1_read   = 1'b1;
        M0_st_R_HS:         wait_IM1_read   = 1'b1;
        M0_st_R:            wait_IM1_read   = 1'b1;
        M0_st_RDUPCACHE:    wait_IM1_read   = 1'b1;
        M0_st_SRAMTOCPU:    wait_IM1_read   = 1'b0;
        default:            wait_IM1_read   = 1'b0;
    endcase
end

Reg_ID u0_Reg_ID (
    .clk                    (clk                            ),
    .rst                    (rst                            ),
    .flush                  (Reg_PC_o_flush                 ),
    .stall                  (stall                          ),
	.i_nt_pt				(BPU_o_nt_pt					),
	.i_t_pnt				(BPU_o_t_pnt					),
    .i_wait_DM1             (wait_DM1                       ),
    .i_wait_WFI             (CSR_o_wait_WFI                 ),
    .i_wait_IM1_read        (wait_IM1_read                  ),
    .i_pc                   (Reg_PC_o_pc                    ),
    .i_inst                 (i_IM1_DO                       ),
    .o_pc                   (Reg_ID_o_pc                    ),
    .o_inst                 (Reg_ID_o_inst                  )
);

Decoder u0_Decoder (
    .i_inst                 (Reg_ID_o_inst                  ),
    .o_aluoperation         (Decoder_o_aluoperation         ),
    .o_rs1_index            (Decoder_o_rs1_index            ),
    .o_rs2_index            (Decoder_o_rs2_index            ),
    .o_rd_index             (Decoder_o_rd_index             ),
    .o_wb_en                (Decoder_o_wb_en                ),
    .o_wb_en_f              (Decoder_o_wb_en_f              ),
    .o_alu_src2_imm         (Decoder_o_alu_src2_imm         ),
    .o_ftype                (Decoder_o_ftype                ),
    .o_DM_write             (Decoder_o_DM_write             ),
    .o_DM_read              (Decoder_o_DM_read              ),
    .o_jalr                 (Decoder_o_jalr                 ),
    .o_jal                  (Decoder_o_jal                  ),
    .o_branch               (Decoder_o_branch               ),
    .o_wb_sel               (Decoder_o_wb_sel               ),
    .o_csr_sel              (Decoder_o_csr_sel              ),
    .o_csr_addr             (Decoder_o_csr_addr             )
);

imm_gen u0_imm_gen (
    .i_inst                 (Reg_ID_o_inst                  ),
    .o_imm                  (imm_gen_o_imm                  )
);

RegFile u0_RegFile (
    .clk                    (clk                            ),
    .rst                    (rst                            ),
    .i_rs1_index            (Decoder_o_rs1_index            ),
    .i_rs2_index            (Decoder_o_rs2_index            ),
    .i_W_wb_data            (WB_DATA_ctlr_o_wb_data         ),
    .i_W_wb_en              (Reg_WB_o_wb_en                 ),
    .i_W_rd_index           (Reg_WB_o_rd_index              ),
    .o_rs1_data             (RegFile_o_rs1_data             ),
    .o_rs2_data             (RegFile_o_rs2_data             )
);

FP_RegFile u0_FP_RegFile (
    .clk                    (clk                            ),
    .rst                    (rst                            ),
    .i_frs1_index           (Decoder_o_rs1_index            ),
    .i_frs2_index           (Decoder_o_rs2_index            ),
    .i_W_wb_data            (WB_DATA_ctlr_o_wb_data         ),
    .i_W_wb_en_f            (Reg_WB_o_wb_en_f               ),
    .i_W_frd_index          (Reg_WB_o_rd_index              ),
    .o_frs1_data            (FP_RegFile_o_frs1_data         ),
    .o_frs2_data            (FP_RegFile_o_frs2_data         )
);

assign  stall = (|Reg_EX_o_DM_read) ? ((Reg_EX_o_rd_index == Decoder_o_rs1_index) || (Reg_EX_o_rd_index == Decoder_o_rs2_index)) : 1'b0;

Reg_EX u0_Reg_EX (
    .clk                    (clk                            ),
    .rst                    (rst                            ),
    .stall                  (stall                          ),
	.i_t_pnt				(BPU_o_t_pnt					),
	.i_nt_pt				(BPU_o_nt_pt					),
	.i_inst					(Reg_ID_o_inst					),
    .i_wait_DM1             (wait_DM1                       ),
    .i_wait_WFI             (CSR_o_wait_WFI                 ),
    .i_pc                   (Reg_ID_o_pc                    ),
    .i_aluoperation         (Decoder_o_aluoperation         ),
    .i_rs1_index            (Decoder_o_rs1_index            ),
    .i_rs2_index            (Decoder_o_rs2_index            ),
    .i_rs1_data             (RegFile_o_rs1_data             ),
    .i_rs2_data             (RegFile_o_rs2_data             ),
    .i_frs1_data            (FP_RegFile_o_frs1_data         ),
    .i_frs2_data            (FP_RegFile_o_frs2_data         ),
    .i_imm                  (imm_gen_o_imm                  ),
    .i_rd_index             (Decoder_o_rd_index             ),
    .i_wb_en                (Decoder_o_wb_en                ),
    .i_wb_en_f              (Decoder_o_wb_en_f              ),
    .i_alu_src2_imm         (Decoder_o_alu_src2_imm         ),
    .i_ftype                (Decoder_o_ftype                ),
    .i_DM_write             (Decoder_o_DM_write             ),
    .i_DM_read              (Decoder_o_DM_read              ),
    .i_jalr                 (Decoder_o_jalr                 ),
    .i_jal                  (Decoder_o_jal                  ),
    .i_branch               (Decoder_o_branch               ),
    .i_wb_sel               (Decoder_o_wb_sel               ),
    .i_csr_sel              (Decoder_o_csr_sel              ),
    .i_csr_addr             (Decoder_o_csr_addr             ),
	.o_inst					(Reg_EX_o_inst					),
    .o_pc                   (Reg_EX_o_pc                    ),
    .o_aluoperation         (Reg_EX_o_aluoperation          ),
    .o_rs1_index            (Reg_EX_o_rs1_index             ),
    .o_rs2_index            (Reg_EX_o_rs2_index             ),
    .o_rs1_data             (Reg_EX_o_rs1_data              ),
    .o_rs2_data             (Reg_EX_o_rs2_data              ),
    .o_frs1_data            (Reg_EX_o_frs1_data             ),
    .o_frs2_data            (Reg_EX_o_frs2_data             ),
    .o_imm                  (Reg_EX_o_imm                   ),
    .o_rd_index             (Reg_EX_o_rd_index              ),
    .o_wb_en                (Reg_EX_o_wb_en                 ),
    .o_wb_en_f              (Reg_EX_o_wb_en_f               ),
    .o_alu_src2_imm         (Reg_EX_o_alu_src2_imm          ),
    .o_ftype                (Reg_EX_o_ftype                 ),
    .o_DM_write             (Reg_EX_o_DM_write              ),
    .o_DM_read              (Reg_EX_o_DM_read               ),
    .o_jalr                 (Reg_EX_o_jalr                  ),
    .o_jal                  (Reg_EX_o_jal                   ),
    .o_branch               (Reg_EX_o_branch                ),
    .o_wb_sel               (Reg_EX_o_wb_sel                ),
    .o_csr_sel              (Reg_EX_o_csr_sel               ),
    .o_csr_addr             (Reg_EX_o_csr_addr              )
);

assign  intr_dma_epu    = intr_dma || intr_epu;

CSR u0_CSR (
    .clk                    (clk                            ),
    .rst                    (rst                            ),
    .i_rst_1                (Reg_PC_o_rst_1                 ),
    .i_pc                   (Reg_PC_o_pc                    ),
    .i_csr_sel              (Reg_EX_o_csr_sel               ),
    .i_csr_addr             (Reg_EX_o_csr_addr              ),
    .i_rs1_data             (ALU_DATA_ctlr_o_src1           ),
    .i_imm                  (Reg_EX_o_imm                   ),
    .i_intr_dma             (intr_dma_epu                   ),
    .i_intr_wdt             (intr_wdt                       ),
    .o_csr_result           (CSR_o_csr_result               ),
    .o_mret                 (CSR_o_mret                     ),
    .o_intr                 (CSR_o_intr                     ),
    .o_pc_mret              (CSR_o_pc_mret                  ),
    .o_pc_intr              (CSR_o_pc_intr                  ),
    .o_wait_WFI             (CSR_o_wait_WFI                 )
);

ALU_DATA_ctlr u0_ALU_DATA_ctlr (
    .i_E_rs1_index          (Reg_EX_o_rs1_index             ),
    .i_E_rs2_index          (Reg_EX_o_rs2_index             ),
    .i_E_rs1_data           (Reg_EX_o_rs1_data              ),
    .i_E_rs2_data           (Reg_EX_o_rs2_data              ),
    .i_E_frs1_data          (Reg_EX_o_frs1_data             ),
    .i_E_frs2_data          (Reg_EX_o_frs2_data             ),
    .i_E_imm                (Reg_EX_o_imm                   ),
    .i_E_alu_rs2_imm        (Reg_EX_o_alu_src2_imm          ),
    .i_E_ftype              (Reg_EX_o_ftype                 ),
    .i_M_rd_index           (Reg_MEM_o_rd_index             ),
    .i_M_wb_en              (Reg_MEM_o_wb_en                ),
    .i_M_wb_en_f            (Reg_MEM_o_wb_en_f              ),
    .i_M_aluresult          (Reg_MEM_o_aluresult            ),
    .i_M_imm                (Reg_MEM_o_imm                  ),
    .i_M_pc_4               (Reg_MEM_o_pc_4                 ),
    .i_M_pc_imm             (Reg_MEM_o_pc_imm               ),
    .i_M_csr_result         (Reg_MEM_o_csr_result           ),
    .i_M_wb_sel             (Reg_MEM_o_wb_sel               ),
    .i_W_rd_index           (Reg_WB_o_rd_index              ),
    .i_W_wb_en              (Reg_WB_o_wb_en                 ),
    .i_W_wb_en_f            (Reg_WB_o_wb_en_f               ),
    .i_W_wb_data            (WB_DATA_ctlr_o_wb_data         ),
    .o_src1                 (ALU_DATA_ctlr_o_src1           ),
    .o_src2                 (ALU_DATA_ctlr_o_src2           ),
    .o_rs2_data             (ALU_DATA_ctlr_o_rs2_data       )
);

ALU u0_ALU (
    .i_aluoperation         (Reg_EX_o_aluoperation          ),
    .i_src1                 (ALU_DATA_ctlr_o_src1           ),
    .i_src2                 (ALU_DATA_ctlr_o_src2           ),
    .o_aluresult            (ALU_o_aluresult                )
);

JB_unit u0_JB_unit (
    .i_rs1_data             (ALU_DATA_ctlr_o_src1           ),
    .i_pc                   (Reg_EX_o_pc                    ),
    .i_imm                  (Reg_EX_o_imm                   ),
    .i_aluresult0           (ALU_o_aluresult[0]             ),
    .i_jalr                 (Reg_EX_o_jalr                  ),
    .i_jal                  (Reg_EX_o_jal                   ),
    .i_branch               (Reg_EX_o_branch                ),
    .i_mret                 (CSR_o_mret                     ),
    .i_intr                 (CSR_o_intr                     ),
    .i_pc_mret              (CSR_o_pc_mret                  ),
    .i_pc_intr              (CSR_o_pc_intr                  ),
    .o_jb_pc                (JB_unit_o_jb_pc                ),
    .o_next_pc_sel          (JB_unit_o_next_pc_sel          ),
    .o_pc_4                 (JB_unit_o_pc_4                 ),
    .o_pc_imm               (JB_unit_o_pc_imm               )
);
 
Reg_MEM u0_Reg_MEM (
    .clk                    (clk                            ),
    .rst                    (rst                            ),
    .i_wait_DM1             (wait_DM1                       ),
    .i_wait_WFI             (CSR_o_wait_WFI                 ),
    .i_aluresult            (ALU_o_aluresult                ),
    .i_rd_index             (Reg_EX_o_rd_index              ),
    .i_rs2_data             (ALU_DATA_ctlr_o_rs2_data       ),
    .i_imm                  (Reg_EX_o_imm                   ),
    .i_wb_en                (Reg_EX_o_wb_en                 ),
    .i_wb_en_f              (Reg_EX_o_wb_en_f               ),
    .i_DM_write             (Reg_EX_o_DM_write              ),
    .i_DM_read              (Reg_EX_o_DM_read               ),
    .i_wb_sel               (Reg_EX_o_wb_sel                ),
    .i_pc_4                 (JB_unit_o_pc_4                 ),
    .i_pc_imm               (JB_unit_o_pc_imm               ),
    .i_csr_result           (CSR_o_csr_result               ),
    .o_aluresult            (Reg_MEM_o_aluresult            ),
    .o_rd_index             (Reg_MEM_o_rd_index             ),
    .o_rs2_data             (Reg_MEM_o_rs2_data             ),
    .o_imm                  (Reg_MEM_o_imm                  ),
    .o_wb_en                (Reg_MEM_o_wb_en                ),
    .o_wb_en_f              (Reg_MEM_o_wb_en_f              ),
    .o_DM_write             (Reg_MEM_o_DM_write             ),
    .o_DM_read              (Reg_MEM_o_DM_read              ),
    .o_wb_sel               (Reg_MEM_o_wb_sel               ),
    .o_pc_4                 (Reg_MEM_o_pc_4                 ),
    .o_pc_imm               (Reg_MEM_o_pc_imm               ),
    .o_csr_result           (Reg_MEM_o_csr_result           )
);
 
assign  o_DM1_CEB   =   ~((|{Reg_MEM_o_DM_read, Reg_MEM_o_DM_write})/* & (i_m1_state == M1_st_IDLE)*/);
assign  o_DM1_WEB   =   ~((|Reg_MEM_o_DM_write) /*& (i_m1_state == M1_st_IDLE)*/);
always_comb begin
    case ({Reg_MEM_o_DM_write, Reg_MEM_o_aluresult[1:0]})
        4'b11_00:   o_DM1_BWEB  =   32'd0;
        4'b11_01:   o_DM1_BWEB  =   32'd0;
        4'b11_10:   o_DM1_BWEB  =   32'd0;
        4'b11_11:   o_DM1_BWEB  =   32'd0;
        4'b10_00:   o_DM1_BWEB  =   {16'hffff, 16'd0};
        4'b10_01:   o_DM1_BWEB  =   {8'hff, 16'd0, 8'hff};
        4'b10_10:   o_DM1_BWEB  =   {16'd0, 16'hffff};
        4'b10_11:   o_DM1_BWEB  =   {8'd0, 24'hffff_ff};
        4'b01_00:   o_DM1_BWEB  =   {24'hffff_ff, 8'd0};
        4'b01_01:   o_DM1_BWEB  =   {16'hffff, 8'd0, 8'hff};
        4'b01_10:   o_DM1_BWEB  =   {8'hff, 8'd0, 16'hffff};
        4'b01_11:   o_DM1_BWEB  =   {8'd0, 24'hffff_ff};
        default:    o_DM1_BWEB  =   32'hffff_ffff;
    endcase
end
assign  o_DM1_A     =   Reg_MEM_o_aluresult[31:2];

always_comb begin
    case ({Reg_MEM_o_DM_write, Reg_MEM_o_aluresult[1:0]})
        4'b11_00:   o_DM1_DI    =   Reg_MEM_o_rs2_data;
        4'b11_01:   o_DM1_DI    =   Reg_MEM_o_rs2_data;
        4'b11_10:   o_DM1_DI    =   Reg_MEM_o_rs2_data;
        4'b11_11:   o_DM1_DI    =   Reg_MEM_o_rs2_data;
        4'b10_00:   o_DM1_DI    =   {{16{Reg_MEM_o_rs2_data[15]}}, Reg_MEM_o_rs2_data[15:0]};
        4'b10_01:   o_DM1_DI    =   {{8{Reg_MEM_o_rs2_data[15]}}, Reg_MEM_o_rs2_data[15:0], 8'd0};
        4'b10_10:   o_DM1_DI    =   {Reg_MEM_o_rs2_data[15:0], 16'd0};
        4'b01_00:   o_DM1_DI    =   {{24{Reg_MEM_o_rs2_data[7]}}, Reg_MEM_o_rs2_data[7:0]};
        4'b01_01:   o_DM1_DI    =   {{16{Reg_MEM_o_rs2_data[15]}}, Reg_MEM_o_rs2_data[7:0], 8'd0};
        4'b01_10:   o_DM1_DI    =   {{8{Reg_MEM_o_rs2_data[23]}}, Reg_MEM_o_rs2_data[7:0], 16'd0};   
        4'b01_11:   o_DM1_DI    =   {Reg_MEM_o_rs2_data[7:0], 24'd0};
        default:    o_DM1_DI    =   Reg_MEM_o_rs2_data;
    endcase
end
//assign  wait_DM1_read   = ((!o_DM1_CEB) & o_DM1_WEB & (i_m1_state == M1_st_IDLE)) || (i_m1_state == M1_st_RDTAG) || (i_m1_state == M1_st_AR) || (i_m1_state == M1_st_R_wait) || (i_m1_state == M1_st_R_HS);
always_comb begin
    case (i_m1_state)
        M1_st_IDLE:         wait_DM1_read   = ((!o_DM1_CEB) && o_DM1_WEB)   ? 1'b1  : 1'b0;
        M1_st_RDTAG:        wait_DM1_read   = 1'b1;
        M1_st_RDCHECK:      wait_DM1_read   = 1'b1;
        M1_st_RDCACHE:      wait_DM1_read   = 1'b1;
        M1_st_CACHETOCPU:   wait_DM1_read   = 1'b0;
        M1_st_AR:           wait_DM1_read   = 1'b1;
        M1_st_R_wait:       wait_DM1_read   = 1'b1;
        M1_st_R_HS:         wait_DM1_read   = 1'b1;
        M1_st_R:            wait_DM1_read   = 1'b1;
        M1_st_RDUPCACHE:    wait_DM1_read   = 1'b1;
        M1_st_SRAMTOCPU:    wait_DM1_read   = 1'b0;
        M1_st_WRTAG:        wait_DM1_read   = 1'b0;
        M1_st_WRCHECK:      wait_DM1_read   = 1'b0;
        M1_st_WRCACHE:      wait_DM1_read   = 1'b0;
        M1_st_AW:           wait_DM1_read   = 1'b0;
        M1_st_W:            wait_DM1_read   = 1'b0;
        M1_st_B_HS:         wait_DM1_read   = 1'b0;
        M1_st_B:            wait_DM1_read   = 1'b0;
        default:            wait_DM1_read   = 1'b0;
    endcase
end
//assign  wait_DM1_write  = /*((!o_DM1_CEB) & (!o_DM1_WEB)) ||*/ (i_m1_state == M1_st_AW) || (i_m1_state == M1_st_W) || (i_m1_state == M1_st_B_HS) || (i_m1_state == M1_st_B);
always_comb begin
    case (i_m1_state)
        M1_st_IDLE:         wait_DM1_write   = 1'b0;
        M1_st_RDTAG:        wait_DM1_write   = 1'b0;
        M1_st_RDCHECK:      wait_DM1_write   = 1'b0;
        M1_st_RDCACHE:      wait_DM1_write   = 1'b0;
        M1_st_CACHETOCPU:   wait_DM1_write   = 1'b0;
        M1_st_AR:           wait_DM1_write   = 1'b0;
        M1_st_R_wait:       wait_DM1_write   = 1'b0;
        M1_st_R_HS:         wait_DM1_write   = 1'b0;
        M1_st_R:            wait_DM1_write   = 1'b0;
        M1_st_RDUPCACHE:    wait_DM1_write   = 1'b0;
        M1_st_SRAMTOCPU:    wait_DM1_write   = 1'b0;
        M1_st_WRTAG:        wait_DM1_write   = 1'b1;
        M1_st_WRCHECK:      wait_DM1_write   = 1'b1;
        M1_st_WRCACHE:      wait_DM1_write   = 1'b1;
        M1_st_AW:           wait_DM1_write   = 1'b1;
        M1_st_W:            wait_DM1_write   = 1'b1;
        M1_st_B_HS:         wait_DM1_write   = 1'b1;
        M1_st_B:            wait_DM1_write   = 1'b1;
        default:            wait_DM1_write   = 1'b0;
    endcase
end

assign  wait_DM1        = wait_DM1_read || wait_DM1_write;

Reg_WB u0_Reg_WB (
    .clk                    (clk                            ),
    .rst                    (rst                            ),
    .i_wait_DM1             (wait_DM1                       ),
    .i_wait_WFI             (CSR_o_wait_WFI                 ),
    .i_aluresult            (Reg_MEM_o_aluresult            ),
    .i_rd_index             (Reg_MEM_o_rd_index             ),
    .i_imm                  (Reg_MEM_o_imm                  ),
    .i_dm_out               (i_DM1_DO                       ),
    .i_wb_en                (Reg_MEM_o_wb_en                ),
    .i_wb_en_f              (Reg_MEM_o_wb_en_f              ),
    .i_DM_write             (Reg_MEM_o_DM_write             ),
    .i_DM_read              (Reg_MEM_o_DM_read              ),
    .i_wb_sel               (Reg_MEM_o_wb_sel               ),
    .i_pc_4                 (Reg_MEM_o_pc_4                 ),
    .i_pc_imm               (Reg_MEM_o_pc_imm               ),
    .i_csr_result           (Reg_MEM_o_csr_result           ),
    .o_aluresult            (Reg_WB_o_aluresult             ),
    .o_dm_out               (Reg_WB_o_DM_out                ),
    .o_rd_index             (Reg_WB_o_rd_index              ),
    .o_imm                  (Reg_WB_o_imm                   ),
    .o_wb_en                (Reg_WB_o_wb_en                 ),
    .o_wb_en_f              (Reg_WB_o_wb_en_f               ),
    .o_DM_write             (Reg_WB_o_DM_write              ),
    .o_DM_read              (Reg_WB_o_DM_read               ),
    .o_wb_sel               (Reg_WB_o_wb_sel                ),
    .o_pc_4                 (Reg_WB_o_pc_4                  ),
    .o_pc_imm               (Reg_WB_o_pc_imm                ),
    .o_csr_result           (Reg_WB_o_csr_result            )
);

WB_DATA_ctlr u0_WB_DATA_ctlr (
    .i_aluresult            (Reg_WB_o_aluresult             ),
    .i_dm_out               (Reg_WB_o_DM_out                ),
    .i_imm                  (Reg_WB_o_imm                   ),
    .i_pc_4                 (Reg_WB_o_pc_4                  ),
    .i_pc_imm               (Reg_WB_o_pc_imm                ),
    .i_DM_read              (Reg_WB_o_DM_read               ),
    .i_wb_sel               (Reg_WB_o_wb_sel                ),
    .i_csr_result           (Reg_WB_o_csr_result            ),
    .o_wb_data              (WB_DATA_ctlr_o_wb_data         )
);

endmodule