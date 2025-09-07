// author: Matthew Molinar
// email: mmolinar@hmc.edu
// date created: 09/06/2025

// test bench for summing the switch inputs

`timescale 1ps/1ps

module input_sum_tb();

    logic clk, reset; // 'clk' & 'reset' are common names for the clock and reset

    logic [3:0] s1;
    logic [3:0] s2;
    logic [4:0] sum, sum_expected;
    logic [31:0] vectornum, errors;

    logic [3:0] x;    // logic holding value for s1
    logic [3:0] y;    // logic holding value for s2
    logic done;       // logic keep track of when all test cases are exhausted

    input_sum dut(
        .s1(s1),
        .s2(s2),
        .sum(sum)
    );

    // Generate clock: 10 time units period (5 high, 5 low)
    always begin
        clk = 1; #5;
        clk = 0; #5;
    end

    // Start of test
    initial begin
        vectornum = 0;
        errors = 0;
        reset = 1; #22;
        reset = 0;
        x = 0;
        y = 0;
    end

    // Apply test vectors on rising edge of clk
    always @(posedge clk) begin
        // Apply testvectors 1 time unit after rising edge to avoid data changes concurrently with the clock
        #1;

        // set values for test case
        s1 = x;
        s2 = y;
        sum_expected = x + y;
		
    end

    // Check results on falling edge of clk
    always @(negedge clk) begin
        if (~reset) begin
            // Detect error by checking if outputs from DUT match expectation
            if (sum !== sum_expected) begin
                $display("Error: inputs = %b", {s1, s2});
                $display(" outputs = %b (%b expected)", sum, sum_expected);
                // Increment the count of errors
                errors = errors + 1;
            end

            // Update values for next test case
            if (y == 15) begin
                y = 0;
                if (x == 15) begin
                    done = 1; // All test cases exhausted
                    $display("All test cases completed with %d errors", errors);
                    $stop;
                end else begin
                    x = x + 1;
                end
            end else begin
                y = y + 1;
            end
        end
    end

endmodule