module RegFile(
    clk,
    rst,
    i_rs1_index,
    i_rs2_index,
    i_W_wb_data,
    i_W_wb_en,
    i_W_rd_index,
    o_rs1_data,
    o_rs2_data
);

input                   clk;
input                   rst;
input           [4:0]   i_rs1_index;
input           [4:0]   i_rs2_index;
input           [31:0]  i_W_wb_data;
input                   i_W_wb_en;
input           [4:0]   i_W_rd_index;

output  logic   [31:0]  o_rs1_data;
output  logic   [31:0]  o_rs2_data;

logic           [31:0]  register_file   [31:0];

// if writing back and rd == rs1|rs2 -> forwarding
assign  o_rs1_data  = (i_W_wb_en && (i_W_rd_index == i_rs1_index) && (i_W_rd_index != 5'd0)) ? i_W_wb_data : register_file[i_rs1_index];
assign  o_rs2_data  = (i_W_wb_en && (i_W_rd_index == i_rs2_index) && (i_W_rd_index != 5'd0)) ? i_W_wb_data : register_file[i_rs2_index];

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        for (int i=0; i<32; i=i+1)
            register_file[i]    <= 32'd0;
    end
    else if (i_W_wb_en) begin
        if (i_W_rd_index != 5'd0) register_file[i_W_rd_index] <= i_W_wb_data;
    end
end

endmodule