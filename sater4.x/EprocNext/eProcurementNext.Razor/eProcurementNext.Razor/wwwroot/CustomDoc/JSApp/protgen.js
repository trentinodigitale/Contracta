function MyOpenDocumentColumn(objGrid , Row , c)
{
	var cod;
	var strDoc = '';
	
	try	{ 	cod = getObjValue( 'R' + Row + '_Appl_Id_Evento');	}catch( e ) {};
	
	if ( cod == '' || cod == undefined )
	{
		try	{ 	cod = getObj( 'R' + Row + '_Appl_Id_Evento')[0].value; }catch( e ) {};
	}

	try	{ 	strDoc = getObj( 'R' + Row + '_OPEN_DOC_NAME').value;	}catch( e ) {};
	
	if ( strDoc == '' || strDoc == undefined )
	{
		try	{ 	strDoc = getObj( 'R' + Row + '_OPEN_DOC_NAME')[0].value; }catch( e ) {};
	}
	
	if ( strDoc == '' || strDoc == undefined ) 
	{
		alert( 'Errore tecnico - ' +  'R' + Row + '_OPEN_DOC_NAME - non trovato' );
		return;
	}
	
	ShowDocument( strDoc , cod );
}