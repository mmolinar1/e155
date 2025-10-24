// author: Matthew Molinar
// email: mmolinar@hmc.edu
// date created: 10/24/2025

// test bench for shift rows module, which
// cyclically shifts rows according to aes-128


`timescale 1ps/1ps

module shift_rows_tb();

    logic [127:0] state_in, state_out;

    shift_rows dut(
        .state_in(state_in),
        .state_out(state_out)
    );

    // Start of test
    initial begin
        // Initialize inputs
        
        // Input state
        // 00 04 08 0C
        // 01 05 09 0D
        // 02 06 0A 0E
        // 03 07 0B 0F
        state_in = 128'h0F0E0D0C_0B0A0908_07060504_03020100;

        // Expected output after shift_rows
        // 00 04 08 0C
        // 05 09 0D 01
        // 0A 0E 02 06
        // 0F 03 07 0B
        logic [127:0] expected_state_out = 128'h0B06010C_07020D08_030E0904_0F0A0500;
        
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