module SquareScaler_SIM();

    reg[1:0] in; 
    wire[1:0] out;  

    SquareScaler SquareScaler (.in(in), .out(out));
    
    initial begin
    
        in = 2'b00;
    
    end

endmodule
