module SubText_Sim();

    reg clk;
    reg[95:0] az, bz, z;
    reg[63:0] a, b;
    wire[63:0] aq, bq;
    
    SubText st (.clk(clk), .az(az), .bz(bz), .z(z), .a(a), .b(b), .aq(aq), .bq(bq));
    
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end
    
    initial begin
    
        az = 96'h40aae997566b5d15efc9ea95;     
        bz = 96'h72328ed3bcf5fe5cebee1d54;     
         z = 96'h674c4e573fa97b4b7429f208;

         
        a = 64'h0;
        b = 64'h0; 
        
        #20;
        
        
        a = 64'h0;
        b = 64'h0;
        
        
        #20;
        
        
        b = 64'hfedcba9876543210;
        a = 64'h0;
        
        #100;
        
        
        $finish;
    end

endmodule