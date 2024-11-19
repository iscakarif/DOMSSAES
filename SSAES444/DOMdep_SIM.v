module DOMdep_SIM();
    
    reg[1:0] Ax, Bx, Ay, By, Az, Bz, Z;
    wire[1:0] Aq, Bq;
    
    DOMdep dom(.Ax(Ax), .Ay(Ay), .Az(Az), .Bx(Bx), .By(By), .Bz(Bz), .Z(Z), .Aq(Aq), .Bq(Bq));
    
    
    initial begin 
    
       Ax = 2'd3;
       Ay = 2'd1;
       Bx = 2'd0;
       By = 2'd2;
       
       Az = 2'd0;
       Bz = 2'd0;
       Z = 2'd0;    
    
    end
    
    
endmodule
