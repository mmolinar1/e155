// author: Matthew Molinar
// email: mmolinar@hmc.edu
// date created: 09/10/2025

// Lab 3: Keypad Scanner
// This module scans inputs from a
// keypad and displays inputs on a
// dual seven-segment display - the most
// recent entry appears on the right

module lab3_mm(
    input reset,
	input logic [3:0] row,
    output logic [3:0] col,
	output logic [6:0] seg,
    output logic seven_seg_1,
    output logic seven_seg_2
    );

    logic int_osc;
    logic [3:0] key_digit;
    logic valid_key;
    logic [3:0] digit1, digit2;
    logic [3:0] display_digit;

    // Internal high-speed oscillator
	HSOSC hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));

    // Keypad FSM to manage scanning and button detection
    keypad_fsm fsm(
        .clk(int_osc), .reset(reset),
        .row(row), .col(col),
        .digit(key_digit),
        .valid_key(valid_key)
    );

    // displaying the right digit on the correct
    // displays
    always_ff @(posedge int_osc)
        if (reset) begin
            digit1 <= 4'h0;
            digit2 <= 4'h0;
        end else if (valid_key) begin
            digit1 <= digit2;
            digit2 <= key_digit;
        end

    // digit1 is the older entry (left display), digit2 is newest (right display)
    assign display_digit = seven_seg_en ? digit2 : digit1;

    // modified lab 2 module to drive a dual
    // seven segment display w/ time multiplexing
    lab2_mm dual_seven_seg(
        .clk(int_osc), .reset(reset),
        .digit(display_digit), .seg(seg),
        .seven_seg_1(seven_seg_1),
        .seven_seg_2(seven_seg_2),
        .seven_seg_en(seven_seg_en)
    );

endmodule