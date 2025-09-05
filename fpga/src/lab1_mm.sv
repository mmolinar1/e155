// author: Matthew Molinar
// email: mmolinar@hmc.edu
// date created: 08/31/2025

// lab 1 FPGA and MCU Setup and Testing
module top(
	input logic [3:0] s,
	output logic [2:0] led, 
	output logic [6:0] seg
);

	// led control module
	led_control ledcontrol(.s(s), .led(led));

    // seven segment module
	seven_seg sevseg(.s(s), .seg(seg));

endmodule