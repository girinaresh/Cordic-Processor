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
module welcome_text
	(
	input wire clk,
	input wire [9:0] pix_x, pix_y,
	input wire video_on,
	output reg [2:0] text_rgb
	);
	
	wire [10:0] rom_addr;
	reg [7:0] char_addr, char_addr_w, char_addr_m, char_addr_nam;
	reg [2:0] row_addr;
	wire [2:0] row_addr_w, row_addr_m, row_addr_nam;
	
	reg [2:0] bit_addr;
	wire [2:0] bit_addr_w, bit_addr_m, bit_addr_nam;
	wire [7:0] font_word;
	wire font_bit, wel_on, min_on, nam_on;
	wire [6:0]rom_addr_nam;
	
			
	assign  rom_addr = {char_addr,row_addr};
	assign  font_bit = font_word[~bit_addr];
	
	//--------------instantiate font rom------------------------------------------------------------
	Font_ROM font_unit( .pixel_clock(clk),
								.address(rom_addr),
								.data(font_word)
								);
	//----------------------------------------------------------------------------------------------
	assign wel_on = (pix_y[9:6] == 1);
	assign row_addr_w = pix_y[5:3];
	assign bit_addr_w = pix_x[5:3];
	integer i =0;
	wire [0:8*10-1] welcome_text = " WELCOME ";
	always@(posedge clk)
	begin
		if(pix_y[9:6] == 1)
			begin
				if((pix_x[9:6] >=0)&& (pix_x[9:6]<=9))
				begin
						i=pix_x[9:6];
						char_addr_w = welcome_text[i*8+:8];
				end
				else  char_addr_w = 8'b0;
			end
	end
//-------------------------------------------------------------------------------------------------
	assign min_on = (pix_y[9:5] == 6) ;
	assign row_addr_m = pix_y[4:2];
	assign bit_addr_m = pix_x[4:2];
	integer j =0;
	wire [0:8*20-1] minor_text = "   MINOR  PROJECT   ";
	always@(posedge clk)
	begin
		if(pix_y[9:5] == 6)
			begin
				if((pix_x[9:5] >=0)&& (pix_x[9:5]<=19))
				begin
						j=pix_x[9:5];
						char_addr_m = minor_text[j*8+:8];
				end
				else 	char_addr_m = 8'b0;
			end
	end
	// prints 		MINOR  PROJECT
//-------------------------------------------------------------------------------------------------
	assign nam_on = ((pix_y[9:6] == 5) && (pix_x[9] == 0));
	assign row_addr_nam = pix_y[3:1];
	assign bit_addr_nam = pix_x[3:1];
//	assign rom_addr_nam = {pix_y[5:4],pix_x[8:4]};
	integer k =0;
	wire [0:8*32-1] aman_text   = "AMAN KANDOI       - 403";
	wire [0:8*32-1] bibek_text  = "BIBEK BHATTARAI   - 409";
	wire [0:8*32-1] bipin_text  = "BIPIN THAPA MAGAR - 413";
	wire [0:8*32-1] naresh_text = "NARESH KUMAR GIRI - 416";
	always@(posedge clk)
	begin
		if(pix_y[9:6] == 5)
			begin
				if(pix_x[9] == 0)
				begin
					k=pix_x[8:4];
					if(pix_y[5:4]==2'b00)
							char_addr_nam = aman_text[k*8+:8];
					else if(pix_y[5:4]== 2'b01)
							char_addr_nam = bibek_text[k*8+:8];
					else if(pix_y[5:4]==2'b10)
							char_addr_nam = bipin_text[k*8+:8];
					else if(pix_y[5:4] == 2'b11)
							char_addr_nam = naresh_text[k*8+:8];
					else
							char_addr_nam = 8'h0;
					
				end
			end
	end
			/* display as 
				Naresh Kumar Giri - 416
				Bipin Thapa Magar - 413
				Bibek Bhattarai   - 409
				Aman Kandoi 		- 403 */
//-------------------------------------------------------------------------------------------------
//------------------- always block to control the print--------------------------------------------
		always @(posedge clk)
			begin
			if(video_on)
				begin
				text_rgb	= 3'b111; //background 				
				if(wel_on)
					begin
						char_addr = char_addr_w;
						row_addr  = row_addr_w;
						bit_addr  = bit_addr_w;
						if(font_bit)
							text_rgb = 3'b100; //red
					end
				else if(min_on)
					begin
						char_addr = char_addr_m;
						row_addr  = row_addr_m;
						bit_addr  = bit_addr_m;
						if(font_bit)
							text_rgb = 3'b110; //
					end
				else if(nam_on)
					begin
						char_addr = char_addr_nam;
						row_addr  = row_addr_nam;
						bit_addr  = bit_addr_nam;
						if(font_bit)
							text_rgb = 3'b000; //
					end
				else;
				end
				
				else
					text_rgb = 3'b000;
		end
//-------------------------------------------------------------------------------------------------
endmodule 