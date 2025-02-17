module SBox(
    input clk, rst,
    input[1:0] Az0, Bz0, Az1, Bz1, Az2, Bz2, Z0, Z1, Z2,
    input[3:0] A, B, round,
    
    output reg[3:0] A_out, B_out
    );
    
    reg[1:0] ra1, ra0, rb1, rb0, asqsc, bsqsc, doma, domb, ra_1, ra_0, rb_1, rb_0;
    
    wire[3:0] a_in_tf, b_in_tf, a_out_tf, b_out_tf, a_pretf, b_pretf, aq_final, bq_final;
    wire[1:0] a1, a0, b1, b0, a01, b01, ass, bss, aq, bq, apre, bpre, ainv, binv, a_1, b_1, a_0, b_0, wa_1, wa_0, wb_1, wb_0, wa1, wa0, wb1, wb0, wass, wbss, waq, wbq;
    

    always @( posedge clk ) begin

        ra1 <= a1;
        ra0 <= a0;
        rb1 <= b1;
        rb0 <= b0;
        asqsc <= ass;
        bsqsc <= bss;
        doma <= aq;
        domb <= bq;
        ra_1 <= a_1;
        ra_0 <= a_0;
        rb_1 <= b_1;
        rb_0 <= b_0;
        
        A_out <= aq_final;
        B_out <= bq_final;

    end 
    
    
    MatMul ai_tf (.in(A), .matrix(16'h5739), .out(a_in_tf)); 
    MatMul bi_tf (.in(B), .matrix(16'h5739), .out(b_in_tf));
    
    assign a1 = a_in_tf[3:2];
    assign a0 = a_in_tf[1:0];
    assign b1 = b_in_tf[3:2];
    assign b0 = b_in_tf[1:0];
    
    assign a01 = a1 ^ a0;
    assign b01 = b1 ^ b0;
    
    SquareScaler a_sqscale (.in(a01), .out(ass));
    SquareScaler b_sqscale (.in(b01), .out(bss));
    DepMultiplier mult01 (.clk(clk), .Ax(a1), .Ay(a0), .Bx(b1), .By(b0), .Az(Az0), .Bz(Bz0), .Z(Z0), .Aq(aq), .Bq(bq));
      
    assign waq = doma;
    assign wbq = domb;
    assign wa1 = ra1;
    assign wa0 = ra0;
    assign wb1 = rb1;
    assign wb0 = rb0;
    assign wass = asqsc;
    assign wbss = bsqsc;
    
    assign apre = waq ^ wass;
    assign bpre = wbq ^ wbss;
    
    Inverter inv1 (.in(apre), .out(ainv));
    Inverter inv2 (.in(bpre), .out(binv));
    DepMultiplier multOx1 (.clk(clk), .Ax(wa1), .Ay(ainv), .Bx(wb1), .By(binv), .Az(Az1), .Bz(Bz1), .Z(Z1), .Aq(a_1), .Bq(b_1));
    DepMultiplier multOx0 (.clk(clk), .Ax(ainv), .Ay(wa0), .Bx(binv), .By(wb0), .Az(Az2), .Bz(Bz2), .Z(Z2), .Aq(a_0), .Bq(b_0));
    
    assign wa_1 = ra_1;
    assign wa_0 = ra_0;
    assign wb_1 = rb_1;
    assign wb_0 = rb_0;
    
    assign a_pretf = {wa_0, wa_1};
    assign b_pretf = {wb_0, wb_1};
    
    MatMul ao_tf (.in(a_pretf), .matrix(16'hD754), .out(a_out_tf));
    MatMul bo_tf (.in(b_pretf), .matrix(16'hD754), .out(b_out_tf));
    
    assign aq_final = a_out_tf ^ 4'h6;
    assign bq_final = b_out_tf;
    
endmodule
