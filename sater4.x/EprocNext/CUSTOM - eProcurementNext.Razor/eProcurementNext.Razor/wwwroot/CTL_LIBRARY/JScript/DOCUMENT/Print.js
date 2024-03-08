
function Print( strUrlPage )
{
	var w;
	var h;

	CheckFirmaEBlocco( strUrlPage );
	
	//debugger;
	try {
		
		var IDDOC = getObj( 'IDDOC' ).value;
		var TYPEDOC = getObj( 'TYPEDOC' ).value;
		var suffix = getObj( 'SUFFIX_LANGUAGE' ).value;
		
		w = screen.availWidth-50;
		h = screen.availHeight-50;
		
		var url = strUrlPage;
		url = url.replace( '.asp?' , '_' + suffix + '.asp?');
		
		//Se siamo nella versione accessibile sostituisco il layout con quello print
		if ( isSingleWin() )
		{
			url = ReplaceExtended( url, '%5F', '_');

			url = url.replace( 'lo=' + layout , 'lo=print');
			url = url.replace( 'LO=' + layout , 'lo=print');
		}
		
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

function PrintCnv( strUrlPage )
{
	var w;
	var h;

	CheckFirmaEBlocco( strUrlPage );
	
	//debugger;
	try {
		
		var IDDOC = getObj( 'IDDOC' ).value;
		var TYPEDOC = getObj( 'TYPEDOC' ).value;
		var suffix = getObj( 'SUFFIX_LANGUAGE' ).value;
		
		w = screen.availWidth-50;
		h = screen.availHeight-50;
		
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

function PrintPdf( strUrlPage )
{
	var w;
	var h;

	CheckFirmaEBlocco( strUrlPage );

	try 
	{

		var IDDOC = '0';

		if ( getObj( 'IDDOC' ) )
			IDDOC = getObj( 'IDDOC' ).value;

		var TYPEDOC = '';

		if ( getObj( 'TYPEDOC' ) )
			TYPEDOC = getObj( 'TYPEDOC' ).value;

		var suffix = 'I';

		if ( getObj( 'SUFFIX_LANGUAGE' ) )
			suffix = getObj( 'SUFFIX_LANGUAGE' ).value;

		w = screen.availWidth-100;
		h = screen.availHeight-100;

		var pathToRoot = '../../';

		if ( isSingleWin() )
			pathToRoot = pathRoot;

		var objForm;

		/* Se mi trovo su un documento */
		if ( getObj('FORMDOCUMENT') )
		{
			objForm=getObj('FORMDOCUMENT');
			
			var url = strUrlPage;
			var newwin = window.open( '' , 'PrintPdf' ,'toolbar=no,location=no,directories=no,status=yes,resizable=yes,copyhistory=yes,scrollbars=yes,menubar=yes,left=0,top=0,width=' + w + ',height=' + h );
			
			try{ 
				newwin.document.write( '<html><body><table class="Loading" width="100%" height="100%" ><tr><td width="100%" height="100%" align="center" valign="center" >Loading ...</td></tr></table></body></html>'); 
				newwin.focus(); 	
			}catch(e){
			
				//pop-up bloccati
				DMessageBox( pathToRoot , 'Errore creazione pop-up, verificare l\'esistenza di un pop-up aperto oppure disabilitare il blocco dei pop-up', 'Attenzione' , 1 , 400 , 300 );
				return;
				
			};

			

			objForm.action= pathToRoot + "ctl_library/pdf/pdf.asp?URL=" +  url + "&IDDOC=" + IDDOC + "&TYPEDOC="+ TYPEDOC;
			objForm.target='PrintPdf';

			objForm.submit();

		}
		else
		{
			/* Se sono su un viewer */
			ExecFunction( pathToRoot + 'ctl_library/pdf/pdf.asp?URL=' +  strUrlPage + '&IDDOC=' + IDDOC + '&TYPEDOC=' + TYPEDOC , 'PrintDocument' , ',menubar=yes,left=0,top=0,width=950,height=900');	
		}

	}
	catch(e)
	{
	}

}

// param nella forma : URL =/report/istanza_pmi.ASP?&TABLE_SIGN=tabella&AREA_SIGN&IDENTITY_SIGN=id
// table_sign e area_sign sono opzionali, identity_sign pure ma è più usato
function PrintPdfSign( param )
{
	var w;
	var h;
	CheckFirmaEBlocco( param );
	
	var pathToRoot = '../../';

	if ( isSingleWin() )
		pathToRoot = pathRoot;
	
	try 
	{
		
		var IDDOC = getObj( 'IDDOC' ).value;
		var TYPEDOC = getObj( 'TYPEDOC' ).value;
		var suffix = getObj( 'SUFFIX_LANGUAGE' ).value;
		
		w = screen.availWidth-50;
		h = screen.availHeight-50;
		
		var url = param;
		var newwin = window.open( '' , 'PrintPdf' ,'toolbar=no,location=no,directories=no,status=yes,resizable=yes,copyhistory=yes,scrollbars=yes,menubar=yes,left=0,top=0,width=' + w + ',height=' + h );
    	try{ 
			newwin.document.write( '<html><body><table class="Loading" width="100%" height="100%" ><tr><td width="100%" height="100%" align="center" valign="center" >Loading ...</td></tr></table></body></html>'); 
			newwin.focus();
		}catch(e){
			
			//pop-up bloccati
			DMessageBox( pathToRoot , 'Errore creazione pop-up, verificare l\'esistenza di un pop-up aperto oppure disabilitare il blocco dei pop-up', 'Attenzione' , 1 , 400 , 300 );
			return;
		};
		
		
		var objForm=getObj('FORMDOCUMENT');
	
		//objForm.action= "../../ctl_library/pdf/pdf.asp?TO_SIGN=YES&IDDOC=" + IDDOC + "&TYPEDOC="+ TYPEDOC + "&" + param;
		objForm.action= pathToRoot + "ctl_library/pdf/pdf.asp?TO_SIGN=YES&IDDOC=" + IDDOC + "&TYPEDOC="+ TYPEDOC + "&" + param;
		objForm.target='PrintPdf';
		try{  CloseRTE() }catch(e){};
		objForm.submit();

	}
	catch( e ) {};
}


function PrintCnvTarget( strUrlPage )
{
	var w;
	var h;
	
	CheckFirmaEBlocco( strUrlPage );

	//debugger;
	try {

		
		var IDDOC = getObj( 'IDDOC' ).value;
		var TYPEDOC = getObj( 'TYPEDOC' ).value;
		var suffix = getObj( 'SUFFIX_LANGUAGE' ).value;
		
		w = screen.availWidth-50;
		h = screen.availHeight-50;
		
		var url = strUrlPage.split('#')[0];
		//url = url.replace( '.asp?' , '_' + suffix + '.asp?');
		
		//ExecFunction( url + 'IDDOC='+ IDDOC + '&TYPEDOC='+ TYPEDOC , 'PrintDocument' , ',menubar=yes,left=0,top=0,width=' + w + ',height=' + h );
		
		var newwin = window.open( '' , strUrlPage.split('#')[1] ,'toolbar=no,location=no,directories=no,status=yes,resizable=yes,copyhistory=yes,scrollbars=yes,menubar=yes,left=0,top=0,width=' + w + ',height=' + h );
		newwin.focus();
		
		var objForm=getObj('FORMDOCUMENT');
	
		objForm.action= url + 'IDDOC='+ IDDOC + '&TYPEDOC='+ TYPEDOC;
		objForm.target=strUrlPage.split('#')[1];

		objForm.submit();

	}
	catch( e ) {};


}

function PrintCnv2( strUrlPage , FIELD_NAME , TYPEDOC )
{
	var w;
	var h;

	CheckFirmaEBlocco( strUrlPage );
	
	//debugger;
	try {
		
		var IDDOC = getObj( FIELD_NAME ).value;
		//var TYPEDOC = getObj( 'TYPEDOC' ).value;
		var suffix = getObj( 'SUFFIX_LANGUAGE' ).value;
		
		w = screen.availWidth-50;
		h = screen.availHeight-50;
		
		var url = strUrlPage;
		
		var newwin = window.open( '' , 'PrintDocument' ,'toolbar=no,location=no,directories=no,status=yes,resizable=yes,copyhistory=yes,scrollbars=yes,menubar=yes,left=0,top=0,width=' + w + ',height=' + h );

		newwin.focus();
		
		var objForm=getObj('FORMDOCUMENT');
	
		objForm.action= url + 'IDDOC='+ IDDOC + '&TYPEDOC='+ TYPEDOC;
		objForm.target='PrintDocument';

		objForm.submit();

	}
	catch( e ) {};

}


function ToPrint( param )
{
	var w;
	var h;
	
	w = screen.availWidth - 50;
	h = screen.availHeight - 50;

	CheckFirmaEBlocco( param );	

	//debugger;
	var CommandQueryString = getObj('CommandQueryString').value;
	var IDDOC = getObj( 'IDDOC' ).value;
	var TYPEDOC = getObj( 'TYPEDOC' ).value;
	var strPrecTarget;

	//Se siamo nella versione accessibile sostituisco il layout con quello print
	if ( isSingleWin() )
	{
		CommandQueryString = ReplaceExtended( CommandQueryString, '%5F', '_');

		CommandQueryString = CommandQueryString.replace( 'lo=' + layout , 'lo=print');
		CommandQueryString = CommandQueryString.replace( 'LO=' + layout , 'lo=print');
	}

	var newwin = window.open( '' , 'PrintDocument' ,'toolbar=no,location=no,directories=no,status=yes,resizable=yes,copyhistory=yes,scrollbars=yes,menubar=yes,left=0,top=0,width=' + (w-100) + ',height=' + (h-100) );

	newwin.focus();
	
	var objForm=getObj('FORMDOCUMENT');
	
		
	strPrecTarget=objForm.target;
	//objForm.action='document.asp?' + CommandQueryString + '&MODE=SHOW&COMMAND=PRINT&OPERATION=PRINT&' + param ;
	objForm.action='ToPrintDocument.asp?' + CommandQueryString + '&MODE=SHOW&COMMAND=PRINT&OPERATION=PRINT&' + param ;
	
	objForm.target='PrintDocument';
	
	objForm.submit();
	
	objForm.target=strPrecTarget;
}

function ToPrintPdf( param )
{
	var w;
	var h;
	
	w = screen.availWidth - 50;
	h = screen.availHeight - 50;

	CheckFirmaEBlocco( param );	

	//debugger;
	var CommandQueryString = getObj('CommandQueryString').value;
	var IDDOC = getObj( 'IDDOC' ).value;
	var TYPEDOC = getObj( 'TYPEDOC' ).value;
	var strPrecTarget;


	var newwin = window.open( '' , 'PrintPdf' ,'toolbar=no,location=no,directories=no,status=yes,resizable=yes,copyhistory=yes,scrollbars=yes,menubar=yes,left=0,top=0,width=' + w + ',height=' + h );
   	try{ newwin.document.write( '<html><body><table class="Loading" width="100%" height="100%" ><tr><td width="100%" height="100%" align="center" valign="center" >Loading ...</td></tr></table></body></html>'); }catch(e){};

	newwin.focus();
	
	var objForm=getObj('FORMDOCUMENT');
	
	strPrecTarget=objForm.target;
	//objForm.action="../../ctl_library/pdf/pdf.asp?URL=/CTL_Library/Document/ToPrintDocument.asp?&" + CommandQueryString + "&MODE=SHOW&COMMAND=PRINT&OPERATION=PRINT&" + param + "&IDDOC=" + IDDOC + "&TYPEDOC="+ TYPEDOC;
	objForm.action="../../ctl_library/pdf/pdf.asp?URL=/CTL_Library/Document/ToPrintDocument.asp?&" + CommandQueryString + "&MODE=SHOW&COMMAND=PRINT&OPERATION=PRINT&" + param + "&TYPEDOC="+ TYPEDOC;
	objForm.target='PrintPdf';

	objForm.submit();
	
	objForm.target=strPrecTarget;
	
}


function ToPrintPdfSign( param )
{
	var w;
	var h;
	
	w = screen.availWidth - 50;
	h = screen.availHeight - 50;

	CheckFirmaEBlocco( param );	

	//debugger;
	var CommandQueryString = getObj('CommandQueryString').value;
	var IDDOC = getObj( 'IDDOC' ).value;
	var TYPEDOC = getObj( 'TYPEDOC' ).value;
	var strPrecTarget;


	var newwin = window.open( '' , 'PrintPdf' ,'toolbar=no,location=no,directories=no,status=yes,resizable=yes,copyhistory=yes,scrollbars=yes,menubar=yes,left=0,top=0,width=' + w + ',height=' + h );
   	try{ newwin.document.write( '<html><body><table class="Loading" width="100%" height="100%" ><tr><td width="100%" height="100%" align="center" valign="center" >Loading ...</td></tr></table></body></html>'); }catch(e){};

	newwin.focus();
	
	var objForm=getObj('FORMDOCUMENT');
	
	strPrecTarget=objForm.target;
	objForm.action="../../ctl_library/pdf/pdf.asp?TO_SIGN=YES&URL=/CTL_Library/Document/ToPrintDocument.asp?&" + CommandQueryString + "&MODE=SHOW&COMMAND=PRINT&OPERATION=PRINT&" + param + "&TYPEDOC="+ TYPEDOC; // + "&IDDOC=" + IDDOC;
	objForm.target='PrintPdf';

	objForm.submit();
	
	objForm.target=strPrecTarget;
	
}

function CheckFirmaEBlocco( param ) 
{
	var strCheck = '&' + param.toUpperCase() + '&';

	if( strCheck.indexOf( '&SIGN=YES&' ) > -1 )
	{
		//-- se avvio la stampa per la firma digitale blocco a video il documento
		try{
			try {
				ShowWorkInProgress();
			}catch(e)
			{
				getObj('INFO_PROCESS').style.display='';
				getObj('INFO_PROCESS2').style.display='';
			}
		}catch(e){};
	}
}



