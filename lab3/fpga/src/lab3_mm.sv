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
	input logic [3:0] s1,    // switches for display 1
    input logic [3:0] s2,    // switches for display 2, 
	output logic [6:0] seg,
    output logic seven_seg_1,
    output logic seven_seg_2
    );

    logic int_osc;
    logic d;
    logic d_mid;
    logic q;
    logic seven_seg_en;   // seven-segment enable
    logic [3:0] key;   // key input that will be used
    logic [19:0] debounce_counter;
    logic key_press;
    parameter DEBOUNCE_DIVIDER = 20'd0;

    // Internal high-speed oscillator
	HSOSC hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));

    lab2_mm dual_seven_seg(
        .clk(clk), .reset(reset),
        .int_osc(int_osc), .digit(digit)
        .seg(seg), .seven_seg_1(seven_seg_1),
        .seven_seg_2(seven_seg_2)
    );

    // synchronizer
    always_ff @(posedge clk)
        begin
            d_mid <= d;
            q <= d_mid;
        end

    // checking all rows
    always_ff @(posedge clk)
        if (reset) begin
            row <= 4'b0001;
        end else if (state == IDLE1) begin
            // Rotate active row
            if (row == 4'b0001) row <= 4'b0010;
            if (row == 4'b0010) row <= 4'b0100;
            if (row == 4'b0100) row <= 4'b1000;
            if (row == 4'b1000) row <= 4'b0001;
        end
        
    // debounce counter
    always_ff @(posedge clk)
        if (reset || state != DEBOUNCE) debounce_counter <= 20'd0;
        else if (state == DEBOUNCE && debounce_counter < DEBOUNCE_DIVIDER)
            debounce_counter <= debounce_counter + 1'b1;
            
    // Key press detection
    assign key_press = |col;

endmodule