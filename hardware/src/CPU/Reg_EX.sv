module Reg_EX (
input   logic           clk,
input   logic           rst,

input   logic           stall,
input   logic 			i_t_pnt,
input   logic 			i_nt_pt,
input   logic 	[31:0]	i_inst,
input   logic           i_wait_DM1,
input   logic           i_wait_WFI,
input   logic   [31:0]  i_pc,
input   logic   [4:0]   i_aluoperation,
input   logic   [4:0]   i_rs1_index,
input   logic   [4:0]   i_rs2_index,
input   logic   [31:0]  i_rs1_data,
input   logic   [31:0]  i_rs2_data,
input   logic   [31:0]  i_frs1_data,
input   logic   [31:0]  i_frs2_data,
input   logic   [31:0]  i_imm,
input   logic   [4:0]   i_rd_index,
input   logic           i_wb_en,
input   logic           i_wb_en_f,
input   logic           i_alu_src2_imm,
input   logic   [1:0]   i_ftype,
input   logic   [1:0]   i_DM_write,
input   logic   [2:0]   i_DM_read,
input   logic           i_jalr,
input   logic           i_jal,
input   logic           i_branch,
input   logic   [2:0]   i_wb_sel,
input   logic   [2:0]   i_csr_sel,
input   logic   [11:0]  i_csr_addr,

output  logic   [31:0]  o_inst,
output  logic   [31:0]  o_pc,
output  logic   [4:0]   o_aluoperation,
output  logic   [4:0]   o_rs1_index,
output  logic   [4:0]   o_rs2_index,
output  logic   [31:0]  o_rs1_data,
output  logic   [31:0]  o_rs2_data,
output  logic   [31:0]  o_frs1_data,
output  logic   [31:0]  o_frs2_data,
output  logic   [31:0]  o_imm,
output  logic   [4:0]   o_rd_index,
output  logic           o_wb_en,
output  logic           o_wb_en_f,
output  logic           o_alu_src2_imm,
output  logic   [1:0]   o_ftype,
output  logic   [1:0]   o_DM_write,
output  logic   [2:0]   o_DM_read,
output  logic           o_jalr,
output  logic           o_jal,
output  logic           o_branch,
output  logic   [2:0]   o_wb_sel,
output  logic   [2:0]   o_csr_sel,
output  logic   [11:0]  o_csr_addr
);

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        o_pc            <= 32'd0;
        o_aluoperation  <= 5'd0;
        o_rs1_index     <= 5'd0;
        o_rs2_index     <= 5'd0;
        o_rs1_data      <= 32'd0;
        o_rs2_data      <= 32'd0;
        o_frs1_data     <= 32'd0;
        o_frs2_data     <= 32'd0;
        o_imm           <= 32'd0;
        o_rd_index      <= 5'd0;
        o_wb_en         <= 1'b0;
        o_wb_en_f       <= 1'b0;
        o_alu_src2_imm  <= 1'b0;
        o_ftype         <= 2'd0;
        o_DM_write      <= 2'd0;
        o_DM_read       <= 3'd0;
        o_jalr          <= 1'b0;
        o_jal           <= 1'b0;
        o_branch        <= 1'b0;
        o_wb_sel        <= 3'd0;
        o_csr_sel       <= 3'd0;
        o_csr_addr      <= 12'd0;
		o_inst			<= 32'd0;
    end
    else begin
//        if (flush || stall) begin
        if (stall || i_nt_pt || i_t_pnt) begin
            o_pc            <= 32'd0;
            o_aluoperation  <= 5'd0;
            o_rs1_index     <= 5'd0;
            o_rs2_index     <= 5'd0;
            o_rs1_data      <= 32'd0;
            o_rs2_data      <= 32'd0;
            o_frs1_data     <= 32'd0;
            o_frs2_data     <= 32'd0;
            o_imm           <= 32'd0;
            o_rd_index      <= 5'd0;
            o_wb_en         <= 1'b0;
            o_wb_en_f       <= 1'b0;
            o_alu_src2_imm  <= 1'b0;
            o_ftype         <= 2'd0;
            o_DM_write      <= 2'd0;
            o_DM_read       <= 3'd0;
            o_jalr          <= 1'b0;
            o_jal           <= 1'b0;
            o_branch        <= 1'b0;
            o_wb_sel        <= 3'd0;
            o_csr_sel       <= 3'd0;
            o_csr_addr      <= 12'd0;
			o_inst			<= 32'd0;
        end
        else if (!i_wait_DM1 && !i_wait_WFI) begin
            o_pc            <= i_pc;
            o_aluoperation  <= i_aluoperation;
            o_rs1_index     <= i_rs1_index;
            o_rs2_index     <= i_rs2_index;
            o_rs1_data      <= i_rs1_data;
            o_rs2_data      <= i_rs2_data;
            o_frs1_data     <= i_frs1_data;
            o_frs2_data     <= i_frs2_data;
            o_imm           <= i_imm;
            o_rd_index      <= i_rd_index;
            o_wb_en         <= i_wb_en;
            o_wb_en_f       <= i_wb_en_f;
            o_alu_src2_imm  <= i_alu_src2_imm;
            o_ftype         <= i_ftype;
            o_DM_write      <= i_DM_write;
            o_DM_read       <= i_DM_read;
            o_jalr          <= i_jalr;
            o_jal           <= i_jal;
            o_branch        <= i_branch;
            o_wb_sel        <= i_wb_sel;
            o_csr_sel       <= i_csr_sel;
            o_csr_addr      <= i_csr_addr;
			o_inst			<= i_inst;
        end
    end
end

endmodule