`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company          : Semicon_Academi
// Engineer         : Jiyun_Han
// 
// Create Date	    : 2025/11/20
// Design Name      : VGA_IMG_ROM
// Module Name      : Gray_Scale
// Target Devices   : Basys3
// Tool Versions    : 2020.2
// Description      : Image Gray_Scale Out
//////////////////////////////////////////////////////////////////////////////////

module Gray_Scale (
    input  logic [11:0] iData,
    output logic [11:0] oData
);

    wire [11:0] wY_Calc = (iData[11:8] * 51) + (iData[7:4] * 179) + (iData[3:0] * 26);
    assign oData = {wY_Calc[11:8], wY_Calc[11:8], wY_Calc[11:8]};

endmodule
