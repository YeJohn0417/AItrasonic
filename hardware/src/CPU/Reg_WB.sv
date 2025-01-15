module Reg_WB(
    input   logic           clk,
    input   logic           rst,
    input   logic           i_wait_DM1,
    input   logic           i_wait_WFI,
    input   logic   [31:0]  i_aluresult,
    input   logic   [31:0]  i_dm_out,
    input   logic   [4:0]   i_rd_index,
    input   logic   [31:0]  i_imm,
    input   logic           i_wb_en,
    input   logic           i_wb_en_f,
    input   logic   [1:0]   i_DM_write,
    input   logic   [2:0]   i_DM_read,
    input   logic   [2:0]   i_wb_sel,
    input   logic   [31:0]  i_pc_4,
    input   logic   [31:0]  i_pc_imm,
    input   logic   [31:0]  i_csr_result,

    output  logic   [31:0]  o_aluresult,
    output  logic   [31:0]  o_dm_out,
    output  logic   [4:0]   o_rd_index,
    output  logic   [31:0]  o_imm,
    output  logic           o_wb_en,
    output  logic           o_wb_en_f,
    output  logic   [1:0]   o_DM_write,
    output  logic   [2:0]   o_DM_read,
    output  logic   [2:0]   o_wb_sel,
    output  logic   [31:0]  o_pc_4,
    output  logic   [31:0]  o_pc_imm,
    output  logic   [31:0]  o_csr_result
);

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        o_aluresult     <= 32'd0;
        o_dm_out        <= 32'd0;
        o_rd_index      <= 5'd0;
        o_imm           <= 32'd0;
        o_wb_en         <= 1'b0;
        o_wb_en_f       <= 1'b0;
        o_DM_write      <= 2'd0;
        o_DM_read       <= 3'd0;
        o_wb_sel        <= 3'd0;
        o_pc_4          <= 32'd0;
        o_pc_imm        <= 32'd0;
        o_csr_result    <= 32'd0;
    end
    else if (!i_wait_DM1 && !i_wait_WFI) begin
        o_aluresult     <= i_aluresult;
        o_dm_out        <= i_dm_out;
        o_rd_index      <= i_rd_index;
        o_imm           <= i_imm;
        o_wb_en         <= i_wb_en;
        o_wb_en_f       <= i_wb_en_f;
        o_DM_write      <= i_DM_write;
        o_DM_read       <= i_DM_read;
        o_wb_sel        <= i_wb_sel;
        o_pc_4          <= i_pc_4;
        o_pc_imm        <= i_pc_imm;
        o_csr_result    <= i_csr_result;
    end
end

endmodule