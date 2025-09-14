// author: Matthew Molinar
// email: mmolinar@hmc.edu
// date created: 09/11/2025

// Lab 3: Keypad Scanner
// This module decodes switch inputs
// from the keypad

module keypad_decoder(
    input  logic [3:0] row,    // Input row
    input logic [3:0] col,     // Input col
    output logic [3:0] digit
);

    always_comb begin
        case ({row, col})

            {4'b0001, 4'b0001}: digit = 4'b0001;    // row 0, col 0, 1
            {4'b0001, 4'b0010}: digit = 4'b0010;    // row 0, col 1, 2
            {4'b0001, 4'b0100}: digit = 4'b0011;    // row 0, col 2, 3
            {4'b0001, 4'b1000}: digit = 4'b1010;    // row 0, col 3, A

            {4'b0010, 4'b0001}: digit = 4'b0100;    // row 1, col 0, 4
            {4'b0010, 4'b0010}: digit = 4'b0101;    // row 1, col 1, 5
            {4'b0010, 4'b0100}: digit = 4'b0110;    // row 1, col 2, 6
            {4'b0010, 4'b1000}: digit = 4'b1011;    // row 1, col 3, B

            {4'b0100, 4'b0001}: digit = 4'b0111;    // row 2, col 0, 7 
            {4'b0100, 4'b0010}: digit = 4'b1000;    // row 2, col 1, 8
            {4'b0100, 4'b0100}: digit = 4'b1001;    // row 2, col 2, 9
            {4'b0100, 4'b1000}: digit = 4'b1100;    // row 2, col 3, C

            {4'b1000, 4'b0001}: digit = 4'b1110;    // row 3, col 0, E
            {4'b1000, 4'b0010}: digit = 4'b0000;    // row 3, col 1, 0
            {4'b1000, 4'b0100}: digit = 4'b1111;    // row 3, col 2, F
            {4'b1000, 4'b1000}: digit = 4'b1101;    // row 3, col 3, D
           
            default digit = 4'b0000;
        endcase
    end

endmodule