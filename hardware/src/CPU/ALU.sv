module ALU (
    i_aluoperation,
    i_src1,
    i_src2,
    o_aluresult
);

input           [4:0]   i_aluoperation;
input           [31:0]  i_src1;
input           [31:0]  i_src2;

output  logic   [31:0]  o_aluresult;

logic           [63:0]  Mul_result;
logic           [63:0]  i_src1_64_u;
logic           [63:0]  i_src2_64_u;
logic           [63:0]  i_src1_64_s;
logic           [63:0]  i_src2_64_s;
logic           [31:0]  fadd_result;

// parameters for ALU operations
localparam  ADD             = 5'b00000;
localparam  SUB             = 5'b00001;
localparam  SLL             = 5'b00010;
localparam  SLT             = 5'b00011;
localparam  SLTU            = 5'b00100;
localparam  XOR             = 5'b00101;
localparam  SRL             = 5'b00110;
localparam  SRA             = 5'b00111;
localparam  OR              = 5'b01000;
localparam  AND             = 5'b01001;
localparam  MUL             = 5'b01010;
localparam  MULH            = 5'b01011;
localparam  MULHSU          = 5'b01100;
localparam  MULHU           = 5'b01101;
localparam  EQUAL           = 5'b01110;
localparam  NEQUAL          = 5'b01111;
localparam  S_LESSTHAN      = 5'b10000;
localparam  S_GREATEREQUAL  = 5'b10001;
localparam  U_LESSTHAN      = 5'b10010;
localparam  U_GREATEREQUAL  = 5'b10011;
localparam  FADD            = 5'b10100;
localparam  FSUB            = 5'b10101;
localparam  ANDN            = 5'b10110; // from Zbb extension
localparam  ORN             = 5'b10111; // from Zbb extension
localparam  XNOR            = 5'b11000; // from Zbb extension
localparam  MAX             = 5'b11001; // from Zbb extension
localparam  MAXU            = 5'b11010; // from Zbb extension
localparam  MIN             = 5'b11011; // from Zbb extension
localparam  MINU            = 5'b11100; // from Zbb extension
localparam  SEXTB           = 5'b11101; // from Zbb extension
localparam  RETURN1         = 5'b11111;

