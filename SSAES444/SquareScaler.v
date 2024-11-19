module SquareScaler(
        input[1:0] in, 
        output[1:0] out 
    );
    
    reg[1:0] scaler = 2'b10;
    wire[1:0] temp;
    
    GF22Mult mult1 (.x(in), .y(in), .result(temp));
    GF22Mult mult2 (.x(scaler), .y(temp), .result(out));
    
    
endmodule
