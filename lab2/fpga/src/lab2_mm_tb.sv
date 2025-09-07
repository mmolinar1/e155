// author: Matthew Molinar
// email: mmolinar@hmc.edu
// date created: 09/06/2025

// test bench for lab 2 top module, which drives
// two seven segment displays via time multiplexing
// the switch inputs for these displays are added, such
// that the sum is displayed on other LEDs

`timescale 1ps/1ps

module lab2_mm_tb();

    logic clk, reset; // 'clk' & 'reset' are common names for the clock and reset
    logic [3:0] s1, s2 ;    // switches for displays 1 + 2
    logic [6:0] seg;
    logic seven_seg_1, seven_seg_2;
    logic [31:0] errors;

    top dut(
        .clk(clk),
        .reset(reset),
        .s1(s1),
        .s2(s2),
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
        // Initialize switch inputs
        s1 = 0;
        s2 = 0;
        errors = 0;

        reset = 1; #22;
        reset = 0;
        
        // first test
        
        // Set inputs
        s1 = 4'b0011; // 3
        s2 = 4'b0101; // 5
        
        // wait for the counter to toggle seven_seg_en
        // first check display 1
        wait(seven_seg_1 == 1'b1);
        #10;
        
        if (seg !== 7'b0110000 || seven_seg_1 !== 1'b1 || seven_seg_2 !== 1'b0) begin
            $display("First test failed");
            $display("  seg=%b, expected=%b, seven_seg_1=%b, seven_seg_2=%b", 
                     seg, 7'b0110000, seven_seg_1, seven_seg_2);
            errors = errors + 1;
        end
        
        // check display 2
        wait(seven_seg_2 == 1'b1);
        #10;
        
        if (seg !== 7'b0010010 || seven_seg_2 !== 1'b1 || seven_seg_1 !== 1'b0) begin
            $display("First test failed");
            $display("  seg=%b, expected=%b, seven_seg_1=%b, seven_seg_2=%b", 
                     seg, 7'b0010010, seven_seg_1, seven_seg_2);
            errors = errors + 1;
        end
        
        // second test
        
        // set both inputs to max
        s1 = 4'b1111; // 15
        s2 = 4'b1111; // 15
        
        // check display 1
        wait(seven_seg_1 == 1'b1);
        #10;
        
        if (seg !== 7'b0001110 || seven_seg_1 !== 1'b1) begin
            $display("Second test failed");
            $display("  seg=%b, expected=%b", seg, 7'b0001110);
            errors = errors + 1;
        end
        
        // check display 2
        wait(seven_seg_2 == 1'b1);
        #10;
        
        if (seg !== 7'b0001110 || seven_seg_2 !== 1'b1) begin
            $display("Second test failed");
            $display("  seg=%b, expected=%b", seg, 7'b0001110);
            errors = errors + 1;
        end
        
        // third test
        
        s1 = 4'b1010; // 10
        s2 = 4'b0111; // 7
        // Sum should be 17 (5'b10001)
        
        // Check display 1
        wait(seven_seg_1 == 1'b1);
        #10;
        
        if (seg !== 7'b0001000 || seven_seg_1 !== 1'b1) begin
            $display("Third test failed");
            $display("  seg=%b, expected=%b", seg, 7'b0001000);
            errors = errors + 1;
        end
        
        // Check display 2
        wait(seven_seg_2 == 1'b1);
        #10;
        
        if (seg !== 7'b1111000 || seven_seg_2 !== 1'b1) begin
            $display("Third test failed");
            $display("  seg=%b, expected=%b", seg, 7'b1111000);
            errors = errors + 1;
        end
        $display("Tests completed ");
        // stop the simulation.
        $stop;
    end
endmodule