// author: Matthew Molinar
// email: mmolinar@hmc.edu
// date created: 09/14/2025

// test bench for debouncer module, which debounces
// input signals from a key press on a keypad

`timescale 1ps/1ps

module debouncer_tb();

    logic clk, reset; 
    logic s_in, s_out; 
    logic debounce_counter;
    logic [31:0] errors;

    debouncer dut(
        .clk(clk), .reset(reset),
        .s_in(s_in), .s_out(s_out),
        .debounce_counter(debounce_counter)
    );

    // Generate clock: 10 time units period (5 high, 5 low)
    always begin
        clk = 1; #5;
        clk = 0; #5;
    end

    // Start of test
    initial begin
        // Initialize inputs
        s_in = 0;
        errors = 0;

        reset = 1; #22;
        reset = 0;
        
        // first test (debounce divider is 2,400,000)
        // Set inputs
        s_in = 1;    
        
        $display("Tests completed ");
        // stop the simulation.
        $stop;
    end
endmodule