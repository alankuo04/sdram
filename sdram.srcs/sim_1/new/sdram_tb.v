`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/05/2023 05:47:09 PM
// Design Name: 
// Module Name: sdram__tb
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
reg [31:0] RAM [0:1024*1024*4-1];

reg stb_i;
reg cyc_i;
reg we_i;
reg [3:0] sel_i;
reg [31:0] dat_i;
reg [31:0] adr_i;
wire ack_o;
wire [31:0] dat_o;

reg [31:0] golden_dat;

reg [31:0] dat_o_mem [0:`TEST_NUM-1];

reg [22:0] random_adr [0:`TEST_NUM-1];

integer i, j, k;

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
    j = 0;
    for (k=0; k<`TEST_NUM; k=k+1) begin
        random_adr[k] = $random;
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
        write;
    end
    while (j < `TEST_NUM+3) begin
        @(posedge clk);
        read;
    end
	// $display("-----------------------------------------------------\n");
	// $display("------------------Congratulations!!!-----------------\n");
 	// $display("-----------------------------------------------------\n");
    check;
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
        if (ack_o) begin
            we_i = 1'b1;
            adr_i = random_adr[i];
            dat_i = $random();
            RAM[adr_i] = dat_i;
            $display("Time %t Write: addr: %h, dat_i: %h", $time, adr_i, dat_i);
            i = i + 1;
        end
    end
endtask

task read;
    begin
        if (ack_o) begin
            we_i = 1'b0;
            adr_i = random_adr[j];
            dat_i = 32'hZZZZZZZZ;
            golden_dat = RAM[adr_i];
            $display("Time %t Read: addr: %h, dat_o: %h", $time, adr_i, dat_o);
            // if (golden_dat !== dat_o) begin
            //     $display("Error: addr: %h, golden: %h, dat_o: %h", adr_i, golden_dat, dat_o);
            //     // $finish;
            // end
            if (j - 2 > 0) begin
                dat_o_mem[j - 3] = dat_o;
            end
            j = j + 1;
        end
    end
endtask

task check;
    begin
        for (i = 0; i < `TEST_NUM; i = i + 1) begin
            if (RAM[random_adr[i]] !== dat_o_mem[i]) begin
                $display("Error: addr: %h, golden: %h, dat_o: %h", random_adr[i], RAM[random_adr[i]], dat_o_mem[i]);
                // $finish;
            end
        end
    end
endtask

endmodule
