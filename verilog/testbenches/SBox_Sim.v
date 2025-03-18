module SBox_Sim();

    reg clk;
    reg[1:0] Z0, Z1, Z2, Az0, Az1, Az2, Bz0, Bz1, Bz2;
    reg[3:0] A, B;
    wire[3:0] A_out, B_out;
    
    SBox sbox (.clk(clk), .Z0(Z0), .Z1(Z1), .Z2(Z2), .Az0(Az0), .Az1(Az1), .Az2(Az2), .Bz0(Bz0), .Bz1(Bz1), .Bz2(Bz2), .A(A), .B(B), .A_out(A_out), .B_out(B_out));
    
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end
    
    initial begin
        
        Az0 = 2'd1; Az1 = 2'd3; Az2 = 2'd0; Bz0 = 2'd3; Bz1 = 2'd1; Bz2 = 2'd2; Z0 = 2'd2; Z1 = 2'd0; Z2 = 2'd1; A = 4'd0; B = 4'd0; 
        
        #100;
        
        $finish;
        
    end

endmodule
