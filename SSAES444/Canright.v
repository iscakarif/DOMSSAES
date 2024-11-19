module Canright(
    input[3:0] in,
    output[3:0] out
    );
    
    wire[1:0] int0, int1, int2, int3, int4, int5, int6;
    
    assign int0 = in[1:0];
    assign int1 = in[3:2];
    assign int2 = int0 ^ int1;
    
    GF22Mult mult1 (.x(int0), .y(int1), .result(int3));
    SquareScaler sq (.in(int2), .out(int4));
    
    assign int5 = int3 ^ int4;
    
    Inverter inv (.in(int5), .out(int6));
    
    wire[1:0] res0, res1;
    
    GF22Mult mult2 (.x(int6), .y(int0), .result(res1));
    GF22Mult mult3 (.x(int6), .y(int1), .result(res0));
    
    assign out = {res1, res0};
     
endmodule
