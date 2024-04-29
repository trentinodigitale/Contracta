//-- ritorna l'identificativo della  riga richiesta
function GetIdRow( grid , numRow , Page )
{
	var objInd;
	var valueret;
	
	indSel = -1;
	
	try
	{
		//-- Prendo l'identificativo della riga passato l'indice della riga
		if( numRow >= 0 )
		{
			//-- prelevo il valore dell'identificativo
			objInd = getObjPage( grid + '_idRow_' + numRow , Page);

			if ( !objInd )
			{
				objInd = getObj( 'R' + + numRow + '_idRow' );
			}
			
			try
			{
				valueret= objInd[0].value;
			}
			catch(e)
			{
				valueret= objInd.value;
			}

			return valueret

		}
		else
			return '';
		
	}
	catch(  e ){ return ''; 	};

}
