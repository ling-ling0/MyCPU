`timescale 1ns/1ps

module MUX_B(
	input [63:0] rs2_data,
	input [63:0] imm,
	input [1:0] alu_bsel,
	output [63:0] alu_b
);
parameter choose_0=2'b00;
parameter choose_rs2=2'b01;
parameter choose_imm=2'b10;


	reg [63:0] alu_b_reg;

always@(*) begin
	case(alu_bsel)
		choose_0:
			alu_b_reg={64{1'b0}};
		choose_rs2:
			alu_b_reg=rs2_data;
		choose_imm:
			alu_b_reg=imm;
		default:
			alu_b_reg={64{1'b0}};
	endcase
end

assign alu_b=alu_b_reg;
endmodule
