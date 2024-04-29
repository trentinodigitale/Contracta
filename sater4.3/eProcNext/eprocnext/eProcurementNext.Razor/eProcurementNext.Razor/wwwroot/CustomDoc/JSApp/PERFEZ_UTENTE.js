window.onload = OnLoadPage;

function OnLoadPage() 
{
	var DOCUMENT_READONLY = '0';
	DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;
	if (DOCUMENT_READONLY == '1') 
	{
		document.getElementById('bottone_conferma').style.display='none';
	}
	else
	{
		document.getElementById('bottone_chiudi').style.display='none';
	}
		
	
}

function Conferma()
{

	
	var value ='';
	
	if ( getObj('StatoFunzionale').value != 'InLavorazione')
    {
		value='NO';		
	}	
	
	if ( value == '' )
	{ 
		
		if ( checkCoerenzaCF() == 1 )
		{
			ExecDocProcess( 'CONFERMA,PERFEZ_UTENTE' );
		}
		
	}
	else
		return false; 

}
function Chiudi()
{
	breadCrumbPop();
}


function checkCoerenzaCF()
{
	var nome = getObjValue('pfuNome').replace(/^\s+|\s+$/gm,'');
	var cognome = getObjValue('pfuCognome').replace(/^\s+|\s+$/gm,'');
	var cf = getObjValue('codicefiscale').replace(/^\s+|\s+$/gm,'');
	
	var resFunct = 1;
	
	/* Se sono avvalorati tutti i campi utili */
	if ( nome !== '' && cognome !== '' && cf !== '' )
	{
		if ( !isMyCF('../../', nome , cognome, cf) )
		{
			resFunct = 0;

			DMessageBox( '../' , 'Codice fiscale non coerente con nome e cognome' , 'Attenzione' , 1 , 400 , 300 );

			TxtErr( 'pfuNome' );
			TxtErr( 'pfuCognome' );
			TxtErr( 'codicefiscale' );
		}
		else
		{
			resFunct = 1;

			TxtOK( 'pfuNome' );
			TxtOK( 'pfuCognome' );
			TxtOK( 'codicefiscale' );
		}
	}

	return resFunct;
}

function afterProcess( param )
{
	
   
		try
		{
			/* RICARICO I PERMESSI DELL'UTENTE COLLEGATO */
			ajax = GetXMLHttpRequest(); 
			var nocache = new Date().getTime();

			if(ajax)
			{
				ajax.open("GET", '../reloadFunz.asp?nocache=' + nocache, false);
				ajax.send(null);
				//alert(ajax.readyState);
				//alert(ajax.status);
				//alert(ajax.responseText);
				if(ajax.readyState == 4) 
				{
					//Se non ci sono stati errori di runtime
					
					if(ajax.status == 200)
					{
						var res = ajax.responseText;
						
						if ( res!= '' ) 
						{
							
							//Se l'esito della chiamata è stato positivo
							//if ( res.substring(0, 2) == '1#' ) 
							//{
								//RefreshDocument( './' );
								
							//}
						}
					}
				}
			}
		}
		catch(e)
		{
		}
	
}
