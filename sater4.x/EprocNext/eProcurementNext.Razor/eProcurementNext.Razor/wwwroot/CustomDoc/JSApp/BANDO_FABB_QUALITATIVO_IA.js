function ApriRisposta()
{
	//-- verifica se è già presente un documento per la risposta altrimenti lo create
	if ( getObjValue( 'Id_Doc_New' ) == '' )
		ExecDocProcess( 'CREA_RISPOSTA,BANDO_FABB_QUALITATIVO_IA,,NO_MSG');
	else
		afterProcess( 'CREA_RISPOSTA' )
	
}

function afterProcess( param )
{

	if ( param == 'CREA_RISPOSTA' )
	{
		
		ShowDocument( getObjValue( 'TipoBando')  , getObjValue( 'Id_Doc_New' ) )
		
	}
	
}