module Cache #(
    parameter integer ADDR_WIDTH = 64,
    parameter integer DATA_WIDTH = 64,
    parameter integer BANK_NUM   = 4,
    parameter integer CAPACITY   = 1024
) (
    input                     clk,
    input                     rstn,
    input  [  ADDR_WIDTH-1:0] addr_cpu,
    input  [  DATA_WIDTH-1:0] wdata_cpu,
    input                     wen_cpu,
    input  [DATA_WIDTH/8-1:0] wmask_cpu,
    input                     ren_cpu,
    output [  DATA_WIDTH-1:0] rdata_cpu,
    output                    hit_cpu,

    Mem_ift.Master mem_ift
);

    wire                      ren_mem;
    wire                      wen_mem;
    wire [    ADDR_WIDTH-1:0] raddr_mem;
    wire [    ADDR_WIDTH-1:0] waddr_mem;
    wire [  DATA_WIDTH*2-1:0] wdata_mem;
    wire [DATA_WIDTH*2/8-1:0] wmask_mem;
    wire [  DATA_WIDTH*2-1:0] rdata_mem;
    wire                      wvalid_mem;
    wire                      rvalid_mem;

    assign mem_ift.Mw.waddr = waddr_mem;
    assign mem_ift.Mr.raddr = raddr_mem;
    assign mem_ift.Mw.wen   = wen_mem;
    assign mem_ift.Mr.ren   = ren_mem;
    assign mem_ift.Mw.wdata = wdata_mem;
    assign mem_ift.Mw.wmask = wmask_mem;
    assign rdata_mem        = mem_ift.Sr.rdata;
    assign rvalid_mem       = mem_ift.Sr.rvalid;
    assign wvalid_mem       = mem_ift.Sw.wvalid;

    localparam BYTE_NUM = DATA_WIDTH / 8;
    localparam LINE_NUM = CAPACITY / 2 / (BANK_NUM * BYTE_NUM);
    localparam GRANU_LEN = $clog2(BYTE_NUM);
    localparam GRANU_BEGIN = 0;
    localparam GRANU_END = GRANU_BEGIN + GRANU_LEN - 1;
    localparam OFFSET_LEN = $clog2(BANK_NUM);
    localparam OFFSET_BEGIN = GRANU_END + 1;
    localparam OFFSET_END = OFFSET_BEGIN + OFFSET_LEN - 1;
    localparam INDEX_LEN = $clog2(LINE_NUM);
    localparam INDEX_BEGIN = OFFSET_END + 1;
    localparam INDEX_END = INDEX_BEGIN + INDEX_LEN - 1;
    localparam TAG_BEGIN = INDEX_END + 1;
    localparam TAG_END = ADDR_WIDTH - 1;
    localparam TAG_LEN = ADDR_WIDTH - TAG_BEGIN;
    typedef logic [TAG_LEN-1:0] tag_t;
    typedef logic [INDEX_LEN-1:0] index_t;
    typedef logic [OFFSET_LEN-1:0] offset_t;

    wire [         ADDR_WIDTH-1:0] addr_wb;
    wire [BANK_NUM*DATA_WIDTH-1:0] data_wb;
    wire                           busy_wb;
    wire                           need_wb;

    wire [         ADDR_WIDTH-1:0] addr_cache;
    wire                           miss_cache;
    wire                           set_cache;
    wire                           busy_rd;
    wire [         ADDR_WIDTH-1:0] addr_rd;
    wire [       DATA_WIDTH*2-1:0] data_rd;
    wire                           wen_rd;
    wire                           set_rd;
    wire                           finish_rd;

    CacheBank #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .BANK_NUM  (BANK_NUM),
        .CAPACITY  (CAPACITY)
    ) cache_bank (
        .clk      (clk),
        .rstn     (rstn),
        .addr_cpu (addr_cpu),
        .wdata_cpu(wdata_cpu),
        .wen_cpu  (wen_cpu),
        .wmask_cpu(wmask_cpu),
        .ren_cpu  (ren_cpu),
        .rdata_cpu(rdata_cpu),
        .hit_cpu  (hit_cpu),

        .addr_wb(addr_wb),
        .data_wb(data_wb),
        .busy_wb(busy_wb),
        .need_wb(need_wb),

        .addr_cache(addr_cache),
        .miss_cache(miss_cache),
        .set_cache (set_cache),

        .busy_rd  (busy_rd),
        .addr_rd  (addr_rd),
        .data_rd  (data_rd),
        .wen_rd   (wen_rd),
        .set_rd   (set_rd),
        .finish_rd(finish_rd)
    );

    wire [  ADDR_WIDTH-1:0] addr_mem;
    wire [DATA_WIDTH*2-1:0] data_mem;
    wire [  OFFSET_LEN-2:0] bank_index;
    wire                    finish_wb;
    CacheWriteBuffer #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .BANK_NUM  (BANK_NUM)
    ) cache_write_buffer (
        .clk       (clk),
        .rstn      (rstn),
        .addr_wb   (addr_wb),
        .data_wb   (data_wb),
        .busy_wb   (busy_wb),
        .need_wb   (need_wb),
        .miss_cache(miss_cache),

        .addr_mem  (addr_mem),
        .data_mem  (data_mem),
        .bank_index(bank_index),
        .finish_wb (finish_wb)
    );

    //在这里实现CMU
    
    localparam IDLE=2'b00;
    localparam READ=2'b01;
    localparam WRITE=2'b10;
    reg count;
    //2'b11保留
    reg [1:0] state;
    reg set_cache_reg;
    reg [ADDR_WIDTH-1:0] addr_cache_reg;
    reg busy_rd_reg;
    assign busy_rd=busy_rd_reg;
    reg [ADDR_WIDTH-1:0] raddr_mem_reg;
    assign raddr_mem=raddr_mem_reg;
    reg ren_mem_reg;
    assign ren_mem=ren_mem_reg;
    reg [DATA_WIDTH*2-1:0] data_rd_reg;
    assign data_rd=data_rd_reg;
    reg [ADDR_WIDTH-1:0] addr_rd_reg;
    assign addr_rd=addr_rd_reg;
    reg set_rd_reg;
    assign set_rd=set_rd_reg;
    reg wen_rd_reg;
    assign wen_rd=wen_rd_reg;
    reg finish_rd_reg;
    assign finish_rd=finish_rd_reg;
    reg [ADDR_WIDTH-1:0] waddr_mem_reg;
    assign waddr_mem=waddr_mem_reg;
    reg wen_mem_reg;
    assign wen_mem=wen_mem_reg;
    reg [OFFSET_LEN-2:0] bank_index_reg;
    assign bank_index=bank_index_reg;
    reg [DATA_WIDTH*2-1:0] wdata_mem_reg;
    assign wdata_mem=wdata_mem_reg;
    reg [DATA_WIDTH*2/8-1:0] wmask_mem_reg;
    assign wmask_mem=wmask_mem_reg;
    reg finish_wb_reg;
    assign finish_wb=finish_wb_reg;
    /* verilator lint_off WIDTHEXPAND */

    always@(posedge clk) begin
        case(state)
            IDLE:begin
                //如果 cacheback 检查未失配，有限状态机保持 IDLE 状态，不发出任何控制信号。
                //如果 cachebank 检查失配，cachebank 发送给 write back buffer 的脏数据信号载入 write back buffer，
                //cachebank 发送给 CMU 的载入数据信号载入 CMU 的寄存器，进入 READ 状态，rd_busy 变为 1。

                if(miss_cache)  //检查失配 数据载入buffer已经有实现 CMU寄存器实现在bank最后实现了
                begin
                    state<=READ;
                    busy_rd_reg<=1;
                    set_rd_reg<=set_cache;
                    addr_cache_reg<=addr_cache;
                    raddr_mem_reg<=addr_cache;
                    addr_rd_reg<=raddr_mem_reg;
                    wen_rd_reg<=0;
                    ren_mem_reg<=1;
                end
                else begin
                    state<=IDLE;
                    wen_rd_reg<=0;
                    busy_rd_reg<=0;
                    addr_rd_reg<=raddr_mem_reg;
                end
                finish_rd_reg<=0;
                count<=0;
                finish_wb_reg<=0;
            end
            READ:begin
                //该状态根据 IDLE->READ 载入 CMU 的地址，将数据写回 addr。这里我们的 cache 的 word 是 64 位，
                //但是 memory 的总线是 128 位（因为 DDR2 的 MIG 支持 128 位读写，可以将 cache-memory 的传输效率提高一倍），
                //所以我们每次可以读入两个 word，而不是一个。然后开始如下操作流程：

                //1.将变量 count 初始化为 0
                //2.将 cachline 要读的前 2 个 word 的地址写入 mem_ift.Mr，发送读请求
                //3.等待 mem_ift.Sr.rvalid=1，得到需要的 2 个 word 数据
                //4.根据 CMU 在 IDLE->READ 时候载入的写入 cacheline 的 set、addr，将读到的数据写入 cache
                //5.count++，再次执行第二步读后续的 2 个 word，直到一个 cacheline 读完，发送 finish_rd
                //6.看 write back buffer 是不是 busy，是的话进入 WRITE 状态开始将脏数据写回 memory，不是的话返回 IDLE 状态，完成一次 cache 失配处理，rd_busy 变为 0。

                //1.
                // count<=0;
                //2.
                // ren_mem_reg<=1;
                
                //3.
                if(rvalid_mem && count+1!=2) begin
                    //4.
                    raddr_mem_reg<=raddr_mem_reg+16;
                    data_rd_reg <= rdata_mem;//得到的word数据
                    addr_rd_reg<=raddr_mem_reg;
                    // set_rd_reg<=set_cache;
                    // wen_rd_reg<=1;
                    count<=count+1;
                    state<=READ;//5. 再重复执行一遍
                    addr_cache_reg<=addr_cache;
                    ren_mem_reg<=0;
                    wen_rd_reg<=1;
                end
                else if(rvalid_mem && count+1==2) begin
                    data_rd_reg <= rdata_mem;//得到的word数据
                    // addr_rd_reg<=addr_cache;
                    // set_rd_reg<=set_cache;
                    // wen_rd_reg<=1;
                    if(busy_wb) begin
                        state<=WRITE;
                        waddr_mem_reg<=addr_mem;
                        wdata_mem_reg<=data_mem;
                        wen_mem_reg<=1;
                        bank_index_reg<=1;
                        wmask_mem_reg<={(DATA_WIDTH*2/8){1'b1}};
                    end
                    else if(~busy_wb)begin
                        state<=IDLE;
                    end
                    finish_rd_reg<=1;
                    ren_mem_reg<=0;
                    addr_cache_reg<=addr_cache;
                    wen_rd_reg<=1;
                    count<=0;
                end
                else begin
                    state<=READ;
                    addr_rd_reg<=raddr_mem_reg;
                    ren_mem_reg<=1;
                    wen_rd_reg<=0;
                end


            end
            WRITE:begin
                //该状态将 write back buffer 的数据写回 memory，然后开始如下流程：

                //1.将变量 count 初始化为 0
                //2.向 write back buffer 请求要写的前 2 个 word 的地址写入 mem_ift.Mw，发送写请求
                //3.等待 mem_ift.Sw.wvalid=1，2 个 word 写入完毕
                //4.count++，再次执行第二步读后续的 2 个 word，直到一个 cacheline 读完，发送 finish_wb
                //5.返回 IDLE 状态

                //1.
                //count<=0;
                //2.
                // waddr_mem_reg<=addr_mem;
                // wen_mem_reg<=1;
                // bank_index_reg<=addr_mem-;
                wen_rd_reg<=0;
                if(wvalid_mem && count+1!=2)begin
                    waddr_mem_reg<=waddr_mem_reg+16;
                    wdata_mem_reg<=data_mem;
                    bank_index_reg<=0;
                    // wdata_mem_reg<=data_mem;
                    wmask_mem_reg<={(DATA_WIDTH*2/8){1'b1}};
                    count<=count+1;
                    state<=WRITE;
                    wen_mem_reg<=1;
                end
                else if(wvalid_mem && count+1==2) begin
                    finish_wb_reg<=1;
                    state<=IDLE;
                    count<=0;
                    wen_mem_reg<=0;
                    bank_index_reg<=0;
                end
                else begin
                    state<=WRITE;
                    wen_mem_reg<=0;
                end
            end
            default:begin
                state<=IDLE;
            end
        endcase
    end

endmodule
