
// -----------------------------------------------------------------------------
// File: decode_stage/imm_gen.v
// Purpose: Generate sign/zero-extended immediates for RV32I instruction types.
// Supports: I, S, B, U, J formats. R-type yields 0.
// -----------------------------------------------------------------------------
module imm_gen (
    input  wire [31:0] instruction,
    output reg  [31:0] immediate_out
);

    wire [6:0] opcode = instruction[6:0];
    // opcode to compare the output with
    localparam OPCODE_I_IMM   = 7'b0010011; // (addi, slti, etc.)
    localparam OPCODE_I_LOAD  = 7'b0000011; // (lb, lh, lw)
    localparam OPCODE_I_JALR  = 7'b1100111; // (jalr)
    localparam OPCODE_S       = 7'b0100011; // (sb, sh, sw)
    localparam OPCODE_B       = 7'b1100011; // (beq, bne, etc.)
    localparam OPCODE_U_LUI   = 7'b0110111; // (lui)
    localparam OPCODE_U_AUIPC = 7'b0010111; // (auipc)
    localparam OPCODE_J       = 7'b1101111; // (jal)
    localparam OPCODE_R       = 7'b0110011; // (add, sub, etc.) - No immediate
    always @(*) begin
        case (opcode)
            // I-Type (Sign-extend from bit 11) 
            OPCODE_I_IMM, OPCODE_I_LOAD, OPCODE_I_JALR: begin
                // imm[11:0] = ins[31:20]
                // Sign extend from ins[31]
                immediate_out = {{20{instruction[31]}}, instruction[31:20]};
            end

            // S-Type (Sign-extend from bit 11)
            OPCODE_S: begin
                // imm[11:5] = ins[31:25], imm[4:0] = ins[11:7]
                // Sign extend from inst[31]
                immediate_out = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            end

            // B-Type (Sign-extend from bit 12)
            OPCODE_B: begin
                // imm[12|10:5|4:1|11] = ins[31|30:25|11:8|7]
                // Note: immediate bit 0 is always 0.
                // Sign extend from ins[31]
                immediate_out = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
            end

            // U-Type (Pads with 0s at the bottom)
            OPCODE_U_LUI, OPCODE_U_AUIPC: begin
                // imm[31:12] = ins[31:12]
                // Lower 12 bits are 0.
                immediate_out = {instruction[31:12], 12'b0};
            end

            // J-Type (Sign-extend from bit 20)
            OPCODE_J: begin
                // imm[20|10:1|11|19:12] = ins[31|30:21|20|19:12]
                // Note: immediate bit 0 is always 0.
                // Sign extend from inst[31]
                immediate_out = {{11{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};
            end
            // for R type instructions            
            default: begin
                immediate_out = 32'b0;
            end
        endcase
    end

endmodule
