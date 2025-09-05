// author: Matthew Molinar
// email: mmolinar@hmc.edu
// date created: 09/1/2025

// module to control on-board LEDs - one LED
// is blinking at 2.4 Hz, while the rest are toggled
// with switches

module led_control(
	input logic [3:0] s,
	output logic [2:0] led
);

	logic int_osc;
	logic [25:0] counter = 0; // counter for 2.4 Hz
	
	// Internal high-speed oscillator
	HSOSC hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));

	// Clock divider variable
    // 24 MHz / 10 MHz / 2 = 2.4 Hz (50% duty cycle)
    parameter CLOCK_DIVIDER = 25'd5000000;
	
	// counter
	always_ff @(posedge int_osc) begin
        if (counter >= CLOCK_DIVIDER - 1) begin
            counter <= 0;
            led[2] <= ~led[2];   // toggle LED at 2.4 Hz
        end else begin
            counter <= counter + 1'b1;
        end
    end
	
	// led 0 and led 1 logic
	assign led[0] = s[0] ^ s[1];
	assign led[1] = s[2] & s[3];
	
endmodule