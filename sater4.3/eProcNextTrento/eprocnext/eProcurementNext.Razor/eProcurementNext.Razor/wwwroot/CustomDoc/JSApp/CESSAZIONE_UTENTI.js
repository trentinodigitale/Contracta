function Verifica()
{

	 if (getObj('DataUltimoCollegamento').value == '') 
	 {
		   getObj('DataUltimoCollegamento').focus();
		   DMessageBox('../', 'E\' necessario selezionare la "Data Ultimo collegamento alla piattaforma"', 'Attenzione', 1, 400, 300);
           return;
	 }
	
	var value ='';

	if ( getObj('StatoFunzionale').value != 'InLavorazione')
    {
		value='NO';
	}	
	
	if ( value == '' )
	{ 
		ExecDocProcess( 'VERIFICA,CESSAZIONE_UTENTI' );
	}
	else
		return false; 

}

function RefreshContent()
{ 	
	RefreshDocument('');      
}


window.onload=controlli;

function controlli()
{
	var DOCUMENT_READONLY = getObj( 'DOCUMENT_READONLY' ).value;
	
	
	//se il doc è readonly nasconde il ricerca	
	if ( DOCUMENT_READONLY == '1' )
    {
		document.getElementById('bottone_ricerca').style.visibility = 'hidden';
	
	}	
	
}


function ChangedField( obj )
{
	var DOCUMENT_READONLY = getObj( 'DOCUMENT_READONLY' ).value;	
	
	//se il doc non è readonly 
	if ( DOCUMENT_READONLY == '0' )
    {		
		//-- cancella il risultato precedente se c'era almeno una riga
		var numeroRighe0 = GetProperty( getObj('ESITIGrid') , 'numrow');
		
		if ( numeroRighe0 > 0 )
		{
			ExecDocProcess( 'DELETE_ALL,CESSAZIONE_UTENTI' );
		}
	}

}

function afterProcess( param )
{
    if ( param == 'DELETE_ALL' )
    {
		DMessageBox( '../' , 'Gli esiti della verifica sono stati svuotati in seguito ad un cambiamento dei "Parametri". Rieseguire la "Verifica"' , 'Attenzione' , 1 , 400 , 300 );
		return;
    }
	
}


function MY_ESPORTA(param)
{
	
	
	var HIDECOL='' 
	
	
	HIDECOL=HIDECOL + 'MailObj';
	
	
	ExecDownloadSelf(param + '&HIDECOL=' + HIDECOL)
}
