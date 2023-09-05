`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/05/2023 05:46:44 PM
// Design Name: 
// Module Name: uut
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
`define MPRJ_IO_PADS_1 19	/* number of user GPIO pads on user1 side */
`define MPRJ_IO_PADS_2 19	/* number of user GPIO pads on user2 side */
`define MPRJ_IO_PADS (`MPRJ_IO_PADS_1 + `MPRJ_IO_PADS_2)

module uut(
// Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o
);

    wire clk;
    wire rst, rst_n;

    wire valid;

    wire sdram_cle;
    wire sdram_cs;
    wire sdram_cas;
    wire sdram_ras;
    wire sdram_we;
    wire sdram_dqm;
    wire [1:0] sdram_ba;
    wire [12:0] sdram_a;
    wire [31:0] d2c_data;
    wire [31:0] c2d_data;
    wire [3:0]  bram_mask;

    wire [22:0] ctrl_addr;
    wire ctrl_busy;
    wire ctrl_out_valid;

    // reg ack, ctrl_out_valid_q;

    // WB MI A
    assign valid = wbs_stb_i;
    assign wbs_ack_o = (wbs_we_i) ? ~ctrl_busy : ctrl_out_valid;
    // assign wbs_ack_o = ack;

    assign clk = wb_clk_i;
    assign rst = wb_rst_i;
    assign rst_n = ~rst;
    assign ctrl_addr = wbs_adr_i[22:0];

    // assign bram_mask = {4{sdram_dqm}};
    assign bram_mask = wbs_sel_i;

    // always@(posedge clk) begin
    //     if (rst) begin
    //         ack <= 1'b0;
    //         ctrl_out_valid_q <= 1'b0;
    //     end
    //     else begin
    //         ctrl_out_valid_q <= ctrl_out_valid;
    //         if (wbs_we_i) begin
    //             if (ctrl_busy) begin
    //                 ack <= 1'b0;
    //             end
    //             else begin
    //                 ack <= ctrl_out_valid_q ? 1'b0 : 1'b1;
    //             end
    //         end
    //         else begin
    //             if (ctrl_busy) begin
    //                 ack <= 1'b0;
    //             end
    //             else begin
    //                 ack <= ctrl_out_valid_q ? 1'b1 : 1'b0;
    //             end
    //         end
    //     end
    // end

    sdram_controller user_sdram_controller (
        .clk(clk),
        .rst(rst),
        
        .sdram_cle(sdram_cle),
        .sdram_cs(sdram_cs),
        .sdram_cas(sdram_cas),
        .sdram_ras(sdram_ras),
        .sdram_we(sdram_we),
        .sdram_dqm(sdram_dqm),
        .sdram_ba(sdram_ba),
        .sdram_a(sdram_a),
        .sdram_dqi(d2c_data),
        .sdram_dqo(c2d_data),

        .user_addr(ctrl_addr),
        .rw(wbs_we_i),
        .data_in(wbs_dat_i),
        .data_out(wbs_dat_o),
        .busy(ctrl_busy),
        .in_valid(valid),
        .out_valid(ctrl_out_valid)
    );

    sdr user_bram (
        .Rst_n(rst_n),
        .Clk(clk),
        .Cke(sdram_cle),
        .Cs_n(sdram_cs),
        .Ras_n(sdram_ras),
        .Cas_n(sdram_cas),
        .We_n(sdram_we),
        .Addr(sdram_a),
        .Ba(sdram_ba),
        .Dqm(bram_mask),
        .Dqi(c2d_data),
        .Dqo(d2c_data)
    );

endmodule
