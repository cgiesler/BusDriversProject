class alu_tc;

int A_in;
int B_in;
logic [4:0] opcode;

function new();
	A_in = $random();
	B_in = $random();
	opcode = $urandom_range(16);
endfunction: new

function setParams(int Ain, int Bin, int op);
	A_in = Ain;
	B_in = Bin;
	opcode = op;
	return 0;
endfunction: setParams

function int getOutput();
	int out;
	logic [3:0] op_type;
	case(opcode) 
		5'b0001x: begin //SUB
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
	case(op_type) 
		4'b0000: begin //Add
			out = A_in + B_in;
		end
		4'b0001: begin //Subtract
			out = A_in - B_in;
		end
		4'b0010: begin //OR
			out = A_in | B_in;
		end
		4'b0011: begin //AND
			out = A_in & B_in;
		end
		4'b0100: begin //NOT
			out = ~A_in;
		end
		4'b0101: begin //Shift left
			out = A_in << B_in;
		end
		4'b0110: begin //LSR
			out = A_in >> B_in;
		end
		4'b0111: begin //ASR (signed shift)
			out = A_in >>> B_in;
		end
		4'b1000: begin //MOV instruction
			out = B_in;
		end
	endcase

	return out;
endfunction: getOutput

endclass;

module alu_tb();

logic [31:0] ALU_A_in, ALU_B_in, ALUOut;
logic [4:0] opcode;

alu DUT(.*);
alu_tc inDrivers;

int errors;
int tests = 150;

initial begin
	ALU_A_in = 32'h0;
	ALU_B_in = 32'h0;
	opcode = 5'h0;
	#5;
	for(int i = 0; i < tests; i++) begin
		inDrivers = new();
		ALU_A_in = inDrivers.A_in;
		ALU_B_in = inDrivers.B_in;
		opcode = inDrivers.opcode;
		#5;
		$display("opcode = %h, ALU_A_in = %h, ALU_B_in = %h, ALUOut = %h, expected = %h", opcode, ALU_A_in, ALU_B_in, ALUOut, inDrivers.getOutput);
		if(inDrivers.getOutput != ALUOut) begin
			errors++;
			$display("Incorrect calculation!");
		end
	end

	if(errors > 0) begin
		$display("Test failed, errors found: $d", errors);
	end else begin
		$display("Test passed!");
	end
	$display("Simulation complete");
	$stop();
end


endmodule
