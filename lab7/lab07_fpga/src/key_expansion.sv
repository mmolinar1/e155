// author: Matthew Molinar
// email: mmolinar@hmc.edu
// date created: 10/25/2025

// key_expansion.sv

/////////////////////////////////////////////
// key_expansion
// generates keys for add_round_key
// NIST FIPS 197 section 5.2
/////////////////////////////////////////////

module key_expansion(input  logic         clk,
                     input  logic         reset,
                     input  logic         start,   // flag indicating when to start key expansion
                     input  logic [127:0] init_key,
                     input  logic [3:0]   round_number,
                     output logic [127:0] round_key,
                     output logic         done);  // flag indicating when keys are ready

    // FSM with control signals used to 
    // perform key expansion

    // Entire set of key words
    logic [31:0] w[0:43];

    // States
    typedef enum logic [2:0] {IDLE, LOAD, GEN, DONE} statetype;
    statetype state, nextstate;

    // Counter for gen loop, counting up to 43
    logic [5:0] i;

    // temps for RotWord and SubWord
    logic [31:0] temp_rot;
    logic [31:0] temp_sub;
    logic [31:0] rcon;

    // use multiple sboxes (for sub_word) in order to preform
    // substitutions in parallel
    sbox sbox0(temp_rot[31:24], temp_sub[31:24]);
    sbox sbox1(temp_rot[23:16], temp_sub[23:16]);
    sbox sbox2(temp_rot[15:8],  temp_sub[15:8]);
    sbox sbox3(temp_rot[7:0],   temp_sub[7:0]);

    // Round constant logic (see Table 5 in NIST FIPS 197)
    always_comb begin
        case (i / 4) // i is the word index, so i/4 gives the round
            1:  rcon = 32'h01000000;
            2:  rcon = 32'h02000000;
            3:  rcon = 32'h04000000;
            4:  rcon = 32'h08000000;
            5:  rcon = 32'h10000000;
            6:  rcon = 32'h20000000;
            7:  rcon = 32'h40000000;
            8:  rcon = 32'h80000000;
            9:  rcon = 32'h1b000000;
            10: rcon = 32'h36000000;
            default: rcon = 32'h00000000;
        endcase
    end

    // State register
    always_ff @(posedge clk) begin
        if (~reset) begin
			state <= IDLE;
        end else begin
			state <= nextstate;	
		end
	end
	
    // ROTWORD([a0, a1, a2, a3]) = [a1, a2, a3, a0] - eq. 5.10 in NIST FIPS 197
	logic [31:0] w_im1, w_im4;
    assign w_im1 = w[i-1];  // geting the previous word
    assign w_im4 = w[i-4];  // getting the 4th word back
    assign temp_rot = {w_im1[23:16], w_im1[15:8], w_im1[7:0], w_im1[31:24]};

	// logic for control signals
    always_ff @(posedge clk) begin
        case(state)
            IDLE: 
                if (start) begin
                    i <= 0;
                end
            LOAD: begin
                {w[0], w[1], w[2], w[3]} <= init_key;
                i <= 4; // Start generating from the 4th word
			end
			GEN: begin                
                if (i % 4 == 0) begin
                    // XOR with Rcon[1/4]
                    w[i] <= w_im4 ^ temp_sub ^ rcon;  
                end else begin
                    // else just keep the pervious word
                    w[i] <= w_im4 ^ w_im1;
                end
                i <= i + 1'b1;
			end
            default: begin
				i <= 0;
			end
        endcase
    end

    // Next state logic
    always_comb begin
        done = (state == DONE);  
        case(state)
            IDLE: 
                if (start) nextstate = LOAD;
                    else nextstate = IDLE;
            LOAD: nextstate = GEN;
            // keep generating until the last word (44) is reached
            GEN: if (i > 43) nextstate = DONE;
                 else nextstate = GEN;
            DONE: nextstate = IDLE;
            default: nextstate = state;
        endcase
	end

    // Output logic
    // The key for a given round
    assign round_key = {w[round_number*4], w[round_number*4+1], w[round_number*4+2], w[round_number*4+3]};

endmodule