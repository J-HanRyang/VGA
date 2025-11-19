`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company          : Semicon_Academi
// Engineer         : Jiyun_Han
// 
// Create Date	    : 2025/11/19
// Design Name      : VGA_RGW_SW
// Module Name      : VGA_Decoder
// Target Devices   : Basys3
// Tool Versions    : 2020.2
// Description      : VGA_Decoder
//
// Revision 	    : 2025/11/19    v1.0 VGA_Decoder Base (640*480)
//////////////////////////////////////////////////////////////////////////////////

module VGA_Decoder #(
    // Parameter Horizon
    parameter H_Visible_Area = 640,
    parameter H_Front_Porch = 16,
    parameter H_Sync_Pulse = 96,
    parameter H_Back_Porch = 48,
    // Parameter Vertical
    parameter V_Visible_Area = 480,
    parameter V_Front_Porch = 10,
    parameter V_Sync_Pulse = 2,
    parameter V_Back_Porch = 33,
    // WIDTH
    localparam H_MAX   = H_Visible_Area+H_Front_Porch+H_Sync_Pulse+H_Back_Porch,
    localparam V_MAX   = V_Visible_Area+V_Front_Porch+V_Sync_Pulse+V_Back_Porch,
    localparam H_WIDTH = $clog2(H_MAX),
    localparam V_WIDTH = $clog2(V_MAX)
) (
    input  logic               iClk,
    input  logic               iRst,
    output logic               oH_Sync,
    output logic               oV_Sync,
    output logic               oDE,
    output logic [H_WIDTH-1:0] oX_Pixel,
    output logic [V_WIDTH-1:0] oY_Pixel
);

    // Clock Devider
    localparam TARGET_FREQ = H_MAX * V_MAX * 60;  // 60Hz
    localparam CLK_DIV = (100_000_000 + (TARGET_FREQ / 2)) / TARGET_FREQ;

    logic wP_Clk;
    logic [H_WIDTH-1:0] wH_Counter;
    logic [V_WIDTH-1:0] wV_Counter;

    /***********************************************
    // Instantiation
    ***********************************************/
    pixel_clk_gen #(
        .CLK_DIV(CLK_DIV)
    ) U_PIXEL_CLE_GEN (
        .iClk  (iClk),
        .iRst  (iRst),
        .oP_Clk(wP_Clk)
    );

    pixel_counter #(
        .H_MAX(H_MAX),
        .V_MAX(V_MAX)
    ) U_PIXEL_COUNTER (
        .iP_Clk    (wP_Clk),
        .iRst      (iRst),
        .oH_Counter(wH_Counter),
        .oV_Counter(wV_Counter)
    );

    vga_decoder_in #(
        .H_Visible_Area(H_Visible_Area),
        .H_Front_Porch (H_Front_Porch),
        .H_Sync_Pulse  (H_Sync_Pulse),
        .H_Back_Porch  (H_Back_Porch),
        .V_Visible_Area(V_Visible_Area),
        .V_Front_Porch (V_Front_Porch),
        .V_Sync_Pulse  (V_Sync_Pulse),
        .V_Back_Porch  (V_Back_Porch)
    ) U_VGA_DECODER_IN (
        .iH_Counter(wH_Counter),
        .iV_Counter(wV_Counter),
        .oH_Sync   (oH_Sync),
        .oV_Sync   (oV_Sync),
        .oDE       (oDE),
        .oX_Pixel  (oX_Pixel),
        .oY_Pixel  (oY_Pixel)
    );

endmodule

module pixel_clk_gen #(
    parameter  CLK_DIV   = 4,
    localparam CNT_WIDTH = $clog2(CLK_DIV)
) (
    input  logic iClk,
    input  logic iRst,
    output logic oP_Clk
);
    logic [CNT_WIDTH-1:0] pCounter;

    always_ff @(posedge iClk, posedge iRst) begin
        if (iRst) begin
            pCounter <= 0;
            oP_Clk   <= 0;
        end else begin
            if (pCounter == (CLK_DIV - 1)) begin
                pCounter <= 0;
                oP_Clk   <= 1;
            end else begin
                pCounter <= pCounter + 1;
                oP_Clk   <= 1'b0;
            end
        end
    end
endmodule

module pixel_counter #(
    parameter  H_MAX   = 800,
    parameter  V_MAX   = 525,
    localparam H_WIDTH = $clog2(H_MAX),
    localparam V_WIDTH = $clog2(V_MAX)
) (
    input  logic               iP_Clk,
    input  logic               iRst,
    output logic [H_WIDTH-1:0] oH_Counter,
    output logic [V_WIDTH-1:0] oV_Counter
);

    always_ff @(posedge iP_Clk, posedge iRst) begin
        if (iRst) begin
            oH_Counter <= 0;
            oV_Counter <= 0;
        end else begin
            if (oH_Counter == (H_MAX - 1)) begin
                oH_Counter <= 0;

                if (oV_Counter == (V_MAX - 1)) begin
                    oV_Counter <= 0;
                end else begin
                    oV_Counter <= oV_Counter + 1;
                end
            end else begin
                oH_Counter <= oH_Counter + 1;
            end
        end
    end
endmodule

module vga_decoder_in #(
    // Parameter Horizon
    parameter H_Visible_Area = 640,
    parameter H_Front_Porch = 16,
    parameter H_Sync_Pulse = 96,
    parameter H_Back_Porch = 48,
    // Parameter Vertical
    parameter V_Visible_Area = 480,
    parameter V_Front_Porch = 10,
    parameter V_Sync_Pulse = 2,
    parameter V_Back_Porch = 33,
    // WIDTH
    localparam H_MAX   = H_Visible_Area+H_Front_Porch+H_Sync_Pulse+H_Back_Porch,
    localparam V_MAX   = V_Visible_Area+V_Front_Porch+V_Sync_Pulse+V_Back_Porch,
    localparam H_WIDTH = $clog2(H_MAX),
    localparam V_WIDTH = $clog2(V_MAX)
) (
    input  logic [H_WIDTH-1:0] iH_Counter,
    input  logic [V_WIDTH-1:0] iV_Counter,
    output logic               oH_Sync,
    output logic               oV_Sync,
    output logic               oDE,
    output logic [H_WIDTH-1:0] oX_Pixel,
    output logic [V_WIDTH-1:0] oY_Pixel
);

    assign oH_Sync  = !((iH_Counter >= (H_Visible_Area+H_Front_Porch)) && (iH_Counter < (H_Visible_Area+H_Front_Porch+H_Sync_Pulse)));
    assign oV_Sync  = !((iV_Counter >= (V_Visible_Area+V_Front_Porch)) && (iV_Counter < (V_Visible_Area+V_Front_Porch+V_Sync_Pulse)));
    assign oDE      =  ((iH_Counter < H_Visible_Area) && (iV_Counter < V_Visible_Area));
    assign oX_Pixel = iH_Counter;
    assign oY_Pixel = iV_Counter;

endmodule
