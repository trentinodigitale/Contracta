function TipoGara (param){
	
	var idRow;
	var vet;
	var altro;
	
		
	//debugger;
	vet = param.split( '#' );

	var w;
	var h;
	var Left;
	var Top;
    
    if( vet.length < 3  )
    {
		w = screen.availWidth;
		h = screen.availHeight;
		Left=0;
		Top=0;
	}
	else    
	{
		var d;
		d = vet[2].split( ',' );
		w = d[0];
		h = d[1];
		Left = (screen.availWidth-w)/2;
		Top  = (screen.availHeight-h)/2;
		
		if( vet.length > 3 )
		{
			altro = vet[3];
		}
	}
  
	
	
	var IDDOC = getObj( 'IDDOC' ).value;
	
	strUrl=vet[0] + '&IDDOC='+IDDOC;
	
	
	ExecFunction(  strUrl  , vet[1] , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  );
	
	
}


function ApriBando (param){
	var idRow;
	var vet;
	var altro;
	
		
	//debugger;
	vet = param.split( '#' );

	var w;
	var h;
	var Left;
	var Top;
    
    if( vet.length < 3  )
    {
		w = screen.availWidth;
		h = screen.availHeight;
		Left=0;
		Top=0;
	}
	else    
	{
		var d;
		d = vet[2].split( ',' );
		w = d[0];
		h = d[1];
		Left = (screen.availWidth-w)/2;
		Top  = (screen.availHeight-h)/2;
		
		if( vet.length > 3 )
		{
			altro = vet[3];
		}
	}
	var ProtocolloBando = getObj( 'ProtocolloBando' ).value;
	strUrl=vet[0] + 'ProtocolloBando=' + ProtocolloBando ;
	ExecFunction(  strUrl  , vet[1] , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  );
}

function CheckForSend(){

 var TipoProcedura = getObj( 'TipoProcedura' ).value;
  
 if (TipoProcedura=='8')
	getObj( 'PROGETTO_TOOLBAR_DOCUMENT_SEND' ).disabled=true;
 else
	getObj( 'PROGETTO_TOOLBAR_DOCUMENT_SEND' ).disabled=false;	
}


function ApriInvito (param){
	var idRow;
	var vet;
	var altro;
	
		
	//debugger;
	vet = param.split( '#' );

	var w;
	var h;
	var Left;
	var Top;
    
    if( vet.length < 3  )
    {
		w = screen.availWidth;
		h = screen.availHeight;
		Left=0;
		Top=0;
	}
	else    
	{
		var d;
		d = vet[2].split( ',' );
		w = d[0];
		h = d[1];
		Left = (screen.availWidth-w)/2;
		Top  = (screen.availHeight-h)/2;
		
		if( vet.length > 3 )
		{
			altro = vet[3];
		}
	}
	var ProtocolloBando = getObj( 'ProtocolloBando' ).value;
	strUrl=vet[0] + 'ProtocolloBando=' + ProtocolloBando ;
	ExecFunction(  strUrl  , vet[1] , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  );
}