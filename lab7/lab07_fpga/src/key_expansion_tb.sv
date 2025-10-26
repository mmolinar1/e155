// author: Matthew Molinar
// email: mmolinar@hmc.edu
// date created: 10/26/2025

// test bench for key expansion module, which
// which does the key expansion according to aes-128


`timescale 1ps/1ps

module key_expansion_tb();

    logic clk, rest, load, key_expansion_done;
    logic [127:0] key, current_round_key;
    logic [3:0]   round_count;
    
    key_expansion dut(
        .clk(clk), .reset(reset), .start(load), 
        .init_key(key), .round_number(round_count), 
        .round_key(current_round_key), .done(key_expansion_done)
    );

    // Start of test
    initial begin
        // Initialize inputs

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