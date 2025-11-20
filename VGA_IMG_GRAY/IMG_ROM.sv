`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company          : Semicon_Academi
// Engineer         : Jiyun_Han
// 
// Create Date	    : 2025/11/20
// Design Name      : VGA_IMG_ROM
// Module Name      : VGA_IMG_ROM
// Target Devices   : Basys3
// Tool Versions    : 2020.2
// Description      : VGA_IMG_ROM
//
// Revision 	    : 
//////////////////////////////////////////////////////////////////////////////////

module IMG_ROM #(
    parameter  H_Visible_Area = 640,
    parameter  V_Visible_Area = 480,
    localparam Q_Visibla_Area = ((H_Visible_Area / 2) * (V_Visible_Area / 2)),
    localparam WIDTH          = $clog2(Q_Visibla_Area)
) (
    input  logic [WIDTH-1:0] iAddr,
    output logic [     15:0] oData
);

    logic [15:0] rMem[0:Q_Visibla_Area-1];

    initial begin
        $readmemh("Eevee.mem", rMem);
    end

    assign oData = rMem[iAddr];
endmodule
