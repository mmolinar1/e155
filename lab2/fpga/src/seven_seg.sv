// author: Matthew Molinar
// email: mmolinar@hmc.edu
// date created: 09/1/2025

// 7-segment display
// seg[0]=A, seg[1]=B, seg[2]=C, seg[3]=D, seg[4]=E, seg[5]=F, seg[6]=G

module seven_seg(
    input  logic [3:0] s,      // Input hex
    output logic [6:0] seg     // 7-segment outputs
);
    always_comb begin
        case (s)
            4'h0: seg = 7'b1000000;  // All except G
            4'h1: seg = 7'b1111001;  // B C
            4'h2: seg = 7'b0100100;  // A B G E D
            4'h3: seg = 7'b0110000;  // A B G C D
            4'h4: seg = 7'b0011001;  // F G B C
            4'h5: seg = 7'b0010010;  // A F G C D
            4'h6: seg = 7'b0000010;  // A F G E C D
            4'h7: seg = 7'b1111000;  // A B C
            4'h8: seg = 7'b0000000;  // All
            4'h9: seg = 7'b0010000;  // A B F G C D
            4'hA: seg = 7'b0001000;  // A B C E F G
            4'hB: seg = 7'b0000011;  // C D E F G
            4'hC: seg = 7'b1000110;  // A F E D
            4'hD: seg = 7'b0100001;  // B C D E G
            4'hE: seg = 7'b0000110;  // A F G E D
            4'hF: seg = 7'b0001110;  // A F G E
            default: seg = 7'b1111111;
        endcase
    end
endmodule