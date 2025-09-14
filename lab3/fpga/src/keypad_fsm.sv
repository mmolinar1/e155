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

    logic [3:0] state, nextstate;
    logic [21:0] debounce_counter;
    logic key_press, key_debounced;
    logic [3:0] decoded_digit;

    // defining states
	parameter IDLE = 4'b0000;
    parameter DEBOUNCE = 4'b0001;
    parameter SYNC = 4'b0010;
    parameter ROW = 4'b0011;
    parameter DRIVE = 4'b0100;
    parameter HOLD = 4'b0101;

    // Key press detection
    assign key_press = |col;
    
    // Keypad decoder to convert row/col to a digit
    keypad_decoder decoder(
        .row(row),
        .col(col),
        .digit(decoded_digit)
    );

    debouncer debounce(
        .clk(clk)
        .reset(reset)
        .s_in(key_pressed)
        .s_out(key_debounced)
    )

    // State register
    always_ff @(posedge clk)
        if (reset) state <= IDLE;
        else state <= nextstate;
    
    // checking all rows
    always_ff @(posedge clk)
        if (reset) begin
            row <= 4'b0001;
        end else if (state == IDLE) begin
            // Rotate active row
            if (row == 4'b0001) row <= 4'b0010;
            if (row == 4'b0010) row <= 4'b0100;
            if (row == 4'b0100) row <= 4'b1000;
            if (row == 4'b1000) row <= 4'b0001;
        end

    // Next state logic
    always_comb
        case(state)
            IDLE: if(key_press) nextstate = DEBOUNCE;
                
            DEBOUNCE: if(debounce_counter >= DEBOUNCE_DIVIDER) nextstate = SYNC;

            SYNC: if(key_press) nextstate = ROW;
                else nextstate = IDLE;

            ROW: if(x) nextstate = DRIVE;
                else nextstate = IDLE;

            DRIVE: nextstate = HOLD;

            HOLD: if(key_press) nextstate = HOLD;
                else nextstate = IDLE;

            default: nextstate = IDLE;
        endcase

    // Output logic
    assign digit = decoded_digit;
    assign valid_key = (state == DRIVE);

endmodule