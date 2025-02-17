module DepMultiplier(
    input clk,
    input[1:0] Ax, Ay, Az, Bx, By, Bz, Z,
    output[1:0] Aq, Bq
    );
    
    reg[1:0] A_in, B_in, AyAz, ByBz, AxAz, BxBz, AxBzZ, BxAzZ;
    wire[1:0] Ax_x_Az, Ax_x_Bz, Bx_x_Az, Bx_x_Bz, AxBz_Z, BxAz_Z, Ay_Az, By_Bz;
    
    NormalMultiplier mult1 (.x(Ax), .y(Az), .result(Ax_x_Az));
    NormalMultiplier mult2 (.x(Ax), .y(Bz), .result(Ax_x_Bz));
    NormalMultiplier mult3 (.x(Bx), .y(Az), .result(Bx_x_Az));
    NormalMultiplier mult4 (.x(Bx), .y(Bz), .result(Bx_x_Bz));
    
    assign AxBz_Z = Ax_x_Bz ^ Z;
    assign BxAz_Z = Bx_x_Az ^ Z;
    assign Ay_Az = Ay ^ Az;
    assign By_Bz = By ^ Bz;
    
    always @( clk ) begin
        
        A_in <= Ax;
        B_in <= Bx;
        AyAz <= Ay_Az;
        ByBz <= By_Bz;
        AxAz <= Ax_x_Az;
        BxBz <= Bx_x_Bz;
        AxBzZ <= AxBz_Z;
        BxAzZ <= BxAz_Z;
    
    end
    
    
    wire[1:0] AyAz_ByBz, Ax_x_AyBy, Bx_x_AyBy, Ax_Az, Bx_Bz;
    
    assign AyAz_ByBz = AyAz ^ ByBz;
    assign Ax_Az = AxAz ^ AxBzZ;
    assign Bx_Bz = BxBz ^ BxAzZ;
    
    NormalMultiplier mult5 (.x(A_in), .y(AyAz_ByBz), .result(Ax_x_AyBy));
    NormalMultiplier mult6 (.x(B_in), .y(AyAz_ByBz), .result(Bx_x_AyBy));
    
    
    
    assign Aq = Ax_Az ^ Ax_x_AyBy;
    assign Bq = Bx_Bz ^ Bx_x_AyBy;
    
    
endmodule
