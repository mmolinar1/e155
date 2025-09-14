// author: Matthew Molinar
// email: mmolinar@hmc.edu
// date created: 09/10/2025

// Lab 3: Keypad Scanner
// This module scans inputs from a
// keypad and displays inputs on a
// dual seven-segment display - the most
// recent entry appears on the right

module lab3_mm(
    input clk, reset,
	input logic [3:0] row,    // switches for display 1
    output logic [3:0] col,    // switches for display 2, 
	output logic [6:0] seg,
    output logic seven_seg_1,
    output logic seven_seg_2
    );

    logic int_osc;
    logic [3:0] key_digit;
    logic key_valid;
    logic [3:0] digit1, digit2;
    logic [3:0] display_digit;

    // Internal high-speed oscillator
	HSOSC hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));

    // Keypad FSM to manage scanning and button detection
    keypad_fsm fsm(
        .clk(clk), .reset(reset),
        .col(col), .row(row),
        .digit(key_digit),
        .key_valid(key_valid)
    );

    // displaying the right digit on the correct
    // displays
    always_ff @(posedge clk)
        if (reset) begin
            digit1 <= 4'h0;
            digit2 <= 4'h0;
        end else if (key_valid) begin
            digit1 <= digit2;
            digit2 <= key_digit;
        end

    // display the correct digit
    assign display_digit = seven_seg_1 ? digit1 : digit2;

    // modified lab 2 module to drive a dual
    // seven segment display w/ time multiplexing
    lab2_mm dual_seven_seg(
        .clk(clk), .reset(reset),
        .int_osc(int_osc), .digit(display_digit)
        .seg(seg), .seven_seg_1(seven_seg_1),
        .seven_seg_2(seven_seg_2)
    );

endmodule