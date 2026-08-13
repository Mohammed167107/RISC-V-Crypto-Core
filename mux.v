module mux2_to_1(
    input s,
    input [31:0] a,
    input [31:0] b,
    output reg [31:0] c
);

    always @(*) begin
        case(s)
            0: c=a;
            1: c=b;
        endcase
    end
endmodule

module mux3_to_1(
    input [1:0] s,
    input [31:0] a,
    input [31:0] b,
    input [31:0] c,
    output reg [31:0] d
);

    always @(*) begin
        case(s)
            2'b00: d=a;
            2'b01: d=b;
            2'b10: d=c;
        endcase
    end
endmodule

module mux2_to_1_12bit(
    input s,
    input [11:0] a,
    input [11:0] b,
    output reg [11:0] c
);

    always @(*) begin
        case(s)
            0: c=a;
            1: c=b;
        endcase
    end
endmodule

module mux2_to_1_5bit(
    input s,
    input [4:0] a,
    input [4:0] b,
    output reg [4:0] c
);

    always @(*) begin
        case(s)
            0: c=a;
            1: c=b;
        endcase
    end
endmodule