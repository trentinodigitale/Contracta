function OpenCreatePDA( objGrid , Row , c ){

  //-- recupero il codice della riga passata
	cod = GetIdRow( objGrid , Row , 'self' );
 
	var strDoc = '';
	
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
	
	var TYPEDOC = '';
	
	try	{ 	TYPEDOC = getObj( 'R' + Row + '_MAKE_DOC_NAME').value;	}catch( e ) {};
	
	if ( TYPEDOC == '' || TYPEDOC == undefined )
	{
		try	{ 	TYPEDOC = getObj( 'R' + Row + '_MAKE_DOC_NAME')[0].value; }catch( e ) {};
	}
	
	if ( TYPEDOC == '' || TYPEDOC == undefined ) 
	{
		alert( 'Errore tecnico - ' +  'R' + Row + '_MAKE_DOC_NAME - non trovato' );
		return;
	}
	
		
	//alert( cod + '--' + strDoc + '--' + TYPEDOC );
	var w;
	var h;
	var Left;
	var Top;
  var altro = '';
    
	w = screen.availWidth * 0.5;
	h = screen.availHeight  * 0.5;
	Left= (screen.availWidth - w) / 2;
	Top= (screen.availHeight - h ) / 2;
 
  var strUrl = '../CustomDoc/VerificaBloccoCommissione.asp?OPERATION=VISUAL&COD=' + cod + '&STRDOC=' + strDoc + '&TYPEDOC=' + escape(TYPEDOC)  ;
	
	ExecFunction( strUrl , 'VerificaBloccoCommissione' , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h + altro );
		

}