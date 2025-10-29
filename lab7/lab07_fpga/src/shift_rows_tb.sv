// author: Matthew Molinar
// email: mmolinar@hmc.edu
// date created: 10/24/2025

// test bench for shift rows module, which
// cyclically shifts rows according to aes-128


`timescale 1ps/1ps

module shift_rows_tb();

    logic [127:0] state_in, state_out, expected_state_out;

    shift_rows dut(
        .state_in(state_in),
        .state_out(state_out)
    );

    // Start of test
    initial begin
        //waveform dumping
        $dumpfile("shift_rows.vcd");
        $dumpvars(0, shift_rows_tb);

        // based on appendix b in NIST FIPS 197
        // Expected output after shift_rows
        expected_state_out = 128'hd4bf5d30_e0b452ae_b84111f1_1e2798e5;

        // Initialize inputs
        state_in = 128'hd42711ae_e0bf98f1_b8b45de5_1e415230;
        
        #10;

        // Check if output matches the expected result
        if (state_out === expected_state_out) begin
            $display("Test passed");
        end else begin
            $display("Test failed");
        end

        // stop the simulation
        $display("Tests completed");
        $finish;
    end

endmodule