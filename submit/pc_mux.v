`timescale 1ns/1ps

module pc_mux(
	input [63:0] pc,
	input [63:0] alu_out,
	input br_taken,
	input npc_sel,
	input pc_stall,
	output [63:0] pc_out
);
reg [63:0] pc_out_reg;
always@(*) begin
	if(br_taken&&npc_sel) pc_out_reg=alu_out;
	else if(pc_stall) pc_out_reg=pc;
	else pc_out_reg=pc+4;
end
	assign pc_out=pc_out_reg;
endmodule
