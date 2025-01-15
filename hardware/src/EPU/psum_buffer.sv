module psum_buffer(
input                   clk,
input                   rst,
input                   start,
input           [ 2:0]  layer,
input                   data_valid,
input           [23:0]  data_in,

// output logic            data_last, 
output logic            output_valid,
output logic    [ 7:0]  data_out
);

// local parameter declaration for states
localparam IDLE           = 3'd0;
localparam FIRST          = 3'd1;
localparam SECOND         = 3'd2;
localparam MAX_POOL       = 3'd3;
localparam FC             = 3'd4;
localparam RE_QUAN        = 3'd5;
localparam POP            = 3'd6;
// local parameter declaration for layer information
localparam INPUT_SIZE_0   = 7'd95;  // layer0 96x96x1 -> 48x48x4
localparam INPUT_SIZE_1   = 7'd43;  // layer1 44x44x4 -> 22x22x8
localparam INPUT_SIZE_2   = 7'd17;  // layer2 18x18x8 -> 9x9x8  
localparam INPUT_SIZE_3   = 7'd3;   // layer3 4x4x8   -> 2x2x8  
localparam OUTPUT_SIZE_0  = 7'd47;  // layer0 96x96x1 -> 48x48x4
localparam OUTPUT_SIZE_1  = 7'd21;  // layer1 44x44x4 -> 22x22x8
localparam OUTPUT_SIZE_2  = 7'd8;   // layer2 18x18x8 -> 9x9x8  
localparam OUTPUT_SIZE_3  = 7'd1;   // layer3 4x4x8   -> 2x2x8
localparam CHANNEL_SIZE_1 = 4'd0;   // input channel for layer0
localparam CHANNEL_SIZE_4 = 4'd3;   // input channel for layer1
localparam CHANNEL_SIZE_8 = 4'd7;   // input channel for layer2/3
// finite state machine states
logic [ 2:0] cur_state;
logic [ 2:0] next_state;
// layer information
logic [ 2:0] layer_latch;    
logic [ 6:0] input_size;            // input picture size
logic [ 6:0] output_size;           // output picture size
logic [ 3:0] channel_size;          // input channel size
// counters
logic [ 3:0] count_c;               // counter for input data channel
logic [ 6:0] count_1;               // counter for first row
logic [ 6:0] count_2;               // counter for second row
logic [ 6:0] count_mp;              // counter for max pooling
logic [ 6:0] count_mp1;             // counter for max pooling
logic [ 6:0] count_o;               // counter for output data
// psum buffer
logic [23:0] psum_1[0:95];          // first row register
logic [23:0] psum_2[0:95];          // second row register
logic [23:0] psum_fc;               // fully connect resgister
logic [23:0] psum_mp;               // after max pooling register
logic [23:0] psum_relu;             // after ReLU register
// rounding 
logic        round_0;
logic        round_1;
logic        round_2;
logic        round_3;
logic        round_5;
logic        round_6;

