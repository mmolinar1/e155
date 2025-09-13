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
	input logic [3:0] col,                   // columns of keypad
	output logic [6:0] seg,   
	output logic [3:0] row,                  // rows of keypad
	output logic seven_seg_1, seven_seg_2    // controls
);

    logic [3:0] state, nextstate;

    // defining states
	parameter IDLE = 4'b0000;
    parameter DEBOUNCE = 4'b0001;
    parameter SYNC = 4'b0010;
    parameter ROW = 4'b0011;
    parameter DRIVE = 4'b0100;
    parameter HOLD = 4'b0101;


    // State register
    always_ff @(posedge clk)
        if (reset) state <= IDLE;
        else state <= nextstate;

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
    assign seven_seg_1 = (state == IDLE);
    assign seven_seg_2 = (state == HOLD);

endmodule