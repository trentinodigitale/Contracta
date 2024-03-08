function AddProdottiConvenzione( objGrid , Row , c  )
{
	var cod;
	var nq;
	var strCommand;
	var testo;

	//debugger;
	//-- recupero il codice della riga passata
	cod = GetIdRow( objGrid , Row , 'self' );
	//alert(cod);
	
  var IdConvenzione=getObjGrid( 'R' + Row + '_Id_Convenzione' ).value;
	//alert(IdConvenzione);
	
	//se si tratta di un princiapale recupero con AJAX i suoi RICHIESTI e li aggiungo al carrello
	var TipoProdotto;
  //TipoProdotto = getObjGrid( 'val_R' + Row + '_TipoProdotto').value;
  TipoProdotto =  GetProperty( getObjGrid( 'val_R' + Row + '_TipoProdotto') , 'value' );
  //alert(TipoProdotto);
  
	if (TipoProdotto=='principale'){
    
    ajax = GetXMLHttpRequest(); 
    
    if(ajax){
  		
      var strParam;		 
  		strParam = 'OPERATION=ADDROW&IDHEADER=' + IdConvenzione + '&IDROWPRINCIPALE=' + cod ;
  		
      ajax.open("GET", '../customDoc/OperationPrincipaleCarrello.asp?'+ strParam , false);
  	 
      ajax.send(null);
      //alert(ajax.readyState);
      if(ajax.readyState == 4) {
        //alert(ajax.status);
  	    if(ajax.status == 200)
  	    {
  	      result =  ajax.responseText;
  	      if (result != '')
  		      cod = cod + '~~~' + result ;
  		    
  	    }
      }
    }
  }
	
	//se si tratta di un accessorio lo aggiungo se almeno uno dei suoi principale è già presente
	if (TipoProdotto=='accessorio'){
    
    //alert(cod);
    
    ajax = GetXMLHttpRequest(); 
    
    if(ajax){
  		
      var strParam;		 
  		strParam = 'OPERATION=GETPRINCIPALI&IDHEADER=' + IdConvenzione + '&IDROW=' + cod ;
  		
      ajax.open("GET", '../customDoc/OperationPrincipaleCarrello.asp?'+ strParam , false);
  	 
      ajax.send(null);
      //alert(ajax.readyState);
      if(ajax.readyState == 4) {
        //alert(ajax.status);
  	    if(ajax.status == 200)
  	    {
  	      result =  ajax.responseText;
  		    //alert(result);
  		    
  		    //controllo che almeno 1 dei principali è nel carrello sotto
  		    if ( result != '' ){
            
            result= '~~~' + result + '~~~' ;
            
            var numRowCarrello= GetProperty( parent.opener.getObj('PRODOTTIGrid'),'NumRow');
            //alert(numRowCarrello);
            var bfound=0;
            if ( numRowCarrello != -1 ){
            
              for( j = 0; j <= numRowCarrello ; j++ ){
    		        
                idrowcarrello = '~~~' + parent.opener.getObjGrid( 'R' + j + '_Id_Product' ).value + '~~~';
                //alert('result=' + result + '--idrowcarrello=' + idrowcarrello);
    		        if (result.indexOf(idrowcarrello, 0) >= 0 ) {
                  bfound=1;
                  break;
                }
    		            
    		    
    		      } 
  		      }else{
  		          DMessageBox( '../CTL_Library/' , 'accessori senza i principali' , 'Attenzione' , 2 , 400 , 300 );
  		          return;
  		      }
  		      //se nessun principale è presente nel carrello non inserisco accessorio
  		      if ( bfound == 0 ){
  		          DMessageBox( '../CTL_Library/' , 'accessori senza i principali' , 'Attenzione' , 2 , 400 , 300 );
  		          return;
  		      }     
  		      
          }
  		    
  		    
  		    
  	    }
      }
    }
    
  }
	
	
	//testo = getObjGrid('R' + Row + '_FNZ_ADD').innerHTML;
	//alert( getObj('R' + Row + '_FNZ_ADD')[0].innerText );
	//alert( testo );

	//testo = testo.replace( 'carrello.GIF' , 'carrellook.GIF');
	//alert( testo );
	
	//testo = '<table  class="FLbl_Tab" ><tr><td ><img border="0" src="../CTL_Library/images/Domain/../toolbar/carrellook.GIF" ></td><td nowrap class="FLbl_label"  id="R0_FNZ_ADD_label" ></td></tr></table>';
	getObjGrid('R' + Row + '_FNZ_ADD').style.border = "solid 1px black"
  
	//-- controllo che l'articolo selezionato è appartanente alla stessa convenzione di quelli presenti nel carrello
	/*
  try
	{
        
	    if( parent.parent.Carrello.getObj( 'R0_Id_Convenzione' ).value != getObj( 'R' + Row + '_Id_Convenzione' )[0].value )
	    {
            DMessageBox( '../CTL_Library/' , 'Non e\' possibile inserire nel carrello articoli di convenzioni diverse.Svuotare prima il carrello' , 'Attenzione' , 2 , 400 , 300 );
	        return ;
	    }
	    
	}catch ( e ) {};
	*/
	
	var strDoc;
	strDoc = getObj('DOCUMENT').value;
	v = strDoc.split('.');
	
	//-- compone il comando per aggiungere la riga
	strCommand = v[0] + '#' + v[1] + '#' + 'IDROW=' + cod + '&TABLEFROMADD=' + v[2];
	
	//alert( strCommand );
	
	
	
	//-- invoca sulla pagina chiamante l'aggiunta della riga
	parent.opener.ExecDocCommand( strCommand );

	try{ 
		var sec = parent.opener.getObj( 'SECTION_DETTAGLI_NAME' ).value;
		parent.opener.ShowLoading( sec ); 
	}catch( e ){};

}


