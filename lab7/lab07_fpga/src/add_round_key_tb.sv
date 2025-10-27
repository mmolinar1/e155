// author: Matthew Molinar
// email: mmolinar@hmc.edu
// date created: 10/25/2025

// test bench for add round key module, which
// is a bitwise XOR

`timescale 1ps/1ps

module add_round_key_tb();

    logic [127:0] state_in, round_key, state_out;

    add_round_key dut(
        .state_in(state_in),
        .round_key(round_key),
        .state_out(state_out)
    );

    // Start of test
    
    // inputs and outputs are based on
    // the cipher example in Appendix B

    initial begin
        logic [127:0] expected_state_out = 128'h193de3bea0f4e22b9ac68d2ae9f84808;

        // Initialize inputs
        state_in = 128'h3243f6a8885a308d313198a2e0370734;
        round_key = 128'h2b7e151628aed2a6abf7158809cf4f3c;
        
        #10;

        // Check if output matches the expected result
        if (state_out === expected_state_out) begin
            $display("Test passed");
        end else begin
            $display("Test failed");
        end

        // stop the simulation
        $display("Tests completed");
        $stop;
    end

endmodule