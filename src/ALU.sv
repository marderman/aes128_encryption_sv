module ALU #(parameter WIDTH = 4)
	(input logic [WIDTH-1:0] operand_a,
	input logic [WIDTH-1:0] operand_b,
	input logic [1:0] alu_op,
	output logic [WIDTH-1:0] result,
	output logic zero);
// Internal signals
	logic [WIDTH-1:0] and_result, or_result;
	logic [WIDTH-1:0] xor_result, add_result;
// AND operation
	always_comb
		and_result = operand_a & operand_b;
// OR operation
	always_comb
		or_result = operand_a | operand_b;
// XOR operation
	always_comb
		xor_result = operand_a ^ operand_b;
// ADD operation
	always_comb
		add_result = operand_a + operand_b;
// Output result based on ALU operation code
	always_comb begin
		case (alu_op)
			2'b00: result = and_result; // AND
			2'b01: result = or_result; // OR
			2'b10: result = xor_result; // XOR
			2'b11: result = add_result; // ADD
			default: result = 0;
		endcase
	end
// Output zero flag
	always_comb
		zero = (result == 0);
endmodule
