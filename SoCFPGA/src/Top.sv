`default_nettype none

module Top #(parameter HDISP = 800, parameter VDISP = 480) 
	(
    // Les signaux externes de la partie FPGA
	input  wire         FPGA_CLK1_50,
	input  wire  [1:0]	KEY,
	output logic [7:0]	LED,
	input  wire  [3:0]	SW,
    // Les signaux du support matériel son regroupés dans une interface
    hws_if.master       hws_ifm,
    video_if.master 	video_ifm
);

//Instanciation du module vga
vga #(HDSIP, VDSIP) vga1 (.pixel_clk(pixel_clk), .pixel_rst(pixel_rst), .video_ifm(video_ifm));

//====================================
//  Déclarations des signaux internes
//====================================
  wire        sys_rst;   // Le signal de reset du système
  wire        sys_clk;   // L'horloge système a 100Mhz
  wire        pixel_clk; // L'horloge de la video 32 Mhz
  logic	      pixel_rst; // Le signal de reset du bloc video

//Variable pour clignotement des LEDS en fonction de l'usage
`ifdef SIMULATION
	//On la fait clignoter 100 fois plus vite pour la simulation
	localparam hcmpt = 100;
	localparam hcmpt2 = 32;
`else
	//Clignotement réel
	localparam hcmpt = 100_000_000;
	localparam hcmpt2 = 32_000_000;
`endif
//Pour une horloge de 1Hz
logic [$clog2(hcmpt)-1:0] cmp; //clk a 100MHz
logic [$clog2(hcmpt2)-1:0] cmp2;//clk a 23MHz
 
//=======================================================
//  La PLL pour la génération des horloges
//=======================================================

sys_pll  sys_pll_inst(
		   .refclk(FPGA_CLK1_50),   // refclk.clk
		   .rst(1'b0),              // pas de reset
		   .outclk_0(pixel_clk),    // horloge pixels a 32 Mhz
		   .outclk_1(sys_clk)       // horloge systeme a 100MHz
);

//=============================
//  Les bus Wishbone internes
//=============================
wshb_if #( .DATA_BYTES(4)) wshb_if_sdram  (sys_clk, sys_rst);
wshb_if #( .DATA_BYTES(4)) wshb_if_stream (sys_clk, sys_rst);

//=============================
//  Le support matériel
//=============================
hw_support hw_support_inst (
    .wshb_ifs (wshb_if_sdram),
    .wshb_ifm (wshb_if_stream),
    .hws_ifm  (hws_ifm),
    .sys_rst  (sys_rst), // output
    .SW_0     ( SW[0] ),
    .KEY      ( KEY )
 );

//=============================
// On neutralise l'interface
// du flux video pour l'instant
// A SUPPRIMER PLUS TARD
//=============================
assign wshb_if_stream.ack = 1'b1;
assign wshb_if_stream.dat_sm = '0 ;
assign wshb_if_stream.err =  1'b0 ;
assign wshb_if_stream.rty =  1'b0 ;

//=============================
// On neutralise l'interface SDRAM
// 
// pour l'instant
// A SUPPRIMER PLUS TARD
//=============================
assign wshb_if_sdram.stb  = 1'b0;
assign wshb_if_sdram.cyc  = 1'b0;
assign wshb_if_sdram.we   = 1'b0;
assign wshb_if_sdram.adr  = '0  ;
assign wshb_if_sdram.dat_ms = '0 ;
assign wshb_if_sdram.sel = '0 ;
assign wshb_if_sdram.cti = '0 ;
assign wshb_if_sdram.bte = '0 ;

//--------------------------
//------- Code Eleves ------
//--------------------------

assign LED[0] = KEY[0];

//Clignotement de la LED[1] sur sys_clk
always_ff @(posedge sys_clk or posedge sys_rst)
begin
	if (sys_rst)
		cmp <= 0;
	else begin
		cmp <= (cmp == hcmpt-1)? 0 : cmp+1;
		LED[1] <= (cmp == hcmpt-1)? ~LED[1]: LED[1];
	end
end

//Clignotement de la LED[2] sur pixel_clk
always_ff @(posedge pixel_clk or posedge pixel_rst)
begin
	if (pixel_rst)
		cmp2 <= 0;
	else begin
		cmp2 <= (cmp2 == hcmpt2-1)? 0 : cmp2+1;
		LED[2] <= (cmp2 == hcmpt2-1)? ~LED[2]: LED[2];
	end
end

//Génération de pixel_rst
always @(posedge pixel_clk)
begin  
	logic 	      Q1; //Signal pour stabilité de pixel_rst (entre 2 bascules)	
	if(sys_rst)
	begin
		Q1 <= sys_rst;
		pixel_rst <= sys_rst;
	end
	else begin
		Q1 <= 0;
		pixel_rst <= Q1;
	end	
end

endmodule
