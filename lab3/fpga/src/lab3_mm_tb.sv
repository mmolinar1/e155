// author: Matthew Molinar
// email: mmolinar@hmc.edu
// date created: 09/15/2025

// test bench for the lab3_mm top module, which holds
// all other sub-modules. lab3_mm scans inputs from a
// keypad and displays inputs on a
// dual seven-segment display - the most
// recent entry appears on the right

`timescale 1ps/1ps

module lab3_mm_tb();

    logic clk, reset;
	logic [3:0] row, col;
	logic [6:0] seg;
    logic seven_seg_1, seven_seg_2;
    logic [31:0] errors;

    lab3_mm dut(
        .reset(reset),
        .row(row), .col(col),
        .seg(seg), .seven_seg_1(seven_seg_1),
        .seven_seg_2(seven_seg_2)
    );

    logic int_osc_clk = dut.int_osc;

    // Generate clock: 10 time units period (5 high, 5 low)
    always begin
        clk = 1; #5;
        clk = 0; #5;
    end

    // Start of test
    initial begin
        // Initialize inputs
        row = 4'b0000;
        errors = 0;
        
        reset = 1; #22;
        reset = 0;

        // test first key press with "pressing" the number 1 : row 0, col 0
        row = 4'b0001;
        wait(dut.col == 4'b0001); // waiting for 1st col check

        wait(dut.valid_key);
        #20;
        wait(!dut.valid_key); // once valid_key is 0, it means that we're in the hold state

        // testing that digit 2 is holding the value 1
        assert(dut.digit2 == 4'b0001) else begin
            $error("Digit 2 is not 1");
            errors++;
        end

        // testing that digit 1 is still 0
        assert(dut.digit1 == 4'b0000) else begin
            $error("Digit 1 is not 0");
            errors++;
        end

        // release key and make sure it goes to other display after new key-press
        row = 4'b0000;
        #100;

        // test second key press with "pressing" the number 5 : row 1, col 1
        row = 4'b0010; // row 1
        wait(dut.col == 4'b0010); // col 1

        wait(dut.valid_key);
        #20;
        wait(!dut.valid_key) // once valid_key is 0, it means that we're in the hold state

        // testing that digit 1 is now 1
        assert(dut.digit1 == 4'b0001) else begin
            $error("Digit 1 is not 1");
            errors++;
        end

        // testing that digit 2 is now 5
        assert(dut.digit1 == 4'b0101) else begin
            $error("Digit 2 is not 5");
            errors++;
        end

        // release key
        row = 4'b0000;
        #100;

        //testing display mux
        if (dut.seven_seg_en == 1) begin
            assert(dut.dsiplay_digit == dut.digit2) else begin
                $error("when seven_seg_en is high, display_digit should be digit2");
                errors++;
            end 
        end else if (dut.seven_seg_en == 0) begin
            assert(dut.dsiplay_digit == dut.digitq) else begin
                $error("when seven_seg_en is low, display_digit should be digit1");
                errors++;
            end
        end

        // wait a long time to see int_osc toggle
        #10000;

        // stop the simulation
        if (errors == 0)
            $display("All tests passed");
        else
            $display("%d tests failed", errors);

        $display("Tests completed ");
        $stop;
    end
endmodule