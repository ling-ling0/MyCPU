`include "Define.vh"
`include "TimerStruct.vh"
`include "ExceptStruct.vh"
`include "CSRStruct.vh"
`include "RegStruct.vh"
module Core (
    input wire clk,                       /* 时钟 */ 
    input wire rstn,                       /* 重置信号 */ 

    output wire [63:0] pc,                /* current pc */
    input wire [31:0] inst,               /* read inst from ram */

    output wire [63:0] address,           /* memory address */
    output wire we_mem,                   /* write enable */
    output wire [63:0] wdata_mem,         /* write data to memory */
    output wire [7:0] wmask_mem,          /* write enable for each byte */ 
    output wire re_mem,                   /* read enable */
    input wire [63:0] rdata_mem,          /* read data from memory */

    input wire if_stall,
    input wire mem_stall,
    output wire if_request,               // if请求内存信号

    output wire switch_mode,

    //input wire time_int,
    input TimerStruct::TimerPack time_out,

    // cosim系列
    output cosim_valid,
    output [63:0] cosim_pc,          /* current pc */
    output [31:0] cosim_inst,        /* current instruction */
    output [ 7:0] cosim_rs1_id,      /* rs1 id */
    output [63:0] cosim_rs1_data,    /* rs1 data */
    output [ 7:0] cosim_rs2_id,      /* rs2 id */
    output [63:0] cosim_rs2_data,    /* rs2 data */
    output [63:0] cosim_alu,         /* alu out */
    output [63:0] cosim_mem_addr,    /* memory address */
    output [ 3:0] cosim_mem_we,      /* memory write enable */
    output [63:0] cosim_mem_wdata,   /* memory write data */
    output [63:0] cosim_mem_rdata,   /* memory read data */
    output [ 3:0] cosim_rd_we,       /* rd write enable */
    output [ 7:0] cosim_rd_id,       /* rd id */
    output [63:0] cosim_rd_data,     /* rd data */
    output [ 3:0] cosim_br_taken,    /* branch taken? */
    output [63:0] cosim_npc,         /* next pc */


    output CSRStruct::CSRPack cosim_csr_info,
    output RegStruct::RegPack cosim_regs,

    output cosim_interrupt,
    output [63:0] cosim_cause
);
// 导入模块
    import ExceptStruct::*;
    import TimerStruct::*;

//----------------------------
//剩余变量定义
    wire if_stall_cpu;
    wire mem_stall_cpu;

    wire [63:0] IF_pc;
    wire WB_br_taken;
    wire IF_valid=1;

    wire [63:0] pc_next;

    wire [31:0] ID_inst;
    wire [31:0] IF_inst;
    wire [63:0] ID_pc;
    wire ID_valid;
    wire [21:0] ID_decode;
    wire [63:0] ID_read_data_1;
    wire [63:0] ID_read_data_2;
    wire [63:0] WB_write_data;
    wire [63:0] ID_imm;
    wire ID_br_taken;
    wire [63:0] ID_alu_a;
    wire [63:0] ID_alu_b;
    wire [63:0] EXE_pc;
	wire [21:0] EXE_decode;
    wire [63:0] EXE_read_data_1;
	wire [63:0] EXE_read_data_2;
    wire [63:0] EXE_alu_a;
    wire [63:0] EXE_alu_b;
    wire [31:0] EXE_inst;
    wire EXE_br_taken;
    wire EXE_valid;
    wire [63:0] EXE_alu_out;
    wire [63:0] MEM_pc;
    wire [31:0] MEM_inst;
	wire [21:0] MEM_decode;
    wire [63:0] MEM_alu_out;
    wire [63:0] MEM_read_data_1;
	wire [63:0] MEM_read_data_2;
    wire MEM_br_taken;
    wire MEM_valid;
    wire [7:0] MEM_rw_wmask;
    wire [63:0]MEM_trdata;
    wire [63:0] WB_pc;
    wire [21:0] WB_decode;
    wire [63:0] WB_read_data_1;
	wire [63:0] WB_read_data_2;
    wire [63:0] WB_trdata;
    wire [31:0] WB_inst;
    wire [63:0] WB_rw_rdata;
    wire WB_valid;

    // csr信号
    wire [11:0] csr_addr_id;
    wire [11:0] csr_addr_wb;

    wire [63:0] csr_val_id;     //csr_val需要传递
    wire [63:0] csr_val_exe;
    wire [63:0] csr_val_mem;
    wire [63:0] csr_val_wb;

    wire [1:0] csr_ret_id;      //sret将【0】置为1,mret将【1】置为1
    wire [1:0] csr_ret_exe;     //需要传递
    wire [1:0] csr_ret_mem;
    wire  mret = (WB_inst == 32'h30200073 );
    wire  sret = (WB_inst == 32'h10200073 );
    wire  [1:0]  csr_ret_wb = {mret,sret};

    wire csr_we_id;             //需要传递
    wire csr_we_exe;
    wire csr_we_mem;
    wire csr_we_wb;
    
    wire [63:0] csr_alu_out;
//------------------------------------------------------------

	//ram
    wire [63:0] ID_ro_out;
    wire [63:0] MEM_rw_rdata;
    wire [7:0] EXE_rw_wmask;
    wire [63:0] EXE_data_pkg;
    wire [63:0] WB_alu_out;

    // assign pc=IF_pc;
    // assign address=EXE_alu_out;

    // assign we_mem=EXE_decode[20]&~switch_mode;//内存写使能

    // assign wdata_mem=EXE_data_pkg;
    // assign wmask_mem=EXE_rw_wmask;
    // assign re_mem=(EXE_decode[4:3]==2'b10)&~switch_mode;//内存读使能
    
    // 在没有EXE指令的时候才去获取下一条指令 这也是对于跳转指令运行要多3 cycles的原因
    wire if_request_cpu;
    assign if_request_cpu=~(
        MEM_inst[6:0]==7'b1100011|
        MEM_inst[6:0]==7'b1101111|
        MEM_inst[6:0]==7'b1100111|
        EXE_inst[6:0]==7'b1100011|
        EXE_inst[6:0]==7'b1101111|
        EXE_inst[6:0]==7'b1100111|
        ID_inst[6:0]==7'b1100011|
        ID_inst[6:0]==7'b1101111|
        ID_inst[6:0]==7'b1100111|   // 是跳转指令
        // (csr_we_exe&&csr_addr_exe==12'h180)|    //是设置satp的指令
        // (csr_we_id&&csr_addr_id==12'h180)|
        csr_we_exe|    //是设置satp的指令
        csr_we_id|
        csr_we_mem|
        csr_we_wb|

        ID_inst==`ECALL|ID_inst==`MRET|ID_inst==`SRET|
        EXE_inst==`ECALL|EXE_inst==`MRET|EXE_inst==`SRET|
        MEM_inst==`ECALL|MEM_inst==`MRET|MEM_inst==`SRET|
        WB_inst==`ECALL|WB_inst==`MRET|WB_inst==`SRET|

        MEM_inst[6:0]==7'b0000011|     //是load指令
        EXE_inst[6:0]==7'b0000011|
        ID_inst[6:0]==7'b0000011|
        MEM_inst[6:0]==7'b0100011|     //是store指令
        EXE_inst[6:0]==7'b0100011|
        ID_inst[6:0]==7'b0100011|
        
        // 这里偷懒了 后来实在de不出来了，就直接这样限制了
        MEM_inst!=32'b0|
        EXE_inst!=32'b0|
        ID_inst!=32'b0|
        WB_inst!=32'b0
    );
    // assign IF_inst=inst;
    
    wire [63:0] EXE_rw_rdata;
    // assign EXE_rw_rdata=rdata_mem;

    wire rst;
    assign rst = ~rstn;
    wire valid;

    reg [63:0] satp;
    wire [11:0] csr_addr_exe;
    assign csr_addr_exe = EXE_inst[31:20];
    always @(posedge clk or negedge rst) begin
        if(rst)
            satp <= 64'b0;
        else
            satp <= (csr_we_exe&&csr_addr_exe==12'h180)?csr_alu_out:satp;
    end



    // 这里接入MMU
    MMU mmu(
        .rst(rst),
        .clk(clk),
        .satp(satp),
        .interrupt(cosim_interrupt),

        .is_ecall(ID_inst==`ECALL),
        .is_mret(ID_inst==`MRET),

        .if_stall_from_mem(if_stall),
        .if_stall_to_cpu(if_stall_cpu),
        .mem_stall_from_mem(mem_stall),
        .mem_stall_to_cpu(mem_stall_cpu),

        .inst_addr_from_cpu(IF_pc),
        .inst_addr_to_mem(pc),

        .if_request_from_cpu(if_request_cpu),
        .if_request_to_mem(if_request),

        .inst_from_mem(inst),
        .inst_to_cpu(IF_inst),

        .address_from_cpu(EXE_alu_out),
        .address_to_mem(address),

        .re_mem_from_cpu((EXE_decode[4:3]==2'b10)&~switch_mode),
        .re_mem_to_mem(re_mem),
        
        .rdata_mem_to_cpu(EXE_rw_rdata),
        .rdata_mem_from_mem(rdata_mem),

        .we_mem_from_cpu(EXE_decode[20]&~switch_mode),
        .we_mem_to_mem(we_mem),

        .wdata_mem_from_cpu(EXE_data_pkg),
        .wdata_mem_to_mem(wdata_mem),

        .wmask_mem_from_cpu(EXE_rw_wmask),
        .wmask_mem_to_mem(wmask_mem)
    );

    //stall变量定义============================

    wire IF_ID_stall;
    wire IF_ID_flush;
    wire ID_EXE_stall;
    wire ID_EXE_flush;
    wire EXE_MEM_stall;
    wire EXE_MEM_flush;
    wire MEM_WB_stall;
    wire MEM_WB_flush;
    wire pc_stall;


    // csr部分
    wire [1:0] priv;

    ExceptStruct::ExceptPack except_id='{except:1'b0, epc:64'b0, ecause:64'b0,etval: 64'b0};
    ExceptStruct::ExceptPack except_exe;
    ExceptStruct::ExceptPack except_mem;
    ExceptStruct::ExceptPack except_wb;

    wire [63:0] pc_csr;

    wire is_zicsr_inst;         //解码得到的，说明这条指令是zicsr指令
    wire [1:0] csr_alu_op_id;      //csr_alu的op
    wire [1:0] csr_alu_op_exe;

    wire EXE_forwarding_rs1;
    wire EXE_forwarding_rs2;
    wire MEM_forwarding_rs1;
    wire MEM_forwarding_rs2;

	//IF阶段=========================
    //PC

    pc_mux PC_MUX(
        .pc(IF_pc),
        .alu_out(MEM_alu_out),
        .br_taken(MEM_br_taken),
        .npc_sel(MEM_decode[19]),
        .pc_stall(pc_stall|cosim_interrupt),
        .pc_out(pc_next)
    );
    //最后的pc选择器 对csr和正常的进行选择
    wire [63:0] pc_to_if;
    assign pc_to_if=((csr_ret_wb[0]|csr_ret_wb[1]|except_wb.except|switch_mode))?pc_csr:pc_next;

    PC pc_(
    .clk(clk),
    .rst(rst),
    .pc_next(pc_to_if),
    .pc_out(IF_pc)
    );

	//读取内存的行为也在IF
    //写内存的行为在MEM
    
    // 这一部分是原来直接接入RAM时的接口设置 设置RAM接口信号时参考
	// RAM ram_(
    // .clk(clk),
	// .rstn(rstn),
    // .rw_wmode(EXE_decode[20]),
    // .rw_addr(EXE_alu_out[11:3]),
    // .rw_wdata(EXE_data_pkg),
    // .rw_wmask(EXE_rw_wmask),
    // .rw_rdata(MEM_rw_rdata),
    // .ro_addr(pc_next[11:3]),
    // .ro_rdata(IF_ro_out)
    // );

    //接入RAM的部分
    // assign rw_wmode=EXE_decode[20];
    // assign rw_addr=EXE_alu_out[11:3];
    // assign rw_wdata=EXE_data_pkg;
    // assign rw_wmask=EXE_rw_wmask;
    // assign MEM_rw_rdata=rw_rdata;
    // assign ro_addr=pc_next[11:3];
    // assign IF_ro_out=ro_rdata;
	

    //IF.ID寄存器
	IF_ID if_id(
        .clk(clk),
        .rst(rst),
        .IF_ID_stall(IF_ID_stall),
        .IF_ID_flush(IF_ID_flush),
        .IF_valid(IF_valid),
        .ID_valid(ID_valid),
		.IF_pc(IF_pc),
		.IF_inst(IF_inst),
		.ID_pc(ID_pc),
		.ID_inst(ID_inst)
	);

    //ID阶段====================================
    //有IDpc，IDinst

	//decode 解码
    wire [21:0] ID_decode_out;
    controller control(
        .inst(ID_inst),
        .comb_decode(ID_decode_out),

        .csr_ret_id(csr_ret_id),
        .csr_we_id(csr_we_id),
        .csr_alu_op(csr_alu_op_id),
        .is_zicsr_inst(is_zicsr_inst)
    );

    // assign ID_decode=cosim_interrupt?22'b0:ID_decode_out;
    assign ID_decode = ID_decode_out;

    //register，此处是读取操作
    wire [63:0] ID_read_data_1_fromreg;
    wire [63:0] ID_read_data_2_fromreg;
    Regs Reg_(
        .clk(clk),
        .rst(rst),
        .we(WB_decode[21]&~switch_mode),
        .read_addr_1(ID_inst[19:15]),
        .read_addr_2(ID_inst[24:20]),
        .write_addr(WB_inst[11:7]),
        .write_data(WB_write_data),
        .read_data_1(ID_read_data_1_fromreg),
        .read_data_2(ID_read_data_2_fromreg),
        .cosim_regs(cosim_regs)
    );

    // 为了forwarding实现的
    assign ID_read_data_1=MEM_forwarding_rs1?MEM_alu_out:EXE_forwarding_rs1?EXE_alu_out:ID_read_data_1_fromreg;
    assign ID_read_data_2=MEM_forwarding_rs2?MEM_alu_out:EXE_forwarding_rs2?EXE_alu_out:ID_read_data_2_fromreg;


    //ImmGen
    ImmGen immgen (
        .inst(ID_inst),
        .immgen_op(ID_decode[18:16]),
        .imm(ID_imm)
    );

    //BranchComp
    BranchComp BCp (
        .bralu_op(ID_decode[11:9]),
        .dataR1(ID_read_data_1),
        .dataR2(ID_read_data_2),
        .br_taken(ID_br_taken)
    );
    
	//muxa
    MUX_A muxa (
        .rs1_data(ID_read_data_1),
        .pc(ID_pc),
        .alu_asel(ID_decode[8:7]),
        .alu_a(ID_alu_a)
    );

    //muxb
    MUX_B muxb (
        .rs2_data(ID_read_data_2),
        .imm(ID_imm),
        .alu_bsel(ID_decode[6:5]),
        .alu_b(ID_alu_b)
    );

	//ID_EXE寄存器
	ID_EXE id_exe(
        .clk(clk),
        .rst(rst),
        .ID_EXE_stall(ID_EXE_stall),
        .ID_EXE_flush(ID_EXE_flush),
        .ID_valid(ID_valid),
        .EXE_valid(EXE_valid),
		.ID_pc(ID_pc),
		.EXE_pc(EXE_pc),
        .ID_inst(ID_inst),
        .EXE_inst(EXE_inst),
		.ID_decode(ID_decode),
		.EXE_decode(EXE_decode),
        .ID_read_data_1(ID_read_data_1),
		.EXE_read_data_1(EXE_read_data_1),
		.ID_read_data_2(ID_read_data_2),
		.EXE_read_data_2(EXE_read_data_2),
        .ID_alu_a(ID_alu_a),
        .EXE_alu_a(EXE_alu_a),
        .ID_alu_b(ID_alu_b),
        .EXE_alu_b(EXE_alu_b),
        .ID_br_taken(ID_br_taken),
        .EXE_br_taken(EXE_br_taken),

        .csr_val_id(csr_val_id),
        .csr_ret_id(csr_ret_id),
        .csr_we_id(csr_we_id),
        .csr_alu_op_id(csr_alu_op_id),
        .csr_alu_op_exe(csr_alu_op_exe),
        .csr_val_exe(csr_val_exe),
        .csr_ret_exe(csr_ret_exe),
        .csr_we_exe(csr_we_exe)
	);

	//EXE阶段===========================================
    
    //ALU
    ALU alu (
        .a(EXE_alu_a),
        .b(EXE_alu_b),
        .alu_op(EXE_decode[15:12]),
        .res(EXE_alu_out)
    );

    // 没有使用到 后面可能会用到吧 就先没删
    //--------------------------
    //ALU_CSR_MUX
    // wire [63:0] EXE_alu_out_after;
    // ALU_CSR_MUX alu_csr_mux(
    //     .is_zicsr_inst(is_zicsr_inst),
    //     .alu_out(EXE_alu_out),
    //     .csr_val_exe(csr_val_exe),
    //     .alu_out_after(EXE_alu_out_after)
    // );
    //-------------------------------

    //DataPkg
    DataPkg DataPkg(
    	.data(EXE_read_data_2),
    	.remain(EXE_alu_out),
    	.data_out(EXE_data_pkg)
    );

    //mask
    MaskGen genmask(
   	  .width(EXE_decode[2:0]),
   	  .remain(EXE_alu_out),
   	  .mask(EXE_rw_wmask)
    );


	//EXE_MEM寄存器
	wire [63:0] csr_alu_mem;
    wire [63:0] csr_alu_wb;

	EXE_MEM exe_mem(
        .clk(clk),
        .rst(rst),
        .EXE_MEM_stall(EXE_MEM_stall),
        .EXE_MEM_flush(EXE_MEM_flush),
        .EXE_valid(EXE_valid),
        .MEM_valid(MEM_valid),
		.EXE_pc(EXE_pc),
        .MEM_pc(MEM_pc),
        .EXE_inst(EXE_inst),
        .MEM_inst(MEM_inst),
        .EXE_decode(EXE_decode),
        .MEM_decode(MEM_decode),
        .EXE_read_data_1(EXE_read_data_1),
		.MEM_read_data_1(MEM_read_data_1),
		.EXE_read_data_2(EXE_read_data_2),
		.MEM_read_data_2(MEM_read_data_2),
        .EXE_alu_out(EXE_alu_out),
        .MEM_alu_out(MEM_alu_out),
        //.EXE_data_out(EXE_data_pkg),
        //.MEM_data_out(MEM_data_pkg),
        .EXE_br_taken(EXE_br_taken),
        .MEM_br_taken(MEM_br_taken),
        // .EXE_rw_wmask(EXE_rw_wmask),
        // .MEM_rw_wmask(MEM_rw_wmask)

        .EXE_rw_rdata(EXE_rw_rdata),
        .MEM_rw_rdata(MEM_rw_rdata),

        //.csr_val_exe(csr_alu_out),  ////这个实验里暂时不需要计算csr，直接传就好了
        .csr_val_exe(csr_val_exe),
        .csr_alu_exe(csr_alu_out),
        .csr_ret_exe(csr_ret_exe),
        .csr_we_exe(csr_we_exe),

        .except_exe(except_exe),

        .csr_val_mem(csr_val_mem),
        .csr_alu_mem(csr_alu_mem),
        .csr_ret_mem(csr_ret_mem),
        .csr_we_mem(csr_we_mem),

        .except_mem(except_mem)
	);
    
	//MEM阶段=======================================

    //ram写入过程 不用做什么 只是写在这里 该传递的变量已经在最开始的RAM那里设置好了


    //DataTrunc
    DataTrunc datatrunc(
        .width(MEM_decode[2:0]),
        .remain(MEM_alu_out[2:0]),
        .rdata(MEM_rw_rdata),
        .trdata(MEM_trdata)
    );

    //MEM_WB寄存器
    MEM_WB mem_wb(
        .clk(clk),
        .rst(rst),
        .MEM_WB_stall(MEM_WB_stall),
        .MEM_WB_flush(MEM_WB_flush),
        .MEM_valid(MEM_valid),
        .WB_valid(WB_valid),
        .MEM_pc(MEM_pc),
        .WB_pc(WB_pc),
        .MEM_inst(MEM_inst),
        .WB_inst(WB_inst),
        .MEM_decode(MEM_decode),
        .WB_decode(WB_decode),
        .MEM_read_data_1(MEM_read_data_1),
        .WB_read_data_1(WB_read_data_1),
        .MEM_read_data_2(MEM_read_data_2),
        .WB_read_data_2(WB_read_data_2),
        .MEM_alu_out(MEM_alu_out),
        .WB_alu_out(WB_alu_out),
        .MEM_trdata(MEM_trdata),
        .WB_trdata(WB_trdata),
        .MEM_rw_rdata(MEM_rw_rdata),
        .WB_rw_rdata(WB_rw_rdata),
        .MEM_br_taken(MEM_br_taken),
        .WB_br_taken(WB_br_taken),

        .csr_val_mem(csr_val_mem),
        .csr_alu_mem(csr_alu_mem),
        .csr_ret_mem(csr_ret_mem),
        .csr_we_mem(csr_we_mem),
        .csr_val_wb(csr_val_wb),
        .csr_alu_wb(csr_alu_wb),
        .csr_ret_wb(),//////////////////
        .csr_we_wb(csr_we_wb),

        .except_mem(except_mem),
        .except_wb(except_wb)
    );

	//WB阶段==========================================
    //rb_sec 选择写回的数据
    wire [63:0] WB_write_data_nocsr;
    wb_mux wbmux (
        .alu_out(WB_alu_out),
        .mem(WB_trdata),
        .pc(WB_pc+4),
        .wb_sel(WB_decode[4:3]),
        .wb_data(WB_write_data_nocsr)
    );

    assign WB_write_data=csr_we_wb?csr_val_wb:WB_write_data_nocsr;

	//reg写入 这部分也不在这里做什么 信号的设置在ID阶段那个调用regs的地方


    // racecontroller
    RaceController racecontroller(
        .clk(clk),
        .rst(rst),

        .if_stall(if_stall_cpu),
        .mem_stall(mem_stall_cpu),

        .ID_inst(ID_inst),
        .EXE_inst(EXE_inst),
        .MEM_inst(MEM_inst),
        .WB_inst(WB_inst),
        .ID_decode(ID_decode),
        .EXE_decode(EXE_decode),
        .MEM_decode(MEM_decode),
        .WB_decode(WB_decode),

        //----------------------
        .except_wb(except_wb),
        .interrupt(cosim_interrupt),
        .switch_mode(switch_mode),

        .pc_stall(pc_stall),
        .IF_ID_stall(IF_ID_stall),
        .IF_ID_flush(IF_ID_flush),
        .ID_EXE_stall(ID_EXE_stall),
        .ID_EXE_flush(ID_EXE_flush),
        .EXE_MEM_stall(EXE_MEM_stall),
        .EXE_MEM_flush(EXE_MEM_flush),
        .MEM_WB_stall(MEM_WB_stall),
        .MEM_WB_flush(MEM_WB_flush),

        .EXE_forwarding_rs1(EXE_forwarding_rs1),
        .EXE_forwarding_rs2(EXE_forwarding_rs2),
        .MEM_forwarding_rs1(MEM_forwarding_rs1),
        .MEM_forwarding_rs2(MEM_forwarding_rs2)
    );


//----------------------csr流水线部分
    // core中给定的相关输入和输出
    // output wire switch_mode,
    // input wire time_int,
    // output CSRStruct::CSRPack cosim_csr_info,
    // output RegStruct::RegPack cosim_regs,
    // output cosim_interrupt,
    // output [63:0] cosim_cause


    //IF阶段正常读取指令，这一部分交给原来的流水线就可以

    //ID阶段先执行decode模块，得到csr流水线的信号

    //调用csrModule，这是在解码的同时调用的
    assign csr_addr_id=ID_inst[31:20];
    assign csr_addr_wb=WB_inst[31:20];
    

    CSRModule csrmodule(
        .clk(clk),
        .rst(rst),
        .csr_we_wb(csr_we_wb),
        .csr_addr_wb(csr_addr_wb),
        .csr_val_wb(csr_alu_wb),
        .csr_addr_id(csr_addr_id),
        .csr_val_id(csr_val_id),

        //.pc_wb(pc_wb),
        .pc_wb(WB_pc),
        //.valid_wb(valid_wb),
        .inst_wb(WB_inst),
        .valid_wb(WB_valid),
        //---
        .time_out(time_out),
        .csr_ret_wb(csr_ret_wb),
        .csr_we_wb_temp(csr_we_wb),
        .except_wb(except_wb),
        //----

        .priv(priv),
        .switch_mode(switch_mode),
        .pc_csr(pc_csr),

        .cosim_interrupt(cosim_interrupt),
        .cosim_cause(cosim_cause),
        .cosim_csr_info(cosim_csr_info)

    );

    //EXE阶段进行多路选择
    //CSR_write_mask


    //wire csr_alu_op=
    CSR_ALU csr_alu(
        .rs1(EXE_alu_out),
        .csr_read(csr_val_exe),
        .inst(EXE_inst),
        // .csr_alu_op(csr_alu_op_exe),
        // .rd(EXE_inst[11:7]),
        // .rs1_id(EXE_inst[19:15]),

        .csr_write(csr_alu_out) 
    );
    //assign csr_val_exe=csr_alu_out;

    //MEM阶段写回内存

    //WB阶段写回寄存器，同样调用csrModule

    // examine 之前是只需要检测id阶段的
    wire except_happen_id;
    IDExceptExamine idexceptexamine(
        .clk(clk),
        .rst(rst),
        .stall(ID_EXE_stall),
        .flush(ID_EXE_flush),

        .pc_id(ID_pc),
        .priv(priv),
        .is_ecall_id(ID_inst==`ECALL),
        .is_ebreak_id(ID_inst==`EBREAK),
        .illegal_id((ID_inst[1:0]!=2'b11)&ID_valid),
        .inst_id(ID_inst),
        .valid_id(ID_valid),

        .except_id(except_id),
        .except_exe(except_exe),
        .except_happen_id(except_happen_id)
    );

    assign cosim_valid=WB_valid&~cosim_interrupt;
    assign cosim_pc = WB_pc;
    assign cosim_inst = WB_inst;
    assign cosim_rs1_id = {3'b0,WB_inst[19:15]};
    assign cosim_rs1_data = WB_read_data_1;
    assign cosim_rs2_id = {3'b0,WB_inst[24:20]};
    assign cosim_rs2_data = WB_read_data_2;
    assign cosim_alu = WB_alu_out;
    assign cosim_mem_addr = WB_alu_out;
    assign cosim_mem_we = {3'b0,WB_decode[20]};
    assign cosim_mem_wdata = WB_read_data_2;
    assign cosim_mem_rdata = WB_rw_rdata;
    assign cosim_rd_we = {3'b0,WB_decode[21]};
    assign cosim_rd_id = {3'b0,WB_inst[11:7]};
    assign cosim_rd_data = WB_write_data;
    assign cosim_br_taken = {3'b0,WB_br_taken};
    assign cosim_npc = MEM_pc;

endmodule
