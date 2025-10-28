//-----------------------------------------------------------------------------
// Key expansion module following the provided pseudocode.
//   - Word width is 32 bits (4 bytes).
//   - Inputs:
//       * key_words[0..NK-1]  : initial NK words (32-bit each)
//       * Rcon[0..RCON_MAX-1] : round constants (32-bit each) -- user provides
//   - Outputs:
//       * w[0..4*NR+3] : expanded words (32-bit each)
//-----------------------------------------------------------------------------
// NOTE: This code assumes the existence of two combinational modules with
// the following interface signatures (adjust if your actual modules use
// different port names or widths):
//
// module module1(input  logic [31:0] in, output logic [31:0] out);
// module module2(input  logic [31:0] in, output logic [31:0] out);
//-----------------------------------------------------------------------------

module key_expander #(
    parameter int NK = 4,               // from your pseudo code
    parameter int NR = 10               // from your pseudo code
) (
    input  logic [31:0] key_words [0: NK-1],                 // initial key words
    input  logic [31:0] Rcon       [0: (4*NR+4)/NK - 1],    // Rcon array (sized by caller)
    output logic [31:0] w          [0: 4*NR + 3]            // output expanded key words
);

    // Number of output words
    localparam int WLEN = 4*NR + 4;

    // Temporary nets to hold module outputs for each index that may need them.
    // We create arrays sized to WLEN to keep wiring simple; only a subset will be used.
    logic [31:0] mod2_out      [0: WLEN-1];
    logic [31:0] mod1_out_from_mod2 [0: WLEN-1];
    logic [31:0] mod1_out_direct     [0: WLEN-1];

    // -------------------------------------------------------------------------
    // Instantiate module2 and module1 for every index i where they *might* be
    // used. They are combinational and wired directly to w[i-1] (which will be
    // computed in the combinational block below). Only the ones that are needed
    // by the conditional logic in the pseudo code will be read when generating
    // w[i].
    // -------------------------------------------------------------------------
    genvar gi;
    generate
        for (gi = 0; gi < WLEN; gi = gi + 1) begin : gen_mods
            // module2 instance (used when i % NK == 0)
            // Input: w[gi-1]  (we wire from an intermediate net called w_wire)
            // Since w is computed in always_comb below, the connection is safe;
            // mod* are combinational and will simply reflect the connected net.
            module2 u_module2 (
                .in  ( (gi == 0) ? 32'h0 : /* unused when gi==0 */ w[gi-1] ),
                .out ( mod2_out[gi] )
            );

            // module1 instance used on module2 output: module1(module2(temp))
            module1 u_module1_from_mod2 (
                .in  ( mod2_out[gi] ),
                .out ( mod1_out_from_mod2[gi] )
            );

            // module1 instance used directly when Nk > 6 and i % Nk == 4
            module1 u_module1_direct (
                .in  ( (gi == 0) ? 32'h0 : /* unused when gi==0 */ w[gi-1] ),
                .out ( mod1_out_direct[gi] )
            );
        end
    endgenerate

    // -------------------------------------------------------------------------
    // Compute w sequentially in index order using a single combinational block.
    // Blocking assignments (`=`) are used so each iteration's calculation uses
    // the previously computed w values (this "unwraps" the loop).
    // -------------------------------------------------------------------------
    integer i;
    always_comb begin
        // default initialization (avoid X)
        for (i = 0; i < WLEN; i = i + 1) begin
            w[i] = 32'h0000_0000;
        end

        // first loop: copy the initial key words into w[0..NK-1]
        for (i = 0; i < NK; i = i + 1) begin
            // w[i] <- key_words[i]
            w[i] = key_words[i];
        end

        // second loop: for i from NK to 4*Nr+3 inclusive
        for (i = NK; i <= 4*NR + 3; i = i + 1) begin
            logic [31:0] temp;
            // temp <- w[i-1]
            temp = w[i-1];

            // if i mod Nk = 0 then
            if ((i % NK) == 0) begin
                // temp <- module1(module2(temp)) (+) Rcon[i/Nk]
                // module2 and module1 outputs are prewired to use w[i-1], so:
                temp = mod1_out_from_mod2[i] ^ Rcon[i / NK];
            end
            // else if Nk > 6 and i mod Nk = 4 then
            else if ((NK > 6) && ((i % NK) == 4)) begin
                // temp <- module1(temp)
                temp = mod1_out_direct[i];
            end

            // w[i] <- w[i-Nk] (+) temp
            w[i] = w[i - NK] ^ temp;
        end
    end

endmodule