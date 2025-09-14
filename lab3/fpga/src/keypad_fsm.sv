// author: Matthew Molinar
// email: mmolinar@hmc.edu
// date created: 09/11/2025

// Lab 3: Keypad Scanner
// This module contains the FSM
// which handles different button press
// inputs and makes sure the proper 
// seven-segment display is lit up

module keypad_fsm(
	input logic clk, reset,
    input logic [3:0] row,
    output logic [3:0] col,
    output logic [3:0] digit,
	output logic valid_key
);
	typedef enum logic [3:0] {IDLE, DEBOUNCE, SYNC, ROW, DRIVE, HOLD} statetype;
    statetype state, nextstate;
    logic [21:0] debounce_counter;
    logic key_press, key_debounced;
	logic key_synced;
    logic [3:0] decoded_digit;
	
	parameter DEBOUNCE_DIVIDER = 22'd2400000;

    // Key press detection
    assign key_press = |row;
    
    // Keypad decoder to convert row/col to a digit
    keypad_decoder decoder(
        .row(row),
        .col(col),
        .digit(decoded_digit)
    );

    debouncer debounce(
        .clk(clk),
        .reset(reset),
        .s_in(key_press),
        .s_out(key_debounced),
		.debounce_counter(debounce_counter)
    );
	
	sync key_sync(
		.clk(clk),
		.d(key_debounced),
		.q(key_synced)
	);

    // State register
    always_ff @(posedge clk) begin
        if (reset) begin
			state <= IDLE;
        end else begin
			state <= nextstate;
		end
	end
    
    // checking all columns
    always_ff @(posedge clk)
        if (reset) begin
            col <= 4'b0001;
        end else if (state == IDLE) begin
            // Rotate active col
            if (col == 4'b0001) col <= 4'b0010;
            if (col == 4'b0010) col <= 4'b0100;
            if (col == 4'b0100) col <= 4'b1000;
            if (col == 4'b1000) col <= 4'b0001;
        end

    // Next state logic
    always_comb
        case(state)
            IDLE: if(key_press) nextstate = DEBOUNCE;
                else nextstate = IDLE;
                
            DEBOUNCE: if(debounce_counter >= DEBOUNCE_DIVIDER) nextstate = SYNC;

            SYNC: if(key_synced) nextstate = ROW;
                else nextstate = IDLE;

            ROW: if(key_synced) nextstate = DRIVE;
                else nextstate = IDLE;

            DRIVE: nextstate = HOLD;

            HOLD: if(key_synced) nextstate = HOLD;
                else nextstate = IDLE;

            default: nextstate = IDLE;
        endcase

    // Output logic
    assign digit = decoded_digit;
    assign valid_key = (state == DRIVE);

endmodule