
module part1 (
    input Clock,
    input Reset,
    input w,
    output z,
    output [3:0] CurState
);

reg [3:0] y_Q, Y_D;
localparam A = 4'd0, B = 4'd1, C = 4'd2, D = 4'd3, E = 4'd4, F = 4'd5, G = 4'd6;

// State table
always @* begin
    case (y_Q)
        A: 
	    begin
            if (!w) Y_D = A;
            else Y_D = B;
            end
        B: 
	    begin
            if (w) Y_D = C;
            else Y_D = A;
            end
        C: 
	    begin
            if (w) Y_D = D;
            else Y_D = E;
            end
        D: 
	    begin
            if (w) Y_D = F;
            else Y_D = E;
            end
        E: 
            begin
            if (w) Y_D = G;
            else Y_D = A;
            end
        F: 
            begin
            if (w) Y_D = F;
            else Y_D = E;
            end
        G: 
	    begin
            if (w) Y_D = C;
            else Y_D = A;
            end

        default: Y_D = A;
    endcase
end

// State Registers
always @(posedge Clock) begin
    if (Reset == 1'b1)
        y_Q <= A; // Should set reset state to state A
    else
        y_Q <= Y_D;
end

assign z = ((y_Q == F) | (y_Q == G)); // Output logic
assign CurState = y_Q;

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

module toplevel(KEY[0:0], SW[1:0], LEDR[9:0], HEX0);
	input [1:0] SW;
	input [0:0] KEY;
	output [9:0] LEDR;
	output [6:0] HEX0;
   part1 p0(KEY[0],SW[0],SW[1],LEDR[9],LEDR[3:0]);
	hex_decoder u7(.c(LEDR[3:0]), .display(HEX0[6:0]));
endmodule	