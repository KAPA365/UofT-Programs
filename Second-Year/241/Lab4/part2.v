module part2(Clock, Reset_b, Data, Function, ALUout);
	input Clock, Reset_b;
	input [3:0] Data; // signal A
	input [1:0] Function;
	reg [7:0] Pre_reg_ALUout; // output of ALU
	wire [3:0] Signal_A, Signal_B; 
	output [7:0] ALUout;
	
	assign Signal_A = Data;
	assign Signal_B = ALUout[3:0];
	
	always@ (*)
	begin 
		case ( Function )
			2'b00: Pre_reg_ALUout = Signal_A + Signal_B;
			2'b01: Pre_reg_ALUout = Signal_A * Signal_B;
			2'b10: Pre_reg_ALUout = Signal_B << Signal_A; 
			2'b11: Pre_reg_ALUout = ALUout; // carry last value
			default: Pre_reg_ALUout = 8'b00000000;
		endcase
	end
	
	// register
	D_flip_flop_8b u1(Clock, Reset_b, Pre_reg_ALUout, ALUout);
endmodule

module D_flip_flop_8b (
	input wire clk ,
	input wire reset_b ,
	input wire [7:0] d ,
	output reg [7:0] q) ;
	always@ ( posedge clk )
	begin
		if ( reset_b ) q <= 8'b00000000;
		else q <= d ;
	end
endmodule
