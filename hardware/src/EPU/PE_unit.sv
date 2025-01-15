module PE_unit(
	input clk,rst,
	input Conv_en,
	input [7:0]image1,
	input [7:0]image2,
	input [7:0]image3,
	input [7:0]image4,
	input [7:0]image5,
	input [7:0]image6,
	input [7:0]image7,
	input [7:0]image8,
	input [7:0]image9,
	input [7:0]image10,
	input [7:0]image11,
	input [7:0]image12,
	input [7:0]image13,
	input [7:0]image14,
	input [7:0]image15,
	input [7:0]image16,
	input [7:0]image17,
	input [7:0]image18,
	input [7:0]image19,
	input [7:0]image20,
	input [7:0]image21,
	input [7:0]image22,
	input [7:0]image23,
	input [7:0]image24,
	input [7:0]image25,
	input [7:0]weight1,
	input [7:0]weight2,
	input [7:0]weight3,
	input [7:0]weight4,
	input [7:0]weight5,
	input [7:0]weight6,
	input [7:0]weight7,
	input [7:0]weight8,
	input [7:0]weight9,
	input [7:0]weight10,
	input [7:0]weight11,
	input [7:0]weight12,
	input [7:0]weight13,
	input [7:0]weight14,
	input [7:0]weight15,
	input [7:0]weight16,
	input [7:0]weight17,
	input [7:0]weight18,
	input [7:0]weight19,
	input [7:0]weight20,
	input [7:0]weight21,
	input [7:0]weight22,
	input [7:0]weight23,
	input [7:0]weight24,
	input [7:0]weight25,
	input [7:0]bias,
	output logic [23:0]result
);
	logic [23:0]conv[0:24];
	logic [23:0]sum1,sum2,sum3,sum4,sum5;
	logic [23:0]sum11,sum12,sum13;
	logic [23:0]sum;
	logic [23:0]bias_extend;
	
	assign bias_extend = {{16{bias[7]}},bias};
	
	always_ff @(posedge clk or posedge rst) begin
		if(rst)begin
			for(int i=0;i<25;i++)begin
				conv[i] <= 24'd0;
			end
		end
		else if(Conv_en)begin
			conv[0]  <= $signed(image1)  * $signed(weight1);
			conv[1]  <= $signed(image2)  * $signed(weight2);
			conv[2]  <= $signed(image3)  * $signed(weight3);
			conv[3]  <= $signed(image4)  * $signed(weight4);
			conv[4]  <= $signed(image5)  * $signed(weight5);
			conv[5]  <= $signed(image6)  * $signed(weight6);
			conv[6]  <= $signed(image7)  * $signed(weight7);
			conv[7]  <= $signed(image8)  * $signed(weight8);
			conv[8]  <= $signed(image9)  * $signed(weight9);
			conv[9]  <= $signed(image10) * $signed(weight10);
			conv[10] <= $signed(image11) * $signed(weight11);
			conv[11] <= $signed(image12) * $signed(weight12);
			conv[12] <= $signed(image13) * $signed(weight13);
			conv[13] <= $signed(image14) * $signed(weight14);
			conv[14] <= $signed(image15) * $signed(weight15);
			conv[15] <= $signed(image16) * $signed(weight16);
			conv[16] <= $signed(image17) * $signed(weight17);
			conv[17] <= $signed(image18) * $signed(weight18);
			conv[18] <= $signed(image19) * $signed(weight19);
			conv[19] <= $signed(image20) * $signed(weight20);
			conv[20] <= $signed(image21) * $signed(weight21);
			conv[21] <= $signed(image22) * $signed(weight22);
			conv[22] <= $signed(image23) * $signed(weight23);
			conv[23] <= $signed(image24) * $signed(weight24);
			conv[24] <= $signed(image25) * $signed(weight25);
		end
		else begin
			for(int i=0;i<25;i++)begin
				conv[i] <= 24'd0;
			end
		end
	end
	
	//Adder
	always_ff @(posedge clk or posedge rst) begin
		if(rst)begin
			sum1 <= 24'd0;
			sum2 <= 24'd0;
			sum3 <= 24'd0;
			sum4 <= 24'd0;
			sum5 <= 24'd0;
		end
		else if(Conv_en) begin
			sum1 <= conv[0]  + conv[1]  + conv[2]  + conv[3]  + conv[4];
			sum2 <=	conv[5]  + conv[6]  + conv[7]  + conv[8]  + conv[9];
			sum3 <= conv[10] + conv[11] + conv[12] + conv[13] + conv[14];	
			sum4 <= conv[15] + conv[16] + conv[17] + conv[18] + conv[19];
			sum5 <= conv[20] + conv[21] + conv[22] + conv[23] + conv[24];
		end
		else begin
			sum1 <= 24'd0;
			sum2 <= 24'd0;
			sum3 <= 24'd0;
			sum4 <= 24'd0;
			sum5 <= 24'd0;
		end
	end
	
	always_ff @(posedge clk or posedge rst) begin
		if(rst)
			sum <= 24'd0;
		else if(Conv_en)
			sum <= sum1 + sum2 + sum3 + sum4 + sum5 + bias_extend;
		else
			sum <= 24'd0;
	end

	///output
	always_comb begin
		result = sum;
	end

endmodule