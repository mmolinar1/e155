// // author: Matthew Molinar
// // email: mmolinar@hmc.edu
// // date created: 10/24/2025

// // aes.sv

// /////////////////////////////////////////////
// // aes
// //   Top level module with SPI interface and SPI core
// /////////////////////////////////////////////

// module aes(input  logic clk,
// 		   input  logic reset,
//            input  logic sck, 
//            input  logic sdi,
//            output logic sdo,
//            input  logic load,
//            output logic done);
                    
//     logic [127:0] key, plaintext, cyphertext;
//     logic int_osc;
//     logic core_load, core_done, spi_done;
	
//     HSOSC #(.CLKHF_DIV(2'b11)) hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));

//     // synchronizing

//     // sync load signal
//     sync load_sync (
//         .old_clk(sck),
//         .new_clk(int_osc),
//         .d(load),
//         .q(core_load)
//     );

//     // sync done signal
//     sync done_sync (
//         .old_clk(clk),
//         .new_clk(int_osc),
//         .d(core_done),
//         .q(spi_done)
//     );
	
//     aes_spi spi(sck, sdi, sdo, spi_done, key, plaintext, cyphertext);
//     aes_core core(int_osc, reset, core_load, key, plaintext, core_done, cyphertext);

//     assign done = spi_done;
// endmodule

// author: Matthew Molinar
// email: mmolinar@hmc.edu
// date created: 10/24/2025

// aes.sv

/////////////////////////////////////////////
// aes
//   Top level module with SPI interface and SPI core
/////////////////////////////////////////////



module aes(input  logic reset,
           input  logic sck, 
           input  logic sdi,
           output logic sdo,
           input  logic load,
           output logic done);

    logic [127:0] key, plaintext, cyphertext;
    logic int_osc;

   HSOSC hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));

    aes_spi spi(sck, sdi, sdo, done, key, plaintext, cyphertext);
    aes_core core(int_osc, reset, load, key, plaintext, done, cyphertext);

endmodule