module W_CDC(
    input               clk,
    input               rst,
    input               clk2,
    input               rst2,
    input               AW_rd_en,
    input               AW_wr_en,
    input        [48:0] AW_w_data,
    input               W_rd_en,
    input               W_wr_en,
    input        [36:0] W_w_data,
    input               B_rd_en,
    input               B_wr_en,
    input        [ 9:0] B_w_data,

    output logic        AW_not_empty,
    output logic        AW_not_full,
    output logic [48:0] AW_r_data,
    output logic        W_not_empty,
    output logic        W_not_full,
    output logic [36:0] W_r_data,
    output logic        B_not_empty,
    output logic        B_not_full,
    output logic [ 9:0] B_r_data
);

async_fifo_A AW_FIFO(
    .clk            (clk),
    .rst            (rst),
    .clk2           (clk2),
    .rst2           (rst2),
    .rd_en          (AW_rd_en),
    .wr_en          (AW_wr_en),
    .w_data         (AW_w_data),

    .not_empty      (AW_not_empty),
    .not_full       (AW_not_full),
    .r_data         (AW_r_data)
);

async_fifo_W W_FIFO(
    .clk            (clk),
    .rst            (rst),
    .clk2           (clk2),
    .rst2           (rst2),
    .rd_en          (W_rd_en),
    .wr_en          (W_wr_en),
    .w_data         (W_w_data),

    .not_empty      (W_not_empty),
    .not_full       (W_not_full),
    .r_data         (W_r_data)
);

async_fifo_B B_FIFO(
    .clk            (clk2),
    .rst            (rst2),
    .clk2           (clk),
    .rst2           (rst),
    .rd_en          (B_rd_en),
    .wr_en          (B_wr_en),
    .w_data         (B_w_data),

    .not_empty      (B_not_empty),
    .not_full       (B_not_full),
    .r_data         (B_r_data)
);

endmodule