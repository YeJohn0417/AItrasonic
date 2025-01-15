module CSR (
input                   clk,
input                   rst,
input                   i_rst_1,
input           [31:0]  i_pc,
input           [2:0]   i_csr_sel,
input           [11:0]  i_csr_addr,
input           [31:0]  i_rs1_data,
input           [31:0]  i_imm,
input                   i_intr_dma,
input                   i_intr_wdt,

output  logic   [31:0]  o_csr_result,   // 1 RDINSTRETH, 2 RDINSTRET, 3 RDCYCLEH, 4 RDCYCLE
output  logic           o_mret,
output  logic           o_intr,
output  logic   [31:0]  o_pc_mret,
output  logic   [31:0]  o_pc_intr,
output  logic           o_wait_WFI
);

logic   [31:0]  mstatus;
logic   [31:0]  mie;
logic   [31:0]  mtvec;
logic   [31:0]  mepc;
logic   [31:0]  mip;
logic   [63:0]  cycle;
logic   [63:0]  instret;
logic           MRET;
logic           WFI;
logic           INTR_WFI;
logic           INTR_NWFI;
logic           INTR;

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        cycle   <= 64'd0;
        instret <= 64'd0;
    end
    else begin
        if (!i_rst_1)    instret <= 64'd1;
        else begin
            cycle   <= cycle    + 64'd1;
            if (i_pc != 32'd0)  instret <= instret  + 64'd1;
        end
    end
end

assign  MRET        = (i_csr_sel == 3'd1) && (i_csr_addr == 12'h302);   // clear mip
assign  WFI         = (i_csr_sel == 3'd1) && (i_csr_addr == 12'h105);
assign  INTR_WFI    = (mip[7] && mie[7]) || (mip[11] && mie[11]);
assign  INTR_NWFI   = (mip[7] && mstatus[3] && mie[7]) || (mip[11] && mstatus[3] && mie[11]);
//assign  INTR        = i_intr_dma || i_intr_wdt;
assign  INTR        = o_wait_WFI    ? INTR_WFI  : INTR_NWFI;
assign  o_intr      = INTR;
assign  o_pc_intr   = INTR  ? {mtvec[31:2], 2'b00}  : 32'd0;
assign  o_mret      = MRET;
assign  o_pc_mret   = MRET  ? mepc  : 32'd0;

always_ff @(posedge clk or posedge rst) begin
    if (rst)    o_wait_WFI   <= 1'b0;
    else begin
        if (WFI)    o_wait_WFI   <= 1'b1;
        else if (INTR)  o_wait_WFI   <= 1'b0;
    end
end

always_ff @(posedge clk or posedge rst) begin
    if (rst)                    mstatus     <= 32'd0;
    else begin
//        if  ((mstatus[3] && mie[7] && mip[7]) && (mstatus[3] && mie[11] && mip[11])) begin
        if  (INTR) begin
            mstatus[3]      <= 1'b0;
            mstatus[7]      <= mstatus[3];
            mstatus[12:11]  <= 2'b11;
        end
        else if (MRET) begin
            mstatus[3]      <= mstatus[7];
            mstatus[7]      <= 1'b1;
            mstatus[12:11]  <= 2'b11;
        end
        else begin
            case ({i_csr_sel, i_csr_addr})
                15'b010_0011_0000_0000: begin
                    mstatus[3]  <= i_rs1_data[3];
                    mstatus[7]  <= i_rs1_data[7];
                    mstatus[11] <= i_rs1_data[11];
                    mstatus[12] <= i_rs1_data[12];
                end
                15'b011_0011_0000_0000: begin
                    mstatus[3]  <= mstatus[3]   | i_rs1_data[3];
                    mstatus[7]  <= mstatus[7]   | i_rs1_data[7];
                    mstatus[11] <= mstatus[11]  | i_rs1_data[11];
                    mstatus[12] <= mstatus[12]  | i_rs1_data[12];
                end
                15'b100_0011_0000_0000: begin
                    mstatus[3]  <= mstatus[3]   & (~i_rs1_data[3]);
                    mstatus[7]  <= mstatus[7]   & (~i_rs1_data[7]);
                    mstatus[11] <= mstatus[11]  & (~i_rs1_data[11]);
                    mstatus[12] <= mstatus[12]  & (~i_rs1_data[12]);
                end
                15'b101_0011_0000_0000: begin
                    mstatus[3]  <= i_imm[3];
                    mstatus[7]  <= i_imm[7];
                    mstatus[11] <= i_imm[11];
                    mstatus[12] <= i_imm[12];
                end
                15'b110_0011_0000_0000: begin
                    mstatus[3]  <= mstatus[3]   | i_imm[3];
                    mstatus[7]  <= mstatus[7]   | i_imm[7];
                    mstatus[11] <= mstatus[11]  | i_imm[11];
                    mstatus[12] <= mstatus[12]  | i_imm[12];
                end
                15'b111_0011_0000_0000: begin
                    mstatus[3]  <= mstatus[3]   & (~i_imm[3]);
                    mstatus[7]  <= mstatus[7]   & (~i_imm[7]);
                    mstatus[11] <= mstatus[11]  & (~i_imm[11]);
                    mstatus[12] <= mstatus[12]  & (~i_imm[12]);
                end
                default:    mstatus <= mstatus;
            endcase
        end
    end
end

always_ff @(posedge clk or posedge rst) begin
    if (rst)    mie     <= 32'd0;
    else begin
        case ({i_csr_sel, i_csr_addr})
            15'b010_0011_0000_0100: begin
                mie[7]  <= i_rs1_data[7];
                mie[11] <= i_rs1_data[11];
            end
            15'b011_0011_0000_0100: begin
                mie[7]  <= mie[7]   | i_rs1_data[7];
                mie[11] <= mie[11]  | i_rs1_data[11];
            end
            15'b100_0011_0000_0100: begin
                mie[7]  <= mie[7]   & (~i_rs1_data[7]);
                mie[11] <= mie[11]  & (~i_rs1_data[11]);
            end
            15'b101_0011_0000_0100: begin
                mie[7]  <= i_imm[7];
                mie[11] <= i_imm[11];
            end
            15'b110_0011_0000_0100: begin
                mie[7]  <= mie[7]   | i_imm[7];
                mie[11] <= mie[11]  | i_imm[11];
            end
            15'b111_0011_0000_0100: begin
                mie[7]  <= mie[7]   & (~i_imm[7]);
                mie[11] <= mie[11]  & (~i_imm[11]);
            end
            default:    mie <= mie;
        endcase
    end
end

always_ff @(posedge clk or posedge rst) begin
    if (rst)    mtvec   <= 32'd0;
    else begin  mtvec   <= 32'h0001_0000;
/*         case ({i_csr_sel, i_csr_addr})
            15'b010_0011_0000_0101: begin
                mtvec[7]  <= i_rs1_data[7];
                mtvec[11] <= i_rs1_data[11];
            end
            15'b011_0011_0000_0101: begin
                mtvec[7]  <= mtvec[7]   | i_rs1_data[7];
                mtvec[11] <= mtvec[11]  | i_rs1_data[11];
            end
            15'b100_0011_0000_0101: begin
                mtvec[7]  <= mtvec[7]   & (~i_rs1_data[7]);
                mtvec[11] <= mtvec[7]   & (~i_rs1_data[11]);
            end
            15'b101_0011_0000_0101: begin
                mtvec[7]  <= i_imm[7];
                mtvec[11] <= i_imm[11];
            end
            15'b110_0011_0000_0101: begin
                mtvec[7]  <= mtvec[7]   | i_imm[7];
                mtvec[11] <= mtvec[7]   | i_imm[11];
            end
            15'b111_0011_0000_0101: begin
                mtvec[7]  <= mtvec[7]   & (~i_imm[7]);
                mtvec[11] <= mtvec[11]  & (~i_imm[11]);
            end
            default:    mtvec <= 32'd0;
        endcase*/
    end
end

always_ff @(posedge clk or posedge rst) begin
    if (rst)    mepc    <= 32'd0;
    else begin
//        if      (o_wait_WFI && INTR_WFI)   mepc    <= i_pc + 32'd4;
        if      (o_wait_WFI && INTR_WFI)   mepc    <= i_pc;
        else if (INTR_NWFI)  mepc    <= i_pc;
//        else if ((i_csr_sel == 3'd1) && (i_csr_sel == 12'h302)) 
        else begin
            case ({i_csr_sel, i_csr_addr})
                15'b010_0011_0100_0001: mepc    <= i_rs1_data;
                15'b011_0011_0100_0001: mepc    <= mepc   | i_rs1_data;
                15'b100_0011_0100_0001: mepc    <= mepc   & (~i_rs1_data);
                15'b101_0011_0100_0001: mepc    <= i_imm;
                15'b110_0011_0100_0001: mepc    <= mepc   | i_imm;
                15'b111_0011_0100_0001: mepc    <= mepc   & (~i_imm);
                default:                mepc    <= mepc;
            endcase
        end
    end
end

always_ff @(posedge clk or posedge rst) begin
    if (rst)                    mip     <= 32'd0;
    else begin
//        if      (i_intr_dma)    mip[11] <= 1'b1;
        if      (i_intr_dma)    mip     <= 32'h800;
//        else if (i_intr_wdt)    mip[7]  <= 1'b1;
        else if (i_intr_wdt)    mip     <= 32'h80;
        else if (MRET)          mip     <= 32'b0;
//        else begin
//            case ({i_csr_sel, i_csr_addr})
//                15'b010_0011_0100_0100: begin
//                    mip[7]  <= i_rs1_data[7];
//                    mip[11] <= i_rs1_data[11];
//                end
//                15'b011_0011_0100_0100: begin
//                    mip[7]  <= mip[7]   | i_rs1_data[7];
//                    mip[11] <= mip[11]  | i_rs1_data[11];
//                end
//                15'b100_0011_0100_0100: begin
//                    mip[7]  <= mip[7]   & (~i_rs1_data[7]);
//                    mip[11] <= mip[11]  & (~i_rs1_data[11]);
//                end
//                15'b101_0011_0100_0100: begin
//                    mip[7]  <= i_imm[7];
//                    mip[11] <= i_imm[11];
//                end
//                15'b110_0011_0100_0100: begin
//                    mip[7]  <= mip[7]   | i_imm[7];
//                    mip[11] <= mip[11]  | i_imm[11];
//                end
//                15'b111_0011_0100_0100: begin
//                    mip[7]  <= mip[7]   & (~i_imm[7]);
//                    mip[11] <= mip[11]  & (~i_imm[11]);
//                end
//                default:    mip <= mip;
//            endcase
//        end
    end
end

always_comb begin
    if (i_csr_sel == 3'd2) begin
        case (i_csr_addr)
            12'h300:    o_csr_result    = mstatus;
            12'h304:    o_csr_result    = mie;
            12'h305:    o_csr_result    = mtvec;
            12'h341:    o_csr_result    = mepc;
            12'h344:    o_csr_result    = mip;
            12'hc82:    o_csr_result    = instret[63:32];
            12'h002:    o_csr_result    = instret[31:0];
            12'hc80:    o_csr_result    = cycle[63:32];
            12'hc00:    o_csr_result    = cycle[31:0];
            default:    o_csr_result    = 32'd0;
        endcase
    end
    else begin
        case (i_csr_addr)
            12'h300:    o_csr_result    = mstatus;
            12'h304:    o_csr_result    = mie;
            12'h305:    o_csr_result    = mtvec;
            12'h341:    o_csr_result    = mepc;
            12'h344:    o_csr_result    = mip;
            default:    o_csr_result    = 32'd0;
        endcase
    end
end

endmodule
