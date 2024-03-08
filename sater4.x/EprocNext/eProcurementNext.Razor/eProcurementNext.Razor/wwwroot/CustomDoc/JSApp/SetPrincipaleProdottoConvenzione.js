
//effettua l'associazione prodotto-principale e restituisce html per la cella "Articoli Principali Collegati"
function SetPrincipaleProdottoConvenzione ( objGrid , Row , c ) {
  
    //-- recupero il codice della riga passata
	
  var idRow;
  idRow = GetIdRow( objGrid , Row , 'self' );
	
	var IdConvenzione;
	IdConvenzione = getObjGrid( 'R' + Row + '_idHeader').value;
	
	
	var IdRowPrincipale;
	IdRowPrincipale = getObjGrid( 'R' + Row + '_idRowPrincipale').value;
	
	var CheckPrincipale;
	CheckPrincipale = getObjGrid( 'R' + Row + '_CheckPrincipale');
	
  var SelPrincipale;
  SelPrincipale=0;
  if ( CheckPrincipale.checked ) {
    SelPrincipale=1;
  }
	
	
	//ricavop la riga della griglia della convenzione
	var i;
	//alert(self.parent.opener.GetPositionRow);
  //i = self.parent.opener.GetPositionRow( 'PRODOTTIGrid' , idRow , '' );
  //alert(i);
  
  //determino la riga interessata in base a iddoc
	numRow = eval('self.parent.opener.PRODOTTIGrid_NumRow') ;
	//alert(numRow);
  for( i = 0; i <= numRow ; i++ ){
	  try {
	      if ( self.parent.opener.getObj( 'R' + i + '_idRow').value ==  idRow )
		break;
		  }
		   catch( e ) {}
	}
	//alert(i);
  
	var objNameArticoliCollegati;
	objNameArticoliCollegati = 'R' + i + '_ArticoliCollegati';
	
	
	//alert('Riga=' + idRow + '--Convenzione=' + IdConvenzione + '--Principale=' + IdRowPrincipale);
	
	//chiamata AJAX per fare associazione e recupero HTML per la cella "Articoli Principali Collegati"
	ajax = GetXMLHttpRequest(); 
  
  if(ajax){
		
    var strParam;		 
		strParam = 'IDROW=' + idRow + '&IDHEADER=' + IdConvenzione + '&IDROWPRINCIPALE=' + IdRowPrincipale + '&SELPRINCIPALE=' + SelPrincipale ;
		
    ajax.open("GET", '../customDoc/SetPrincipaleProdottoConvenzione.asp?'+ strParam , false);
	 
    ajax.send(null);
    //alert(ajax.readyState);
    if(ajax.readyState == 4) {
      //alert(ajax.status);
	    if(ajax.status == 200)
	    {
		    result =  ajax.responseText;
		    
		    //aggiorno il campo "Articoli Principali Collegati" della griglia prodotti della convenzione
		    //self.parent.opener.SetTextValue( objNameArticoliCollegati , result ) ;
		    self.parent.opener.SetTAValue( objNameArticoliCollegati , result ) ;
		    
		    
	    }
    }
  }
  

}