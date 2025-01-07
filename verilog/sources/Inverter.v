module Inverter(
    input  [1:0] in,   
    output [1:0] out  
);
    
    //--polynomial basis--//
    
    //assign out[1] = in[1];
    //assign out[0] = in[1] ^ in[0];

    
    //--normal basis--//

    assign out[1] = in[0];
    assign out[0] = in[1];

endmodule