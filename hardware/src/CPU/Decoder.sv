module Decoder (
input           [31:0]  i_inst,
output  logic   [4:0]   o_aluoperation,
output  logic   [4:0]   o_rs1_index,
output  logic   [4:0]   o_rs2_index,
output  logic   [4:0]   o_rd_index,
output  logic           o_wb_en,
output  logic           o_wb_en_f,
output  logic           o_alu_src2_imm,
output  logic   [1:0]   o_ftype,
output  logic   [1:0]   o_DM_write,         // 1 SB, 2 SH, 3 SW/FSW
output  logic   [2:0]   o_DM_read,          // 1 LB, 2 LH, 3 LW/FLW, 4 LBU, 5 LHU
output  logic           o_jalr,
output  logic           o_jal,
output  logic           o_branch,
output  logic   [2:0]   o_wb_sel,           // 0 alu, 1 dm, 2 imm, 3 pc_4, 4 pc_imm, 5 csr
output  logic   [2:0]   o_csr_sel,          // 1 CSRRW
                                            // 2 CSRRS, RDINSTRETH, RDINSTRET, RDCYCLEH, RDCYCLE
                                            // 3 CSRRC
                                            // 4 CSRRWI
                                            // 5 CSRRSI
                                            // 6 CSRRCI
output  logic   [11:0]  o_csr_addr
);

logic           [6:0]   opcode;
logic           [2:0]   funct3;
logic           [4:0]   funct5;
logic           [6:0]   funct7;

// parameters for opcode
localparam  R_TYPE          = 7'b0110011;
localparam  LOAD            = 7'b0000011;   // LW, LH, LBU, LHU
localparam  I_TYPE          = 7'b0010011;
localparam  JALR            = 7'b1100111;
localparam  S_TYPE          = 7'b0100011;   // SW, SB, SH
localparam  B_TYPE          = 7'b1100011;   // BEQ, BNE, BLT, BGE, BLTU, BGEU
localparam  AUIPC           = 7'b0010111;
localparam  LUI             = 7'b0110111;
localparam  JAL             = 7'b1101111;
localparam  FLW             = 7'b0000111;
localparam  FSW             = 7'b0100111;
localparam  F_TYPE          = 7'b1010011;   // FADD.S, FSUB.S
localparam  CSR             = 7'b1110011;

// parameters for ALU operations
localparam  ADD             = 5'b00000;
localparam  SUB             = 5'b00001; 
localparam  SLL             = 5'b00010;
localparam  SLT             = 5'b00011;
localparam  SLTU            = 5'b00100;
localparam  XOR             = 5'b00101;
localparam  SRL             = 5'b00110;
localparam  SRA             = 5'b00111;
localparam  OR              = 5'b01000;
localparam  AND             = 5'b01001;
localparam  MUL             = 5'b01010;
localparam  MULH            = 5'b01011;
localparam  MULHSU          = 5'b01100;
localparam  MULHU           = 5'b01101;
localparam  EQUAL           = 5'b01110;
localparam  NEQUAL          = 5'b01111;
localparam  S_LESSTHAN      = 5'b10000;
localparam  S_GREATEREQUAL  = 5'b10001;
localparam  U_LESSTHAN      = 5'b10010;
localparam  U_GREATEREQUAL  = 5'b10011;
localparam  FADD            = 5'b10100;
localparam  FSUB            = 5'b10101;
localparam  ANDN            = 5'b10110; // from Zbb extension
localparam  ORN             = 5'b10111; // from Zbb extension
localparam  XNOR            = 5'b11000; // from Zbb extension
localparam  MAX             = 5'b11001; // from Zbb extension
localparam  MAXU            = 5'b11010; // from Zbb extension
localparam  MIN             = 5'b11011; // from Zbb extension
localparam  MINU            = 5'b11100; // from Zbb extension
localparam  SEXTB           = 5'b11101; // from Zbb extension
localparam  RETURN1         = 5'b11111;

