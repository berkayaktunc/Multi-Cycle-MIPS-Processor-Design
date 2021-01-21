// datapath.sv
module datapath(input logic clk, reset, IorD, MemRead, MemWrite, MemToReg, 
					 input logic IRWrite, ALUSrcA, RegWrite, RegDst, PCSel,
					 input logic [1:0] PCSource,
					 input logic [1:0] ALUSrcB, 
					 input logic [3:0] ALUCtrl, 
					 output logic Zero, 
					 output logic [5:0] Op,
					 output logic [5:0] Function
	);

	// PARAMETER DECLERATIONS
	parameter PCSTART = 128; //starting address of instruction memory
	logic [7:0] PC_Temp;
	logic [7:0]	PC;
	logic [31:0] ALUOut;
	logic [31:0] ALUResult;
	logic [31:0] OpA;
	logic [31:0] OpB;

	// Declaration of missing units
	logic [31:0] Instruction;
	logic [31:0] registers [31:0];

	logic [4:0] RF_rd;
	logic [31:0] MDR;
	logic [31:0] RA;
	logic [31:0] RB;
	logic [31:0] RA_Data;
	logic [31:0] RB_Data;
	logic [31:0] RF_WriteData;

	logic [7:0] File [255:0];
	logic [7:0] File_Adr;
	logic [31:0] Adress;
	
	//FETCH
	always @( posedge clk ) begin
		if(reset)
			PC <= PCSTART;
		else begin
			if(PCSel)
				PC <= PC_Temp;
		end
	end

	initial
		$readmemh("unified_memory.dat", File);

	// Instruction Memory Address
	always_comb
	begin
		if(IorD)
			File_Adr <= ALUOut;
		else
			File_Adr <= PC;
	end
	
	assign Adress[31:24] = (MemRead)? File[File_Adr]  :8'bx;
	assign Adress[23:16] = (MemRead)? File[File_Adr+1]:8'bx;
	assign Adress[15:8]  = (MemRead)? File[File_Adr+2]:8'bx;
	assign Adress[7:0]   = (MemRead)? File[File_Adr+3]:8'bx;
	
	always @( posedge clk ) begin
		if (MemWrite) begin
			File[File_Adr]   <= RB[31:24];
			File[File_Adr+1] <= RB[23:16];
			File[File_Adr+2] <= RB[15:8];
			File[File_Adr+3] <= RB[7:0];
		end
	end
	
	always @( posedge clk ) begin
		MDR <= Adress;
	end

	always @( posedge clk ) begin
		if(IRWrite)
			Instruction <= Adress;
	end

	//Op Code and Function assign for output
	assign Op = Instruction[31:26];
	assign Function = (Instruction[31:26]!=0) ? Instruction[5:0] : 0;
	
	
	//Memory File
	
	//register file
	assign RA_Data = (Instruction[25:21]!=0) ? registers[Instruction[25:21]] : 0;
	assign RB_Data = (Instruction[20:16]!=0) ? registers[Instruction[20:16]] : 0;
	assign RF_WriteData = (MemToReg) ? MDR : ALUOut;
	assign RF_rd = (RegDst) ? Instruction[15:11] : Instruction[20:16];
	

	always @( posedge clk ) begin
		if (RegWrite)
			registers[RF_rd] <= RF_WriteData;
	end

	//RA and RB registers

	always @( posedge clk ) begin
		if (reset)
			RA <= 0;
		else
			RA<=RA_Data;
	end

	always @( posedge clk ) begin
		if (reset)
			RB <= 0;
		else
			RB<=RB_Data;
	end

	//ALU

	assign OpA = (ALUSrcA) ? RA : PC;

	always_comb
	begin
		case(ALUSrcB)
			2'b00:OpB=RB;
			2'b01:OpB=4;
			2'b10:OpB={{(16){Instruction[15]}},Instruction[15:0]};
			2'b11:OpB={{(14){Instruction[15]}},Instruction[15:0],2'b00};
			default: OpB=4;
		endcase
	end

	assign Zero = (ALUResult==0); //Zero == 1 when ALUResult is 0 (for branch)

	always_comb
	begin
		case(ALUCtrl)
			4'b0000: ALUResult = OpA & OpB;
			4'b0001: ALUResult = OpA | OpB;
			4'b0010: ALUResult = OpA ^ OpB;
			4'b0011: ALUResult = ~(OpA | OpB);
			4'b0110: ALUResult = OpA + OpB;
			4'b1110: ALUResult = OpA - OpB;
			4'b1111: ALUResult = OpA < OpB?1:0;
			default: ALUResult = OpA + OpB;
		endcase
	end

	always_comb
	begin
		case(PCSource)
			2'b00: PC_Temp <= ALUResult;
			2'b01: PC_Temp <= ALUOut;
			2'b10: PC_Temp <= Instruction[7:0];
			default:PC_Temp <= Instruction[7:0];
		endcase
	end

	always @( posedge clk ) begin
		ALUOut = ALUResult;
	end

endmodule