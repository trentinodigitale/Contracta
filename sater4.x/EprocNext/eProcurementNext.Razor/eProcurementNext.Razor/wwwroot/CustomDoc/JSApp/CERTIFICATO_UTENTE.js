function checkCoerenzaCF( nMakeAlert )
{
	var nome = getObjValue('Nome').replace(/^\s+|\s+$/gm,'');
	var cognome = getObjValue('Cognome').replace(/^\s+|\s+$/gm,'');
	var cf = getObjValue('codicefiscale').replace(/^\s+|\s+$/gm,'');
	
	
	
	var resFunct = 1;
	
	/* Se sono avvalorati tutti i campi utili */
	if ( nome !== '' && cognome !== '' && cf !== '')
	{

		n_Made_Check_CF = '1';
		
		if ( !isMyCF('../../', nome , cognome, cf) )
		{
			resFunct = 0;
			
			if ( nMakeAlert != 0 )
				DMessageBox( '../' , 'Codice fiscale non coerente con nome e cognome' , 'Attenzione' , 1 , 400 , 300 );
			
			TxtErr( 'Nome' );
			TxtErr( 'Cognome' );
			TxtErr( 'codicefiscale' );
		}
		else
		{
			resFunct = 1;
			
			TxtOK( 'Nome' );
			TxtOK( 'Cognome' );
			TxtOK( 'codicefiscale' );
		}

	}
	
	return resFunct;
	
	
	//isMyCF
}

window.onload = OnloadPage;

function OnloadPage()
{
	//se documento editabile
	if ( getObj('DOCUMENT_READONLY').value != '1' )
	{
		
		try{ getObj('SIGN_ATTACH_V_BTN').setAttribute("onclick", "ExecFunctionCenterDoc('../functions/field/uploadattachsigned.asp?TABLE=CTL_DOC&NO_REFRESH_PARENT=YES&IDDOC=' + getObjValue('IDDOC') + '&OPERATION=INSERTSIGN&PATH=../../&SAVE_HASH=YES&IDENTITY=Id&AREA=&DOMAIN=FileExtention&FORMAT=#AllegaFirma#600,400');" );}catch( e ) {};

	}
}

	//////////////////////////////////////////////////////////////////////////////////
	
	
function SIGN_ATTACH_OnChange()
{
	
	//alert('Save F1');
	ExecDocProcess('POPOLA_CERTIFICATI,CERTIFICATO_UTENTE,,NO_MSG');
	
}


function MyOpenDocumentColumn(objGrid , Row , c)
{
	//alert 
	var cod;
	var nq;


	var cod = '';
	
	try	{ 	cod = getObj( 'R' + objGrid + '_' + Row + '_idHeader').value;	}catch( e ) {};
	
	if ( cod == '' || cod == undefined )
	{	
		try	{ 	cod = getObj( 'R' + Row + '_idHeader').value;	}catch( e ) {};
	}
	
	if ( cod == '' || cod == undefined )
	{
		try	{ 	cod = getObj( 'R' + Row + '_idHeader')[0].value; }catch( e ) {};
	}
	
	if ( cod == '' || cod == undefined ) 
	{
		DMessageBox( '../' , 'per il certificato di firma non è presente nessun documento' , 'Attenzione' , 1 , 400 , 300 );
		return;
	}
		//per il certificato di firma non è presente nessun documento
		
	var strDoc = '';
	
	try	{ 	strDoc = getObj( 'R' + objGrid + '_' + Row + '_OPEN_DOC_NAME').value;	}catch( e ) {};
	
	if ( strDoc == '' || strDoc == undefined )
	{	
		try	{ 	strDoc = getObj( 'R' + Row + '_OPEN_DOC_NAME').value;	}catch( e ) {};
	}
	
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



