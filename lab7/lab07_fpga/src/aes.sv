// author: Matthew Molinar
// email: mmolinar@hmc.edu
// date created: 10/24/2025

// aes.sv

/////////////////////////////////////////////
// aes
//   Top level module with SPI interface and SPI core
/////////////////////////////////////////////

module aes(input  logic clk,
		   input  logic reset,
           input  logic sck, 
           input  logic sdi,
           output logic sdo,
           input  logic load,
           output logic done);
                    
    logic [127:0] key, plaintext, cyphertext;
	
    HSOSC #(.CLKHF_DIV(2'b11)) hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));
	
    aes_spi spi(sck, sdi, sdo, done, key, plaintext, cyphertext);
    aes_core core(int_osc, reset, load, key, plaintext, done, cyphertext);
endmodule