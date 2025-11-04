// author: Matthew Molinar
// email: mmolinar@hmc.edu
// date created: 10/25/2025

// key_expansion.sv

/////////////////////////////////////////////
// key_expansion
// generates keys for add_round_key
// NIST FIPS 197 section 5.2
/////////////////////////////////////////////

   module key_expansion(input  logic       clk,
                        input  logic       reset,
                        input  logic       start,    // flag indicating when to start key expansion
                        input  logic [127:0] init_key,
                        input  logic [3:0]   round_number,
                        output logic [127:0] round_key,
                        output logic       done);  // flag indicating when keys are ready

       // FSM with control signals used to 
       // perform key expansion

       // key word
       // 11-key x 128-bit memory
       logic [127:0] w[10:0];

       // Counter for rounds 0-10
       logic [3:0] i;

       logic [127:0] prev_key_reg;
       logic [31:0]  prev_w0, prev_w1, prev_w2, prev_w3;

		// States
       typedef enum logic [2:0] {IDLE, LOAD, GEN, DONE} statetype;
       statetype state, nextstate;

       // temps for RotWord and SubWord
       logic [31:0] temp_rot;
       logic [31:0] temp_sub;
       logic [31:0] rcon;
       logic [31:0] w0_next, w1_next, w2_next, w3_next;
       
       assign {prev_w0, prev_w1, prev_w2, prev_w3} = prev_key_reg;

       // use multiple sboxes (for sub_word) in order to preform
       // substitutions in parallel
       sbox sbox0(temp_rot[31:24], temp_sub[31:24]);
       sbox sbox1(temp_rot[23:16], temp_sub[23:16]);
       sbox sbox2(temp_rot[15:8],  temp_sub[15:8]);
       sbox sbox3(temp_rot[7:0],   temp_sub[7:0]);

       // Round constant logic (see Table 5 in NIST FIPS 197)
       always_comb begin
           case (i) // i is the counter for rounds
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
       
       always_comb begin
           w0_next = prev_w0 ^ temp_sub ^ rcon;
           w1_next = w0_next ^ prev_w1;
           w2_next = w1_next ^ prev_w2;
           w3_next = w2_next ^ prev_w3;
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
       assign temp_rot = {prev_w3[23:16], prev_w3[15:8], prev_w3[7:0], prev_w3[31:24]};

       // logic for control signals
       always_ff @(posedge clk) begin
           case(state)
               IDLE: 
                   if (start) begin
                       i <= 0;
                   end
               LOAD: begin
                   w[0] <= init_key;
                   prev_key_reg <= init_key;
                   i <= 1;
               end
               GEN: begin  
                   w[i] <= {w0_next, w1_next, w2_next, w3_next};
                   prev_key_reg <= {w0_next, w1_next, w2_next, w3_next};
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
               // keep generating until the last key is reached
               GEN: if (i == 10) nextstate = DONE;
                    else nextstate = GEN;
               DONE: nextstate = DONE;
               default: nextstate = state;
           endcase
       end

       // Output logic
       // The key for a given round
       assign round_key = w[round_number];

   endmodule