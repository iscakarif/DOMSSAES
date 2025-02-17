module MatMul(
        input[3:0] in,
        input[15:0] matrix,
        output[3:0] out
    );
    
    assign out[3] = ^(in & matrix[15:12]);
    assign out[2] = ^(in & matrix[11:8]);
    assign out[1] = ^(in & matrix[7:4]);
    assign out[0] = ^(in & matrix[3:0]);
 
endmodule