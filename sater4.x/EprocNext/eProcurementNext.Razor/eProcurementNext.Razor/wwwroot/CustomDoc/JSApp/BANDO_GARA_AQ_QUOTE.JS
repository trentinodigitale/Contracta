function OpenQuota(objGrid , Row , c)
{
var idRow;
var parametri;
idRow = getObj( 'R' + Row + '_id').value;
parametri='AQ_QUOTA##AQ_QUOTA'


var cod;
	var nq;
	var altro;
	var altroDOC = '';
	var s;
	var strURL = 'document.asp?';

	//alert( idRow );
	
	var vet;
	var documento;
	var docfrom;

	vet = parametri.split( '#' );
	documento = vet[0];
	docfrom = vet[1];

	
	
	try{
		s = docfrom.split( ',' );
		if(  s.length > 1 ) 
		{
			docfrom = s[0];
			idRow = s[1];
		}
	}
	catch( e ) {
	

	}

	if( idRow == '' )
	{
		DMessageBox( '../' , 'E\' necessario prima il documento' , 'Attenzione' , 1 , 400 , 300 );
		//alert( "E' necessario prima il documento" );
		return;
	}

	
	parametri=parametri + '#' + idRow + '##'
	
	MakeDocFrom(parametri); 
  
}



