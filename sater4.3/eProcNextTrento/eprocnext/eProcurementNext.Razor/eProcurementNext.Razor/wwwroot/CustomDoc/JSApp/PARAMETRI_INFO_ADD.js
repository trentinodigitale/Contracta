window.onload = onLoadFunc;

function onLoadFunc()
{
	hideSelLivello();
}

function hideSelLivello()
{
	var modalita = getObjValue('modalitaDiScelta');
	
	if (modalita == '' || modalita == '0' )
	{
		$( "#cap_livelloBloccato" ).parents("table:first").css({"display":"none"});
	}
	else
	{
		$( "#cap_livelloBloccato" ).parents("table:first").css({"display":""});
	}
	
}

