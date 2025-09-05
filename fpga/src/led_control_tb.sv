// author: Matthew Molinar
// email: mmolinar@hmc.edu
// date created: 09/1/2025

// test bench for the on-board LED control module

module led_control_tb();
	
//// Testbench module tests another module called the device under test(DUT).
// It applies inputs to DUT and check if outputs are as expected.
// User provides patterns of inputs & desired outputs called testvectors.

logic clk, reset;
// 'clk' & 'reset' are common names for the clock and the reset, 
// but they're not reserved.

logic [3:0] s;
logic [2:0] led, led_expected;
logic [31:0] vectornum, errors;
logic [6:0] testvectors[10000:0];

seven_seg dut(s, seg);
//// Generate clock.
always
begin
 //// Create clock with period of 10 time units. 
// Set the clk signal HIGH(1) for 5 units, LOW(0) for 5 units 
clk=1; #5; 
clk=0; #5;
end

//// Start of test. 
initial
begin
//// Load vectors stored as 0s and 1s (binary) in .tv file.
$readmemb("led_control.tv", testvectors);
// $readmemb reads binarys, $readmemh reads hexadecimals.
// Initialize the number of vectors applied & the amount of 
// errors detected.
vectornum=0; 
errors=0;

reset=1; #22; 
reset=0;

end
//// Apply test vectors on rising edge of clk.
always @(posedge clk)
begin
//// Apply testvectors 1 time unit after rising edge of clock to 
// avoid data changes concurrently with the clock.
#1;

{s, led_expected} = testvectors[vectornum];
end
//// Check results on falling edge of clk.
always @(negedge clk)
	
if (~reset) begin
	
//// Detect error by checking if outputs from DUT match 
// expectation.
if (s !== led_expected) begin
$display("Error: inputs = %b", {s});
$display(" outputs = %b (%b expected)", led, led_expected);
//// Increment the count of errors.
errors = errors + 1;
end

//// In any event, increment the count of vectors.
vectornum = vectornum + 1;

if (testvectors[vectornum] === 7'bx) begin
$display("%d tests completed with %d errors", vectornum, 
errors);

$stop;
end
end
endmodule