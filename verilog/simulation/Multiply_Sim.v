module Multiply_Sim();

    reg[1:0] x, y;
    wire[1:0] result;
    
    Multiply mult(.x(x), .y(y), .result(result));
    
    initial begin
    
        x = 2'b10;
        y = 2'b11;
    
    end

endmodule
