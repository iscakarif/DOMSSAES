module Inverter_Sim();

    reg[1:0] in;
    wire[1:0] out;
    
    Inverter invert (.in(in), .out(out));
    
    initial begin
    
        in = 2'b10;
    
    end


endmodule
