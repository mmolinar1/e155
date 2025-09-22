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
    input logic [3:0] key_synced,
    output logic [3:0] col,
    output logic [3:0] digit,
	output logic valid_key
);
	// typedef enum logic [2:0] {IDLE, DEBOUNCE, ROW, DRIVE, HOLD} statetype;
    // statetype state, nextstate;
    logic [21:0] debounce_counter;
    logic count_done, reset_count, cycle;
    logic [3:0] decoded_digit, col_cycle;
	
	typedef enum logic [2:0] {
		IDLE = 3'b000, 
		DEBOUNCE = 3'b001, 
		ROW = 3'b011, 
		DRIVE = 3'b100, 
		HOLD = 3'b101
	} statetype;
	
	statetype state, nextstate;

    // actual divider value used in hardware
	parameter DEBOUNCE_DIVIDER = 22'd2400000;
    
    // Keypad decoder to convert row/col to a digit
    keypad_decoder decoder(
        .row(key_synced),
        .col(col),
        .digit(decoded_digit)
    );

    debouncer #(DEBOUNCE_DIVIDER) debounce(
        .clk(clk),
        .reset(reset),
        .reset_count(reset_count),
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
	
	always_ff @(posedge clk) begin
		if (reset == 0) begin
			col_cycle <= 0;
		end else if (cycle) begin
			col_cycle <= col_cycle + 4'b1;
		end else col_cycle <= col_cycle;
	end
	
	always_comb begin
		case(col_cycle)
			0: col <= 4'b0001;
			1: col <= 4'b0001;
			2: col <= 4'b0001;
			3: col <= 4'b0001;
			4: col <= 4'b0010;
			5: col <= 4'b0010;
			6: col <= 4'b0010;
			7: col <= 4'b0010;
			8: col <= 4'b0100;
			9: col <= 4'b0100;
			10: col <= 4'b0100;
			11: col <= 4'b0100;
			12: col <= 4'b1000;
			13: col <= 4'b1000;
			14: col <= 4'b1000;
			15: col <= 4'b1000;
		endcase
	end

    always_comb begin
        case(state)
            IDLE: begin
				reset_count = 1;
				cycle = 1;
			end
            DEBOUNCE: begin
				reset_count = 0;
				cycle = 0;
			end
            default: begin
				reset_count = 0; 
				cycle = 0;
			end
        endcase
    end

    // Next state logic
    always_comb
        case(state)
            IDLE: if(|key_synced) nextstate = DEBOUNCE;
                else nextstate = IDLE;
                
            DEBOUNCE: if(count_done) nextstate = ROW;
				else nextstate = DEBOUNCE;

            ROW: if(|key_synced) nextstate = DRIVE;
                else nextstate = IDLE;

            DRIVE: nextstate = HOLD;

            HOLD: if(|key_synced) nextstate = HOLD;
                else nextstate = IDLE;

            default: nextstate = IDLE;
        endcase

    // Output logic
    assign digit = decoded_digit;
    assign valid_key = (state == DRIVE);

endmodule