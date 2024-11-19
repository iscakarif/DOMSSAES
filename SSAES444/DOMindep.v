module DOMindep(
    input[1:0] Ax, Ay, Bx, By, Z,
    output[1:0] Aq, Bq
    );
    
    wire[1:0] Axy;
    wire[1:0] AxBy;
    wire[1:0] AyBx;
    wire[1:0] Bxy;
    wire[1:0] AxByZ;
    wire[1:0] AyBxZ;
    
    GF22Mult mult1 ( .x(Ax), .y(Ay), .result(Axy));
    GF22Mult mult2 ( .x(Bx), .y(By), .result(Bxy));
    GF22Mult mult3 ( .x(Ax), .y(By), .result(AxBy));
    GF22Mult mult4 ( .x(Bx), .y(Ay), .result(AyBx));
    
    assign AxByZ = AxBy[1:0] ^ Z[1:0];
    assign AyBxZ = AyBx[1:0] ^ Z[1:0];
    
    assign Aq = AxBy[1:0] ^ Axy[1:0];
    assign Bq = AyBx[1:0] ^ Bxy[1:0];
    
    //register-stages missing
    
endmodule
