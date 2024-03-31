`timescale 1ns / 100ps

module multiply_32 #(
    parameter WIDTH = 32
) (
    input [WIDTH - 1:0] A,
    input [WIDTH - 1:0] B,
    output [WIDTH - 1:0] Result
);

  wire sign;
  wire [WIDTH - 25:0] exponent;
  wire [WIDTH - 10:0] mantissa;
  
  wire [WIDTH - 9:0] A_Mantissa_w_o, B_Mantissa_w_o;
  wire [WIDTH - 25:0] A_Exponent_w_o, B_Exponent_w_o;
  
  wire [47:0] Temp_Mantissa;
  wire [WIDTH - 25:0] Temp_Exponent;
  
  assign A_Mantissa_w_o = {1'b1, A[WIDTH - 10:0]};
  assign A_Exponent_w_o = A[WIDTH - 2:WIDTH - 9];
  assign B_Mantissa_w_o = {1'b1, B[WIDTH - 10:0]}; 
  assign B_Exponent_w_o = B[WIDTH - 2:WIDTH - 9];


  assign Temp_Exponent = (A == 30'b0 | B == 30'b0) ? 'b0 : A_Exponent_w_o + B_Exponent_w_o - 127;
  assign Temp_Mantissa = (A == 30'b0 | B == 30'b0) ? 'b0 : A_Mantissa_w_o * B_Mantissa_w_o;
  
  
  assign sign = (A == 30'b0 | B == 30'b0) ? 'b0 :(A[WIDTH - 1] ^ B[WIDTH - 1]);
  assign exponent = (Temp_Mantissa[47] ? Temp_Exponent + 1'b1 : Temp_Exponent);
  assign mantissa = Temp_Mantissa[47] ? Temp_Mantissa[46:24] : Temp_Mantissa[45:23];
  
  assign Result = {sign, exponent, mantissa};

endmodule