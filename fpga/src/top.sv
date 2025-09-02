// author: Matthew Molinar
// email: mmolinar@hmc.edu
// date created: 08/31/2025

module top(
	input logic clk,
	input logic [3:0] s,
	output logic [2:0] led, 
	output logic [6:0] seg
);

	logic int_osc;
	logic [24:0] counter = 0; // counter for 2.4 Hz
	
	// Internal high-speed oscillator
	HSOSC hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));

	// Clock divider variable
    // 48 MHz / 10 MHz = 2.4 Hz
    parameter CLOCK_DIVIDER = 24'd10000000;
	
	// counter
	always_ff @(posedge int_osc) begin
        if (counter >= CLOCK_DIVIDER - 1) begin
            counter <= '0;
            led[2] <= ~led[2];   // toggle LED at 2.4 Hz
        end else begin
            counter <= counter + 1'b1;
        end
    end

	led[0] = s[0] & s[1];
	led[1] = s[2] ^ s[3];

    // seven segment module
	seven_seg sevseg(.digit(s), .seg(seg));

endmodule 