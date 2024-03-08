function MY_R_OpenDocument( objGrid , Row , c )
{
	var cod;
	
	//-- recupero il codice del documento se esiste
	{
		cod = getObj( 'R' + Row + '_GridViewer_ID_DOC').value;
	} 
	if ( cod > 0 )
	{
		ShowDocument( 'RUOLI_PROFILI' , cod );
	}
	else	
	{
		DMessageBox( '../ctl_library/' , 'Non esiste un documento nel sistema per il ruolo selezionato' , 'Attenzione' , 2 , 400 , 300 );
		return;				  
	}

}