module FP_RegFile(
    clk,
    rst,
    i_frs1_index,
    i_frs2_index,
    i_W_wb_data,
    i_W_wb_en_f,
    i_W_frd_index,
    o_frs1_data,
    o_frs2_data
);

input                   clk;
input                   rst;
input           [4:0]   i_frs1_index;
input           [4:0]   i_frs2_index;
input           [31:0]  i_W_wb_data;
input                   i_W_wb_en_f;
input           [4:0]   i_W_frd_index;

output  logic   [31:0]  o_frs1_data;
output  logic   [31:0]  o_frs2_data;

logic           [31:0]  register_file   [31:0];

// if writing back and rd == rs1|rs2 -> forwarding
assign  o_frs1_data  = (i_W_wb_en_f & (i_W_frd_index == i_frs1_index)) ? i_W_wb_data : register_file[i_frs1_index];
assign  o_frs2_data  = (i_W_wb_en_f & (i_W_frd_index == i_frs2_index)) ? i_W_wb_data : register_file[i_frs2_index];

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        for (int i=0; i<32; i=i+1)
            register_file[i]    <= 32'd0;
    end
    else if (i_W_wb_en_f) begin
        register_file[i_W_frd_index] <= i_W_wb_data;
    end
end

endmodule