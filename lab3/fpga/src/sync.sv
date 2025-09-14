// author: Matthew Molinar
// email: mmolinar@hmc.edu
// date created: 09/13/2025

// Lab 3: Keypad Scanner
// This module is a synchronizer
// made from two flip-flops

module sync(
    input logic clk,
    input logic d,
    output logic q);

    logic n1;

    always_ff @(posedge clk)
    begin
        n1 <= d;
        q <= n1;
    end 
endmodule