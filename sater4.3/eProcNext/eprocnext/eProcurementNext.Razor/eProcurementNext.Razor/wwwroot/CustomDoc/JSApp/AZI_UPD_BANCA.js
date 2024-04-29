function MyExecDocProcess( param )
{
	
	SetTextValue( 'ABIBanca' ,  getObj( 'ABIBanca' ).value.toUpperCase() );
	SetTextValue( 'CABBanca' ,  getObj( 'CABBanca' ).value.toUpperCase() );
	SetTextValue( 'CCBanca' ,  getObj( 'CCBanca' ).value.toUpperCase() );
	SetTextValue( 'IBAANBanca' ,  getObj( 'IBAANBanca' ).value.toUpperCase() );


	if ( getObj( 'ABIBanca' ).value.length != 5 )
	{
		DMessageBox( '../' , 'Il campo ABI deve essere lungo 5' , 'Attenzione' , 2 , 400 , 300 );
		getObj('ABIBanca').focus();
		return;
	}


	if ( CheckNUM( getObj( 'ABIBanca' ).value ) )
	{
		DMessageBox( '../' , 'Il campo ABI contiene caratteri non validi' , 'Attenzione' , 2 , 400 , 300 );
		getObj('ABIBanca').focus();
		return;
	}


	if ( getObj( 'CABBanca' ).value.length != 5 )
	{
		DMessageBox( '../' , 'Il campo CAB deve essere lungo 5' , 'Attenzione' , 2 , 400 , 300 );
		getObj('CABBanca').focus();
		return;
	}


	if ( CheckNUM( getObj( 'CABBanca' ).value ) )
	{
		DMessageBox( '../' , 'Il campo CAB contiene caratteri non validi' , 'Attenzione' , 2 , 400 , 300 );
		getObj('CABBanca' ).focus();
		return;
	}


	if ( getObj( 'CCBanca' ).value.length != 12 )
	{
		DMessageBox( '../' , 'Il campo conto corrente deve essere lungo 12' , 'Attenzione' , 2 , 400 , 300 );
		getObj('CCBanca').focus();
		return;
	}

	if ( CheckChar( getObj( 'CCBanca' ).value ) )
	{
		DMessageBox( '../' , 'Il campo conto corrente contiene caratteri non validi' , 'Attenzione' , 2 , 400 , 300 );
		getObj('CCBanca').focus();
		return;
	}


	if ( getObj( 'IBAANBanca' ).value.length != 27 )
	{
		DMessageBox( '../' , 'Il campo IBAN deve essere lungo 27' , 'Attenzione' , 2 , 400 , 300 );
		getObj('IBAANBanca').focus();
		return;
	}


	if ( CheckChar( getObj( 'IBAANBanca').value ) )
	{
		DMessageBox( '../' , 'Il campo IBAN contiene caratteri non validi' , 'Attenzione' , 2 , 400 , 300 );
		getObj('IBAANBanca').focus();
		return;
	}





	ExecDocProcess( param );
}

function CheckChar( str )
{
	var strCheck = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
	var i;

	for( i = 0 ; i < str.length ; i++ )
	{
		if ( strCheck.indexOf( str.charAt( i ) ) < 0 ) 
		{
			return -1;
		}
	}
	return 0;

}

function CheckNUM( str )
{
	var strCheck = '0123456789';
	var i;

	for( i = 0 ; i < str.length ; i++ )
	{
		if ( strCheck.indexOf( str.charAt( i ) ) < 0 ) 
		{
			return -1;
		}
	}
	return 0;

}

