
function VisualizzaAzienda( grid , r , c )
{
	//-- recupero il codice della riga passata
	
	var nIdAzienda;
	try{
		nIdAzienda = getObj( 'R' + r + '_IdAzi' )[0].value;
	}catch( e ) {
		nIdAzienda = getObj( 'R' + r + '_IdAzi' ).value;
	}
	//alert( nIdAzienda );
	
	ExecFunctionCenter( '../../customdoc/VisualizzaAzienda.asp?IdPfu=&strFlag=OK&idAzi=' + nIdAzienda + '&IDMP=&intTab=0&strNomeCampo=-1&Provenienza=1#Run_Dati_AziendaLinked#780,500' );
}


function OpenSpese()
{
	//-- controllo che siano stati imputati i valori
	if( Number( getObj( 'Importo' ).value ) == 0 )
	{
		DMessageBox( '../' , 'E\' necessario inserire un valore per il campo Importo versato' , 'Attenzione' , 2 , 400 , 300 );
		getObj( 'Importo_V' ).focus();
		return;
	}
	if( Number( getObj( 'Corrispettivo' ).value ) == 0 && JSTrim( getObj( 'NaturaAtto' ).value.toLowerCase()) == 'atto pubblico' )
	{
		DMessageBox( '../' , 'E\' necessario inserire un valore per il campo Corrispettivo' , 'Attenzione' , 2 , 400 , 300 );
		getObj( 'Corrispettivo_V' ).focus();
		return;
	}
	
	//ShowDoc( 'SPESE_CONTRATTO.800.600' , 1 );
	var IDDOC = getObj( 'IDDOC' ).value;

	ExecFunctionCenter( '../../customdoc/OpenSpeseContratto.asp?IDDOC='+ IDDOC + '#Run_Dati_AziendaLinked#800,900' );

}


function OpenPreventivo()
{

	ShowDoc( 'SPESE_CONTRATTO.800.600' , 2 );

}



function ShowDoc( strDoc , cod )
{
	var nq;

	
	var w;
	var h;
	var Left;
	var Top;
    
	v = strDoc.split( '.' );
	if ( v.length > 1 )
	{
		strDoc = v[0];
		w = Number( v[1] );
		h = screen.availHeight * 0.9 ; //Number( v[2] );
		Left= (screen.availWidth - w) / 2;
		Top= (screen.availHeight - h ) / 2;	
	}
	var NewWin;
	
	NewWin = ExecFunction(  'document.asp?JScript=' + strDoc + '&DOCUMENT=' + strDoc + '&MODE=OPEN&IDDOC=' + cod  , strDoc + '_DOC_' + cod , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  );
	
	NewWin.focus();
	return NewWin;
}


function CheckSave(param)
{
    var stato = getObj('StatoRepertorio').value;
    
    if ( stato == 'PreArchiviato')
    {
        if( confirm(CNV( '../','Per il documento e\' stata richiesta l\'archiviazione, si vuole comunque procedere?')) )
        {
            ExecDocProcess(param);
        }
    }
    else
    {
            ExecDocProcess(param);
    }
}
