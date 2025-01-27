`timescale 1ns / 1ps
module DataPkg(
	input [63:0] data,
	input [63:0] remain,
	output [63:0] data_out
);
	assign data_out=data << (remain[2:0]*8);

endmodule
