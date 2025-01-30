`timescale 1ns / 1ps
/* verilator lint_off LATCH */

module ALU (
    input  [63:0] a,                // 输入端口 a，位宽为 64 位
    input  [63:0] b,                // 输入端口 b，位宽为 64 位
    input  [3:0]  alu_op,           // 输入端口 alu_op，位宽为 4 位，用于选择 ALU 操作
    output [63:0] res               // 输出寄存器 res，位宽为 64 位，存储 ALU 运算结果
);
    reg [63:0] resreg;
    reg [31:0] resreg_32;

//alu_op[3:0]
parameter ADD = 4'b0000;
parameter SUB = 4'b0001;
parameter AND = 4'b0010;
parameter OR = 4'b0011;
parameter XOR = 4'b0100;
parameter SLT = 4'b0101;
parameter SLTU = 4'b0110;
parameter SLL = 4'b0111;
parameter SRL = 4'b1000;
parameter SRA = 4'b1001;
parameter ADDW = 4'b1010;
parameter SUBW = 4'b1011;
parameter SLLW = 4'b1100;
parameter SRLW = 4'b1101;
parameter SRAW = 4'b1110;


    always @(*) begin               // 组合逻辑块，根据 alu_op 执行相应的 ALU 运算
        case (alu_op)
            ADD:    resreg = a + b;           // 加法运算
            SUB:    resreg = a - b;           // 减法运算
            AND:    resreg = a & b;           // 位与运算
            OR:     resreg = a | b;            // 位或运算
            XOR:    resreg = a ^ b;           // 位异或运算
            SLT:    begin
                    if(a[63] == 0 && b[63] == 1) resreg = 0;
                    else if(a[63] == 1 && b[63] == 0) resreg = 1;
                    else if(a[62:0] < b[62:0]) resreg = 1;
                    else resreg = 0;
                    end  // 有符号比较，判断 a 是否小于 b
            SLTU:   resreg = (a < b) ? 1 : 0;                     // 无符号比较，判断 a 是否小于 b
            SLL:    begin
                        if(b[63])
                            resreg = a << (63-~b); 
                        else
                            resreg = a << b;       // 逻辑左移运算
                    end        
            SRL:    begin
                        if(b[63])
                            resreg = a >> (63-~b); 
                        else
                            resreg = a >> b;          // 逻辑右移运算
                    end 
            SRA:    begin
                        if(b[63])
                            resreg = $signed(a) >>> (63-~b); 
                        else
                            resreg = $signed(a) >>> b;        // 算术右移运算
                    end 
        //---------------------------此处开始word部分
            ADDW:   //resreg = {{32{1'b0}},{$signed(a[31:0] + b[31:0])}};                  // 有符号加法运算，结果截断为 32 位
                begin
                    resreg_32 = $signed(a[31:0] + b[31:0]);
                    resreg = {{32{resreg_32[31]}},{resreg_32}};
                end
            SUBW:   //resreg = {{32{1'b0}},{$signed(a[31:0] - b[31:0])}};                  // 有符号减法运算，结果截断为 32 位
                begin
                    resreg_32 = $signed(a[31:0] - b[31:0]);
                    resreg = {{32{resreg_32[31]}},{resreg_32}};
                end
            SLLW:   begin
                        if(b[31]) begin
                            //resreg = {{32{1'b0}},{$signed(a[31:0] << (31-~b[31:0]))}}; 
                            resreg_32 = $signed(a[31:0] << (31-~b[31:0]));
                            resreg = {{32{resreg_32[31]}},{resreg_32}};
                        end
                        else begin
                            //resreg = {{32{1'b0}},{$signed(a[31:0] << b[31:0])}};         // 逻辑左移运算，结果截断为 32 位
                            resreg_32 = $signed(a[31:0] << b[31:0]);
                            resreg = {{32{resreg_32[31]}},{resreg_32}};
                        end
                    end
            SRLW:   begin
                        if(b[31]) begin
                            //resreg = {{32{1'b0}},{$signed(a[31:0] >> (31-~b[31:0]))}}; 
                            resreg_32 = $signed(a[31:0] >> (31-~b[31:0]));
                            resreg = {{32{resreg_32[31]}},{resreg_32}};
                        end
                        else begin
                            //resreg = {{32{1'b0}},{$signed(a[31:0] >> b[31:0])}};       // 逻辑右移运算，结果截断为 32 位
                            resreg_32 = $signed(a[31:0] >> b[31:0]);
                            resreg = {{32{resreg_32[31]}},{resreg_32}};
                        end
                    end       
            SRAW:   begin
                        if(b[31]) begin
                            //resreg = {{32{1'b0}},{$signed(a[31:0]) >>> (31-~b[31:0])}}; 
                            resreg_32 = $signed(a[31:0]) >>> (31-~b[31:0]);
                            resreg = {{32{resreg_32[31]}},{resreg_32}};
                        end
                        else begin
                            //resreg = {{32{1'b0}},{$signed(a[31:0]) >>> b[31:0]}};     // 有符号算术右移运算，结果截断为 32 位
                            resreg_32 = $signed(a[31:0]) >>> b[31:0];
                            resreg = {{32{resreg_32[31]}},{resreg_32}};
                        end
                    end 
            default: begin 
                resreg_32 = 0;
                resreg = 0;           // 默认情况，将 res 置为零
            end
        endcase
    end

    assign res = resreg;    
    
endmodule
