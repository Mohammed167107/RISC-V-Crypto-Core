module instructionMemory(
    input [31:0] address,
    input clk,
    output reg [31:0] q
);

    reg [31:0] IM [2047:0];

    initial begin
        $readmemh("instructions.hex",IM);
    end

    always @(*) begin

        q = IM[address>>2];
        
    end
endmodule


module instructionMemory_tb;

    // Inputs
    reg [31:0] address;
    reg clk;

    // Outputs
    wire [31:0] q;

    // Instantiate the Unit Under Test (UUT)
    instructionMemory uut (
        .address(address), 
        .clk(clk), 
        .q(q)
    );

    // Clock generation (10ns period -> 100MHz)
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        address = 0;


        #10;
        
        // --- Test Sequence ---

        address = 32'h0000000c;
        #10;

        address = 32'h00000004;
        #10;

        address = 32'h00000008;
        #10;

        address = 32'h00000000;
        #10;

        address = 32'd52;
        #10;


        // End simulation
        $display("Testbench complete. Check waveforms for 'q' values.");
        $finish;
    end

endmodule