module MatMul(
        input[63:0] in,
        input[15:0] matrix,
        output[63:0] out
    );
    
    genvar i;
    generate
        for(i = 0;  i < 16; i = i + 1) begin
            wire[3:0] in_slice = in[(i*4) +: 4];
            wire[3:0] res_slice;
            
            assign res_slice[3] = ^(in_slice & matrix[15:12]);
            assign res_slice[2] = ^(in_slice & matrix[11:8]);
            assign res_slice[1] = ^(in_slice & matrix[7:4]);
            assign res_slice[0] = ^(in_slice & matrix[3:0]);
            
            assign out[(i*4) +: 4] = res_slice;
            
        end
    endgenerate  
endmodule