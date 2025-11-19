`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company          : Semicon_Academi
// Engineer         : Jiyun_Han
// 
// Create Date	    : 2025/11/19
// Design Name      : VGA_RGW_SW
// Module Name      : VGA_RGW_SW
// Target Devices   : Basys3
// Tool Versions    : 2020.2
// Description      : VGA_RGW_SW
//
// Revision 	    : 2025/11/19    v1.0 VGA_RGW_SW Base (640*480)
//////////////////////////////////////////////////////////////////////////////////

module VGA_RGB_SW #(
    parameter H_MAX = 800,
    parameter V_MAX = 640,
    parameter H_WIDTH = $clog2(H_MAX),
    parameter V_WIDTH = $clog2(V_MAX),
    parameter X_SECTION = 8,
    parameter Y_SECTION = 2
) (
    // Clock & Reset
    input logic               iClk,
    input logic               iRst,
    input logic               iDE,
    input logic               iBtn_U,
    input logic               iBtn_L,
    input logic               iBtn_R,
    input logic               iBtn_D,
    input logic [H_WIDTH-1:0] iX_Pixel,
    input logic [V_WIDTH-1:0] iY_Pixel,
    // Input SW
    input logic [        3:0] iR_SW,
    input logic [        3:0] iG_SW,
    input logic [        3:0] iB_SW,

    // Output Port
    output logic [3:0] oR_Port,
    output logic [3:0] oG_Port,
    output logic [3:0] oB_Port
);

    parameter TOTAL_SECTION = (X_SECTION * Y_SECTION);
    parameter X_SECTION_PIXEL = 640 / X_SECTION;
    parameter Y_SECTION_PIXEL = 480 / Y_SECTION;
    parameter X_WIDTH = $clog2(X_SECTION);
    parameter Y_WIDTH = $clog2(Y_SECTION);
    parameter TOTAL_WIDTH = X_WIDTH + Y_WIDTH;

    // Divide Section
    logic [    X_WIDTH-1:0] wX_Section_Idx;
    logic [    Y_WIDTH-1:0] wY_Section_Idx;
    logic [TOTAL_WIDTH-1:0] wDraw_Idx;
    assign wX_Section_Idx = iX_Pixel / X_SECTION_PIXEL;
    assign wY_Section_Idx = iY_Pixel / Y_SECTION_PIXEL;
    assign wDraw_Idx = (wY_Section_Idx * X_SECTION) + wX_Section_Idx;
    // Color Memory
    logic [       11:0] rColor_Mem  [0:TOTAL_SECTION-1];
    // Current Edit Section
    logic [X_WIDTH-1:0] rEdit_X_Idx;
    logic               rEdit_Y_Idx;

    always_ff @(posedge iClk, posedge iRst) begin
        if (iRst) begin
            rEdit_X_Idx <= 0;
            rEdit_Y_Idx <= 0;

            for (int i = 0; i < TOTAL_SECTION; i++) rColor_Mem[i] <= 12'h000;
        end else begin
            // Color Save
            if (iBtn_U || iBtn_L || iBtn_R || iBtn_D) begin
                rColor_Mem[(rEdit_Y_Idx*X_SECTION)+rEdit_X_Idx] <= {
                    iR_SW, iG_SW, iB_SW
                };
            end

            // Move
            if (iBtn_U) begin
                rEdit_Y_Idx <= ~rEdit_Y_Idx;
            end else if (iBtn_L) begin
                if (rEdit_X_Idx == 0) begin
                    rEdit_X_Idx <= X_SECTION - 1;
                end else begin
                    rEdit_X_Idx <= rEdit_X_Idx - 1;
                end
            end else if (iBtn_R) begin
                if (rEdit_X_Idx == (X_SECTION - 1)) begin
                    rEdit_X_Idx <= 0;
                end else begin
                    rEdit_X_Idx <= rEdit_X_Idx + 1;
                end
            end else if (iBtn_D) begin
                rEdit_Y_Idx <= ~rEdit_Y_Idx;
            end
        end
    end

    logic [11:0] wFinal_Color;
    logic [TOTAL_WIDTH-1:0] wEdit_Idx;
    assign wEdit_Idx = (rEdit_Y_Idx * X_SECTION) + rEdit_X_Idx;

    always_comb begin
        if (!iDE) begin
            wFinal_Color = 12'h000;
        end else begin
            if (wDraw_Idx == wEdit_Idx) begin
                wFinal_Color = {iR_SW, iG_SW, iB_SW};
            end else begin
                wFinal_Color = rColor_Mem[wDraw_Idx];
            end
        end
    end

    assign oR_Port = wFinal_Color[11:8];
    assign oG_Port = wFinal_Color[7:4];
    assign oB_Port = wFinal_Color[3:0];
endmodule
