
function OpenFatturaInfo( objGrid , Row , c )
{
	var cod;
	var nq;

	//-- recupero il codice della riga passata
	cod = GetIdRow( objGrid , Row , 'self' );
	
	var w;
	var h;
	var Left;
	var Top;
    
	w = 500; 
	h = 400; 
	Left= (screen.availWidth - w) / 2;
	Top= (screen.availHeight - h) / 2;;
  
	var strDoc;
	strDoc = 'FATTURA_INFO'; //getObj('DOCUMENT').value;


	
	ExecFunction(  '../CTL_Library/Document/document.asp?DOCUMENT=' + strDoc + '&MODE=OPEN&IDDOC=' + cod  , 'FATTURA_INFO_' + cod , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  ).focus();


}

