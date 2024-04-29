
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
    var im =  Number( getObj( r + '_RDP_Qt' ).value ).toFixed(6);
    
    SetNumericValue( r + '_Importo' , qt * im );

    
    if ( QtMinTot == 0 ) 
    {
        var qtMin = Number( getObj( r +  '_QtMin' ).value ).toFixed(6);

        if ( Number( qt ) < Number( qtMin ))
        {
            SetNumericValue(  r + '_RDP_Qt' , qtMin );
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
    */
}



function PRODOTTI_OnLoad()
{
    ShowCol_TipoOrdine();

    
    //PRODOTTI_MakeTotal();

/*    
    if ( getObj( 'val_RDA_Stato' ) .value == '' )
    {
        try{
            //opener.alert( 'delete carrello' );
            //opener.getObj('CARRELLO_TOOLBAR_DOCUMENT_del').innerHTML = 'ATTENZIONE';
            //opener.ExecDocProcess( 'DELETE,CARRELLO,,NO_MSG');"
            opener.ExecDocProcess( 'DELETE,CARRELLO,,NO_MSG');
        }catch(e){};
    }    
*/    
}


function ShowCol_TipoOrdine()
{

 
        var TipoOrdine = 'S';
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
        
            //ShowCol( 'PRODOTTI' , 'RDP_CodArtProd' , 'none' );
            ShowCol( 'PRODOTTI' , 'QtMin' , 'none' );
            //ShowCol( 'PRODOTTI' , 'RDP_Qt' , 'none' );

            ShowCol( 'PRODOTTI' , 'CostoComplessivo' , 'none' );
            ShowCol( 'PRODOTTI' , 'CoefCorr' , 'none' );
            ShowCol( 'PRODOTTI' , 'PercSconto' , '' );
            ShowCol( 'PRODOTTI' , 'DataUtilizzo' , '' );
            ShowCol( 'PRODOTTI' , 'ImportoCompenso' , '' );
            ShowCol( 'PRODOTTI' , 'FNZ_COPY' , 'none' );
        
        }
        

}


function PRODOTTI_AFTER_COMMAND( com )
{
    ShowCol_TipoOrdine( );
}

