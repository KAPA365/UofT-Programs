module part2(A, B, Function, ALUout);
	input [3:0] A, B;
	input [1:0] Function;
	output reg [7:0] ALUout;
	
	wire [7:0] w; 
	wire [2:0] Temp;
	FA2 u5(A[0], B[0], 0, w[0], Temp[0]);
	FA2 u6(A[1], B[1], Temp[0], w[1], Temp[1]);
	FA2 u7(A[2], B[2], Temp[1], w[2], Temp[2]);
	FA2 u8(A[3], B[3], Temp[2], w[3], w[4]); // carry out as fifth bit
	assign w[7:5] = 3'b000; // default values for first 3 bits
	
	always@(*)
	begin 
		case (Function)
			2'b00: ALUout = w;
			2'b01: ALUout = |{A, B};
			2'b10: ALUout = &{A, B};
			2'b11: ALUout = {A, B};
			default: ALUout = 0;
		endcase
	end
endmodule


module FA2(a, b, ci, s, co);
	input a;
	input b;
	input ci;
	output s;
	output co;
	
	assign s = ci^a^b; // 001, 100, 010, 111
	assign co = (a&b)|(ci&a)|(ci&b); // 101, 011, 110, 111
endmodule

//module hex_decoder(c, display);
//
//	input [3:0] c;
//	output[6:0] display;
//	
//	assign display[0] = (~c[3] & ~c[2] & ~c[1] & c[0]) | (~c[3] & c[2] & ~c[1] & ~c[0]) | (c[3] & ~c[2] & c[1] & c[0]) | (c[3] & c[2] & ~c[1] & c[0]); // 0001, 0100, 1011, 1101
//	
//	assign display[1] = (~c[3] & c[2] & ~c[1] & c[0]) | (~c[3] & c[2] & c[1] & ~c[0]) | (c[3] & ~c[2] & c[1] & c[0]) | (c[3] & c[2] & ~c[1] & ~c[0]) | 
//								(c[3] & c[2] & c[1] & ~c[0]) | (c[3] & c[2] & c[1] & c[0]); // 0101, 0110, 1011, 1100, 1110, 1111
//	
//	assign display[2] = (~c[3] & ~c[2] & c[1] & ~c[0]) | (c[3] & c[2] & ~c[1] & ~c[0]) | (c[3] & c[2] & c[1] & ~c[0]) | (c[3] & c[2] & c[1] & c[0]); // 0010, 1100, 1110, 1111
//	
//	assign display[3] = (~c[3] & ~c[2] & ~c[1] & c[0]) | (~c[3] & c[2] & ~c[1] & ~c[0]) | (~c[3] & c[2] & c[1] & c[0]) | (c[3] & ~c[2] & ~c[1] & c[0]) | 
//								(c[3] & ~c[2] & c[1] & ~c[0]) | (c[3] & c[2] & c[1] & c[0]); // 0001, 0100, 0111, 1001, 1010, 1111
//	
//	assign display[4] = (~c[3] & ~c[2] & ~c[1] & c[0]) | (~c[3] & ~c[2] & c[1] & c[0]) | (~c[3] & c[2] & ~c[1] & ~c[0]) | (~c[3] & c[2] & ~c[1] & c[0]) | 
//								(~c[3] & c[2] & c[1] & c[0]) | (c[3] & ~c[2] & ~c[1] & c[0]); // 0001, 0011, 0100, 0101, 0111, 1001
//	
//	assign display[5] = (~c[3] & ~c[2] & ~c[1] & c[0]) | (~c[3] & ~c[2] & c[1] & ~c[0]) | (~c[3] & ~c[2] & c[1] & c[0]) | (~c[3] & c[2] & c[1] & c[0]) | 
//								(c[3] & c[2] & ~c[1] & ~c[0]) | (c[3] & c[2] & ~c[1] & c[0]); // 0001, 0010, 0011, 0111, 1100, 1101
//	
//	assign display[6] = (~c[3] & ~c[2] & ~c[1] & ~c[0]) | (~c[3] & ~c[2] & ~c[1] & c[0]) | (~c[3] & c[2] & c[1] & c[0]) | (c[3] & c[2] & ~c[1] & ~c[0]); // 0000, 0001, 0111, 1100
//	
//endmodule
//
//module toplevel(SW, KEY, HEX0, HEX1, HEX2, HEX3);
//	input [7:0] SW;
//	input [1:0] KEY;
//	output [7:0] HEX0, HEX1, HEX2, HEX3;
//	wire [7:0] hexresult;
//	
//	part2 u6(.A(SW[7:4]), .B(SW[3:0]), .Function(KEY[1:0]), .ALUout(hexresult));
//	hex_decoder u7(.c(SW[3:0]), .display(HEX0[7:0]));
//	hex_decoder u8(.c(SW[7:4]), .display(HEX1[7:0]));
//	hex_decoder u9(.c(hexresult[3:0]), .display(HEX2[7:0]));
//	hex_decoder u10(.c(hexresult[7:4]), .display(HEX3[7:0]));
//endmodule
