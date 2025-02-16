module domSBoxNoR(
    input   [3:0] a, b,
    input   [11:0] r_bits,
    
    output  [3:0] aq, bq
    );
    
    wire[3:0] ain_tf, bin_tf, aout_tf, bout_tf, preaq, prebq;
    wire[1:0] a1, a0, b1, b0, a01, b01, ass, bss, faq, fbq, paxd, pbxd, inva, invb;
    
    MatMul ai_tf (.in(a), .matrix(16'h5739), .out(ain_tf)); 
    MatMul bi_tf (.in(b), .matrix(16'h5739), .out(bin_tf));
    
    assign a1 = ain_tf[3:2];
    assign a0 = ain_tf[1:0];
    assign b1 = bin_tf[3:2];
    assign b0 = bin_tf[1:0];
    
    assign a01 = a0 ^ a1;
    assign b01 = b0 ^ b1;
    
    SquareScaler as (.in(a01), .out(ass));
    SquareScaler bs (.in(b01), .out(bss));
    depMultNoR g0g1 (.ax(a1), .ay(a0), .bx(b1), .by(b0), .z0(r_bits[01:00]), .z1(r_bits[03:02]), .aq(faq), .bq(fbq));
    
    assign paxd = ass ^ faq;
    assign pbxd = bss ^ fbq;
    
    Inverter inv1 (.in(paxd), .out(inva));
    Inverter inv2 (.in(pbxd), .out(invb));
    depMultNoR g1x1 (.ax(a1), .ay(inva), .bx(b1), .by(invb), .z0(r_bits[05:04]), .z1(r_bits[07:06]), .aq(aout_tf[1:0]), .bq(bout_tf[1:0]));
    depMultNoR g0x0 (.ax(inva), .ay(a0), .bx(invb), .by(b0), .z0(r_bits[09:08]), .z1(r_bits[11:10]), .aq(aout_tf[3:2]), .bq(bout_tf[3:2]));
    MatMul ao_tf (.in(aout_tf), .matrix(16'hD754), .out(preaq));
    MatMul bo_tf (.in(bout_tf), .matrix(16'hD754), .out(prebq));    
    
    assign aq = preaq ^ 4'h6;
    assign bq = prebq;
    
endmodule
