module NormalMultiplier(
    input[1:0] x, y,
    output[1:0] result
    );
    
    wire input_unknown;
    assign input_unknown = (^x === 1'bx || ^y === 1'bx);
    
    assign result[1] = input_unknown ? 1'bX : ((x[1] ^ x[0]) & (y[1] ^ y[0])) ^ (x[1] & y[1]);
    assign result[0] = input_unknown ? 1'bX : ((x[1] ^ x[0]) & (y[1] ^ y[0])) ^ (x[0] & y[0]);
    
endmodule