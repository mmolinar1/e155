// author: Matthew Molinar
// email: mmolinar@hmc.edu
// date created: 09/05/2025

// mux to pick between switch inputs

module switch_mux(
	input logic [3:0] s1,        // switches for display 1
    input logic [3:0] s2,         // switches for display 2
    input logic seven_seg_en,    // seven-segment enable
    output logic [3:0] switch    // switch input that will be used
);
	    
    assign switch = seven_seg_en ? s2 : s1;

endmodule