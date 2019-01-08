module vga #parameter(HDISP = 800, VDISP = 480)
	//Longeur et largeur de l'image affichée
	(
	input wire pixel_clk,
	input wire pixel_rst,
	video_if.master video_ifm );

//Déclaration de signaux internes
wire [$clog2(VDISP)-1:0] lignes;  //Compteur de lignes
wire [$clog2(HDISP)-1:0] pixels; //Compteur de pixels


//Déclaration des paramètres locaux
localparam HFP = 40; // Horizontal Front Porch
localparam HPULSE = 48; //Largeur de la syncro ligne
localparam HBP = 40; //Horizontal Back Porch
localparam VFP = 12; //Vertical Front Porch
localparam VPULSE = 3; //Largeur de la sync image
localparam VBP = 40; //Vertical Back Porch

//Compteur de lignes et de colonnes
always_ff @(posedge pixel_clk or posedge pixel_rst)
begin
	if(pixel_rst) begin
		lignes <= 0;
		colonnes <= 0;
		video_fm.HS <= 0;
		video_if.VS <= 0;
	end
	else begin
		colonnes <= (colonnes == VDISP-1)? 0 : colonnes+1 ;
		lignes <= (colonnes == VDISP-1)? lignes+1 : 0;
	end
end



endmodule
