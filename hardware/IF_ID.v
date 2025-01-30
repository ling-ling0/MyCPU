`timescale 1ns/1ps

module IF_ID (
	input clk,
    input rst,
	input [63:0] IF_pc,
	input IF_ID_stall,
	input IF_ID_flush,
	input IF_valid,
	output ID_valid,
	input [31:0] IF_inst,
	output [63:0] ID_pc,
	output [31:0] ID_inst
	);
	reg valid_reg;
	reg [63:0] pc_reg;
	reg [31:0] inst_reg;
	
	always@(posedge rst or posedge clk) begin
		if(rst|IF_ID_flush) begin
			valid_reg<=1'b0;
			pc_reg<=64'b0;
			inst_reg<=32'b0;
		end else if(!IF_ID_stall) begin
			pc_reg<=IF_pc;
			valid_reg<=IF_valid;
			inst_reg<=IF_inst;
		end
	end

	assign ID_valid=valid_reg;
	assign ID_pc=pc_reg;
	assign ID_inst=inst_reg;
endmodule