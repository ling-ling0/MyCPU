`timescale 1ns / 1ps

module BranchComp(
    input   [2:0]   bralu_op,
    input   [63:0]  dataR1,
    input   [63:0]  dataR2,
    output          br_taken //
);

    reg out;
    always @(*) begin
        case(bralu_op)
            3'b000: out = 1; //none
            3'b001: out = (dataR1 == dataR2) ? 1 : 0; //EQ
            3'b010: out = (dataR1 == dataR2) ? 0 : 1; //NE
            3'b011: begin //LT
                    if(dataR1[63] == 0 && dataR2[63] == 1) out = 0;
                    else if(dataR1[63]== 1 && dataR2[63] == 0) out = 1;
                    else if(dataR1[62:0] < dataR2[62:0]) out = 1;
                    else out = 0;
                    end
            3'b100: begin //GE
                    if(dataR1[63] == 0 && dataR2[63] == 1) out = 1;
                    else if(dataR1[63] == 1 && dataR2[63] == 0) out = 0;
                    else if(dataR1[62:0] < dataR2[62:0]) out = 0;
                    else out = 1;
                    end
            3'b101: out = (dataR1 < dataR2)  ? 1 : 0; //LTU
            3'b110: out = (dataR1 >= dataR2) ? 1 : 0; //GEU
            default:out = 0; 
        endcase
    end
    assign br_taken = out;

endmodule

