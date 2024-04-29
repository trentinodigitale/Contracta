//-- esegue un comando su una pagina ASP
//-- recupera dalla pagina un campo hidden chiamato CommandQueryString
//-- e lo concatena all'url richiesto nel parametro
//-- il parametro è formatatto con il separatore #
//-- 1° -- URL con comando da eseguire
//-- 2° -- target
//-- 3° -- se presente è la dimensione della finestra da aprire altrimenti è tutto schermo

function ExecCommand( param  )
{
	var QS;
	var vet;
	var sQS;
	var altro;
	
	sQS = '';
	//debugger;
	vet = param.split( '#' );

	//-- determina le dimensioni
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
  
	try
	{	
		//-- recupera il codice della riga selezionata
		QS = getObj('CommandQueryString');
		sQS =  '&' + QS.value;
	} catch( e ) { };
	
	ExecFunction(  vet[0] + sQS  , vet[1] , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h + altro );

}