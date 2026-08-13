module adder(
    input [31:0] pc_in,
    input [31:0] pc_4,
    output reg [31:0] pc_plus
);

    always @(*) begin
        pc_plus = pc_in + pc_4;
    end
endmodule