// author: Matthew Molinar
// email: mmolinar@hmc.edu
// date created: 09/14/2025

// test bench for key_pad_fsm module, which holds
// the FSM logic driving the dual 
// seven_segment display

`timescale 1ps/1ps

module keypad_fsm_tb();

    logic clk, reset;
    logic [3:0] row, col, digit;
    logic valid_key;
    logic [31:0] errors;

    keypad_fsm dut(
        .clk(clk), .reset(reset),
        .row(row), .col(col), .digit(digit),
        .valid_key(valid_key)
    );

    // Generate clock: 10 time units period (5 high, 5 low)
    always begin
        clk = 1; #5;
        clk = 0; #5;
    end

    // Start of test
    initial begin
        // Initialize inputs
        row = 0;
        errors = 0;
        
        reset = 1; #22;
        reset = 0;

        // testing IDLE state after reset
        #20;
        assert(dut.state == dut.IDLE) else begin
            $error("Not in IDLE state after reset"); 
            errors++;
        end

        // testing IDLE > DEBOUNCE
        row = 4'b0001; // key press
        #50;

        assert(dut.state == dut.DEBOUNCE) else begin
            $error("Did not transition to DEBOUNCE state after key press"); 
            errors++;
        end

        // testing DEBOUNCE stays in DEBOUNCE before it reaches its desired value
        // each cycle is 10 ps, and DEBOUNCE_DIVIDER is 100 for sim
        #2000;

        if (dut.debounce_counter < dut.DEBOUNCE_DIVIDER) begin
            assert(dut.state == dut.DEBOUNCE) else begin
            $error("Did not stay in DEBOUNCE while counter < divider");
            errors++;
            end
        end

        // testing DEBOUNCE > SYNC
        // wait for counter to reach divider value
        while (dut.debounce_counter < dut.DEBOUNCE_DIVIDER) #10;
        #100;
        assert(dut.state == dut.SYNC) else begin
            $error("Did not go to SYNC after DEBOUNCE");
            errors++;
        end

        // testing SYNC > ROW (key_synced should be 1)
        #50;
        assert(dut.state == dut.ROW) else begin
            $error("Did not go SYNC > ROW");
            errors++;
        end

        // testing ROW > DRIVE (key_synced should be 1)
        #50;
        assert(dut.state == dut.DRIVE) else begin
            $error("Did not go ROW > DRIVE");
            errors++;
        end

        // testing DRIVE > HOLD
        #50;
        assert(dut.state == dut.HOLD) else begin
            $error("Did not go DRIVE > HOLD");
            errors++;
        end

        // testing HOLD stays in HOLD while key is still pressed
        #50;
        assert(dut.state == dut.HOLD) else begin
            $error("Did not stay in HOLD while key is still being pressed");
            errors++;
        end

        // testing HOLD > IDLE when key is no longer pressed
        #10;
        row = 4'b0000;
        #20;
        assert(dut.state == dut.IDLE) else begin
            $error("Did not got HOLD > IDLE once key is released");
            errors++;
        end

        // testing that valid_key is 1 in DRIVE and 0 after

        #50;
        row = 4'b0010;

        while (dut.state != dut.DRIVE) #10;

        assert(valid_key == 1) else begin
            $error("valid_key is not 1 in DRIVE state");
            errors++;
        end

        #50;
        // should be in HOLD state here
        assert(dut.state == dut.HOLD && valid_key == 0) else begin
            $error("valid_key is 1 in HOLD or we didn't reach the HOLD state after DRIVE");
            errors++;
        end

        // stop the simulation
        if (errors == 0)
            $display("All tests passed");
        else
            $display("%d tests failed", errors);

        $display("Tests completed ");
        $stop;
    end
endmodule