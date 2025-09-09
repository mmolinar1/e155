// author: Matthew Molinar
// email: mmolinar@hmc.edu
// date created: 09/05/2025

// Lab 2: Multiplexed 7-Segment Display
// This module computes the sum of both
// switch inputs and outputs the sum
// as a 5-bit binary number

module input_sum(
	input logic [3:0] s1,    // switches for display 1
    input logic [3:0] s2,    // switches for display 2, 
    output logic [4:0] sum    
);

    assign sum = s1 + s2;

endmodule