function ContrattoTelematico( param ){

  
  
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
  
	
	var IDPDA;
  IDPDA = getObj( 'ID_MSG_PDA' ).value ;
	
	strUrl=vet[0] + 'IDPDA=' + IDPDA;
	
	
	ExecFunction(  strUrl  , 'ContrattoTelematico' , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  );
	

}