function afterProcess( param )
{
	try
	{
		/* RICARICO I PERMESSI DELL'UTENTE COLLEGATO */
		ajax = GetXMLHttpRequest(); 
		var nocache = new Date().getTime();

		if(ajax)
		{
			ajax.open("GET", '../../ctl_library/reloadFunz.asp?nocache=' + nocache, false);
			ajax.send(null);

			if(ajax.readyState == 4) 
			{
				//Se non ci sono stati errori di runtime
				if(ajax.status == 200)
				{
					var res = ajax.responseText;
					
					if ( res!= '' ) 
					{

						//Se l'esito della chiamata è stato positivo
						if ( res.substring(0, 2) == '1#' ) 
						{
							RefreshDocument( './' );
						}
					}
				}
			}
		}
	}
	catch(e)
	{
	}
}

function RefreshContent()
{
	RefreshDocument('');	
}
