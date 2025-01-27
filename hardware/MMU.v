`timescale 1ps/1ps

module MMU(
    input rst,
    input clk,
    input [63:0] satp,
    input interrupt,    
    input is_ecall,
    input is_mret,

    input wire if_stall_from_mem,
    output wire if_stall_to_cpu,

    input wire mem_stall_from_mem,
    output wire mem_stall_to_cpu,

    // 指令部分访问内存
    input wire [63:0] inst_addr_from_cpu,
    output wire [63:0] inst_addr_to_mem,

    input wire if_request_from_cpu,
    output wire if_request_to_mem,

    input wire [31:0] inst_from_mem,
    output wire [31:0] inst_to_cpu,

    // 数据部分访问内存
    input wire [63:0] address_from_cpu,
    output wire [63:0] address_to_mem,           /* memory address */

    input wire re_mem_from_cpu,                   /* read enable */
    output wire re_mem_to_mem,                   /* read enable */

    output wire [63:0] rdata_mem_to_cpu,          // rdata_from_mem_to_cpu
    input wire [63:0] rdata_mem_from_mem,          /* read data from memory */

    input wire we_mem_from_cpu,
    output wire we_mem_to_mem,                   /* write enable */

    input wire [63:0] wdata_mem_from_cpu,         /* write data to memory */
    output wire [63:0] wdata_mem_to_mem,         /* write data to memory */

    input wire [7:0] wmask_mem_from_cpu,          /* write enable for each byte */ 
    output wire [7:0] wmask_mem_to_mem          /* write enable for each byte */ 
);

    // reg [63:0] satp_reg;
    // assign satp_reg=satp;
    // satp设置正确
    reg [3:0] satp_mode;
    assign satp_mode = satp[63:60];
    reg [43:0] satp_PPN=satp[43:0];

    localparam IDLE = 2'b00;
    localparam LEVEL1 = 2'b01;
    localparam LEVEL2 = 2'b10;
    localparam LEVEL3 = 2'b11;

    reg if_stall_reg;
    reg [63:0] inst_addr;
    reg if_request;
    reg [31:0] inst;
    reg inst_fetch_finish;

    reg [1:0] MODE;
    reg [1:0] pre_MODE;

    reg [63:0] VA;
    reg [8:0] VA_VPN2;
    reg [8:0] VA_VPN1;
    reg [8:0] VA_VPN0;
    reg [11:0] VA_OFFSET;

    reg mem_fetch_finish;

    reg mem_stall_reg;

    reg [63:0] address_reg;
    reg re_mem_reg;
    reg [63:0] rdata_reg;

    reg we_mem_reg;
    reg [63:0] wdata_reg;
    reg [7:0] wmask_reg;

    reg [63:0] pte;

    reg inst_busy;
    reg mem_busy;
    reg [1:0] tag;

    reg inst_M_mode;
    always@(posedge clk or negedge rst) begin
        if(rst) begin
            inst_M_mode<=0;
        end
        if(is_ecall||inst_addr_from_cpu<64'h800004a8) begin
            inst_M_mode<=1;
        end
        if(is_mret||inst_addr_from_cpu>64'h80210000) begin
            inst_M_mode<=0;
        end
    end

    // 对于inst
    always @(posedge clk or negedge rst) begin
        if(rst) begin
            inst_fetch_finish=1;
            mem_fetch_finish=1;
            MODE<=IDLE;
            pre_MODE<=IDLE;
            
            tag<=0;
        end    
        else if(satp_mode!=8) begin   //说明不是SV39
            inst_fetch_finish=1;
            mem_fetch_finish=1;
            MODE<=IDLE;
            pre_MODE<=IDLE;
        end
        else if(mem_busy) begin
            if_stall_reg<=1;
            if_request<=0;
        end
        else if(if_request_from_cpu) begin  // SV39模式
        
            inst_fetch_finish=0;
            mem_fetch_finish=0;
            VA = inst_addr_from_cpu;
            
            if(MODE==IDLE) begin
                // if_stall_reg<=0;
                if(pre_MODE==IDLE&&if_request_from_cpu) begin
                    inst_busy<=1;
                    // 读取VPN
                    VA_VPN2<=inst_addr_from_cpu[38:30];
                    VA_VPN1<=inst_addr_from_cpu[29:21];
                    VA_VPN0<=inst_addr_from_cpu[20:12];
                    VA_OFFSET<=inst_addr_from_cpu[11:0];
                    
                    if_stall_reg<=1;
                    mem_stall_reg<=0;

                    if_request<=0;
                    address_reg <= {8'b0,satp_PPN,VA_VPN2,3'b0};
                    we_mem_reg<=0;
                    // wdata_reg<=0;
                    // wmask_reg<=0;
                    if(tag==0) tag<=1;
                    else if(tag==1) tag<=2;
                    // tag<=1;
                    
                    // 上面已经设置好了 过了一个cycle再进行访问内存 传递内存信号 cpu的stall信号维持
                    if(tag==2) begin
                        // address_reg <= {8'b0,satp_PPN,VA_VPN2,3'b0};
                        MODE<=LEVEL1;
                        pre_MODE<=IDLE;
                        re_mem_reg<=1;
                    end
                end
                else if(pre_MODE==LEVEL1||pre_MODE==LEVEL2||pre_MODE==LEVEL3) begin
                    if_request<=1;
                    re_mem_reg<=0;
                    if(if_request==1&&if_stall_from_mem==0) begin    //读取好了
                        if_request<=0;
                        inst<=inst_from_mem;
                        if_stall_reg<=0;
                        mem_stall_reg<=0;
                        pre_MODE<=IDLE;
                        inst_busy<=0;
                        tag<=0;
                        // 是load和store指令，说明接下来进行data的部分
                        if(inst_from_mem[6:0]==7'b0000011|inst_from_mem[6:0]==7'b0100011) begin
                            mem_busy<=1;
                            address_reg<=address_from_cpu;
                            // if_stall_reg<=1;
                        end
                        // else begin
                        //     if_stall_reg<=0;
                        // end
                    end
                end
            end
            else if(MODE==LEVEL1) begin
                // if(if_request==1) begin // 读取指令了
                //     inst_fetch_finish=1;
                //     mem_fetch_finish=1;
                // end
                // MODE<=LEVEL1;   // 保持LEVEL1
                pte=rdata_mem_from_mem;  // 读取出来的是pte2

                if(re_mem_reg==1&&mem_stall_from_mem==0) begin// 说明读取出来了

                    re_mem_reg<=0;
                    // 判断当前读取出来的地址是不是正常的
                    // if(address_reg!={8'b0,satp_PPN,VA[38:30],3'b0}) begin 
                    //     // 当前地址不正确，需要回到IDLE重新开始
                    //     MODE<=IDLE;
                    //     pre_MODE<=IDLE;
                    // end
                    // else 
                    if(pte[3:1]==3'b000&&pte[0]==1) begin   // 说明还有接下来的页表
                        address_reg <= {8'b0,pte[53:10],VA_VPN1,3'b0};
                        MODE<=LEVEL2;
                        pre_MODE<=LEVEL1;
                        // re_mem_reg<=1;
                    end
                    else begin  //说明就到这一级页表
                        inst_addr<= {8'b0,pte[53:28],VA_VPN1,VA_VPN0,VA_OFFSET};
                        MODE<=IDLE;
                        pre_MODE<=LEVEL1;
                    end
                end
            end
            else if(MODE==LEVEL2) begin

                // if (is_ecall) begin
                //     inst_fetch_finish=1;
                //     mem_fetch_finish=1;
                // end
                // else if(is_mret) begin
                //     inst_fetch_finish=0;
                //     mem_fetch_finish=0;
                // end

                pte=rdata_mem_from_mem;  // 读取出来的是pte1

                if(re_mem_reg==0) begin
                    re_mem_reg<=1;
                end
                else if(re_mem_reg==1&&mem_stall_from_mem==0) begin// 说明读取出来了

                    re_mem_reg<=0;
                    if(pte[3:1]==3'b000&&pte[0]==1) begin   // 说明还有接下来的页表
                        address_reg <= {8'b0,pte[53:10],VA_VPN0,3'b0};
                        MODE<=LEVEL3;
                        pre_MODE<=LEVEL2;
                        // re_mem_reg<=1;
                    end
                    else begin  //说明就到这一级页表
                        inst_addr<= {8'b0,pte[53:19],VA_VPN0,VA_OFFSET};
                        MODE<=IDLE;
                        pre_MODE<=LEVEL2;
                    end
                end
            end
            else if(MODE==LEVEL3) begin
                pte=rdata_mem_from_mem;  // 读取出来的是pte0

                if(re_mem_reg==0) begin
                    re_mem_reg<=1;
                end
                else if(re_mem_reg==1&&mem_stall_from_mem==0) begin// 说明读取出来了

                    re_mem_reg<=0;
                    
                    inst_addr<= {8'b0,pte[53:10],VA_OFFSET};
                    MODE<=IDLE;
                    pre_MODE<=LEVEL3;
                end
            end
        end
    end

    reg [1:0] MODE2;
    reg [1:0] pre_MODE2;

    reg [63:0] VA2;
    reg [8:0] VA2_VPN2;
    reg [8:0] VA2_VPN1;    
    reg [8:0] VA2_VPN0;
    reg [11:0] VA2_OFFSET;

    reg do_write;
    reg do_read;

    reg temp;
    reg temp2;
    reg [63:0] pte2;

    // 对于data
    always @(posedge clk or negedge rst) begin
        if(rst) begin
            inst_fetch_finish=1;
            mem_fetch_finish=1;
            MODE2<=IDLE;
            pre_MODE2<=IDLE;
        end    
        else if(satp_mode!=8) begin   //说明不是SV39
            inst_fetch_finish=1;
            mem_fetch_finish=1;
            MODE2<=IDLE;
            pre_MODE2<=IDLE;
        end
        // else if(inst_busy) begin
        //     // mem_stall_reg<=0;
        //     we_mem_reg<=0;
        //     // re_mem_reg<=0;
        // end
        // else if(re_mem_from_cpu|we_mem_from_cpu) begin  // SV39模式
        else if(mem_busy) begin  // SV39模式
            temp<=1;
            inst_fetch_finish=0;
            mem_fetch_finish=0;
            VA2 = address_from_cpu;
            
            if(MODE2==IDLE&&temp==1) begin
                // if(pre_MODE2==IDLE&&(re_mem_from_cpu|we_mem_from_cpu)) begin
                
                if(pre_MODE2==IDLE) begin
                    if_stall_reg<=1;
                    mem_stall_reg<=1;
                    if_request<=0;

                    if(re_mem_from_cpu|we_mem_from_cpu) begin
                        // mem_busy<=1;
                        // 读取VPN
                        VA2_VPN2<=VA2[38:30];
                        VA2_VPN1<=VA2[29:21];
                        VA2_VPN0<=VA2[20:12];
                        VA2_OFFSET<=VA2[11:0];

                        temp2<=1;
                        // address_reg <= {8'b0,satp_PPN,VA2_VPN2,3'b0};
                        we_mem_reg<=0;
                        do_write<=we_mem_from_cpu;
                        do_read<=re_mem_from_cpu;
                        wdata_reg<=wdata_mem_from_cpu;
                        wmask_reg<=wmask_mem_from_cpu;
                    
                        // 上面已经设置好了 过了一个cycle再进行访问内存 传递内存信号 cpu的stall信号维持
                        if(temp2==1) begin
                            address_reg <= {8'b0,satp_PPN,VA2_VPN2,3'b0};
                            MODE2<=LEVEL1;
                            pre_MODE2<=IDLE;
                            re_mem_reg<=1;
                        end
                    end
                end
                else if(pre_MODE2==LEVEL1||pre_MODE2==LEVEL2||pre_MODE2==LEVEL3) begin
                    // if_request<=1;
                    re_mem_reg<=re_mem_from_cpu;
                    we_mem_reg<=we_mem_from_cpu;
                    if((re_mem_reg==1||we_mem_reg==1)&&mem_stall_from_mem==0) begin    //读取好了或者写好了
                        re_mem_reg<=0;
                        we_mem_reg<=0;
                        rdata_reg<=rdata_mem_from_mem;
                        if_stall_reg<=0;
                        mem_stall_reg<=0;
                        pre_MODE2<=IDLE;
                        mem_busy<=0;

                        temp<=0;
                        temp2<=0;
                    end
                end
            end
            else if(MODE2==LEVEL1) begin

                pte2=rdata_mem_from_mem;  // 读取出来的是pte2

                if(re_mem_reg==1&&mem_stall_from_mem==0) begin// 说明读取出来了
                    re_mem_reg<=0;
                    if(pte2[3:1]==3'b000&&pte2[0]==1) begin   // 说明还有接下来的页表
                        address_reg <= {8'b0,pte2[53:10],VA2_VPN1,3'b0};
                        MODE2<=LEVEL2;
                        pre_MODE2<=LEVEL1;
                        // re_mem_reg<=1;
                    end
                    else begin  //说明就到这一级页表
                        address_reg <= {8'b0,pte2[53:28],VA2_VPN1,VA2_VPN0,VA2_OFFSET};
                        MODE2<=IDLE;
                        pre_MODE2<=LEVEL1;
                    end
                end
            end
            else if(MODE2==LEVEL2) begin

                pte2=rdata_mem_from_mem;  // 读取出来的是pte1

                if(re_mem_reg==0) begin
                    re_mem_reg<=1;
                end
                else if(re_mem_reg==1&&mem_stall_from_mem==0) begin// 说明读取出来了

                    re_mem_reg<=0;
                    if(pte2[3:1]==3'b000&&pte2[0]==1) begin   // 说明还有接下来的页表
                        address_reg <= {8'b0,pte2[53:10],VA2_VPN0,3'b0};
                        MODE2<=LEVEL3;
                        pre_MODE2<=LEVEL2;
                        // re_mem_reg<=1;
                    end
                    else begin  //说明就到这一级页表
                        address_reg <= {8'b0,pte2[53:19],VA2_VPN0,VA2_OFFSET};
                        MODE2<=IDLE;
                        pre_MODE2<=LEVEL2;
                    end
                end
            end
            else if(MODE2==LEVEL3) begin
                pte2=rdata_mem_from_mem;  // 读取出来的是pte0

                if(re_mem_reg==0) begin
                    re_mem_reg<=1;
                end
                else if(re_mem_reg==1&&mem_stall_from_mem==0) begin// 说明读取出来了

                    re_mem_reg<=0;
                    
                    address_reg<= {8'b0,pte2[53:10],VA2_OFFSET};
                    MODE2<=IDLE;
                    pre_MODE2<=LEVEL3;
                end
            end
        end
    end
    

assign if_stall_to_cpu=inst_fetch_finish?(if_stall_from_mem|~if_request_from_cpu):if_stall_reg;
assign inst_addr_to_mem=inst_fetch_finish?inst_addr_from_cpu:(inst_M_mode?inst_addr_from_cpu:inst_addr);
assign if_request_to_mem=inst_fetch_finish?if_request_from_cpu:if_request;
assign inst_to_cpu=inst_fetch_finish?inst_from_mem:inst;

assign mem_stall_to_cpu=mem_fetch_finish?mem_stall_from_mem:mem_stall_reg;
assign address_to_mem=mem_fetch_finish?address_from_cpu:(inst_M_mode?address_from_cpu:address_reg);
assign re_mem_to_mem=mem_fetch_finish?re_mem_from_cpu:re_mem_reg;
assign rdata_mem_to_cpu=mem_fetch_finish?rdata_mem_from_mem:rdata_reg;
assign we_mem_to_mem=mem_fetch_finish?we_mem_from_cpu:we_mem_reg;
assign wdata_mem_to_mem=mem_fetch_finish?wdata_mem_from_cpu:(inst_M_mode?wdata_mem_from_cpu:wdata_reg);
assign wmask_mem_to_mem=mem_fetch_finish?wmask_mem_from_cpu:(inst_M_mode?wmask_mem_from_cpu:wmask_reg);

endmodule