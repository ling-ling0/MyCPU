`timescale 1ns / 1ps
 
module DataTrunc (	//对内存中读出的数据进行切割
    input  [ 2:0] width,
    input  [ 2:0] remain,
    input  [63:0] rdata,
    output [63:0] trdata
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


    reg  [ 7:0] mask_reg;
    reg  [63:0] data_reg;
    reg  [ 3:0] help;
    reg  [63:0] data_temp1;
    reg  [63:0] data_temp2;
    wire [ 7:0] mask;
    integer i;
    integer j;
    always @(*) begin
        case (width)
            mem_no: mask_reg = 8'b11111111; // 不访存
            mem_double: mask_reg = 8'b11111111; // double word
            mem_word: mask_reg = 8'b00001111; // word
            mem_half: mask_reg = 8'b00000011; // Half word
            mem_byte: mask_reg = 8'b00000001; // Byte
            mem_unword: mask_reg = 8'b00001111; // Unsigned word
            mem_unhalf: mask_reg = 8'b00000011; // Unsigned Half word
            mem_unbyte: mask_reg = 8'b00000001; // Unsigned Byte
            default:mask_reg = 8'b11111111;
        endcase
    end

    always @(*) begin	//有符号
        case (width)
            mem_word: help = 4; // word
            mem_half: help = 2; // Half word
            mem_byte: help = 1; // Byte
            default:help = 8;
        endcase
    end
    
    assign mask = mask_reg << remain;

    always @(*) begin
        for(i = 0; i < 8; i = i+1) begin
            if(mask[i])
                data_reg[i*8 +: 8] = rdata[i*8 +: 8];
            else
                data_reg[i*8 +: 8] = 8'b00000000;
        end
    end
    always @(*) begin
        data_temp1 = data_reg << (8*(8-help-remain));
        if(width > 3'b000 && width < 3'b101)
            data_temp2 = $signed(data_temp1) >>> (8*(8-help));
        else
            data_temp2 = data_reg >> (8*remain);
    end

    assign trdata = data_temp2;

endmodule
