// author: Matthew Molinar
// email: mmolinar@hmc.edu
// date created: 09/05/2025

// Lab 2: Multiplexed 7-Segment Display

module top(
    input clk, reset,
	input logic [3:0] s1,    // switches for display 1
    input logic [3:0] s2,    // switches for display 2, 
	output logic [6:0] seg,
    output logic seven_seg_1,
    output logic seven_seg_2
);

    logic int_osc;
    logic seven_seg_en;    // seven-segment enable
    logic [4:0] sum;      // for input summing
    logic [3:0] switch;   // switch input that will be used

	// Internal high-speed oscillator
	HSOSC hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));

    // clock counter to create the enable signal
	// Clock divider variable at 24 KHz
	logic [14:0] counter = 0;    // counter for 24 KHz
    parameter CLOCK_DIVIDER = 25'd24000;   
	
	// counter using high-speed oscillator
	// always_ff @(posedge int_osc) begin
    //     if (counter == CLOCK_DIVIDER) begin
    //         counter <= 0;
    //         seven_seg_en <= ~seven_seg_en;    // toggle seven-segment enable
    //     end else begin
    //         counter <= counter + 1'b1;
    //     end
    // end

    // counter using clk
    // this is only used for modelsim since
    // questa can't interpret what HSOSC is
	always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            counter <= 0;
            seven_seg_en <= 0;    // toggle seven-segment enable
        end else if (counter == 1'b1) begin
            counter <= 0;
            seven_seg_en <= ~seven_seg_en;    // toggle seven-segment enable
        end else begin
            counter <= counter + 1'b1;
        end
    end
    
    // switch mux module to use the right switch inputs
    switch_mux sw_mux(
        .s1(s1),
        .s2(s2),
        .seven_seg_en(seven_seg_en),
        .switch(switch)
    );

    // display gate module to turn on the correct display
    display_gate disp_gate(
        .seven_seg_en(seven_seg_en),
        .seven_seg_1(seven_seg_1),
        .seven_seg_2(seven_seg_2)
    );

    // seven segment module to drive a seven-segment module
	seven_seg sevseg(.s(switch), .seg(seg));

    // adder module to sum inputs from both switches
    input_sum adder(
        .s1(s1),
        .s2(s2),
        .sum(sum)
    );

endmodule