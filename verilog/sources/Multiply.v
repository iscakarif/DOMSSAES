module Multiply(
    input[1:0] x,
    input[1:0] y,
    
    output[1:0] result
    );
    
    //assign result[1] = (x[1] & y[0]) ^ (x[0] & y[1]) ^ (x[1] & y[1]);
    //assign result[0] = (x[0] & y[0]) ^ (x[1] & y[1]);
    
    assign result[1] = ((x[0] ^ x[1]) & (y[0] ^ y[1])) ^ (x[0] & y[0]);
    assign result[0] = (x[1] & y[1]) ^ (x[0] & y[0]);
      
endmodule