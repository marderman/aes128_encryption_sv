module ALU_tb;

    // Testbench parameters
    parameter WIDTH = 4;
    
    // Testbench signals
    logic [WIDTH-1:0] operand_a;
    logic [WIDTH-1:0] operand_b;
    logic [1:0] alu_op;
    logic [WIDTH-1:0] result;
    logic zero;

    // Instantiate the DUT (Device Under Test)
    ALU #(.WIDTH(WIDTH)) uut (
        .operand_a(operand_a),
        .operand_b(operand_b),
        .alu_op(alu_op),
        .result(result),
        .zero(zero)
    );

    // Test sequence
    initial begin
        // Test AND operation
        operand_a = 4'b1010; operand_b = 4'b1100; alu_op = 2'b00;
        #10;
        $display("AND: %b & %b = %b", operand_a, operand_b, result);

        // Test OR operation
        operand_a = 4'b1010; operand_b = 4'b1100; alu_op = 2'b01;
        #10;
        $display("OR: %b | %b = %b", operand_a, operand_b, result);

        // Test XOR operation
        operand_a = 4'b1010; operand_b = 4'b1100; alu_op = 2'b10;
        #10;
        $display("XOR: %b ^ %b = %b", operand_a, operand_b, result);

        // Test ADD operation
        operand_a = 4'b1010; operand_b = 4'b0011; alu_op = 2'b11;
        #10;
        $display("ADD: %b + %b = %b", operand_a, operand_b, result);
        
        // Test Zero flag
        operand_a = 4'b0000; operand_b = 4'b0000; alu_op = 2'b11;
        #10;
        $display("Zero flag: %b", zero);
        
        // Finish simulation
        #50 $finish;
    end
endmodule
