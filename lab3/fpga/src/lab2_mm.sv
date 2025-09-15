// author: Matthew Molinar
// email: mmolinar@hmc.edu
// date created: 09/05/2025

// Lab 2: Multiplexed 7-Segment Display
// This module powers two seven-segment
// displays using only one seven_seg
// module (only seven output pins)
// by taking advantage of time multiplexing

// This is a modified version of my original
// lab 2 code

module lab2_mm(
    input clk, reset,
	input logic [3:0] digit,
	output logic [6:0] seg,
    output logic seven_seg_1,
    output logic seven_seg_2,
    output logic seven_seg_en    // seven-segment enable
);

    logic [25:0] counter = 0;    // counter for 400 KHz
    parameter CLOCK_DIVIDER = 25'd400000;   

	// counter using high-speed oscillator
	always_ff @(posedge clk) begin
        if (reset) begin
            counter <= 0;
            seven_seg_en <= 0;
        end else if (counter == CLOCK_DIVIDER) begin
            counter <= 0;
            seven_seg_en <= ~seven_seg_en;    // toggle seven-segment enable
        end else begin
            counter <= counter + 1'b1;
        end
    end

    // display gate module to turn on the correct display
    display_gate disp_gate(
        .seven_seg_en(seven_seg_en),
        .seven_seg_1(seven_seg_1),
        .seven_seg_2(seven_seg_2)
    );

    // seven segment module to drive a seven-segment module
	seven_seg sevseg(.s(digit), .seg(seg));

endmodule