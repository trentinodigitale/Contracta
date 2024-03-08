

function ViewerGrigliaXml( param )
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
	
	var win;
	win = ExecFunction( 'xml.asp?OPERATION=XML' +  '&'  + QS + '&' + vet[0]  , '' , '' );
	

}
