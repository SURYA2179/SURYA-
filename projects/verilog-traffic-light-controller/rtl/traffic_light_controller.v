// Educational Verilog FSM: two-road traffic controller with pedestrian request.
// Light encodings: RED=2'b00, YELLOW=2'b01, GREEN=2'b10.
// Not intended for real-world traffic control.

module traffic_light_controller #(
    parameter integer NS_GREEN_CYCLES  = 5,
    parameter integer NS_YELLOW_CYCLES = 2,
    parameter integer EW_GREEN_CYCLES  = 5,
    parameter integer EW_YELLOW_CYCLES = 2,
    parameter integer PED_WALK_CYCLES  = 4
) (
    input  wire       clk,
    input  wire       rst_n,       // Active-low asynchronous reset
    input  wire       ped_request, // Synchronous request input
    output reg  [1:0] ns_light,
    output reg  [1:0] ew_light,
    output reg        walk
);

    localparam [1:0] RED    = 2'b00;
    localparam [1:0] YELLOW = 2'b01;
    localparam [1:0] GREEN  = 2'b10;

    localparam [2:0] NS_GREEN  = 3'd0;
    localparam [2:0] NS_YELLOW = 3'd1;
    localparam [2:0] EW_GREEN  = 3'd2;
    localparam [2:0] EW_YELLOW = 3'd3;
    localparam [2:0] PED_WALK  = 3'd4;

    reg [2:0]  state;
    reg [31:0] timer;
    reg        ped_pending;

    // State sequencing and cycle timer.
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state       <= NS_GREEN;
            timer       <= 32'd0;
            ped_pending <= 1'b0;
        end else begin
            if (ped_request) begin
                ped_pending <= 1'b1;
            end else if ((state == PED_WALK) &&
                         (timer == PED_WALK_CYCLES - 1)) begin
                ped_pending <= 1'b0;
            end

            if (timer == phase_length(state) - 1) begin
                timer <= 32'd0;
                case (state)
                    NS_GREEN:  state <= NS_YELLOW;
                    NS_YELLOW: state <= EW_GREEN;
                    EW_GREEN:  state <= EW_YELLOW;
                    EW_YELLOW: begin
                        if (ped_pending || ped_request)
                            state <= PED_WALK;
                        else
                            state <= NS_GREEN;
                    end
                    PED_WALK:  state <= NS_GREEN;
                    default:   state <= NS_GREEN;
                endcase
            end else begin
                timer <= timer + 1'b1;
            end
        end
    end

    // Return the duration of the active state. Parameters should be >= 1.
    function [31:0] phase_length;
        input [2:0] current_state;
        begin
            case (current_state)
                NS_GREEN:  phase_length = NS_GREEN_CYCLES;
                NS_YELLOW: phase_length = NS_YELLOW_CYCLES;
                EW_GREEN:  phase_length = EW_GREEN_CYCLES;
                EW_YELLOW: phase_length = EW_YELLOW_CYCLES;
                PED_WALK:  phase_length = PED_WALK_CYCLES;
                default:   phase_length = NS_GREEN_CYCLES;
            endcase
        end
    endfunction

    // Combinational output decode.
    always @* begin
        ns_light = RED;
        ew_light = RED;
        walk     = 1'b0;

        case (state)
            NS_GREEN: begin
                ns_light = GREEN;
                ew_light = RED;
            end
            NS_YELLOW: begin
                ns_light = YELLOW;
                ew_light = RED;
            end
            EW_GREEN: begin
                ns_light = RED;
                ew_light = GREEN;
            end
            EW_YELLOW: begin
                ns_light = RED;
                ew_light = YELLOW;
            end
            PED_WALK: begin
                ns_light = RED;
                ew_light = RED;
                walk     = 1'b1;
            end
            default: begin
                ns_light = RED;
                ew_light = RED;
                walk     = 1'b0;
            end
        endcase
    end

endmodule
