function OpenControlliAlbo(){
	var IDDOC;
	IDDOC = getObj( 'IDDOC' ).value;
	
	var UpdParent = 'no';
	//--recupera il campo nascosto che indica se aggiornare oppure no il chiamante
	
	var w;
	var h;
	var Left;
	var Top;
    
	w=700;
	h=500;
	Left= (screen.availWidth - w) / 2;
	Top= (screen.availHeight - h ) / 2;
  
	strDoc='CONTROLLIALBO';	
	ExecFunction(  '../ctl_library/document/document.asp?UpdateParent=' + UpdParent + '&JScript=' + strDoc + '&DOCUMENT=' + strDoc + '&MODE=OPEN&IDDOC=' + IDDOC  , strDoc + '_DOC_' + IDDOC , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  );


}