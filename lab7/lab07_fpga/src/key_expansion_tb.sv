// author: Matthew Molinar
// email: mmolinar@hmc.edu
// date created: 10/26/2025

// test bench for key expansion module, which
// which does the key expansion according to aes-128

`timescale 1ps/1ps

module key_expansion_tb();

    logic clk, rest, load, key_expansion_done;
    logic [127:0] init_key, current_round_key;
    logic [3:0]   round_number;
    logic [127:0] expected_key;

    key_expansion dut(
        .clk(clk), .reset(reset), .start(load), 
        .init_key(init_key), .round_number(round_number), 
        .round_key(current_round_key), .done(key_expansion_done)
    );

    // Generate clock: 10 time units period (5 high, 5 low)
    always begin
        clk = 1; #5;
        clk = 0; #5;
    end

    // Start of test (referencing NIST FIPS 197 Appendix A.1)
    initial begin
        // Initialize inputs
        clk = 0;
        reset = 1;
        start = 0;
        init_key = 128'h2b7e151628aed2a6abf7158809cf4f3c;
        round_number = 0;

        // Testing reset
        reset = 0;
        #10;
        reset = 1;
        #10;

        // Starting key expansion
        start = 1;
        #10;
        start = 0;

        // Wait for key expansion to finish
        wait(key_expansion_done);

        integer error_count = 0;
        
        for (int i = 0; i <= 3; i = i + 1) begin
            round_number = i;

            case (i)
                0:  expected_key = 128'h2b7e151628aed2a6abf7158809cf4f3c;  // [w0, w1, w2, w3]
                1:  expected_key = 128'ha0fafe1788542cb123a339392a6c7605;  // [w4, w5, w6, w7]
                2:  expected_key = 128'hf2c295f27a96b9435935807a7359f67f;  // [w8, w9, w10, w11]
                default: expected_key = 128'h0;
            endcase
        
        #1;

        if (current_round_key != expected_key) begin
            error_count = error_count + 1;
        end

        // Check if output matches the expected result
        if (error_count == 0) begin
            $display("All tests passed");
        end else begin
            $display("Tests failed");
        end

        // stop the simulation
        $display("Tests completed");
        $stop;
    end

endmodule