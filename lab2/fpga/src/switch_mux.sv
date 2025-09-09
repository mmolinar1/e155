// author: Matthew Molinar
// email: mmolinar@hmc.edu
// date created: 09/05/2025

// Lab 2: Multiplexed 7-Segment Display
// This module is a mux that 
// picks between two 4-bit switch inputs
// and determines which input should be used
// to drive a seven_segment display based on
// the display that's enabled

module switch_mux(
	input logic [3:0] s1,        // switches for display 1
    input logic [3:0] s2,         // switches for display 2
    input logic seven_seg_en,    // seven-segment enable
    output logic [3:0] switch    // switch input that will be used
);
	    
    assign switch = seven_seg_en ? s2 : s1;

endmodule