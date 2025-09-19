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

        #20;
        assert (q == 0) else begin
            $error("q didn't start at 0");
            errors++;
        end
        
        // first test - testing with an asynchronous input
        #2;
        d = 1;

        // at 1st clock edge, first ff captures d, but q doesn't
        @(posedge clk);
        #1;
        assert (q == 0) else begin
            $error("q changed after first clock cycle");
            errors++;
        end
        
        // at 2nd clock edge, q should now be 1
        @(posedge clk);
        #1;
        assert (q == 1) else begin
            $error("q didn't update after two clock cycles");
            errors++;
        end

        // second test - testing with an asynchronous input, but now doing the inverse
        #2;
        d = 0;

        // at 1st clock edge, first ff captures d, but q doesn't
        @(posedge clk);
        #1;
        assert (q == 1) else begin
            $error("q changed after first clock cycle");
            errors++;
        end
        
        // at 2nd clock edge, q should now be 1
        @(posedge clk);
        #1;
        assert (q == 0) else begin
            $error("q didn't update after two clock cycles");
            errors++;
        end

        // stop the simulation
        $display("Tests completed ");
        $stop;
    end
endmodule