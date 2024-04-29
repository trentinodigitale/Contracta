window.onload = onloadpage;

function onloadpage()
{
	var AttivaFilePending = getObj('AttivaFilePending');
	
	/* SE IL CAMPO ESISTE */
	if ( AttivaFilePending )
	{
    
		//Se non è richiesta la verifica pending dei file nascondiamo la colonna statoFirma
		if (AttivaFilePending.value != 'si' )
		{
			ShowCol('DETTAGLI', 'statoFirma', 'none');
		}
	}

}