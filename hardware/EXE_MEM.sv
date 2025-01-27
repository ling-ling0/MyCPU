`timescale 1ns/1ps
`include "ExceptStruct.vh"

module EXE_MEM (
    input clk,
    input rst,
    input EXE_MEM_stall,
	input EXE_MEM_flush,
	input EXE_valid,
	output MEM_valid,
    input [63:0] EXE_pc,
    output [63:0] MEM_pc,
    input [31:0] EXE_inst,
    output [31:0] MEM_inst,
    input [21:0] EXE_decode,
    output [21:0] MEM_decode,
    input [63:0] EXE_read_data_1,
    output [63:0] MEM_read_data_1,
    input [63:0] EXE_read_data_2,
    output [63:0] MEM_read_data_2,
    input [63:0] EXE_alu_out,
    output [63:0] MEM_alu_out,
    input EXE_br_taken,
    output MEM_br_taken,

    input [63:0] EXE_rw_rdata,
    output [63:0] MEM_rw_rdata,

    input [63:0] csr_val_exe,
    input [63:0] csr_alu_exe,
    input [1:0] csr_ret_exe,
    input csr_we_exe,
    input ExceptStruct::ExceptPack except_exe,

    output [63:0] csr_val_mem,
    output [63:0] csr_alu_mem,
    output [1:0] csr_ret_mem,
    output csr_we_mem,
    output ExceptStruct::ExceptPack except_mem
);
    
    import ExceptStruct::*;

    reg valid_reg;
    reg [63:0] pc_reg;
    reg [31:0] inst_reg;
    reg [21:0] decode_reg;
    reg [63:0] read_data_1_reg;
    reg [63:0] read_data_2_reg;
    reg [63:0] alu_out_reg;
    reg br_taken_reg;

    reg [63:0] rw_rdata_reg;

    reg [63:0] csr_val_reg;
    reg [1:0] csr_ret_reg;
    reg csr_we_reg;
    reg [63:0] csr_alu_reg;
    
    ExceptPack except_reg;

    always@(posedge rst or posedge clk) begin
        if(rst|EXE_MEM_flush) begin
            valid_reg<=1'b0;
            pc_reg<=64'b0;
            inst_reg<=32'b0;
            decode_reg<=22'b0;
            read_data_1_reg<=64'b0;
            read_data_2_reg<=64'b0;
            alu_out_reg<=64'b0;
            br_taken_reg<=1'b0;

            rw_rdata_reg<=64'b0;

            csr_val_reg<=64'b0;
            csr_ret_reg<=2'b0;
            csr_we_reg<=1'b0;
            csr_alu_reg<=64'b0;

            except_reg<='{except: 1'b0, epc:64'b0, ecause:64'b0,etval: 64'b0};
        end else if(!EXE_MEM_stall) begin
            valid_reg<=EXE_valid;
            pc_reg<=EXE_pc;
            inst_reg<=EXE_inst;
            decode_reg<=EXE_decode;
            read_data_1_reg<=EXE_read_data_1;
            read_data_2_reg<=EXE_read_data_2;
            alu_out_reg<=EXE_alu_out;
            br_taken_reg<=EXE_br_taken;

            rw_rdata_reg<=EXE_rw_rdata;

            csr_val_reg<=csr_val_exe;
            csr_ret_reg<=csr_ret_exe;
            csr_we_reg<=csr_we_exe;
            csr_alu_reg<=csr_alu_exe;

            except_reg<=except_exe;
        end
    end

    assign MEM_valid=valid_reg;
    assign MEM_pc=pc_reg;
    assign MEM_inst=inst_reg;
    assign MEM_decode=decode_reg;
    assign MEM_read_data_1=read_data_1_reg;
    assign MEM_read_data_2=read_data_2_reg;
    assign MEM_alu_out=alu_out_reg;
    assign MEM_br_taken=br_taken_reg;
    
    assign MEM_rw_rdata=rw_rdata_reg;

    assign csr_val_mem=csr_val_reg;
    assign csr_ret_mem=csr_ret_reg;
    assign csr_we_mem=csr_we_reg;
    assign csr_alu_mem=csr_alu_reg;

    assign except_mem=except_reg;

endmodule
