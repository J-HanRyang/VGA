`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company          : Semicon_Academi
// Engineer         : Jiyun_Han
// 
// Create Date	    : 2025/11/20
// Design Name      : VGA_IMG_ROM
// Module Name      : IMG_MEM_Reader
// Target Devices   : Basys3
// Tool Versions    : 2020.2
// Description      : IMG_MEM_Reader
//
// Revision 	    : 
//////////////////////////////////////////////////////////////////////////////////

// Up Scaling
module IMG_MEM_Reader_Scaling #(
    parameter  H_MAX          = 800,
    parameter  V_MAX          = 525,
    parameter  H_Visible_Area = 640,
    parameter  V_Visible_Area = 480,
    localparam H_WIDTH        = $clog2(H_MAX),
    localparam V_WIDTH        = $clog2(V_MAX),
    localparam IMG_H          = H_Visible_Area / 2,
    localparam IMG_V          = V_Visible_Area / 2,
    localparam WIDTH          = $clog2(IMG_H * IMG_V)
) (
    input  logic               iDE,
    input  logic [H_WIDTH-1:0] iX_Pixel,
    input  logic [V_WIDTH-1:0] iY_Pixel,
    output logic [  WIDTH-1:0] oAddr,

    input  logic [15:0] iImg_Data,
    output logic [ 3:0] oR_Port,
    output logic [ 3:0] oG_Port,
    output logic [ 3:0] oB_Port
);

    // logic wImg_En;
    // assign wImg_En = iDE && (iX_Pixel < IMG_H) && (iY_Pixel < IMG_V);

    logic [H_WIDTH-1:0] wRom_X;
    logic [V_WIDTH-1:0] wRom_Y;

    assign wRom_X = iX_Pixel[H_WIDTH-1:1];
    assign wRom_Y = iY_Pixel[V_WIDTH-1:1];

    assign oAddr = iDE ? (IMG_H * wRom_Y) + wRom_X : 'bz;
    assign {oR_Port, oG_Port, oB_Port} = iDE ? {iImg_Data[15:12], iImg_Data[10:7], iImg_Data[4:1]} : 0;
endmodule

// Center Image
module IMG_MEM_Reader #(
    parameter  H_MAX          = 800,
    parameter  V_MAX          = 525,
    parameter  H_Visible_Area = 640,
    parameter  V_Visible_Area = 480,
    localparam H_WIDTH        = $clog2(H_MAX),
    localparam V_WIDTH        = $clog2(V_MAX),
    localparam IMG_H          = H_Visible_Area / 2,
    localparam IMG_V          = V_Visible_Area / 2,
    localparam WIDTH          = $clog2(IMG_H * IMG_V)
) (
    input  logic               iDE,
    input  logic [H_WIDTH-1:0] iX_Pixel,
    input  logic [V_WIDTH-1:0] iY_Pixel,
    output logic [  WIDTH-1:0] oAddr,

    input  logic [15:0] iImg_Data,
    output logic [ 3:0] oR_Port,
    output logic [ 3:0] oG_Port,
    output logic [ 3:0] oB_Port
);

    // Start Pointer
    localparam X_START = (H_Visible_Area - IMG_H) / 2;  // 160
    localparam Y_START = (V_Visible_Area - IMG_V) / 2;  // 120
    localparam X_END = X_START + IMG_H;  // 480
    localparam Y_END = Y_START + IMG_V;  // 360

    logic wImg_En;

    assign wImg_En = iDE && 
                     (iX_Pixel >= X_START) && (iX_Pixel < X_END) &&
                     (iY_Pixel >= Y_START) && (iY_Pixel < Y_END);

    logic [H_WIDTH-1:0] wRom_X;
    logic [V_WIDTH-1:0] wRom_Y;

    assign wRom_X = iX_Pixel - X_START;
    assign wRom_Y = iY_Pixel - Y_START;

    assign oAddr = wImg_En ? (wRom_Y * IMG_H) + wRom_X : 0;
    assign {oR_Port, oG_Port, oB_Port} = wImg_En ? {iImg_Data[15:12], iImg_Data[10:7], iImg_Data[4:1]} : 12'h000;

endmodule
