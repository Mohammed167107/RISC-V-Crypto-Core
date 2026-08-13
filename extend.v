module extend(
    input [11:0] imm,
    output [31:0] imm_ext
);

    assign imm_ext = {{20{imm[11]}}, imm[11:0]};
endmodule

module extend_B(
    input [11:0] imm,
    output [31:0] imm_ext
);

    assign imm_ext = {{19{imm[11]}}, imm[11:0], 1'b0};
endmodule

module extend_20bits_j(
    input [19:0] imm,
    output [31:0] imm_ext
);

    assign imm_ext = {{11{imm[19]}}, imm[19:0],1'b0};
endmodule