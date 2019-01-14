module vga #(parameter HDISP = 800, parameter VDISP = 480)
	//Longeur et largeur de l'image affichée
	(
	input wire pixel_clk,
	input wire pixel_rst,
	video_if.master video_ifm,
	wshb_if.master wshb_ifm );

//Déclaration de signaux internes
logic [$clog2(VSIZE)-1:0] lignes;  //Compteur de lignes
logic [$clog2(HSIZE)-1:0] pixels; //Compteur de pixels
logic [$clog2(VDISP)-1:0] pixel_Y; //Coordonnée verticale du pixel actif
logic [$clog2(HDISP)-1:0] pixel_X; //Coordonnée horizontale du pixel actif


//Déclaration des paramètres locaux
localparam HFP = 40; // Horizontal Front Porch
localparam HPULSE = 48; //Largeur de la syncro ligne
localparam HBP = 40; //Horizontal Back Porch
localparam VFP = 12; //Vertical Front Porch
localparam VPULSE = 3; //Largeur de la sync image
localparam VBP = 40; //Vertical Back Porch
localparam VSIZE = VDISP+VBP+VPULSE+VFP; //Taille verticale de l'écran
localparam HSIZE = HDISP+HBP+HPULSE+HFP; //Taille horizontale de l'écran
localparam VSUP = VFP+VPULSE+VBP; //Zone de suppression verticale
localparam HSUP = HFP+HPULSE+HBP; //Zone de suppression horizontale

//Clock video
assign video_ifm.CLK = pixel_clk;

//Signaux de l'interface wshb_if
/*
assign wshb_ifm.dat_ms = 32'hBABECAFE;
assign wshb_ifm.adr = '0;
assign wshb_ifm.cyc = 1'b1;
assign wshb_ifm.sel = 4'b1111;
assign wshb_ifm.stb = 1'b1;
assign wshb_ifm.we = 1'b1;
assign wshb_ifm.cti = '0;
assign wshb_ifm.bte = '0;
*/
//Compteur de lignes et de colonnes
always_ff @(posedge pixel_clk or posedge pixel_rst)
begin
	if(pixel_rst) begin
		lignes <= 0;
		pixels <= 0;
	end
	else begin
		pixels <= (pixels == HSIZE-1)? 0 : pixels+1 ;
		lignes <= (pixels == HSIZE-1)? lignes+1 : lignes;
		//Retour à 0 à la fin du balayage
		if(lignes == VSIZE)
			lignes <= 0;

	end
end

//Calcul des signaux de synchronisation
//Syncronisation horizontale
always_comb 
begin
	if(HFP-1 < pixels && pixels < HFP+HPULSE)
		video_ifm.HS = 0;
	else
		video_ifm.HS = 1;	
end

//Syncronisation verticale
always_comb
begin
	if(VFP-1 < lignes && lignes < VFP+VPULSE)
		video_ifm.VS = 0;
	else
		video_ifm.VS = 1;	
end

//Signal de transmission
always_comb 
begin
	if(pixels < HSUP || lignes < VSUP)
		video_ifm.BLANK = 0;
	else
		video_ifm.BLANK = 1;

end

//Génération de la mire de test et calcul des coordonnées du pixel actif
always_comb 
begin
	pixel_X = pixels - (HSUP); 
	pixel_Y = lignes - (VSUP); 
	video_ifm.RGB = (pixel_X%16 == 0 || pixel_Y%16 == 0)? {8'hff, 8'hff,8'hff}: {8'h0,8'h0,8'h0};
end

//Compteur pour coordonnées des pixels lus en mémoire
logic[$clog2(HDISP)-1:0] X;
logic[$clog2(VDISP)-1:0] Y;
//Lecture en SDRAM
assign wshb_ifm.cyc = 1'b1; //On sollicite l'esclave en permanence
assign wshb_ifm.we = 1'b0; //Ecriture
assign wshb_ifm.cti = 3'b10; //Transfert classique
assign wshb_ifm.bte = '0; 
assign wshb_ifm.sel = 4'b1111; //4 octets à ecrire
assign wshb_ifm.adr = 4*(HDISP*Y + X);
assign wshb_ifm.stb = 1'b1;

always_ff @(posedge wshb_ifm.clk or posedge wshb_ifm.rst)
begin
	logic [31:0] pixels;
	//Lecture en continue
	if(wshb_ifm.rst)
	begin
		Y <= 0;
		X <= 0;
	end
	else begin
		//On attend la validation de l'esclave
		if(wshb_ifm.ack)
		begin
			Y <= (X == HDISP)? Y+1 : Y;
			X <= (X == HDISP)? 0 : X+1;
			pixels <= wshb_ifm.dat_sm;
	
			//Pour reboucler
			if(Y == VDISP && X == HDISP)
			begin
				Y <= 0;
				X <= 0;
			end
		end
	end	
end

endmodule
