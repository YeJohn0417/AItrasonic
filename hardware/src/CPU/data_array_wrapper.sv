module data_array_wrapper (
  input           clk,
  input           rst,
  input   [4:0]   A,
  output  [127:0] DO,
  input   [127:0] DI,
  input           WEB,
  input   [127:0] BWEB,
  input           CEB,
  input           i_WAY
);

logic [4:0]   DA1_A, DA2_A;
logic         DA1_CEB1, DA1_CEB2, DA2_CEB1, DA2_CEB2;
logic         DA1_WEB1, DA1_WEB2, DA2_WEB1, DA2_WEB2;
logic [63:0]  DA1_BWEB1, DA1_BWEB2, DA2_BWEB1, DA2_BWEB2;
logic [63:0]  DA1_DI1, DA1_DI2, DA2_DI1, DA2_DI2;
logic [63:0]  DA1_DO1, DA1_DO2, DA2_DO1, DA2_DO2;
logic         WAY_d;

assign  DA1_A     = A;
assign  DA2_A     = A;

 // when write another SRAM, this CEB should be 1
assign  DA1_CEB1  = (!i_WAY)  ? CEB : 1'b1;
assign  DA1_CEB2  = (!i_WAY)  ? CEB : 1'b1;
assign  DA2_CEB1  = i_WAY     ? CEB : 1'b1; 
assign  DA2_CEB2  = i_WAY     ? CEB : 1'b1;

assign  DA1_WEB1  = ((!i_WAY) && (!(&BWEB[63:0])))    ? WEB : 1'b1;
assign  DA1_WEB2  = ((!i_WAY) && (!(&BWEB[127:64])))  ? WEB : 1'b1;
assign  DA2_WEB1  = (i_WAY && (!(&BWEB[63:0])))       ? WEB : 1'b1;
assign  DA2_WEB2  = (i_WAY && (!(&BWEB[127:64])))     ? WEB : 1'b1;

assign  DA1_BWEB1 = (!i_WAY)  ? BWEB[63:0]    : {64{1'b1}};
assign  DA1_BWEB2 = (!i_WAY)  ? BWEB[127:64]  : {64{1'b1}};
assign  DA2_BWEB1 = i_WAY     ? BWEB[63:0]    : {64{1'b1}};
assign  DA2_BWEB2 = i_WAY     ? BWEB[127:64]  : {64{1'b1}};

assign  DA1_DI1   = (!i_WAY)  ? DI[63:0]      : 64'd0;
assign  DA1_DI2   = (!i_WAY)  ? DI[127:64]    : 64'd0;
assign  DA2_DI1   = i_WAY     ? DI[63:0]      : 64'd0;
assign  DA2_DI2   = i_WAY     ? DI[127:64]    : 64'd0;

assign  DO        = (!WAY_d)  ? {DA1_DO2, DA1_DO1}  : {DA2_DO2, DA2_DO1};

always_ff @(posedge clk or posedge rst) begin
  if (rst)  WAY_d <= 1'b0;
  else      WAY_d <= i_WAY;
end

  TS1N16ADFPCLLLVTA128X64M4SWSHOD_data_array i_data_array1_1 (
    .CLK        (clk        ),
    .A          (DA1_A      ),
    .CEB        (DA1_CEB1   ),  // chip enable, active LOW
    .WEB        (DA1_WEB1   ),  // write:LOW, read:HIGH
    .BWEB       (DA1_BWEB1  ),  // bitwise write enable write:LOW
    .D          (DA1_DI1    ),  // Data into RAM
    .Q          (DA1_DO1    ),  // Data out of RAM
    .RTSEL      (2'b01      ),
    .WTSEL      (2'b01      ),
    .SLP        (1'b0       ),
    .DSLP       (1'b0       ),
    .SD         (1'b0       ),
    .PUDELAY    (           )
  );
  
  
    TS1N16ADFPCLLLVTA128X64M4SWSHOD_data_array i_data_array1_2 (
    .CLK        (clk        ),
    .A          (DA1_A      ),
    .CEB        (DA1_CEB2   ),  // chip enable, active LOW
    .WEB        (DA1_WEB2   ),  // write:LOW, read:HIGH
    .BWEB       (DA1_BWEB2  ),  // bitwise write enable write:LOW
    .D          (DA1_DI2    ),  // Data into RAM
    .Q          (DA1_DO2    ),  // Data out of RAM
    .RTSEL      (2'b01      ),
    .WTSEL      (2'b01      ),
    .SLP        (1'b0       ),
    .DSLP       (1'b0       ),
    .SD         (1'b0       ),
    .PUDELAY    (           )
  );

  TS1N16ADFPCLLLVTA128X64M4SWSHOD_data_array i_data_array2_1 (
    .CLK        (clk        ),
    .A          (DA2_A      ),
    .CEB        (DA2_CEB1   ),  // chip enable, active LOW
    .WEB        (DA2_WEB1   ),  // write:LOW, read:HIGH
    .BWEB       (DA2_BWEB1  ),  // bitwise write enable write:LOW
    .D          (DA2_DI1    ),  // Data into RAM
    .Q          (DA2_DO1    ),  // Data out of RAM
    .RTSEL      (2'b01      ),
    .WTSEL      (2'b01      ),
    .SLP        (1'b0       ),
    .DSLP       (1'b0       ),
    .SD         (1'b0       ),
    .PUDELAY    (           )
  );
  
  TS1N16ADFPCLLLVTA128X64M4SWSHOD_data_array i_data_array2_2 (
    .CLK        (clk        ),
    .A          (DA2_A      ),
    .CEB        (DA2_CEB2   ),  // chip enable, active LOW
    .WEB        (DA2_WEB2   ),  // write:LOW, read:HIGH
    .BWEB       (DA2_BWEB2  ),  // bitwise write enable write:LOW
    .D          (DA2_DI2    ),  // Data into RAM
    .Q          (DA2_DO2    ),  // Data out of RAM
    .RTSEL      (2'b01      ),
    .WTSEL      (2'b01      ),
    .SLP        (1'b0       ),
    .DSLP       (1'b0       ),
    .SD         (1'b0       ),
    .PUDELAY    (           )
  );


endmodule