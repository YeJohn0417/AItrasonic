module tag_array_wrapper (
  input                 clk,
  input                 rst,
  input         [4:0]   A,
  output  logic [22:0]  TAG1,
  output  logic [22:0]  TAG2,
  input         [22:0]  DI,
  input                 WEB,
  input                 CEB,
  input                 i_WAY
);

logic [4:0]   TA1_A, TA2_A;
logic         TA1_CEB, TA2_CEB;
logic         TA1_WEB, TA2_WEB;
logic [31:0]  TA1_BWEB, TA2_BWEB;
logic [31:0]  TA1_DI, TA2_DI;
logic [31:0]  TA1_DO, TA2_DO;

assign  TA1_A     = A;
assign  TA2_A     = A;

 // when write another SRAM, this CEB should be 1
assign  TA1_CEB   = ((!WEB) && (!CEB) && i_WAY)     ? 1'b1  : CEB;
assign  TA2_CEB   = ((!WEB) && (!CEB) && (!i_WAY))  ? 1'b1  : CEB;

assign  TA1_WEB   = (!i_WAY)    ? WEB         : 1'b1;
assign  TA2_WEB   = i_WAY       ? WEB         : 1'b1;

assign  TA1_BWEB  = (!i_WAY)    ? {32{WEB}}   : 1'b1;
assign  TA2_BWEB  = i_WAY       ? {32{WEB}}   : 1'b1;

assign  TA1_DI    = (!i_WAY)    ? {9'd0, DI}  : 32'd0;
assign  TA2_DI    = i_WAY       ? {9'd0, DI}  : 32'd0;

assign  TAG1      = TA1_DO[22:0];
assign  TAG2      = TA2_DO[22:0];

  TS1N16ADFPCLLLVTA128X64M4SWSHOD_tag_array i_tag_array1 (
    .CLK        (clk        ),
    .A          (TA1_A      ),
    .CEB        (TA1_CEB    ),  // chip enable, active LOW
    .WEB        (TA1_WEB    ),  // write:LOW, read:HIGH
    .BWEB       (TA1_BWEB   ),  // bitwise write enable write:LOW
    .D          (TA1_DI     ),  // Data into RAM
    .Q          (TA1_DO     ),  // Data out of RAM
    .RTSEL      (2'b01      ),
    .WTSEL      (2'b01      ),
    .SLP        (1'b0       ),
    .DSLP       (1'b0       ),
    .SD         (1'b0       ),
    .PUDELAY    (           )
  );

  TS1N16ADFPCLLLVTA128X64M4SWSHOD_tag_array i_tag_array2 (
    .CLK        (clk        ),
    .A          (TA2_A      ),
    .CEB        (TA2_CEB    ),  // chip enable, active LOW
    .WEB        (TA2_WEB    ),  // write:LOW, read:HIGH
    .BWEB       (TA2_BWEB   ),  // bitwise write enable write:LOW
    .D          (TA2_DI     ),  // Data into RAM
    .Q          (TA2_DO     ),  // Data out of RAM
    .RTSEL      (2'b01      ),
    .WTSEL      (2'b01      ),
    .SLP        (1'b0       ),
    .DSLP       (1'b0       ),
    .SD         (1'b0       ),
    .PUDELAY    (           )
  );

endmodule