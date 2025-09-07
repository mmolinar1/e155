// author: Matthew Molinar
// email: mmolinar@hmc.edu
// date created: 09/06/2025

// test bench for switch mux which determines which switch to use as an input

`timescale 1ps/1ps

module switch_mux_tb();

    logic clk, reset; // 'clk' & 'reset' are common names for the clock and reset

    logic [3:0] s1, s2 ;    // switches for displays 1 + 2
    logic seven_seg_en;    // seven-segment enable
    logic [3:0] switch, switch_expected;
    logic [31:0] vectornum, errors;
    logic [12:0] testvectors[10000:0];
	
	logic [3:0] x;    // logic holding value for s1
    logic [3:0] y;    // logic holding value for s2
	logic z; 		  // logic to track seven_seg_en
    logic done;       // logic keep track of when all test cases are exhausted

    switch_mux dut(
        .s1(s1),
        .s2(s2),
        .seven_seg_en(seven_seg_en),
        .switch(switch)
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
		z = 0;
    end

    // Apply test vectors on rising edge of clk
    always @(posedge clk) begin
        // Apply testvectors 1 time unit after rising edge to avoid data changes concurrently with the clock
        #1;

        // set values for test case
        s1 = x;
        s2 = y;
		seven_seg_en = z;
        switch_expected = seven_seg_en ? s2 : s1;
    end

    // Check results on falling edge of clk
    always @(negedge clk) begin
        if (~reset) begin
            // Detect error by checking if outputs from DUT match expectation
            if (switch !== switch_expected) begin
                $display("Error: inputs = %b", {s1, s2, seven_seg_en});
                $display(" outputs = %b (%b expected)", switch, switch_expected);
                // Increment the count of errors
                errors = errors + 1;
            end

            // Update values for next test case
			z = ~z; // flip z to switch the enable
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