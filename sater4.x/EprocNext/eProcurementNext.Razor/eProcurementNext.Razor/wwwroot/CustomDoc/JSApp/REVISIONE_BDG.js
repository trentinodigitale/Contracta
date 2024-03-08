function Economo_Sec_Dettagli_AddRow( objGrid , Row , c  )
{
	var cod;
	var nq;
	var strCommand;
	var testo;

	//-- recupero il codice della riga passata
	cod = GetIdRow( objGrid , Row , 'self' );
	
	
	var strDoc;
	strDoc = getObj('DOCUMENT').value;
	v = strDoc.split('.');

	/*if (getObjValue( 'val_R' + Row + '_BDD_Level') != 3) 
	{
	alert ('Non e\' possibile inserire nell\'area sottostante  righe con stato diverso da inviato.');
	return;
	}
	*/
	ExecFunction1(  '../CTL_Library/Document/document.asp?JScript=' + strDoc + '&DOCUMENT=' + strDoc + '&MODE=OPEN&IDDOC=' + cod  , 'AreaUpd' , ''  );
	

}