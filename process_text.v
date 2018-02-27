`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:46:50 07/16/2013 
// Design Name: 
// Module Name:    welcome_text 
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
module process_text(		clk,
								pix_x,
								pix_y,
								video_on,
								text_rgb,
								ip_device_on1,
								error_on1,
								value_enter_key_on1,
								value_enter_rot_on1,
								result_on1,
								keep_disp_msg1,
								data_temp_disp,
								q_val_op,
								i_val_op
								);
	
	input wire clk;
	input wire [9:0] pix_x, pix_y;
	input wire video_on;
	output reg [2:0] text_rgb;
	input ip_device_on1,error_on1,value_enter_key_on1,value_enter_rot_on1,result_on1,keep_disp_msg1;
	input [23:0] data_temp_disp;
	input [48:0] q_val_op,i_val_op;
	
	
	reg [7:0] d_ipdevice = 8'h00;
	reg [23:0] d_ip =24'h000000;
	reg [48:0] q_val =48'h0000_0000_0000, i_val =48'h0000_0000_0000;
	
	wire [10:0] rom_addr;
	reg [7:0] char_addr, char_addr_ent,char_addr_error,char_addr_valuer,char_addr_valuek,char_addr_result,char_addr_thank;
	
	reg [2:0] row_addr;
	wire [2:0] row_addr_text;
	
	reg [2:0] bit_addr;
	wire [2:0] bit_addr_text;
	wire [7:0] font_word;
	wire font_bit;
	
	assign  rom_addr = {char_addr,row_addr};
	assign  font_bit = font_word[~bit_addr];
	
	assign row_addr_text = pix_y[3:1];
	assign bit_addr_text = pix_x[3:1];
//-----------------always block for assiginng values from ip devices-------------------------------
	always@(posedge clk)
		begin
			if(ip_device_on1 == 1'b1 && value_enter_key_on1 == 1'b0 && value_enter_rot_on1 == 1'b0 )
				d_ipdevice[7:0] = data_temp_disp[7:0];
			
			else if((value_enter_key_on1 == 1'b1 || value_enter_rot_on1 == 1'b1) && result_on1 == 1'b0)
				d_ip = data_temp_disp;
			
			else if(result_on1 == 1'b1 )
				begin
					q_val = q_val_op;
					i_val = i_val_op;
				end
			else;
		end
//----------------------------instantiate font rom-------------------------------------------------
	Font_ROM font_unit( .pixel_clock(clk),
								.address(rom_addr),
								.data(font_word)
								);
//-----------------------wires as control bits to on/off lines-------------------------------------
	assign ip_device_on			=(pix_y[9:4]>=3 && pix_y[9:4]<=4 && ip_device_on1);
	assign error_on 				=(pix_y[9:4]==6 && error_on1);
	assign value_enter_key_on	=(pix_y[9:4]==9 && value_enter_key_on1);
	assign value_enter_rot_on	=(pix_y[9:4]==10 && value_enter_rot_on1);
	assign result_on				=(pix_y[9:4]>=16 && pix_y[9:4]<=18 && result_on1);
	assign keep_disp_msg			=(pix_y[9:4]>=25 && pix_y[9:4]<=27 && keep_disp_msg1);
//---------------------------defination of text for display----------------------------------------
	integer k =0;
	wire [1:8*25-1] enter_text        = "Choose the input device ";
	wire [1:8*25-1] device_text       = "K:Keyboard   R:Rotor  : ";
	wire [1:8*25-1] error_text       = "          !!! ERROR !!!  ";
	wire [1:8*25-1] valuer_text       = "Value from Rotor      : ";
	wire [1:8*25-1] valuek_text       = "Value from Keyboard   : ";
	wire [1:8*25-1] result_text       = "Result:                 ";
	wire [1:8*25-1] q_val_text        = "Q_value (sin(angle))  : ";
	wire [1:8*25-1] i_val_text        = "I_value (cos(angle))  : ";
	wire [1:8*25-1] th_text           = "THANK-YOU!!!            ";
	wire [1:8*25-1] press_enter_text  = "Enter C to Continue     ";
	wire [1:8*25-1] space_exit_text   = "Enter E to Exit         ";
//------------------------always block for text print----------------------------------------------
	always@(posedge clk)
	begin
		if(pix_x[9:4]>=1 && pix_x[9:4]<25)
		begin
			k=pix_x[9:4];
				if(pix_y[9:4]==6'd3)
						char_addr_ent     = enter_text[k*8+:8];
						
				else if(pix_y[9:4]==6'd4)
						char_addr_ent      = device_text[k*8+:8];
				
				else if(pix_y[9:4]==6'd6)
						char_addr_error    = error_text[k*8+:8];
						
				else if(pix_y[9:4]==6'd9)
						char_addr_valuek   = valuek_text[k*8+:8];
						
				else if(pix_y[9:4] ==6'd10)
						char_addr_valuer   = valuer_text[k*8+:8];
						
				else if(pix_y[9:4] ==6'd16)
						char_addr_result   = result_text[k*8+:8];
						
				else if(pix_y[9:4] ==6'd17)
						char_addr_result   = q_val_text[k*8+:8];
						
				else if(pix_y[9:4] ==6'd18)
						char_addr_result   = i_val_text[k*8+:8];
						
				else if(pix_y[9:4] ==6'd25)
						char_addr_thank    = th_text[k*8+:8];
						
				else if(pix_y[9:4] ==6'd26)
						char_addr_thank    = press_enter_text[k*8+:8];
						
				else if(pix_y[9:4] == 6'd27)
						char_addr_thank    = space_exit_text[k*8+:8];
						
				else;
			end	
//--------- for input values obtained from keyboard and rotor--------------------------------------
	if(pix_x[9:4]>25 && pix_x[9:4]<35)
		begin
			if(pix_y[9:4] == 4)
				begin
					case(pix_x[9:4])
							6'd26: char_addr_ent= d_ipdevice; // takes hex value entered by user as r or k
							default: char_addr_ent=8'h00;
					endcase
				end
			else if(pix_y[9:4] == 9)
				begin
					case(pix_x[9:4])
							6'd26: char_addr_valuek= d_ip[23:16];
							6'd27: char_addr_valuek= d_ip[15:8];
							6'd28: char_addr_valuek= d_ip[7:0];
							default: char_addr_valuek =8'h00;
					endcase
				end
			else if(pix_y[9:4] == 10)
				begin
					case(pix_x[9:4])
							6'd26: char_addr_valuer= d_ip[23:16];
							6'd27: char_addr_valuer= d_ip[15:8];
							6'd28: char_addr_valuer= d_ip[7:0];
							default: char_addr_valuer =8'h00;
					endcase
				end
			else if(pix_y[9:4] == 17)
				begin
					case(pix_x[9:4])
							6'd26: char_addr_result= q_val[47:40];
							6'd27: char_addr_result= q_val[39:32];
							6'd28: char_addr_result= q_val[31:24];
							6'd29: char_addr_result= q_val[23:16];
							6'd30: char_addr_result= q_val[15:8];
							6'd31: char_addr_result= q_val[7:0];
							default: char_addr_result =8'h00;
					endcase
				end
			else if(pix_y[9:4] == 18)
				begin
					case(pix_x[9:4])
							6'd26: char_addr_result= i_val[47:40];
							6'd27: char_addr_result= i_val[39:32];
							6'd28: char_addr_result= i_val[31:24];
							6'd29: char_addr_result= i_val[23:16];
							6'd30: char_addr_result= i_val[15:8];
							6'd31: char_addr_result= i_val[7:0];
							default: char_addr_result =8'h00;
					endcase
				end
		end
			else;
end
//--------------------------always block controlling display of this screen------------------------
always @(posedge clk)
			begin
			if(video_on)
				begin
				row_addr  = row_addr_text;
				bit_addr  = bit_addr_text;
				text_rgb	= 3'b111; //background 				
				
				if(ip_device_on)
					begin
						char_addr = char_addr_ent;
						if(font_bit)
							text_rgb = 3'b100; //blue
					end
				else if(error_on)
					begin
						char_addr = char_addr_error;
						if(font_bit)
							text_rgb = 3'b001; //red
					end
				else if(value_enter_key_on)
					begin
						char_addr = char_addr_valuek;
						if(font_bit)
							text_rgb = 3'b000; //
					end
				else if(value_enter_rot_on)
				begin
					char_addr = char_addr_valuer;
					if(font_bit)
						text_rgb = 3'b000; //
				end
				else if(result_on)
					begin
						char_addr = char_addr_result;
						if(font_bit)
							text_rgb = 3'b100; //
					end
				else if(keep_disp_msg)
					begin
						char_addr = char_addr_thank;
						if(font_bit)
							text_rgb = 3'b000; //
					end
				else
						char_addr = 8'b0;
				end
			else
					text_rgb = 3'b000;
		end
//-------------------------------------------------------------------------------------------------
endmodule 