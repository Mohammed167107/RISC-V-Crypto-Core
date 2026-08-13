module data_mem (
    input test_button,
    output reg [31:0] data_seg_test,
    input clk,
    input [31:0] address,
    input [2:0] func3,
    input [31:0] rg2,
    input wr_en,
    input rd_en,
    output reg [31:0] data_out
);
    reg   [7:0] memory[0:16383]; //////////// make back to 16k or 64k instead
    
    initial begin
        $readmemh("dmem.hex",memory);
    end

    wire [1:0] memsize = func3[1:0];

    always @(posedge clk) begin
        if(wr_en) begin
            case(memsize)
                2'b00:
                    memory[address[31:0]] = rg2[7:0];       ////////////// should fix that back to 32-bits
                2'b01: begin
                    memory[address[31:0]] = rg2[7:0];
                    memory[address[31:0]+1] = rg2[15:8];
                end
                2'b10: begin 
                    memory[address[31:0]] = rg2[7:0];
                    memory[address[31:0]+1] = rg2[15:8];
                    memory[address[31:0]+2] = rg2[23:16];
                    memory[address[31:0]+3] = rg2[31:24];
                end
            endcase
        end
    end
    always @(*) begin
		data_seg_test = memory[4];
        case(func3)
             
             3'b000:
                data_out = {{24{memory[address[31:0]][7]}}, memory[address[31:0]]};
            3'b001: begin
                data_out = {{16{memory[address[31:0]+1][7]}}, memory[address[31:0]+1], memory[address[31:0]]};
            end
            3'b010: begin
                data_out = {memory[address[31:0]+3], memory[address[31:0]+2], memory[address[31:0]+1], memory[address[31:0]]};
            end
            3'b100: begin
                data_out = {24'b0, memory[address[31:0]]};
            end
            3'b101: begin
                data_out = {16'b0, memory[address[31:0]+1], memory[address[31:0]]};
            end
            default:
                data_out = 32'b0;  // optional, but explicit is nice
            endcase
    end

endmodule