window.onload = OnLoadPage; 

function OnLoadPage()
{

	var JumpCheck = getObjValue( 'JumpCheck' );

	if( JumpCheck.toLowerCase() == 'monoround'   ) 
	{
		ShowCol( 'LISTA_BUSTE' , 'Posizione' , 'none' );
	}
	else
	{
		ShowCol( 'LISTA_BUSTE' , 'PercAgg' , 'none' );
 	}

	var TipoSceltaContraente = getObjValue('TipoSceltaContraente').toLowerCase();
	var TipoProceduraCaratteristica = getObjValue('TipoProceduraCaratteristica').toLowerCase();
	
	/*
	if ( TipoProceduraCaratteristica == 'rilanciocompetitivo' || TipoSceltaContraente == 'accordoquadro' )
	{
		$("#cap_ImportoAggiudicatoInConvenzione").parents("table:first").css({"display": "none"});
	}
	*/
	
}