assign  i_src1_64_u = {32'd0, i_src1};
assign  i_src2_64_u = {32'd0, i_src1};
assign  i_src1_64_s = {{32{i_src1[31]}}, i_src1};
assign  i_src2_64_s = {{32{i_src1[31]}}, i_src1};

always_comb begin
    case (i_aluoperation)
        MUL:            Mul_result  =   i_src1 * i_src2;
        MULH:           Mul_result  =   i_src1_64_s * i_src2_64_s;
        MULHSU:         Mul_result  =   i_src1_64_s * i_src2;
        MULHU:          Mul_result  =   i_src1 * i_src2;
        default:        Mul_result  =   64'd0;
    endcase
end

always_comb begin
    case (i_aluoperation)
        ADD:            o_aluresult =   $signed(i_src1) + $signed(i_src2);
        SUB:            o_aluresult =   $signed(i_src1) - $signed(i_src2);
        SLL:            o_aluresult =   i_src1 << i_src2[4:0];
        SLT:            o_aluresult =   ($signed(i_src1) < $signed(i_src2)) ?   32'd1 : 32'd0;
        SLTU:           o_aluresult =   (i_src1 < i_src2) ? 32'd1 : 32'd0;
        XOR:            o_aluresult =   i_src1 ^ i_src2;
        SRL:            o_aluresult =   i_src1 >> i_src2[4:0];
        SRA:            o_aluresult =   $signed(i_src1) >>> i_src2[4:0];
        OR:             o_aluresult =   i_src1 | i_src2;
        AND:            o_aluresult =   i_src1 & i_src2;
        MUL:            o_aluresult =   Mul_result[31:0];
        MULH:           o_aluresult =   Mul_result[63:32];
        MULHSU:         o_aluresult =   Mul_result[63:32];
        MULHU:          o_aluresult =   Mul_result[63:32];
        EQUAL:          o_aluresult =   (i_src1 == i_src2)  ? 32'd1 : 32'd0;
        NEQUAL:         o_aluresult =   (i_src1 != i_src2)  ? 32'd1 : 32'd0;
        S_LESSTHAN:     o_aluresult =   ($signed(i_src1) < $signed(i_src2)) ? 32'd1 : 32'd0;
        S_GREATEREQUAL: o_aluresult =   ($signed(i_src1) >= $signed(i_src2))? 32'd1 : 32'd0;
        U_LESSTHAN:     o_aluresult =   (i_src1 < i_src2)   ? 32'd1 : 32'd0;
        U_GREATEREQUAL: o_aluresult =   (i_src1 >= i_src2)  ? 32'd1 : 32'd0;
        FADD:           o_aluresult =   fadd_result;
        FSUB:           o_aluresult =   fadd_result;
        ANDN:           o_aluresult =   i_src1 & (~i_src2);
        ORN:            o_aluresult =   i_src1 | (~i_src2);
        XNOR:           o_aluresult =   ~(i_src1 ^ i_src2);
        MAX:            o_aluresult =   ($signed(i_src1) > $signed(i_src2)) ? i_src1 : i_src2;
        MAXU:           o_aluresult =   (i_src1 > i_src2) ? i_src1 : i_src2;
        MIN:            o_aluresult =   ($signed(i_src1) < $signed(i_src2)) ? i_src1 : i_src2;
        MINU:           o_aluresult =   (i_src1 < i_src2) ? i_src1 : i_src2;
        SEXTB:          o_aluresult =   {{24{i_src1[7]}}, i_src1[7:0]};
        RETURN1:        o_aluresult =   32'd1;
        default:        o_aluresult =   32'd1;
    endcase
end

logic           fopr_add, fopr_sub;
logic   [31:0]  fadd_a, fadd_b;
logic   [7:0]   exp_fadd_a, exp_fadd_b;
logic   [22:0]  frac_fadd_a, frac_fadd_b;
logic           fadd_a_abs_larger, fadd_res_0;
logic   [31:0]  swap_fadd_a, swap_fadd_b;
logic   [7:0]   exp_swap_fadd_a, exp_swap_fadd_b, diff_exponent;
logic   [48:0]  frac_swap_fadd_a, frac_swap_fadd_b;
logic   [48:0]  shift_frac_swap_fadd_b;
logic   [48:0]  frac_fadd_temp;

assign  fopr_add                =   (i_aluoperation == FADD);
assign  fopr_sub                =   (i_aluoperation == FSUB);
assign  fadd_a                  =   fopr_add ? i_src1 :
                                    fopr_sub ? i_src1 : 32'd0;
assign  fadd_b                  =   fopr_add ? i_src2 :
                                    fopr_sub ? {~i_src2[31], i_src2[30:0]} : 32'd0;
assign  exp_fadd_a              =   fadd_a[30:23];
assign  exp_fadd_b              =   fadd_b[30:23];
assign  frac_fadd_a             =   fadd_a[22:0];
assign  frac_fadd_b             =   fadd_b[22:0];

assign  fadd_a_abs_larger       =   (exp_fadd_a > exp_fadd_b)   ? 1'b1  :
                                    ((exp_fadd_a == exp_fadd_b) && (frac_fadd_a > frac_fadd_b))  ? 1'b1  : 1'b0;
assign  fadd_res_0              =   (fadd_a[31] ^ fadd_b) && (fadd_a[30:0] == fadd_b[30:0]);

assign  swap_fadd_a             =   fadd_a_abs_larger  ? fadd_a : fadd_b;
assign  swap_fadd_b             =   fadd_a_abs_larger  ? fadd_b : fadd_a;
assign  exp_swap_fadd_a         =   swap_fadd_a[30:23];
assign  exp_swap_fadd_b         =   swap_fadd_b[30:23];
assign  diff_exponent           =   exp_swap_fadd_a - exp_swap_fadd_b;
assign  frac_swap_fadd_a        =   {2'b01, swap_fadd_a[22:0], 24'd0};  // carry, hidden 1, fraction
assign  frac_swap_fadd_b        =   {2'b01, swap_fadd_b[22:0], 24'd0};
assign  shift_frac_swap_fadd_b  =   frac_swap_fadd_b >> diff_exponent;
assign  frac_fadd_temp          =   (swap_fadd_a[31] == swap_fadd_b[31]) ? (frac_swap_fadd_a + shift_frac_swap_fadd_b) : (frac_swap_fadd_a - shift_frac_swap_fadd_b);
// Find first 1
logic   [4:0]   index;
logic   [15:0]  tmp0;
logic   [7:0]   tmp1;
logic   [3:0]   tmp2;
logic   [1:0]   tmp3;
logic   [48:0]  shift_manti, round_manti;
logic   [22:0]  correct_manti;
logic   [7:0]   tmp_exp, correct_exp;
assign  index[4]                =   |{7'd0, frac_fadd_temp[48:24]};
assign  tmp0                    =   index[4] ? {7'd0, frac_fadd_temp[48:40]} : frac_fadd_temp[39:24];
assign  index[3]                =   |tmp0[15:8];
assign  tmp1                    =   index[3] ? tmp0[15:8] : tmp0[7:0];
assign  index[2]                =   |tmp1[7:4];
assign  tmp2                    =   index[2] ? tmp1[7:4] : tmp1[3:0];
assign  index[1]                =   |tmp2[3:2];
assign  tmp3                    =   index[1] ? tmp2[3:2] : tmp2[1:0];
assign  index[0]                =   tmp3[1];
assign  shift_manti             =   (index == 5'd24) ? (frac_fadd_temp >> 5'd1)   :
                                    (index == 5'd23) ? frac_fadd_temp   :
                                    (index < 5'd23) ? (frac_fadd_temp << (5'd23 - index))   : 49'd0;
assign  tmp_exp                 =   (index == 5'd24) ? (exp_swap_fadd_a + 8'd1) :
                                    (index == 5'd23) ? exp_swap_fadd_a  :
                                    (index < 5'd23) ? (exp_swap_fadd_a - (5'd23 - index))   : 8'd0;
assign  round_manti             =   (shift_manti[23:0] > 24'h80_0000) ? (shift_manti + 32'h0100_0000) :
                                    ((shift_manti[23:0] == 24'h80_0000) & shift_manti[24]) ? (shift_manti + 32'h0100_0000) : shift_manti;
assign  correct_manti           =   round_manti[48] ? round_manti[47:25] : round_manti[46:24];
assign  correct_exp             =   round_manti[48] ? (tmp_exp + 8'd1) : tmp_exp;

assign  fadd_result             =   fadd_res_0 ? 32'd0 : {swap_fadd_a[31], correct_exp, correct_manti};

endmodule