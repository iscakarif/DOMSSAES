module PolyCanright(
    input[3:0] in,
    output[3:0] out
    );
    
    wire[1:0] y1, y0, y1_y0, y0y01, scale, scl_y0y01, inverse;
    
    assign y1 = in[3:2];
    assign y0 = in[1:0];
    assign y1_y0 = y0 ^ y1;
    
    Multiply mult1 (.x(y0), .y(y1_y0), .result(y0y01));
    SquareScaler scl (.in(y1), .out(scale));
    
    assign scl_y0y01 = y0y01 ^ scale;
    
    Inverter inv (.in(scl_y0y01), .out(inverse));
    Multiply delta1 (.x(y1), .y(inverse), .result(out[3:2]));
    Multiply delta0 (.x(y1_y0), .y(inverse), .result(out[1:0]));
    
endmodule
