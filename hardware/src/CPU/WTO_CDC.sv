module WTO_CDC(
    input           clk,
    input           rst,
    input           clk2,
    input           rst2,
    input           cdc_in,

    output logic    cdc_out
);

logic toggle_1;
logic toggle_2;
logic toggle_3;
logic cdc_d;

always_ff@(posedge clk or posedge rst)begin
    if (rst)begin
        cdc_d    <= 1'b0;
    end
    else begin
        cdc_d    <= cdc_in;
    end
end

always_ff@(posedge clk2 or posedge rst2)begin
    if(rst2)begin
        toggle_1 <= 1'b0;
        toggle_2 <= 1'b0;
        toggle_3 <= 1'b0;
    end
    else begin
//        toggle_1 <= cdc_in;
        toggle_1 <= cdc_d;
        toggle_2 <= toggle_1;
        toggle_3 <= toggle_2;
    end
end

assign cdc_out = toggle_2 && (!toggle_3);

endmodule