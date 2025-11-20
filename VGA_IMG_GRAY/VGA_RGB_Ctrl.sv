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
//                  : 2025/11/20    v1.1 Add Color Bar
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
    // Color Section
    parameter X_SECTION = 8,
    parameter Y_SECTION = 2,
    // WIDTH
    localparam H_MAX   = H_Visible_Area+H_Front_Porch+H_Sync_Pulse+H_Back_Porch,
    localparam V_MAX   = V_Visible_Area+V_Front_Porch+V_Sync_Pulse+V_Back_Porch,
    localparam H_WIDTH = $clog2(H_MAX),
    localparam V_WIDTH = $clog2(V_MAX),
    // QVGA
    localparam IMG_H = H_Visible_Area / 2,
    localparam IMG_V = V_Visible_Area / 2,
    localparam WIDTH = $clog2(IMG_H * IMG_V)
) (
    // Global Signals
    input  logic       iClk,
    input  logic       iRst,
    input  logic [2:0] iSel,
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
    logic               wDE;
    logic               wBtn_U;
    logic               wBtn_L;
    logic               wBtn_R;
    logic               wBtn_D;
    logic [H_WIDTH-1:0] wX_Pixel;
    logic [V_WIDTH-1:0] wY_Pixel;
    // SW_Control
    logic [        3:0] wSW_R_Port;
    logic [        3:0] wSW_G_Port;
    logic [        3:0] wSW_B_Port;
    logic [       11:0] wSW_Port;
    assign wSW_Port = {wSW_R_Port, wSW_G_Port, wSW_B_Port};
    // Color Bar
    logic [ 3:0] wBar_R_Port;
    logic [ 3:0] wBar_G_Port;
    logic [ 3:0] wBar_B_Port;
    logic [11:0] wBar_Port;
    assign wBar_Port = {wBar_R_Port, wBar_G_Port, wBar_B_Port};
    // QVGA Image
    logic [ 3:0] wQVGA_R_Port;
    logic [ 3:0] wQVGA_G_Port;
    logic [ 3:0] wQVGA_B_Port;
    logic [11:0] wQVGA_Port;
    assign wQVGA_Port = {wQVGA_R_Port, wQVGA_G_Port, wQVGA_B_Port};
    // VGA Image
    logic [ 3:0] wVGA_R_Port;
    logic [ 3:0] wVGA_G_Port;
    logic [ 3:0] wVGA_B_Port;
    logic [11:0] wVGA_Port;
    assign wVGA_Port = {wVGA_R_Port, wVGA_G_Port, wVGA_B_Port};
    // Mux_DeMux
    logic [WIDTH-1:0] wAddr;
    logic [WIDTH-1:0] wAddr_qvga;
    logic [WIDTH-1:0] wAddr_vga;
    logic [     15:0] wImg_Data;
    logic [     15:0] wImg_qvga;
    logic [     15:0] wImg_vga;
    logic [     11:0] wData;


    /***********************************************
    // Instantiation
    ***********************************************/
    /*************************************
    // Btn_Decounce
    *************************************/
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

    /*************************************
    // VGA_Decoder
    *************************************/
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

    /*************************************
    // Output Image
    *************************************/
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
        .oR_Port (wSW_R_Port),
        .oG_Port (wSW_G_Port),
        .oB_Port (wSW_B_Port),
        .*
    );

    VGA_ColorBar U_COLOR_BAR (
        .display_enable(wDE),
        .x_pixel       (wX_Pixel),
        .y_pixel       (wY_Pixel),
        .red_port      (wBar_R_Port),
        .green_port    (wBar_G_Port),
        .blue_port     (wBar_B_Port)
    );

    IMG_ROM #(
        .H_Visible_Area(H_Visible_Area),
        .V_Visible_Area(V_Visible_Area)
    ) U_IMG_ROM (
        .iAddr(wAddr),
        .oData(wImg_Data)
    );

    Mux_2x1 #(
        .BIT_SIZE(WIDTH)
    ) U_MUX_ROM (
        .iSel  (iSel[0]),
        .iData0(wAddr_qvga),
        .iData1(wAddr_vga),
        .oData (wAddr)
    );

    DeMux_2x1 #(
        .BIT_SIZE(16)
    ) U_DEMUX_ROM (
        .iSel  (iSel[0]),
        .iData (wImg_Data),
        .oData0(wImg_qvga),
        .oData1(wImg_vga)
    );

    IMG_MEM_Reader #(
        .H_MAX         (H_MAX),
        .V_MAX         (V_MAX),
        .H_Visible_Area(H_Visible_Area),
        .V_Visible_Area(V_Visible_Area)
    ) U_IMG_MEM_READER (
        .iDE      (wDE),
        .iX_Pixel (wX_Pixel),
        .iY_Pixel (wY_Pixel),
        .oAddr    (wAddr_qvga),
        .iImg_Data(wImg_qvga),
        .oR_Port  (wQVGA_R_Port),
        .oG_Port  (wQVGA_G_Port),
        .oB_Port  (wQVGA_B_Port)
    );

    IMG_MEM_Reader_Scaling #(
        .H_MAX         (H_MAX),
        .V_MAX         (V_MAX),
        .H_Visible_Area(H_Visible_Area),
        .V_Visible_Area(V_Visible_Area)
    ) U_IMG_MEM_READER_SCALING (
        .iDE      (wDE),
        .iX_Pixel (wX_Pixel),
        .iY_Pixel (wY_Pixel),
        .oAddr    (wAddr_vga),
        .iImg_Data(wImg_vga),
        .oR_Port  (wVGA_R_Port),
        .oG_Port  (wVGA_G_Port),
        .oB_Port  (wVGA_B_Port)
    );

    logic [11:0] wRGB_Data;
    Mux_4x1 #(
        .BIT_SIZE(12)
    ) U_MUX_OUT (
        .iSel  (iSel[1:0]),
        .iData0(wSW_Port),
        .iData1(wBar_Port),
        .iData2(wQVGA_Port),
        .iData3(wVGA_Port),
        .oData (wRGB_Data)
    );

    logic [11:0] wGray_Data;

    Gray_Scale U_GRAY_SCLAE (
        .iData(wRGB_Data),
        .oData(wGray_Data)
    );

    Mux_2x1 #(
        .BIT_SIZE(12)
    ) U_MUX_GRAY_OUT (
        .iSel  (iSel[2]),
        .iData0(wRGB_Data),
        .iData1(wGray_Data),
        .oData (wData)
    );

    assign oR_Port = wData[11:8];
    assign oG_Port = wData[7:4];
    assign oB_Port = wData[3:0];

endmodule
