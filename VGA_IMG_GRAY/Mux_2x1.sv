`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company          : Semicon_Academi
// Engineer         : Jiyun_Han
// 
// Create Date	    : 2025/11/20
// Design Name      : VGA_IMG_ROM
// Module Name      : Mux_DeMux
// Target Devices   : Basys3
// Tool Versions    : 2020.2
// Description      : Mux_2x1, Mux_4x1 DeMux_2x1
//////////////////////////////////////////////////////////////////////////////////

module Mux_2x1 #(
    parameter BIT_SIZE = 12
) (
    input  logic                iSel,
    input  logic [BIT_SIZE-1:0] iData0,
    input  logic [BIT_SIZE-1:0] iData1,
    output logic [BIT_SIZE-1:0] oData
);

    always_comb begin
        oData = 0;

        case (iSel)
            1'b0: oData = iData0;
            1'b1: oData = iData1;
        endcase
    end
endmodule

module Mux_4x1 #(
    parameter BIT_SIZE = 12
) (
    input  logic [         1:0] iSel,
    input  logic [BIT_SIZE-1:0] iData0,
    input  logic [BIT_SIZE-1:0] iData1,
    input  logic [BIT_SIZE-1:0] iData2,
    input  logic [BIT_SIZE-1:0] iData3,
    output logic [BIT_SIZE-1:0] oData
);

    always_comb begin
        oData = 0;

        case (iSel)
            2'd0: oData = iData0;
            2'd1: oData = iData1;
            2'd2: oData = iData2;
            2'd3: oData = iData3;
        endcase
    end
endmodule

module DeMux_2x1 #(
    parameter BIT_SIZE = 16
) (
    input  logic                iSel,
    input  logic [BIT_SIZE-1:0] iData,
    output logic [BIT_SIZE-1:0] oData0,
    output logic [BIT_SIZE-1:0] oData1
);

    always_comb begin
        oData0 = 0;
        oData1 = 0;

        case (iSel)
            1'b0: oData0 = iData;
            1'b1: oData1 = iData;
        endcase
    end
endmodule
