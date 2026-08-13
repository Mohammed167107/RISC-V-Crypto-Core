module register_file(
    input clk,
    input wr_en,
    input [4:0] rs1, rs2,
    input [4:0] rd,
    input [31:0] rd_data,
    output [31:0] rs1_data, rs2_data
);

    reg [31:0] file [0:31];

    integer i;
    initial begin
        file[0] = 32'b0; 
        file[1] = 32'b0; 
        file[2] = 32'h00000FFF;
        for(i=3; i<32;i=i+1) begin
            file[i] = 32'b0; 
        end
    end

    always @(posedge clk)begin 
        if(wr_en)
            file[rd] <= rd_data;
        if(rd == 5'b00000)
            file[rd] <= 0;
    end

    assign rs1_data = file[rs1];
    assign rs2_data = file[rs2];


endmodule