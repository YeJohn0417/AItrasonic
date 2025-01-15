module EPU(
  input clk,rst,
  input EPU_start,
  input System_Image0_CEB,
  input System_Weight_CEB,
  input System_Image1_CEB,
  input System_WEB,
  input [31:0]System_DI,
  input [13:0]System_A,
  output logic [31:0]System_DO,
  output logic layer1_done,
  output logic layer2_done,
  output logic layer3_done,
  output logic layer4_done,
  output logic layer5_done,
  output logic layer6_done,
  output logic EPU_done
);
  logic [13:0]Image_SRAM_A;
  logic Image_SRAM_CEB,Image_SRAM_WEB;
  logic [31:0]Image_SRAM_DI;
  
  //////control outputs
  logic     control_o_read_25_image;
  logic     control_o_read_16_image;
  logic     control_o_read_8_image;
  logic     control_o_read_5_image;
  logic     control_o_read_weight;
  logic     control_o_load;
  logic   control_o_cal_done;
  logic   control_o_image_new;
  logic [4:0] control_o_conv1_ifchannel;
  logic [4:0] control_o_conv1_ofchannel;
  logic     control_o_cal_start;
  logic     control_o_row_start;
  logic [2:0] control_o_layer;
  logic 	control_o_gap_cal;
  /////PE outputs
  logic [23:0] PE_result;

  /////psum buffer outputs
  logic     psum_buffer_output_valid;
  logic [7:0] psum_buffer_data_out;
  /////GAP unit outputs
  logic       gap_unit_output_valid;
  logic [7:0] gap_unit_data_out;
  /////Image_SRAM_ctlr outputs
  logic       image_ctlr_o_read_25_done;
  logic       image_ctlr_o_read_5_done;
  logic       image_ctlr_o_read_16_done;
  logic       image_ctlr_o_read_8_done;
  logic       image_ctlr_o_conv_2row_done;
  logic       image_ctlr_o_gap_done;
  logic       image_ctlr_o_image_new_25;
  logic       image_ctlr_o_image_new_5;
  logic       image_ctlr_o_image_new_16;
  logic       image_ctlr_o_image_new_8;
  logic [7:0] image_ctlr_o_image;
  /////image_buffer outputs
  logic [7:0] image_RC[0:24];
  /////Weight_SRAM_ctlr outputs
  logic       weight_ctlr_o_weight_new;
  logic       weight_ctlr_o_weight_new_16;
  logic       weight_ctlr_o_weight_new_8;
  logic [7:0] weight_ctlr_o_weight;
  logic       weight_ctlr_o_bias_new;
  logic [7:0] weight_ctlr_o_bias;
  /////weight_buffer outputs
  logic [7:0] weight_RC[0:24];
  logic [7:0] weight_buf_bias;

