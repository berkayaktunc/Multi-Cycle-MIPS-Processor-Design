// control.sv
module control (input logic clk, reset, Zero,
					 input logic [5:0] Op,
					 output logic IorD, MemRead, MemWrite, MemToReg, IRWrite,
					 output logic ALUSrcA, RegWrite, RegDst, PCSel,
					 output logic [1:0] PCSource,
					 output logic [1:0] ALUSrcB,
					 output logic [1:0] ALUOp
	);

	// Parameter for us to use
	parameter F_State = 0;
	parameter D_State = 1;
	parameter LoS_State = 2;
	parameter Lw_State = 3;
	parameter Wb_State = 4;
	parameter Sw_State = 5;
	parameter R_Type = 6;
	parameter Rw_State = 7;
	parameter Beq_State = 8;
	parameter J_State = 9;
	reg [5:0] State = F_State;
	reg [5:0] Next_State;

	// State changer
	always @( posedge clk ) begin
		State = Next_State;
		if (reset == 1)
			State = F_State;
	end
 
	// State work
	always @ (State , Op) begin
		IorD     = 0;
		MemRead  = 0;
		MemWrite = 0;
		MemToReg = 0;
		IRWrite  = 0;
		ALUSrcA  = 0;
		RegWrite = 0;
		RegDst   = 0;
		PCSel    = 0;
		PCSource = 2'b00;
		ALUSrcB  = 2'b00;
		ALUOp    = 2'b00;

		case(State)
			F_State: begin		// Fetch State
				IorD = 0;
				ALUSrcA = 0;
				ALUSrcB = 2'b01;
				ALUOp = 2'b00;
				PCSource = 2'b00;
				MemRead = 1;
				MemWrite = 0;
				IRWrite = 1;
				PCSel = 1;

				Next_State = D_State;
			end

			D_State: begin		// Decode State
				 ALUOp = 2'b00;
				 ALUSrcA = 0;
				 ALUSrcB = 2'b11;
				 
				 if (Op == 6'b000000) Next_State = R_Type;
				 else if (Op == 6'b100011 | Op == 6'b101011) Next_State = LoS_State;
				 else if (Op == 6'b000100) 						Next_State = Beq_State;
				 else if (Op == 6'b000010) 						Next_State = J_State;
			end
			
			J_State: begin		// Jump State
				PCSel = 1;
				PCSource = 2'b10;

				Next_State = F_State;
			end
			
			Beq_State: begin		// Beq State
				ALUSrcA = 1;
				ALUOp = 2'b01;
				ALUSrcB = 2'b00;
				PCSource = 2'b01;

				Next_State=F_State;
			end

			Wb_State: begin		// Write Back State
				RegDst = 0;
				RegWrite = 1;
				MemToReg = 1;

				Next_State = F_State;
			end

			R_Type: begin		// R-type State
				ALUOp = 2'b10;
				ALUSrcA = 1;
				ALUSrcB = 2'b00;

				Next_State = Rw_State;
			end

			Rw_State: begin		// Register Write State
				RegDst = 1;
				RegWrite = 1;
				MemToReg = 0;

				Next_State = F_State;
			end
			
			LoS_State: begin		// LoadWord or StoreWord State
				ALUOp = 2'b00;
				ALUSrcA = 1;
				ALUSrcB = 2'b10;
				
				if (Op == 6'b100011) 		Next_State = Lw_State;
				else if (Op == 6'b101011)	Next_State = Sw_State;
			end

			Lw_State: begin		// LoadWord State
				MemRead = 1;
				IorD = 1;

				Next_State = Wb_State;
			end

			Sw_State: begin		// StoreWord State
				MemWrite = 1;
				IorD = 1;

				Next_State = F_State;
			end
			
		endcase
	end
endmodule