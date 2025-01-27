`timescale 1ns / 1ps

module PC (
    input clk,
    input rst,
    input [63:0] pc_next,
	//input [63:0] pc,
	//input pc_stall,
    output [63:0] pc_out
);
	reg [63:0] pc_reg;

	always@(posedge clk or posedge rst) begin
		if(rst) pc_reg<=0;
		//else if(pc_stall) pc_reg<=pc;
		else pc_reg<=pc_next;
	end
	assign pc_out=pc_reg;
	
endmodule
