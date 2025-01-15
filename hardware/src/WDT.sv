module WDT(
    input                       clk,
    input                       rst,
    input                       WDEN,
    input                       WDLIVE,
    input [`AXI_DATA_BITS-1:0]  WTOCNT,

    output logic                WTO
);

logic [`AXI_DATA_BITS-1:0]  count;

logic                       Latch_WDEN;
logic [`AXI_DATA_BITS-1:0]  Latch_WTOCNT;


assign WTO = (count == Latch_WTOCNT) && (count != `AXI_DATA_BITS'd0);

always_ff@(posedge clk or posedge rst)
begin
    if(rst)
        Latch_WDEN      <= 1'b0;
    else if(WDEN)
        Latch_WDEN      <= 1'b1;
    else if(WTO)
        Latch_WDEN      <= 1'b0;
end

always_ff@(posedge clk or posedge rst)
begin
    if(rst)
        Latch_WTOCNT <= `AXI_DATA_BITS'd0;
    else if(WTOCNT != 0)
        Latch_WTOCNT <= WTOCNT;
    else if(WTO)
        Latch_WTOCNT <= `AXI_DATA_BITS'd0;
end

always_ff@(posedge clk or posedge rst)
begin
    if(rst)
        count <= `AXI_DATA_BITS'd0;
    else if(WDEN || Latch_WDEN)begin
        if(WDLIVE)
            count <= `AXI_DATA_BITS'd0;
        else if(count >= Latch_WTOCNT)
            count <= `AXI_DATA_BITS'd0;
        else begin
            count <= count + `AXI_DATA_BITS'd1;        
        end
    end
end

endmodule