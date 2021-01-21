// mips_mc.sv
module mips_mc(input logic clk,
               input logic reset,
			   output logic [5:0] Opcode_Out);

	logic [5:0] Op;
	logic Zero;
	logic IorD;
	logic MemRead;
	logic MemWrite;
	logic MemToReg;
	logic IRWrite;
	logic [1:0] PCSource;
	logic [1:0] ALUSrcB;
	logic ALUSrcA;
	logic RegWrite;
	logic RegDst;
	logic PCSel;
	logic [1:0] ALUOp;
	logic [3:0] ALUCtrl;
	logic [5:0] Function;

	assign Opcode_Out = Op;

	control u0(.clk(clk), .reset(reset), .Zero(Zero), .Op(Op), .IorD(IorD), .MemRead(MemRead), 
				.MemWrite(MemWrite), .MemToReg(MemToReg), .IRWrite(IRWrite), .ALUSrcA(ALUSrcA), 
				.RegWrite(RegWrite), .RegDst(RegDst), .PCSel(PCSel), .PCSource(PCSource), 
				.ALUSrcB(ALUSrcB), .ALUOp(ALUOp));

	alucontrol u1(.ALUOp(ALUOp), .Function(Function), .ALUCtrl(ALUCtrl)); 

	datapath u2(.clk(clk), .reset(reset), .IorD(IorD), .MemRead(MemRead), .MemWrite(MemWrite), 
				.MemToReg(MemToReg), .IRWrite(IRWrite), .ALUSrcA(ALUSrcA), .RegWrite(RegWrite),
				.RegDst(RegDst), .PCSel(PCSel), .PCSource(PCSource), .ALUSrcB(ALUSrcB),
				.ALUCtrl(ALUCtrl), .Zero(Zero), .Op(Op), .Function(Function));

endmodule