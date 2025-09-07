// author: Matthew Molinar
// email: mmolinar@hmc.edu
// date created: 09/06/2025

// test bench for display gate module to ensure the proper
// seven segment displays are being driven

`timescale 1ps/1ps

module display_gate_tb();

    logic clk, reset; // 'clk' & 'reset' are common names for the clock and reset

    logic seven_seg_en;
    logic seven_seg_1, seven_seg_1_expected;
    logic seven_seg_2, seven_seg_2_expected;
    logic [31:0] vectornum, errors;
    logic [2:0] testvectors[10000:0];

    display_gate dut(
        .seven_seg_en(seven_seg_en),
        .seven_seg_1(seven_seg_1),
        .seven_seg_2(seven_seg_2)
    );

    // Generate clock: 10 time units period (5 high, 5 low)
    always begin
        clk = 1; #5;
        clk = 0; #5;
    end

    // Start of test
    initial begin
        $readmemb("display_gate_tb.tv", testvectors);
        vectornum = 0;
        errors = 0;
        reset = 1; #22;
        reset = 0;
    end

    // Apply test vectors on rising edge of clk
    always @(posedge clk) begin
        // Apply testvectors 1 time unit after rising edge to avoid data changes concurrently with the clock
        #1;
        {seven_seg_en, seven_seg_1_expected, seven_seg_2_expected} = testvectors[vectornum];
    end

    // Check results on falling edge of clk
    always @(negedge clk) begin
        if (~reset) begin
            // Detect error by checking if outputs from DUT match expectation
            if (seven_seg_1 !== seven_seg_1_expected || seven_seg_2 !== seven_seg_2_expected) begin
                $display("Error: inputs = %b", {seven_seg_en});
                $display(" outputs = %b (%b expected)", seven_seg_1, seven_seg_1_expected,
                seven_seg_2, seven_seg_2_expected);
                // Increment the count of errors
                errors = errors + 1;
            end
            // Increment the count of vectors
            vectornum = vectornum + 1;
            // When the test vector becomes all 'x', the test is complete
            if (testvectors[vectornum] === 3'bx) begin
                $display("%d tests completed with %d errors", vectornum, errors);
                // Stop the simulation
                $stop;
            end
        end
    end

endmodule