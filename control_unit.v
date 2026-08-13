module control_unit(
    input [6:0] opCode,
    input [2:0] func3,
    input [6:0] func7,
    output reg reg_wr_en,
    output reg alu_op1,
    output reg s_e,
    output reg alu_src,
    output reg [4:0] alu_cont,
    output reg mem_rd_en,
    output reg mem_wr_en,
    output reg [1:0] wb_mux,
    output reg rg_s,
    output reg br,
    output reg jal,
    output reg jalr,
    output reg bj_mux
);

    /*
        alu control:

        op      alu_cont    func3
        add:    0000        000    
        sub:    0001        000
        xor:    0010        100
        or:     0011        110
        and:    0100        111
        sll:    0101        001
        srl:    0110        101
        sra:    0111        101
        slt:    1000        010, 011
        mul     1010        000
        mulh    1011        001
        mulsu   1100        010
        mulu    1101        011
        div     1110        100
        divu    1111        101
        rem                 110
        remu                111
    
    */

    always @(*) begin
        case (opCode)
            7'b0110011: begin //// r-type
                alu_op1 = 1'b0;
                br = 0;
                jal = 0;
                jalr = 0;
                rg_s = 1;
                reg_wr_en = 1;
                alu_src = 0;
                mem_rd_en = 0;
                mem_wr_en = 0;
                wb_mux = 2'b01;
                bj_mux = 0; 
                case (func3) 
                    3'b000: begin
                        case (func7)
                            7'b0000000: alu_cont=5'b00000;
                            7'b0000001: alu_cont=5'b01010;
                            7'b0100000: alu_cont=5'b00001;
                        endcase
                    end
                    3'b001: begin
                        case(func7)
                            7'b0000001: alu_cont=5'b01011;
                            7'b0000000: alu_cont=5'b00101;
                        endcase
                     end  
                    3'b010: begin
                        case(func7)
                            7'b0000001: alu_cont=5'b01100;  
                            7'b0000000: alu_cont=5'b01000;
                        endcase  ///  slt
                    end
                    3'b011: begin
                        case(func7)
                            7'b0000001: alu_cont=5'b01101;  
                            7'b0000000: alu_cont=5'b01001;
                        endcase  ///  sltu
                    end
                    3'b100: begin
                        case(func7)
                            7'b0000001: alu_cont=5'b01110;  
                            7'b0000000: alu_cont=5'b00010;
                        endcase
                    end
                    3'b101: begin
                        if (func7 == 7'b0000001) begin
                            alu_cont = 5'b01111; // DIVU
                        end else if (func7[5]) begin   // Checks bit 30 ONLY! Works for SRA and SRAI
                            alu_cont = 5'b00111; // SRA / SRAI
                        end else begin
                            alu_cont = 5'b00110; // SRL / SRLI
                        end
                    end
                    3'b110:  begin 
                        case(func7) 
                            7'b0000001: alu_cont=5'b01110; 
                            7'b0000000: alu_cont=5'b00011;
                        endcase
                    end
                    3'b111:begin case(func7) 
                            7'b0000001: alu_cont=5'b01110; 
                            7'b0000000: alu_cont=5'b00100;
                        endcase  
                    end
                endcase
            end

            7'b0010011: begin //// i-type
                alu_op1 = 1'b0;
                br = 0;
                jal = 0;
                jalr = 0;
                rg_s = 1;
                reg_wr_en = 1;
                alu_src = 1;
                mem_rd_en = 0;
                mem_wr_en = 0;
                s_e = 0;
                bj_mux = 0;
                wb_mux = 2'b01;
                case (func3) 
                    3'b000:  alu_cont=5'b00000;
                    3'b001:  alu_cont=5'b00101;
                    3'b010:  alu_cont=5'b01000;  ///  slt
                    3'b011:  alu_cont=5'b01001;  ///  sltu
                    3'b100:  alu_cont=5'b00010;
                    3'b101:  begin /// srl,sra 0110 0111
                        if (func7 == 7'b0000001) begin
                            alu_cont = 5'b01111; // DIVU
                        end else if (func7[5]) begin   // Checks bit 30 ONLY! Works for SRA and SRAI
                            alu_cont = 5'b00111; // SRA / SRAI
                        end else begin
                            alu_cont = 5'b00110; // SRL / SRLI
                        end
                    end
                    3'b110:  alu_cont=5'b00011;
                    3'b111:  alu_cont=5'b00100;
                endcase
            end

            7'b0000011: begin //// i-type load instructions
                alu_op1 = 1'b0;
                br = 0;
                jal = 0;
                jalr = 0;
                rg_s = 1;
                s_e = 0;
                reg_wr_en = 1;
                alu_src = 1;
                mem_rd_en = 1;
                mem_wr_en = 0;
                wb_mux = 2'b00;
                alu_cont=5'b00000;
                bj_mux = 0;
            end

            7'b0100011: begin //// s-type 
                alu_op1 = 1'b0;
                bj_mux = 0;
                br = 0;
                jal = 0;
                jalr = 0;
                rg_s = 0;
                s_e = 1;
                reg_wr_en  = 0;
                alu_src = 1;
                mem_rd_en = 0;
                mem_wr_en = 1;
                wb_mux = 2'b00;
                alu_cont=5'b00000;
            end

            7'b1100011: begin /// B-type
                br = 1;
                jal = 0;
                jalr = 0;
                bj_mux = 1;                                                
                reg_wr_en = 0;                                                                
            end

            7'b1101111: begin /// J-type jal
                br = 0;
                jal = 1;
                jalr = 0;
                bj_mux = 0;
                wb_mux = 2'b10;
                reg_wr_en  = 1;
                rg_s = 1;
            end

            7'b1100111: begin /// J-type jal
                rg_s = 1;
                reg_wr_en  = 1;
                bj_mux = 0;
                br = 0;
                jal = 0;
                jalr = 1;
                wb_mux = 2'b10;
            end

            7'b0110111: begin
                br = 0;
                jal = 0;
                jalr = 0;
                rg_s = 1;
                reg_wr_en = 1;
                alu_src = 1;
                mem_rd_en = 0;
                mem_wr_en = 0;
                s_e = 0;
                bj_mux = 0;
                wb_mux = 2'b01;
                alu_cont = 5'b10010;   // shift 12 bits
            end

            7'b0010111: begin
                alu_op1 = 1'b1;
                br = 0;
                jal = 0;
                jalr = 0;
                rg_s = 1;
                reg_wr_en = 1;
                alu_src = 1;
                mem_rd_en = 0;
                mem_wr_en = 0;
                s_e = 0;
                bj_mux = 0;
                wb_mux = 2'b01;
                alu_cont = 5'b10011;   // shift 12 bits + PC
            end
        endcase
    end

endmodule