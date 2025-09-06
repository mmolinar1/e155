// author: Matthew Molinar
// email: mmolinar@hmc.edu
// date created: 09/05/2025

// modules to sum both switch inputs

module input_sum(
	input logic [3:0] s1,    // switches for display 1
    input logic [3:0] s2,    // switches for display 2, 
    output logic [4:0] sum    
);

    sum = s1 + s2

endmodule