EPU_Control epu_control(
  .clk                (clk                        ),
  .rst                (rst                        ),
  .i_EPU_start        (EPU_start                  ),
  .i_read_5_done      (image_ctlr_o_read_5_done   ),
  .i_read_8_done	  (image_ctlr_o_read_8_done	  ),
  .i_read_16_done     (image_ctlr_o_read_16_done  ),
  .i_read_25_done     (image_ctlr_o_read_25_done  ),
  .i_weight_done      (control_o_read_done        ),
  .i_2_row_done       (image_ctlr_o_conv_2row_done),
  .i_gap_saved        (image_ctlr_o_gap_saved     ),
  .o_cal_start        (control_o_cal_start        ),
  .o_load             (control_o_load             ),
  .o_read_5_image     (control_o_read_5_image     ),
  .o_read_8_image     (control_o_read_8_image     ),
  .o_read_16_image    (control_o_read_16_image    ),
  .o_read_25_image    (control_o_read_25_image    ),
  .o_read_weight      (control_o_read_weight      ),
  .o_image_new        (control_o_image_new        ),
  .o_conv1_ifchannel  (control_o_conv1_ifchannel  ),
  .o_conv1_ofchannel  (control_o_conv1_ofchannel  ),
  .o_cal_done         (control_o_cal_done         ),
  .o_row_start        (control_o_row_start        ),
  .o_gap_cal		  (control_o_gap_cal		  ),
  .o_layer            (control_o_layer            ),
  .o_layer1_done      (layer1_done                ),
  .o_layer2_done      (layer2_done                ),
  .o_layer3_done      (layer3_done                ),
  .o_layer4_done      (layer4_done                ),
  .o_layer5_done      (layer5_done                ),
  .o_layer6_done      (layer6_done                ),
  .o_EPU_done         (EPU_done                   )
);
Image_SRAM_ctlr image_SRAM_ctlr(
  .clk                (clk                        ),
  .rst                (rst                        ),
  .i_read_25          (control_o_read_25_image    ),
  .i_read_5           (control_o_read_5_image     ),
  .i_read_16          (control_o_read_16_image    ),
  .i_read_8           (control_o_read_8_image     ),
  .i_image_new        (control_o_image_new        ),
  .i_layer            (control_o_layer            ),
  .i_if_channel       (control_o_conv1_ifchannel  ),
  .i_layer1_done      (layer1_done                ),
  .i_layer2_done      (layer2_done                ),
  .i_layer3_done      (layer3_done                ),
  .i_layer4_done      (layer4_done                ),
  .i_layer5_done      (layer5_done                ),
  .i_layer6_done      (layer6_done                ),
  .i_system_load      (control_o_load             ),
  .i_system_CEB0      (System_Image0_CEB          ),
  .i_system_CEB1      (System_Image1_CEB          ),
  .i_system_WEB       (System_WEB                 ),
  .i_system_DI        (System_DI                  ),
  .i_system_A         (System_A                   ),
  .i_psum_new         (psum_buffer_output_valid   ),
  .i_psum             (psum_buffer_data_out       ),
  .i_gap_new          (gap_unit_output_valid      ),
  .i_gap              (gap_unit_data_out          ),
  .o_read_25_done     (image_ctlr_o_read_25_done  ),
  .o_read_5_done      (image_ctlr_o_read_5_done   ),
  .o_read_16_done     (image_ctlr_o_read_16_done  ),
  .o_read_8_done      (image_ctlr_o_read_8_done   ),
  .o_conv_2row_done   (image_ctlr_o_conv_2row_done),
  .o_gap_saved        (image_ctlr_o_gap_saved     ),
  .o_fc_saved         (image_ctlr_o_fc_saved      ),
  .o_SRAM_DO          (System_DO                  ),
  .o_image_new_25     (image_ctlr_o_image_new_25  ),
  .o_image_new_5      (image_ctlr_o_image_new_5   ),
  .o_image_new_16     (image_ctlr_o_image_new_16  ),
  .o_image_new_8      (image_ctlr_o_image_new_8   ),
  .o_image            (image_ctlr_o_image         )
);
Weight_SRAM_ctlr weight_SRAM_ctlr(
  .clk                (clk                        ),
  .rst                (rst                        ),
  .i_read             (control_o_read_weight      ),
  .i_layer            (control_o_layer            ),
  .i_if_channel       (control_o_conv1_ifchannel  ),
  .i_of_channel       (control_o_conv1_ofchannel  ),
  .i_system_load      (control_o_load             ),
  .i_system_CEB       (System_Weight_CEB          ),
  .i_system_WEB       (System_WEB                 ),
  .i_system_DI        (System_DI                  ),
  .i_system_A         (System_A                   ),
  .o_read_done        (control_o_read_done        ),
  .o_weight_new       (weight_ctlr_o_weight_new   ),
  .o_weight_new_16    (weight_ctlr_o_weight_new_16),
  .o_weight_new_8     (weight_ctlr_o_weight_new_8 ),
  .o_weight           (weight_ctlr_o_weight       ),
  .o_bias_new         (weight_ctlr_o_bias_new     ),
  .o_bias             (weight_ctlr_o_bias         )
);
Image_buf image_buf(
  .clk                (clk                        ),
  .rst                (rst                        ),
  .i_image_new_25     (image_ctlr_o_image_new_25  ),
  .i_image_new_5      (image_ctlr_o_image_new_5   ),
  .i_image_new_16     (image_ctlr_o_image_new_16  ),
  .i_image_new_8      (image_ctlr_o_image_new_8   ),
  .i_conv_done        (control_o_cal_done         ),
  .i_image            (image_ctlr_o_image         ),
  .o_RC00             (image_RC[0]                ), 
  .o_RC01             (image_RC[1]                ), 
  .o_RC02             (image_RC[2]                ), 
  .o_RC03             (image_RC[3]                ), 
  .o_RC04             (image_RC[4]                ),
  .o_RC10             (image_RC[5]                ), 
  .o_RC11             (image_RC[6]                ), 
  .o_RC12             (image_RC[7]                ), 
  .o_RC13             (image_RC[8]                ), 
  .o_RC14             (image_RC[9]                ),
  .o_RC20             (image_RC[10]               ), 
  .o_RC21             (image_RC[11]               ), 
  .o_RC22             (image_RC[12]               ), 
  .o_RC23             (image_RC[13]               ), 
  .o_RC24             (image_RC[14]               ),
  .o_RC30             (image_RC[15]               ), 
  .o_RC31             (image_RC[16]               ), 
  .o_RC32             (image_RC[17]               ), 
  .o_RC33             (image_RC[18]               ), 
  .o_RC34             (image_RC[19]               ),
  .o_RC40             (image_RC[20]               ), 
  .o_RC41             (image_RC[21]               ),
  .o_RC42             (image_RC[22]               ), 
  .o_RC43             (image_RC[23]               ), 
  .o_RC44             (image_RC[24]               )
);
Weight_buf weight_buf(
  .clk                (clk                        ),
  .rst                (rst                        ),
  .i_weight_new       (weight_ctlr_o_weight_new   ),
  .i_weight_new_16    (weight_ctlr_o_weight_new_16),
  .i_weight_new_8     (weight_ctlr_o_weight_new_8 ),
  .i_weight           (weight_ctlr_o_weight       ),
  .i_bias_new         (weight_ctlr_o_bias_new     ),
  .i_bias             (weight_ctlr_o_bias         ),
  .o_RC00             (weight_RC[0]               ), 
  .o_RC01             (weight_RC[1]               ), 
  .o_RC02             (weight_RC[2]               ), 
  .o_RC03             (weight_RC[3]               ), 
  .o_RC04             (weight_RC[4]               ),
  .o_RC10             (weight_RC[5]               ), 
  .o_RC11             (weight_RC[6]               ), 
  .o_RC12             (weight_RC[7]               ), 
  .o_RC13             (weight_RC[8]               ), 
  .o_RC14             (weight_RC[9]               ),
  .o_RC20             (weight_RC[10]              ), 
  .o_RC21             (weight_RC[11]              ), 
  .o_RC22             (weight_RC[12]              ), 
  .o_RC23             (weight_RC[13]              ), 
  .o_RC24             (weight_RC[14]              ),
  .o_RC30             (weight_RC[15]              ), 
  .o_RC31             (weight_RC[16]              ), 
  .o_RC32             (weight_RC[17]              ), 
  .o_RC33             (weight_RC[18]              ), 
  .o_RC34             (weight_RC[19]              ),
  .o_RC40             (weight_RC[20]              ), 
  .o_RC41             (weight_RC[21]              ), 
  .o_RC42             (weight_RC[22]              ), 
  .o_RC43             (weight_RC[23]              ), 
  .o_RC44             (weight_RC[24]              ),
  .o_BIAS             (weight_buf_bias            )
);

