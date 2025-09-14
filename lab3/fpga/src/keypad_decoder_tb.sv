// author: Matthew Molinar
// email: mmolinar@hmc.edu
// date created: 09/12/2025

// Lab 3: Keypad Scanner
// This module tests the keypad decoder
// module, which decodes switch inputs from
// the keypad

`timescale 1ps/1ps

module keypad_decoder_tb();

    logic clk, reset;
    logic [3:0] row, col;
    logic [3:0] digit, digit_expected;
    logic [31:0] vectornum, errors;
    logic [11:0] testvectors[10000:0];

    keypad_decoder dut(
        .row(row),
        .col(col),
        .digit(digit)
    );

    // Generate clock: 10 time units period (5 high, 5 low)
    always begin
        clk = 1; #5;
        clk = 0; #5;
    end

    // Start of test
    initial begin
        $readmemb("keypad_decoder_tb.tv", testvectors);
        vectornum = 0;
        errors = 0;
        reset = 1; #22;
        reset = 0;
    end

    // Apply test vectors on rising edge of clk
    always @(posedge clk) begin
        #1;
        {row, col, digit_expected} = testvectors[vectornum];
    end

    // Check results on falling edge of clk
    always @(negedge clk) begin
        if (~reset) begin
            // Detect error by checking if outputs from DUT match expectation
            if (digit !== digit_expected) begin
                $display("Error: inputs = %b", {row, col});
                $display(" outputs = %b (%b expected)", digit, digit_expected);
                // Increment the count of errors
                errors = errors + 1;
            end
            // Increment the count of vectors
            vectornum = vectornum + 1;
            // When the test vector becomes all 'x', the test is complete
            if (testvectors[vectornum] === 12'bx) begin
                $display("%d tests completed with %d errors", vectornum, errors);
                // Stop the simulation
                $stop;
            end
        end
    end

endmodule