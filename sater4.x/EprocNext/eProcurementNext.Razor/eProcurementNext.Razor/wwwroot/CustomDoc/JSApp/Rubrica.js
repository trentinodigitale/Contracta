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


	//-- rimpiazzo dei parametri /blue/gi str.replace(/blue/gi, "red");
	//QS=QS.replace(/modgriglia=bo/gi,'ModGriglia=DASHBOARD_VIEW_RUBRICAGriglia');
	QS=QS.replace(/modgriglia=bo/gi,'ModGriglia_X=');

	//QS=QS.replace(/positionalmodelgrid=dashboard_view_rubricagriglia/gi,'positionalmodelgrid_x=');
	QS=QS.replace(/positionalmodelgrid=/gi,'ModGriglia=');
	

	var win;
	win = ExecFunction( 'viewerPrint.asp?OPERATION=PRINT' +  '&'  + QS + '&Hide_Col=HR1&' + vet[0]  , 'Print_Viewer' , ',menubar=yes' + ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h + altro );
	win.focus();
	
}






function ViewerExcel( param )
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

	//-- rimpiazzo dei parametri /blue/gi str.replace(/blue/gi, "red");
	//QS=QS.replace(/modgriglia=bo/gi,'ModGriglia=DASHBOARD_VIEW_RUBRICAGriglia');

	//QS=QS.replace(/positionalmodelgrid=dashboard_view_rubricagriglia/gi,'positionalmodelgrid_x=');
	
		//-- rimpiazzo dei parametri /blue/gi str.replace(/blue/gi, "red");
	//QS=QS.replace(/modgriglia=bo/gi,'ModGriglia=DASHBOARD_VIEW_RUBRICAGriglia');
	QS=QS.replace(/modgriglia=bo/gi,'ModGriglia_X=');

	//QS=QS.replace(/positionalmodelgrid=dashboard_view_rubricagriglia/gi,'positionalmodelgrid_x=');
	QS=QS.replace(/positionalmodelgrid=/gi,'ModGriglia=EXCEL_');
	

	
	var win;
	win = ExecFunction( 'viewerExcel.asp?OPERATION=EXCEL' +  '&'  + QS + '&Hide_Col=HR1&' + vet[0]  , '' , '' );
	

}
