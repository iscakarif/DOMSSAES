module depMultNoR(
    input   [1:0] ax, ay, bx, by,
    input   [1:0] z0, z1,
    
    output  [1:0] aq, bq
    );
    
    // aq = ax*(ay + (by + z0)) + (ax*z0 + z1)
    // bq = bx*(by + (ay + z0)) + (bx*z0 + z1)
    
    wire[1:0] axz0, bxz0, aybyz0, byayz0, aabz, bbaz;
    
    assign aybyz0 = (by ^ z0) ^ ay;
    assign byayz0 = (ay ^ z0) ^ by;
    
    NormalMultiplier mult1 (.x(ax), .y(z0), .result(axz0));
    NormalMultiplier mult2 (.x(bx), .y(z0), .result(bxz0));
    NormalMultiplier mult3 (.x(aybyz0), .y(ax), .result(aabz));
    NormalMultiplier mult4 (.x(byayz0), .y(bx), .result(bbaz));
    
    assign  aq = aabz ^ (axz0 ^ z1);
    assign  bq = bbaz ^ (bxz0 ^ z1);
    
    
endmodule