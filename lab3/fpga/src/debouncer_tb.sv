// author: Matthew Molinar
// email: mmolinar@hmc.edu
// date created: 09/14/2025

// test bench for debouncer module, which debounces
// input signals from a key press on a keypad

`timescale 1ps/1ps

module debouncer_tb();

    logic clk, reset;
    logic reset_count;
    logic count_done;
    logic [21:0] debounce_counter;
    logic [31:0] errors;

    // using a smaller divider so that the simulation doesn't take as long
    parameter TEST_DEBOUNCE_DIVIDER = 22'd50;  

    debouncer #(.DEBOUNCE_DIVIDER(TEST_DEBOUNCE_DIVIDER)) dut(
        .clk(clk), .reset(reset),
        .reset_count(reset_count), .count_done(count_done),
        .debounce_counter(debounce_counter)
    );

    // Generate clock: 10 time units period (5 high, 5 low)
    always begin
        clk = 1; #5;
        clk = 0; #5;
    end

    // Start of test
    initial begin
        // Initialize inputs
        reset_count = 0;
        errors = 0;

        reset = 1; #22;
        reset = 0;
        
        // should be set to 1 after reaching the divider val
        // wait for more than a full debounce period
        #((TEST_DEBOUNCE_DIVIDER) * 10); // 10 time unit period
        assert (count_done === 1) else begin
            $error("count_done is not 1 after counting up"); 
            errors++;
        end

        // count_done should be 0 on the next cycle
        #10;
        assert (count_done === 0) else begin
            $error("count_done is not 0 a clk cycle after finishing the count"); 
            errors++;
        end

        // testing reset_count
        #50;
        reset_count = 1; #10;

        assert (debounce_counter === 0) else begin
            $error("debounce counter did not reset properly"); 
            errors++;
        end

        reset_count = 0; #10;
        
        assert (debounce_counter !== 0) else begin
            $error("debounce counter did begin counting after reset"); 
            errors++;
        end

        // testing reset
        reset = 1; #22;
        reset = 0;

        assert (debounce_counter === 0 && count_done === 0) else begin
            $error("debounce_counter or count_done did not reset to 0");
            errors++;
        end
        
        // stop the simulation
        $display("Tests completed ");
        $stop;
    end
endmodule