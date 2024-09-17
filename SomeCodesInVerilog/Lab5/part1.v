module t_flip_flop (
    input T,
    input Clock,
    input Reset,
    output Q
);
    reg D;
	 wire q;


    always @(*)
    begin
	     if (Reset)
            D <= 1'b0;
        else
            D <= T ^ q;
    end

    D_flip_flop u0 (
        .clk(Clock),
        .reset_b(Reset),
        .d(D),
        .q(q)
	 );
    assign Q = q; // syncing both Q = q
endmodule

module D_flip_flop (
    input wire clk,
    input wire reset_b,
    input wire d,
    output reg q
);
    always @(posedge clk)
    begin
        if (reset_b)
            q <= 1'b0;
        else
            q <= d;
    end
endmodule

module part1 (
    input Clock,
    input Enable,
    input Reset,
    output [7:0] CounterValue
);

   wire [7:0] t_outputs;

    // Instantiating 8 of the T-type flip-flops
    t_flip_flop tff0 (.T(Enable), .Clock(Clock), .Reset(Reset), .Q(t_outputs[0]));
    t_flip_flop tff1 (.T(Enable & t_outputs[0]), .Clock(Clock), .Reset(Reset), .Q(t_outputs[1]));
    t_flip_flop tff2 (.T(Enable & &t_outputs[1:0]), .Clock(Clock), .Reset(Reset), .Q(t_outputs[2]));
    t_flip_flop tff3 (.T(Enable & &t_outputs[2:0]), .Clock(Clock), .Reset(Reset), .Q(t_outputs[3]));
    t_flip_flop tff4 (.T(Enable & &t_outputs[3:0]), .Clock(Clock), .Reset(Reset), .Q(t_outputs[4]));
    t_flip_flop tff5 (.T(Enable & &t_outputs[4:0]), .Clock(Clock), .Reset(Reset), .Q(t_outputs[5]));
    t_flip_flop tff6 (.T(Enable & &t_outputs[5:0]), .Clock(Clock), .Reset(Reset), .Q(t_outputs[6]));
    t_flip_flop tff7 (.T(Enable & &t_outputs[6:0]), .Clock(Clock), .Reset(Reset), .Q(t_outputs[7]));

	
	 assign CounterValue = t_outputs;

endmodule
