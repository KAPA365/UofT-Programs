module part1(a, b, c_in, s, c_out);
	input [3 : 0] a;
	input [3 : 0] b;
	input c_in;
	output reg [3 : 0] s;
	output reg [3:0] c_out;
	
	wire [3 : 0] sTemp, cLast; // save carry to next bit
	FA u0(a[0], b[0], c_in, sTemp[0], cLast[0]);
	FA u1(a[1], b[1], cLast[0], sTemp[1], cLast[1]); // c0 in, c1 out
	FA u2(a[2], b[2], cLast[1], sTemp[2], cLast[2]); // c1 in, c2 out
	FA u3(a[3], b[3], cLast[2], sTemp[3], cLast[3]); // c2 in, c3 out
	
	always@(*)
	begin
		s = sTemp;
		c_out = cLast;
	end
endmodule

module FA(a, b, ci, s, co);
	input a;
	input b;
	input ci;
	output s;
	output co;
	
	assign s = (~a & ~b & ci) | (a & ~b & ~ci) | (~a & b & ~ci) | (a & b & ci); // 001, 100, 010, 111
	assign co = (a & ~b & ci) | (~a & b & ci) | (a & b & ~ci) | (a & b & ci); // 101, 011, 110, 111
	
//	assign s = ci^a^b; // 001, 100, 010, 111
//	assign co = (a&b)|(ci&a)|(ci&b); // 101, 011, 110, 111
endmodule
