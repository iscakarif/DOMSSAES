module GF22Mult(
    input[1:0] x,
    input[1:0] y,
    
    output[1:0] result
    );
    
    function [1:0] gf22mult(input [1:0] x, input [1:0] y);
        reg[1:0] temp;
        begin
            temp[1] = (x[1] & y[0]) ^ (x[0] & y[1]) ^ (x[1] & y[1]);
            temp[0] = (x[0] & y[0]) ^ (x[1] & y[1]);
            
            gf22mult = temp[1:0];
        end
    endfunction
    
    wire[1:0] temp = gf22mult(x, y);
    assign result = temp;
    
endmodule
