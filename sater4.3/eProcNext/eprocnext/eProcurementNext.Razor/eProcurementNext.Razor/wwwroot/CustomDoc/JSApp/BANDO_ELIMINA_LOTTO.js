function MyOpenCreateDettaglioVoci(){

  
  //alert('ok');
  
  var idRow='';
	var sel;
	
  //idRow = GetIdSelectedRow( 'PRODOTTI' , 'SelRow' , '' ) ;
	
	//idRow = Grid_GetIdSelectedRow( 'PRODOTTI' );	
	
	
  //R0_SelRow
	//PRODOTTIGrid_idRow_0
	
	for( i = 0 ; i <= PRODOTTIGrid_NumRow ; i++)
	{
		sel = getObj( 'R' +  i  + '_SelRow' ).checked;
		//alert(sel);
    if ( sel == true )
		{
		  if ( idRow == '')
		    
        idRow = getObj( 'PRODOTTIGrid_idRow_' + i ).value ;
		    
		  else{
        
        DMessageBox( '../ctl_library/' , 'E\' necessario selezionare una sola riga' , 'Attenzione' , 2 , 400 , 300 );
				return;		
        
      }
		  
		 	  
		}
	
	}
	
	if ( idRow == ''){
        DMessageBox( '../ctl_library/' , 'E\' necessario selezionare prima una riga' , 'Attenzione' , 2 , 400 , 300 );
				return;		
    
  }
	 
	
	//alert (idRow );
	
  //creo ildocumento di dettaglio delle voci
  //DASH_NewDocumentFrom('BANDO_ELIMINA_LOTTO_VOCI#BANDO_ELIMINA_LOTTO,'+ idRow +'#900,600###../ctl_library/document/document.asp?')
	
  MakeDocFrom( 'BANDO_ELIMINA_LOTTO_VOCI#900,800#BANDO_ELIMINA_LOTTO#' + idRow );
  

}




function OpenDettaglioVoci( objGrid , Row , c ){

  var idRow = getObj( 'PRODOTTIGrid_idRow_' + Row ).value ;
  
  //se lo statoriga parziale apro il doc di dettaglio
  //apro il documento di dettaglio voci
  
  var statoriga= getExtraAttrib( 'val_R' + Row + '_StatoRiga','value');
  
  if ( statoriga == 'Parziale')
    MakeDocFrom( 'BANDO_ELIMINA_LOTTO_VOCI#900,800#BANDO_ELIMINA_LOTTO#' + idRow );

}

window.onload = Init_Prodotti ;
function Init_Prodotti()
{
  var statoriga ;
  
  for( i = 0 ; i <= PRODOTTIGrid_NumRow ; i++)
	{
	   statoriga = getExtraAttrib( 'val_R' + i + '_StatoRiga','value');
	   //alert(statoriga);
	   //cambio stile 
     if ( statoriga != 'Parziale'){
       
       //setClassName ( 'PRODOTTIGrid_r' + i + '_c2' , 'Text' ) ;
       getObj('PRODOTTIGrid_r' + i + '_c2').className = 'Text' ;
       //alert ( getObj('R' + i + '_NumeroLotto_V').className);    
       //setClassName ( 'R' + i + '_NumeroLotto_V' , 'Text' ) ;
       getObj('R' + i + '_NumeroLotto_V').className = 'Text' ;
       
       getObj('PRODOTTIGrid_r' + i + '_c2').innerHTML = getObj('R' + i + '_NumeroLotto_V').innerHTML;
	   }
	   
	}
}