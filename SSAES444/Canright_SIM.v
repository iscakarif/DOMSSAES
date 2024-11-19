module Canright_SIM();

    reg[3:0] in;
    wire[3:0] out;
    
    Canright canright (.in(in), .out(out));
    
    initial begin
    
        in = 4'b0000; #100;
        in = 4'b0001; #100;
        in = 4'b0010; #100;
        in = 4'b0011; #100;
        in = 4'b0100; #100;
        in = 4'b0101; #100;
        in = 4'b0110; #100;
        in = 4'b0111; #100;
        in = 4'b1000; #100;
        in = 4'b1001; #100;
        in = 4'b1010; #100;
        in = 4'b1011; #100;
        in = 4'b1100; #100;
        in = 4'b1101; #100;
        in = 4'b1110; #100;
        in = 4'b1111; #100;
    
    end 


endmodule
