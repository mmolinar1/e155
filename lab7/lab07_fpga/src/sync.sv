// author: Matthew Molinar
// email: mmolinar@hmc.edu
// date created: 09/13/2025

// synchronizer module

module sync(
    input logic old_clk,
    input logic new_clk,
    input logic d,
    output logic q);

    logic n1;

    always_ff @(posedge new_clk) begin
        n1 <= d;
        q <= n1;
    end 
endmodule
