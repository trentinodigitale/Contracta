
//'--Versione=1&data=2014-06-18&Attvita=57459&Nominativo=Leone

function resetFormFiltro(form)
{
	/* Funzione per Reset del form di ricerca. il reset html non va bene
		perchè riporta il form alla situazione iniziale (quindi ad un eventuale
		ricerca precedente), a noi serve che il form si svuoti interamente
		tranne per quanto riguarda i campi tecnici relativamente valori di configurazioni */
	
	var nomeForm = 'FormViewerFiltro';
	
	if (typeof form != 'undefined')
		nomeForm = form.getAttribute('id');
	
	var elems = document.getElementById(nomeForm).elements;
	
	var type = '';
	var elem;
	
	for(var i = 0; i < elems.length; i++)
	{
		try
		{
			elem = elems[i];
			type = elem.type.toLowerCase();
			
			switch (type)
			{
				case "text":
				case "password":				
				case "textarea":				
				case "hidden":
				
					//svuoto solo se non è un campo tecnico non influenzabile dall'utente
					if ( elem.id.indexOf("_extraAttrib") == -1 )
						elem.value = "";
						
					break;
					
				case "radio":
				case "checkbox":
					if (elem.checked)
					{
						elem.checked = false;
					}
					break;
					
				case "select-one":				
				case "select-multi":
					elem.selectedIndex = -1;
					break;
					
				default:
					break;
			}
		}
		catch(e)
		{
			//alert(e.message);
		}
		
	}

}
