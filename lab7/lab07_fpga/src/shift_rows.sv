// author: Matthew Molinar
// email: mmolinar@hmc.edu
// date created: 10/24/2025

// shift_rows.sv

/////////////////////////////////////////////
// shift_rows
//   Section 5.1.2
/////////////////////////////////////////////

module shift_rows(input  logic [127:0] state_in,  // 4x4 matrix of bytes
                  output logic [127:0] state_out);
            
  // first row remains unshifted, the rest are cyclically shifted
  // row 0 (0, 4, 8, 12)
  // row 1 (1, 5, 9, 13) - shift by 1
  // row 2 (2, 6, 10, 14) - shift by 2
  // row 3 (3, 7, 11, 15)- shift by 3

  // row 0
  assign state_out[7:0] = state_in[7:0];        // byte 0 > 0
  assign state_out[39:32] = state_in[39:32];    // byte 4 > 4
  assign state_out[71:64] = state_in[71:64];    // byte 8 > 8
  assign state_out[103:96] = state_in[103:96];  // byte 12 > 12

  // row 1
  assign state_out[15:8] = state_in[47:40];     // byte 1 > 5
  assign state_out[47:40] = state_in[79:72];    // byte 5 > 9
  assign state_out[79:72] = state_in[111:104];  // byte 9 > 13
  assign state_out[111:104] = state_in[15:8];   // byte 13 > 1

  // row 2
  assign state_out[23:16] = state_in[87:80];    // byte 2 > 10
  assign state_out[55:48] = state_in[119:112];  // byte 6 > 14
  assign state_out[87:80] = state_in[23:16];    // byte 10 > 2
  assign state_out[119:112] = state_in[55:48];  // byte 14 > 6

  // row 3
  assign state_out[31:24] = state_in[127:120];  // byte 3 > 15
  assign state_out[63:56] = state_in[31:24];    // byte 7 > 3
  assign state_out[95:88] = state_in[63:56];    // byte 11 > 7
  assign state_out[127:120] = state_in[95:88];  // byte 15 > 11

endmodule