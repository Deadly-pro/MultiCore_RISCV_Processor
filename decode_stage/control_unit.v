// RV32I control signal decoder.
`timescale 1ns / 1ps

module control_unit(
    input  wire [6:0] opcode,
    input  wire [2:0] funct3,
    input  wire [6:0] funct7,
    output reg        RegWrite,
    output reg        MemToReg,
    output reg        MemRead,
    output reg        MemWrite,
    output reg        ALUSrc,
    output reg        Branch,
    output reg [3:0]  ALUCtrl,
    output reg        WriteFromPC
);

    always @(*) begin
        RegWrite     = 0;
        MemToReg     = 0;
        MemRead      = 0;
        MemWrite     = 0;
        ALUSrc       = 0;
        Branch       = 0;
        ALUCtrl      = 4'b0000;
        WriteFromPC  = 0;

        case (opcode)
            7'b0110011: begin // R-type
                RegWrite = 1;
                case (funct3)
                    3'b000: ALUCtrl = (funct7[5]) ? 4'b0001 : 4'b0000; // SUB : ADD
                    3'b111: ALUCtrl = 4'b0010; // AND
                    3'b110: ALUCtrl = 4'b0011; // OR
                    default: ALUCtrl = 4'b0000;
                endcase
            end
            7'b0010011: begin // I-type
                RegWrite = 1;
                ALUSrc   = 1;
                case (funct3)
                    3'b000: ALUCtrl = 4'b0000; // ADDI
                    3'b111: ALUCtrl = 4'b0010; // ANDI
                    3'b110: ALUCtrl = 4'b0011; // ORI
                    3'b100: ALUCtrl = 4'b0100; // XORI
                    default: ALUCtrl = 4'b0000;
                endcase
            end
            7'b0000011: begin // Load (LW)
                RegWrite = 1;
                MemToReg = 1;
                MemRead  = 1;
                ALUSrc   = 1;
                ALUCtrl  = 4'b0000;
            end
            7'b0100011: begin // Store (SW)
                MemWrite = 1;
                ALUSrc   = 1;
                ALUCtrl  = 4'b0000;
            end
            7'b1100011: begin // Branch (BEQ)
                Branch   = 1;
                ALUCtrl  = 4'b0001;
            end
            7'b0110111: begin // LUI
                RegWrite = 1;
                ALUSrc   = 1;
                ALUCtrl  = 4'b0101;
            end
            7'b0010111: begin // AUIPC
                RegWrite     = 1;
                ALUSrc       = 1;
                WriteFromPC  = 1;
                ALUCtrl      = 4'b0000;
            end
            default: ;
        endcase
    end

endmodule
