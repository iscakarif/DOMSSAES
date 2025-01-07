module SquareScaler_Sim();
    
    reg[1:0] in;
    wire[1:0] out;
    
    SquareScaler sqsc (.in(in), .out(out));
    
    initial begin
    
        in = 2'b01;
    
    end
    
endmodule
