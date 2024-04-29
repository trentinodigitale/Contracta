
 $( document ).ready(function() {
    InitComunicazione();
	
	SetPositionRecursive( getObj( 'Cell_Body' ) , 'relative' );
	
});



function OpenCollegati( )
{
  
	var Fascicolo = '';
	try	{ 	Fascicolo = getObjValue( 'Fascicolo')	}catch( e ) {};

	
	var URL = '';
	
	
	if( getObj( 'VersioneLinkedDoc' ).value.indexOf( 'BANDO_CONSULTAZIONE_GENERICA' ) >= 0 )
	{
		URL = '../dashboard/mainView.asp?A=A&FOLDER_GROUP=LINKED_CONSULTAZIONE_BANDO&FilterHide= Fascicolo = \'' + Fascicolo + '\' ';
		
	}
	else
	{
		URL = '../dashboard/mainView.asp?A=A&FOLDER_GROUP=LINKED_ISCRIZIONE_ALBO&FilterHide= Fascicolo = \'' + Fascicolo + '\' ';
	}
	
	
	
	parent.parent.parent.DocumentiCollegati( URL );

}


function InitComunicazione()
{
	//PER LE COMUNICAZIONI DI RISPOSTA SUI FABBISOGNI CAMBIO CAPTION AL FORNITORE METTENDO ENTE
	if( getObj( 'VersioneLinkedDoc' ).value.indexOf( 'FABBISOGNI_COMUNICAZIONE_GENERICA' ) >= 0 )
	{
		try
		{
			getObj('cap_Azienda').innerHTML = CNV(pathRoot, 'ente destinatario');
		}catch(e){}	
	}

}