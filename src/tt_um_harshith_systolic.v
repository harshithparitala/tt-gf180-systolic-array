`default_nettype none

module tt_um_harshith_systolic (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

    assign uio_oe  = 8'b0000_0001;
    assign uio_out = {7'b000_0000, (state == S_OUT)};

    localparam S_LOAD = 2'b00;
    localparam S_CALC = 2'b01;
    localparam S_OUT  = 2'b10;

    reg [1:0] state;
    reg [4:0] count;
    
    reg [7:0] mem_in  [0:17];
    reg [7:0] mem_out [0:26]; 
    wire [17:0] C [0:8];      

    matrix_mult core_array (
        .clk(clk),
        .rst(~rst_n),
        .A0(mem_in[0]), .A1(mem_in[1]), .A2(mem_in[2]),
        .A3(mem_in[3]), .A4(mem_in[4]), .A5(mem_in[5]),
        .A6(mem_in[6]), .A_7(mem_in[7]), .A8(mem_in[8]),
        .B0(mem_in[9]),  .B1(mem_in[10]), .B2(mem_in[11]),
        .B3(mem_in[12]), .B4(mem_in[13]), .B5(mem_in[14]),
        .B6(mem_in[15]), .B_7(mem_in[16]), .B_8(mem_in[17]),
        .C_O(C[0]), .C1(C[1]), .C2(C[2]),
        .C3(C[3]), .C4(C[4]), .C5(C[5]),
        .C_6(C[6]), .C7(C[7]), .C8(C[8])
    );

    always @(posedge clk) begin
        if (!rst_n) begin
            state <= S_LOAD;
            count <= 5'd0;
        end else begin
            case (state)
                S_LOAD: begin
                    mem_in[count] <= ui_in;
                    if (count == 5'd17) begin
                        count <= 5'd0;
                        state <= S_CALC;
                    end else begin
                        count <= count + 5'd1;
                    end
                end
                
                S_CALC: begin
                    if (count == 5'd1) begin       // Cycle 0: multiplier computes. Cycle 1: capture valid C.
                        state <= S_OUT;
                        count <= 5'd0;

                        mem_out[0]  <= C[0][7:0];  mem_out[1]  <= C[0][15:8];  mem_out[2]  <= {6'd0, C[0][17:16]};
                        mem_out[3]  <= C[1][7:0];  mem_out[4]  <= C[1][15:8];  mem_out[5]  <= {6'd0, C[1][17:16]};
                        mem_out[6]  <= C[2][7:0];  mem_out[7]  <= C[2][15:8];  mem_out[8]  <= {6'd0, C[2][17:16]};

                        mem_out[9]  <= C[3][7:0];  mem_out[10] <= C[3][15:8];  mem_out[11] <= {6'd0, C[3][17:16]};
                        mem_out[12] <= C[4][7:0];  mem_out[13] <= C[4][15:8];  mem_out[14] <= {6'd0, C[4][17:16]};
                        mem_out[15] <= C[5][7:0];  mem_out[16] <= C[5][15:8];  mem_out[17] <= {6'd0, C[5][17:16]};

                        mem_out[18] <= C[6][7:0];  mem_out[19] <= C[6][15:8];  mem_out[20] <= {6'd0, C[6][17:16]};
                        mem_out[21] <= C[7][7:0];  mem_out[22] <= C[7][15:8];  mem_out[23] <= {6'd0, C[7][17:16]};
                        mem_out[24] <= C[8][7:0];  mem_out[25] <= C[8][15:8];  mem_out[26] <= {6'd0, C[8][17:16]};
                    end else begin
                        count <= count + 5'd1;
                    end
                end
                
                S_OUT: begin
                    if (count == 5'd26) begin
                        count <= 5'd0;
                        state <= S_LOAD;
                    end else begin
                        count <= count + 5'd1;
                    end
                end
                
                default: begin
                    state <= S_LOAD;
                    count <= 5'd0;
                end
            endcase
        end
    end

    assign uo_out = (state == S_OUT) ? mem_out[count] : 8'd0;

endmodule