// author: Matthew Molinar
// email: mmolinar@hmc.edu
// date created: 10/26/2025

// sub_bytes.sv

/////////////////////////////////////////////
// sub bytes
// s box transformation for all states
// NIST FIPS 197 section 5.1.1
/////////////////////////////////////////////

module sub_bytes(input  logic         clk,
                 input  logic [127:0] a,
                 output logic [127:0] y);

  // generate block to create 16 instances of sbox_sync

  genvar i;
  generate
    for (i = 0; i < 16; i = i + 1) begin : sbox_gen_loop
      sbox_sync sbox_inst (
        .clk(clk),
        .a(a[i*8 + 7 : i*8]),
        .y(y[i*8 + 7 : i*8])
      );
    end
  endgenerate

endmodule