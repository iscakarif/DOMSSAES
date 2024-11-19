module Inverter_SIM();

    reg[1:0] in; 
    wire[1:0] out; 
    
    Inverter Inverter ( .in(in), .out(out)); 
    
    initial begin 

        in = 2'b10; #100;
    
    end
    

endmodule
