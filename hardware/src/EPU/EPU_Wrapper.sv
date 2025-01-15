module EPU_Wrapper(

	input ACLK,
	input ARESETn,
	
	//WRITE ADDRESS
	input [`AXI_IDS_BITS-1:0] AWID,
	input [`AXI_ADDR_BITS-1:0] AWADDR,
	input [`AXI_LEN_BITS-1:0] AWLEN,
	input [`AXI_SIZE_BITS-1:0] AWSIZE,
	input [1:0] AWBURST,
	input AWVALID,
	output logic AWREADY,
	//WRITE DATA
	input [`AXI_DATA_BITS-1:0] WDATA,
	input [`AXI_STRB_BITS-1:0] WSTRB,
	input WLAST,
	input WVALID,
	output logic WREADY,
	//WRITE RESPONSE
	output logic [`AXI_IDS_BITS-1:0] BID,
	output logic [1:0] BRESP,
	output logic BVALID,
	input BREADY,
	//READ ADDRESS
	input [`AXI_IDS_BITS-1:0] ARID,
	input [`AXI_ADDR_BITS-1:0] ARADDR,
	input [`AXI_LEN_BITS-1:0] ARLEN,
	input [`AXI_SIZE_BITS-1:0] ARSIZE,
	input [1:0] ARBURST,
	input ARVALID,
	output logic ARREADY,
	//READ DATA
	output logic [`AXI_IDS_BITS-1:0] RID,
	output logic [`AXI_DATA_BITS-1:0] RDATA,
	output logic [1:0] RRESP,
	output logic RLAST,
	output logic RVALID,
	input RREADY,
	//layer done
	output	logic	layer_done,
//	output logic layer1_done,
//	output logic layer2_done,
//	output logic layer3_done,
//	output logic layer4_done,
//	output logic layer5_done,
//	output logic layer6_done,
	//interrupt
	output logic epu_interrupt
);
	//////////////layer//////////////
	logic	layer1_done;
	logic	layer2_done;
	logic	layer3_done;
	logic	layer4_done;
	logic	layer5_done;
	logic	layer6_done;
	//////////////reg//////////////
	logic [`AXI_ADDR_BITS-1:0] ARADDR_reg,AWADDR_reg;
	logic [`AXI_IDS_BITS-1:0] ARID_reg,AWID_reg;
	logic [`AXI_LEN_BITS-1:0] ARLEN_reg,AWLEN_reg,ARLEN_counter,WLEN_counter;
	logic [`AXI_DATA_BITS-1:0] WDATA_reg,RDATA_reg;
	logic [`AXI_STRB_BITS-1:0] WSTRB_reg;
	logic ARVALID_reg;
	//////////////SRAM//////////////
	logic EPU_start;
	logic EPU_done;
	logic Image1_CEB,Image0_CEB;
	logic Weight_CEB,Bias_CEB;
	logic WEB;
	logic [31:0]DI;
	logic [31:0]DO;
	logic [13:0]A;
	logic rst;
	//////////////state//////////////
	parameter IDLE = 3'd0,SWAIT = 3'd1,ReadAddress = 3'd2,ReadData = 3'd3,WriteAddress= 3'd4,WriteData = 3'd5,WriteResponse = 3'd6,WriteDataHandShaking = 3'd7;
	logic [2:0]next_state,state;
	parameter intrIDLE = 1'd0,intrDO = 1'd1;
	logic intrstate,next_intrstate;
	
	always_ff @(posedge ACLK or negedge ARESETn)begin
        if (~ARESETn)begin
			intrstate <= intrIDLE;
            state <= IDLE;	
		end
        else begin
			intrstate <= next_intrstate;
            state <= next_state;
		end
    end
	//////////AR//////////
	always_ff @(posedge ACLK or negedge ARESETn)begin
		if (~ARESETn)begin
			ARID_reg <= 8'd0;
			ARADDR_reg <= 32'd0;	
			ARLEN_reg <= 4'd0;
			ARLEN_counter <= 4'd0;			
		end
        else begin
			if (ARREADY && ARVALID)begin
				ARID_reg <= ARID;
				ARADDR_reg <= ARADDR + 32'd4;;
				ARLEN_reg <= ARLEN;
			end
			else if(RREADY && RVALID)begin
				ARID_reg <= ARID_reg;
				ARADDR_reg <= ARADDR_reg + 32'd4;
				ARLEN_reg <= ARLEN_reg;
			end
			else begin
				ARID_reg <= ARID_reg;
				ARADDR_reg <= ARADDR_reg;
				ARLEN_reg <= ARLEN_reg;
			end
			
			if(state != ReadData)begin
				ARLEN_counter <= 4'd0;
			end
			else if(RREADY && RVALID)begin
				ARLEN_counter <= ARLEN_counter + 4'd1;
			end
			else begin
				ARLEN_counter <= ARLEN_counter;
			end
		end
	end
	//////////R//////////
	always_ff @(posedge ACLK or negedge ARESETn) begin
		if (~ARESETn)begin
			RDATA_reg <= 32'b0;			
		end
        else begin
			if(RVALID && RREADY)begin
				RDATA_reg <= DO;
			end
			else begin
				RDATA_reg <= RDATA_reg;
			end
		end
	end
	//////////AW//////////
	always_ff @(posedge ACLK or negedge ARESETn) begin
		if (~ARESETn)begin
			AWID_reg <= 8'd0;
			AWADDR_reg <= 32'b0;
			AWLEN_reg <= 4'd0;	
			
		end
        else begin
			if (AWREADY && AWVALID)begin
				AWID_reg <= AWID;
				AWADDR_reg <= AWADDR;
				AWLEN_reg <= AWLEN;
			end
			else if(WREADY && WVALID)begin
				AWID_reg <= AWID;
				AWADDR_reg <= AWADDR_reg + 32'd4;//////支援burst
				AWLEN_reg <= AWLEN;
			end
			else begin
				AWID_reg <= AWID_reg;
				AWADDR_reg <= AWADDR_reg;
				AWLEN_reg <= AWLEN_reg;
			end
		end
	end
	//////////W//////////
	always_ff @(posedge ACLK or negedge ARESETn) begin
		if (~ARESETn)begin
			WDATA_reg <= 32'b0;	
			WSTRB_reg <= 4'd0;
		end
        else begin
			if(WREADY && WVALID)begin
				WDATA_reg <= WDATA;
				WSTRB_reg <= WSTRB;
			end
			else begin
				WDATA_reg <= WDATA_reg;
				WSTRB_reg <= WSTRB_reg;
			end
		end
	end
	
	
	always_comb begin
		case (state)
			IDLE: begin	
                next_state = SWAIT;
            end
			SWAIT:begin
				if(ARVALID)
                    next_state = ReadAddress;
				else if(AWVALID)
					next_state = WriteAddress;
				else
					next_state = SWAIT;
			end
			ReadAddress:begin
				if(ARVALID && ARREADY)
					next_state = ReadData;
				else
					next_state = ReadAddress;
			end
			ReadData:begin
				if (RVALID && RREADY)begin
					if(ARLEN_reg == ARLEN_counter)begin
						next_state = SWAIT;
					end
					else begin
						next_state = ReadData;
					end
				end
				else begin
					next_state = ReadData;
				end
			end
			WriteAddress:begin	
				next_state = WriteData;
			end
			WriteData:begin
				if (WVALID)
					next_state = WriteDataHandShaking;		
				else 
					next_state = WriteData;
			end
			WriteDataHandShaking:begin
				if(WLAST)
					next_state = WriteResponse;
				else
					next_state = WriteData;
			end
			WriteResponse:begin
				if(BVALID && BREADY)
					next_state = SWAIT;
				else 
					next_state = WriteResponse;
			end
		endcase
	end
	
	always_comb begin
		case(intrstate)
			intrIDLE:begin
				if(EPU_start)
					next_intrstate = intrDO;
				else
					next_intrstate = intrIDLE;
			end
			intrDO:begin
				if(EPU_done)
					next_intrstate = intrIDLE;
				else
					next_intrstate = intrDO;
			end
		endcase
	end
	
	
	always_ff @(posedge ACLK or negedge ARESETn) begin
		if(~ARESETn)
			EPU_start <= 1'b0;
		else if(WVALID && WREADY && AWADDR_reg[18:16] == 3'b110)
			EPU_start <= WDATA[0];
		else if(EPU_done)
			EPU_start <= 1'b0;
		else
			EPU_start <= EPU_start;
	end
	
	
	
	////////AXI////////
	assign ARREADY = (state == ReadAddress) ? 1'b1 : 1'b0;
	assign AWREADY = (state == WriteAddress) ? 1'b1 : 1'b0;
	assign RVALID = (state == ReadData)? 1'b1 : 1'b0;
	assign RID = (state == ReadData) ? ARID_reg : 8'd0;
	assign RDATA = (RVALID && RREADY)? DO : RDATA_reg;
	assign RRESP = 2'b00;
	assign RLAST = (RVALID && (ARLEN_counter == ARLEN_reg))? 1'b1 : 1'b0;
	assign WREADY = (state == WriteDataHandShaking) ? 1'b1 : 1'b0;
	assign BRESP = 2'b00;
	assign BID = (state == WriteResponse) ? AWID_reg : 8'd0;
	assign BVALID = (state == WriteResponse) ? 1'b1 : 1'b0;
	
	////////SRAM////////
	assign Image0_CEB = ((state == ReadAddress && ARADDR_reg [18:16] == 3'b011) || (state == ReadData && ARLEN_reg != ARLEN_counter) || (WREADY && WVALID && AWADDR_reg [18:16] == 3'b011))?1'd0:1'd1;
	assign Weight_CEB = ((state == ReadAddress && ARADDR_reg [18:16] == 3'b100) || (state == ReadData && ARLEN_reg != ARLEN_counter) || (WREADY && WVALID && AWADDR_reg [18:16] == 3'b100))?1'd0:1'd1;
	assign Image1_CEB = ((state == ReadAddress /*&& ARADDR_reg [18:16] == 3'b101*/) || (state == ReadData /*&& ARLEN_reg != ARLEN_counter*/) || (WREADY && WVALID && AWADDR_reg [18:16] == 3'b101))?1'd0:1'd1;
	assign WEB = (WREADY && WVALID)? 1'd0 : 1'd1;
	assign DI = (WREADY && WVALID)? WDATA : WDATA_reg;
	assign A = (ARREADY && ARVALID)? ARADDR[15:2] : (state == ReadData) ? ARADDR_reg[15:2] : AWADDR_reg[15:2];
	
	////////Interrupt////////
	assign	layer_done	= layer1_done || layer2_done || layer3_done || layer4_done || layer5_done || layer6_done;
	assign epu_interrupt = (intrstate == intrDO && next_intrstate == intrIDLE)? 1'b1 : 1'b0;
	
	assign rst = !ARESETn;
	
	EPU epu(
	.clk				(ACLK		),
	.rst				(rst		),
	.EPU_start			(EPU_start	),
	.System_Image0_CEB	(Image0_CEB	),
	.System_Weight_CEB	(Weight_CEB	),
	.System_Image1_CEB	(Image1_CEB	),
	.System_WEB			(WEB		),
	.System_DI			(DI			),
	.System_A			(A			),
	.System_DO			(DO			),
	.layer1_done		(layer1_done),
	.layer2_done		(layer2_done),
	.layer3_done		(layer3_done),
	.layer4_done		(layer4_done),
	.layer5_done		(layer5_done),
	.layer6_done		(layer6_done),
	.EPU_done			(EPU_done	)
);
	

endmodule