// assign signals
assign count_mp1    = count_mp + 7'd1;
assign output_valid = (cur_state == POP)       ? 1'b1   : 1'b0;
// assign data_last    = (count_o == output_size) ? 1'b1   : 1'b0;
assign round_0      = (layer_latch == 3'd0) && ((psum_relu[9:0] > 10'b10_0000_0000) || (psum_relu[9:0] == 10'b10_0000_0000 && psum_relu[10]));
assign round_1      = (layer_latch == 3'd1) && ((psum_relu[8:0] >   9'b1_0000_0000) || (psum_relu[8:0] ==   9'b1_0000_0000 && psum_relu[9]));
assign round_2      = (layer_latch == 3'd2) && ((psum_relu[8:0] >   9'b1_0000_0000) || (psum_relu[8:0] ==   9'b1_0000_0000 && psum_relu[9]));
assign round_3      = (layer_latch == 3'd3) && ((psum_relu[8:0] >   9'b1_0000_0000) || (psum_relu[8:0] ==   9'b1_0000_0000 && psum_relu[9]));
assign round_5      = (layer_latch == 3'd5) && ((psum_relu[6:0] >      7'b100_0000) || (psum_relu[6:0] ==      7'b100_0000 && psum_relu[7]));
assign round_6      = (layer_latch == 3'd6) && ((psum_relu[6:0] >      7'b100_0000) || (psum_relu[6:0] ==      7'b100_0000 && psum_relu[7]));
assign psum_relu    = ((layer_latch == 3'd0 || layer_latch == 3'd1 || layer_latch == 3'd2 || layer_latch == 3'd3) && (~psum_mp[23])) ? psum_mp : 
                      ((layer_latch == 3'd5 || layer_latch == 3'd6) && (~psum_fc[23]))                                               ? psum_fc : 24'd0;

// finite state machine
always_ff@(posedge clk or posedge rst)begin
    if(rst) cur_state <= IDLE;
    else    cur_state <= next_state;
end

// next state logic
always_comb 
begin
    case(cur_state)
    IDLE:       next_state = (start) ? (layer == 3'd5 || layer == 3'd6) ? FC : FIRST : IDLE;
    FIRST:      next_state = (data_valid && count_1 == input_size) ? SECOND : FIRST;
    SECOND:     next_state = (data_valid && count_2 == input_size) ? ((count_c == channel_size) ? MAX_POOL : FIRST) : SECOND;
    MAX_POOL:   next_state = RE_QUAN;
    FC:         next_state = (data_valid) ? RE_QUAN : FC;
    RE_QUAN:    next_state = POP;
    POP:        next_state = (count_o == output_size) ? IDLE : MAX_POOL;
    default:    next_state = IDLE;
    endcase
end

// calculating layer save
always_ff@(posedge clk or posedge rst)begin
    if(rst)
        layer_latch <= 3'd0;
    else if(start)
        layer_latch <= layer;
    else
        layer_latch <= layer_latch;
end

// layer information set
assign input_size   =   (layer_latch == 3'd0) ? INPUT_SIZE_0    :
                        (layer_latch == 3'd1) ? INPUT_SIZE_1    :
                        (layer_latch == 3'd2) ? INPUT_SIZE_2    :
                        (layer_latch == 3'd3) ? INPUT_SIZE_3    : 7'd0;
assign output_size  =   (layer_latch == 3'd0) ? OUTPUT_SIZE_0   :
                        (layer_latch == 3'd1) ? OUTPUT_SIZE_1   :
                        (layer_latch == 3'd2) ? OUTPUT_SIZE_2   :
                        (layer_latch == 3'd3) ? OUTPUT_SIZE_3   : 7'd0;
assign channel_size =   (layer_latch == 3'd0) ? CHANNEL_SIZE_1  :
                        (layer_latch == 3'd1) ? CHANNEL_SIZE_4  :
                        (layer_latch == 3'd2) ? CHANNEL_SIZE_8  :
                        (layer_latch == 3'd3) ? CHANNEL_SIZE_8  : 4'd0;

// first row counter
always_ff@(posedge clk or posedge rst)begin
    if(rst)
        count_1 <= 7'd0;
    else if(cur_state == SECOND)
        count_1 <= 7'd0;
    else if(cur_state == FIRST && data_valid)
        count_1 <= count_1 + 7'd1;
    else
        count_1 <= count_1;
end

// first row data save
always_ff@(posedge clk or posedge rst)begin
    if(rst)begin
        for(integer i=0; i<96; i=i+1)
            psum_1[i] <= 24'd0;
    end
    else if(cur_state == IDLE)begin
        for(integer j=0; j<96; j=j+1)
            psum_1[j] <= 24'd0;
    end
    else if(cur_state == FIRST && data_valid)begin
        psum_1[count_1] <= psum_1[count_1] + data_in;
    end
end

// second row counter
always_ff@(posedge clk or posedge rst)begin
    if(rst)
        count_2 <= 7'd0;
    else if(cur_state == FIRST)
        count_2 <= 7'd0;
    else if(cur_state == SECOND && data_valid)
        count_2 <= count_2 + 7'd1;
    else
        count_2 <= count_2;
end

// second row data save
always_ff@(posedge clk or posedge rst)begin
    if(rst)begin
        for(integer m=0; m<96; m=m+1)
            psum_2[m] <= 24'd0;
    end
    else if(cur_state == IDLE)begin
        for(integer n=0; n<96; n=n+1)
            psum_2[n] <= 24'd0;
    end
    else if(cur_state == SECOND && data_valid)begin
        psum_2[count_2] <= psum_2[count_2] + data_in;
    end
end

// channel counter
always_ff@(posedge clk or posedge rst)begin
    if(rst)
        count_c <= 4'd0;
    else if(cur_state == IDLE)
        count_c <= 4'd0;
    else if(data_valid && count_2 == input_size)
        count_c <= count_c + 4'd1;
    else
        count_c <= count_c;
end

// max pooling counter
always_ff@(posedge clk or posedge rst)begin
    if(rst)
        count_mp <= 7'd0;
    else if(cur_state == IDLE)
        count_mp <= 7'd0;
    else if(cur_state == MAX_POOL)
        count_mp <= count_mp + 7'd2;
    else
        count_mp <= count_mp;
end

// max pooling
always_ff@(posedge clk or posedge rst)begin
    if(rst)
        psum_mp <= 24'd0;
    else if(cur_state == MAX_POOL)begin
        if(($signed(psum_1[count_mp])>=$signed(psum_1[count_mp1])) && ($signed(psum_1[count_mp])>=$signed(psum_2[count_mp])) && ($signed(psum_1[count_mp])>=$signed(psum_2[count_mp1])))
            psum_mp <= psum_1[count_mp];
        else if(($signed(psum_1[count_mp1])>=$signed(psum_1[count_mp])) && ($signed(psum_1[count_mp1])>=$signed(psum_2[count_mp])) && ($signed(psum_1[count_mp1])>=$signed(psum_2[count_mp1])))
            psum_mp <= psum_1[count_mp1];
        else if(($signed(psum_2[count_mp])>=$signed(psum_1[count_mp])) && ($signed(psum_2[count_mp])>=$signed(psum_1[count_mp1])) && ($signed(psum_2[count_mp])>=$signed(psum_2[count_mp1])))
            psum_mp <= psum_2[count_mp];
        else
            psum_mp <= psum_2[count_mp1];
    end
end

// fuly connect data save
always_ff@(posedge clk or posedge rst)begin
    if(rst)
        psum_fc <= 24'd0;
    else if(cur_state == IDLE)
        psum_fc <= 24'd0;
    else if(cur_state == FC && data_valid)
        psum_fc <= data_in;
    else 
        psum_fc <= psum_fc;
end

// requantization result
always_ff@(posedge clk or posedge rst)begin
    if(rst)
        data_out <= 8'd0;
    else if(cur_state == RE_QUAN)begin
        case(layer_latch)
        3'd0:    data_out <= (round_0) ? psum_relu[17:10] + 8'd1 : psum_relu[17:10];
        3'd1:    data_out <= (round_1) ? psum_relu[16:9]  + 8'd1 : psum_relu[16:9];
        3'd2:    data_out <= (round_2) ? psum_relu[16:9]  + 8'd1 : psum_relu[16:9];
        3'd3:    data_out <= (round_3) ? psum_relu[16:9]  + 8'd1 : psum_relu[16:9];
        3'd5:    data_out <= (round_5) ? psum_relu[14:7]  + 8'd1 : psum_relu[14:7];
        3'd6:    data_out <= (round_6) ? psum_relu[14:7]  + 8'd1 : psum_relu[14:7];
        default: data_out <= 8'd0;
        endcase
    end
end

// output counter
always_ff@(posedge clk or posedge rst)begin
    if(rst)
        count_o <= 7'd0;
    else if(cur_state == IDLE)
        count_o <= 7'd0;
    else if(cur_state == POP)
        count_o <= count_o + 7'd1;
    else
        count_o <= count_o;
end

endmodule
