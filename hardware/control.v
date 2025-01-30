`include "Define.vh"

module controller(
  input [31:0] inst,
  output wire [21:0] comb_decode,

  output wire [1:0] csr_ret_id,
  output wire csr_we_id,
  output wire [1:0] csr_alu_op,
  output wire is_zicsr_inst
);
/*
  reg we_reg;		//21
  reg we_mem;		//20
  reg npc_sel;		//19
  reg [2:0] immgen_op;	//18-16
  reg [3:0] alu_op;	//15-12
  reg [2:0] bralu_op;	//11-9
  reg [1:0] alu_asel;	//8-7
  reg [1:0] alu_bsel;	//6-5
  reg [1:0] wb_sel;	//4-3
  reg [2:0] memdata_width;//2-0
 */

 wire [6:0] opcode=inst[6:0];
 wire [2:0] op_2=inst[14:12];

 wire is_rtype=opcode==7'b0110011;//rtype instruction
    wire is_sub=(op_2==3'b000)&&inst[30]&&is_rtype;
    wire is_add=(op_2==3'b000)&&~inst[30]&&is_rtype;
    wire is_sll=op_2==3'b001&&is_rtype;
    wire is_slt=op_2==3'b010&&is_rtype;
    wire is_sltu=op_2==3'b011&&is_rtype;
    wire is_xor=op_2==3'b100&&is_rtype;
    wire is_sra=(op_2==3'b101)&&inst[30]&&is_rtype;
    wire is_srl=(op_2==3'b101)&&~inst[30]&&is_rtype;
    wire is_or=op_2==3'b110&&is_rtype;
    wire is_and=op_2==3'b111&&is_rtype;
 wire is_load=opcode==7'b0000011;//load instruction
    wire is_lb=op_2==3'b000&&is_load;
    wire is_lh=op_2==3'b001&&is_load;
    wire is_lw=op_2==3'b010&&is_load;
    wire is_ld=op_2==3'b011&&is_load;
    wire is_lbu=op_2==3'b100&&is_load;
    wire is_lhu=op_2==3'b101&&is_load;
    wire is_lwu=op_2==3'b110&&is_load;
wire is_itype=opcode==7'b0010011;//itype instruction
    wire is_addi=op_2==3'b000&&is_itype;
    wire is_slli=op_2==3'b001&&is_itype;
    wire is_slti=op_2==3'b010&&is_itype;
    wire is_sltiu=op_2==3'b011&&is_itype;
    wire is_xori=op_2==3'b100&&is_itype;
    wire is_srai=(op_2==3'b101)&&inst[30]&&is_itype;
    wire is_srli=(op_2==3'b101)&&~inst[30]&&is_itype;
    wire is_ori=op_2==3'b110&&is_itype;
    wire is_andi=op_2==3'b111&&is_itype;
wire is_store=opcode==7'b0100011;//store instruction
    wire is_sb=op_2==3'b000&&is_store;
    wire is_sh=op_2==3'b001&&is_store;
    wire is_sw=op_2==3'b010&&is_store;
    wire is_sd=op_2==3'b011&&is_store;
wire is_btype=opcode==7'b1100011;//btype instruction
    wire is_beq=op_2==3'b000&&is_btype;
    wire is_bne=op_2==3'b001&&is_btype;
    wire is_blt=op_2==3'b100&&is_btype;
    wire is_bge=op_2==3'b101&&is_btype;
    wire is_bltu=op_2==3'b110&&is_btype;
    wire is_bgeu=op_2==3'b111&&is_btype;

wire is_lui=opcode==7'b0110111;
wire is_auipc=opcode==7'b0010111;
wire is_jal=opcode==7'b1101111;
wire is_jalr=opcode==7'b1100111;

wire is_itypew=opcode==7'b0011011;//itypew instruction
    wire is_addiw=op_2==3'b000&&is_itypew;
    wire is_slliw=op_2==3'b001&&is_itypew;
    wire is_sraiw=op_2==3'b101&&inst[30]&&is_itypew;
    wire is_srliw=op_2==3'b101&&~inst[30]&&is_itypew;
wire is_rtypew=opcode==7'b0111011;//rtypew instruciton
    wire is_subw=(op_2==3'b000)&&inst[30]&&is_rtypew;
    wire is_addw=(op_2==3'b000)&&~inst[30]&&is_rtypew;
    wire is_sllw=op_2==3'b001&&is_rtypew;
    wire is_sraw=(op_2==3'b101)&&inst[30]&&is_rtypew;
    wire is_srlw=(op_2==3'b101)&&~inst[30]&&is_rtypew;

//---------------lab6 扩展部分--------------------------------------------------
    wire is_mret= inst==`MRET;
    wire is_sret= inst==`SRET;

wire is_zicsr=opcode==7'b1110011&~is_mret&~is_sret;
    wire is_csrrw=op_2==3'b001&&is_zicsr;//本来应该使用define中的三个宏定义来写的
    wire is_csrrs=op_2==3'b010&&is_zicsr;
    wire is_csrrc=op_2==3'b011&&is_zicsr;

    // wire is_csrrwi=op_2==3'b101&&is_zicsr;
    // wire is_csrrsi=op_2==3'b110&&is_zicsr;
    // wire is_csrrci=op_2==3'b111&&is_zicsr;

assign csr_ret_id[1]=is_mret;
assign csr_ret_id[0]=is_sret;
assign is_zicsr_inst=is_zicsr;

assign csr_we_id=is_csrrw|is_csrrs|is_csrrc;
assign csr_alu_op[1]=is_csrrc;
assign csr_alu_op[0]=is_csrrs;

//------------------------------------------------------------------------

wire we_reg=is_rtype|is_load|is_itype|is_lui|is_auipc|is_jal|is_itypew|is_rtypew|is_jalr|is_zicsr;
wire we_mem=is_store;
wire npc_sel=is_btype|is_jalr|is_jal;
//
wire [2:0] immgen_op;
assign immgen_op[2]=is_lui|is_auipc|is_jal|is_jal|is_zicsr;
assign immgen_op[1]=is_store|is_btype|is_zicsr;
assign immgen_op[0]=is_load|is_itype|is_btype|is_itypew|is_jalr|is_jal;
//
wire [3:0] alu_op;
assign alu_op[3]=is_sra|is_srl|is_srai|is_srli|is_itypew|is_rtypew;
assign alu_op[2]=is_sll|is_slt|is_sltu|is_xor|is_slli|is_slti|is_sltiu|is_xori|is_slliw|is_sraiw|is_srliw|is_sllw|is_sraw|is_srlw;
assign alu_op[1]=is_sll|is_sltu|is_or|is_and|is_slli|is_sltiu|is_ori|is_andi|is_addiw|is_sraiw|is_subw|is_addw|is_sraw;
assign alu_op[0]=is_sub|is_sll|is_slt|is_sra|is_or|is_slli|is_slti|is_srai|is_ori|is_srliw|is_subw|is_srlw;
wire [2:0] bralu_op;
assign bralu_op[2]=is_bge|is_bltu|is_bgeu;
assign bralu_op[1]=is_bne|is_blt|is_bgeu;
assign bralu_op[0]=is_beq|is_blt|is_bltu;
wire [1:0] alu_asel;
assign alu_asel[1]=is_btype|is_auipc|is_jal;
assign alu_asel[0]=is_rtype|is_load|is_itype|is_store|is_itypew|is_rtypew|is_jalr|is_zicsr;
wire [1:0] alu_bsel;
assign alu_bsel[1]=is_load|is_itype|is_store|is_btype|is_lui|is_auipc|is_jal|is_itypew|is_jalr;
assign alu_bsel[0]=is_rtype|is_rtypew;
wire [1:0] wb_sel;
assign wb_sel[1]=is_load|is_jal|is_jalr;
assign wb_sel[0]=is_rtype|is_itype|is_btype|is_lui|is_auipc|is_jal|is_jalr|is_itypew|is_rtypew|is_zicsr;
wire [2:0] memdata_width;
assign memdata_width[2]=is_lb|is_lbu|is_lhu|is_lwu|is_sb;
assign memdata_width[1]=is_lh|is_lw|is_lbu|is_lhu|is_sh|is_sw;
assign memdata_width[0]=is_lh|is_ld|is_lbu|is_lwu|is_sh|is_sd;
assign comb_decode={we_reg,we_mem,npc_sel,immgen_op,alu_op,bralu_op,alu_asel,alu_bsel,wb_sel,memdata_width};

endmodule
