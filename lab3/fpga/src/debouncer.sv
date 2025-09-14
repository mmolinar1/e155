// author: Matthew Molinar
// email: mmolinar@hmc.edu
// date created: 09/13/2025

// Lab 3: Keypad Scanner
// This module debounces the signal
// from the keypad, which experiences
// bouncing


module debouncer (
    input logic clk, reset,
    input logic s_in,
    output logic s_out,
	output logic [21:0] debounce_counter
);

    logic stable;
    parameter DEBOUNCE_DIVIDER = 22'd2400000;
    
    always_ff @(posedge clk)
        if (reset) begin
            debounce_counter <= 0;
            stable <= 0;
        end else if (s_in != stable) begin
            if (debounce_counter == DEBOUNCE_DIVIDER) begin
                stable <= s_in;
                debounce_counter <= 0;
            end else debounce_counter <= debounce_counter + 1;
        end else debounce_counter <= 0;
    
    assign s_out = stable;
endmodule