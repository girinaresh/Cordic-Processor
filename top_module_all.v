`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:38:03 07/26/2013 
// Design Name: 
// Module Name:    top_module_all 
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
module top_module_all(clk,
							reset,
							ps2d,
							ps2c,
							v_sync,
							h_sync,
							RGB,
							rotary_a,
							rotary_b, 
							rotary_press,
							top_cordic
							);
//-------------------------------------------------------------------------------------------------
input clk, reset;
input ps2d,ps2c;
input rotary_a, rotary_b, rotary_press;
output v_sync, h_sync;
output [2:0] RGB;
output [7:0]top_cordic;

reg [8:0] input_angle;
reg ip_frm_kbd = 1'b0;
reg ip_frm_rot = 1'b0;

wire [8:0] input_angle_wire;
assign input_angle_wire = input_angle;
//---------------------------------variable for keyboard ------------------------------------------
reg [1:0] sel;
reg enable_kbd;
reg out_enter;

wire [1:0] sel_wire;
wire enable_kbd_wire;
wire out_enter_wire;
wire [7:0] IP_Command,Nex_Command;
wire [8:0] IP_Angle;
wire [23:0] kbd_data_disp;

assign sel_wire = sel;
assign enable_kbd_wire = enable_kbd;
//---------------------------------variable for rotor----------------------------------------------
reg enable_rot;
reg out_pressed;

wire enable_rot_wire;
wire out_pressed_wire;
wire [8:0] op_rotor;
wire [23:0] counted_disp;

assign enable_rot_wire = enable_rot;
//-----------------------------variable for vga-----------------------------------------------------
reg [5:0] print_line = 6'b0;
reg welcome_print;
reg [23:0] data_for_disp;

wire [5:0] print_line_wire;
wire welcome_print_wire;
wire [47:0] q_val_wire, i_val_wire;
wire [23:0] data_for_disp_wire;

assign print_line_wire = print_line;
assign welcome_print_wire = welcome_print;
assign data_for_disp_wire = data_for_disp;
//-------------------------------variable for cordic-----------------------------------------------

//---------------always block for assigning outputs from keyboard, rotor----------------------------
always@(posedge clk)
begin	
	out_enter = out_enter_wire;
	out_pressed = out_pressed_wire;
end
//------------------parameter for fsm of main module ------------------------------------------------
parameter [3:0]	print_welcome		= 4'b0000,
						delay_loop			= 4'b0001,
						ask_ip_dev			= 4'b0010,
						wait_for_ip			= 4'b0011,
						dev_kbd				= 4'b0100,
						dev_rot				= 4'b0101,
						ip_receive			= 4'b0110,
						delay_result		= 4'b0111,
						op_print				= 4'b1000,
						display_exit		= 4'b1001;
reg [3:0] current_state, next_state = print_welcome;
integer counter = 0;
//------------------------always block for state transition----------------------------------------
always@(posedge clk)
begin
	if(reset == 1'b1)
		current_state = print_welcome;
	else
		current_state = next_state;
end
//-------------------------------always block for fsm----------------------------------------------
always @(posedge clk)
begin	
	if(reset == 1'b1)
		begin	
			print_line = 6'b0;
			ip_frm_kbd = 1'b0;
			ip_frm_rot = 1'b0;
			input_angle = 9'b0;
		end
	else
		begin
			case(current_state)
				print_welcome: begin
										welcome_print = 1'b1;
										next_state    = delay_loop;
									end
				delay_loop	:	begin
										if(counter == 100000000)
											begin
												counter = 1'b0;
												welcome_print = 1'b0;
												next_state = ask_ip_dev;
											end
										else
											begin
												counter = counter +1;
												next_state = delay_loop;
											end
									end
			ask_ip_dev:			begin
										enable_kbd = 1'b1;
										sel = 2'b01;					//selcet for input command
										print_line[0] = 1'b1;			// enable line asking to enter input
										next_state = wait_for_ip;
									end
			wait_for_ip:		begin
										data_for_disp = {16'b0,IP_Command};
										if(IP_Command == 8'h4B)
											begin	
												sel = 2'b10;
												next_state = dev_kbd;
											end
										else if(IP_Command == 8'h52)
											begin
												enable_kbd= 1'b0;			//disbale keyboard
												enable_rot = 1'b1;
												next_state = dev_rot;
											end
//										else if(IP_Command != 8'h00)
//											begin
//												print_line[3] = 1'b1;	//enable line of error
//												next_state = wait_for_ip;
//											end
										else
											begin
												next_state = wait_for_ip;
											end
									end
			dev_kbd	:			begin
										print_line[2] = 1'b1;	//enable line asking enter value from keyboard
										data_for_disp = kbd_data_disp;	// ascii value loaded to vga from keyboard
										
										if(out_enter == 1'b1)
											begin
												ip_frm_kbd = 1'b1;
												enable_kbd = 1'b0;
												next_state = ip_receive;
											end
										else
												next_state = dev_kbd;
									end
			dev_rot:				begin
										print_line[3]	= 1'b1;	//enable line asking enter value from rotor
										data_for_disp = counted_disp;	// ascii value loaded to vga from rotor
										if(out_pressed == 1'b1)
											begin
												ip_frm_rot = 1'b1;
												enable_rot = 1'b0;
												next_state = ip_receive;
											end
										else
												next_state = dev_rot;
									end
			ip_receive:			begin
										if(counter == 50)
											begin
												counter = 0;
												if(ip_frm_kbd == 1'b1 && ip_frm_rot == 1'b0)
													begin
														ip_frm_kbd = 1'b0;
														input_angle = IP_Angle;
													end
												else if(ip_frm_kbd == 1'b0 && ip_frm_rot == 1'b1)
													begin
														ip_frm_rot = 1'b0;
														input_angle = op_rotor;
													end
												else;
												
												next_state = delay_result;
											end
										else
											begin
												counter = counter +1;
												next_state = ip_receive;
											end
									end
			delay_result:		begin
										if(counter == 50)
											begin
												counter = 0;
												next_state = op_print;
											end
										else
											begin
												counter = counter + 1;
												next_state = delay_result;
											end
									end
			op_print:			begin
										print_line[4] = 1'b1;			// print result line
										next_state    = display_exit;
										sel = 2'b00;
										enable_kbd = 1'b1;
									end
			display_exit:		begin
										print_line[5] = 1'b1;	// print thank you line 
										if(Nex_Command == 8'h43)
											begin
												print_line[5:0] = 6'b0;
												//send reset to rotor, keyboard, vaga;
												next_state = ask_ip_dev;
											end
										else if(Nex_Command == 8'h45)
											begin
												print_line[5:0] = 6'b0;
												//send reset to rotor,keyboard, vga
												next_state = display_exit;
											end
										else
												next_state = display_exit;
									end
			default:				next_state = print_welcome;
		endcase
	end
end
												


//----------------------------instantiation of sub-blocks------------------------------------------
//----------------------------keyboard-------------------------------------------------------------
top_keyboard KEYBOARD(.clk(clk),
							.reset(reset),
							.sel(sel_wire),
							.ps2d(ps2d),
							.ps2c(ps2c),
							.rx_en(enable_kbd_wire),
							.IP_Command(IP_Command),
							.IP_Angle(IP_Angle),
							.Nex_Command(Nex_Command),
							.dout_enter(out_enter_wire),
							.data_temp_disp(kbd_data_disp)
						);
//--------------------------rotor-------------------------------------------------------------------
rotary_encoder	ROTOR(.clk(clk),
							.reset(reset),
							.rotory_dev_on(enable_rot_wire),
							.rotary_a(rotary_a), 
							.rotary_b(rotary_b), 
							.rotary_press(rotary_press), 
							.counted_value(op_rotor), 
							.counted_disp(counted_disp),
							.press(out_pressed_wire)
							);
//---------------------------------------VGA-------------------------------------------------------
top_vga	VGA( 			.clk(clk),
							.reset(reset),
							.v_sync(v_sync), 
							.h_sync(h_sync), 
							.RGB(RGB),
							.welcome_trig(welcome_print_wire),
							.print_line(print_line_wire),
							.data_temp_disp(data_for_disp_wire),
							.q_val_op(q_val_wire),
							.i_val_op(i_val_wire)
							);
//---------------------------------------CORDIC HANDLER  -------------------------------------------
Cordic_Handler CORDIC(.clk(clk),
							.angle_ip(input_angle_wire),
							.Xout(i_val_wire),
							.Yout(q_val_wire)
							);
assign top_cordic = i_val_wire[47:40];
//-------------------------------------------------------------------------------------------------
endmodule
//------------------------------------------end of top module--------------------------------------