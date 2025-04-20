module memory(
    input wire clk,
    input wire reset,
    input wire [AddressWidth-1:0] read_addr,
    output wire [DataWidth-1:0] data_out
);
    parameter AddressWidth = 10;
    parameter DataWidth = 16;

    audio_memory #(.AddressWidth(AddressWidth), .DataWidth(DataWidth)) 
    audio_mem (
        .clk(clk),
        .address(read_addr),
        .data_out(data_out)
    );
endmodule

module ram_control(
   input clk,
   input Reset,
   input [4:0] addr,
   input write,
   output reg ld,
   output reg [4:0] ld_in,
   output reg [4:0] ld_out,
   output reg pl
);
    reg [1:0] current_state, next_state;
    localparam LOAD = 2'd0, WAIT = 2'd1, OUTPUT = 2'd2;

    always @(posedge clk or posedge Reset) begin
        if (Reset)
            current_state <= LOAD;
        else
            current_state <= next_state;
    end

    always @(*) begin
        case (current_state)
            LOAD: next_state = write ? WAIT : LOAD;
            WAIT: next_state = OUTPUT;
            OUTPUT: next_state = LOAD;
            default: next_state = LOAD;
        endcase
    end

    always @(*) begin
        ld = (current_state == LOAD);
        ld_in = (current_state == WAIT) ? addr : 5'b0;
        ld_out = (current_state == OUTPUT) ? addr : 5'b0;
        pl = (current_state == OUTPUT);
    end
endmodule

module ram_datapath(
   input clk,
   input Reset,
   input [7:0] data_in,
   input ld,
   input [4:0] ld_in,
   input [4:0] ld_out,
   input play,
   output reg [7:0] data_result
);
    wire [4:0] ram_address = (ld) ? ld_in : ld_out;
    wire [7:0] ram_data_out;
    wire ram_write_enable = ld;

    RAM ram_module (
        .clock(clk),
        .write_enable(ram_write_enable),
        .address(ram_address),
        .data_in(data_in),
        .data_out(ram_data_out)
    );

    always @(posedge clk) begin
        if (Reset)
            data_result <= 8'b0;
        else if (play)
            data_result <= ram_data_out;
    end
endmodule

module RAM(
    input clock,            
    input write_enable,     
    input [4:0] address,         
    input [7:0] data_in,          
    output [7:0] data_out
);
    reg [7:0] mem [0:29];

    always @(posedge clock) begin
        if (write_enable)
            mem[address] <= data_in;
    end

    assign data_out = mem[address];
endmodule
