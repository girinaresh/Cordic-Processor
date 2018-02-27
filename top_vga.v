`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:07:46 07/22/2013 
// Design Name: 
// Module Name:    top_vga 
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
module top_vga(		reset, 
							clk, 
							v_sync, 
							h_sync, 
							RGB,
							welcome_trig,
							print_line,
							data_temp_disp,
							q_val_op,
							i_val_op
							);
//-------------------------------------------------------------------------------------------------							
	input [5:0]print_line;
	input [23:0] data_temp_disp;
	input [48:0] q_val_op,i_val_op;
//	
	input clk, reset;
	input welcome_trig;
	//input [2:0] sw;
	output v_sync, h_sync;
	output [2:0] RGB;
	
	wire video_on, blank;
	wire [9:0] pixel_x, pixel_y;
	
	reg pixel_clk = 1'b0;
	wire [2:0] rgb_welcome;
	wire [2:0] rgb_process;
	reg [2:0] RGB_reg;
	
	assign video_on = ~blank;
	always @ (posedge clk)
	begin
		pixel_clk = ~pixel_clk;
	end
	
	always @ (posedge clk)
	begin
	if (pixel_clk)
		begin
			if(welcome_trig== 1'b1)
				RGB_reg = rgb_welcome;
			else if(welcome_trig == 1'b0)
				RGB_reg = rgb_process;
			else 
				RGB_reg = 2'b0;
			end
	end
		
assign RGB = RGB_reg;	

//------------module call----------------------------------------	
	sync_module SYNC(		.pixel_clock(pixel_clk),
								.reset(reset),
								.h_synch(h_sync),
								.v_synch(v_sync),
								.blank(blank),
								.pixel_count(pixel_x),
								.line_count(pixel_y)
								);
//-----------------------------------------------------------------	
	welcome_text WELCOME(
						.clk(clk),
						.pix_x(pixel_x), 
						.pix_y(pixel_y),
						.video_on(video_on),
						.text_rgb(rgb_welcome)
	);
//--------------------------------------------------------------------
	process_text PROCESS(
						.clk(clk),
						.pix_x(pixel_x), 
						.pix_y(pixel_y),
						.video_on(video_on),
						.text_rgb(rgb_process),
						.ip_device_on1(print_line[0]),
						.error_on1(print_line[1]),
						.value_enter_key_on1(print_line[2]),
						.value_enter_rot_on1(print_line[3]),
						.result_on1(print_line[4]),
						.keep_disp_msg1(print_line[5]),
						.data_temp_disp(data_temp_disp),
						.q_val_op(q_val_op),
						.i_val_op(i_val_op)
						);
//-----------------------------------------------------------------

endmodule
