`timescale 1ps/1ps

module CSR_ALU(
    input [63:0] rs1,
    input [63:0] csr_read,
    input [31:0] inst,
    // input [1:0] csr_alu_op,
    // input [4:0] rd,
    // input [4:0] rs1_id,

    output [63:0] csr_write
);

//csr在csr三条指令和ecall时被写入，计算得到需要被写入csr的值
   reg [63:0] csr_reg;
  // integer i;

  // always @(*) begin
  //   case(csr_alu_op)
  //     2'b00: begin//csrrw alu_op=00 rs1写入csr
  //       csr_reg = rs1;
  //     end
  //     2'b01: begin//csrrs alu_op=01 将rs1对应的位设置为1
  //         if(rs1_id==5'b0)
  //           csr_reg = csr_read;
  //         else begin
  //           for (i = 0; i < 64; i = i + 1) begin
  //               csr_reg[i] = rs1[i]|csr_read[i]; // 将整数的每个位赋值给对应的二进制位
  //           end
  //         end
  //     end
  //     2'b10: begin//csrrc alu_op=10 将rs1对应的位设置为0
  //         for (i = 0; i < 64; i = i + 1) begin
  //             csr_reg[i] = rs1[i]?0:csr_read[i]; // 将整数的每个位赋值给对应的二进制位
  //         end
  //       end
  //     default: begin 
  //       csr_reg = 64'b0;
  //     end
  //   endcase
  // end
  
  // assign csr_write=csr_reg;

  //只有csrrw和csrrs两条 csrrw的rd一定为0 csrrs的rs一定为0
  wire is_csrrw=inst[6:0]==7'b1110011&inst[14:12]==3'b001;
  wire is_csrrs=inst[6:0]==7'b1110011&inst[14:12]==3'b010;
  always@(*) begin
    if(is_csrrw) begin
      csr_reg=rs1;
    end
    else if(is_csrrs) begin
      csr_reg=csr_read;
    end
    else begin
      csr_reg=64'b0;
    end
  end
  assign csr_write=csr_reg;
endmodule