// author: Matthew Molinar
// email: mmolinar@hmc.edu
// date created: 09/05/2025

// Lab 2: Multiplexed 7-Segment Display

module top(
	input logic [3:0] s1,    // switches for display 1
    input logic [3:0] s2,    // switches for display 2, 
	output logic [6:0] seg
    output logic seven_seg_1,
    output logic seven_seg_2
);

    logic int_osc;
    logic seven_seg_en;    // seven-segment enable
    logic [4:0] sum;      // for input summing
    logic [3:0] switch;   // switch input that will be used

	// Internal high-speed oscillator
	HSOSC hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));

    // clock counter module to create the enable signal
	clk_counter clock(
        .clk(int_osc),
        .seven_seg_en(seven_seg_en)
    );
    
    // switch mux module to use the right switch inputs
    switch_mux sw_mux(
        .s1(s1)
        .s2(s2)
        .seven_seg_en(seven_seg_en)
        .switch(switch)
    );

    // display gate module to turn on the correct display
    display_gate disp_gate(
        .seven_seg_en(seven_seg_en)
        .seven_seg_1(seven_seg_1)
        .seven_seg_2(seven_seg_2)
    );

    // seven segment module to drive a seven-segment module
	seven_seg sevseg(.s(display), .seg(seg));

    // adder module to sum inputs from both switches
    input_sum adder(
        .s1(s1),
        .s2(s2),
        .sum(sum)
    );

endmodule