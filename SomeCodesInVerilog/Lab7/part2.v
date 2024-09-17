

module part2(iResetn,iPlotBox,iBlack,iColour,iLoadX,iXY_Coord,iClock,oX,oY,oColour,oPlot,oDone);
		parameter X_SCREEN_PIXELS = 8'd160;
		parameter Y_SCREEN_PIXELS = 7'd120;
	
		input wire iResetn, iPlotBox, iBlack, iLoadX;
		input wire [2:0] iColour;
		input wire [6:0] iXY_Coord;
		input wire iClock;
		output wire [7:0] oX;         
		output wire [6:0] oY;
	
		output wire [2:0] oColour;     
		output wire oPlot;     
		output wire oDone;       
	
	  
	 
		wire controlBlack, loadXControl, loadYControl, colourControl, controlEnY, qODone;
		
		
		control c (.iClock(iClock), .iResetn(iResetn), .iBlack(iBlack), .iLoadX(iLoadX), .iPlotBox(iPlotBox), .qODone(oDone),
				  .controlBlack(controlBlack), .loadXControl(loadXControl), .loadYControl(loadYControl), .colourControl(colourControl), .controlEnY(controlEnY),
				  .oPlot(oPlot),  .state(state));
				  
		datapath d (.iClock(iClock), .iResetn(iResetn), .iXY_Coord(iXY_Coord), .iLoadX(loadXControl), .iColour(iColour), .iPlotBox(loadYControl), 
						.colourControl(iPlotBox), .controlEnY(controlEnY), .controlBlack(controlBlack),
						.oX(oX), .oY(oY), .oColour(oColour), .oDone(oDone));

endmodule

module datapath(input iClock, input iResetn, input [6:0] iXY_Coord, input iLoadX, input [2:0] iColour, input iPlotBox, 
					 input colourControl, input controlEnY, input controlBlack,
					 output [7:0] oX, output[6:0] oY, output [2:0] oColour, output oDone);
					 
		wire [7:0] qX;
		wire [6:0] qY;
		wire [6:0] yCount;
		wire [7:0] xCount;
		
		
		registerX rX (.iXY_Coord(iXY_Coord[6:0]), .iLoadX(iLoadX), .iClock(iClock), .iResetn(iResetn), .iBlack(controlBlack), .qX(qX));
		registerY rY (.iXY_Coord(iXY_Coord[6:0]), .iPlotBox(iPlotBox), .iClock(iClock), .iResetn(iResetn), .iBlack(controlBlack), .qY(qY));
		registerC rC (.iColour(iColour[2:0]), .colourControl(colourControl), .iClock(iClock), .iResetn(iResetn), .iBlack(controlBlack), .qC(oColour));
		
		countUnitX cX (.qX(qX), .yCount(yCount[6:0]), .iResetn(iResetn), .iClock(iClock), .controlBlack(controlBlack), .oX(oX), .xCount(xCount[7:0]), .oDone(oDone));
		countUnitY cY (.qY(qY), .controlEn(controlEnY), .iResetn(iResetn), .iClock(iClock), .controlBlack(controlBlack), .oY(oY), .yCount(yCount[6:0]));
					 
endmodule


