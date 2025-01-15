module EPU_Control(
	input clk,rst,
	input i_EPU_start,
	///ybc input
	input i_read_5_done,
	input i_read_8_done,
	input i_read_25_done,
	input i_read_16_done,
	input i_weight_done,
	input i_2_row_done,
	input i_gap_saved,
	///my
	output logic o_cal_start,
	///ybc
	output logic o_load,
	output logic o_read_5_image,
	output logic o_read_8_image,
	output logic o_read_16_image,
	output logic o_read_25_image,
	output logic o_read_weight,
	output logic o_image_new,
	output logic [4:0]o_conv1_ifchannel,
	output logic [4:0]o_conv1_ofchannel,
	//lin
	output logic o_cal_done,///算完一個pixel
	output logic o_row_start,
	output logic o_gap_cal,
	///Conv Control
	output logic [2:0]o_layer,
	
	output logic o_layer1_done,
	output logic o_layer2_done,
	output logic o_layer3_done,
	output logic o_layer4_done,
	output logic o_layer5_done,
	output logic o_layer6_done,
	output logic o_EPU_done
);

/////////////////////state/////////////////////
//layer1
localparam IDLE 							= 6'd0;
localparam conv1_read_input_25 				= 6'd1;
localparam conv1_read_input_5 				= 6'd2;
localparam conv1_read_weight				= 6'd3;
localparam conv1_calculate					= 6'd4;
localparam conv1_1_row_done					= 6'd5;
localparam conv_2_row_done					= 6'd6;
localparam conv1_image_done					= 6'd7;
localparam conv1_save_layer					= 6'd8;
localparam conv1_save_2_row					= 6'd9;
localparam conv1_save_image					= 6'd10;
localparam layer1_done						= 6'd11;
//layer2
localparam conv2_read_input_25				= 6'd12;
localparam conv2_read_input_5 				= 6'd13;
localparam conv2_read_weight				= 6'd14;
localparam conv2_calculate					= 6'd15;
localparam conv2_1_row_done					= 6'd16;
localparam conv2_2_row_done					= 6'd17;
localparam conv2_all_ifchannel_2_row_done	= 6'd18;
localparam conv2_save_data			   		= 6'd19;
localparam conv2_1_ofchannel_2_row_done		= 6'd20;
localparam conv2_all_ofchannel_2_row_done	= 6'd21;
localparam conv2_save_layer			   		= 6'd22;
localparam conv2_choose						= 6'd23;
localparam layer2_done						= 6'd24;
//layer3
localparam conv3_read_input_25				= 6'd25;
localparam conv3_read_input_5 				= 6'd26;
localparam conv3_read_weight				= 6'd27;
localparam conv3_calculate					= 6'd28;
localparam conv3_1_row_done					= 6'd29;
localparam conv3_2_row_done					= 6'd30;
localparam conv3_all_ifchannel_2_row_done	= 6'd31;
localparam conv3_save_data			   		= 6'd32;
localparam conv3_1_ofchannel_2_row_done		= 6'd33;
localparam conv3_all_ofchannel_2_row_done	= 6'd34;
localparam conv3_save_layer			   		= 6'd35;
localparam conv3_choose						= 6'd36;
localparam layer3_done						= 6'd37;
//layer4
localparam conv4_read_input_25				= 6'd38;
localparam conv4_read_input_5 				= 6'd39;
localparam conv4_read_weight				= 6'd40;
localparam conv4_calculate					= 6'd41;
localparam conv4_1_row_done					= 6'd42;
localparam conv4_2_row_done					= 6'd43;
localparam conv4_all_ifchannel_2_row_done	= 6'd44;
localparam conv4_save_data			   		= 6'd45;
localparam conv4_1_ofchannel_2_row_done		= 6'd46;
localparam conv4_all_ofchannel_2_row_done	= 6'd47;
localparam conv4_save_layer			   		= 6'd48;
localparam conv4_choose						= 6'd49;
localparam layer4_done						= 6'd50;
//layer5
localparam gap1_read_input_16				= 6'd51;
localparam gap1_cal							= 6'd52;
localparam gap2_read_input_16				= 6'd53;
localparam gap2_cal							= 6'd54;
localparam layer5_done						= 6'd55;
//layer6
localparam fc1_read_input_8					= 6'd56;
localparam fc1_read_weight					= 6'd57;
localparam fc1_calculate					= 6'd58;
localparam layer6_done						= 6'd59;
//layer7
localparam fc2_read_input_16				= 6'd60;
localparam fc2_read_weight					= 6'd61;
localparam fc2_calculate					= 6'd62;
localparam EPU_done							= 6'd63;

	logic [5:0]state,next_state;
	logic Conv_1_pixel_done;
	logic Conv1_1_row_done;
	logic Conv1_1_image_done;
	logic Conv_2_row_done;
	logic Conv2_1_image_done;
	logic Conv1_all_ofchannel_done;
	logic Conv2_1_row_done;
	logic Conv2_ifchannel_done;
	logic Conv2_all_ofchannel_done;
	logic Conv2_1_ofchannel_done;
	logic Conv3_1_row_done;
	logic Conv3_ifchannel_done;
	logic Conv3_all_ofchannel_done;
	logic Conv3_1_ofchannel_done;
	logic Conv4_1_row_done;
	logic Conv4_ifchannel_done;
	logic Conv4_all_ofchannel_done;
	logic Conv4_1_ofchannel_done;
	logic fc1_all_ofchannel_done;
	logic fc2_all_ofchannel_done;
	/////////////////////counter/////////////////////
	logic [1:0]Conv_pixel_counter;
	logic [6:0]Conv_row_counter;////數到95
	logic Conv_2_row_counter;
	logic [6:0]Conv_column_counter;///數到95
	logic [4:0]Conv_ifchannel_counter;////數到4
	logic [4:0]Conv_ofchannel_counter;////數到4
	
	///////數每次conv需要的時間
	always_ff @(posedge clk or posedge rst)begin
		if (rst)
			Conv_pixel_counter <= 2'd0;
		else begin
			case(state)
				conv1_calculate:	Conv_pixel_counter <= Conv_pixel_counter + 2'd1;
				conv2_calculate:	Conv_pixel_counter <= Conv_pixel_counter + 2'd1;
				conv3_calculate:	Conv_pixel_counter <= Conv_pixel_counter + 2'd1;
				conv4_calculate:	Conv_pixel_counter <= Conv_pixel_counter + 2'd1;
				fc1_calculate:		Conv_pixel_counter <= Conv_pixel_counter + 2'd1;
				fc2_calculate:		Conv_pixel_counter <= Conv_pixel_counter + 2'd1;
				default:			Conv_pixel_counter <= 2'd0;
			endcase
		end
	end
	//////計算目前row
	always_ff @(posedge clk or posedge rst)begin
		if (rst)
			Conv_row_counter <= 7'd0;
		else if(Conv_1_pixel_done && (Conv1_1_row_done || Conv2_1_row_done || Conv3_1_row_done || Conv4_1_row_done))
			Conv_row_counter <= 7'd0;
		else if(Conv_1_pixel_done)//////做完一次Conv後+1
			Conv_row_counter <= Conv_row_counter + 7'd1;
		else
			Conv_row_counter <= Conv_row_counter;
	end
	//////計算目前在row內到第幾個，每兩個為單位
	always_ff @(posedge clk or posedge rst)begin
		if (rst)
			Conv_2_row_counter <= 1'd0;
		else if(state == conv1_save_2_row || state == conv2_2_row_done || state == conv3_2_row_done || state == conv4_2_row_done)
			Conv_2_row_counter <= 1'd0;
		else if(Conv_1_pixel_done && (Conv1_1_row_done || Conv2_1_row_done || Conv3_1_row_done || Conv4_1_row_done))//////做完一row後+1
			Conv_2_row_counter <= Conv_2_row_counter + 1'd1;
		else
			Conv_2_row_counter <= Conv_2_row_counter;
	end
	//////計算目前cloumn
	always_ff @(posedge clk or posedge rst)begin
		if (rst)
			Conv_column_counter <= 7'd0;
		else if(state == layer1_done || state == layer2_done || state == layer3_done || state == layer4_done)
			Conv_column_counter <= 7'd0;
		else if(Conv_1_pixel_done && Conv1_1_image_done)/////layer0
			Conv_column_counter <= 7'd0;
		else if(state == conv2_1_ofchannel_2_row_done)/////layer1
			Conv_column_counter <= 7'd0;
		else if(state == conv3_1_ofchannel_2_row_done)/////layer2
			Conv_column_counter <= 7'd0;
		else if(state == conv4_1_ofchannel_2_row_done)/////layer2
			Conv_column_counter <= 7'd0;
		else if(next_state == conv4_all_ifchannel_2_row_done && state != conv4_all_ifchannel_2_row_done)
			Conv_column_counter <= Conv_column_counter + 7'd1;
		else if(next_state == conv3_all_ifchannel_2_row_done && state != conv3_all_ifchannel_2_row_done)
			Conv_column_counter <= Conv_column_counter + 7'd1;
		else if(next_state == conv2_all_ifchannel_2_row_done && state != conv2_all_ifchannel_2_row_done)
			Conv_column_counter <= Conv_column_counter + 7'd1;
		else if(Conv_1_pixel_done && Conv1_1_row_done)
			Conv_column_counter <= Conv_column_counter + 7'd1;
		else
			Conv_column_counter <= Conv_column_counter;
	end

	///////計算目前ifchannel
	always_ff @(posedge clk or posedge rst)begin
		if (rst)
			Conv_ifchannel_counter <= 5'd0;
		else begin
			case(state)
				conv2_1_ofchannel_2_row_done:			Conv_ifchannel_counter <= 5'd0;
				conv2_all_ifchannel_2_row_done:			Conv_ifchannel_counter <= 5'd0;
				conv2_all_ofchannel_2_row_done:			Conv_ifchannel_counter <= 5'd0;
				conv3_1_ofchannel_2_row_done:			Conv_ifchannel_counter <= 5'd0;
				conv3_all_ifchannel_2_row_done:			Conv_ifchannel_counter <= 5'd0;
				conv3_all_ofchannel_2_row_done:			Conv_ifchannel_counter <= 5'd0;
				conv4_all_ifchannel_2_row_done:			Conv_ifchannel_counter <= 5'd0;
				conv4_1_ofchannel_2_row_done:			Conv_ifchannel_counter <= 5'd0;
				conv4_all_ofchannel_2_row_done:			Conv_ifchannel_counter <= 5'd0;
				conv2_choose:begin
					case(next_state)
						conv2_2_row_done:				Conv_ifchannel_counter <= Conv_ifchannel_counter + 5'd1;
						default:						Conv_ifchannel_counter <= Conv_ifchannel_counter;
					endcase
				end
				conv2_save_data:begin
					case(next_state)
						conv2_all_ifchannel_2_row_done:	Conv_ifchannel_counter <= 5'd0;
						conv2_1_ofchannel_2_row_done:	Conv_ifchannel_counter <= 5'd0;
						default:						Conv_ifchannel_counter <= Conv_ifchannel_counter;
					endcase
				end
				conv3_choose:begin
					case(next_state)
						conv3_2_row_done:				Conv_ifchannel_counter <= Conv_ifchannel_counter + 5'd1;
						default:						Conv_ifchannel_counter <= Conv_ifchannel_counter;
					endcase
				end
				conv3_save_data:begin
					case(next_state)
						conv3_all_ifchannel_2_row_done:	Conv_ifchannel_counter <= 5'd0;
						conv3_1_ofchannel_2_row_done:	Conv_ifchannel_counter <= 5'd0;
						default:						Conv_ifchannel_counter <= Conv_ifchannel_counter;
					endcase
				end
				conv4_choose:begin
					case(next_state)
						conv4_2_row_done:				Conv_ifchannel_counter <= Conv_ifchannel_counter + 5'd1;
						default:						Conv_ifchannel_counter <= Conv_ifchannel_counter;
					endcase
				end
				conv4_save_data:begin
					case(next_state)
						conv4_all_ifchannel_2_row_done:	Conv_ifchannel_counter <= 5'd0;
						conv4_1_ofchannel_2_row_done:	Conv_ifchannel_counter <= 5'd0;
						default:						Conv_ifchannel_counter <= Conv_ifchannel_counter;
					endcase
				end
				default:Conv_ifchannel_counter <= Conv_ifchannel_counter;
			endcase
		end
	end
	///////計算目前ofchannel
	always_ff @(posedge clk or posedge rst)begin
		if (rst)
			Conv_ofchannel_counter <= 5'd0;
		else if(Conv_1_pixel_done && Conv1_1_image_done && o_layer == 3'd0)////layer 1
			Conv_ofchannel_counter <= Conv_ofchannel_counter + 5'd1;
		else begin
			case(state)
				layer1_done:							Conv_ofchannel_counter <= 5'd0;
				layer2_done:							Conv_ofchannel_counter <= 5'd0;
				layer3_done:							Conv_ofchannel_counter <= 5'd0;
				layer4_done:							Conv_ofchannel_counter <= 5'd0;
				layer5_done:							Conv_ofchannel_counter <= 5'd0;
				layer6_done:							Conv_ofchannel_counter <= 5'd0;
				conv2_save_data:begin
					case(next_state)
						conv2_1_ofchannel_2_row_done:	Conv_ofchannel_counter <= Conv_ofchannel_counter + 5'd1;
						default:						Conv_ofchannel_counter <= Conv_ofchannel_counter;
					endcase
				end
				conv3_save_data:begin
					case(next_state)
						conv3_1_ofchannel_2_row_done:	Conv_ofchannel_counter <= Conv_ofchannel_counter + 5'd1;
						default:						Conv_ofchannel_counter <= Conv_ofchannel_counter;
					endcase
				end
				conv4_save_data:begin
					case(next_state)
						conv4_1_ofchannel_2_row_done:	Conv_ofchannel_counter <= Conv_ofchannel_counter + 5'd1;
						default:						Conv_ofchannel_counter <= Conv_ofchannel_counter;
					endcase
				end
				fc1_read_weight:begin
					case(next_state)
						fc1_calculate:					Conv_ofchannel_counter <= Conv_ofchannel_counter + 5'd1;
						default:						Conv_ofchannel_counter <= Conv_ofchannel_counter;
					endcase
				end
				fc2_read_weight:begin
					case(next_state)
						fc2_calculate:					Conv_ofchannel_counter <= Conv_ofchannel_counter + 5'd1;
						default:						Conv_ofchannel_counter <= Conv_ofchannel_counter;
					endcase
				end
				default:Conv_ofchannel_counter <= Conv_ofchannel_counter;
			endcase
		end
	end
	
	///進行完[一個捲積]提醒系統
	assign Conv_1_pixel_done = (Conv_pixel_counter == 2'd2)? 1'b1: 1'b0;
	///進行完[一個row]提醒系統
	assign Conv1_1_row_done = (o_layer == 3'd0 && Conv_row_counter == 7'd95)? 1'b1: 1'b0;
	assign Conv2_1_row_done = (o_layer == 3'd1 && Conv_row_counter == 7'd43)? 1'b1: 1'b0;
	assign Conv3_1_row_done = (o_layer == 3'd2 && Conv_row_counter == 7'd17)? 1'b1: 1'b0;
	assign Conv4_1_row_done = (o_layer == 3'd3 && Conv_row_counter == 7'd3 )? 1'b1: 1'b0;
	///進行到[二個row開始]提醒系統
	assign Conv_2_row_done = (Conv_2_row_counter == 1'd1)? 1'b1: 1'b0;
	///進行完[一個image]提醒系統
	assign Conv1_1_image_done = (Conv_row_counter == 7'd95 && Conv_column_counter == 7'd95)? 1'b1: 1'b0;
	//assign Conv2_1_image_done = (Conv_row_counter == 7'd43 && Conv_column_counter == 7'd43)? 1'b1: 1'b0;
	//assign Conv3_1_image_done = (Conv_row_counter == 7'd17 && Conv_column_counter == 7'd17)? 1'b1: 1'b0;
	///進行完[全部ifchannel]提醒系統
	assign Conv2_ifchannel_done = (o_layer == 3'd1 && Conv_ifchannel_counter == 5'd3 )? 1'b1: 1'b0;
	assign Conv3_ifchannel_done = (o_layer == 3'd2 && Conv_ifchannel_counter == 5'd7 )? 1'b1: 1'b0;
	assign Conv4_ifchannel_done = (o_layer == 3'd3 && Conv_ifchannel_counter == 5'd7 )? 1'b1: 1'b0;
	///進行完[全部ofchannel]提醒系統
	assign Conv1_all_ofchannel_done = (o_layer == 3'd0 && Conv_ofchannel_counter == 5'd3)? 1'b1: 1'b0;
	assign Conv2_1_ofchannel_done 	= (o_layer == 3'd1 && Conv2_ifchannel_done && Conv_column_counter == 7'd21)? 1'b1: 1'b0;
	assign Conv2_all_ofchannel_done = (o_layer == 3'd1 && Conv_ofchannel_counter == 5'd7 && Conv2_1_ofchannel_done && Conv2_ifchannel_done)? 1'b1: 1'b0;
	assign Conv3_1_ofchannel_done	= (o_layer == 3'd2 && Conv3_ifchannel_done && Conv_column_counter == 7'd8)? 1'b1: 1'b0;
	assign Conv3_all_ofchannel_done = (o_layer == 3'd2 && Conv_ofchannel_counter == 5'd7 && Conv3_1_ofchannel_done && Conv3_ifchannel_done)? 1'b1: 1'b0;
	assign Conv4_1_ofchannel_done	= (o_layer == 3'd3 && Conv4_ifchannel_done && Conv_column_counter == 7'd1 )? 1'b1: 1'b0;
	assign Conv4_all_ofchannel_done = (o_layer == 3'd3 && Conv_ofchannel_counter == 5'd7 && Conv4_1_ofchannel_done && Conv4_ifchannel_done)? 1'b1: 1'b0;
	assign fc1_all_ofchannel_done   = (o_layer == 3'd5 && Conv_ofchannel_counter == 5'd16)? 1'b1: 1'b0;
	assign fc2_all_ofchannel_done   = (o_layer == 3'd6 && Conv_ofchannel_counter == 5'd5)? 1'b1: 1'b0;
	
	/////////////////////state/////////////////////
	always_ff @(posedge clk or posedge rst)begin
        if (rst)
            state <= IDLE;	
        else
            state <= next_state;
    end
	
	always_comb begin
		case(state)
			IDLE:begin
				if(i_EPU_start)
					next_state = conv1_read_input_25;
				else
					next_state = IDLE;			
			end
			conv1_read_input_25:begin
				if(i_read_25_done)
					next_state = conv1_read_weight;
				else
					next_state = conv1_read_input_25;
			end
			conv1_read_input_5:begin
				if(i_read_5_done)
					next_state = conv1_calculate;
				else
					next_state = conv1_read_input_5;
			end
			conv1_read_weight:begin
				if(i_weight_done)
					next_state = conv1_calculate;
				else
					next_state = conv1_read_weight;
			end
			conv1_calculate:begin
				if(Conv_1_pixel_done)
					if(Conv1_all_ofchannel_done && Conv1_1_image_done)
						next_state = conv1_save_layer;
					else if(Conv1_1_image_done)
						next_state = conv1_save_image;
					else if(Conv_2_row_done && Conv1_1_row_done)
						next_state = conv1_save_2_row;
					else if(Conv1_1_row_done)
						next_state = conv1_1_row_done;
					else
						next_state = conv1_read_input_5;
				else
					next_state = conv1_calculate;
			end
			conv1_1_row_done:begin
				if(i_read_25_done)
					next_state = conv1_calculate;
				else
					next_state = conv1_1_row_done;
			end
			conv_2_row_done:begin
				if(i_read_25_done)
					next_state = conv1_calculate;
				else
					next_state = conv_2_row_done;
			end
			conv1_image_done:begin
				if(i_read_25_done)
					next_state = conv1_read_weight;
				else
					next_state = conv1_image_done;
			end
			conv1_save_image:begin
				if(i_2_row_done)
					next_state = conv1_image_done;
				else
					next_state = conv1_save_image;
			end
			conv1_save_2_row:begin
				if(i_2_row_done)
					next_state = conv_2_row_done;
				else
					next_state = conv1_save_2_row;
			end
			conv1_save_layer:begin
				if(i_2_row_done)
					next_state = layer1_done;
				else
					next_state = conv1_save_layer;
			end
			layer1_done:begin
				next_state = conv2_read_input_25;
			end
			conv2_read_input_25:begin
				if(i_read_25_done)
					next_state = conv2_read_weight;
				else
					next_state = conv2_read_input_25;
			end
			conv2_read_input_5:begin
				if(i_read_5_done)
					next_state = conv2_calculate;
				else
					next_state = conv2_read_input_5;
			end
			conv2_read_weight:begin
				if(i_weight_done)
					next_state = conv2_calculate;
				else
					next_state = conv2_read_weight;
			end
			conv2_calculate:begin
				if(Conv_1_pixel_done)
					if(Conv_2_row_done && Conv2_1_row_done)
						next_state = conv2_choose;
					else if(Conv2_1_row_done)
						next_state = conv2_1_row_done;
					else
						next_state = conv2_read_input_5;
				else
					next_state = conv2_calculate;
			end
			conv2_choose:begin
				if(Conv2_all_ofchannel_done)
					next_state = conv2_all_ofchannel_2_row_done;
				else if(Conv2_1_ofchannel_done || Conv2_ifchannel_done)
					next_state = conv2_save_data;
				else
					next_state = conv2_2_row_done;
			end
			conv2_1_row_done:begin
				if(i_read_25_done)
					next_state = conv2_calculate;
				else
					next_state = conv2_1_row_done;
			end
			conv2_2_row_done:begin
				if(i_read_25_done)
					next_state = conv2_read_weight;
				else 
					next_state = conv2_2_row_done;
			end
			conv2_all_ifchannel_2_row_done:begin
				if(i_read_25_done)
					next_state = conv2_read_weight;
				else
					next_state = conv2_all_ifchannel_2_row_done;
			end
			conv2_1_ofchannel_2_row_done:begin
				if(i_read_25_done)
					next_state = conv2_read_weight;
				else
					next_state = conv2_1_ofchannel_2_row_done;
			end
			conv2_all_ofchannel_2_row_done:begin
				next_state = conv2_save_layer;
			end
			conv2_save_data:begin
				if(i_2_row_done)begin
					if(Conv2_1_ofchannel_done && Conv2_ifchannel_done)
						next_state = conv2_1_ofchannel_2_row_done;
					else
						next_state = conv2_all_ifchannel_2_row_done;
				end
				else
					next_state = conv2_save_data;
			end
			conv2_save_layer:begin
				if(i_2_row_done)
					next_state = layer2_done;
				else
					next_state = conv2_save_layer;
			end
			layer2_done:begin
				next_state = conv3_read_input_25;
			end
			conv3_read_input_25:begin
				if(i_read_25_done)
					next_state = conv3_read_weight;
				else
					next_state = conv3_read_input_25;
			end
			conv3_read_input_5:begin
				if(i_read_5_done)
					next_state = conv3_calculate;
				else
					next_state = conv3_read_input_5;
			end
			conv3_read_weight:begin
				if(i_weight_done)
					next_state = conv3_calculate;
				else
					next_state = conv3_read_weight;
			end
			conv3_calculate:begin
				if(Conv_1_pixel_done)
					if(Conv_2_row_done && Conv3_1_row_done)
						next_state = conv3_choose;
					else if(Conv3_1_row_done)
						next_state = conv3_1_row_done;
					else
						next_state = conv3_read_input_5;
				else
					next_state = conv3_calculate;
			end
			conv3_choose:begin
				if(Conv3_all_ofchannel_done)
					next_state = conv3_all_ofchannel_2_row_done;
				else if(Conv3_1_ofchannel_done || Conv3_ifchannel_done)
					next_state = conv3_save_data;
				else
					next_state = conv3_2_row_done;
			end
			conv3_1_row_done:begin
				if(i_read_25_done)
					next_state = conv3_calculate;
				else
					next_state = conv3_1_row_done;
			end
			conv3_2_row_done:begin
				if(i_read_25_done)
					next_state = conv3_read_weight;
				else 
					next_state = conv3_2_row_done;
			end
			conv3_all_ifchannel_2_row_done:begin
				if(i_read_25_done)
					next_state = conv3_read_weight;
				else
					next_state = conv3_all_ifchannel_2_row_done;
			end
			conv3_1_ofchannel_2_row_done:begin
				if(i_read_25_done)
					next_state = conv3_read_weight;
				else
					next_state = conv3_1_ofchannel_2_row_done;
			end
			conv3_all_ofchannel_2_row_done:begin
				next_state = conv3_save_layer;
			end
			conv3_save_data:begin
				if(i_2_row_done)begin
					if(Conv3_1_ofchannel_done && Conv3_ifchannel_done)
						next_state = conv3_1_ofchannel_2_row_done;
					else
						next_state = conv3_all_ifchannel_2_row_done;
				end
				else
					next_state = conv3_save_data;
			end
			conv3_save_layer:begin
				if(i_2_row_done)
					next_state = layer3_done;
				else
					next_state = conv3_save_layer;
			end
			layer3_done:begin
				next_state = conv4_read_input_25;
			end
			conv4_read_input_25:begin
				if(i_read_25_done)
					next_state = conv4_read_weight;
				else
					next_state = conv4_read_input_25;
			end
			conv4_read_input_5:begin
				if(i_read_5_done)
					next_state = conv4_calculate;
				else
					next_state = conv4_read_input_5;
			end
			conv4_read_weight:begin
				if(i_weight_done)
					next_state = conv4_calculate;
				else
					next_state = conv4_read_weight;
			end
			conv4_calculate:begin
				if(Conv_1_pixel_done)
					if(Conv_2_row_done && Conv4_1_row_done)
						next_state = conv4_choose;
					else if(Conv4_1_row_done)
						next_state = conv4_1_row_done;
					else
						next_state = conv4_read_input_5;
				else
					next_state = conv4_calculate;
			end
			conv4_choose:begin
				if(Conv4_all_ofchannel_done)
					next_state = conv4_all_ofchannel_2_row_done;
				else if(Conv4_1_ofchannel_done || Conv4_ifchannel_done)
					next_state = conv4_save_data;
				else
					next_state = conv4_2_row_done;
			end
			conv4_1_row_done:begin
				if(i_read_25_done)
					next_state = conv4_calculate;
				else
					next_state = conv4_1_row_done;
			end
			conv4_2_row_done:begin
				if(i_read_25_done)
					next_state = conv4_read_weight;
				else 
					next_state = conv4_2_row_done;
			end
			conv4_all_ifchannel_2_row_done:begin
				if(i_read_25_done)
					next_state = conv4_read_weight;
				else
					next_state = conv4_all_ifchannel_2_row_done;
			end
			conv4_1_ofchannel_2_row_done:begin
				if(i_read_25_done)
					next_state = conv4_read_weight;
				else
					next_state = conv4_1_ofchannel_2_row_done;
			end
			conv4_all_ofchannel_2_row_done:begin
				next_state = conv4_save_layer;
			end
			conv4_save_data:begin
				if(i_2_row_done)begin
					if(Conv4_1_ofchannel_done && Conv4_ifchannel_done)
						next_state = conv4_1_ofchannel_2_row_done;
					else
						next_state = conv4_all_ifchannel_2_row_done;
				end
				else
					next_state = conv4_save_data;
			end
			conv4_save_layer:begin
				if(i_2_row_done)
					next_state = layer4_done;
				else
					next_state = conv4_save_layer;
			end
			layer4_done:begin
				next_state = gap1_read_input_16;
			end
			gap1_read_input_16:begin
				if(i_read_16_done)
					next_state = gap1_cal;
				else
					next_state = gap1_read_input_16;
			end
			gap1_cal:begin
				if(i_gap_saved)
					next_state = gap2_read_input_16;
				else
					next_state = gap1_cal;
			end
			gap2_read_input_16:begin
				if(i_read_16_done)
					next_state = gap2_cal;
				else
					next_state = gap2_read_input_16;
			end
			gap2_cal:begin
				if(i_gap_saved)
					next_state = layer5_done;
				else
					next_state = gap2_cal;
			end
			layer5_done:begin
				next_state = fc1_read_input_8;
			end
			fc1_read_input_8:begin
				if(i_read_8_done)
					next_state = fc1_read_weight;
				else
					next_state = fc1_read_input_8;
			end
			fc1_read_weight:begin
				if(i_weight_done)
					next_state = fc1_calculate;
				else
					next_state = fc1_read_weight;
			end
			fc1_calculate:begin
				if(Conv_1_pixel_done)begin
					if(fc1_all_ofchannel_done)
						next_state = layer6_done;
					else
						next_state = fc1_read_weight;
				end
				else
					next_state = fc1_calculate;
			end
			layer6_done:begin
				next_state = fc2_read_input_16;
			end
			fc2_read_input_16:begin
				if(i_read_16_done)
					next_state = fc2_read_weight;
				else
					next_state = fc2_read_input_16;
			end
			fc2_read_weight:begin
				if(i_weight_done)
					next_state = fc2_calculate;
				else
					next_state = fc2_read_weight;
			end
			fc2_calculate:begin
				if(Conv_1_pixel_done)begin
					if(fc2_all_ofchannel_done)
						next_state = EPU_done;
					else
						next_state = fc2_read_weight;
				end
				else
					next_state = fc2_calculate;
			end
			EPU_done:begin
				next_state = IDLE;
			end
		endcase
	end
	
	assign o_layer = ((6'd0  < state) && (state < 6'd11))? 3'd0 : 
					 ((6'd11 < state) && (state < 6'd25))? 3'd1 :
					 ((6'd24 < state) && (state < 6'd38))? 3'd2 :
					 ((6'd37 < state) && (state < 6'd51))? 3'd3 :
					 ((6'd50 < state) && (state < 6'd56))? 3'd4 :
					 ((6'd55 < state) && (state < 6'd60))? 3'd5 :
					 (6'd59 < state)					 ? 3'd6 : 3'd0;
	assign o_layer1_done = (state == layer1_done)? 1'b1 : 1'b0;
	assign o_layer2_done = (state == layer2_done)? 1'b1 : 1'b0;
	assign o_layer3_done = (state == layer3_done)? 1'b1 : 1'b0;
	assign o_layer4_done = (state == layer4_done)? 1'b1 : 1'b0;
	assign o_layer5_done = (state == layer5_done)? 1'b1 : 1'b0;
	assign o_layer6_done = (state == layer6_done)? 1'b1 : 1'b0;
	assign o_EPU_done	 = (state == EPU_done	)? 1'b1 : 1'b0;
	logic [4:0]image_new_counter;
	
	always_ff @(posedge clk or posedge rst)begin
		if (rst)
			image_new_counter <= 5'd0;
		else begin
			case(state)
				conv1_image_done:				image_new_counter <= image_new_counter + 5'd1;
				conv2_2_row_done:				image_new_counter <= image_new_counter + 5'd1;
				conv3_2_row_done:				image_new_counter <= image_new_counter + 5'd1;
				conv4_2_row_done:				image_new_counter <= image_new_counter + 5'd1;
				conv2_1_ofchannel_2_row_done:	image_new_counter <= image_new_counter + 5'd1;
				conv3_1_ofchannel_2_row_done:	image_new_counter <= image_new_counter + 5'd1;
				conv4_1_ofchannel_2_row_done:	image_new_counter <= image_new_counter + 5'd1;
				default:						image_new_counter <= 5'd0;
			endcase
		end
	end
	
///////ybc
	///layer1
	always_comb begin
		o_conv1_ifchannel = Conv_ifchannel_counter;
		o_conv1_ofchannel = Conv_ofchannel_counter;
		o_load = !i_EPU_start;
/////////o_read_weight
		case(next_state)
			conv1_read_weight:begin
				case(state)
					conv1_read_weight:	o_read_weight = 1'b0;
					default:			o_read_weight = 1'b1;
				endcase
			end
			conv2_read_weight:begin
				case(state)
					conv2_read_weight:	o_read_weight = 1'b0;
					default:			o_read_weight = 1'b1;
				endcase
			end
			conv3_read_weight:begin
				case(state)
					conv3_read_weight:	o_read_weight = 1'b0;
					default:			o_read_weight = 1'b1;
				endcase
			end
			conv4_read_weight:begin
				case(state)
					conv4_read_weight:	o_read_weight = 1'b0;
					default:			o_read_weight = 1'b1;
				endcase
			end
			fc1_read_weight:begin
				case(state)
					fc1_read_weight:	o_read_weight = 1'b0;
					default:			o_read_weight = 1'b1;
				endcase
			end
			fc2_read_weight:begin
				case(state)
					fc2_read_weight:	o_read_weight = 1'b0;
					default:			o_read_weight = 1'b1;
				endcase
			end
			default:					o_read_weight = 1'b0;
		endcase
/////////o_read_25_image
		case(state)
			conv1_read_input_25:			o_read_25_image = 1'b1;
			conv1_1_row_done:				o_read_25_image = 1'b1;
			conv_2_row_done:				o_read_25_image = 1'b1;
			conv1_image_done:				o_read_25_image = 1'b1;
			conv2_read_input_25:			o_read_25_image = 1'b1;
			conv2_1_row_done:				o_read_25_image = 1'b1;
			conv2_2_row_done:				o_read_25_image = 1'b1;
			conv2_all_ifchannel_2_row_done:	o_read_25_image = 1'b1;
			conv2_1_ofchannel_2_row_done:	o_read_25_image = 1'b1;
			conv3_read_input_25:			o_read_25_image = 1'b1;
			conv3_1_row_done:				o_read_25_image = 1'b1;
			conv3_2_row_done:				o_read_25_image = 1'b1;
			conv3_all_ifchannel_2_row_done:	o_read_25_image = 1'b1;
			conv3_1_ofchannel_2_row_done:	o_read_25_image = 1'b1;
			conv4_read_input_25:			o_read_25_image = 1'b1;
			conv4_1_row_done:				o_read_25_image = 1'b1;
			conv4_2_row_done:				o_read_25_image = 1'b1;
			conv4_all_ifchannel_2_row_done:	o_read_25_image = 1'b1;
			conv4_1_ofchannel_2_row_done:	o_read_25_image = 1'b1;
			default:						o_read_25_image = 1'b0;
		endcase
/////////o_read_5_image
		case(state)
			conv1_read_input_5:				o_read_5_image = 1'b1;
			conv2_read_input_5:				o_read_5_image = 1'b1;
			conv3_read_input_5:				o_read_5_image = 1'b1;
			conv4_read_input_5:				o_read_5_image = 1'b1;
			default:						o_read_5_image = 1'b0;
		endcase
/////////////o_read_16_image	
		case(state)
			gap1_read_input_16:				o_read_16_image = 1'b1;
			gap2_read_input_16:				o_read_16_image = 1'b1;
			fc2_read_input_16:				o_read_16_image = 1'b1;
			default:						o_read_16_image = 1'b0;
		endcase
/////////////o_read_8_image
		case(state)
			fc1_read_input_8:				o_read_8_image = 1'b1;
			default:						o_read_8_image = 1'b0;
		endcase
/////////o_image_new
		case(state)
			conv1_image_done:begin
				case(image_new_counter)
					5'd0:					o_image_new = 1'b1;
					default:				o_image_new = 1'b0;
				endcase
			end
			conv2_2_row_done:begin
				case(image_new_counter)
					5'd0:begin
						case(Conv_column_counter)
							7'd0:			o_image_new = 1'b1;
							default:		o_image_new = 1'b0;
						endcase
					end
					default:				o_image_new = 1'b0;
				endcase
			end
			conv2_1_ofchannel_2_row_done:begin
				case(image_new_counter)
					5'd0:					o_image_new = 1'b1;
					default:				o_image_new = 1'b0;
				endcase
			end
			conv3_2_row_done:begin
				case(image_new_counter)
					5'd0:begin
						case(Conv_column_counter)
							7'd0:			o_image_new = 1'b1;
							default:		o_image_new = 1'b0;
						endcase
					end
					default:				o_image_new = 1'b0;
				endcase
			end
			conv3_1_ofchannel_2_row_done:begin
				case(image_new_counter)
					5'd0:					o_image_new = 1'b1;
					default:				o_image_new = 1'b0;
				endcase
			end
			conv4_2_row_done:begin
				case(image_new_counter)
					5'd0:begin
						case(Conv_column_counter)
							7'd0:			o_image_new = 1'b1;
							default:		o_image_new = 1'b0;
						endcase
					end
					default:				o_image_new = 1'b0;
				endcase
			end
			conv2_1_ofchannel_2_row_done:begin
				case(image_new_counter)
					5'd0:					o_image_new = 1'b1;
					default:				o_image_new = 1'b0;
				endcase
			end
			default:						o_image_new = 1'b0;
		endcase
	end
///////lin
	always_comb begin
/////////o_gap_cal
		case(state)
			gap1_cal:						o_gap_cal = 1'b1;
			gap2_cal:						o_gap_cal = 1'b1;
			default:						o_gap_cal = 1'b0;
		endcase
/////////o_cal_done
		case(Conv_pixel_counter)
			2'd3:							o_cal_done = 1'b1;
			default:						o_cal_done = 1'b0;
		endcase
/////////o_row_start
		case(state)
			conv1_read_input_25:			o_row_start = 1'b1;
			conv_2_row_done:				o_row_start = 1'b1;
			conv1_image_done:				o_row_start = 1'b1;
			conv2_read_input_25:			o_row_start = 1'b1;
			conv2_all_ifchannel_2_row_done:	o_row_start = 1'b1;
			conv2_1_ofchannel_2_row_done:	o_row_start = 1'b1;
			conv3_read_input_25:			o_row_start = 1'b1;
			conv3_all_ifchannel_2_row_done:	o_row_start = 1'b1;
			conv3_1_ofchannel_2_row_done:	o_row_start = 1'b1;
			conv4_read_input_25:			o_row_start = 1'b1;
			conv4_all_ifchannel_2_row_done:	o_row_start = 1'b1;
			conv4_1_ofchannel_2_row_done:	o_row_start = 1'b1;
			fc1_read_weight:				o_row_start = 1'b1;
			fc2_read_weight:				o_row_start = 1'b1;
			default:						o_row_start = 1'b0;
		endcase
	end
///////my
	always_comb	begin
		case(state)
			conv1_calculate:				o_cal_start = 1'b1;
			conv2_calculate:				o_cal_start = 1'b1;
			conv3_calculate:				o_cal_start = 1'b1;
			conv4_calculate:				o_cal_start = 1'b1;
			fc1_calculate:					o_cal_start = 1'b1;
			fc2_calculate:					o_cal_start = 1'b1;
			default:						o_cal_start = 1'b0;
		endcase
	end

endmodule