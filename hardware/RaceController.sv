`timescale 1ps/1ps
`include "ExceptStruct.vh"

// 这个模块写的是最不好的 里面很多嵌套 但是已经堆积成shi山了 不是很敢动 只能哪里有问题动哪里

module RaceController(
    input clk,
    input rst,

    input if_stall,
    input mem_stall,

    input [31:0] ID_inst,
    input [31:0] EXE_inst,
    input [31:0] MEM_inst,
    input [31:0] WB_inst,
    input [21:0] ID_decode,
    input [21:0] EXE_decode,
    input [21:0] MEM_decode,
    input [21:0] WB_decode,

    //--------------------
    input ExceptStruct::ExceptPack except_wb,
    input interrupt,
    input switch_mode,
    //---------------------

    output pc_stall,
    output IF_ID_stall,
    output IF_ID_flush,                                                                                 
    output ID_EXE_stall,
    output ID_EXE_flush,
    output EXE_MEM_stall,
    output EXE_MEM_flush,
    output MEM_WB_stall,
    output MEM_WB_flush,

    output EXE_forwarding_rs1,
    output EXE_forwarding_rs2,
    output MEM_forwarding_rs1,
    output MEM_forwarding_rs2
);

    import ExceptStruct::ExceptPack;
    
    wire [4:0] ID_rs1=ID_inst[19:15];
    wire [4:0] ID_rs2=ID_inst[24:20];
    wire [4:0] EXE_rd=EXE_inst[11:7];
    wire [4:0] MEM_rd=MEM_inst[11:7];
    wire [4:0] WB_rd=WB_inst[11:7];

    wire ID_is_b=ID_inst[6:0]==7'b1100011;
    wire ID_is_jal=ID_inst[6:0]==7'b1101111;
    wire ID_is_jalr=ID_inst[6:0]==7'b1100111;
    wire EXE_is_b=EXE_inst[6:0]==7'b1100011;
    wire EXE_is_jal=EXE_inst[6:0]==7'b1101111;
    wire EXE_is_jalr=EXE_inst[6:0]==7'b1100111;
    wire MEM_is_b=MEM_inst[6:0]==7'b1100011;
    wire MEM_is_jal=MEM_inst[6:0]==7'b1101111;
    wire MEM_is_jalr=MEM_inst[6:0]==7'b1100111;
    wire WB_is_b=WB_inst[6:0]==7'b1100011;
    wire WB_is_jal=WB_inst[6:0]==7'b1101111;
    wire WB_is_jalr=WB_inst[6:0]==7'b1100111;

    wire EXE_wb=EXE_decode[4:3]!=2'b00;//&EXE_rd!=4'b0;
    wire MEM_wb=MEM_decode[4:3]!=2'b00;//&MEM_rd!=4'b0;
    wire WB_wb=WB_decode[4:3]!=2'b00;//&WB_rd!=4'b0;
//===============================================
//新加的forwarding
    //EXE_for需要先满足EXE和ID的数据冲突，再选择EXE的格式
    wire EXE_for_rs1=(EXE_wb&ID_rs1==EXE_rd)&EXE_decode[4:3]==2'b01&EXE_rd!=5'b0;
    wire EXE_for_rs2=(ID_rs2==EXE_rd&EXE_wb)&EXE_decode[4:3]==2'b01&EXE_rd!=5'b0;
    wire EXE_for=EXE_for_rs2|EXE_for_rs1;

    wire MEM_for_rs1=(MEM_wb&ID_rs1==MEM_rd)&MEM_decode[4:3]==2'b10&MEM_rd!=5'b0&!(EXE_for&EXE_rd==MEM_rd);
    wire MEM_for_rs2=(ID_rs2==MEM_rd&MEM_wb)&MEM_decode[4:3]==2'b10&MEM_rd!=5'b0&!(EXE_for&EXE_rd==MEM_rd);
    wire MEM_for=MEM_for_rs2|MEM_for_rs1;

