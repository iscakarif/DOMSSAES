module NormalMultiplier_Sim();

    reg [1:0] x, y;
    wire [1:0] result;
    
    NormalMultiplier mult (.x(x), .y(y), .result(result));

    initial begin

        x = 2'b01; y = 2'b10;
        #10;


        x = 2'b10; y = 2'b11;
        #10;


        x = 2'b11; y = 2'b01;
        #10;
        
        x = 2'b11; y = 2'b11;
        #10;
        
        x = 2'b01; y = 2'b01;
        #10;
        
        x = 2'b10; y = 2'b10;
        #10;

        $stop;
    end
endmodule
