//Sw[7:0] data_in
//KEY[0] synchronous reset when pressed
//KEY[1] go signal
//LEDR displays result
//HEX0 & HEX1 also displays result
module part2(Clock, Reset, Go, DataIn, DataResult, ResultValid);
   input Clock;
   input Reset;
   input Go;
   input [7:0] DataIn;
   output [7:0] DataResult;
   output ResultValid;
   // lots of wires to connect our datapath and control
   wire ld_a, ld_b, ld_c, ld_x, ld_r;
   wire ld_alu_out;
   wire [1:0] alu_select_a, alu_select_b;
   wire alu_op;
   control C0(
      .clk(Clock),
      .Reset(Reset),
      .go(Go),
      .ld_alu_out(ld_alu_out),
      .ld_x(ld_x),
      .ld_a(ld_a),
      .ld_b(ld_b),
      .ld_c(ld_c),
      .ld_r(ld_r),
      .alu_select_a(alu_select_a),
      .alu_select_b(alu_select_b),
      .alu_op(alu_op),
      .result_valid(ResultValid)
   );
   datapath D0(
      .clk(Clock),
      .Reset(Reset),
      .ld_alu_out(ld_alu_out),
      .ld_x(ld_x),
      .ld_a(ld_a),
      .ld_b(ld_b),
      .ld_c(ld_c),
      .ld_r(ld_r),
      .alu_select_a(alu_select_a),
      .alu_select_b(alu_select_b),
      .alu_op(alu_op),
      .data_in(DataIn),
      .data_result(DataResult)
   );
endmodule
module control(
   input clk,
   input Reset,
   input go,
   output reg ld_a, ld_b, ld_c, ld_x, ld_r,
   output reg ld_alu_out,
   output reg [1:0] alu_select_a, alu_select_b,
   output reg alu_op,
   output reg result_valid
);
   reg [5:0] current_state, next_state;
   localparam S_LOAD_A = 5'd0,
   S_LOAD_A_WAIT = 5'd1,
   S_LOAD_B = 5'd2,
   S_LOAD_B_WAIT = 5'd3,
   S_LOAD_C = 5'd4,
   S_LOAD_C_WAIT = 5'd5,
   S_LOAD_X = 5'd6,
   S_LOAD_X_WAIT = 5'd7,
   S_CYCLE_0 = 5'd8,
   S_CYCLE_1 = 5'd9,
   S_CYCLE_2 = 5'd10,
   S_CYCLE_3 = 5'd11,
   S_CYCLE_4 = 5'd12,
	S_CYCLE_5 = 5'd13;
   // Next state logic aka our state table
   always@(*)
      begin: state_table
         case (current_state)
            S_LOAD_A: next_state = go ? S_LOAD_A_WAIT : S_LOAD_A; // Loop in current state until value is input
				S_LOAD_A_WAIT: next_state = go ? S_LOAD_A_WAIT : S_LOAD_B; // Loop in current state until go signal goes low
				S_LOAD_B: next_state = go ? S_LOAD_B_WAIT : S_LOAD_B; // Loop in current state until value is input
				S_LOAD_B_WAIT: next_state = go ? S_LOAD_B_WAIT : S_LOAD_C; // Loop in current state until go signal goes low
				S_LOAD_C: next_state = go ? S_LOAD_C_WAIT : S_LOAD_C; // Loop in current state until value is input
				S_LOAD_C_WAIT: next_state = go ? S_LOAD_C_WAIT : S_LOAD_X; // Loop in current state until go signal goes low 
				S_LOAD_X: next_state = go ? S_LOAD_X_WAIT : S_LOAD_X; // Loop in current state until value is input
				S_LOAD_X_WAIT: next_state = go ? S_LOAD_X_WAIT : S_CYCLE_0; // Loop in current state until go signal goes low
            S_CYCLE_0: next_state = S_CYCLE_1;
            S_CYCLE_1: next_state = S_CYCLE_2;
            S_CYCLE_2: next_state = S_CYCLE_3;
            S_CYCLE_3: next_state = S_CYCLE_4;
				S_CYCLE_4: next_state = S_CYCLE_5;
            S_CYCLE_5: next_state = go ? S_LOAD_A : S_CYCLE_5; // we will be done our two operations, start over after
            default: next_state = S_LOAD_A;
         endcase
      end // state_table
   // Output logic aka all of our datapath control signals
   always @(*)
      begin: enable_signals
         // By default make all our signals 0
         ld_alu_out = 1'b0;
         ld_a = 1'b0;
         ld_b = 1'b0;
         ld_c = 1'b0;
         ld_x = 1'b0;
         ld_r = 1'b0;
         alu_select_a = 2'b0;
         alu_select_b = 2'b0;
         alu_op = 1'b0;
         case (current_state)
            S_LOAD_A: begin
               ld_a = 1'b1;
            end
            S_LOAD_B: begin
               ld_b = 1'b1;
            end
            S_LOAD_C: begin
               ld_c = 1'b1;
            end
            S_LOAD_X: begin
               ld_x = 1'b1;
            end
            S_CYCLE_0: begin // Do B <- B * x
               ld_alu_out = 1'b1; ld_b = 1'b1; // store result back into b
               alu_select_a = 2'b01; // Select register B
               alu_select_b = 2'b11; //  select register x
               alu_op = 1'b1; // Do multiply operation
            end
            S_CYCLE_1: begin // Do A <- A * x
               ld_alu_out = 1'b1; ld_a = 1'b1; // store result back into x
               alu_select_a = 2'b00; // Select register A
               alu_select_b = 2'b11; //  select register x
               alu_op = 1'b1; // Do multiply operation
            end
            S_CYCLE_2: begin // Do A <- A * x
               ld_alu_out = 1'b1; ld_a = 1'b1; // store result back into x
               alu_select_a = 2'b00; // Select register A
               alu_select_b = 2'b11; //  select register x
               alu_op = 1'b1; // Do multiply operation
            end
            S_CYCLE_3: begin // Do B <- B + C
               ld_alu_out = 1'b1; ld_b = 1'b1; // store result back into B
               alu_select_a = 2'b01; // Select register B
               alu_select_b = 2'b10; //  select register C
               alu_op = 1'b0; // Do add operation
            end
            S_CYCLE_4: begin // Do B <- A + B 
               ld_r = 1'b1; // store result in result register
               alu_select_a = 2'b00; // Select register A
               alu_select_b = 2'b01; // Select register B
               alu_op = 1'b0; // Do Add operation
            end
				S_CYCLE_5: begin
               result_valid = 1'b1;
            end
            // default: // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
         endcase
      end // enable_signals
   // current_state registers
   always@(posedge clk)
      begin: state_FFs
         if(Reset) begin
            current_state <= S_LOAD_A;
         end
         else begin
            current_state <= next_state;
         end // state_FFS
      end
	always@(*)
      begin
			if (current_state == S_CYCLE_5) result_valid = 1;
         else result_valid = 0;
      end
