`timescale 1ns / 1ps

module clk_div2 (
  input clk_i,
  input rst,
  output reg clk_o
);

  always @(posedge clk_i) begin
    if (!rst)
      clk_o <= 1'b0;
    else
      clk_o <= ~clk_o;
  end

endmodule

module clk_div3 (
  input clk_i,
  input rst,
  output clk_o
);

  reg [1:0] pos_count, neg_count;
  wire [1:0] r_nxt;

  always @(posedge clk_i) begin
    if (!rst)
      pos_count <= 0;
    else if (pos_count == 2)
      pos_count <= 0;
    else
      pos_count <= pos_count + 1;
  end

  always @(negedge clk_i) begin
    if (!rst)
      neg_count <= 0;
    else if (neg_count == 2)
      neg_count <= 0;
    else
      neg_count <= neg_count + 1;
  end

  assign clk_o = ((pos_count == 2) | (neg_count == 2));

endmodule