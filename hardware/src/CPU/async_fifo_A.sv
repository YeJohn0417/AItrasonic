module async_fifo_A(
    input                 clk,
    input                 clk2,
    input                 rst,
    input                 rst2,
    input                 rd_en,
    input                 wr_en,
    input        [48:0]   w_data,

    output logic          not_empty,
    output logic          not_full,
    output logic [48:0]   r_data
);

logic [48:0]    FIFO [0:3];

logic           empty;
logic           full;

logic [2:0]     w_ptr;
logic [2:0]     r_ptr;
logic [2:0]     w_ptr_gray;
logic [2:0]     r_ptr_gray;
logic [2:0]     r_ptr_gray_d;
logic [2:0]     w_ptr_gray_d;
logic [2:0]     w_ptr_gray_sync;
logic [2:0]     r_ptr_gray_sync;
logic [2:0]     rq2_w_ptr;
logic [2:0]     wq2_r_ptr;

logic [1:0]     w_addr;
logic [1:0]     r_addr;

assign w_addr     = w_ptr[1:0];
assign r_addr     = r_ptr[1:0];

assign not_empty  = !empty;
assign not_full   = !full;

assign empty      = (r_ptr_gray == rq2_w_ptr);
assign full       = (w_ptr_gray[2] != wq2_r_ptr[2]) && (w_ptr_gray[1] != wq2_r_ptr[1]) && (w_ptr_gray[0] == wq2_r_ptr[0]);

assign r_data     = (rd_en && (!empty)) ? FIFO[r_addr] : {8'd0,FIFO[r_addr][40:9],9'd0};

always_comb
begin
    // binary to gray
    r_ptr_gray = r_ptr ^ (r_ptr >> 1);
    w_ptr_gray = w_ptr ^ (w_ptr >> 1);
    // gray to binary
end

// write into FIFO
always_ff@(posedge clk or posedge rst)begin
    if(rst)begin
        w_ptr        <= 3'd0;
        for(integer i = 0; i < 4; i = i+1)
            FIFO[i]  <= 49'd0;
    end
    else if(wr_en && (!full))begin
        w_ptr        <= w_ptr + 3'd1;
        FIFO[w_addr] <= w_data;
    end
end

always_ff@(posedge clk or posedge rst)begin
    if(rst)begin
        w_ptr_gray_d  <= 3'd0;
    end
    else begin
        w_ptr_gray_d  <= w_ptr_gray;
    end
end

// read from FIFO
always_ff@(posedge clk2 or posedge rst2)begin
    if(rst2)
        r_ptr        <= 3'd0;
    else if(rd_en && (!empty))
        r_ptr        <= r_ptr + 3'd1;
    else
        r_ptr        <= r_ptr;
end

always_ff@(posedge clk2 or posedge rst2)begin
    if(rst2)begin
        r_ptr_gray_d  <= 3'd0;
    end
    else begin
        r_ptr_gray_d  <= r_ptr_gray;
    end
end

// sync_w2r
always_ff@(posedge clk2 or posedge rst2) begin
    if(rst2)begin
        w_ptr_gray_sync <= 3'd0;
        rq2_w_ptr       <= 3'd0;
    end
    else begin
//        w_ptr_gray_sync <= w_ptr_gray;
        w_ptr_gray_sync <= w_ptr_gray_d;
        rq2_w_ptr       <= w_ptr_gray_sync;
    end
end

// sync_r2w
always_ff@(posedge clk or posedge rst)begin
    if(rst)begin
        r_ptr_gray_sync <= 3'd0;
        wq2_r_ptr       <= 3'd0;
    end
    else begin
//        r_ptr_gray_sync <= r_ptr_gray;
        r_ptr_gray_sync <= r_ptr_gray_d;
        wq2_r_ptr       <= r_ptr_gray_sync;
    end
end

endmodule