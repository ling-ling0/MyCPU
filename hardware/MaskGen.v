`timescale 1ns / 1ps
 
module MaskGen (	//得到对应的掩码
    input [2:0] width,
    input [63:0] remain,
    output [7:0] mask
);
//memdata_width[2:0]
parameter mem_no=3'b000;
parameter mem_double = 3'b001;
parameter mem_word = 3'b010;
parameter mem_half = 3'b011;
parameter mem_byte = 3'b100;
parameter mem_unword = 3'b101;
parameter mem_unhalf = 3'b110;
parameter mem_unbyte = 3'b111;

    reg  [7:0] mask_reg;
    always @(*) begin
        case (width)
            mem_no:  mask_reg = 8'b11111111; // 不访存
            mem_double:  mask_reg = 8'b11111111; // double word
            mem_word:  mask_reg = 8'b00001111; // word
            mem_half:  mask_reg = 8'b00000011; // Half word
            mem_byte:  mask_reg = 8'b00000001; // Byte
            mem_unword:  mask_reg = 8'b00001111; // Unsigned word
            mem_unhalf:  mask_reg = 8'b00000011; // Unsigned Half word
            mem_unbyte:  mask_reg = 8'b00000001; // Unsigned Byte
            default: mask_reg = 8'b11111111;
        endcase
    end
    assign mask = mask_reg << remain[2:0];
endmodule
