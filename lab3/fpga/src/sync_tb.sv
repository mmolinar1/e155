// author: Matthew Molinar
// email: mmolinar@hmc.edu
// date created: 09/14/2025

// test bench for sync module, which is
// a synchronizer for asynchronous inputs

`timescale 1ps/1ps

module sync_tb();

    logic clk; 
    logic d, q; 
    logic [31:0] errors;

    sync dut(
        .clk(clk),
        .d(d),
        .q(q)
    );

    // Generate clock: 10 time units period (5 high, 5 low)
    always begin
        clk = 1; #5;
        clk = 0; #5;
    end

    // Start of test
    initial begin
        // Initialize inputs
        d = 0;
        errors = 0;
        
        // testing with an asynchronous input
        #2;

        d = 1; #20; // two clk cycles

        // should still be low until debounce completes
        assert (q == d) else begin
            $error("q didn't grab d's value"); 
            errors++;
        end

        // stop the simulation
        $display("Tests completed ");
        $stop;
    end
endmodule