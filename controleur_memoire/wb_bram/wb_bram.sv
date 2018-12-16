//-----------------------------------------------------------------
// Wishbone BlockRAM
//-----------------------------------------------------------------
//
// Le paramètre mem_adr_width doit permettre de déterminer le nombre 
// de mots de la mémoire : (2048 pour mem_adr_width=11)

module wb_bram #(parameter mem_adr_width = 11) (
      // Wishbone interface
      wshb_if.slave wb_s
      );

      logic[3:0][7:0] mem [0: 1 << mem_adr_width];
      logic ack_r, ack_w;

      //Mise à zéro des signaux de répétition et d'erreur
      assign wb_s.rty = 0;
      assign wb_s.err = 0;
      
      //Processus de calcul du ACK
      //ACK en ecriture est combinatoire, l'esclave doit répondre le plus vite
      //possible
      assign ack_w = wb_s.stb & wb_s.we;      
      always_ff @(posedge wb_s.clk) begin
	      ack_r <= wb_s.stb & ~wb_s.we;

	      if (ack_r)
	      begin
		      if(tag==0 | tag == 3)
			      ack_r <= 0;
		      else 
			      ack_r <= ack_r;
      end
      //On assigne le signal ACK de l'interface en fonction du signal WE
      assign wb_s.ack = wb_s.we ? ack_w : ack_r; 

      //Gestion du tag du signal CTI: la variable tag retransmet le mode
      //incrémental ou non
      logic tag;
      always_comb
      begin
	      if(ack_r)
	      begin
		      case(wb_s.cti)
			      //Mode classique
			      3'b000: tag = 0;
			      //Mode burst avec adresse constante
			      3'b001: tag = 1;
			      //Mode burst avec incrémentation d'adresse
			      3'b010: tag = 2;
			      //Fin du burst
			      3'b111: tag = 3;
		      endcase
	      end
      end


      //Incrémenteur d'adresse de l'esclave
      logic [10:0] adr;
      always_ff @(posedge wb_s.clk)
      begin
	      adr = wb_s.adr[12:2];
	      if( ack_r & tag == 2)
	      begin
			while(  ~ (ack_w & tag == 3)) begin
				adr <= adr + 4;
			end
		end
		
	      else if( ack_r & (tag == 1 | tag == 0))
	      begin
		      while(  ~ (ack_w & tag == 3)) begin
				adr <= adr;
			end
		end
	end	

      //Procesus pour la mémoire synchrone
      always_ff @(posedge wb_s.clk)
      begin
	if (wb_s.we)
	begin
		if(wb_s.sel[0])
			mem[wb_s.adr[12:2]][0] <= wb_s.dat_ms[7:0] ;
		if(wb_s.sel[1])
			mem[wb_s.adr[12:2]][1] <= wb_s.dat_ms[15:8] ;
		if(wb_s.sel[2])
			mem[wb_s.adr[12:2]][2] <= wb_s.dat_ms[23:16] ;
		if(wb_s.sel[3])
			mem[wb_s.adr[12:2]][3] <= wb_s.dat_ms[31:24] ;
	end
	wb_s.dat_sm <= mem[adr];

	end 
endmodule
