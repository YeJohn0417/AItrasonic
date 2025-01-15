module Reg_PC (
    input                   clk,
    input                   rst,
//    input                   flush,
    input                   stall,
    input                   i_wait_DM1,
    input                   i_wait_WFI,
    input                   i_wait_IM1_read,
    input           [31:0]  i_jb_pc,
    input                   i_next_pc_sel,
	input					i_pred_jump,
	input 			[31:0]	i_pred_pc,
	input 					i_nt_pt,
	input 					i_t_pnt,

    output  logic           flush,
    output  logic   [31:0]  o_addr,
    output  logic   [31:0]  o_pc,
    output  logic           o_rst_1
);

logic           [31:0]  cur_pc;
logic           [31:0]  next_pc;
logic           [31:0]  cur_pc_add_4;
logic           [31:0]  jb_pc_1;
logic                   next_pc_sel_1;
logic                   rst_1;
logic 			[31:0] 	original_pc;

assign  o_addr          =   {2'd0, cur_pc[31:2]};
assign  o_pc            =   cur_pc;
assign  cur_pc_add_4    =   cur_pc + 32'd4;
assign  next_pc         =   next_pc_sel_1 || i_t_pnt   ? jb_pc_1   : cur_pc_add_4;
assign  flush           =   next_pc_sel_1;

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        cur_pc      <= 32'd0;
        o_rst_1 <= 1'b0;
    end
	else if(i_nt_pt)begin
		cur_pc <= original_pc + 32'd4;
	end
	else if(i_pred_jump)begin
		cur_pc <= i_pred_pc;
	end
    else if ((!stall) & (!i_wait_DM1) & (!i_wait_IM1_read) & (!i_wait_WFI)) begin
        cur_pc  <= next_pc;
        o_rst_1 <= 1'b1;
    end
end

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        jb_pc_1         <= 32'd0;
        next_pc_sel_1   <= 1'b0;
    end
    else if (i_next_pc_sel) begin
        jb_pc_1         <= i_jb_pc;
        next_pc_sel_1   <= i_next_pc_sel;
    end
    else if ((!stall) & (!i_wait_DM1) & (!i_wait_IM1_read) && (!i_wait_WFI)) begin
        jb_pc_1         <= 32'd0;
        next_pc_sel_1   <= 1'b0;
    end
end

always@(posedge clk or posedge rst)begin
    if(rst)begin
        original_pc<=32'd0;
    end
    else begin
        if(i_pred_jump)begin
            original_pc <= cur_pc;
        end
        else begin
            original_pc<=original_pc;
        end
    end
end

endmodule