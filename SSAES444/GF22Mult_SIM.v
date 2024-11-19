module GF22Mult_SIM();

    reg[1:0] x, y;
    wire[1:0] result;
    
    GF22Mult GF22Mult (.x(x), .y(y), .result(result));
    
    initial begin
        
        x = 2'b10; #100;
        y = 2'b10; #100; 
        
    end

endmodule
