module vga #(parameter HDISP = 800, parameter VDISP = 480)
	//Longeur et largeur de l'image affichée
	(
	input wire pixel_clk,
	input wire pixel_rst,
	video_if.master video_ifm );

//Déclaration de signaux internes
wire [$clog2(VSIZE)-1:0] lignes;  //Compteur de lignes
wire [$clog2(HSIZE)-1:0] pixels; //Compteur de pixels


//Déclaration des paramètres locaux
localparam HFP = 40; // Horizontal Front Porch
localparam HPULSE = 48; //Largeur de la syncro ligne
localparam HBP = 40; //Horizontal Back Porch
localparam VFP = 12; //Vertical Front Porch
localparam VPULSE = 3; //Largeur de la sync image
localparam VBP = 40; //Vertical Back Porch
localparam VSIZE = VDISP+VBP+VPULSE+VFP //Taille verticale de l'écran
localparam HSIZE = HDISP+HBP+HPULSE+HFP //Taille horizontale de l'écran
localparam VDIS = VFP+VPULSE+VBP; //Zone d'affichage vertical
localparam HDIS = HFP+HPULSE+HBP; //Zone d'affichage horizontal

//Clock video
assign video_ifm.CLK = pixel_clk;

//Compteur de lignes et de colonnes
always_ff @(posedge pixel_clk or posedge pixel_rst)
begin
	if(pixel_rst) begin
		lignes <= 0;
		colonnes <= 0;
	end
	else begin
		pixels <= (pixels == VSIZE-1)? 0 : pixels+1 ;
		lignes <= (pixels == VSIZE-1)? lignes+1 : lignes;

	end
end

//Calcul des signaux de synchronisation
//Syncronisation horizontale et transmission
always_ff @(posedge pixel_clk or posedge pixel_rst)
begin
	video_ifm.BLANCK <= (pixels <= HDIS-1 | lignes <= VDIS-1)? 0 : 1;
	if(pixels < HFP-1 | HPULSE-1 <= pixels < HDISP-1)
		video_ifm.HS <= 1;
	else if( HFP-1 <= pixels < HPULSE-1)
		video_ifm.HS <= 0;	
end

//Syncronisation verticale
always_ff @(posedge pixel_clk or posedge pixel_rst)
begin
	if(lignes < VFP-1 | VPULSE-1 <= lignes < VDISP-1)
		video_ifm.VS <= 1;
	else if( VFP-1 <= lignes < VPULSE-1)
		video_ifm.VS <= 0;	
end


endmodule
