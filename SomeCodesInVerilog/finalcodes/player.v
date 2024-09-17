module player (
    input wire clk,
    input wire reset,
    input wire [2:0] command,
    output wire ld, p, ps, pn, pp,
    output wire [3:0] song_index
);
    reg [4:0] cmd;

    always @(*) begin
        case (command)
            3'b000: cmd = 5'b00001;
            3'b001: cmd = 5'b00010;
            3'b010: cmd = 5'b00100;
            3'b011: cmd = 5'b01000;
            3'b100: cmd = 5'b10000;
            default: cmd = 5'b00000;
        endcase
    end

    player_control control(
        .Clock(clk),
        .Reset(reset),
        .cmd(cmd),
        .ld(ld),
        .p(p),
        .ps(ps),
        .pn(pn),
        .pp(pp),
        .song_index(song_index)
    );
endmodule

module player_control (
    input Clock,
    input Reset,
    input [4:0] cmd,
    output reg ld, p, ps, pn, pp,
    output reg [3:0] song_index
);
    localparam LOAD = 5'b00001, PLAY = 5'b00010, PAUSE = 5'b00100, PLAYNEXT = 5'b01000, PLAYPREVIOUS = 5'b10000;
    reg [4:0] CurState, NextState;

    initial begin
        song_index = 0;
    end

    always @(*) begin
        case (CurState)
            LOAD: NextState = (cmd == PLAY) ? PLAY : LOAD;
            PLAY: begin
                case (cmd)
                    PAUSE: NextState = PAUSE;
                    PLAYNEXT: NextState = PLAYNEXT;
                    PLAYPREVIOUS: NextState = PLAYPREVIOUS;
                    default: NextState = PLAY;
                endcase
            end
            PAUSE: NextState = (cmd == PLAY) ? PLAY : PAUSE;
            PLAYNEXT: NextState = PLAY;
            PLAYPREVIOUS: NextState = PLAY;
            default: NextState = LOAD;
        endcase
    end

    always @(posedge Clock) begin
        if (Reset) begin
            CurState <= LOAD;
            song_index <= 0;
        end else begin
            CurState <= NextState;
            case (NextState)
                PLAYNEXT: song_index <= (song_index < 9) ? song_index + 1 : 0;
                PLAYPREVIOUS: song_index <= (song_index > 0) ? song_index - 1 : 9;
            endcase
        end
    end
endmodule
