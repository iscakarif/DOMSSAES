module DepMultiplier_Sim();

    reg clk, reset;
    reg[1:0] Ax, Ay, Bx, By, Z0, Z1;
    wire[1:0] Aq, Bq;  

    DepMultiplier dep (.clk(clk), .reset(reset), .Ax(Ax), .Ay(Ay), .Bx(Bx), .By(By), .Z0(Z0), .Z1(Z1), .Aq(Aq), .Bq(Bq));

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end
    
    initial begin 
        
        //Initialize inputs
        reset = 1;
        Ax = 2'b00; Ay = 2'b00; Bx = 2'b00; By = 2'b00; Z0 = 2'b00; Z1 = 2'b00;
        #10;
        
        reset = 0;
        
        Ax = 2'b10; Ay = 2'b01; Bx = 2'b01; By = 2'b10; Z0 = 2'b01; Z1 = 2'b10;
        #20;
        
        $stop;
    end

endmodule
