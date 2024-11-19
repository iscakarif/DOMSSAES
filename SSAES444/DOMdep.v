module DOMdep(
    input[1:0] Ax, Ay, Az, Bx, By, Bz, Z,
    output[1:0] Aq,Bq
    );
    
    wire[1:0] temp1, temp2, temp3;
    
    assign temp1 = Ay ^ Az;
    assign temp2 = By ^ Bz;
    assign temp3 = temp1 ^ temp2;
    
    wire[1:0] intres1, intres2, intres3, intres4;
    
    GF22Mult mult1 (.x(temp3), .y(Ax), .result(intres1));
    GF22Mult mult2 (.x(temp3), .y(Bx), .result(intres2));
    
    DOMindep dom (.Ax(Ax), .Ay(Az), .Bx(Bx), .By(Bz), .Z(Z), .Aq(intres3), .Bq(intres4));
    
    assign Aq = intres1 ^ intres3;
    assign Bq = intres2 ^ intres4;
    
    //register-stages missing
    
endmodule