PE_unit pe_unit(
  .clk                (clk                        ),
  .rst                (rst                        ),
  .Conv_en            (control_o_cal_start        ),
  .image1             (image_RC[0]                ),
  .image2             (image_RC[1]                ),
  .image3             (image_RC[2]                ),
  .image4             (image_RC[3]                ),
  .image5             (image_RC[4]                ),
  .image6             (image_RC[5]                ),
  .image7             (image_RC[6]                ),
  .image8             (image_RC[7]                ),
  .image9             (image_RC[8]                ),
  .image10            (image_RC[9]                ),
  .image11            (image_RC[10]               ),
  .image12            (image_RC[11]               ),
  .image13            (image_RC[12]               ),
  .image14            (image_RC[13]               ),
  .image15            (image_RC[14]               ),
  .image16            (image_RC[15]               ),
  .image17            (image_RC[16]               ),
  .image18            (image_RC[17]               ),
  .image19            (image_RC[18]               ),
  .image20            (image_RC[19]               ),
  .image21            (image_RC[20]               ),
  .image22            (image_RC[21]               ),
  .image23            (image_RC[22]               ),
  .image24            (image_RC[23]               ),
  .image25            (image_RC[24]               ),
  .weight1            (weight_RC[0]               ),
  .weight2            (weight_RC[1]               ),
  .weight3            (weight_RC[2]               ),
  .weight4            (weight_RC[3]               ),
  .weight5            (weight_RC[4]               ),
  .weight6            (weight_RC[5]               ),
  .weight7            (weight_RC[6]               ),
  .weight8            (weight_RC[7]               ),
  .weight9            (weight_RC[8]               ),
  .weight10           (weight_RC[9]               ),
  .weight11           (weight_RC[10]         	    ),
  .weight12           (weight_RC[11]         	    ),
  .weight13           (weight_RC[12]         	    ),
  .weight14           (weight_RC[13]         	    ),
  .weight15           (weight_RC[14]         	    ),
  .weight16           (weight_RC[15]         	    ),
  .weight17           (weight_RC[16]         	    ),
  .weight18           (weight_RC[17]         	    ),
  .weight19           (weight_RC[18]         	    ),
  .weight20           (weight_RC[19]         	    ),
  .weight21           (weight_RC[20]         	    ),
  .weight22           (weight_RC[21]         	    ),
  .weight23           (weight_RC[22]         	    ),
  .weight24           (weight_RC[23]         	    ),
  .weight25           (weight_RC[24]         	    ),
  .bias               (weight_buf_bias       	    ),
  .result             (PE_result             	    )
);

