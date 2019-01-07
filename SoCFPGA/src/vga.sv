
module vga #parameter(HDISP = 800, VDISP = 480)
	//Longeur et largeur de l'image affichée
	(
	input wire pixel_clk,
	input wire pixel_rst,
	video_if.master video_ifm );

//Déclaration de signaux internes
wire [$clog2(VDISP)-1:0] cmp;  //Compteur de lignes
wire [$clog2(HDISP)-1:0] cmp2; //Compteur de colonnes


//Déclaration des paramètres locaux
localparam HFP = 40; // Horizontal Front Porch
localparam HPULSE = 48; //Largeur de la syncro ligne
localparam HBP = 40; //Horizontal Back Porch
localparam VFP = 12; //Vertical Front Porch
localparam VPULSE = 3; //Largeur de la sync image
localparam VBP = 40; //Vertical Back Porch

//Compteur de lignes
always_ff @(posedge pixel_clk or posedge pixel_rst)
begin
	if(pixel_rst)
		cmp <=0;
	else
		cmp <= (cmp == HDISP-1)? cmp+1 : 0;
end

//Compteur de colonnes
always_ff @(posedge pixel_clk or posedge pixel_rst)
begin
	if(pixel_rst)
		cmp2 <=0;
	else
		cmp2 <= (cmp2 == VDISP-1)? cmp2+1 : 0;
end





endmodule
