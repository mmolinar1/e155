// author: Matthew Molinar
// email: mmolinar@hmc.edu
// date created: 09/13/2025

// Lab 3: Keypad Scanner
// This module debounces the signal
// from the keypad, which experiences
// bouncing due to its physical
// nature


module debouncer #(
    parameter DEBOUNCE_DIVIDER = 22'd48000
)(
    input logic clk, reset,
    input logic reset_count,
    output logic count_done,
    output logic [21:0] debounce_counter
);
    
    always_ff @(posedge clk)
        if (~reset) begin
            debounce_counter <= 0;
            count_done <= 0;
        end else if (reset_count) begin
            debounce_counter <= 0;
        end else if (debounce_counter >= DEBOUNCE_DIVIDER - 1) begin
            count_done<= 1;
            debounce_counter <= 0;
        end else begin 
            count_done <= 0;
            debounce_counter <= debounce_counter + 1'b1;
        end

endmodule