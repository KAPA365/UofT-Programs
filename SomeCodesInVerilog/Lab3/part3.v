module part3(A, B, Function, ALUout);
	parameter N = 4;
	input [N-1:0] A, B;
	input [1:0] Function;
	output reg [2*N-1:0] ALUout;  
	
	wire [N:0] w;
	assign w = A + B;
	
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