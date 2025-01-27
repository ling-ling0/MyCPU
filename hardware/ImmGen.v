`timescale 1ns/1ps


module ImmGen(
	input [2:0] immgen_op,
	input [31:0] inst,
	output [63:0] imm
);
//immgen_op[2:0]
parameter immgen_0=3'b000;
parameter immgen_I=3'b001;
parameter immgen_S=3'b010;
parameter immgen_B=3'b011;
parameter immgen_U=3'b100;
parameter immgen_J=3'b101;

parameter immgen_csr=3'b110;

reg [63:0] imm_reg;
always@(*) begin
	case (immgen_op) 
		immgen_I://I型32位，扩展为32位符号扩展立即数
		begin
                if(inst[14:12] == 3'b101 && (inst[6:0] == 7'b0010011 || inst[6:0] == 7'b0011011))
                    imm_reg = {{54{inst[31]}}, inst[29:20]};
                //else if(inst[6:0] == 7'b0110111)
                  //  imm_reg = {44'b0, inst[31:12]};
                else
                    imm_reg = {{52{inst[31]}}, inst[31:20]};
            	end
		immgen_B://B型32位，扩展为32位符号扩展立即数
			imm_reg = {{52{inst[31]}},inst[7],inst[30:25],inst[11:8],1'b0};
		immgen_S://S型存数指令
			imm_reg={{52{inst[31]}},inst[31:25],inst[11:7]};
		immgen_U://lui//U型指令
			imm_reg={{32{inst[31]}},inst[31:12],{12{1'b0}}};
		immgen_J://jal//J型指令
			imm_reg={{44{inst[31]}},inst[19:12],inst[20],inst[30:21],1'b0};
		immgen_csr://csr指令
			imm_reg={{52{1'b0}},{inst[31:20]}};
		immgen_0:
			imm_reg={64{1'b0}};
		default:
			imm_reg={64{1'b0}};
	
	endcase
end
assign imm=imm_reg;
endmodule
