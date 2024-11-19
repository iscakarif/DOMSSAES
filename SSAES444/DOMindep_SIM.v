
module DOMindep_SIM();

    reg[1:0] Ax, Ay, Bx, By, Z;    
    wire[1:0] Aq, Bq;

    
    DOMindep DOMindep (.Ax(Ax), .Ay(Ay), .Bx(Bx), .By(By), .Z(Z), .Aq(Aq), .Bq(Bq));
    
    initial begin
        Z = 2'b0;
        Ax = 2'b01;
        Ay = 2'b01;
        Bx = 2'b01;
        By = 2'b01;
    end

endmodule
