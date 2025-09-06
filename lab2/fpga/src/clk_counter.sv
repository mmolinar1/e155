// author: Matthew Molinar
// email: mmolinar@hmc.edu
// date created: 09/05/2025

// clock counter module to toggle seven-segment enable
// which will determine which display to light up

module clk_counter(
	input logic clk,
    output logic seven_seg_en
);

    // Clock divider variable at 24 KHz
	logic [14:0] counter = 0;    // counter for 24 KHz
    parameter CLOCK_DIVIDER = 25'd24000;   
	
	// counter
	always_ff @(posedge int_osc) begin
        if (counter == CLOCK_DIVIDER) begin
            counter <= 0;
            seven_seg_en <= ~seven_seg_en;    // toggle seven-segment enable
        end else begin
            counter <= counter + 1'b1;
        end
    end
    
endmodule