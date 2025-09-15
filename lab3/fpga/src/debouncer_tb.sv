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

    // using a smaller divider so that the simulation doesn't take as long
    parameter TEST_DEBOUNCE_DIVIDER = 22'd100;  

    debouncer #(.DEBOUNCE_DIVIDER(TEST_DEBOUNCE_DIVIDER)) dut(
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
        
        // first test - simulating key bouncing
        s_in = 1; #15;
        s_in = 0; #15;
        s_in = 1; #15;
        s_in = 0; #15;
        s_in = 1; // Final state is high
        
        // should still be low until debounce completes
        assert (s_out !== 0) else begin
            $error("s_out changed during bouncing"); 
            errors++;
        end
        
        // wait for the full debounce period
        #((TEST_DEBOUNCE_DIVIDER + 10) * 10); // 10 time unit period
        
        assert (s_out == 1) else begin
            $error"s_out should be 1 after debounce period");
            errors++;
        end

        // second test - checking reset
        // set input high and wait
        s_in = 1;
        #((TEST_DEBOUNCE_DIVIDER + 10) * 10);
        
        // apply reset
        reset = 1; #20;
        
        // check that output returns to 0 after reset
        assert(s_out === 0) else begin
            $error("s_out not properly reset (s_out = %b)", s_out);
            errors++;
        end
        
        // stop the simulation
        $display("Tests completed ");
        $stop;
    end
endmodule