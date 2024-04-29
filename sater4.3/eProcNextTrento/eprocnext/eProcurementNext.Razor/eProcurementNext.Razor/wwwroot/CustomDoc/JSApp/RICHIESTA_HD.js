window.onload = OnLoadPage;

function getLegend(codUrgenza)
{
	var valCodUrg = getObjValue( codUrgenza.id );
	
	if ( valCodUrg != '') 
		getObj('RTESTATA_SEGNALAZIONE_MODEL_Motivazione_V').innerHTML = CNV( '../../', 'HELP_' + valCodUrg);
	else
		getObj('RTESTATA_SEGNALAZIONE_MODEL_Motivazione_V').innerHTML = "";
}

function OnLoadPage()
{
	try
	{
		//Recupero la legenda per la priorità selezionata anche all'apertura del documento e non solo all'onChange del dominio
		getLegend( getObj('val_RTESTATA_SEGNALAZIONE_MODEL_Priorita') );
	}
	catch(e)
	{}
}
