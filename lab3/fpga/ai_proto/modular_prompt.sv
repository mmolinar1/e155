// error:
// Error	35901348	Synthesis	ERROR <35901348> - c:/users/mmolinar/my_designs/lab3_ai_proto/source/impl_1/lab3_ai_proto.sv(167): 
// an enum variable may only be assigned to same enum typed variable or one of its values. VERI-1348 [lab3_ai_proto.sv:167]	
//

//==============================================================
// Top-level keypad + 7-seg display for Lattice iCE40 UP5K
//==============================================================

module top_keypad_display (
    input  logic rst_n,         // active-low reset

    // Keypad connections
    output logic [3:0] col,     // keypad columns (active low)
    input  logic [3:0] row,     // keypad rows (active low)

    // Seven segment display
    output logic [6:0] seg,     // segments a–g (active low)
    output logic [1:0] an       // digit enables (active low)
);

    // ---------------------------------------------------------
    // Internal oscillator (12 MHz typical)
    // ---------------------------------------------------------
    logic clk;

    SB_HFOSC u_hfosc (
        .CLKHFEN (1'b1),
        .CLKHFPU (1'b1),
        .CLKHF   (clk)
    );
    defparam u_hfosc.CLKHF_DIV = "0b00"; // 12 MHz

    // ---------------------------------------------------------
    // Keypad scanner
    // ---------------------------------------------------------
    logic        key_pressed;
    logic [3:0]  key_code;

    keypad_scanner u_scan (
        .clk        (clk),
        .rst_n      (rst_n),
        .col        (col),
        .row        (row),
        .key_pressed(key_pressed),
        .key_code   (key_code)
    );

    // ---------------------------------------------------------
    // One-shot key register
    // ---------------------------------------------------------
    logic new_key;
    logic [3:0] last_key;

    key_register u_reg (
        .clk       (clk),
        .rst_n     (rst_n),
        .key_valid (key_pressed),
        .key_code  (key_code),
        .new_key   (new_key),
        .last_key  (last_key)
    );

    // ---------------------------------------------------------
    // Shift register for last two digits
    // ---------------------------------------------------------
    logic [3:0] digit0, digit1; // digit0 = most recent, digit1 = older

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            digit0 <= 4'h0;
            digit1 <= 4'h0;
        end else if (new_key) begin
            digit1 <= digit0;
            digit0 <= last_key;
        end
    end

    // ---------------------------------------------------------
    // Display multiplexing
    // ---------------------------------------------------------

    // Divider for ~1 kHz per digit refresh
    localparam integer DISP_DIV = 6000; // 12 MHz / 6000 ≈ 2 kHz
    logic [$clog2(DISP_DIV)-1:0] disp_cnt;
    logic disp_tick;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            disp_cnt  <= '0;
            disp_tick <= 1'b0;
        end else begin
            if (disp_cnt == DISP_DIV-1) begin
                disp_cnt  <= '0;
                disp_tick <= 1'b1;
            end else begin
                disp_cnt  <= disp_cnt + 1;
                disp_tick <= 1'b0;
            end
        end
    end

    // Toggle between digits
    logic sel; // 0 = digit0, 1 = digit1

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            sel <= 1'b0;
        else if (disp_tick)
            sel <= ~sel;
    end

    // Decode and drive seven segment
    logic [3:0] digit_val;
    logic [6:0] seg_val;

    always_comb begin
        digit_val = (sel == 1'b0) ? digit0 : digit1;
    end

    sevenSegment u_seven (
        .bin(digit_val),
        .seg(seg_val)
    );

    assign seg = seg_val;
    assign an  = (sel == 1'b0) ? 2'b10 : 2'b01; // active low digit select

endmodule


//==============================================================
// Keypad Scanner
//==============================================================
module keypad_scanner #(
    parameter integer CLK_DIV = 12_000  // adjust for scan rate
)(
    input  logic        clk,
    input  logic        rst_n,
    output logic [3:0]  col,
    input  logic [3:0]  row,
    output logic        key_pressed,
    output logic [3:0]  key_code
);
    // Divider for scan tick
    logic [$clog2(CLK_DIV)-1:0] div_cnt;
    logic tick;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            div_cnt <= '0;
            tick    <= 1'b0;
        end else begin
            if (div_cnt == CLK_DIV-1) begin
                div_cnt <= '0;
                tick    <= 1'b1;
            end else begin
                div_cnt <= div_cnt + 1;
                tick    <= 1'b0;
            end
        end
    end

    // Column state machine
    typedef enum logic [1:0] { COL0, COL1, COL2, COL3 } col_state_t;
    col_state_t col_state;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            col_state <= COL0;
        else if (tick)
            col_state <= col_state + 2'd1;
    end

    // Column drive
    always_comb begin
        case (col_state)
            COL0: col = 4'b1110;
            COL1: col = 4'b1101;
            COL2: col = 4'b1011;
            COL3: col = 4'b0111;
            default: col = 4'b1111;
        endcase
    end

    // Sample rows
    logic [3:0] row_sample;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            row_sample <= 4'b1111;
        else if (tick)
            row_sample <= row;
    end

    // Decode key
    logic [3:0] decode_code;
    logic decode_valid;

    always_comb begin
        decode_valid = 1'b0;
        decode_code  = 4'h0;
        case (col_state)
            COL0: case (row_sample)
                4'b1110: begin decode_code=4'h1; decode_valid=1'b1; end
                4'b1101: begin decode_code=4'h4; decode_valid=1'b1; end
                4'b1011: begin decode_code=4'h7; decode_valid=1'b1; end
                4'b0111: begin decode_code=4'hE; decode_valid=1'b1; end
            endcase
            COL1: case (row_sample)
                4'b1110: begin decode_code=4'h2; decode_valid=1'b1; end
                4'b1101: begin decode_code=4'h5; decode_valid=1'b1; end
                4'b1011: begin decode_code=4'h8; decode_valid=1'b1; end
                4'b0111: begin decode_code=4'h0; decode_valid=1'b1; end
            endcase
            COL2: case (row_sample)
                4'b1110: begin decode_code=4'h3; decode_valid=1'b1; end
                4'b1101: begin decode_code=4'h6; decode_valid=1'b1; end
                4'b1011: begin decode_code=4'h9; decode_valid=1'b1; end
                4'b0111: begin decode_code=4'hF; decode_valid=1'b1; end
            endcase
            COL3: case (row_sample)
                4'b1110: begin decode_code=4'hA; decode_valid=1'b1; end
                4'b1101: begin decode_code=4'hB; decode_valid=1'b1; end
                4'b1011: begin decode_code=4'hC; decode_valid=1'b1; end
                4'b0111: begin decode_code=4'hD; decode_valid=1'b1; end
            endcase
        endcase
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            key_code    <= 4'h0;
            key_pressed <= 1'b0;
        end else if (decode_valid) begin
            key_code    <= decode_code;
            key_pressed <= 1'b1;
        end else begin
            key_pressed <= 1'b0;
        end
    end

endmodule


//==============================================================
// Key Register (one-shot pulse on new key press)
//==============================================================
module key_register #(
    parameter KEY_WIDTH = 4
)(
    input  logic              clk,
    input  logic              rst_n,
    input  logic              key_valid,
    input  logic [KEY_WIDTH-1:0] key_code,
    output logic              new_key,
    output logic [KEY_WIDTH-1:0] last_key
);

    typedef enum logic [1:0] { IDLE, PRESSED, RELEASE_WAIT } state_t;
    state_t state, state_next;

    logic [KEY_WIDTH-1:0] key_latch;
    logic new_key_reg;

    // Sequential
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state       <= IDLE;
            key_latch   <= '0;
            new_key_reg <= 1'b0;
        end else begin
            state       <= state_next;
            new_key_reg <= 1'b0; // default each cycle

            if (state == IDLE && key_valid) begin
                key_latch   <= key_code;
                new_key_reg <= 1'b1; // one-shot pulse
            end
        end
    end

    // Next-state logic
    always_comb begin
        state_next = state;
        case (state)
            IDLE: begin
                if (key_valid)
                    state_next = PRESSED;
            end
            PRESSED: begin
                if (!key_valid)
                    state_next = RELEASE_WAIT;
            end
            RELEASE_WAIT: begin
                if (!key_valid)
                    state_next = IDLE;
                else
                    state_next = RELEASE_WAIT;
            end
            default: state_next = IDLE;
        endcase
    end

    assign new_key  = new_key_reg;
    assign last_key = key_latch;

endmodule


//==============================================================
// Seven Segment Decoder (hex to 7-seg, active low)
//==============================================================
module sevenSegment (
    input  logic [3:0] bin,
    output logic [6:0] seg
);
    always_comb begin
        case (bin)
            4'h0: seg = 7'b1000000;
            4'h1: seg = 7'b1111001;
            4'h2: seg = 7'b0100100;
            4'h3: seg = 7'b0110000;
            4'h4: seg = 7'b0011001;
            4'h5: seg = 7'b0010010;
            4'h6: seg = 7'b0000010;
            4'h7: seg = 7'b1111000;
            4'h8: seg = 7'b0000000;
            4'h9: seg = 7'b0010000;
            4'hA: seg = 7'b0001000;
            4'hB: seg = 7'b0000011;
            4'hC: seg = 7'b1000110;
            4'hD: seg = 7'b0100001;
            4'hE: seg = 7'b0000110;
            4'hF: seg = 7'b0001110;
            default: seg = 7'b1111111;
        endcase
    end
endmodule