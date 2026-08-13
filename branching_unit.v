module branching_unit(
    input [31:0] op1,
    input [31:0] op2,
    input [2:0] func3,
    output reg true
);

    always @(*) begin
        
        case(func3)

            3'b000: begin
                if(op1 == op2)
                    true = 1;
                else
                    true = 0;
            end

            3'b001: begin
                if(op1 != op2)
                    true = 1;
                else
                    true = 0;
            end

            3'b100: begin
                if($signed(op1) < $signed(op2))
                    true = 1;
                else
                    true = 0;
            end

            3'b101: begin
                if($signed(op1) >= $signed(op2))
                    true = 1;
                else
                    true = 0;
            end

        endcase
    end

endmodule