

function ViewerPrint( param )
{
	var objForm;
	var altro;
	var vet;	
	//debugger;

	vet = param.split( '#' );

	var w;
	var h;
	var Left;
	var Top;
    
    if( vet.length < 2  )
    {
		w = screen.availWidth;
		h = screen.availHeight;
		Left=0;
		Top=0;
	}
	else    
	{
		var d;
		d = vet[1].split( ',' );
		w = d[0];
		h = d[1];
		Left = (screen.availWidth-w)/2;
		Top  = (screen.availHeight-h)/2;
		
		if( vet.length > 2 )
		{
			altro = vet[2];
		}
	}


	var strSort='';
	
	//-- recupero i Query string per passarla alla stampa
	var QS = getObj('QueryString').value;
	
	//-- tolgo eventuali parametri di caption
	QS=QS.replace('Caption','OldCaption');
	
	//Se siamo nella versione accessibile sostituisco il layout con quello print
	if ( isSingleWin() )
	{
		QS = QS.replace( 'lo=' + layout , 'lo=print');
	}
	else
	{
		QS = QS.replace( 'lo=' + layout , 'lo=print');
	}
	
	var win;
	win = ExecFunction( 'viewerPrint.asp?OPERATION=PRINT' +  '&'  + QS + '&' + vet[0]  , 'Print_Viewer' , ',menubar=yes' + ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h + altro );
	win.focus();
	
	//objForm = parent.ViewerFiltro.getObj('FormViewerFiltro'); 
	/*
	objForm = parent.ViewerFiltro.FormViewerFiltro;
	
	var oldAction = objForm.action;
	var oldtarget = objForm.target;
	
	objForm.action='viewerPrint.asp?OPERATION=PRINT' +  '&'  + QS + '&' + vet[0];
	objForm.target='Print_Viewer';
	
	objForm.submit();
	
	objForm.action=oldAction; 
	objForm.target=oldtarget;
	*/

}



function CALENDARIO_PRINT_DATE( param )
{
	var URL = 'InputBoxWin.asp?Modello=CALENDARIO_PRINT_DATE&Caption=Selezione periodi di stampa&Command=CalPrintParam( getObj(\'DataInizio\').value %2B \'Q\' %2B getObj(\'DataFine\').value );'
	URL = URL + '&DefaultValueEdit=DataInizio=' + getObj( 'DATA_CALENDAR' ).value + '-01,DataFine=' + getObj( 'DATA_CALENDAR' ).value + '-01';
	win = ExecFunctionCenter( URL + '#SelDate#500,400');
	win.focus();

}




function CalPrintParam( param )
{
	var objForm;
	var altro;
	var vet;	
	//debugger;
	
	//alert( param );
	
	vet = param.split( 'Q' );
	
	

	var w;
	var h;
	var Left;
	var Top;
    
    {
		w = screen.availWidth;
		h = screen.availHeight;
		Left=0;
		Top=0;
	}
	
	//-- tolgo la data attuale
	
	//-- inserisco le date passate


	var strSort='';
	
	//-- recupero i Query string per passarla alla stampa
	var QS = getObj('QueryString').value;
	
	//-- tolgo eventuali parametri di caption
	QS=QS.replace('Caption','OldCaption');

	var spDate='';
	try
	{
		spDate = '&DATA_CALENDAR=' + vet[0].substr(0,4) + '-' +  vet[0].substr(5,2) + '&DATA_CALENDAR_END=' + vet[1].substr(0,4) + '-' +  vet[1].substr(5,2);
		QS=QS.replace('&DATA_CALENDAR=','&OldDATA_CALENDAR=');
		
	}catch( e ) {};
	
	var win;
	
	win = ExecFunction( 'viewerGriglia.asp?OPERATION=PRINT_CAL' +  '&'  + QS + spDate   , 'Print_Viewer_CAL' , ',menubar=yes' + ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h + altro );
	//win = ExecFunction( 'CalSelPrint.asp?OPERATION=PRINT_CAL' +  '&'  + QS + '&' + vet[0]  , 'Print_Viewer_CAL' , ',menubar=yes' + ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h + altro );
	win.focus();
	

}
