`timescale 1ps/1ps
`include "ExceptStruct.vh"

module MEM_WB(
    input clk,
    input rst,
    input MEM_WB_stall,
	input MEM_WB_flush,
	input MEM_valid,
	output WB_valid,
    input [63:0] MEM_pc,
    output [63:0] WB_pc,
    input [31:0] MEM_inst,
    output [31:0] WB_inst,
    input [21:0] MEM_decode,
    output [21:0] WB_decode,
    input [63:0] MEM_read_data_1,
    output [63:0] WB_read_data_1,
    input [63:0] MEM_read_data_2,
    output [63:0] WB_read_data_2,
    input [63:0] MEM_alu_out,
    output [63:0] WB_alu_out,
    input [63:0] MEM_trdata,
    output [63:0] WB_trdata,
    input [63:0] MEM_rw_rdata,
    output [63:0] WB_rw_rdata,
    input MEM_br_taken,
    output WB_br_taken,

    input [63:0] csr_val_mem,
    input [1:0] csr_ret_mem,
    input csr_we_mem,
    input [63:0] csr_alu_mem,

    input ExceptStruct::ExceptPack except_mem,

    output [63:0] csr_val_wb,
    output [1:0] csr_ret_wb,
    output csr_we_wb,
    output [63:0] csr_alu_wb,

    output ExceptStruct::ExceptPack except_wb
);

    import ExceptStruct::*;
    
    reg valid_reg;
    reg [63:0] pc_reg;
    reg [31:0] inst_reg;
    reg [21:0] decode_reg;
    reg [63:0] read_data_1_reg;
    reg [63:0] read_data_2_reg;
    reg [63:0] alu_out_reg;
    reg [63:0] trdata_reg;
    reg [63:0] rw_rdata_reg;
    reg br_taken_reg;

    reg [63:0] csr_val_reg;
    reg [1:0] csr_ret_reg;
    reg csr_we_reg;
    reg [63:0] csr_alu_reg;

    ExceptPack except_reg;

    always@(posedge rst or posedge clk) begin
        if(rst|MEM_WB_flush) begin
            valid_reg<=1'b0;
            pc_reg<=64'b0;
            inst_reg<=32'b0;
            decode_reg<=22'b0;
            read_data_1_reg<=64'b0;
            read_data_2_reg<=64'b0;
            alu_out_reg<=64'b0;
            trdata_reg<=64'b0;
            rw_rdata_reg<=64'b0;
            br_taken_reg<=1'b0;

            csr_val_reg<=64'b0;
            csr_ret_reg<=2'b0;
            csr_we_reg<=1'b0;
            csr_alu_reg<=64'b0;

            except_reg<='{except:1'b0, epc:64'b0, ecause:64'b0,etval: 64'b0};
        end else if(!MEM_WB_stall) begin
            valid_reg<=MEM_valid;
            pc_reg<=MEM_pc;
            inst_reg<=MEM_inst;
            decode_reg<=MEM_decode;
            read_data_1_reg<=MEM_read_data_1;
            read_data_2_reg<=MEM_read_data_2;
            alu_out_reg<=MEM_alu_out;
            trdata_reg<=MEM_trdata;
            rw_rdata_reg<=MEM_rw_rdata;
            br_taken_reg<=MEM_br_taken;

            csr_val_reg<=csr_val_mem;
            csr_ret_reg<=csr_ret_mem;
            csr_we_reg<=csr_we_mem;
            csr_alu_reg<=csr_alu_mem;

            except_reg<=except_mem;
        end
    end

    assign WB_valid=valid_reg;
    assign WB_pc=pc_reg;
    assign WB_inst=inst_reg;
    assign WB_decode=decode_reg;
    assign WB_read_data_1=read_data_1_reg;
    assign WB_read_data_2=read_data_2_reg;
    assign WB_alu_out=alu_out_reg;
    assign WB_trdata=trdata_reg;
    assign WB_rw_rdata=rw_rdata_reg;
    assign WB_br_taken=br_taken_reg;

    assign csr_val_wb=csr_val_reg;
    assign csr_ret_wb=csr_ret_reg;
    assign csr_we_wb=csr_we_reg;
    assign csr_alu_wb=csr_alu_reg;

    assign except_wb=except_reg;

endmodule