`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:57:28 07/17/2013 
// Design Name: 
// Module Name:    sync_module 
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


//  640 X 480 @ 60Hz with a 25.175MHz pixel clock
`define H_ACTIVE			640	// pixels
`define H_FRONT_PORCH	16		// pixels
`define H_SYNCH			96		// pixels
`define H_BACK_PORCH		48		// pixels
`define H_TOTAL			800	// pixels

`define V_ACTIVE			480	// lines
`define V_FRONT_PORCH	11		// lines
`define V_SYNCH			2		// lines
`define V_BACK_PORCH		31		// lines
`define V_TOTAL			524	// lines

//`define CLK_MULTIPLY		2		// 50 * 2/4 = 25.000 MHz
//`define CLK_DIVIDE		4



module sync_module(		pixel_clock,
								reset,
								h_synch,
								v_synch,
								blank,
								pixel_count,
								line_count
								);

input 			pixel_clock;		// pixel clock 
input 			reset;				// reset
output 			h_synch;				// horizontal synch for VGA connector
output 			v_synch;				// vertical synch for VGA connector
output			blank;				// composite blanking 
output [9:0]	pixel_count;		// counts the pixels in a line
output [9:0]	line_count;			// counts the display lines

reg [9:0]		line_count;			// counts the display lines
reg [9:0]		pixel_count;		// counts the pixels in a line	
reg				h_synch;				// horizontal synch
reg				v_synch;				// vertical synch

reg				h_blank;				// horizontal blanking
reg				v_blank;				// vertical blanking
reg				blank;				// composite blanking


// CREATE THE HORIZONTAL LINE PIXEL COUNTER
always @ (posedge pixel_clock or posedge reset) begin
	if (reset)
		// on reset set pixel counter to 0
		pixel_count <= 10'h000;
	
	else if (pixel_count == (`H_TOTAL - 1))
		// last pixel in the line, so reset pixel counter
		pixel_count <= 10'h000;
	
	else
		pixel_count <= pixel_count +1;		
end

// CREATE THE HORIZONTAL SYNCH PULSE
always @ (posedge pixel_clock or posedge reset) begin
	if (reset)
		// on reset remove h_synch
		h_synch <= 1'b0;
	
	else if (pixel_count == (`H_ACTIVE + `H_FRONT_PORCH -1))
		// start of h_synch
		h_synch <= 1'b1;
	
	else if (pixel_count == (`H_TOTAL - `H_BACK_PORCH -1))
		// end of h_synch
		h_synch <= 1'b0;
end


// CREATE THE VERTICAL FRAME LINE COUNTER
always @ (posedge pixel_clock or posedge reset) begin
	if (reset)
		// on reset set line counter to 0
		line_count <= 10'h000;
	
	else if ((line_count == (`V_TOTAL - 1)) && (pixel_count == (`H_TOTAL - 1)))
		// last pixel in last line of frame, so reset line counter
		line_count <= 10'h000;
	
	else if ((pixel_count == (`H_TOTAL - 1)))
		// last pixel but not last line, so increment line counter
		line_count <= line_count + 1;
end

// CREATE THE VERTICAL SYNCH PULSE
always @ (posedge pixel_clock or posedge reset) begin
	if (reset)
		// on reset remove v_synch
		v_synch = 1'b0;

	else if ((line_count == (`V_ACTIVE + `V_FRONT_PORCH -1) &&
		   (pixel_count == `H_TOTAL - 1))) 
		// start of v_synch
		v_synch = 1'b1;
	
	else if ((line_count == (`V_TOTAL - `V_BACK_PORCH - 1))	&&
		   (pixel_count == (`H_TOTAL - 1)))
		// end of v_synch
		v_synch = 1'b0;
end


// CREATE THE HORIZONTAL BLANKING SIGNAL
// the "-2" is used instead of "-1" because of the extra register delay
// for the composite blanking signal 
always @ (posedge pixel_clock or posedge reset) begin
	if (reset)
		// on reset remove the h_blank
		h_blank <= 1'b0;

	else if (pixel_count == (`H_ACTIVE - 2)) 
		// start of HBI
		h_blank <= 1'b1;
	
	else if (pixel_count == (`H_TOTAL - 2))
		// end of HBI
		h_blank <= 1'b0;
end

// CREATE THE VERTICAL BLANKING SIGNAL
// the "-2" is used instead of "-1"  in the horizontal factor because of the extra
// register delay for the composite blanking signal
always @ (posedge pixel_clock or posedge reset) begin
	if (reset)
		// on reset remove v_blank
		v_blank <= 1'b0;

	else if ((line_count == (`V_ACTIVE - 1) &&
		   (pixel_count == `H_TOTAL - 2))) 
		// start of VBI
		v_blank <= 1'b1;
	
	else if ((line_count == (`V_TOTAL - 1)) &&
		   (pixel_count == (`H_TOTAL - 2)))
		// end of VBI
		v_blank <= 1'b0;
end

// CREATE THE COMPOSITE BLANKING SIGNAL
always @ (posedge pixel_clock or posedge reset) begin
	if (reset)
		// on reset remove blank
		blank <= 1'b0;

	// blank during HBI or VBI
	else if (h_blank || v_blank)
		blank <= 1'b1;
		
	else
		// active video do not blank
		blank <= 1'b0;
end

endmodule //