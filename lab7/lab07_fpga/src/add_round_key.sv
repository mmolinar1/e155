// author: Matthew Molinar
// email: mmolinar@hmc.edu
// date created: 10/24/2025

// add_round_key.sv

/////////////////////////////////////////////
// add_round_key
// state and round key are combined by applying
// a bitwise XOR
// NIST FIPS 197 section 5.1.4
/////////////////////////////////////////////

module add_round_key(input  logic [127:0] state_in,
                     input logic [127:0] round_key,
                     output logic [127:0] state_out);

    assign state_out = state_in ^ round_in;

endmodule