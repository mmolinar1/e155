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
	typedef enum logic [2:0] {IDLE, DEBOUNCE, SYNC, ROW, DRIVE, HOLD} statetype;
    statetype state, nextstate;
    logic [21:0] debounce_counter;
    logic key_press, key_synced;
    logic count_done;
    logic [3:0] decoded_digit;

    // actual divider value used in hardware
	// parameter DEBOUNCE_DIVIDER = 22'd2400000;

    // using a smaller divider so that the simulation doesn't take as long
    parameter DEBOUNCE_DIVIDER = 22'd100;

    // Key press detection
    assign key_press = |row;
    
    // Keypad decoder to convert row/col to a digit
    keypad_decoder decoder(
        .row(row),
        .col(col),
        .digit(decoded_digit)
    );

    sync key_sync(
		.clk(clk),
		.d(key_press),
		.q(key_synced)
	);

    debouncer #(DEBOUNCE_DIVIDER) debounce(
        .clk(clk),
        .reset(reset),
        .count_done(count_done),
		.debounce_counter(debounce_counter)
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
            if (col == 4'b0001)
				col <= 4'b0010;
            else if (col == 4'b0010)
				col <= 4'b0100;
            else if (col == 4'b0100)
				col <= 4'b1000;
            else if (col == 4'b1000)
				col <= 4'b0001;
        end

    // Next state logic
    always_comb
        case(state)
            IDLE: if(key_press) nextstate = SYNC;
                else nextstate = IDLE;

            SYNC: if(key_synced) nextstate = DEBOUNCE;
                else nextstate = IDLE;
                
            DEBOUNCE: if(count_done) nextstate = ROW;
				else nextstate = DEBOUNCE;

            ROW: if(key_synced) nextstate = DRIVE; // might have to be key_press?
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