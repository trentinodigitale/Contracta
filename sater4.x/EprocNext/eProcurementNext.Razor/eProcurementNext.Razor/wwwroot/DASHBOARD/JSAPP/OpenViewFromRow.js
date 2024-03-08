function OpenViewFromRow( obj , ColURL  )
{


	//-- determina il numero della riga

	try{ nameField = obj.id; } catch( e ) {nameField ='';}
	
	if ( nameField == '' )
	{
		alert( 'Errore recupero riga' );
	}


	var riga = nameField.split('_')[0];
		
	//riga = riga.replace('R','');
		
	//var r = parseInt( riga );


	var param = getObj( riga + '_' + ColURL )[0].value;
	param  = unescape(param );
	//-- i parametri sono separati da # e sono in quest'ordine
	//-- 1° - URL da invocare
	//-- 2° - target dell'output
	//-- 3° - dimensioni della finestra
	//-- 4° - parametri aggiuntivi da passare alla nuova finestra per una corretta visualizzazione

	var idRow;
	var vet;
	var altro;
	var i;
	
	//debugger;
	
	vet = param.split( '#' );


	//-- recupera le dimensioni della finestra di output
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
	

	
	ExecFunction(  vet[0]  , vet[1] , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h + altro );
//	window.open( vet[0],target,'toolbar=no,location=no,directories=no,status=yes,menubar=no,resizable=yes,copyhistory=yes,scrollbars=yes' + param );
	


}