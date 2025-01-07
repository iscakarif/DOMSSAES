module MatMul_Sim();

reg[63:0] in;
reg[15:0] matrix;
wire[63:0] out;

MatMul matmul (.in(in), .matrix(matrix), .out(out));

initial begin 
    
    matrix = 16'b1011110111100111;
    in = 4'h0; #100;
    
    $stop; 
     
end
endmodule
