module pc(
    input rst,
    input clk,
    input [31:0] Pcin,
    output reg [31:0] pc_out
);

    always@(posedge clk) begin
        if(~rst) begin
            pc_out <= 32'b0;
        end
        else
            pc_out<= Pcin;

    end

endmodule

module tb_pc;

    reg clk;
    reg [31:0] pc_in;
    wire [31:0] pc_out;

    initial begin
        clk=0;
        pc_in=32'habc0;
        #20;
        pc_in=32'hfff0;
        #25;
        pc_in=32'ha520;
    end
    always #5 clk <= ~clk;

    pc pc_test(.clk(clk),.Pcin(pc_in),.pc_out(pc_out));
endmodule