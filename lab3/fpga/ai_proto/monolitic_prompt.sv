// Filename: keypad_display.sv
// Target: Lattice iCE40 UP5K (internal oscillator ~20 MHz)
// - seg[] are active-low segment outputs (for common-anode displays).
// - anode_en[] are active-high digit enables (set to 1 to enable a digit).
//
// Key mapping (rows 0..3 top->bottom, cols 0..3 left->right):
//  R\C:  C0   C1   C2   C3
//  R0 :  1    2    3    A
//  R1 :  4    5    6    B
//  R2 :  7    8    9    C
//  R3 :  E    0    F    D
//
// Adjust mapping if your physical keypad uses a different layout.

`timescale 1ns/1ps

// -----------------------------------------------------------------------------
// Clock divider that produces a periodic tick (one-cycle pulse) at ~TARGET_HZ.
// Use the iCE40 internal oscillator (e.g. ~20_000_000 Hz) as clk_in.
// -----------------------------------------------------------------------------
module clk_divider #(
    parameter integer CLK_IN_HZ = 20_000_000,   // oscillator frequency (approx)
    parameter integer TARGET_HZ = 150           // desired tick frequency (100-200 Hz)
) (
    input  logic clk_in,
    input  logic rst_n,       // active-low reset
    output logic tick         // one-cycle pulse at TARGET_HZ
);
    // compute integer divider: clk_in / TARGET_HZ -> but we generate 1-cycle pulse every DIV cycles
    localparam integer DIV = (CLK_IN_HZ + (TARGET_HZ/2)) / TARGET_HZ; // rounded
    // We'll assert tick for exactly one clk cycle when counter == DIV-1.
    logic [$clog2(DIV+1)-1:0] cnt;

    always_ff @(posedge clk_in or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 0;
            tick <= 1'b0;
        end else begin
            if (cnt == DIV-1) begin
                cnt <= 0;
                tick <= 1'b1;
            end else begin
                cnt <= cnt + 1;
                tick <= 1'b0;
            end
        end
    end
endmodule


// -----------------------------------------------------------------------------
// Keypad scanner
// - columns are driven active-low (one column low at a time).
// - rows are inputs active-low (pulled-up externally).
// - Produces a one-cycle strobe 'new_key' and a 4-bit hex code for the pressed key.
// - Registers at most one key per physical press; ignores other presses until release.
// -----------------------------------------------------------------------------
module keypad_scanner (
    input  logic        clk,        // system clock (same as clk_divider.clk_in)
    input  logic        rst_n,
    input  logic        scan_tick,  // tick to advance scan (e.g., ~150 Hz)
    input  logic [3:0]  rows_n,     // active-low row inputs (external pull-ups) [row3,row2,row1,row0] or [3:0]
    output logic [3:0]  cols_n,     // active-low one-hot column outputs (drive low to select column)
    output logic [3:0]  keycode,    // hex value of registered key (valid when new_key asserted)
    output logic        new_key     // one-cycle pulse when a new key is registered
);

    // column pointer 0..3
    logic [1:0] col_idx;
    // State to ensure only one registration per press and require full release
    typedef enum logic [1:0] {KS_IDLE = 2'b00, KS_PRESSED = 2'b01} ks_state_t;
    ks_state_t state, next_state;

    // internal values
    logic [3:0] cur_cols_n;
    logic [3:0] detected_rows; // active-high when pressed (converted)
    logic detect_any;

    // Generate column outputs (active-low one-hot)
    always_comb begin
        cur_cols_n = 4'b1111;
        case (col_idx)
            2'd0: cur_cols_n = 4'b1110; // C0 low
            2'd1: cur_cols_n = 4'b1101; // C1 low
            2'd2: cur_cols_n = 4'b1011; // C2 low
            2'd3: cur_cols_n = 4'b0111; // C3 low
            default: cur_cols_n = 4'b1111;
        endcase
    end
    assign cols_n = cur_cols_n;

    // convert active-low rows to active-high pressed flags
    always_comb begin
        detected_rows = ~rows_n; // 1 means pressed on that row
        detect_any = |detected_rows;
    end

    // keycode generation mapping: combine current column and row to 4-bit hex
    function automatic logic [3:0] map_rowcol_to_hex(input logic [1:0] r, input logic [1:0] c);
        // r: row index 0..3 (0=top), c: column index 0..3 (0=left)
        // mapping table (as defined in module header)
        logic [3:0] out;
        begin
            unique case ({r,c})
                4'b0000: out = 4'h1; // R0 C0
                4'b0001: out = 4'h2; // R0 C1
                4'b0010: out = 4'h3; // R0 C2
                4'b0011: out = 4'hA; // R0 C3
                4'b0100: out = 4'h4; // R1 C0
                4'b0101: out = 4'h5; // R1 C1
                4'b0110: out = 4'h6; // R1 C2
                4'b0111: out = 4'hB; // R1 C3
                4'b1000: out = 4'h7; // R2 C0
                4'b1001: out = 4'h8; // R2 C1
                4'b1010: out = 4'h9; // R2 C2
                4'b1011: out = 4'hC; // R2 C3
                4'b1100: out = 4'hE; // R3 C0
                4'b1101: out = 4'h0; // R3 C1
                4'b1110: out = 4'hF; // R3 C2
                4'b1111: out = 4'hD; // R3 C3
                default: out = 4'h0;
            endcase
            return out;
        end
    endfunction

    // Determine which row index (if multiple rows are active in same column, pick the lowest index).
    // We will prefer the *first* row bit (bit0) -> row0, etc. This keeps deterministic behavior.
    function automatic logic [1:0] first_row_index(input logic [3:0] rows);
        logic [1:0] idx;
        begin
            if (rows[0]) idx = 2'd0;
            else if (rows[1]) idx = 2'd1;
            else if (rows[2]) idx = 2'd2;
            else if (rows[3]) idx = 2'd3;
            else idx = 2'd0;
            return idx;
        end
    endfunction

    // FSM and column stepping on scan_tick
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            col_idx <= 2'd0;
            state <= KS_IDLE;
            new_key <= 1'b0;
            keycode <= 4'h0;
        end else begin
            new_key <= 1'b0; // default: no new key this cycle

            // advance column on each scan tick (so we sample one column per tick)
            if (scan_tick) begin
                col_idx <= col_idx + 1'b1;
            end

            // state machine transitions / actions
            case (state)
                KS_IDLE: begin
                    // If any key is detected in the currently-driven column, register it.
                    // Note: we sample rows for the currently active column only (no cross-column mixing).
                    if (scan_tick && detect_any) begin
                        // Only register keys that appear in the column we are asserting low.
                        // Since rows_n sampled when that column is selected, detect_any means a key in this column.
                        // Determine which row index, map to hex, and strobe new_key.
                        logic [1:0] r_idx;
                        r_idx = first_row_index(detected_rows);
                        keycode <= map_rowcol_to_hex(r_idx, col_idx);
                        new_key <= 1'b1;
                        state <= KS_PRESSED; // wait for full release before next registration
                    end else begin
                        state <= KS_IDLE;
                    end
                end

                KS_PRESSED: begin
                    // Stay here until all rows are released (all rows_n == 1).
                    if (!detect_any) begin
                        // full release observed; go back to IDLE and allow next registration
                        state <= KS_IDLE;
                    end else begin
                        state <= KS_PRESSED;
                    end
                end

                default: state <= KS_IDLE;
            endcase
        end
    end
endmodule


// -----------------------------------------------------------------------------
// Hex to 7-segment decoder (common-anode, segments active-low).
// seg[6:0] = {a,b,c,d,e,f,g} active-low (0 turns segment ON).
// -----------------------------------------------------------------------------
module hex7seg_decoder (
    input  logic [3:0] hex,
    output logic [6:0] seg_n  // active-low segments
);
    always_comb begin
        // For active-low segments: 0 = segment on, 1 = off.
        unique case (hex)
            4'h0: seg_n = 7'b0000001; // 0: a b c d e f on, g off
            4'h1: seg_n = 7'b1001111; // 1: b c
            4'h2: seg_n = 7'b0010010; // 2: a b g e d
            4'h3: seg_n = 7'b0000110; // 3: a b c d g
            4'h4: seg_n = 7'b1001100; // 4: f g b c
            4'h5: seg_n = 7'b0100100; // 5: a f g c d
            4'h6: seg_n = 7'b0100000; // 6: a f e d c g
            4'h7: seg_n = 7'b0001111; // 7: a b c
            4'h8: seg_n = 7'b0000000; // 8: all segments
            4'h9: seg_n = 7'b0000100; // 9: a b c d f g
            4'hA: seg_n = 7'b0001000; // A: a b c e f g
            4'hB: seg_n = 7'b1100000; // b: (lowercase) c d e f g maybe
            4'hC: seg_n = 7'b0110001; // C: a f e d
            4'hD: seg_n = 7'b1000010; // d: b c d e g
            4'hE: seg_n = 7'b0110000; // E: a f e d g
            4'hF: seg_n = 7'b0111000; // F: a f e g
            default: seg_n = 7'b1111111;
        endcase
    end
endmodule


// -----------------------------------------------------------------------------
// Display multiplexer: time-multiplex two digits (digit0 = least-significant / right).
// Balanced brightness: each digit on for equal time. We generate a high-rate refresh
// tick internally (parameter REFRESH_HZ) to avoid flicker. Outputs:
// - seg_n[6:0] active-low segment lines
// - anode_en[1:0] active-high digit enables
// -----------------------------------------------------------------------------
module display_mux #(
    parameter integer CLK_HZ = 20_000_000,
    parameter integer REFRESH_PER_DIGIT_HZ = 1000 // per-digit rate; ~1kHz prevents flicker
) (
    input  logic       clk,
    input  logic       rst_n,
    input  logic [3:0] digit0_hex,    // right / least-significant
    input  logic [3:0] digit1_hex,    // left / older
    output logic [6:0] seg_n,         // active-low segments to 7-seg a..g
    output logic [1:0] anode_en       // active-high enables (1 enables that digit's anode)
);
    // small divider to create refresh tick per digit
    localparam integer DIVR = (CLK_HZ + (REFRESH_PER_DIGIT_HZ/2)) / REFRESH_PER_DIGIT_HZ;
    logic [$clog2(DIVR+1)-1:0] rcnt;
    logic refresh_tick;

    // refresh counter (creates refresh_tick)
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rcnt <= 0;
            refresh_tick <= 1'b0;
        end else begin
            if (rcnt == DIVR-1) begin
                rcnt <= 0;
                refresh_tick <= 1'b1;
            end else begin
                rcnt <= rcnt + 1;
                refresh_tick <= 1'b0;
            end
        end
    end

    // toggle active digit on each refresh_tick
    logic active_digit; // 0 => show digit0 (right), 1 => show digit1 (left)
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) active_digit <= 1'b0;
        else if (refresh_tick) active_digit <= ~active_digit;
    end

    // instantiate decoder
    logic [6:0] seg0_n, seg1_n;
    hex7seg_decoder h0(.hex(digit0_hex), .seg_n(seg0_n));
    hex7seg_decoder h1(.hex(digit1_hex), .seg_n(seg1_n));

    // drive outputs combinationally for minimal glitching synchronized with clk
    always_comb begin
        if (active_digit == 1'b0) begin
            // show digit0 on right
            seg_n = seg0_n;
            anode_en = 2'b01; // [left, right] -> only right enabled (LSB)
        end else begin
            // show digit1 on left
            seg_n = seg1_n;
            anode_en = 2'b10; // only left enabled
        end
    end

endmodule


// -----------------------------------------------------------------------------
// Top-level: wires everything together
// - Inputs: clk_in (internal oscillator), rst_n, rows_n
// - Outputs: cols_n (to keypad columns, active-low), seg_n[6:0], anode_en[1:0]
// -----------------------------------------------------------------------------
module top_keypad_display (
    input  logic clk_in,      // internal osc, ~20 MHz
    input  logic rst_n,       // active-low reset
    input  logic [3:0] rows_n,// keypad active-low row inputs
    output logic [3:0] cols_n,// keypad active-low column outputs
    output logic [6:0] seg_n, // 7-seg active-low segments
    output logic [1:0] anode_en
);
    // parameters: adjust if your oscillator frequency differs
    localparam integer SYS_CLK_HZ = 20_000_000;
    localparam integer SCAN_HZ = 150;         // keypad scan rate (~100-200 Hz)
    localparam integer DISP_REFRESH_HZ = 1000; // per digit refresh (1 kHz) -> no flicker

    // Instantiate scan clock divider
    logic scan_tick;
    clk_divider #(.CLK_IN_HZ(SYS_CLK_HZ), .TARGET_HZ(SCAN_HZ)) scanner_clk (
        .clk_in(clk_in),
        .rst_n(rst_n),
        .tick(scan_tick)
    );

    // Keypad scanner
    logic [3:0] keycode;
    logic new_key;
    keypad_scanner kscan (
        .clk(clk_in),
        .rst_n(rst_n),
        .scan_tick(scan_tick),
        .rows_n(rows_n),
        .cols_n(cols_n),
        .keycode(keycode),
        .new_key(new_key)
    );

    // storage for two recent keys
    logic [3:0] recent, older;

    // Update registers on new_key (synchronous to clk_in)
    always_ff @(posedge clk_in or negedge rst_n) begin
        if (!rst_n) begin
            recent <= 4'h0;
            older  <= 4'h0;
        end else begin
            if (new_key) begin
                older  <= recent;
                recent <= keycode;
            end
        end
    end

    // Display multiplexer (time-multiplexed two digits)
    display_mux #(.CLK_HZ(SYS_CLK_HZ), .REFRESH_PER_DIGIT_HZ(DISP_REFRESH_HZ)) disp (
        .clk(clk_in),
        .rst_n(rst_n),
        .digit0_hex(recent), // right / least recent
        .digit1_hex(older),  // left / older
        .seg_n(seg_n),
        .anode_en(anode_en)
    );

endmodule