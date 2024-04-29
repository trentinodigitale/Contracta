function PrintCnv( strUrlPage )
{
	var w;
	var h;
	
	//debugger;
	try {
		
		var IDDOC = getObj( 'IDDOC' ).value;
		var TYPEDOC = getObj( 'TYPEDOC' ).value;
		var suffix = getObj( 'SUFFIX_LANGUAGE' ).value;
		
		w = screen.availWidth;
		h = screen.availHeight;
		
		var url = strUrlPage;
		//url = url.replace( '.asp?' , '_' + suffix + '.asp?');
		
		//ExecFunction( url + 'IDDOC='+ IDDOC + '&TYPEDOC='+ TYPEDOC , 'PrintDocument' , ',menubar=yes,left=0,top=0,width=' + w + ',height=' + h );
		
		var newwin = window.open( '' , 'PrintDocument' ,'toolbar=no,location=no,directories=no,status=yes,resizable=yes,copyhistory=yes,scrollbars=yes,menubar=yes,left=0,top=0,width=' + w + ',height=' + h );
		newwin.focus();
		
		var objForm=getObj('FORMDOCUMENT');
	
		objForm.action= url + 'IDDOC='+ IDDOC + '&TYPEDOC='+ TYPEDOC;
		objForm.target='PrintDocument';

		objForm.submit();

	}
	catch( e ) {};


}
