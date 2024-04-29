
function PRODOTTI_MakeTotal()
{
/*

    var RDA_Total = Number( getObj( 'RDA_Total' ).value ) ;
    var IVA = Number( getObj( 'val_IVA' ).value );
    

    var ValoreIva = ( RDA_Total * IVA ) / 100;
    var TotalIva = ValoreIva + RDA_Total;
    
    SetNumericValue( 'ValoreIva' , ValoreIva );
    SetNumericValue( 'TotalIva' , TotalIva );
*/
}


function LocDetailMakeTotal( Section , obj )
{
    /*
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
            SetNumericValue(  r + '_RDP_Qt' , qtMin );
            alert( CNV ('../../' , 'Qt inferiore alla Qt min' ) );
            
        }
    }

    var TipoOrdine = 'B';
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
    */
}

function ChangeDir( obj )
{
    getObj( 'ODC_PEG' ).value = getObj( 'StrutturaAziendale' ).value;
}

function ChangePeg( obj )
{
    getObj( 'StrutturaAziendale' ).value = getObj( 'ODC_PEG' ).value;
}



function PRODOTTI_OnLoad()
{
    
    ShowCol_TipoOrdine();

    
    //PRODOTTI_MakeTotal();
    
    if ( getObj( 'val_StatoDoc' ).value == '' )
    {
        try{
            opener.ExecDocProcess( 'DELETE,CARRELLO,,NO_MSG');
        }catch(e){};
    }    


    if(  getObj( 'val_StatoDoc' ).value ==  'Saved' || getObj( 'val_StatoDoc' ).value == ''  )
    {
        var over = '';
        var TipoOrdine = 'B';
        try{ TipoOrdine = getObjValue( 'TipoOrdine' );   } catch ( e ) {TipoOrdine = 'S';};
        try{ over  = getObj( 'MSG_OVER_MSG' ).innerHTML }catch(e){over = '';}
        if( over == '' && TipoOrdine == 'B' )
        {
   		    DMessageBox( '../' , 'Si ricorda di tener conto per l\'impegno di spesa dell\'importo di Euro 1.81 relativo all\'imposta di bollo' , 'Attenzione' , 1 , 400 , 300 );
        }
    }

    
}


function ShowCol_TipoOrdine()
{

        var TipoOrdine = 'B';
        try{ TipoOrdine = getObjValue( 'TipoOrdine' );   } catch ( e ) {TipoOrdine = 'S';};



        if( TipoOrdine == 'S' )
        {

            //ShowCol( 'PRODOTTI' , 'RDP_CodArtProd' , '' );
            ShowCol( 'PRODOTTI' , 'QtMin' , '' );
            //ShowCol( 'PRODOTTI' , 'RDP_Qt' , '' );

            ShowCol( 'PRODOTTI' , 'CostoComplessivo' , 'none' );
            ShowCol( 'PRODOTTI' , 'CoefCorr' , 'none' );
            ShowCol( 'PRODOTTI' , 'PercSconto' , 'none' );
            ShowCol( 'PRODOTTI' , 'DataUtilizzo' , 'none' );
            ShowCol( 'PRODOTTI' , 'ImportoCompenso' , 'none' );
        
        }
        
        if( TipoOrdine == 'P' )
        {
        
            //ShowCol( 'PRODOTTI' , 'RDP_CodArtProd' , 'none' );
            ShowCol( 'PRODOTTI' , 'QtMin' , 'none' );
            //ShowCol( 'PRODOTTI' , 'RDP_Qt' , 'none' );

            ShowCol( 'PRODOTTI' , 'CostoComplessivo' , 'none' );
            ShowCol( 'PRODOTTI' , 'CoefCorr' , 'none' );
            ShowCol( 'PRODOTTI' , 'PercSconto' , '' );
            ShowCol( 'PRODOTTI' , 'DataUtilizzo' , '' );
            ShowCol( 'PRODOTTI' , 'ImportoCompenso' , 'none' );
        
        }

        if( TipoOrdine == 'C' )
        {
        
            //ShowCol( 'PRODOTTI' , 'RDP_CodArtProd' , '' );
            ShowCol( 'PRODOTTI' , 'QtMin' , '' );
            //ShowCol( 'PRODOTTI' , 'RDP_Qt' , '' );

            ShowCol( 'PRODOTTI' , 'CostoComplessivo' , '' );
            ShowCol( 'PRODOTTI' , 'CoefCorr' , '' );
            ShowCol( 'PRODOTTI' , 'PercSconto' , 'none' );
            ShowCol( 'PRODOTTI' , 'DataUtilizzo' , 'none' );
            ShowCol( 'PRODOTTI' , 'ImportoCompenso' , 'none' );
        
        }

        if( TipoOrdine == 'B' )
        {
        
            //ShowCol( 'PRODOTTI' , 'CodArt' , 'none' );
            ShowCol( 'PRODOTTI' , 'QtMin' , 'none' );
            //ShowCol( 'PRODOTTI' , 'CARQuantitaDaOrdinare' , 'none' );

            ShowCol( 'PRODOTTI' , 'CostoComplessivo' , 'none' );
            ShowCol( 'PRODOTTI' , 'CoefCorr' , 'none' );
            ShowCol( 'PRODOTTI' , 'PercSconto' , '' );
            ShowCol( 'PRODOTTI' , 'DataUtilizzo' , '' );
            ShowCol( 'PRODOTTI' , 'ImportoCompenso' , '' );
        
        }
        
        

}


function PRODOTTI_AFTER_COMMAND( com )
{
    ShowCol_TipoOrdine( );
}


function FirmaDOC( param )
{
	var err = 0;
  var	cod = getObj( "IDDOC" ).value;

  if( cod.substr( 0 , 3 ) == 'new' )
  {
		  alert( CNV( '../', 'Per proseguire e\' necessario effettuare prima un salvataggio. Verra\' eseguito automaticamente alla chiusura del messaggio' ));
      SaveDoc();
      return;  
  }
    //CheckFirmaEBlocco( param );	
	
	//var strURL= '../../report/richiesta_di_acquisto_i.asp?PDF_FileName_SIGN=' + escape( getObj('RDA_Name').value ) + '&TABLE_SIGN=Document_RDA&IDENTITY_SIGN=RDA_id&' +  param + '&';
	param = param + 'PDF_FileName_SIGN=' + escape( getObj('Titolo').value ) + '&';
	PrintCnv (param);
}


function MYDettagliDelCarrello( objGrid , Row , c  ) {
  
  var TipoProdotto;
  
  //TipoProdotto = getObjGrid( 'val_R' + Row + '_TipoProdotto').value;
  TipoProdotto = GetProperty( getObjGrid( 'val_R' + objGrid + '_' + Row + '_TipoProdotto') , 'value' ); 
  
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
	   ExecDocProcess ('DELETEPRINCIPALE,PREVENTIVO');
	   
  } 
}
  
