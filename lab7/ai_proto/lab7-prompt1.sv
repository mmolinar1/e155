// KeyExpansionComb128.sv
// Purely combinational AES-128 single-step key expansion:
// Given previous 128-bit round key and round number, compute the next 128-bit round key.
// Assumes RotWord and SubWord are implemented as combinational modules:
//   RotWord (.in(word32), .out(word32_rot))
//   SubWord (.in(word32), .out(word32_sub))

module KeyExpansionComb128 (
    input  logic [127:0] prev_key,   // previous round key (4 x 32-bit words)
    input  logic [3:0]   round,      // round number 1..10 (for AES-128)
    output logic [127:0] next_key    // next round key (4 x 32-bit words)
);

    // Split prev_key into four 32-bit words (word 0 is most-significant 32 bits)
    // Adjust these slices if your key word ordering is different.
    logic [31:0] prev_w0, prev_w1, prev_w2, prev_w3;
    assign prev_w0 = prev_key[127:96];
    assign prev_w1 = prev_key[95:64];
    assign prev_w2 = prev_key[63:32];
    assign prev_w3 = prev_key[31:0];

    // Rcon table for rounds 1..10 (leftmost byte only, others zero)
    // Values from FIPS-197 Table 5 in hex: 0x01,0x02,0x04,0x08,0x10,0x20,0x40,0x80,0x1b,0x36
    logic [31:0] rcon_word;
    always_comb begin
        case (round)
            4'd1:  rcon_word = 32'h01_00_00_00;
            4'd2:  rcon_word = 32'h02_00_00_00;
            4'd3:  rcon_word = 32'h04_00_00_00;
            4'd4:  rcon_word = 32'h08_00_00_00;
            4'd5:  rcon_word = 32'h10_00_00_00;
            4'd6:  rcon_word = 32'h20_00_00_00;
            4'd7:  rcon_word = 32'h40_00_00_00;
            4'd8:  rcon_word = 32'h80_00_00_00;
            4'd9:  rcon_word = 32'h1b_00_00_00;
            4'd10: rcon_word = 32'h36_00_00_00;
            default: rcon_word = 32'h00_00_00_00; // invalid round -> no addition
        endcase
    end

    // Wires for RotWord and SubWord outputs
    logic [31:0] rot_out;
    logic [31:0] sub_out;

    // Instantiate RotWord and SubWord (combinational modules)
    // Expected module interface:
    //   module RotWord(input logic [31:0] in, output logic [31:0] out);
    //   module SubWord(input logic [31:0] in, output logic [31:0] out);
    RotWord rotword_inst (
        .in  (prev_w3),
        .out (rot_out)
    );

    SubWord subword_inst (
        .in  (rot_out),
        .out (sub_out)
    );

    // temp = SubWord(RotWord(prev_w3)) XOR Rcon[round]
    logic [31:0] temp;
    assign temp = sub_out ^ rcon_word;

    // Compute new words (combinational XOR chain)
    logic [31:0] new_w0, new_w1, new_w2, new_w3;
    assign new_w0 = prev_w0 ^ temp;
    assign new_w1 = prev_w1 ^ new_w0;
    assign new_w2 = prev_w2 ^ new_w1;
    assign new_w3 = prev_w3 ^ new_w2;

    // Pack next_key using same ordering as prev_key
    assign next_key = { new_w0, new_w1, new_w2, new_w3 };

endmodule