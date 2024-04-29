function NewAzi( objGrid , Row , c  )
{
	//-- recupero il codice della riga passata
	cod = GetIdRow( objGrid , Row , 'self' );

	NewDocument( '../Ctl_Library/document/document.asp?JSCRIPT=' + cod + '&DOCUMENT=' + cod + '&MODE=NEW#New' + cod + '#1024,768' );
	
	top.close();
	
}

function UpdAzi( objGrid , Row , c  )
{
	//-- recupero il codice della riga passata
	documento = GetIdRow( objGrid , Row , 'self' );

	//NewDocument( '../Ctl_Library/document/document.asp?JSCRIPT=' + cod + '&DOCUMENT=' + cod + '&MODE=NEW#New' + cod + '#1024,768' );

	//-- id dell'azienda da modificare
	var idRow = getObj( 'DOCUMENT' ).value;
	var docfrom = 'AZIENDA';

	
	var nq;
	var altro = '';
	
	var w;
	var h;
	var Left;
	var Top;
    
	w = screen.availWidth * 0.9;
	h = screen.availHeight  * 0.9;
	Left= (screen.availWidth - w) / 2;
	Top= (screen.availHeight - h ) / 2;
 
	
	ExecFunction(  '../Ctl_Library/document/document.asp?JScript=' + documento + '&SHOWCAPTION=YES&DOCUMENT=' + documento + '&MODE=CREATEFROM&PARAM=' + docfrom + idRow , documento + '_DOC_createfrom' , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h + altro );
		
	top.close();
}


