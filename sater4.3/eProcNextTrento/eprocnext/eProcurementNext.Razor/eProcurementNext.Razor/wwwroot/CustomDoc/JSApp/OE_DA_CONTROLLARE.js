window.onload = INIT_DOC;


function INIT_DOC()
{
	INIT_ELENCO();
	
	//REGOLA LA VISUALIZZAZIONE DEI CRITERI DI ESTRAZIONE
	if ( getObjValue('Tipo_Estrazione') == '1')
	{
		$( "#cap_Num_estrazione_mista" ).parents("table:first").css({"display":"none"})
	}
	if ( getObjValue('Tipo_Estrazione') == '2')
	{
		$( "#cap_Perc_Soggetti" ).parents("table:first").css({"display":"none"})
	}
	
	
	
}

function INIT_ELENCO()
{
	//SE PUBBLICA E' SELEZIONATO NASCONDO LA COLONNA RAGIONE_SOCIALE
		 
	if( getObj('Pubblica').checked == true)
	{	
	  ShowCol( 'ELENCO_OE' , 'aziRagioneSociale' , 'none' );    
	  ShowCol( 'ELENCO_OE' , 'aziPartitaIVA' , 'none' );    
	  ShowCol( 'ELENCO_OE' , 'aziCodiceFiscale' , 'none' );    
	}
	else
	{
		ShowCol( 'ELENCO_OE' , 'aziRagioneSociale' , '' );
		ShowCol( 'ELENCO_OE' , 'aziPartitaIVA' , '' );    
		ShowCol( 'ELENCO_OE' , 'aziCodiceFiscale' , '' );   
	} 
	 
	 
}


function MY_ESPORTA(param)
{
	
	
	var HIDECOL='' 
	
	if( getObj('Pubblica').checked == true)
	{
		HIDECOL=HIDECOL + 'StatoDoc,aziRagioneSociale,aziPartitaIVA,aziCodiceFiscale,DataScadenza,IdpfuInCharge,'
	}
	
	ExecDownloadSelf(param + '&HIDECOL=' + HIDECOL)
}
