`timescale 1ns/1ps

module ID_EXE (
    input clk,
    input rst,
    input ID_EXE_stall,
	input ID_EXE_flush,
	input ID_valid,
	output EXE_valid,
    input [63:0] ID_pc,
    output [63:0] EXE_pc,
    input [31:0] ID_inst,
    output [31:0] EXE_inst,
    input [21:0] ID_decode,
    output [21:0] EXE_decode,
    input [63:0] ID_read_data_1,
    output [63:0] EXE_read_data_1,
    input [63:0] ID_read_data_2,
    output [63:0] EXE_read_data_2,
    input [63:0] ID_alu_a,
    output [63:0] EXE_alu_a,
    input [63:0] ID_alu_b,
    output [63:0] EXE_alu_b,
    input ID_br_taken,
    output EXE_br_taken,

    //----------------------------
    input [63:0] csr_val_id,
    input [1:0] csr_ret_id,
    input csr_we_id,
    input [1:0] csr_alu_op_id,

    output [1:0] csr_alu_op_exe,
    output [63:0] csr_val_exe,
    output [1:0] csr_ret_exe,
    output csr_we_exe

    );
    reg valid_reg;
    reg [63:0] pc_reg;
    reg [31:0] inst_reg;
    reg [21:0] decode_reg;
    reg [63:0] read_data_1_reg;
    reg [63:0] read_data_2_reg;
    reg [63:0] alu_a_reg;
    reg [63:0] alu_b_reg;
    reg br_taken_reg;

    reg [63:0] csr_val_reg;
    reg [1:0] csr_ret_reg;
    reg csr_we_reg;
    reg [1:0] csr_alu_op_reg;

    always@(posedge rst or posedge clk) begin
        if(rst|ID_EXE_flush) begin
            valid_reg<=1'b0;
            pc_reg<=64'b0;
            inst_reg<=32'b0;
            decode_reg<=22'b0;
            read_data_1_reg<=64'b0;
            read_data_2_reg<=64'b0;
            alu_a_reg<=64'b0;
            alu_b_reg<=64'b0;
            br_taken_reg<=1'b0;
            
            csr_alu_op_reg<=2'b0;
            csr_val_reg<=64'b0;
            csr_ret_reg<=2'b0;
            csr_we_reg<=1'b0;
        end else if(!ID_EXE_stall) begin
            valid_reg<=ID_valid;
            pc_reg<=ID_pc;
            inst_reg<=ID_inst;
            decode_reg<=ID_decode;
            read_data_1_reg<=ID_read_data_1;
            read_data_2_reg<=ID_read_data_2;
            alu_a_reg<=ID_alu_a;
            alu_b_reg<=ID_alu_b;
            br_taken_reg<=ID_br_taken;

            csr_alu_op_reg<=csr_alu_op_id;
            csr_val_reg<=csr_val_id;
            csr_ret_reg<=csr_ret_id;
            csr_we_reg<=csr_we_id;
        end
    end

    assign EXE_valid=valid_reg;
    assign EXE_pc=pc_reg;
    assign EXE_inst=inst_reg;
    assign EXE_decode=decode_reg;
    assign EXE_read_data_1=read_data_1_reg;
    assign EXE_read_data_2=read_data_2_reg;
    assign EXE_alu_a=alu_a_reg;
    assign EXE_alu_b=alu_b_reg;
    assign EXE_br_taken=br_taken_reg;
    
    assign csr_alu_op_exe=csr_alu_op_reg;
    assign csr_val_exe=csr_val_reg;
    assign csr_ret_exe=csr_ret_reg;
    assign csr_we_exe=csr_we_reg;

endmodule