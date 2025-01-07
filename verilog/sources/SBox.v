module SBox(
    input clk,
    input[1:0] Z0, Z1,
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
    
    DepMultiplier dep (.clk(clk), .Ax(A1), .Ay(B1), .Bx(A0), .By(B0), .Z0(Z0), .Z1(Z1), .Aq(Amul), .Bq(Bmul));
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
    
endmodule
