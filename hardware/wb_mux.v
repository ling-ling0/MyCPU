`timescale 1ns/1ps

module wb_mux(
	input [63:0] pc,//要求是+4之后的pc
	input [63:0] alu_out,
	input [63:0] mem,
	input [1:0] wb_sel,
	output [63:0] wb_data
);
//wb_sel[1:0]
parameter wb_0=2'b00;
parameter wb_alu=2'b01;
parameter wb_mem=2'b10;
parameter wb_pc=2'b11;

reg [63:0]  wb_data_reg;
always@(*) begin
	case(wb_sel)
		wb_0:
			wb_data_reg={64{1'b0}};
		wb_alu:
			wb_data_reg=alu_out;
		wb_mem:
			wb_data_reg=mem;
		wb_pc:
			wb_data_reg=pc;
	endcase
end
assign wb_data=wb_data_reg;
endmodule