endmodule
module datapath(
   input clk,
   input Reset,
   input [7:0] data_in,
   input ld_alu_out,
   input ld_x, ld_a, ld_b, ld_c,
   input ld_r,
   input alu_op,
   input [1:0] alu_select_a, alu_select_b,
   output reg [7:0] data_result
);
   // input registers
   reg [7:0] a, b, c, x;
   // output of the alu
   reg [7:0] alu_out;
   // alu input muxes
   reg [7:0] alu_a, alu_b;
   // Registers a, b, c, x with respective input logic
   always@(posedge clk) begin
      if(Reset) begin
         a <= 8'b0;
         b <= 8'b0;
         c <= 8'b0;
         x <= 8'b0;
      end
      else begin
         if(ld_a)
            a <= ld_alu_out ? alu_out : data_in; // load alu_out if load_alu_out signal is high, otherwise load from data_in
         if(ld_b)
            b <= ld_alu_out ? alu_out : data_in; // load alu_out if load_alu_out signal is high, otherwise load from data_in
         if(ld_x)
            x <= data_in;
         if(ld_c)
            c <= data_in;
      end
   end
   // Output result register
   always@(posedge clk) begin
      if(Reset) begin
         data_result <= 8'b0;
      end
      else
         if(ld_r)
            data_result <= alu_out;
   end
   // The ALU input multiplexers
   always @(*)
      begin
         case (alu_select_a)
            2'd0:
               alu_a = a;
            2'd1:
               alu_a = b;
            2'd2:
               alu_a = c;
            2'd3:
               alu_a = x;
            default: alu_a = 8'b0;
         endcase
         case (alu_select_b)
            2'd0:
               alu_b = a;
            2'd1:
               alu_b = b;
            2'd2:
               alu_b = c;
            2'd3:
               alu_b = x;
            default: alu_b = 8'b0;
         endcase
      end
   // The ALU
   always @(*)
      begin : ALU
         // alu
         case (alu_op)
            0: begin
               alu_out = alu_a + alu_b; //performs addition
            end
            1: begin
               alu_out = alu_a * alu_b; //performs multiplication
            end
            default: alu_out = 8'b0;
         endcase
      end
endmodule
