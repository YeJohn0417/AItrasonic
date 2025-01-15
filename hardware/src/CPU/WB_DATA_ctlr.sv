module WB_DATA_ctlr(
    i_aluresult,
    i_dm_out,
    i_imm,
    i_pc_4,
    i_pc_imm,
    i_DM_read,
    i_wb_sel,
    i_csr_result,
    o_wb_data
);

input   logic   [31:0]  i_aluresult;
input   logic   [31:0]  i_dm_out;
input   logic   [31:0]  i_imm;
input   logic   [31:0]  i_pc_4;
input   logic   [31:0]  i_pc_imm;
input   logic   [2:0]   i_DM_read;
input   logic   [2:0]   i_wb_sel;
input   logic   [31:0]  i_csr_result;

output  logic   [31:0]  o_wb_data;  // 0 alu, 1 dm, 2 imm, 3 pc_4, 4 pc_imm

logic           [31:0]  dm_data;

always_comb begin
    case (i_DM_read)
//        3'b001:     dm_data = i_dm_out[7]   ? {24'hffff_ff, i_dm_out[7:0]}  : {24'd0, i_dm_out[7:0]};
        3'b001:     dm_data =   (i_aluresult[1:0] == 2'b00) ? {{24{i_dm_out[7]}}, i_dm_out[7:0]}    :
                                (i_aluresult[1:0] == 2'b01) ? {{24{i_dm_out[15]}}, i_dm_out[15:8]}  :
                                (i_aluresult[1:0] == 2'b10) ? {{24{i_dm_out[23]}}, i_dm_out[23:16]} :
                                (i_aluresult[1:0] == 2'b11) ? {{24{i_dm_out[31]}}, i_dm_out[31:24]} : {{24{i_dm_out[7]}}, i_dm_out[7:0]};
//        3'b010:     dm_data = i_dm_out[15]  ? {16'hffff, i_dm_out[15:0]}    : {16'd0, i_dm_out[15:0]};
        3'b010:     dm_data =   (i_aluresult[1:0] == 2'b00) ? {{16{i_dm_out[15]}}, i_dm_out[15:0]}  :
                                (i_aluresult[1:0] == 2'b01) ? {{16{i_dm_out[23]}}, i_dm_out[23:8]}  :
                                (i_aluresult[1:0] == 2'b10) ? {{16{i_dm_out[31]}}, i_dm_out[31:16]} : {{16{i_dm_out[15]}}, i_dm_out[15:0]};
        3'b011:     dm_data = i_dm_out[31:0];
//        3'b100:     dm_data = {24'd0, i_dm_out[7:0]};
        3'b100:     dm_data =   (i_aluresult[1:0] == 2'b00) ? {24'd0, i_dm_out[7:0]}    :
                                (i_aluresult[1:0] == 2'b01) ? {24'd0, i_dm_out[15:8]}   :
                                (i_aluresult[1:0] == 2'b10) ? {24'd0, i_dm_out[23:16]}  :
                                (i_aluresult[1:0] == 2'b11) ? {24'd0, i_dm_out[31:24]}  : {24'd0, i_dm_out[7:0]};
//        3'b101:     dm_data = {16'd0, i_dm_out[15:0]};
        3'b101:     dm_data =   (i_aluresult[1:0] == 2'b00) ? {16'h0000, i_dm_out[15:0]}    :
                                (i_aluresult[1:0] == 2'b01) ? {16'h0000, i_dm_out[23:8]}    :
                                (i_aluresult[1:0] == 2'b10) ? {16'h0000, i_dm_out[31:16]}   :
                                (i_aluresult[1:0] == 2'b11) ? {16'h0000, i_dm_out[23:8]}    : {{16{i_dm_out[15]}}, i_dm_out[15:0]};
        default:    dm_data = i_dm_out;
    endcase
end

always_comb begin
    case (i_wb_sel)
        3'b000:     o_wb_data   = i_aluresult;
        3'b001:     o_wb_data   = dm_data;
        3'b010:     o_wb_data   = i_imm;
        3'b011:     o_wb_data   = i_pc_4;
        3'b100:     o_wb_data   = i_pc_imm;
        3'b101:     o_wb_data   = i_csr_result;
        default:    o_wb_data   = 32'd0;
    endcase
end

endmodule