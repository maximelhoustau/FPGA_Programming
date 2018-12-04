module MCE #(parameter WIDTH = 8) 
	(input [WIDTH-1:0] A,B,
	output [WIDTH-1:0] MAX, MIN);

	assign MAX = A < B ? B :
	       		     A ;

	assign MIN = A < B ? A :
			     B ;

endmodule
