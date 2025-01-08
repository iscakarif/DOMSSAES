module SBox(
    input clk, reset,
    input[1:0] Z0, Z1, Z2, Z3, Z4, Z5,
    input[3:0] A, B,
    output[3:0] A_out, B_out
    );
    
    reg[1:0] regA1, regA0, regB1, regB0, Ascl, Bscl, Adep, Bdep; 
    
    wire[3:0] A_tf, B_tf;
    wire[1:0] A1, A0, B1, B0, A1_A0, B1_B0, A_scaled, B_scaled, Amul, Bmul;
    
    MatMul transform_A (.in(A), .matrix(16'h8421), .out(A_tf));
    MatMul transform_B (.in(B), .matrix(16'h8421), .out(B_tf));
    
    assign A1 = A_tf[3:2];
    assign A0 = A_tf[1:0];
    assign B1 = B_tf[3:2];
    assign B0 = B_tf[1:0];
    
    assign A1_A0 = A1 ^ A0;
    assign B1_B0 = B1 ^ B0;
    
    DepMultiplier dep (.clk(clk), .reset(), .Ax(A1), .Ay(B1), .Bx(A0), .By(B0), .Z0(Z0), .Z1(Z1), .Aq(Amul), .Bq(Bmul));
    SquareScaler sclA (.in(A1_A0), .out(A_scaled)); 
    SquareScaler sclB (.in(B1_B0), .out(B_scaled));
    
    
    always @(posedge clk) begin        
        regA1 <= A1;
        regA0 <= A0;
        regB1 <= B1;
        regB0 <= B0;
        Ascl <= A_scaled;
        Bscl <= B_scaled;
        Adep <= Amul;
        Bdep <= Bmul;  
    end
    
    
    reg[1:0] Adep_0, Adep_1, Bdep_0, Bdep_1;
    
    wire[1:0] Ascl_Amul, Bscl_Bmul, Ainv, Binv, Amul_1, Amul_0, Bmul_1, Bmul_0, A_retf, B_retf;
    
    assign Ascl_Amul = Ascl ^ Adep;
    assign Bscl_Bmul = Bscl ^ Bdep;
    
    Inverter invert_A (.in(Ascl_Amul), .out(Ainv));
    Inverter invert_B (.in(Bscl_Bmul), .out(Binv));
    
    DepMultiplier dep_A (.clk(clk), .reset(), .Ax(regA1), .Ay(regB1), .Bx(Ainv), .By(Binv), .Z0(Z2), .Z1(Z3), .Aq(Amul_1), .Bq(Amul_0));     
    DepMultiplier dep_B (.clk(clk), .reset(), .Ax(Ainv), .Ay(Binv), .Bx(regA0), .By(regB0), .Z0(Z4), .Z1(Z5), .Aq(Bmul_1), .Bq(Bmul_0));
    
    
    always @(posedge clk) begin  
        Adep_0 <= Amul_0;
        Adep_1 <= Amul_1;
        Bdep_0 <= Bmul_0;
        Bdep_1 <= Bmul_1;
    end
    
    
    wire[3:0] A_outtf, B_outtf;
    
    assign A_outtf = {Adep_1[1:0], Bdep_1[1:0]};
    assign B_outtf = {Adep_0[1:0], Bdep_0[1:0]};
    
    MatMul retransform_A (.in(A_outtf), .matrix(16'h8421), .out(A_retf));
    MatMul retransform_B (.in(B_outtf), .matrix(16'h8421), .out(B_retf));
    
    assign A_out = A_retf ^ 4'h6;
    assign B_out = B_retf ^ 4'h6;
    
endmodule
