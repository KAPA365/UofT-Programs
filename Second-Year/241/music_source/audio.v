module audio_player (
    input wire clk,
    input wire reset,
    input wire play,
    output wire [7:0] audio_out
);
    parameter AddressWidth = 10;
    parameter DataWidth = 8;
    reg [AddressWidth-1:0] address = 0;

    memory #(.AddressWidth(AddressWidth), .DataWidth(DataWidth)) 
    mem (
        .clk(clk),
        .reset(reset),
        .read_addr(address),
        .data_out(audio_out)
    );

    always @(posedge clk) begin
        if (reset) begin
            address <= 0;
        end else if (play) begin
            address <= address + 1;
        end
    end
endmodule



module audio_memory (
    input wire clk,
    input wire [AddressWidth-1:0] address,
    output reg [DataWidth-1:0] data_out
);
    parameter AddressWidth = 10;
    parameter DataWidth = 8;
    parameter MEM_DEPTH = 1 << AddressWidth;

    reg [DataWidth-1:0] rom [0:MEM_DEPTH-1];

    initial begin
        $readmemh("sample.mif", rom);
    end

    always @(posedge clk) begin
        data_out <= rom[address];
    end
endmodule

