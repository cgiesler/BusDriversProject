//Version 0.1
module alu(	
  input signed [31:0] ALU_A_in, ALU_B_in,
  input [4:0] opcode,
  output signed [31:0] ALUOut
);

logic [3:0] op_type;
//Determine ALU operation type
always_comb begin
	case(opcode) 
		5'b00010: begin //SUB
			op_type = 4'b0001;
		end
		5'b00011: begin //SUB
			op_type = 4'b0001;
		end
		5'b10000: begin //SUB: POP
			op_type = 4'b0001;
		end
		5'b00100: begin //LSR
			op_type = 4'b0110;
		end
		5'b00101: begin //ASR
			op_type = 4'b0111;
		end
		5'b00110: begin //SL
			op_type = 4'b0101;
		end
		5'b00111: begin //AND
			op_type = 4'b0011;
		end
		5'b01000: begin //OR
			op_type = 4'b0010;
		end
		5'b01001: begin //NOT
			op_type = 4'b0100;
		end
		5'b01100: begin //MOV
			op_type = 4'b1000;
		end
		default: begin //Default to add op
			op_type = 4'b0000;
		end
	endcase
end

logic signed [31:0] aluTemp;
//Determine ALU ouput
always_comb begin
	case(op_type) 
		4'b0000: begin //Add
			aluTemp = ALU_A_in + ALU_B_in;
		end
		4'b0001: begin //Subtract
			aluTemp = ALU_A_in - ALU_B_in;
		end
		4'b0010: begin //OR
			aluTemp = ALU_A_in | ALU_B_in;
		end
		4'b0011: begin //AND
			aluTemp = ALU_A_in & ALU_B_in;
		end
		4'b0100: begin //NOT
			aluTemp = ~ALU_A_in;
		end
		4'b0101: begin //Shift left
			aluTemp = ALU_A_in << ALU_B_in;
		end
		4'b0110: begin //LSR
			aluTemp = ALU_A_in >> ALU_B_in;
		end
		4'b0111: begin //ASR (signed shift)
			aluTemp = ALU_A_in >>> ALU_B_in;
		end
		4'b1000: begin //MOV instruction
			aluTemp = ALU_B_in;
		end
	endcase
end

assign ALUOut = aluTemp;

endmodule

