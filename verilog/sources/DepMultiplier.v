module DepMultiplier(
    input clk, reset,
    input[1:0] Ax, Ay, Bx, By, Z0, Z1,
    output reg[1:0] Aq, Bq
    );
    
    parameter PHASE1 = 1'b0;
    parameter PHASE2 = 1'b1;
    
    reg state;
    reg[1:0] preAq, preBq, AyZ0, ByZ0, AyZ0_By, ByZ0_Ay;
    wire[1:0] AxZ0, BxZ0, AxZ0_Z1, BxZ0_Z1, Ay_Z0, By_Z0, AxAy_By, BxBy_Ay;
    
    NormalMultiplier mult1 (.x(Ax), .y(Z0), .result(AxZ0));
    NormalMultiplier mult2 (.x(Bx), .y(Z0), .result(BxZ0));
    
    assign AxZ0_Z1 = AxZ0 ^ Z1; 
    assign BxZ0_Z1 = BxZ0 ^ Z1; 
    
    assign Ay_Z0 = By ^ Z0;
    assign By_Z0 = Ay ^ Z0;
    
    wire [1:0] AyZ0_By_intermediate, ByZ0_Ay_intermediate;
    assign AyZ0_By_intermediate = AyZ0 ^ By;
    assign ByZ0_Ay_intermediate = ByZ0 ^ Ay;
    
    NormalMultiplier mult3 (.x(Ax), .y(AyZ0_By_intermediate), .result(AxAy_By));
    NormalMultiplier mult4 (.x(Bx), .y(ByZ0_Ay_intermediate), .result(BxBy_Ay));
    
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= PHASE1;
            preAq <= 2'b0;
            preBq <= 2'b0;
            AyZ0 <= 2'b0;
            ByZ0 <= 2'b0;
        end else begin
            case (state) 
            PHASE1: begin
            
                preAq <= AxZ0_Z1;
                preBq <= BxZ0_Z1;
                AyZ0 <= Ay_Z0;
                ByZ0 <= By_Z0;
                
                state <= PHASE2;
            end
            
            PHASE2: begin
                
                //AyZ0_By <= AyZ0 ^ By;
                //ByZ0_Ay <= ByZ0 ^ Ay;
                
                Aq <= preAq ^ AxAy_By;
                Bq <= preBq ^ BxBy_Ay;
                
                state <= PHASE1;
            end
            endcase
        end
    end
    
endmodule
