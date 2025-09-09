// author: Matthew Molinar
// email: mmolinar@hmc.edu
// date created: 09/05/2025

// Lab 2: Multiplexed 7-Segment Display
// This module is a not gate that
// picks between which of the two
// seven_segment diplays to power on

module display_gate(
    input logic seven_seg_en,
    output logic seven_seg_1,
    output logic seven_seg_2
);

    // pick between seven_segment diplays
    assign seven_seg_1 = ~seven_seg_en;
    assign seven_seg_2 = seven_seg_en;

endmodule