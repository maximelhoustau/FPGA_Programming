//Module extracteur de la valeur médiane de D pixels de W bits chacun
module MED #(parameter W = 8, parameter D = 9 ) (input [W-1:0] DI, input DSI, input BYP, input CLK, output [W-1:0] DO);

//Définition des noeuds présents quelque soit le nombre de données
wire [W-1:0] O_mux1, MIN, MAX, O_mux2; 
//Tableau de D-1 bus de taille W-1 bits chacun pour la suite de registre post MCE
wire [W-1:0] R_OI [D-1:0];

assign R_OI[0] = O_mux1;

MUX #(.W(8)) mux1 (.I0(MIN), .I1(DI), .DSI(DSI), .O(O_mux1));

//Génération de la suite de D-1 registres
genvar i;
generate
	for(i=0; i<D-1; i++)
	begin:position
		REG #(.W(W)) R (.clk(CLK), .D(R_OI[i]),  .Q(R_OI[i+1]));
	end
endgenerate

MCE #(.W(8)) mce (.A(DO), .B(R_OI[D-1]), .MAX(MAX), .MIN(MIN));

MUX #(.W(8)) mux2 (.I0(MAX), .I1(R_OI[D-1]), .DSI(BYP), .O(O_mux2));

//Dernier registre de sortie
REG #(.W(8)) R8 (.clk(CLK), .D(O_mux2), .Q(DO));

endmodule

//Multiplexeur 2 mots de W bits vers un mot de W bits
module MUX #(parameter W = 8) (input [W-1:0] I0, input [W-1:0] I1, input DSI, output logic [W-1:0] O);
always_comb
	if(DSI)
		O = I1;
	else
		O = I0;
endmodule


//Registre W bits
module REG #(parameter W = 8)( input clk, input [W-1:0] D, output logic [W-1:0] Q );
always_ff @(posedge clk) 	
	Q <= D; 	
endmodule
