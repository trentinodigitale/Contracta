
function checkCodiceIniziativa()
{
	var codIniziativa;
	
	if (document.getElementById('NumeroDocumento'))
	{
		codIniziativa = getObjValue('NumeroDocumento');
		
		if ( !IsDecimal(codIniziativa) )
		{
			getObj('NumeroDocumento').value = '';
			DMessageBox( '../' , 'Il codice ammette solo numeri' , 'Attenzione' , 1 , 400 , 300 );
		}
		
	}
	
}

function IsDecimal(sText)
{
	var ValidChars = '0123456789';
	var IsNumber=true;
	var Char;
	
	for (i = 0; i < sText.length && IsNumber == true; i++) 
	{ 
		Char = sText.charAt(i);
		if (ValidChars.indexOf(Char) == -1) 
		{
			IsNumber = false;
		}
	}
	return IsNumber;
	
}