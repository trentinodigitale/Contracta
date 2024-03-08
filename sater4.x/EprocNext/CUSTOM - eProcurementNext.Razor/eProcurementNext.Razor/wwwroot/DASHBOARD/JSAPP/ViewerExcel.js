

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
	
	
	
	//se contiene stored_sql=yes come adesso altrimenti chiamiamo quello xlsx
	if ( QS.toUpperCase().indexOf("STORED_SQL=YES") < 0  ){
		
		return ViewerExcel_x( param );
		
	}else{
	
	
		//-- tolgo eventuali parametri di caption
		QS=QS.replace('Caption','OldCaption');
		
		var win;
		win = ExecFunction( 'viewerExcel.asp?OPERATION=EXCEL' +  '&'  + QS + '&' + vet[0]  , '' , '' );
	
	}	
	
	
	
}


function ViewerExcelAdvanced( param )
{
	
	/*
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
	QS=QS.replace('caption','OldCaption');
	
	//-- tolgo il vecchhio parametro table
	QS=QS.replace('Table=','OldTable=');
	QS=QS.replace('table=','OldTable=');
	
	//-- tolgo il vecchhio parametro ModGriglia
  QS=QS.replace('ModGriglia=','OldModGriglia=');
	QS=QS.replace('modgriglia=','OldModGriglia=');
	
	var win;
	win = ExecFunction( 'viewerExcel.asp?OPERATION=EXCEL' +  '&'  + QS + '&' + vet[0]  , '' , '' );
	*/
	
	return ViewerExcelAdvanced_x( param );

}



function ViewerExcel_x( param )
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
	QS=QS.replace('caption','OldCaption');
	
	var win;
	win = ExecFunction( 'viewerExcel_x.asp?OPERATION=EXCEL' +  '&'  + QS + '&' + vet[0]  , '' , '' );
	

}




function ViewerExcelAdvanced_x( param )
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
	
	QS = QS.toUpperCase();
	
	//-- tolgo eventuali parametri di caption
	QS=QS.replace('CAPTION','OldCaption');
	//QS=QS.replace('caption','OldCaption');
	
	//-- tolgo il vecchhio parametro table
	QS=QS.replace('TABLE=','OldTable=');
	//QS=QS.replace('table=','OldTable=');
	
	//-- tolgo il vecchhio parametro ModGriglia
	QS=QS.replace('MODGRIGLIA=','OldModGriglia=');
	//QS=QS.replace('modgriglia=','OldModGriglia=');
	
	if ( param.toUpperCase().indexOf("STORED_SQL=NO") > 0  )
	{
	
		QS=QS.replace('STORED_SQL=','OldSTORED_SQL=');
		//QS=QS.replace('stored_sql=','OldSTORED_SQL=');
	}	
	if ( param.toUpperCase().indexOf("STORED_SQL=YES") > 0  &&  QS.toUpperCase().indexOf("STORED_SQL=YES") > 0 )
	{
	
		QS=QS.replace('STORED_SQL=','OldSTORED_SQL=');
		//QS=QS.replace('stored_sql=','OldSTORED_SQL=');
	}	
	
	
	var win;

	win = ExecFunction( 'viewerExcel_x.asp?OPERATION=EXCEL' +  '&'  + QS + '&' + vet[0]  , '' , '' );
	 

}
