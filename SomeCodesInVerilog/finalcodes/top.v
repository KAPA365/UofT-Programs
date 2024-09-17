module top (
    input wire CLOCK_50,
    input wire RESET,
    input wire PS2_DAT,
    input wire PS2_CLK,
    output wire [6:0] HEX0,
    output wire [DataWidth-1:0] AUDIO_OUT
);
    reg [2:0] player_command;
    wire valid;
    wire [7:0] outCode;
    localparam [7:0] SCAN_CODE_R = 8'h2D;
    localparam [7:0] SCAN_CODE_N = 8'h31;
    localparam [7:0] SCAN_CODE_L = 8'h4B;
    localparam [7:0] SCAN_CODE_P = 8'h4D;
    localparam [7:0] SCAN_CODE_S = 8'h1B;
    parameter AddressWidth = 10;
    parameter DataWidth = 16;
    wire [1:0] command;
    wire ld, p, ps;

    always @(posedge CLOCK_50 or posedge RESET) begin
        if (RESET) begin
            player_command <= 3'b000;
        end else if (valid) begin
            case (outCode)
                SCAN_CODE_P: player_command <= 3'b001;
                SCAN_CODE_S: player_command <= 3'b010;
                SCAN_CODE_R: player_command <= 3'b011;
                SCAN_CODE_N: player_command <= 3'b100;
                SCAN_CODE_L: player_command <= 3'b101;
                default: player_command <= 3'b000;
            endcase
        end
    end

    player player_inst (
        .clk(CLOCK_50),
        .reset(RESET),
        .command(player_command),
        .ld(ld),
        .p(p),
        .ps(ps)
    );

    keyboard_press_driver keyboard_driver (
        .CLOCK_50(CLOCK_50),
        .valid(valid),
        .makeBreak(), // 1
        .outCode(outCode),
        .PS2_DAT(PS2_DAT),
        .PS2_CLK(PS2_CLK),
        .reset(RESET)
    );

    audio_player #(.AddressWidth(AddressWidth), .DataWidth(DataWidth)) 
    audio_player_inst (
        .clk(CLOCK_50),
        .reset(RESET),
        .play(p),
        .audio_out(AUDIO_OUT)
    );

    hex hex_display (
        .c(), // 1
        .display(HEX0)
    );
endmodule
