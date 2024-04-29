//--Versione=2&data=2012-06-27&Attvita=38848&Nominativo=Sabato
function Seleziona_Ente ( objGrid , Row , c )
 {
 
 
  var cod;
  var strcommand;
 
	//-- recupero il codice della riga passata (idazienda)
	cod = GetIdRow( objGrid , Row , 'self' );
	
	
	
	//parent.self.opener.getObj('Value_tec__Azi').value=cod;
	//parent.close();
	
	
	//-- recupero la plant della riga passata 
	var Plant = GetProperty( getObjGrid( 'val_R' + Row + '_Plant') , 'value' ); 
	
	//la aggiorno sul documento odc_fuoripiattaforma
	parent.self.opener.getObj( 'Plant' ).value = Plant;
	parent.self.opener.getObj( 'ODC_PEG' ).value = Plant;
		
  //invoco il salva
	parent.self.opener.ExecDocProcess ('SAVE,ODC_FUORIPIATTAFORMA');
	
	
    
 
 }
 
 
 function ChangeDir( obj )
{
    getObj( 'ODC_PEG' ).value = getObj( 'Plant' ).value;
}

function ChangePeg( obj )
{
    getObj( 'Plant' ).value = getObj( 'ODC_PEG' ).value;
}


function LocDetailMakeTotal( Section , obj )
{
    
    //-- controollo che la qt non sia inferiore all qtmin
    var r = obj.id.split( '_' )[0];
    var QtMinTot = 0;
    var result = '';
    
    try{
        QtMinTot = Number( getObj( 'QtMinTot' ).value );
    }catch( e ) {
        QtMinTot = 0;
    }



    var qt =  Number( getObj( r + '_RDP_Qt' ).value ).toFixed(6);
    
    
    if ( QtMinTot == 0 ) 
    {
        var qtMin = Number( getObj( r +  '_QtMin' ).value ).toFixed(6);

        if ( Number( qt ) < Number( qtMin ))
        {
            //SetNumericValue(  r + '_RDP_Qt' , qtMin );
            alert( CNV ('../../' , 'Qt inferiore alla Qt min' ) );
            
        }
    }

    var TipoOrdine = 'S';
    try{ TipoOrdine = getObjValue( 'val_TipoOrdine' );   } catch ( e ) {TipoOrdine = 'S';};

    //-- per gli ordini con coefficiente occorre recuperare il valore tramite aiax
    if ( TipoOrdine == 'C' )
    {

	    ajax = GetXMLHttpRequest(); 

	    if(ajax){
    				 
    		
		    ajax.open("GET", '../../customDoc/Coefficienti.asp?VAL=' + escape( qt ) + '&ID_DOC=' + getObj( 'Id_Convenzione' ).value , false);
			 
		    ajax.send(null);
		    if(ajax.readyState == 4) {
			    if(ajax.status == 200)
			    {
				    result =  ajax.responseText;
				    var v = result.split(',');
				    
				    if( v[0] == '0' )
				    {
					SetNumericValue( r + '_RDP_Qt' , 0);
				        alert( v[1] );
				    }
				    else
				    {
				        SetNumericValue( r + '_CoefCorr' , v[0] );
				        var costo = Number(  v[0] ) * qt * Number( getObj( r + '_RDP_Importo' ).value )
				        costo = costo.toFixed(3);
				        SetNumericValue( r + '_CostoComplessivo' , costo );
				    }
			    }
		    }
	    }
	    
	    if ( result == '' )
	    {

	        alert( CNV ('../../' , 'Errore nel recupero del coefficiente') );

	    }
    }
    
    
    DetailMakeTotal( Section , obj );
    
    //azzero valoreiva e totaleconiva in copertina se iva in copertina è vuoto ma stà sui dettagli
    var IVA = Number( GetProperty(getObj( 'val_IVA' ), 'value') );
    if ( IVA ==''){
      SetNumericValue( 'ValoreIva' , 0 );
      SetNumericValue( 'TotalIva' , 0 );
    }
}


function PRODOTTI_OnLoad()
{
 
    Hide_COL();
    MostraEvidenza( 'PRODOTTI' , 'Evidenzia');

}
function Hide_COL()
{
    ShowCol( 'PRODOTTI' , 'PercSconto' , 'none' );
	ShowCol( 'PRODOTTI' , 'CoefCorr' , 'none' );
	ShowCol( 'PRODOTTI' , 'CostoComplessivo' , 'none' );
	ShowCol( 'PRODOTTI' , 'ImportoCompenso' , 'none' );	


}
window.onload = PRODOTTI_OnLoad;

function MYDettagliDelCarrello( objGrid , Row , c  ) {

  var TipoProdotto;
  //TipoProdotto = getObjGrid( 'val_R' + Row + '_TipoProdotto').value;
  TipoProdotto = GetProperty( getObjGrid( 'val_R' + Row + '_TipoProdotto') , 'value' ); 
  
  //se è un accessorio cancello la riga
  if ( TipoProdotto == 'accessorio' )
    DettagliDel ( objGrid , Row , c  );
    
  //se è uno richiesto no posso cancellare
  if ( TipoProdotto == 'richiesto' ){
    DMessageBox( '../../CTL_Library/' , 'prodotto selezionato obbligatorio' , 'Attenzione' , 2 , 400 , 300 );
	  return ;
	}
	
	//se si tratta di un principale setto un flag a 1 per indicare ad un processo DELPRINCIPALE su quale riga stò lavorando
	if ( TipoProdotto == 'principale' ){
	   
	   getObjGrid( 'R' + Row + '_ToDelete').value = 1 ;
	   
	   //invoco un processo sul documento che si preoccupa di cancellare il principale 
	   //e i suoi collegati se possibile (nn ci deve essere un altro princiapale acui sono collegati)
	   ExecDocProcess ('DELETEPRINCIPALE,ODC');
	   
  }  
  
}
//-- invocata dalla griglia per copiare un riga di articolo
function MYDettagliCopy( grid , r , c )
{
	var sec = getObj( grid + '_SECTION_DETTAGLI_NAME' ).value;
	ExecDocCommand( sec + '#COPY_ROW#' + 'IDROW=' + r );
	ShowLoading( sec );
	
}

function PRODOTTI_AFTER_COMMAND( com )
{

  Hide_COL();

}
