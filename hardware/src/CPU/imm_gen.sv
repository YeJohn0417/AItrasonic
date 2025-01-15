module imm_gen(
    i_inst,
    o_imm
);

input   logic   [31:0]  i_inst;
output  logic   [31:0]  o_imm;

always_comb begin
    case (i_inst[6:0])
        // LW, LH, LBU, LHU
        7'b0000011: o_imm = i_inst[31] ? {20'hFFFFF, i_inst[31:20]} : {20'd0, i_inst[31:20]};
        // I-type
        7'b0010011: o_imm = ({i_inst[31:25], i_inst[14:12]} == 10'b0100000101) ? {27'd0, i_inst[24:20]} : // SRAI
                            i_inst[31] ? {20'hFFFFF, i_inst[31:20]} : {20'd0, i_inst[31:20]};
        // JALR
        7'b1100111: o_imm = i_inst[31] ? {20'hFFFFF, i_inst[31:20]} : {20'd0, i_inst[31:20]};
        // S-type
        7'b0100011: o_imm = i_inst[31] ? {20'hFFFFF, i_inst[31:25], i_inst[11:7]} : {20'd0, i_inst[31:25], i_inst[11:7]};
        // B-type
        7'b1100011: o_imm = i_inst[31] ? {19'h7FFFF, i_inst[31], i_inst[7], i_inst[30:25], i_inst[11:8], 1'b0} : {19'd0, i_inst[31], i_inst[7], i_inst[30:25], i_inst[11:8], 1'b0};
        // AUIPC
        7'b0010111: o_imm = {i_inst[31:12], 12'd0};
        // LUI
        7'b0110111: o_imm = {i_inst[31:12], 12'd0};
        // JAL
        7'b1101111: o_imm = i_inst[31] ? {11'h7FF, i_inst[31], i_inst[19:12], i_inst[20], i_inst[30:21], 1'b0} : {11'd0, i_inst[31], i_inst[19:12], i_inst[20], i_inst[30:21], 1'b0};
        7'b0000111: o_imm = i_inst[31] ? {20'hFFFFF, i_inst[31:20]} : {20'd0, i_inst[31:20]};
        7'b0100111: o_imm = i_inst[31] ? {20'hFFFFF, i_inst[31:25], i_inst[11:7]} : {20'd0, i_inst[31:25], i_inst[11:7]};
        // CSR
        7'b1110011: o_imm = {27'd0, i_inst[19:15]};
        default:    o_imm = 32'd0;
    endcase
end
endmodule