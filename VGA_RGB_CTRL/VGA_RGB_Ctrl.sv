`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company          : Semicon_Academi
// Engineer         : Jiyun_Han
// 
// Create Date	    : 2025/11/19
// Design Name      : VGA_RGW_SW
// Module Name      : VGA_RGB_Ctrl
// Target Devices   : Basys3
// Tool Versions    : 2020.2
// Description      : VGA_RGB_Ctrl
//
// Revision 	    : 2025/11/19    v1.0 VGA_RGB_Ctrl Base (640*480)
//////////////////////////////////////////////////////////////////////////////////


module VGA_RGB_Ctrl #(
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
    parameter H_MAX   = H_Visible_Area+H_Front_Porch+H_Sync_Pulse+H_Back_Porch,
    parameter V_MAX   = V_Visible_Area+V_Front_Porch+V_Sync_Pulse+V_Back_Porch,
    parameter H_WIDTH = $clog2(H_MAX),
    parameter V_WIDTH = $clog2(V_MAX),
    // Color Section
    parameter X_SECTION = 8,
    parameter Y_SECTION = 2
) (
    // Global Signals
    input  logic       iClk,
    input  logic       iRst,
    input  logic       iBtn_U,
    input  logic       iBtn_L,
    input  logic       iBtn_R,
    input  logic       iBtn_D,
    // VGA_DECODER
    output logic       oH_Sync,
    output logic       oV_Sync,
    // VGA_RGB_SW
    input  logic [3:0] iR_SW,
    input  logic [3:0] iG_SW,
    input  logic [3:0] iB_SW,
    output logic [3:0] oR_Port,
    output logic [3:0] oG_Port,
    output logic [3:0] oB_Port
);


    /***********************************************
    // Reg & Wire
    ***********************************************/
    logic wDE;
    logic wBtn_U;
    logic wBtn_L;
    logic wBtn_R;
    logic wBtn_D;
    logic [H_WIDTH-1:0] wX_Pixel;
    logic [V_WIDTH-1:0] wY_Pixel;


    /***********************************************
    // Instantiation
    ***********************************************/

    Btn_Debounce U_Btn_U (
        .*,
        .iBtn(iBtn_U),
        .oBtn(wBtn_U)
    );
    Btn_Debounce U_Btn_L (
        .*,
        .iBtn(iBtn_L),
        .oBtn(wBtn_L)
    );
    Btn_Debounce U_Btn_R (
        .*,
        .iBtn(iBtn_R),
        .oBtn(wBtn_R)
    );

    Btn_Debounce U_Btn_D (
        .*,
        .iBtn(iBtn_D),
        .oBtn(wBtn_D)
    );

    VGA_Decoder #(
        .H_Visible_Area(H_Visible_Area),
        .H_Front_Porch (H_Front_Porch),
        .H_Sync_Pulse  (H_Sync_Pulse),
        .H_Back_Porch  (H_Back_Porch),
        .V_Visible_Area(V_Visible_Area),
        .V_Front_Porch (V_Front_Porch),
        .V_Sync_Pulse  (V_Sync_Pulse),
        .V_Back_Porch  (V_Back_Porch)
    ) U_VGA_DECODER (
        .*,
        .oDE     (wDE),
        .oX_Pixel(wX_Pixel),
        .oY_Pixel(wY_Pixel)
    );

    VGA_RGB_SW #(
        .H_MAX    (H_MAX),
        .V_MAX    (V_MAX),
        .X_SECTION(X_SECTION),
        .Y_SECTION(Y_SECTION)
    ) U_VGA_RGB_SW (
        .iDE     (wDE),
        .iBtn_U  (wBtn_U),
        .iBtn_L  (wBtn_L),
        .iBtn_R  (wBtn_R),
        .iBtn_D  (wBtn_D),
        .iX_Pixel(wX_Pixel),
        .iY_Pixel(wY_Pixel),
        .*
    );



endmodule
