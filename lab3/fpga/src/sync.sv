// author: Matthew Molinar
// email: mmolinar@hmc.edu
// date created: 09/13/2025

// Lab 3: Keypad Scanner
// This module is a synchronizer
// made from two flip-flops
// this is adopted from Prof. Brake's
// lecture slides

module sync(
    input logic clk,
    input logic [3:0] d,
    output logic [3:0] q);

    logic [3:0] n1;

    always_ff @(posedge clk)
    begin
        n1 <= d;
        q <= n1;
    end 
endmodule