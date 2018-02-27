`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:17:26 07/07/2013 
// Design Name: 
// Module Name:    kordic 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module kordic (clock, phase_step, Xout, Yout);

parameter IN_WIDTH   = 16; // ADC bitwidth
parameter EXTRA_BITS = 6;  // spur reduction 6 dB per bit

localparam WI  = IN_WIDTH;
localparam WXY = IN_WIDTH + EXTRA_BITS; // 22-bit data regs
localparam STG = WXY;

input                   clock;
input  signed    [31:0] phase_step; // ratio of f0/fs.  Thus 0 to 2*PI will be represented as a 32 bit number from 0 to {32{1'b1}}
reg  signed  [WI-1:0] Xin = 16'd8;
reg  signed  [WI-1:0] Yin = 16'd0;
output signed [WXY-1:0] Xout;
output signed [WXY-1:0] Yout;


//------------------------------------------------------------------------------
//                             arctan table
//------------------------------------------------------------------------------

reg signed [31:0] atan_table [0:30];
always @(posedge clock)
begin
//                      32'b01000000000000000000000000000000; // upper 2 bits = 2'b01 = 90 degrees
		 atan_table[00] = 32'b00100000000000000000000000000000; // 45.000 degrees -> atan(2^0)
		 atan_table[01] = 32'b00010010111001000000010100011101; // 26.565 degrees -> atan(2^-1)
		 atan_table[02] = 32'b00001001111110110011100001011011; // 14.036 degrees -> atan(2^-2)
		 atan_table[03] = 32'b00000101000100010001000111010100; // 7.125
		 atan_table[04] = 32'b00000010100010110000110101000011; // 3.5763
		 atan_table[05] = 32'b00000001010001011101011111100001; // 1.7899
		 atan_table[06] = 32'b00000000101000101111011000011110; // 0.8952
		 atan_table[07] = 32'b00000000010100010111110001010101; // 0.4474
		 atan_table[08] = 32'b00000000001010001011111001010011; // 0.2238
		 atan_table[09] = 32'b00000000000101000101111100101110; // 0.1119
		 atan_table[10] = 32'b00000000000010100010111110011000; // 0.05595
		 atan_table[11] = 32'b00000000000001010001011111001100; // 0.02798
		 atan_table[12] = 32'b00000000000000101000101111100110; // 0.01399
		 atan_table[13] = 32'b00000000000000010100010111110011; // 6.99*10^-3
		 atan_table[14] = 32'b00000000000000001010001011111001; // 3.497056851*10^-3
		 atan_table[15] = 32'b00000000000000000101000101111101; // 1.7485*10^-3
		 atan_table[16] = 32'b00000000000000000010100010111110; // 8.743*10^-4
		 atan_table[17] = 32'b00000000000000000001010001011111; // 4.371*10^-4
		 atan_table[18] = 32'b00000000000000000000101000101111; // 2.185*10^-4
		 atan_table[19] = 32'b00000000000000000000010100011000; // 1.093*10^-4
		 atan_table[20] = 32'b00000000000000000000001010001100; // 5.46*10^-5
		 atan_table[21] = 32'b00000000000000000000000101000110; // 2.732*10^-5
		 atan_table[22] = 32'b00000000000000000000000010100011; // 1.366*10^-5
		 atan_table[23] = 32'b00000000000000000000000001010001; // 6.83*10^-6
		 atan_table[24] = 32'b00000000000000000000000000101000; // 3.41*10^-6
		 atan_table[25] = 32'b00000000000000000000000000010100; // 1.707547292503187176997657229762e-6
		 atan_table[26] = 32'b00000000000000000000000000001010; // 8.5377364625159377807466059221948e-7
		 atan_table[27] = 32'b00000000000000000000000000000101; // 4.2688682312579691273430929327706e-7
		 atan_table[28] = 32'b00000000000000000000000000000010; // 2.1344341156289845932927702128445e-7
		 atan_table[29] = 32'b00000000000000000000000000000001; // 1.0672170578144923003490380747296e-7
		 atan_table[30] = 32'b00000000000000000000000000000000; // 5.3360852890724615063735065840324e-8
end

//------------------------------------------------------------------------------
//                              registers
//------------------------------------------------------------------------------

//stage outputs
reg signed [WXY-1:0] X [0:STG-1];
reg signed [WXY-1:0] Y [0:STG-1];
reg signed    [31:0] Z [0:STG-1]; // 32bit
// NCO
reg           [31:0] phase_acc;


//------------------------------------------------------------------------------
//                               stage 0
//------------------------------------------------------------------------------
wire [1:0] quadrant = phase_acc[31:30];
wire  signed  [WI-1:0] NXin;
wire  signed  [WI-1:0] NYin;

assign NXin = -Xin;
assign NYin = -Yin;

always @(posedge clock)
begin // make sure the rotation angle is in the -pi/2 to pi/2 range.  If not then pre-rotate
	  phase_acc = phase_step;
	  case (quadrant)
	  2'b00,
	  2'b11: // no pre-rotation needed for these quadrants
	  begin
		 X[0] <= {Xin[WI-1], Xin} << (EXTRA_BITS-1); // since An = 1.647, divide input by 2 and then multiply by 2^EXTRA_BITS
		 Y[0] <= {Yin[WI-1], Yin} << (EXTRA_BITS-1);
		 Z[0] <= phase_acc;
	  end

	  2'b01:
	  begin
		 X[0] <= {NYin[WI-1], NYin} << (EXTRA_BITS-1);
		 Y[0] <= {Xin[WI-1],  Xin}  << (EXTRA_BITS-1);
		 Z[0] <= {2'b00,phase_acc[29:0]}; // subtract pi/2 from phase_acc for this quadrant
	  end

	  2'b10:
	  begin
		 X[0] <= {Yin[WI-1],  Yin}  << (EXTRA_BITS-1);
		 Y[0] <= {NXin[WI-1], NXin} << (EXTRA_BITS-1);
		 Z[0] <= {2'b11,phase_acc[29:0]}; // add pi/2 to phase_acc for this quadrant
	  end
	  endcase
end


//------------------------------------------------------------------------------
//                           stages 1 to STG-1
//------------------------------------------------------------------------------
genvar i;

generate
  for (i=0; i < (STG-1); i=i+1)
  begin: XYZ
    wire Z_sign;
    wire signed [WXY-1:0] X_shr, Y_shr; 

    assign X_shr = X[i] >>> i; // signed shift right
    assign Y_shr = Y[i] >>> i;

    //the sign of the current rotation angle
    assign Z_sign = Z[i][31]; // Z_sign = 1 if Z[i] < 0

    always @(posedge clock)
    begin
      // add/subtract shifted data
      X[i+1] <= Z_sign ? X[i] + Y_shr         : X[i] - Y_shr;
      Y[i+1] <= Z_sign ? Y[i] - X_shr         : Y[i] + X_shr;
      Z[i+1] <= Z_sign ? Z[i] + atan_table[i] : Z[i] - atan_table[i];
    end
  end
endgenerate


//------------------------------------------------------------------------------
//                                 output
//------------------------------------------------------------------------------
assign Xout = X[STG-1];
assign Yout = Y[STG-1];

endmodule
