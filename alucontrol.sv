// alucontrol.sv
module alucontrol(input logic [1:0] ALUOp,
						input logic [5:0] Function,
						output logic [3:0] ALUCtrl
	);

	// Operation Decider According to ALUOp
	always @(ALUOp, Function) begin
		if( ALUOp == 0 )begin
			ALUCtrl=4'b0110;	// Add operation
		end
		else if ( ALUOp == 1 ) begin
			ALUCtrl=4'b1110;	// Subtract operation
		end
		else if ( ALUOp == 2 ) begin
			// Operation Decider According to Function
			case (Function)
				6'b100000:ALUCtrl=4'b0110;	// Add operation
				6'b100010:ALUCtrl=4'b1110;	// Subtract operation
				6'b100100:ALUCtrl=4'b0000;	// AND operation 
				6'b100101:ALUCtrl=4'b0001;	// OR operation
				6'b100110:ALUCtrl=4'b0010;	// XOR operation
				6'b100111:ALUCtrl=4'b0011;	// NOR operation
				6'b101010:ALUCtrl=4'b1111;	// SLT operation
			endcase
		end
	end
endmodule