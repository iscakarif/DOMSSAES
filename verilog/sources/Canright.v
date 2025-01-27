module Canright(
    input[3:0] in,
    output[3:0] out
    );
    
    wire[3:0] in_tf, out_tf, temp;
    wire[1:0] y0, y1, y1_xor_y0, y1_mul_y0, scaled, y0y1_xor_scaled, inverse, res0, res1;
    
    MatMul transform_in (.in(in), .matrix(16'h5739), .out(in_tf)); 
    
    assign y1 = in_tf[3:2];
    assign y0 = in_tf[1:0]; 
    assign y1_xor_y0 = y1 ^ y0;
    
    NormalMultiplier mult1 (.x(y1), .y(y0), .result(y1_mul_y0));
    SquareScaler sqscl (.in(y1_xor_y0), .out(scaled));
    
    assign y0y1_xor_scaled = scaled ^ y1_mul_y0;
    
    Inverter inv (.in(y0y1_xor_scaled), .out(inverse));
     
    NormalMultiplier mult2 (.x(inverse), .y(y0), .result(res1));
    NormalMultiplier mult3 (.x(inverse), .y(y1), .result(res0)); 
    
    assign out_tf[3:2] = res1;
    assign out_tf[1:0] = res0;
    
    MatMul transform_out (.in(out_tf), .matrix(16'hD754), .out(temp));  // D754 = F6CE * GF(2)-linearmap (BDE7) 
    
    assign out[3:0] = temp[3:0] ^ 4'h6; 
     
endmodule



/*
---Matrix Pairs---

5739 & F6CE

31D7 & F93B

1DFB & F368

FB1D & FC92

*/
