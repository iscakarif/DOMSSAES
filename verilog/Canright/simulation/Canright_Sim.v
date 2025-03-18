module Canright_Sim();

reg[3:0] in;
wire[3:0] out;

Canright canright (.in(in), .out(out));

initial begin

in = 4'h0; #10;
in = 4'h1; #10;
in = 4'h2; #10;
in = 4'h3; #10;
in = 4'h4; #10;
in = 4'h5; #10;
in = 4'h6; #10;
in = 4'h7; #10;
in = 4'h8; #10;
in = 4'h9; #10;
in = 4'hA; #10;
in = 4'hB; #10;
in = 4'hC; #10;
in = 4'hD; #10;
in = 4'hE; #10;
in = 4'hF; #10;
$finish;
end

endmodule
