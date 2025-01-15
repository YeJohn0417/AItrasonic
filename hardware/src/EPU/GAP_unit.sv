module GAP_unit(
    input                   clk,
    input                   rst,
    input                   start,
    input                   data_valid,
    input           [7:0]   data_in_00,
    input           [7:0]   data_in_10,
    input           [7:0]   data_in_20,
    input           [7:0]   data_in_30,
    input           [7:0]   data_in_01,
    input           [7:0]   data_in_11,
    input           [7:0]   data_in_21,
    input           [7:0]   data_in_31,
    input           [7:0]   data_in_02,
    input           [7:0]   data_in_12,
    input           [7:0]   data_in_22,
    input           [7:0]   data_in_32,
    input           [7:0]   data_in_03,
    input           [7:0]   data_in_13,
    input           [7:0]   data_in_23,
    input           [7:0]   data_in_33,

    output logic            output_valid,
    output logic    [7:0]   data_out
);

localparam IDLE = 2'd0;
localparam SUM  = 2'd1;
localparam POP  = 2'd2;

logic [1:0] cur_state;
logic [1:0] next_state;

logic [1:0] count_o;

logic [9:0] sum_0;
logic [9:0] sum_1;
logic [9:0] sum_2;
logic [9:0] sum_3;

logic [7:0] data_out_0;
logic [7:0] data_out_1;
logic [7:0] data_out_2;
logic [7:0] data_out_3;

assign output_valid = (cur_state == POP) ? 1'b1 : 1'b0;
assign data_out_0 = ((sum_0[1] && sum_0[0]) || (sum_0[2] && sum_0[1] && ~sum_0[0]))? sum_0[9:2] + 8'd1 : sum_0[9:2];
assign data_out_1 = ((sum_1[1] && sum_1[0]) || (sum_1[2] && sum_1[1] && ~sum_1[0]))? sum_1[9:2] + 8'd1 : sum_1[9:2];
assign data_out_2 = ((sum_2[1] && sum_2[0]) || (sum_2[2] && sum_2[1] && ~sum_2[0]))? sum_2[9:2] + 8'd1 : sum_2[9:2];
assign data_out_3 = ((sum_3[1] && sum_3[0]) || (sum_3[2] && sum_3[1] && ~sum_3[0]))? sum_3[9:2] + 8'd1 : sum_3[9:2];

always_ff@(posedge clk or posedge rst)begin
    if(rst) cur_state <= IDLE;
    else    cur_state <= next_state;
end

always_comb
begin
    case(cur_state)
    IDLE: next_state = (start)           ? SUM  : IDLE;
    SUM:  next_state = (data_valid)      ? POP  : SUM;
    POP:  next_state = (count_o == 2'd3) ? IDLE : POP;
    default: next_state = IDLE;
    endcase
end

always_ff@(posedge clk or posedge rst)begin
    if(rst)begin
        sum_0 <= 10'd0;
        sum_1 <= 10'd0;
        sum_2 <= 10'd0;
        sum_3 <= 10'd0;
    end
    else if(data_valid)begin
        sum_0 <= data_in_00 + data_in_10 + data_in_20 + data_in_30; 
        sum_1 <= data_in_01 + data_in_11 + data_in_21 + data_in_31; 
        sum_2 <= data_in_02 + data_in_12 + data_in_22 + data_in_32; 
        sum_3 <= data_in_03 + data_in_13 + data_in_23 + data_in_33;
    end 
end

always_ff@(posedge clk or posedge rst)begin
    if(rst)
        count_o <= 2'd0;
    else if(cur_state == IDLE)
        count_o <= 2'd0;
    else if(cur_state == POP)
        count_o <= count_o + 2'd1;
    else
        count_o <= count_o;
end

always_ff@(posedge clk or posedge rst)begin
    if(rst)
        data_out <= 8'd0;
    else if(cur_state == POP)begin
        case(count_o)
        2'd0: data_out <= data_out_0;
        2'd1: data_out <= data_out_1;
        2'd2: data_out <= data_out_2;
        2'd3: data_out <= data_out_3;
        endcase
    end
end

endmodule
