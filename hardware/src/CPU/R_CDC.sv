module R_CDC(
    input               clk,
    input               rst,
    input               clk2,
    input               rst2,
    input               AR_rd_en,
    input               AR_wr_en,
    input        [48:0] AR_w_data,
    input               R_rd_en,
    input               R_wr_en,
    input        [42:0] R_w_data,

    output logic        AR_not_empty,
    output logic        AR_not_full,
    output logic [48:0] AR_r_data,
    output logic        R_not_empty,
    output logic        R_not_full,
    output logic [42:0] R_r_data
);

async_fifo_A AR_FIFO(
    .clk            (clk),
    .rst            (rst),
    .clk2           (clk2),
    .rst2           (rst2),
    .rd_en          (AR_rd_en),
    .wr_en          (AR_wr_en),
    .w_data         (AR_w_data),

    .not_empty      (AR_not_empty),
    .not_full       (AR_not_full),
    .r_data         (AR_r_data)
);

async_fifo_R R_FIFO (
    .clk            (clk2),
    .rst            (rst2),
    .clk2           (clk),
    .rst2           (rst),
    .rd_en          (R_rd_en),
    .wr_en          (R_wr_en),
    .w_data         (R_w_data),

    .not_empty      (R_not_empty),
    .not_full       (R_not_full),
    .r_data         (R_r_data)
);

endmodule