module registerX(input [6:0] iXY_Coord, input iLoadX, input iClock, input iResetn, input iBlack, output reg [7:0] qX);

		always@(posedge iClock) begin
			if(!iResetn) qX <= 8'b0;
			else if(iBlack) qX <= 8'b0;
			else if(iLoadX) qX <= {1'b0,iXY_Coord};
		end

endmodule

module registerY(input [6:0]iXY_Coord, input iPlotBox, input iClock, input iResetn, input iBlack, output reg [6:0] qY);

		always@(posedge iClock) begin
			if(!iResetn) qY <= 7'b0;
			else if(iBlack) qY <= 7'b0;
			else if(iPlotBox) qY <= iXY_Coord;
		end

endmodule

module registerC(input [2:0] iColour, input colourControl, input iClock, input iResetn, input iBlack, output reg [2:0] qC);

		always@(posedge iClock) begin
			if(!iResetn) qC <= 3'b0;
			else if(iBlack) qC <= 3'b0;
			else if(colourControl) qC <= iColour;
		end

endmodule

module countUnitX(input [7:0] qX, input [6:0] yCount, input controlBlack, input iResetn, input iClock, output [7:0] oX, output [7:0] xCount, output reg oDone);
		
			reg [7:0] countResult;
			always@(posedge iClock) begin
				if(!iResetn || ((countResult == (controlBlack ? 8'b11111111 : 8'b00000011) && yCount == (controlBlack ? 7'b1111111 : 7'b0000011)))) begin
					countResult <= 0;
					oDone = iResetn ? 1 : 0;
				end
				else if(yCount == (controlBlack ? 7'b1111111 : 7'b0000011)) countResult <= countResult+1;
			end
			assign xCount = iResetn ? countResult : 0;
			assign oX = controlBlack ? countResult : (qX + countResult);
			
endmodule

module countUnitY(input [6:0] qY, input controlEn, input iResetn, input iClock, input controlBlack, output [6:0] oY, output [6:0] yCount);
		
		reg [6:0] countResult;
		always@(posedge iClock) begin
			if(!iResetn || countResult == (controlBlack ? 7'b1111111 : 7'b0000011)) countResult <= 0; 
			else if(controlEn) countResult <= countResult+1;
		end
		assign yCount = iResetn ? countResult : 0;
		assign oY = controlBlack ? countResult : (qY + countResult +1);
endmodule



module control(input iResetn, input iClock, input iBlack, input iLoadX, input iPlotBox, input qODone,
					output reg controlBlack, output reg loadXControl, output reg loadYControl, output reg colourControl, output reg controlEnY,
					output reg oPlot, output reg [5:0]state);
					
		reg [5:0] currentState, nextState;
		
		
		localparam SET_BLACK = 5'd0,
					  SET_BLACK_WAIT = 5'd1,
					  LOAD_X = 5'd2,
					  LOAD_X_WAIT = 5'd3,
					  LOAD_Y = 5'd4,
					  LOAD_Y_WAIT = 5'd5,
					  LOAD_C = 5'd6,
					  DRAW_WAIT = 5'd7;
					  
					  
		always@(*) begin
			if(controlBlack) nextState = LOAD_C;
			else begin
			case(currentState) 
				SET_BLACK: nextState = iBlack ? SET_BLACK_WAIT : LOAD_X;
				SET_BLACK_WAIT: nextState = iBlack ? SET_BLACK_WAIT : LOAD_X;
				LOAD_X: nextState = iLoadX ? LOAD_X_WAIT : LOAD_X;
				LOAD_X_WAIT: nextState = iLoadX ? LOAD_X_WAIT : LOAD_Y;
				LOAD_Y: nextState = iPlotBox ? LOAD_Y_WAIT : LOAD_Y;
				LOAD_Y_WAIT: nextState = iPlotBox ? LOAD_Y_WAIT : LOAD_C;
				LOAD_C: nextState = DRAW_WAIT;
				DRAW_WAIT: nextState = qODone ? SET_BLACK : DRAW_WAIT;	
				default: nextState = SET_BLACK;
			endcase
			end
		end
		
		
		
		always@(*) begin
			case(currentState)
				SET_BLACK: begin
					controlBlack = 0;
					
				end
				SET_BLACK_WAIT: begin
					controlBlack = 1;
				end
				LOAD_X: begin
					loadXControl = 0;
				end
				LOAD_X_WAIT: begin
					loadXControl = 1;
				end
				LOAD_Y: begin
					loadXControl = 0;
					loadYControl = 0;
				end
				LOAD_Y_WAIT: begin
					loadYControl = 1;
					colourControl = 1;
				end
				LOAD_C: begin
					loadYControl = 0;
					colourControl = 0;
				end
				DRAW_WAIT: begin
					oPlot = 1;
					controlEnY = !qODone;
				end
			endcase
		end
		
		
		
		
		
		always@(posedge iClock) begin
			if(!iResetn) begin
				currentState <= SET_BLACK;
				state <= SET_BLACK;
			end
			else  begin
				currentState <= nextState;
				state <= nextState;
			end
		end

	
endmodule

