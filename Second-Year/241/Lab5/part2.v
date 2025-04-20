
module RateDivider
#(parameter CLOCK_FREQUENCY = 50000000) (
input ClockIn,
input Reset,
input [1:0] Speed,
output Enable
);

reg [$clog2(4 * CLOCK_FREQUENCY) - 1 : 0] RateDividerCount;

wire pulse;

always @(posedge ClockIn or posedge Reset) 
begin
    if (Reset) 
    begin
        RateDividerCount <= 16'b0;
    end 

    else if (pulse) 
    begin
		  case (Speed)
		      2'b00: RateDividerCount <= 0;
				2'b01: RateDividerCount <= CLOCK_FREQUENCY-1;
				2'b10: RateDividerCount <= 2*CLOCK_FREQUENCY-1;
				2'b11: RateDividerCount <= 4*CLOCK_FREQUENCY-1;   // 4 sec 
				default: RateDividerCount <= 0;
		  endcase
	 end
	 else
        RateDividerCount <= RateDividerCount - 1;
	 

end

assign pulse = (RateDividerCount == 16'b0) ? 1'b1 : 1'b0;

assign Enable = pulse;

endmodule


module DisplayCounter (
input Clock,
input Reset,
input EnableDC,
output reg [3:0] CounterValue
);

always @(posedge Clock or posedge Reset) 
begin
    if (Reset) 
    begin
        CounterValue <= 4'b0;
    end 

    else if (EnableDC) 
    begin
        CounterValue <= CounterValue + 1;
    end
end

endmodule

module part2 #(parameter CLOCK_FREQUENCY = 50000000)(
    input ClockIn,
    input Reset,
    input [1:0] Speed,
    output [3:0] CounterValue
);

// Instantiating the RateDivider module
RateDivider #(.CLOCK_FREQUENCY(CLOCK_FREQUENCY)) RDInst (
    .ClockIn(ClockIn),
    .Reset(Reset),
    .Speed(Speed),
    .Enable(EnableDC)
);

// Instantiating the DisplayCounter module
DisplayCounter DCInst (
    .Clock(ClockIn),
    .Reset(Reset),
    .EnableDC(EnableDC),
    .CounterValue(CounterValue)
);

//reg [3:0] CounterValue;


endmodule

module hex_decoder(c, display);

	input [3:0] c;
	output[6:0] display;
	
	assign display[0] = (~c[3] & ~c[2] & ~c[1] & c[0]) | (~c[3] & c[2] & ~c[1] & ~c[0]) | (c[3] & ~c[2] & c[1] & c[0]) | (c[3] & c[2] & ~c[1] & c[0]); // 0001, 0100, 1011, 1101
	
	assign display[1] = (~c[3] & c[2] & ~c[1] & c[0]) | (~c[3] & c[2] & c[1] & ~c[0]) | (c[3] & ~c[2] & c[1] & c[0]) | (c[3] & c[2] & ~c[1] & ~c[0]) | 
								(c[3] & c[2] & c[1] & ~c[0]) | (c[3] & c[2] & c[1] & c[0]); // 0101, 0110, 1011, 1100, 1110, 1111
	
	assign display[2] = (~c[3] & ~c[2] & c[1] & ~c[0]) | (c[3] & c[2] & ~c[1] & ~c[0]) | (c[3] & c[2] & c[1] & ~c[0]) | (c[3] & c[2] & c[1] & c[0]); // 0010, 1100, 1110, 1111
	
	assign display[3] = (~c[3] & ~c[2] & ~c[1] & c[0]) | (~c[3] & c[2] & ~c[1] & ~c[0]) | (~c[3] & c[2] & c[1] & c[0]) | (c[3] & ~c[2] & ~c[1] & c[0]) | 
								(c[3] & ~c[2] & c[1] & ~c[0]) | (c[3] & c[2] & c[1] & c[0]); // 0001, 0100, 0111, 1001, 1010, 1111
	
	assign display[4] = (~c[3] & ~c[2] & ~c[1] & c[0]) | (~c[3] & ~c[2] & c[1] & c[0]) | (~c[3] & c[2] & ~c[1] & ~c[0]) | (~c[3] & c[2] & ~c[1] & c[0]) | 
								(~c[3] & c[2] & c[1] & c[0]) | (c[3] & ~c[2] & ~c[1] & c[0]); // 0001, 0011, 0100, 0101, 0111, 1001
	
	assign display[5] = (~c[3] & ~c[2] & ~c[1] & c[0]) | (~c[3] & ~c[2] & c[1] & ~c[0]) | (~c[3] & ~c[2] & c[1] & c[0]) | (~c[3] & c[2] & c[1] & c[0]) | 
								(c[3] & c[2] & ~c[1] & ~c[0]) | (c[3] & c[2] & ~c[1] & c[0]); // 0001, 0010, 0011, 0111, 1100, 1101
	
	assign display[6] = (~c[3] & ~c[2] & ~c[1] & ~c[0]) | (~c[3] & ~c[2] & ~c[1] & c[0]) | (~c[3] & c[2] & c[1] & c[0]) | (c[3] & c[2] & ~c[1] & ~c[0]); // 0000, 0001, 0111, 1100
	
endmodule

module toplevel(CLOCK_50, SW, HEX0);
	input [9:0] SW;
	input CLOCK_50;
	output [6:0] HEX0;
	wire [3:0] w1 ;
	


   part2 u6(.ClockIn(CLOCK_50), .Reset(SW[9]), .Speed(SW[1:0]), .CounterValue(w1));
	hex_decoder u7(.c(w1), .display(HEX0[6:0]));
	
endmodule	
