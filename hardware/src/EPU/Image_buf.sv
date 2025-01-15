module Image_buf (
input               clk,
input               rst,
input               i_image_new_25,
input               i_image_new_5,
input               i_image_new_16,
input               i_image_new_8,
input               i_conv_done,
input         [7:0] i_image,
output  logic [7:0] o_RC00, o_RC01, o_RC02, o_RC03, o_RC04,
output  logic [7:0] o_RC10, o_RC11, o_RC12, o_RC13, o_RC14,
output  logic [7:0] o_RC20, o_RC21, o_RC22, o_RC23, o_RC24,
output  logic [7:0] o_RC30, o_RC31, o_RC32, o_RC33, o_RC34,
output  logic [7:0] o_RC40, o_RC41, o_RC42, o_RC43, o_RC44
);

logic [7:0] buf0    [4:0];
logic [7:0] buf1    [4:0];
logic [7:0] buf2    [4:0];
logic [7:0] buf3    [4:0];
logic [7:0] buf4    [4:0];
logic [3:0] row_cnt;
logic [3:0] col_cnt;

always_ff @(posedge clk or posedge rst) begin
  if (rst) begin
    for (int i = 0; i < 5; i++) buf0[i] <= 8'd0;
    for (int i = 0; i < 5; i++) buf1[i] <= 8'd0;
    for (int i = 0; i < 5; i++) buf2[i] <= 8'd0;
    for (int i = 0; i < 5; i++) buf3[i] <= 8'd0;
    for (int i = 0; i < 5; i++) buf4[i] <= 8'd0;
  end
  else begin
    if (i_image_new_25) begin
      case (row_cnt)
        3'd0: buf0[col_cnt] <= i_image;
        3'd1: buf1[col_cnt] <= i_image;
        3'd2: buf2[col_cnt] <= i_image;
        3'd3: buf3[col_cnt] <= i_image;
        3'd4: buf4[col_cnt] <= i_image;
        default:  begin
          buf0[col_cnt] <= 8'd0;
          buf1[col_cnt] <= 8'd0;
          buf2[col_cnt] <= 8'd0;
          buf3[col_cnt] <= 8'd0;
          buf4[col_cnt] <= 8'd0;
        end
      endcase
    end
    else if (i_image_new_5) begin
      case (row_cnt)
        3'd0: buf0[4] <= i_image;
        3'd1: buf1[4] <= i_image;
        3'd2: buf2[4] <= i_image;
        3'd3: buf3[4] <= i_image;
        3'd4: buf4[4] <= i_image;
        default:  begin
          buf0[4] <= 8'd0;
          buf1[4] <= 8'd0;
          buf2[4] <= 8'd0;
          buf3[4] <= 8'd0;
          buf4[4] <= 8'd0;
        end
      endcase
    end
    else if (i_image_new_16 || i_image_new_8) begin
      case (row_cnt)
        3'd0: buf0[col_cnt] <= i_image;
        3'd1: buf1[col_cnt] <= i_image;
        3'd2: buf2[col_cnt] <= i_image;
        3'd3: buf3[col_cnt] <= i_image;
        3'd4: buf4[col_cnt] <= 8'd0;
        default: begin
          buf0[4] <= 8'd0;
          buf1[4] <= 8'd0;
          buf2[4] <= 8'd0;
          buf3[4] <= 8'd0;
          buf4[4] <= 8'd0;
        end
      endcase
    end
    else if (i_conv_done) begin   // shift when convolution done
      buf0[0] <= buf0[1];
      buf0[1] <= buf0[2];
      buf0[2] <= buf0[3];
      buf0[3] <= buf0[4];
      buf1[0] <= buf1[1];
      buf1[1] <= buf1[2];
      buf1[2] <= buf1[3];
      buf1[3] <= buf1[4];
      buf2[0] <= buf2[1];
      buf2[1] <= buf2[2];
      buf2[2] <= buf2[3];
      buf2[3] <= buf2[4];
      buf3[0] <= buf3[1];
      buf3[1] <= buf3[2];
      buf3[2] <= buf3[3];
      buf3[3] <= buf3[4];
      buf4[0] <= buf4[1];
      buf4[1] <= buf4[2];
      buf4[2] <= buf4[3];
      buf4[3] <= buf4[4];
    end
  end
end

always_ff @(posedge clk or posedge rst) begin
  if      (rst) row_cnt <= 3'd0;
  else if ((i_image_new_5 || i_image_new_25) && (row_cnt == 3'd4))  row_cnt <= 3'd0;
  else if ((i_image_new_16 || i_image_new_8) && (row_cnt == 3'd3))  row_cnt <= 3'd0;
  else if (i_image_new_5 || i_image_new_25 || i_image_new_16 || i_image_new_8)  row_cnt <= row_cnt + 3'd1;
end

always_ff @(posedge clk or posedge rst) begin
  if      (rst) col_cnt <= 3'd0;
  else if (i_image_new_25 && (col_cnt == 3'd4) && (row_cnt == 3'd4))  col_cnt <= 3'd0;
  else if ((i_image_new_16 || i_image_new_8) && (col_cnt == 3'd3) && (row_cnt == 3'd3)) col_cnt <= 3'd0;
  else if (i_image_new_25 && (row_cnt == 3'd4)) col_cnt <= col_cnt + 3'd1;
  else if ((i_image_new_16 || i_image_new_8) && (row_cnt == 3'd4))  col_cnt <= col_cnt + 3'd1;
end

assign  o_RC00  = buf0[0];
assign  o_RC01  = buf0[1];
assign  o_RC02  = buf0[2];
assign  o_RC03  = buf0[3];
assign  o_RC04  = buf0[4];

assign  o_RC10  = buf1[0];
assign  o_RC11  = buf1[1];
assign  o_RC12  = buf1[2];
assign  o_RC13  = buf1[3];
assign  o_RC14  = buf1[4];

assign  o_RC20  = buf2[0];
assign  o_RC21  = buf2[1];
assign  o_RC22  = buf2[2];
assign  o_RC23  = buf2[3];
assign  o_RC24  = buf2[4];

assign  o_RC30  = buf3[0];
assign  o_RC31  = buf3[1];
assign  o_RC32  = buf3[2];
assign  o_RC33  = buf3[3];
assign  o_RC34  = buf3[4];

assign  o_RC40  = buf4[0];
assign  o_RC41  = buf4[1];
assign  o_RC42  = buf4[2];
assign  o_RC43  = buf4[3];
assign  o_RC44  = buf4[4];

endmodule