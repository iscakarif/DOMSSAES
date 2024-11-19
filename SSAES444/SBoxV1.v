module SBoxV1(
    input[3:0] Ain, Bin,
    output[3:0] Aout, Bout
    );
    
    wire[1:0] Az, Bz, Z, Aq, Bq;
    assign Az = 2'b0;
    assign Bz = 2'b0;
    assign Z = 2'b0;
    
    
    wire[1:0] intA0, intA1, intB0, intB1;
    
    assign intA0 = Ain[1:0]; assign intA1 = Ain[3:2];
    assign intB0 = Bin[1:0]; assign intB1 = Bin[3:2];
    
    wire[1:0] intA01, intB01;
    
    assign intA01 = intA0 ^ intA1;
    assign intB01 = intB0 ^ intB1;
    
    DOMdep dom1 (.Ax(intA1), .Ay(intB1), .Bx(intA0), .By(intB0), .Az(Az), .Bz(Bz), .Z(Z), .Aq(Aq), .Bq(Bq));
    SquareScaler sq1 (.in(intA01), .out(intA01));
    SquareScaler sq2 (.in(intB01), .out(intB01));
    
    //register-stage
    
    wire[1:0] int0, int1;
    
    assign int0 = intA01 ^ Aq;
    assign int1 = intB01 ^ Bq; 
    
    Inverter inv1 (.in(int0), .out(int0));
    Inverter inv2 (.in(int1), .out(int1));
    
    wire[1:0] Aq1, Aq2, Bq1, Bq2;
    
    DOMdep dom2 (.Ax(intA1), .Ay(intB1), .Bx(int1), .By(int0), .Az(Az), .Bz(Bz), .Z(Z), .Aq(Aq1), .Bq(Bq1));
    DOMdep dom3 (.Ax(int0), .Ay(int1), .Bx(intA0), .By(intB0), .Az(Az), .Bz(Bz), .Z(Z), .Aq(Aq2), .Bq(Bq2));
    
    // register-stage
    
    assign Aout = {Aq1, Aq2};
    assign Bout = {Bq1, Bq2};
    
    // Currently only GF(2^4)-Inverter
    // lin-map and registers missing and not tested!
    
endmodule
