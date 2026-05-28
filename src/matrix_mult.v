`default_nettype none

module matrix_mult (
    input  wire        clk,
    input  wire        rst,
    input  wire [7:0]  A0, A1, A2, A3, A4, A5, A6, A_7, A8,
    input  wire [7:0]  B0, B1, B2, B3, B4, B5, B6, B_7, B_8,
    output reg  [17:0] C_O, C1, C2, C3, C4, C5, C_6, C7, C8
);
    always @(posedge clk) begin
        if (rst) begin
            C_O <= 18'd0; C1 <= 18'd0; C2 <= 18'd0;
            C3  <= 18'd0; C4 <= 18'd0; C5 <= 18'd0;
            C_6 <= 18'd0; C7 <= 18'd0; C8 <= 18'd0;
        end else begin
            C_O <= (A0*B0) + (A1*B3) + (A2*B6);
            C1  <= (A0*B1) + (A1*B4) + (A2*B_7);
            C2  <= (A0*B2) + (A1*B5) + (A2*B_8);
            
            C3  <= (A3*B0) + (A4*B3) + (A5*B6);
            C4  <= (A3*B1) + (A4*B4) + (A5*B_7);
            C5  <= (A3*B2) + (A4*B5) + (A5*B_8);
            
            C_6 <= (A6*B0) + (A_7*B3) + (A8*B6);
            C7  <= (A6*B1) + (A_7*B4) + (A8*B_7);
            C8  <= (A6*B2) + (A_7*B5) + (A8*B_8);
        end
    end
endmodule