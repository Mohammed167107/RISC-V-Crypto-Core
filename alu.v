module alu(
    input [31:0] op1,
    input [31:0] op2,
    input [4:0] alu_cont,
    input [19:0] imm_u,
    output reg [31:0] alu_result
    );
    reg [63:0] mul_r;
    reg [31:0] imm_u_ex;
    always @(*) begin
        mul_r = op1 * op2;
        imm_u_ex = {10'b0,imm_u};
        case(alu_cont)
            5'b00000: alu_result = op1 + op2;
            5'b00001: alu_result = op1 - op2;
            5'b00010: alu_result = op1 ^ op2;    
            5'b00011: alu_result = op1 | op2; 
            5'b00100: alu_result = op1 & op2;
            5'b00101: alu_result = op1 << op2[4:0];
            5'b00110: alu_result = op1 >> op2[4:0];
            5'b00111: alu_result = $signed(op1) >>> op2[4:0];
            5'b01000: alu_result = ($signed(op1) < $signed(op2)) ? 32'd1 : 32'd0;
            5'b01001: alu_result = (op1 < op2) ? 32'd1 : 32'd0;
            5'b01010: alu_result = mul_r[31:0];
            5'b01011: alu_result = mul_r[63:32];
            5'b01100: alu_result = $signed(mul_r[63:32]);
            5'b01101: alu_result = mul_r[63:32];
            5'b01110: alu_result = $signed(op1 / op2);
            5'b01111: alu_result = op1 / op2;
            5'b10000: alu_result = $signed(op1 % op2);
            5'b10001: alu_result = op1 % op2;
            5'b10010: alu_result = imm_u_ex << 12;
            5'b10011: begin 
                    alu_result = imm_u_ex << 12;
                    alu_result = alu_result + op1; 
                end
        endcase
    end
endmodule