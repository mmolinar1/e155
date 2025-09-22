// author: Matthew Molinar
// email: mmolinar@hmc.edu
// date created: 09/15/2025

// test bench for the lab3_mm top module, which holds
// all other sub-modules. lab3_mm scans inputs from a
// keypad and displays inputs on a
// dual seven-segment display - the most
// recent entry appears on the right

`timescale 1ns/1ns

module lab3_mm_tb();

    logic clk, reset;
	tri [3:0] row, col;
	logic [6:0] seg;
    logic seven_seg_1, seven_seg_2;

    logic [3:0][3:0] keys;
    logic [3:0] expected_digit1, expected_digit2;

    lab3_mm dut(
        .reset(reset),
        .row(row), .col(col),
        .seg(seg), .seven_seg_1(seven_seg_1),
        .seven_seg_2(seven_seg_2)
    );

    // ensures rows = 4'b1111 when no key is pressed
    pulldown(row[0]);
    pulldown(row[1]);
    pulldown(row[2]);
    pulldown(row[3]);

    // keypad model using tranif
    genvar r, c;
    generate
        for (r = 0; r < 4; r++) begin : row_loop
            for (c = 0; c < 4; c++) begin : col_loop
                // when keys[r][c] == 1, connect cols[c] <-> rows[r]
                tranif1 key_switch(row[r], col[c], keys[r][c]);
            end
        end
    endgenerate

    // task to check expected values for the digits
    task check_key(input [3:0] expected_digit1, expected_digit2, string msg);
        #1500;
        
        assert (dut.digit1 == expected_digit1 && dut.digit2 == expected_digit2)
            $display("PASSED!: %s -- got digit1=%h digit2=%h expected digit1=%h digit2=%h at time %0t.", 
                    msg, dut.digit1, dut.digit2, expected_digit1, expected_digit2, $time);
        else
            $error("FAILED!: %s -- got digit1=%h digit2=%h expected digit1=%h digit2=%h at time %0t.", 
                   msg, dut.digit1, dut.digit2, expected_digit1, expected_digit2, $time);
            
        #50;
    endtask

    // Start of test
    initial begin
        // Initialize inputs
        reset = 0;

        keys = '{default:0};

        #22; reset = 1;
        
        // press key at row=1, col=2
        #50; keys[1][2] = 1;
        check_key(4'h0, 4'h6, "First key press");

        // release button
        keys[1][2] = 0;
        #50;

        // press another key at row=0, col=0
        keys[2][3] = 1;
        check_key(4'h6, 4'hc, "Second key press");

        // release buttons
        #100; keys = '{default:0};

        #100; $stop;
        $display("Tests completed");
        $stop;
    end
endmodule