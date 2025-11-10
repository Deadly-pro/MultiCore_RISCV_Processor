// control_unit.v
// Combinational control unit for a basic RV32I subset.
// Inputs:  instruction[31:0]
// Outputs: RegWrite, MemRead, MemWrite, MemToReg, ALUSrc, Branch, ALUCtrl[3:0]

module control_unit (
    input  wire [31:0] instr,
    output reg         RegWrite,
    output reg         MemRead,
    output reg         MemWrite,
    output reg         MemToReg,
    output reg         ALUSrc,     // 0 -> reg2, 1 -> immediate
    output reg         Branch,     // generic branch indicator (beq/bne/blt/...)
    output reg  [3:0]  ALUCtrl,     // ALU operation code
    output reg         WriteFromPC
);

    // --- opcode / funct fields ---
    wire [6:0] opcode = instr[6:0];
    wire [2:0] funct3 = instr[14:12];
    wire [6:0] funct7 = instr[31:25];

    // --- opcode encodings (RV32I subset) ---
    localparam [6:0] OP_RTYPE  = 7'b0110011;
    localparam [6:0] OP_ITYPE  = 7'b0010011; // ALU immediate
    localparam [6:0] OP_LOAD   = 7'b0000011;
    localparam [6:0] OP_STORE  = 7'b0100011;
    localparam [6:0] OP_BRANCH = 7'b1100011;
    localparam [6:0] OP_JAL    = 7'b1101111;
    localparam [6:0] OP_JALR   = 7'b1100111;
    localparam [6:0] OP_LUI    = 7'b0110111;
    localparam [6:0] OP_AUIPC  = 7'b0010111;

    // --- ALUCtrl encoding (4-bit) ---
    localparam [3:0] ALU_ADD  = 4'h0;
    localparam [3:0] ALU_SUB  = 4'h1;
    localparam [3:0] ALU_AND  = 4'h2;
    localparam [3:0] ALU_OR   = 4'h3;
    localparam [3:0] ALU_XOR  = 4'h4;
    localparam [3:0] ALU_SLL  = 4'h5;
    localparam [3:0] ALU_SRL  = 4'h6;
    localparam [3:0] ALU_SRA  = 4'h7;
    localparam [3:0] ALU_SLT  = 4'h8;
    localparam [3:0] ALU_SLTU = 4'h9;
    localparam [3:0] ALU_LUI  = 4'hA;
    localparam [3:0] ALU_NOP  = 4'hF;

    // Combinational decode
    always @(*) begin
        // defaults (safe)
        RegWrite = 1'b0;
        MemRead  = 1'b0;
        MemWrite = 1'b0;
        MemToReg = 1'b0;
        ALUSrc   = 1'b0;
        Branch   = 1'b0;
        ALUCtrl  = ALU_NOP;
        WriteFromPC=1'b0;
        case (opcode)
            // ---------------- R-type (register-register) ----------------
            OP_RTYPE: begin
                RegWrite = 1'b1;
                ALUSrc   = 1'b0; // second ALU operand from register
                MemToReg = 1'b0;
                MemRead  = 1'b0;
                MemWrite = 1'b0;
                Branch   = 1'b0;
                // ALU op determined by funct3 and funct7
                case (funct3)
                    3'b000: ALUCtrl = (funct7 == 7'b0100000) ? ALU_SUB : ALU_ADD; // ADD / SUB
                    3'b001: ALUCtrl = ALU_SLL; // SLL
                    3'b010: ALUCtrl = ALU_SLT; // SLT
                    3'b011: ALUCtrl = ALU_SLTU; // SLTU
                    3'b100: ALUCtrl = ALU_XOR; // XOR
                    3'b101: ALUCtrl = (funct7 == 7'b0100000) ? ALU_SRA : ALU_SRL; // SRL / SRA
                    3'b110: ALUCtrl = ALU_OR;  // OR
                    3'b111: ALUCtrl = ALU_AND; // AND
                    default: ALUCtrl = ALU_NOP;
                endcase
            end

            // --------------- I-type ALU immediate (ADDI, ANDI, ORI, etc) ---------------
            OP_ITYPE: begin
                RegWrite = 1'b1;
                ALUSrc   = 1'b1; // second ALU operand is immediate
                MemToReg = 1'b0;
                MemRead  = 1'b0;
                MemWrite = 1'b0;
                Branch   = 1'b0;
                case (funct3)
                    3'b000: ALUCtrl = ALU_ADD;  // ADDI
                    3'b010: ALUCtrl = ALU_SLT;  // SLTI
                    3'b011: ALUCtrl = ALU_SLTU; // SLTIU
                    3'b100: ALUCtrl = ALU_XOR;  // XORI
                    3'b110: ALUCtrl = ALU_OR;   // ORI
                    3'b111: ALUCtrl = ALU_AND;  // ANDI
                    3'b001: ALUCtrl = ALU_SLL;  // SLLI (funct7 == 0000000)
                    3'b101: ALUCtrl = (funct7 == 7'b0100000) ? ALU_SRA : ALU_SRL; // SRLI / SRAI
                    default: ALUCtrl = ALU_NOP;
                endcase
            end

            // ---------------- Loads ----------------
            OP_LOAD: begin
                RegWrite = 1'b1;
                MemRead  = 1'b1;
                MemToReg = 1'b1;
                ALUSrc   = 1'b1; // address = base + imm
                MemWrite = 1'b0;
                Branch   = 1'b0;
                ALUCtrl  = ALU_ADD; // address calculation
            end

            // ---------------- Stores ----------------
            OP_STORE: begin
                RegWrite = 1'b0;
                MemRead  = 1'b0;
                MemWrite = 1'b1;
                MemToReg = 1'b0; // don't care
                ALUSrc   = 1'b1; // address = base + imm
                Branch   = 1'b0;
                ALUCtrl  = ALU_ADD; // address calculation
            end

            // ---------------- Branches (BEQ, BNE, BLT, BGE, ...) ----------------
            OP_BRANCH: begin
                RegWrite = 1'b0;
                MemRead  = 1'b0;
                MemWrite = 1'b0;
                MemToReg = 1'b0;
                ALUSrc   = 1'b0; // typically compare two regs
                Branch   = 1'b1; // high-level branch indicator
                ALUCtrl  = ALU_SUB; // most branch comparisons implemented via subtract/compare
            end

            // ---------------- JAL ----------------
            OP_JAL: begin
                RegWrite = 1'b1; // rd <- PC+4
                MemRead  = 1'b0;
                MemWrite = 1'b0;
                MemToReg = 1'b0; // value comes from PC+4, not memory
                ALUSrc   = 1'b0;
                Branch   = 1'b0;
                ALUCtrl  = ALU_ADD; // not used for jump target writeback, keep ADD
                WriteFromPC=1'b1;
            end

            // ---------------- JALR ----------------
            OP_JALR: begin
                RegWrite = 1'b1; // rd <- PC+4
                MemRead  = 1'b0;
                MemWrite = 1'b0;
                MemToReg = 1'b0;
                ALUSrc   = 1'b1; // target = rs1 + imm
                Branch   = 1'b0;
                ALUCtrl  = ALU_ADD; // used to compute target
                WriteFromPC=1'b1;
            end

            // ---------------- LUI ----------------
            OP_LUI: begin
                RegWrite = 1'b1;
                MemRead  = 1'b0;
                MemWrite = 1'b0;
                MemToReg = 1'b0;
                ALUSrc   = 1'b1; // immediate -> rd
                Branch   = 1'b0;
                ALUCtrl  = ALU_LUI; // special code: place immediate << 12 into rd (handle in datapath)
            end

            // ---------------- AUIPC ----------------
            OP_AUIPC: begin
                RegWrite = 1'b1;
                MemRead  = 1'b0;
                MemWrite = 1'b0;
                MemToReg = 1'b0;
                ALUSrc   = 1'b1; // use immediate with PC
                Branch   = 1'b0;
                ALUCtrl  = ALU_ADD; // rd = PC + imm (datapath uses PC)
            end

            // ---------------- default (unknown) ----------------
            default: begin
                // all defaults already set (safe no-op)
            end
        endcase
    end

endmodule
