`timescale 1ns/1ps

module MUX_A(
	input [63:0] pc,
	input [63:0] rs1_data,
	input [1:0] alu_asel,
	output [63:0] alu_a
);
parameter choose_0=2'b00;
parameter choose_rs1=2'b01;
parameter choose_pc=2'b10;

reg [63:0]  alu_a_reg;
always@(*) begin
	case(alu_asel)
		choose_0:
			alu_a_reg={64{1'b0}};
		choose_rs1:
			alu_a_reg=rs1_data;
		choose_pc:
			alu_a_reg=pc;
		default:
			alu_a_reg={64{1'b0}};
	endcase
end
assign alu_a = alu_a_reg;
endmodule
