module Inverter(
    input  [1:0] in,   
    output [1:0] out  
);
    
    GF22Mult mult (.x(in), .y(in), .result(out));


endmodule
