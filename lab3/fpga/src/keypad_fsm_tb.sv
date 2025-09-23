// author: Matthew Molinar
// email: mmolinar@hmc.edu
// date created: 09/14/2025

// test bench for key_pad_fsm module, which holds
// the FSM logic driving the dual 
// seven_segment display

`timescale 1ns/1ns

module keypad_fsm_tb();

    logic clk, reset;
    logic [3:0] key_synced, col, digit;
    logic valid_key;
    logic [31:0] errors;

    keypad_fsm dut(
        .clk(clk), .reset(reset),
        .key_synced(key_synced), .col(col), .digit(digit),
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
        key_synced = 4'b0000;
        errors = 0;
        
        reset = 0; #22;
        reset = 1;

        // testing IDLE state after reset
        #20;
        assert(dut.state == dut.IDLE) else begin
            $error("Not in IDLE state after reset"); 
            errors++;
        end

        // testing IDLE to DEBOUNCE
        key_synced = 4'b0001; // key press
        #20;
        assert(dut.state == dut.DEBOUNCE) else begin
            $error("Did not transition to DEBOUNCE after key press"); 
            errors++;
        end

        // testing if stay in DEBOUNCE
        #20;
        if (dut.debounce_counter < dut.DEBOUNCE_DIVIDER) begin
            assert(dut.state == dut.DEBOUNCE) else begin
                $error("Didn't stay in DEBOUNCE");
                errors++;
            end
        end

        // testing DEBOUNCE to ROW
        while(!dut.count_done) begin
            #10;
        end
        #10; 
        assert(dut.state == dut.ROW) else begin
            $error("Did not go DEBOUNCE to ROW");
            errors++;
        end

        // testing ROW to DRIVE (key_synced should be 1)
        #10;
        assert(dut.state == dut.DRIVE) else begin
            $error("Did not go ROW to DRIVE");
            errors++;
        end

        // testing DRIVE to HOLD
        #10;
        assert(dut.state == dut.HOLD) else begin
            $error("Did not go DRIVE to HOLD");
            errors++;
        end

        // testing HOLD stays in HOLD while key is still pressed
        #50;
        assert(dut.state == dut.HOLD) else begin
            $error("Did not stay in HOLD while key is still being pressed");
            errors++;
        end

        // testing HOLD to IDLE when key is no longer pressed
        #10
        key_synced = 4'b0000;
        #30;

        assert(dut.state == dut.IDLE) else begin
            $error("Did not got HOLD to IDLE once key is released");
            errors++;
        end

        // testing that valid_key is 1 in DRIVE and 0 after
        #10;
        key_synced = 4'b0010;
        #10;

        while (dut.state != dut.DRIVE) begin
            #10;
        end

        assert(valid_key == 1) else begin
            $error("valid_key is not 1 in DRIVE state");
            errors++;
        end

        // should be in HOLD state here
        #10;
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