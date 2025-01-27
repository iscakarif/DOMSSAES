module DepMultiplier_Sim();

    reg clk;
    reg[1:0] Ax, Ay, Az, Bx, By, Bz, Z;
    wire[1:0] Aq, Bq;  

    DepMultiplier dep (.clk(clk), .Ax(Ax), .Ay(Ay), .Az(Az), .Bx(Bx), .By(By), .Bz(Bz), .Z(Z), .Aq(Aq), .Bq(Bq));

    initial begin
        clk = 1'b0;
        forever #10 clk = ~clk;
    end
    
    initial begin    
        
        Ax = 2'd2; Ay = 2'd1; Az = 2'd3; Bx = 2'd3; By = 2'd1; Bz = 2'd1; Z = 2'd2;
        #100;
        
        $finish;
    end

endmodule