//===============================================

    reg pc_stall_reg;
    reg IF_ID_stall_reg;
    reg IF_ID_flush_reg;
    reg ID_EXE_stall_reg;
    reg ID_EXE_flush_reg;
    reg EXE_MEM_stall_reg;
    reg EXE_MEM_flush_reg;
    reg MEM_WB_stall_reg;
    reg MEM_WB_flush_reg;

    
    always@(*) begin
        if(rst) begin
            pc_stall_reg=1'b0;
            IF_ID_stall_reg=1'b0;
            IF_ID_flush_reg=1'b0;
            ID_EXE_stall_reg=1'b0;
            ID_EXE_flush_reg=1'b0;
            EXE_MEM_stall_reg=1'b0;
            EXE_MEM_flush_reg=1'b0;
            MEM_WB_stall_reg=1'b0;
            MEM_WB_flush_reg=1'b0;
        end
        else if(mem_stall) begin
            if(ID_is_b|ID_is_jal|ID_is_jalr) begin
                pc_stall_reg=1'b1;
                IF_ID_stall_reg=1'b1;
                IF_ID_flush_reg=1'b1;
                ID_EXE_stall_reg=1'b0;
                ID_EXE_flush_reg=1'b0;
                EXE_MEM_stall_reg=1'b0;
                EXE_MEM_flush_reg=1'b0;
                MEM_WB_stall_reg=1'b0;
                MEM_WB_flush_reg=1'b0;
            end
            else if(EXE_is_b|EXE_is_jal|EXE_is_jalr) begin
                pc_stall_reg=1'b1;
                IF_ID_stall_reg=1'b1;
                IF_ID_flush_reg=1'b1;
                ID_EXE_stall_reg=1'b0;
                ID_EXE_flush_reg=1'b1;
                EXE_MEM_stall_reg=1'b0;
                EXE_MEM_flush_reg=1'b0;
                MEM_WB_stall_reg=1'b0;
                MEM_WB_flush_reg=1'b0;
            end
            else if(MEM_is_b|MEM_is_jal|MEM_is_jalr) begin
                pc_stall_reg=1'b1;
                IF_ID_stall_reg=1'b1;
                IF_ID_flush_reg=1'b1;
                ID_EXE_stall_reg=1'b0;
                ID_EXE_flush_reg=1'b1;
                EXE_MEM_stall_reg=1'b0;
                EXE_MEM_flush_reg=1'b1;
                MEM_WB_stall_reg=1'b0;
                MEM_WB_flush_reg=1'b0;
            end else begin
                pc_stall_reg=1'b1;
                IF_ID_stall_reg=1'b1;
                IF_ID_flush_reg=1'b0;
                ID_EXE_stall_reg=1'b1;
                ID_EXE_flush_reg=1'b0;
                EXE_MEM_stall_reg=1'b1;
                EXE_MEM_flush_reg=1'b0;
                MEM_WB_stall_reg=1'b0;
                MEM_WB_flush_reg=1'b0;
            end
        end
        else if(if_stall) begin
            if(ID_is_b|ID_is_jal|ID_is_jalr) begin
                if(WB_wb&ID_rs1==WB_rd|ID_rs2==WB_rd&WB_wb) begin
                    pc_stall_reg=1'b1;
                    IF_ID_stall_reg=1'b1;
                    IF_ID_flush_reg=1'b0;
                    ID_EXE_stall_reg=1'b1;
                    ID_EXE_flush_reg=1'b1;
                    EXE_MEM_stall_reg=1'b0;
                    EXE_MEM_flush_reg=1'b0;
                    MEM_WB_stall_reg=1'b0;
                    MEM_WB_flush_reg=1'b0;
                end
                else begin
                    pc_stall_reg=1'b1;
                    IF_ID_stall_reg=1'b1;
                    IF_ID_flush_reg=1'b1;
                    ID_EXE_stall_reg=1'b0;
                    ID_EXE_flush_reg=1'b0;
                    EXE_MEM_stall_reg=1'b0;
                    EXE_MEM_flush_reg=1'b0;
                    MEM_WB_stall_reg=1'b0;
                    MEM_WB_flush_reg=1'b0;
                end
            end
            else if(EXE_is_b|EXE_is_jal|EXE_is_jalr) begin
                pc_stall_reg=1'b1;
                IF_ID_stall_reg=1'b1;
                IF_ID_flush_reg=1'b1;
                ID_EXE_stall_reg=1'b0;
                ID_EXE_flush_reg=1'b1;
                EXE_MEM_stall_reg=1'b0;
                EXE_MEM_flush_reg=1'b0;
                MEM_WB_stall_reg=1'b0;
                MEM_WB_flush_reg=1'b0;
            end
            else if(MEM_is_b|MEM_is_jal|MEM_is_jalr) begin
                pc_stall_reg=1'b1;
                IF_ID_stall_reg=1'b1;
                IF_ID_flush_reg=1'b1;
                ID_EXE_stall_reg=1'b0;
                ID_EXE_flush_reg=1'b1;
                EXE_MEM_stall_reg=1'b0;
                EXE_MEM_flush_reg=1'b1;
                MEM_WB_stall_reg=1'b0;
                MEM_WB_flush_reg=1'b0;
            end else if(except_wb.except|switch_mode) begin
                pc_stall_reg=1'b1;
                IF_ID_stall_reg=1'b0;
                IF_ID_flush_reg=1'b1;
                ID_EXE_stall_reg=1'b0;
                ID_EXE_flush_reg=1'b1;
                EXE_MEM_stall_reg=1'b0;
                EXE_MEM_flush_reg=1'b1;
                MEM_WB_stall_reg=1'b0;
                MEM_WB_flush_reg=1'b1;
            end else begin
                pc_stall_reg=1'b1;
                IF_ID_stall_reg=1'b1;
                IF_ID_flush_reg=1'b1;
                ID_EXE_stall_reg=1'b0;
                ID_EXE_flush_reg=1'b0;
                EXE_MEM_stall_reg=1'b0;
                EXE_MEM_flush_reg=1'b0;
                MEM_WB_stall_reg=1'b0;
                MEM_WB_flush_reg=1'b0;
            end
        end
    //----------------如果有except的话，将所有flush信号置为1,stall置为0
        else if(switch_mode) begin
                pc_stall_reg=1'b0;
                IF_ID_stall_reg=1'b0;
                IF_ID_flush_reg=1'b1;
                ID_EXE_stall_reg=1'b0;
                ID_EXE_flush_reg=1'b1;
                EXE_MEM_stall_reg=1'b0;
                EXE_MEM_flush_reg=1'b1;
                MEM_WB_stall_reg=1'b0;
                MEM_WB_flush_reg=1'b1;
        end
        else if(except_wb.except) begin
                pc_stall_reg=1'b1;
                IF_ID_stall_reg=1'b0;
                IF_ID_flush_reg=1'b1;
                ID_EXE_stall_reg=1'b0;
                ID_EXE_flush_reg=1'b1;
                EXE_MEM_stall_reg=1'b0;
                EXE_MEM_flush_reg=1'b1;
                MEM_WB_stall_reg=1'b0;
                MEM_WB_flush_reg=1'b1;
        end
    //数据冲突========================================
        else if(WB_wb&ID_rs1==WB_rd|ID_rs2==WB_rd&WB_wb) begin
            // if(EXE_for) begin
            //     pc_stall_reg=1'b0;
            //     IF_ID_stall_reg=1'b0;
            //     IF_ID_flush_reg=1'b0;
            //     ID_EXE_stall_reg=1'b0;
            //     ID_EXE_flush_reg=1'b0;
            //     EXE_MEM_stall_reg=1'b0;
            //     EXE_MEM_flush_reg=1'b0;
            //     MEM_WB_stall_reg=1'b0;
            //     MEM_WB_flush_reg=1'b0;
            // end
            // else begin
                pc_stall_reg=1'b1;
                IF_ID_stall_reg=1'b1;
                IF_ID_flush_reg=1'b0;
                ID_EXE_stall_reg=1'b1;
                ID_EXE_flush_reg=1'b1;
                EXE_MEM_stall_reg=1'b0;
                EXE_MEM_flush_reg=1'b0;
                MEM_WB_stall_reg=1'b0;
                MEM_WB_flush_reg=1'b0;
            //end
        end
        else if(MEM_wb&ID_rs1==MEM_rd|ID_rs2==MEM_rd&MEM_wb) begin
            if(MEM_for) begin
                if(ID_is_b|ID_is_jal|ID_is_jalr) begin
                    pc_stall_reg=1'b1;
                    IF_ID_stall_reg=1'b1;
                    IF_ID_flush_reg=1'b1;
                    ID_EXE_stall_reg=1'b1;//
                    ID_EXE_flush_reg=1'b0;
                    EXE_MEM_stall_reg=1'b0;
                    EXE_MEM_flush_reg=1'b0;
                    MEM_WB_stall_reg=1'b0;
                    MEM_WB_flush_reg=1'b0;
                end
                else if(EXE_is_b|EXE_is_jal|EXE_is_jalr) begin
                    pc_stall_reg=1'b1;
                    IF_ID_stall_reg=1'b1;
                    IF_ID_flush_reg=1'b1;
                    ID_EXE_stall_reg=1'b0;
                    ID_EXE_flush_reg=1'b1;
                    EXE_MEM_stall_reg=1'b0;
                    EXE_MEM_flush_reg=1'b0;
                    MEM_WB_stall_reg=1'b0;
                    MEM_WB_flush_reg=1'b0;
                end
                else if(MEM_is_b|MEM_is_jal|MEM_is_jalr) begin
                    pc_stall_reg=1'b1;
                    IF_ID_stall_reg=1'b1;
                    IF_ID_flush_reg=1'b1;
                    ID_EXE_stall_reg=1'b0;
                    ID_EXE_flush_reg=1'b1;
                    EXE_MEM_stall_reg=1'b0;
                    EXE_MEM_flush_reg=1'b1;
                    MEM_WB_stall_reg=1'b0;
                    MEM_WB_flush_reg=1'b0;
                end
                else if(WB_is_b|WB_is_jal|WB_is_jalr) begin
                    pc_stall_reg=1'b1;
                    IF_ID_stall_reg=1'b1;
                    IF_ID_flush_reg=1'b1;
                    ID_EXE_stall_reg=1'b0;
                    ID_EXE_flush_reg=1'b1;
                    EXE_MEM_stall_reg=1'b0;
                    EXE_MEM_flush_reg=1'b1;
                    MEM_WB_stall_reg=1'b0;
                    MEM_WB_flush_reg=1'b1;
                end else begin
                    pc_stall_reg=1'b0;
                    IF_ID_stall_reg=1'b0;
                    IF_ID_flush_reg=1'b0;
                    ID_EXE_stall_reg=1'b0;
                    ID_EXE_flush_reg=1'b0;
                    EXE_MEM_stall_reg=1'b0;
                    EXE_MEM_flush_reg=1'b0;
                    MEM_WB_stall_reg=1'b0;
                    MEM_WB_flush_reg=1'b0;
                end
            end else begin
                pc_stall_reg=1'b1;
                IF_ID_stall_reg=1'b1;
                IF_ID_flush_reg=1'b0;
                ID_EXE_stall_reg=1'b0;
                ID_EXE_flush_reg=1'b1;
                EXE_MEM_stall_reg=1'b0;
                EXE_MEM_flush_reg=1'b0;
                MEM_WB_stall_reg=1'b0;
                MEM_WB_flush_reg=1'b0;
            end
        end
        else if(EXE_wb&ID_rs1==EXE_rd|ID_rs2==EXE_rd&EXE_wb) begin
            if(EXE_for) begin
                if(ID_is_b|ID_is_jal|ID_is_jalr) begin
                    pc_stall_reg=1'b1;
                    IF_ID_stall_reg=1'b1;
                    IF_ID_flush_reg=1'b1;
                    ID_EXE_stall_reg=1'b0;
                    ID_EXE_flush_reg=1'b0;
                    EXE_MEM_stall_reg=1'b0;
                    EXE_MEM_flush_reg=1'b0;
                    MEM_WB_stall_reg=1'b0;
                    MEM_WB_flush_reg=1'b0;
                end
                else if(EXE_is_b|EXE_is_jal|EXE_is_jalr) begin
                    pc_stall_reg=1'b1;
                    IF_ID_stall_reg=1'b1;
                    IF_ID_flush_reg=1'b1;
                    ID_EXE_stall_reg=1'b0;
                    ID_EXE_flush_reg=1'b1;
                    EXE_MEM_stall_reg=1'b0;
                    EXE_MEM_flush_reg=1'b0;
                    MEM_WB_stall_reg=1'b0;
                    MEM_WB_flush_reg=1'b0;
                end
                else if(MEM_is_b|MEM_is_jal|MEM_is_jalr) begin
                    pc_stall_reg=1'b1;
                    IF_ID_stall_reg=1'b1;
                    IF_ID_flush_reg=1'b1;
                    ID_EXE_stall_reg=1'b0;
                    ID_EXE_flush_reg=1'b1;
                    EXE_MEM_stall_reg=1'b0;
                    EXE_MEM_flush_reg=1'b1;
                    MEM_WB_stall_reg=1'b0;
                    MEM_WB_flush_reg=1'b0;
                end
                else if(WB_is_b|WB_is_jal|WB_is_jalr) begin
                    pc_stall_reg=1'b1;
                    IF_ID_stall_reg=1'b1;
                    IF_ID_flush_reg=1'b1;
                    ID_EXE_stall_reg=1'b0;
                    ID_EXE_flush_reg=1'b1;
                    EXE_MEM_stall_reg=1'b0;
                    EXE_MEM_flush_reg=1'b1;
                    MEM_WB_stall_reg=1'b0;
                    MEM_WB_flush_reg=1'b1;
                end else begin
                    pc_stall_reg=1'b0;
                    IF_ID_stall_reg=1'b0;
                    IF_ID_flush_reg=1'b0;
                    ID_EXE_stall_reg=1'b0;
                    ID_EXE_flush_reg=1'b0;
                    EXE_MEM_stall_reg=1'b0;
                    EXE_MEM_flush_reg=1'b0;
                    MEM_WB_stall_reg=1'b0;
                    MEM_WB_flush_reg=1'b0;
                end
            end else begin
                pc_stall_reg=1'b1;
                IF_ID_stall_reg=1'b1;
                IF_ID_flush_reg=1'b0;
                ID_EXE_stall_reg=1'b0;
                ID_EXE_flush_reg=1'b1;
                EXE_MEM_stall_reg=1'b0;
                EXE_MEM_flush_reg=1'b0;
                MEM_WB_stall_reg=1'b0;
                MEM_WB_flush_reg=1'b0;
            end
        end
    //数据冲突结束====================================================
    //控制冲突=========================================================
        else if(ID_is_b|ID_is_jal|ID_is_jalr) begin
            pc_stall_reg=1'b1;
            IF_ID_stall_reg=1'b1;
            IF_ID_flush_reg=1'b1;
            ID_EXE_stall_reg=1'b0;
            ID_EXE_flush_reg=1'b0;
            EXE_MEM_stall_reg=1'b0;
            EXE_MEM_flush_reg=1'b0;
            MEM_WB_stall_reg=1'b0;
            MEM_WB_flush_reg=1'b0;
        end
        else if(EXE_is_b|EXE_is_jal|EXE_is_jalr) begin
            pc_stall_reg=1'b1;
            IF_ID_stall_reg=1'b1;
            IF_ID_flush_reg=1'b1;
            ID_EXE_stall_reg=1'b0;
            ID_EXE_flush_reg=1'b1;
            EXE_MEM_stall_reg=1'b0;
            EXE_MEM_flush_reg=1'b0;
            MEM_WB_stall_reg=1'b0;
            MEM_WB_flush_reg=1'b0;
        end
        else if(MEM_is_b|MEM_is_jal|MEM_is_jalr) begin
            pc_stall_reg=1'b1;
            IF_ID_stall_reg=1'b1;
            IF_ID_flush_reg=1'b1;
            ID_EXE_stall_reg=1'b0;
            ID_EXE_flush_reg=1'b1;
            EXE_MEM_stall_reg=1'b0;
            EXE_MEM_flush_reg=1'b1;
            MEM_WB_stall_reg=1'b0;
            MEM_WB_flush_reg=1'b0;
        end
        else if(WB_is_b|WB_is_jal|WB_is_jalr) begin
            pc_stall_reg=1'b1;
            IF_ID_stall_reg=1'b1;
            IF_ID_flush_reg=1'b1;
            ID_EXE_stall_reg=1'b0;
            ID_EXE_flush_reg=1'b1;
            EXE_MEM_stall_reg=1'b0;
            EXE_MEM_flush_reg=1'b1;
            MEM_WB_stall_reg=1'b0;
            MEM_WB_flush_reg=1'b1;
        end
    //控制结束=====================================
        else begin
            pc_stall_reg=1'b0;
            IF_ID_stall_reg=1'b0;
            IF_ID_flush_reg=1'b0;
            ID_EXE_stall_reg=1'b0;
            ID_EXE_flush_reg=1'b0;
            EXE_MEM_stall_reg=1'b0;
            EXE_MEM_flush_reg=1'b0;
            MEM_WB_stall_reg=1'b0;
            MEM_WB_flush_reg=1'b0;
        end
    end


    assign pc_stall=pc_stall_reg;
    assign IF_ID_stall=IF_ID_stall_reg;
    assign IF_ID_flush=IF_ID_flush_reg;
    assign ID_EXE_stall=ID_EXE_stall_reg;
    assign ID_EXE_flush=ID_EXE_flush_reg;
    assign EXE_MEM_stall=EXE_MEM_stall_reg;
    assign EXE_MEM_flush=EXE_MEM_flush_reg;
    assign MEM_WB_stall=MEM_WB_stall_reg;
    assign MEM_WB_flush=MEM_WB_flush_reg;

    assign EXE_forwarding_rs1=EXE_for_rs1;
    assign EXE_forwarding_rs2=EXE_for_rs2;
    assign MEM_forwarding_rs1=MEM_for_rs1;
    assign MEM_forwarding_rs2=MEM_for_rs2;


endmodule