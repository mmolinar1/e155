// author: Matthew Molinar
// email: mmolinar@hmc.edu
// date created: 10/24/2025

// aes_core.sv

/////////////////////////////////////////////
// aes_core
//   top level AES encryption module
//   when load is asserted, takes the current key and plaintext
//   generates cyphertext and asserts done when complete 11 cycles later
// 
//   See FIPS-197 with Nk = 4, Nb = 4, Nr = 10
//
//   The key and message are 128-bit values packed into an array of 16 bytes as
//   shown below
//        [127:120] [95:88] [63:56] [31:24]     S0,0    S0,1    S0,2    S0,3
//        [119:112] [87:80] [55:48] [23:16]     S1,0    S1,1    S1,2    S1,3
//        [111:104] [79:72] [47:40] [15:8]      S2,0    S2,1    S2,2    S2,3
//        [103:96]  [71:64] [39:32] [7:0]       S3,0    S3,1    S3,2    S3,3
//
//   Equivalently, the values are packed into four words as given
//        [127:96]  [95:64] [63:32] [31:0]      w[0]    w[1]    w[2]    w[3]
/////////////////////////////////////////////

module aes_core(input  logic         clk,
                input  logic         reset,
                input  logic         load,
                input  logic [127:0] key, 
                input  logic [127:0] plaintext, 
                output logic         done, 
                output logic [127:0] cyphertext);

    // FSM with control signals used to 
    // perform rounds sequentially

    typedef enum logic [3:0] {IDLE, WAIT_KEYS, FIRST_ROUND_KEY, SUB_BYTES_WAIT, SUB_BYTES, SHIFT_ROWS, MIX_COLS, ADD_ROUND_KEY, DONE} statetype;
    statetype state, nextstate;

    logic [127:0] state_reg;
    logic [3:0]   round_count; // Counts from 0 to 10 for the for loop

    logic [127:0] sub_bytes_out;
    logic [127:0] shift_rows_out;
    logic [127:0] mix_cols_out;
    logic [127:0] add_round_key_out;
    logic [127:0] current_round_key;
    logic         key_expansion_done;
    logic         key_expansion_start;

    sub_bytes sub_bytes(
        .a(state_reg),
        .clk(clk),
        .y(sub_bytes_out)
    );

    shift_rows shift_rows(
        .state_in(state_reg),
        .state_out(shift_rows_out)
    );

    mixcolumns mix_columns(
        .a(state_reg),
        .y(mix_cols_out)
    );

    add_round_key add_round_key(
        .state_in(state_reg),
        .round_key(current_round_key),
        .state_out(add_round_key_out)
    );

    key_expansion key_expansion(
        .clk(clk), .reset(reset), .start(key_expansion_start), 
        .init_key(key), .round_number(round_count), 
        .round_key(current_round_key), .done(key_expansion_done)
    );

    // State register
    always_ff @(posedge clk) begin
        if (~reset) begin
			state <= IDLE;
        end else begin
			state <= nextstate;	
		end
	end
	
	// logic for control signals
    always_ff @(posedge clk) begin
        if (~reset) begin
            state_reg <= '0;
            round_count <= 0;
            key_expansion_start <= 0;
        end else begin
            case(state)
                IDLE: 
                    if (!load) begin
                        state_reg <= plaintext;
                        round_count <= 0;
                        key_expansion_start <= 1;
                    end
                WAIT_KEYS: begin
                    key_expansion_start <= 0;
                end
                FIRST_ROUND_KEY: begin
                    state_reg <= add_round_key_out;
                    round_count <= 0;
                end
                SUB_BYTES_WAIT: begin // wait state for sub_bytes
                end
                SUB_BYTES: begin
                    state_reg <= sub_bytes_out;
                end
                SHIFT_ROWS: begin
                    state_reg <= shift_rows_out;
                end
                MIX_COLS: begin
                    if(round_count < 9) begin
                        state_reg <= mix_cols_out;
                    end

                    if(round_count < 10) begin
                        round_count <= round_count + 1;
                    end
                end
                ADD_ROUND_KEY: begin
                    state_reg <= add_round_key_out;
                end
            endcase
        end
    end

    // Next state logic
    always_comb begin
        done = 0;  // done flag default low
    
        case(state)
            IDLE: 
                if (!load) nextstate = WAIT_KEYS;
                    else nextstate = IDLE;
            WAIT_KEYS: if(key_expansion_done) nextstate = FIRST_ROUND_KEY;
                       else nextstate = WAIT_KEYS;
            FIRST_ROUND_KEY: nextstate = SUB_BYTES_WAIT;
            SUB_BYTES_WAIT: nextstate = SUB_BYTES;
			SUB_BYTES: nextstate = SHIFT_ROWS;
			SHIFT_ROWS: begin
				if (round_count == 10) begin
                    nextstate = ADD_ROUND_KEY;
                end else begin
                    nextstate = MIX_COLS;
                end
			end
			MIX_COLS: nextstate = ADD_ROUND_KEY;
            ADD_ROUND_KEY: begin
				if (round_count == 10) begin
                    nextstate = DONE;
                end else begin
                    nextstate = SUB_BYTES_WAIT;
                end
            end
            DONE: begin
                done = 1;
                nextstate = DONE;
            end
            default: nextstate = state;
        endcase
    end

    // Output logic
    assign cyphertext = (state == DONE) ? state_reg : 128'b0;
endmodule