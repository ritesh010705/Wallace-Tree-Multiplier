module half_adder(
 input a, b,
 output sum, carry
);
 assign sum = a ^ b;
 assign carry = a & b;
endmodule
module full_adder(
 input a, b, cin,
 output sum, carry
);
 assign sum = a ^ b ^ cin;
 assign carry = (a & b) | (b & cin) | (a & cin);
endmodule
module RCWM (
 input clk,
 input rst, // synchronous, active-high
 input [3:0] a, b,
 output [7:0] product
18
);
 // ---------------- Stage 1: Input capture register ----------------
 reg [3:0] a_reg, b_reg;
 always @(posedge clk) begin
 if (rst) begin
 a_reg <= 4'b0;
 b_reg <= 4'b0;
 end else begin
 a_reg <= a;
 b_reg <= b;
 end
 end
 // ---------------- Stage 2: Combinational reduction ----------------
 wire [3:0] pp0, pp1, pp2, pp3;
 // Generate Partial Products
 assign pp0 = a_reg & {4{b_reg[0]}};
 assign pp1 = a_reg & {4{b_reg[1]}};
 assign pp2 = a_reg & {4{b_reg[2]}};
 assign pp3 = a_reg & {4{b_reg[3]}};
 // --- STAGE 1 REDUCTION ---
 // Reduced Wallace rule: Only use FAs on columns with 3 bits.
 // Minimize HAs in early stages.
 wire s_1_2, c_1_3;
 full_adder fa_1_2(pp0[2], pp1[1], pp2[0], s_1_2, c_1_3); // Col 2
 wire s_1_3, c_1_4;
 full_adder fa_1_3(pp0[3], pp1[2], pp2[1], s_1_3, c_1_4); // Col 3
 wire s_1_4, c_1_5;
 full_adder fa_1_4(pp1[3], pp2[2], pp3[1], s_1_4, c_1_5); // Col 4
 // --- STAGE 2 REDUCTION ---
 // Now reduce remaining terms and stage 1 carries
 wire s_2_3, c_2_4;
 full_adder fa_2_3(s_1_3, pp3[0], c_1_3, s_2_3, c_2_4); // Col 3
 wire s_2_4, c_2_5;
 full_adder fa_2_4(s_1_4, pp0[1] /*pass through*/, c_1_4, s_2_4, c_2_5); // Col 4
// Final column-by-column ripple-carry combine
 wire [7:0] product_comb;
 // Column 0
 assign product_comb[0] = pp0[0];
 // Column 1
 wire c_f1;
 half_adder ha_f1(pp0[1], pp1[0], product_comb[1], c_f1);
 // Column 2
 wire c_f2;
 full_adder fa_f2(s_1_2, c_f1, 1'b0, product_comb[2], c_f2);
 // Column 3
 wire c_f3;
 full_adder fa_f3(s_2_3, c_f2, 1'b0, product_comb[3], c_f3);
 // Column 4
 wire s_2_4_final, c_2_4_final;
 full_adder fa_col4_inst(s_1_4, pp2[2], c_1_4, s_2_4_final, c_2_4_final);
 wire c_f4;
 full_adder fa_f4(s_2_4_final, pp3[1], c_f3, product_comb[4], c_f4);
 // Column 5
 wire s_col5_stage1, c_col5_stage1;
 half_adder ha_col5(pp2[3], pp3[2], s_col5_stage1, c_col5_stage1);
 wire c_f5;
 full_adder fa_f5(s_col5_stage1, c_1_5, c_f4, product_comb[5], c_f5);
19
 // Column 6
 wire c_f6;
 full_adder fa_f6(pp3[3], c_col5_stage1, c_f5, product_comb[6], c_f6);
 // Column 7
 assign product_comb[7] = c_f6;

// ---------------- Stage 3: Output capture register ----------------
 reg [7:0] product_reg;
 always @(posedge clk) begin
 if (rst)
 product_reg <= 8'b0;
 else
 product_reg <= product_comb;
 end
 assign product = product_reg;
endmodule
module tb_RCWM_4x4;
 reg clk;
 reg rst;
 reg [3:0] a, b;
 wire [7:0] product;
 RCWM uut (
 .clk(clk),
 .rst(rst),
 .a(a),
 .b(b),
 .product(product)
 );
 // 10 ns period clock (100 MHz)
 initial clk = 0;
 always #5 clk = ~clk;
 integer i, j;
 initial begin
 // reset for a couple of cycles
 rst = 1;
 a = 0;
 b = 0;
 @(posedge clk);
 @(posedge clk);
 rst = 0;
 for (i = 0; i < 16; i = i + 1) begin
 for (j = 0; j < 16; j = j + 1) begin
 a = i; b = j;
 @(posedge clk); // edge 1: a,b captured into a_reg,b_reg
 @(posedge clk); // edge 2: product_comb captured -> product valid
 if (product !== a * b)
 $display("FAIL: %0d x %0d = %0d (expected %0d)", a, b, product, a*b);
 end
 end
 $display("All tests done.");
 $finish;
 end
endmodule