assign  opcode          =   i_inst[6:0];
assign  funct3          =   i_inst[14:12];
assign  funct5          =   i_inst[31:27];  // only used for F_TYPE
assign  funct7          =   i_inst[31:25];
assign  o_csr_addr      =   i_inst[31:20];  // only used for csr
assign  o_rs1_index     =   i_inst[19:15];
assign  o_rs2_index     =   i_inst[24:20];
assign  o_rd_index      =   i_inst[11:7];
assign  o_wb_en         =   (opcode == R_TYPE)|| (opcode == LOAD)       || (opcode == I_TYPE)   || (opcode == JALR) || (opcode == AUIPC) || (opcode == LUI) || (opcode == JAL) || (opcode == CSR);
assign  o_wb_en_f       =   (opcode == FLW)   || (opcode == F_TYPE);
assign  o_alu_src2_imm  =   (opcode == LOAD)  || (opcode == I_TYPE)     || (opcode == S_TYPE)   || (opcode == FLW)  || (opcode == FSW);
assign  o_ftype[0]      =   (opcode == F_TYPE);
assign  o_ftype[1]      =   (opcode == FSW)     || (opcode == F_TYPE);
assign  o_DM_write[0]   =   ((opcode == S_TYPE) & (funct3 == 3'b000))   || ((opcode == S_TYPE) & (funct3 == 3'b010))|| (opcode == FSW);
assign  o_DM_write[1]   =   ((opcode == S_TYPE) & (funct3 == 3'b001))   || ((opcode == S_TYPE) & (funct3 == 3'b010))|| (opcode == FSW);
assign  o_DM_read[0]    =   ((opcode == LOAD) & (funct3 == 3'b000))     || ((opcode == LOAD) & (funct3 == 3'b010))  || ((opcode == LOAD) & (funct3 == 3'b101))  || (opcode == FLW);
assign  o_DM_read[1]    =   ((opcode == LOAD) & (funct3 == 3'b001))     || ((opcode == LOAD) & (funct3 == 3'b010))  || (opcode == FLW);
assign  o_DM_read[2]    =   ((opcode == LOAD) & (funct3 == 3'b100))     || ((opcode == LOAD) & (funct3 == 3'b101));
assign  o_jalr          =   (opcode == JALR);
assign  o_jal           =   (opcode == JAL);
assign  o_branch        =   (opcode == B_TYPE);
assign  o_wb_sel[0]     =   (opcode == LOAD)    || (opcode == JAL)  || (opcode == JALR) || (opcode == CSR) || (opcode == FLW);
assign  o_wb_sel[1]     =   (opcode == LUI)     || (opcode == JAL)  || (opcode == JALR);
assign  o_wb_sel[2]     =   (opcode == AUIPC)   || (opcode == CSR);

always_comb begin
    case ({funct3, opcode})
        {3'b000, R_TYPE}:   o_aluoperation =    (funct7 == 7'b0000000) ? ADD    :
                                                (funct7 == 7'b0100000) ? SUB    :
                                                (funct7 == 7'b0000001) ? MUL    : RETURN1;
        {3'b001, R_TYPE}:   o_aluoperation =    (funct7 == 7'b0000000) ? SLL    :
                                                (funct7 == 7'b0000001) ? MULH   : RETURN1;
        {3'b010, R_TYPE}:   o_aluoperation =    (funct7 == 7'b0000000) ? SLT    :
                                                (funct7 == 7'b0000001) ? MULHSU : RETURN1;
        {3'b011, R_TYPE}:   o_aluoperation =    (funct7 == 7'b0000000) ? SLTU   :
                                                (funct7 == 7'b0000001) ? MULHU  : RETURN1;
        {3'b100, R_TYPE}:   o_aluoperation =    (funct7 == 7'b0000000) ? XOR    :
                                                (funct7 == 7'b0100000) ? XNOR   :           // from Zbb extension
                                                (funct7 == 7'b0000101) ? MIN    : RETURN1;  // from Zbb extension
        {3'b101, R_TYPE}:   o_aluoperation =    (funct7 == 7'b0000000) ? SRL    :
                                                (funct7 == 7'b0100000) ? SRA    : 
                                                (funct7 == 7'b0000101) ? MINU   : RETURN1;  // from Zbb extension
        {3'b110, R_TYPE}:   o_aluoperation =    (funct7 == 7'b0000000) ? OR     :
                                                (funct7 == 7'b0100000) ? ORN    :           // from Zbb extension
                                                (funct7 == 7'b0000101) ? MAX    : RETURN1;  // from Zbb extension
        {3'b111, R_TYPE}:   o_aluoperation =    (funct7 == 7'b0000000) ? AND    :
                                                (funct7 == 7'b0100000) ? ANDN   :           // from Zbb extension
                                                (funct7 == 7'b0000101) ? MAXU   : RETURN1;  // from Zbb extension
        {3'b010, LOAD}:     o_aluoperation =    ADD;                                        // LW
        {3'b000, LOAD}:     o_aluoperation =    ADD;                                        // LB
        {3'b001, LOAD}:     o_aluoperation =    ADD;                                        // LH
        {3'b100, LOAD}:     o_aluoperation =    ADD;                                        // LBU
        {3'b101, LOAD}:     o_aluoperation =    ADD;                                        // LHU
        {3'b000, I_TYPE}:   o_aluoperation =    ADD;                                        // ADDI
        {3'b001, I_TYPE}:   o_aluoperation =    (funct7 == 7'b0000000) ? SLL    :           // SLLI
                                                (funct7 == 7'b0110000) ? SEXTB  : RETURN1;  // from Zbb extension
        {3'b010, I_TYPE}:   o_aluoperation =    SLT;                                        // SLTI
        {3'b011, I_TYPE}:   o_aluoperation =    SLTU;                                       // SLTIU
        {3'b100, I_TYPE}:   o_aluoperation =    XOR;                                        // XORI
        {3'b101, I_TYPE}:   o_aluoperation =    (funct7 == 7'b0000000) ? SRL    :           // SRLI, SRAI
                                                (funct7 == 7'b0100000) ? SRA    : RETURN1;
        {3'b110, I_TYPE}:   o_aluoperation =    OR;                                         // ORI
        {3'b111, I_TYPE}:   o_aluoperation =    AND;                                        // ANDI
        {3'b010, S_TYPE}:   o_aluoperation =    ADD;                                        // SW
        {3'b000, S_TYPE}:   o_aluoperation =    ADD;                                        // SB
        {3'b001, S_TYPE}:   o_aluoperation =    ADD;                                        // SH
        {3'b000, B_TYPE}:   o_aluoperation =    EQUAL;                                      // BEQ
        {3'b001, B_TYPE}:   o_aluoperation =    NEQUAL;                                     // BNE
        {3'b100, B_TYPE}:   o_aluoperation =    S_LESSTHAN;                                 // BLT
        {3'b101, B_TYPE}:   o_aluoperation =    S_GREATEREQUAL;                             // BGE
        {3'b110, B_TYPE}:   o_aluoperation =    U_LESSTHAN;                                 // BLTU
        {3'b111, B_TYPE}:   o_aluoperation =    U_GREATEREQUAL;                             // BGEU
        {3'b010, FLW}:      o_aluoperation =    ADD;                                        // FLW
        {3'b010, FSW}:      o_aluoperation =    ADD;                                        // FSW
        {3'b111, F_TYPE}:   o_aluoperation =    (funct5 == 5'b00000) ? FADD :               // FADD.S, FSUB.s
                                                (funct5 == 5'b00001) ? FSUB : RETURN1;
        default:            o_aluoperation =    RETURN1;
    endcase
end

always_comb begin
    case ({funct3, opcode})
        10'b000_1110011:    o_csr_sel   =   3'd1;
        10'b001_1110011:    o_csr_sel   =   3'd2;
        10'b010_1110011:    o_csr_sel   =   3'd3;
        10'b011_1110011:    o_csr_sel   =   3'd4; 
        10'b101_1110011:    o_csr_sel   =   3'd5;
        10'b110_1110011:    o_csr_sel   =   3'd6;
        10'b111_1110011:    o_csr_sel   =   3'd7;
        default:            o_csr_sel   =   3'd0;
    endcase
end
endmodule