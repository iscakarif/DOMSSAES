module SBox_Sim();

    reg clk, reset;
    reg[1:0] Z0, Z1, Z2, Z3, Z4, Z5;
    reg[3:0] A, B;
    wire[3:0] A_out, B_out;
    
    SBox sbox (.clk(clk), .Z0(Z0), .Z1(Z1), .Z2(Z2), .Z3(Z3), .Z4(Z4), .Z5(Z5), .A(A), .B(B), .A_out(A_out), .B_out(B_out));
    
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end
    
    initial begin
        reset = 1; 
        Z0 = 2'b00; Z1 = 2'b00; Z2 = 2'b00; Z3 = 2'b00; Z4 = 2'b00; Z5 = 2'b00; A = 4'b0000; B = 4'b0000;
        #20;
        
        reset = 0;
        Z0 = 2'b10; Z1 = 2'b01; Z2 = 2'b11; Z3 = 2'b01; Z4 = 2'b01; Z5 = 2'b10; A = 4'b0000; B = 4'b0101;
        #100;
        $stop;
    end

endmodule