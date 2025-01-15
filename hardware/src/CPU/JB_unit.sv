module JB_unit (
input           [31:0]  i_rs1_data,
input           [31:0]  i_pc,
input           [31:0]  i_imm,
input                   i_aluresult0,
input                   i_jalr,
input                   i_jal,
input                   i_branch,
input                   i_mret,
input                   i_intr,
input           [31:0]  i_pc_mret,
input           [31:0]  i_pc_intr,

output  logic   [31:0]  o_jb_pc,
output  logic           o_next_pc_sel,
output  logic   [31:0]  o_pc_4,
output  logic   [31:0]  o_pc_imm
);

logic                   branch;

assign  o_pc_4          = i_pc + 32'd4;
assign  o_pc_imm        = i_pc + i_imm;
assign  branch          = i_branch & i_aluresult0;
assign  o_jb_pc         = i_jalr    ? (i_imm + i_rs1_data)  :
                          i_jal     ? o_pc_imm              :
                          branch    ? o_pc_imm              :
                          i_intr    ? i_pc_intr             :
                          i_mret    ? i_pc_mret             : o_pc_4;
assign  o_next_pc_sel   = branch || i_jalr || i_jal || i_intr || i_mret;

endmodule