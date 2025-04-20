module part3(clock, reset, ParallelLoadn, RotateRight, ASRight, Data_IN, Q);
	input clock, reset, ParallelLoadn, RotateRight, ASRight;
	input [3:0] Data_IN;
	output reg [3:0] Q;
	always@ (posedge clock) // register
		begin 
			if (reset) Q <= 4'b0000;
			else if (ParallelLoadn) begin
				if (RotateRight) begin // shift right
					Q[0] <= Q[1];
					Q[1] <= Q[2];
					Q[2] <= Q[3];
					Q[3] <= Q[0];
					if (ASRight) Q[3] <= Q[2]; // if AS then overwrite the MSB
				end
				else begin // shift left
					Q[0] <= Q[3];
					Q[1] <= Q[0];
					Q[2] <= Q[1];
					Q[3] <= Q[2];
				end
			end
			else Q <= Data_IN; // carries the last value
		end
endmodule


	
