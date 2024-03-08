window.onload = OnLoadPage; 

function OnLoadPage()
{
	
	var CriterioAggiudicazioneGara = getObjValue( 'CriterioAggiudicazioneGara' );
	if( CriterioAggiudicazioneGara  == '15532' || CriterioAggiudicazioneGara  == '25532'   ) //-- economicamente vantaggiosa o COSTO FISSO
	{
		ShowCol( 'DETTAGLI' , 'TaglioAli' , 'none' );
		ShowCol( 'DETTAGLI' , 'ScartoAritmetico' , 'none' );
		
		$( "#cap_MediaRibassi" ).parents("table:first").css({"display":"none"});
		$( "#cap_SommaRibassi" ).parents("table:first").css({"display":"none"});
		$( "#cap_MediaScarti" ).parents("table:first").css({"display":"none"});
		$( "#cap_SogliaAnomalia" ).parents("table:first").css({"display":"none"});		
	
	}
	else
	{
		ShowCol( 'DETTAGLI' , 'PunteggioTecnico' , 'none' );
		ShowCol( 'DETTAGLI' , 'PunteggioEconomico' , 'none' );
		ShowCol( 'DETTAGLI' , 'PunteggioTotale' , 'none' );

		$( "#cap_PunteggioTecnico" ).parents("table:first").css({"display":"none"});
		$( "#cap_PunteggioEconomico" ).parents("table:first").css({"display":"none"});
		$( "#cap_SogliaPunteggioTecnico" ).parents("table:first").css({"display":"none"});
		$( "#cap_SogliaPunteggioEconomico" ).parents("table:first").css({"display":"none"});
		$( "#cap_ModalitaAnomalia_TEC" ).parents("table:first").css({"display":"none"});
		$( "#cap_ModalitaAnomalia_ECO" ).parents("table:first").css({"display":"none"});
		
		
		
	}
	
	//Il campo Parametro per esclusione automatica deve essere visualizzato solamente se la gara è al prezzo più basso ed esclusione automatica
	var OffAnomale = getObjValue( 'OffAnomale' );
	if ( CriterioAggiudicazioneGara != '15531' || OffAnomale != '16309' )
	{
		$( "#cap_Parametro_esclusione_automatica" ).parents("table:first").css({"display":"none"});
	}
	
	filtro_stato_offerta();
	
	if( getObjValue( 'OFFERTE_UTILI' ) == 'NO' )
	{
		DMessageBox('../', 'La funzione di anomalia selezionata non e\' applicabile per la numerosita\' dei partecipanti, procedere manualmente se lo si ritiene opportuno', 'Attenzione', 1, 400, 300);
	}
	
}

function TESTATA_OnLoad ()
{

}
function filtro_stato_offerta()
{

	var DOCUMENT_READONLY = '0';
	
	try
	{
		DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;
	}
	catch(e){}
	//Se il documento è editabile
	if (DOCUMENT_READONLY == '0')
	{
		var value= getObjValue('colonnatecnica');
		if ( value == '16310' )
		{
			var filter =  'SQL_WHERE=DMV_COD in (\'SospettoAnomalo\',\'verificasuperata\')';
		}
		else
		{
			var filter =  'SQL_WHERE=DMV_COD in (\'anomalo\',\'verificasuperata\')';
		}
		try
		{
			var n = GetProperty( getObj('DETTAGLIGrid') , 'numrow');
			/* 
			for (i = 0; i <= n; i++) 
			{
				
				if ( getObjValue('R'+i+'_NotEditable') == '' || getObjValue('R'+i+'_NotEditable') == 'undefined' )
				{
					FilterDom( 'R' + i + '_StatoAnomalia' , 'StatoAnomalia' , getObjValue('R' + i + '_StatoAnomalia') , filter ,i, '');				
				}
				
			}*/
			for( i = 0; i < 1; i++ )
			{
				
				try
				{
					FilterDomFirstRowCol(  'R' + i + '_StatoAnomalia' , 'StatoAnomalia' , getObjValue('R' + i + '_StatoAnomalia'), filter ,  i  , '' , '', '', '', 'NotEditable' );
				}
				catch(e)
				{
				}

			}			
			
		}catch( e ) {};	
	
	}
	
	

}
function OnChangeParametroEsclusioneAutomatica()
{
	if( isNumeric( getObj('Parametro_esclusione_automatica').value ) == true )
		ExecDocProcess( 'RIESEGUI_CALCOLI,VERIFICA_ANOMALIA' );
}

function isNumeric(n) { 
      return !isNaN(parseFloat(n)) && isFinite(n); 
}
