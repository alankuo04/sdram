`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/21/2023 05:37:46 PM
// Design Name: 
// Module Name: sdram_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`define CYCLE       10.0
`define DEL         1.0
`define MAX_CYCLE   10000
`define TEST_NUM    5

module sdram_tb;

reg clk;
reg rst;
reg [31:0] RAM [0:1024*4-1];

reg stb_i;
reg cyc_i;
reg we_i;
reg [3:0] sel_i;
reg [31:0] dat_i;
reg [31:0] adr_i;
wire ack_o;
wire [31:0] dat_o;

reg [31:0] golden_dat;

reg [11:0] random_adr [0:`TEST_NUM-1];

integer i, j;

uut uut(
    .wb_clk_i(clk),
    .wb_rst_i(rst),
    .wbs_stb_i(stb_i),
    .wbs_cyc_i(cyc_i),
    .wbs_we_i(we_i),
    .wbs_sel_i(sel_i),
    .wbs_dat_i(dat_i),
    .wbs_adr_i(adr_i),
    .wbs_ack_o(ack_o),
    .wbs_dat_o(dat_o)
);

initial begin
    clk = 1'b0;
    rst = 1'b0;
    stb_i = 1'b1;
    cyc_i = 1'b1;
    we_i = 1'b1;
    sel_i = 4'b0;
    dat_i = 32'b0;
    golden_dat = 32'b0;
    i = 0;
    for (j=0; j<`TEST_NUM; j=j+1) begin
        random_adr[j] = $random;
    end
end

always begin #(`CYCLE/2)  clk = ~clk; end


initial begin
    @(posedge clk)  #`DEL  rst = 1'b1;
    #`CYCLE                rst = 1'b0;

    $display("-----------------------------------------------------\n"); 
    $display("Start to Send Input Data ...");
    $display("\n");
    
    while (i < `TEST_NUM) begin
        @(posedge clk);
        if (ack_o) begin
            write;
            i = i + 1;
        end
    end
    i = 0;
    while (i < `TEST_NUM) begin
        @(posedge clk);
        if (ack_o) begin
            read;
            i = i + 1;
        end
    end
	// $display("-----------------------------------------------------\n");
	// $display("------------------Congratulations!!!-----------------\n");
 	// $display("-----------------------------------------------------\n");
 	$finish;
end

initial begin
	#(`MAX_CYCLE*(`CYCLE));
	$display("-----------------------------------------------------\n");
	$display("Error!!! There is something wrong with your code ...!\n");
 	$display("------The test result is .....FAIL ------------------\n");
 	$display("-----------------------------------------------------\n");
 	$finish;
end

task write;
    begin
        we_i = 1'b1;
        adr_i = random_adr[i];
        dat_i = $random();
        RAM[adr_i] = dat_i;
        $display("Time %t Write: addr: %h, dat_i: %h", $time, adr_i, dat_i);
    end
endtask

task read;
    begin
        we_i = 1'b0;
        adr_i = random_adr[i];
        dat_i = 32'hZZZZZZZZ;
        golden_dat = RAM[adr_i];
        $display("Time %t Read: addr: %h, dat_o: %h", $time, adr_i, dat_o);
        if (golden_dat !== dat_o) begin
            $display("Error: addr: %h, golden: %h, dat_o: %h", adr_i, golden_dat, dat_o);
            // $finish;
        end
    end
endtask

endmodule
