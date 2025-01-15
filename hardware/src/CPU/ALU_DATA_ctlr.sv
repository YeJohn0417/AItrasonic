module ALU_DATA_ctlr (
input           [4:0]   i_E_rs1_index,
input           [4:0]   i_E_rs2_index,
input           [31:0]  i_E_rs1_data,
input           [31:0]  i_E_rs2_data,
input           [31:0]  i_E_frs1_data,
input           [31:0]  i_E_frs2_data,
input           [31:0]  i_E_imm,
input                   i_E_alu_rs2_imm,    // 1 select imm, 0 select rs2
input           [1:0]   i_E_ftype,          // 1 rs1=frs1, 0 rs1=rs1
input           [4:0]   i_M_rd_index,
input                   i_M_wb_en,
input                   i_M_wb_en_f,
input           [31:0]  i_M_aluresult,
input           [31:0]  i_M_imm,
input           [31:0]  i_M_pc_4,
input           [31:0]  i_M_pc_imm,
input           [31:0]  i_M_csr_result,
input           [2:0]   i_M_wb_sel,
input           [4:0]   i_W_rd_index,
input                   i_W_wb_en,
input                   i_W_wb_en_f,
input           [31:0]  i_W_wb_data,

output  logic   [31:0]  o_src1,
output  logic   [31:0]  o_src2,
output  logic   [31:0]  o_rs2_data
);

logic                   M_rd_equal_rs1;
logic                   M_rd_equal_rs2;
logic                   W_rd_equal_rs1;
logic                   W_rd_equal_rs2;
logic                   M_frd_equal_frs1;
logic                   M_frd_equal_frs2;
logic                   W_frd_equal_frs1;
logic                   W_frd_equal_frs2;

assign  M_rd_equal_rs1      = i_M_wb_en & (!i_M_wb_en_f) & (i_M_rd_index == i_E_rs1_index) & (i_M_rd_index != 5'd0) & (!i_E_ftype[0]);
assign  M_rd_equal_rs2      = i_M_wb_en & (!i_M_wb_en_f) & (i_M_rd_index == i_E_rs2_index) & (i_M_rd_index != 5'd0) & (!i_E_ftype[1]);
assign  W_rd_equal_rs1      = i_W_wb_en & (!i_W_wb_en_f) & (i_W_rd_index == i_E_rs1_index) & (i_W_rd_index != 5'd0) & (!i_E_ftype[0]);
assign  W_rd_equal_rs2      = i_W_wb_en & (!i_W_wb_en_f) & (i_W_rd_index == i_E_rs2_index) & (i_W_rd_index != 5'd0) & (!i_E_ftype[1]);
assign  M_frd_equal_frs1    = (!i_M_wb_en) & i_M_wb_en_f & (i_M_rd_index == i_E_rs1_index) & i_E_ftype[0];
assign  M_frd_equal_frs2    = (!i_M_wb_en) & i_M_wb_en_f & (i_M_rd_index == i_E_rs2_index) & i_E_ftype[1];
assign  W_frd_equal_frs1    = (!i_W_wb_en) & i_W_wb_en_f & (i_W_rd_index == i_E_rs1_index) & i_E_ftype[0];
assign  W_frd_equal_frs2    = (!i_W_wb_en) & i_W_wb_en_f & (i_W_rd_index == i_E_rs2_index) & i_E_ftype[1];

always_comb begin
    case ({i_E_ftype[0], M_rd_equal_rs1, W_rd_equal_rs1, M_frd_equal_frs1, W_frd_equal_frs1})
    5'b00000:   o_src1  =   i_E_rs1_data;
    5'b00100:   o_src1  =   i_W_wb_data;
    5'b01000:   o_src1  =   (i_M_wb_sel == 3'b000)  ?   i_M_aluresult   :
                            (i_M_wb_sel == 3'b010)  ?   i_M_imm         :
                            (i_M_wb_sel == 3'b011)  ?   i_M_pc_4        :
                            (i_M_wb_sel == 3'b100)  ?   i_M_pc_imm      :
                            (i_M_wb_sel == 3'b101)  ?   i_M_csr_result  :   i_E_rs1_data;
    5'b01100:   o_src1  =   (i_M_wb_sel == 3'b000)  ?   i_M_aluresult   :
                            (i_M_wb_sel == 3'b010)  ?   i_M_imm         :
                            (i_M_wb_sel == 3'b011)  ?   i_M_pc_4        :
                            (i_M_wb_sel == 3'b100)  ?   i_M_pc_imm      :
                            (i_M_wb_sel == 3'b101)  ?   i_M_csr_result  :   i_E_rs1_data;
    5'b10000:   o_src1  =   i_E_frs1_data;
    5'b10001:   o_src1  =   i_W_wb_data;
    5'b10010:   o_src1  =   i_M_aluresult;
    5'b10011:   o_src1  =   i_M_aluresult;    // rd from MEM stage has priority
    default:    o_src1  =   i_E_rs1_data;
    endcase
end

always_comb begin
    case ({i_E_ftype[1], M_rd_equal_rs2, W_rd_equal_rs2, M_frd_equal_frs2, W_frd_equal_frs2})
    5'b00000:   o_rs2_data  =   i_E_rs2_data;
    5'b00100:   o_rs2_data  =   i_W_wb_data;
    5'b01000:   o_rs2_data  =   (i_M_wb_sel == 3'b000)  ?   i_M_aluresult   :
                                (i_M_wb_sel == 3'b010)  ?   i_M_imm         :
                                (i_M_wb_sel == 3'b011)  ?   i_M_pc_4        :
                                (i_M_wb_sel == 3'b100)  ?   i_M_pc_imm      :
                                (i_M_wb_sel == 3'b101)  ?   i_M_csr_result  :   i_E_rs2_data;
    5'b01100:   o_rs2_data  =   (i_M_wb_sel == 3'b000)  ?   i_M_aluresult   :
                                (i_M_wb_sel == 3'b010)  ?   i_M_imm         :
                                (i_M_wb_sel == 3'b011)  ?   i_M_pc_4        :
                                (i_M_wb_sel == 3'b100)  ?   i_M_pc_imm      :
                                (i_M_wb_sel == 3'b101)  ?   i_M_csr_result  :   i_E_rs2_data;
    5'b10000:   o_rs2_data  = i_E_frs2_data;
    5'b10001:   o_rs2_data  = i_W_wb_data;
    5'b10010:   o_rs2_data  = i_M_aluresult;
    5'b10011:   o_rs2_data  = i_M_aluresult;
    default:    o_rs2_data  = i_E_rs2_data;
    endcase
end

assign  o_src2 = i_E_alu_rs2_imm ? i_E_imm : o_rs2_data;

endmodule