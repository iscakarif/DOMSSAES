module Canright_Sim();

reg[3:0] in;
wire[3:0] out;

Canright canright (.in(in), .out(out));

initial begin

in = 4'h0; #100;
in = 4'h1; #100;
in = 4'h2; #100;
in = 4'h3; #100;
in = 4'h4; #100;
in = 4'h5; #100;
in = 4'h6; #100;
in = 4'h7; #100;
in = 4'h8; #100;
in = 4'h9; #100;
in = 4'hA; #100;
in = 4'hB; #100;
in = 4'hC; #100;
in = 4'hD; #100;
in = 4'hE; #100;
in = 4'hF; #100;

end

endmodule
