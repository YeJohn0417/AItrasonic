module Reg_ID (
    input                   clk,
    input                   rst,
    input                   flush,
    input                   stall,
	input                   i_nt_pt,
	input                   i_t_pnt,
    input                   i_wait_DM1,
    input                   i_wait_WFI,
    input                   i_wait_IM1_read,
    input           [31:0]  i_pc,
    input           [31:0]  i_inst,
    output  logic   [31:0]  o_pc,
    output  logic   [31:0]  o_inst
);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        o_pc    <= 32'd0;
        o_inst  <= 32'd0;
    end
    else begin
        if (flush || i_wait_IM1_read || i_nt_pt || i_t_pnt) begin
            o_pc    <= 32'd0;
            o_inst  <= 32'd0;
        end
        else if ((!stall) & (!i_wait_DM1) & (!i_wait_WFI)) begin
            o_pc    <= i_pc;
            o_inst  <= i_inst;
        end
    end
end

endmodule