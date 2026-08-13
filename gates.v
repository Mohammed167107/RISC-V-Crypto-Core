module and_gate(
    input a,
    input b,
    output c
);

    assign c = a&b;

endmodule

module or_gate(
    input a,
    input b,
    output c
);

    assign c = a|b;

endmodule