psum_buffer psum_buf(
  .clk              (clk                        ),
  .rst              (rst                        ),      
  .start            (control_o_row_start        ),
  .layer            (control_o_layer            ),
  .data_valid       (control_o_cal_done         ),
  .data_in          (PE_result                  ),

  //.data_last    (),
  .output_valid     (psum_buffer_output_valid   ),
  .data_out         (psum_buffer_data_out       )
);

GAP_unit gap_unit(
    .clk            (clk                        ),
    .rst            (rst                        ),
    .start          (control_o_read_16_image   	),
    .data_valid     (control_o_gap_cal	        ),
    .data_in_00     (image_RC[ 0]               ),
    .data_in_10     (image_RC[ 5]               ),
    .data_in_20     (image_RC[10]               ),
    .data_in_30     (image_RC[15]               ),
    .data_in_01     (image_RC[ 1]               ),
    .data_in_11     (image_RC[ 6]               ),
    .data_in_21     (image_RC[11]               ),
    .data_in_31     (image_RC[16]               ),
    .data_in_02     (image_RC[ 2]               ),
    .data_in_12     (image_RC[ 7]               ),
    .data_in_22     (image_RC[12]               ),
    .data_in_32     (image_RC[17]               ),
    .data_in_03     (image_RC[ 3]               ),
    .data_in_13     (image_RC[ 8]               ),
    .data_in_23     (image_RC[13]               ),
    .data_in_33     (image_RC[18]               ),
    .output_valid   (gap_unit_output_valid      ),
    .data_out       (gap_unit_data_out          )
);

endmodule