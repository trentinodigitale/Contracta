//--Versione=3&data=2012-05-21&Attvita=40164&Nominativo=Sabato
var VersionePrint = 0;	

window.onload = Documento_Selezione_Criteri_Anomalia; 


function Documento_Selezione_Criteri_Anomalia()
{
	
	//--eval( 'function DocShowFolder( F ){	alert( ''DOCUMENT_PDA_'' + F ); } ');
	//--eval( 'function DocShowFolder( F ){	alert( ''test'' ); } ' );
	
	DocShowFolder = DocShowFolderLoc;
	
	try {
		VersionePrint = InToPrintDocument ;
	}catch(e){}
	
	//nella versione stampa nascondo le aree ed esco	
	if ( VersionePrint == 1){
		
		OnLoadPage();
		return;
		
	}	

    var statoFunzionale = '';

    try {
        statoFunzionale = getObjValue('StatoFunzionale');
    }
    catch (e) {
        statoFunzionale = getObjValue('val_StatoFunzionale');
    }



	if ( getObjValue( 'RICHIESTA_CALCOLO_ANOMALIA' ) == 'SI' && getObjValue( 'ESISTENZA_RICHIESTA_CALCOLO_ANOMALIA' ) == '' && statoFunzionale == 'VERIFICA_AMMINISTRATIVA')  //getObjValue( 'val_StatoFunzionale' ) == 'VERIFICA_AMMINISTRATIVA' )
	{
		var bStopAnomalia = 0;
		
		try
		{
			var totOfferte = getNumeroOfferte();
			var dataInvioGara = getObjValue('DataInvioGara');
			var criterioAggiudGara = getObjValue('val_CriterioAggiudicazioneGara');
			
			// All'apertura della PDA l'avvio automatico del documento CRITERIO_CALCOLO_ANOMALIA non va fatto nel caso in cui 
			// la data invio bando è >= al 20-05-2017, il numero delle offerte valide ricevute è inferiore a 5 e la gara è al prezzo.
			//if ( dataInvioGara >= '2017-05-20T00:00:00' && totOfferte < 5 && criterioAggiudGara == '15531' )
			if ( dataInvioGara >= '2017-05-20T00:00:00' && totOfferte < 5  ) 
				bStopAnomalia = 1;
			
			// il DL 32/2019 ha tolto la scelta delgi algoritmi dal 18 aprile 2019
			if( dataInvioGara >= '2019-04-19T00:00:00')	
				bStopAnomalia = 1;

		}
		catch(e)
		{
			//alert('errore nel recupero informazioni per la gestione dell\'anomalia post articolo 97');
		}

		if ( bStopAnomalia == 0 )
			LocalMakeDocFrom ('CRITERIO_CALCOLO_ANOMALIA##PDA_MICROLOTTI');
		else
			OnLoadPage();
	}
	else
	{
		OnLoadPage();
	}
	
	try{ rimuovi_OpenOfferta_Allegati(); } catch(e){};
}





function OnLoadPage()
{

    var statoFunzionale = '';

    try {
        statoFunzionale = getObjValue('StatoFunzionale');
    }
    catch (e) {
        statoFunzionale = getObjValue('val_StatoFunzionale');
    }


	var tipoSedutaGara = '';

	try
	{
        tipoSedutaGara = getObjValue('TipoSedutaGara');
        if (tipoSedutaGara != 'virtuale') {
            
            $("#cap_StatoSeduta").parents("table:first").css({ "display": "none" });
        }
        else
        {

            var StatoChat = getObj( 'RCHAT_MODEL_StatoChat' ).value;
            
            //-- attivo la chat per la seduta virtuale
            DOC_CHAT_Room =  getObj( 'IDDOC' ).value;


            //var messaggioChat = getObj('AF_CHAT_MSG_DOC');
            //var bottoneChat = getObj('AF_CHAT_BUTTON_DOC');
        
            //if(messaggioChat != null && bottoneChat != null)
            {
                //messaggioChat.style.display = '';
                //bottoneChat.style.display = '';
                if(statoFunzionale=='Chiuso' || StatoChat != 'OPEN' )
                //if( StatoChat == 'OLD' )
                {
                    //messaggioChat.style.display = 'none';
                    //bottoneChat.style.display = 'none';
                    
                    //-- se la chat è chiusa visualizzo il contenuto solo una volta
                    DOC_CHAT_UpdateWin();
                                        
                }
                else
                {
                    //-- se la conversazione è aperta aggiorno il contenuto della chat ogni TOT secondi
                    window.setInterval ( DOC_CHAT_UpdateWin ,CHAT_TimeRefresh );

                }

            }
            
            
        
        }	
	}
	catch(e)
	{
	}
    
     
	
    
	var CriterioAggiudicazioneGara; 
	var num_criteri_eco='';
	try{ num_criteri_eco = getObjValue( 'num_criteri_eco' ); }catch(e){ num_criteri_eco = ''; };
	try{ ValutazioneSoggettiva = getObjValue( 'ValutazioneSoggettiva' ); }catch(e){ ValutazioneSoggettiva = ''; };
	
	try{
		CriterioAggiudicazioneGara = getObjValue( 'CriterioAggiudicazioneGara' );
	}catch(e){
		CriterioAggiudicazioneGara = getObjValue( ' CriterioAggiudicazioneGara' );
	}
	
	
	if ( VersionePrint == 1 ){
		
		ShowCol( 'OFFERTE' , 'Selezione' , 'none' );
		ShowCol( 'OFFERTE' , 'FNZ_ADD' , 'none' );
		ShowCol( 'OFFERTE' , 'FNZ_OPEN' , 'none' );
		
		ShowCol( 'SEDUTE' , 'FNZ_OPEN' , 'none' );
		
		
		try{
			ShowCol( 'RIEPILOGO_FINALE' , 'FNZ_OPEN' , 'none' );
		}catch(e){}
		
		
		try{
			ShowCol( 'OFFERTE_ECO' , 'Selezione2' , 'none' );
			ShowCol( 'OFFERTE_ECO' , 'FNZ_OPEN' , 'none' );
		}catch(e){}
		
		ShowCol( 'LISTA_DOCUMENTI' , 'FNZ_OPEN' , 'none' );
		
		
		try{
			ShowCol( 'OFFERTE_TEC' , 'Selezione' , 'none' );
			ShowCol( 'OFFERTE_TEC' , 'FNZ_OPEN' , 'none' );
			ShowCol( 'OFFERTE_TEC' , 'FNZ_CONTROLLI' , 'none' );
			
		}catch(e){}
		
	}
	
	
	
	var strStatoRiga = '';
	
	try
	{
		strStatoRiga = getObjValue('val_RRIEPILOGO_MONOLOTTO_MODEL_StatoRiga');
	}
	catch(e)
	{
	}
	
	
	/*
	if( CriterioAggiudicazioneGara  != '15532' && CriterioAggiudicazioneGara != '25532' ) //-- economicamente vantaggiosa e costo fisso 
	{
		try
		{
			ShowCol( 'OFFERTE_ECO' , 'ValoreOfferta' , 'none' );
		}
		catch(e){}
		
		try
		{
			ShowCol( 'OFFERTE_ECO' , 'PunteggioTecnico' , 'none' );
		}
		catch(e){}
		
		try
		{
			ShowCol( 'OFFERTE_ECO' , 'PunteggioEconomico' , 'none' );
		}
		catch(e){}
		
	}
	 //se è al costo fisso nascondo  le colonne scheda valutazione,punteggio tecnico,punteggio economico
	if( CriterioAggiudicazioneGara  == '25532' )
	{
		ShowCol( 'OFFERTE_ECO' , 'FNZ_CONTROLLI' , 'none' );
		ShowCol( 'OFFERTE_ECO' , 'PunteggioTecnico' , 'none' );
		ShowCol( 'OFFERTE_ECO' , 'PunteggioEconomico' , 'none' );
	}
	  
	
	 /*
	
	
  
																		 
  
		 
  
  
 
	if( CriterioAggiudicazioneGara  != '15532' && CriterioAggiudicazioneGara != '25532' ) //-- economicamente vantaggiosa e costo fisso 
	{
	 
   
		ShowCol( 'OFFERTE_ECO' , 'ValoreOfferta' , 'none' );
   
			
  
	 
   
		ShowCol( 'OFFERTE_ECO' , 'PunteggioTecnico' , 'none' );
   
			
  
	 
   
		ShowCol( 'OFFERTE_ECO' , 'PunteggioEconomico' , 'none' );
   
			
		
	}
    
	 //se è al costo fisso nascondo  le colonne scheda valutazione,punteggio tecnico,punteggio economico
	if( CriterioAggiudicazioneGara  == '25532' )
	{
		ShowCol( 'OFFERTE_ECO' , 'FNZ_CONTROLLI' , 'none' );
		ShowCol( 'OFFERTE_ECO' , 'PunteggioTecnico' , 'none' );
		ShowCol( 'OFFERTE_ECO' , 'PunteggioEconomico' , 'none' );
	}
    
    */


    //--se è al prezzo nascondo colonne punteggio
     if ( CriterioAggiudicazioneGara == '15531' )
    {
      ShowCol( 'OFFERTE_ECO' , 'PunteggioTecnico' , 'none' );
      ShowCol( 'OFFERTE_ECO' , 'PunteggioEconomico' , 'none' );
	  
	  //--se è al prezzo ed ho un solo criterio economico e non si è scelta una valutazione soggettiva nasconodo anche la colonna del punteggio e Scheda Valutazione
		if (num_criteri_eco == '1' && ValutazioneSoggettiva == '0')
		{
			ShowCol( 'OFFERTE_ECO' , 'FNZ_CONTROLLI' , 'none' );
			ShowCol( 'OFFERTE_ECO' , 'ValoreOfferta' , 'none' );
		}
    }

    //se è al costo fisso nascondo  le colonne scheda valutazione,punteggio tecnico,punteggio economico
	if ( CriterioAggiudicazioneGara == '25532' )
	{
		ShowCol( 'OFFERTE_ECO' , 'FNZ_CONTROLLI' , 'none' );
		ShowCol( 'OFFERTE_ECO' , 'PunteggioTecnico' , 'none' );
		ShowCol( 'OFFERTE_ECO' , 'PunteggioEconomico' , 'none' );
		ShowCol( 'OFFERTE_ECO' , 'ValoreImportoLotto' , 'none' );
		ShowCol( 'OFFERTE_ECO' , 'ValoreSconto' , 'none' );
        
		ShowCol( 'OFFERTE_ECO' , 'PunteggioEconomicoAssegnato' , 'none' );        

	}
	
    //-- al prezzo più alto
    if ( CriterioAggiudicazioneGara == '16291' )
	{
		ShowCol( 'OFFERTE_ECO' , 'PunteggioTecnico' , 'none' );
		ShowCol( 'OFFERTE_ECO' , 'PunteggioEconomico' , 'none' );
		ShowCol( 'OFFERTE_ECO' , 'ValoreImportoLotto' , 'none' );    
		//se un solo criterio nascondiamo il punteggio altrimenti nascondo la percentuale
		if ( num_criteri_eco == '1' && getObjValue('val_CriterioFormulazioneOfferte') == '15537' )
		{
			ShowCol( 'OFFERTE_ECO' , 'ValoreOfferta' , 'none' );
		}
		else
		{
			ShowCol( 'OFFERTE_ECO' , 'ValoreSconto' , 'none' );
		}  		


		
		
	}
	
	
	try{ var concessione = getObjValue( 'Concessione' ); }catch(e){ concessione = ''; };
	
	if ( concessione == 'si' )
	{
		try 
		{
			ShowCol( 'OFFERTE_ECO' , 'ValoreImportoLotto' , 'none' ); 	
			
		}catch(e){}
		
		try 
		{
			ShowCol( 'LISTA_BUSTE' , 'ValoreImportoLotto' , 'none' );	
		}catch(e){}
	}
	
    
	
	var conformita ;
	
	try{
		conformita = getObjValue( 'Conformita' );
	}catch(e){
		conformita = getObjValue( ' Conformita' );
	}
	
	
	var Divisione_lotti=getObjValue( 'Divisione_lotti' );
	
	if (Divisione_lotti=='0' && conformita =='Ex-Ante' )
	{
		ShowCol( 'OFFERTE_TEC' , 'PunteggioTecnico' , 'none' );
		ShowCol( 'OFFERTE_TEC' , 'FNZ_CONTROLLI' , 'none' );

        ShowCol( 'OFFERTE_TEC' , 'PunteggioTecnicoAssegnato' , 'none' );
        ShowCol( 'OFFERTE_TEC' , 'PunteggioTecnicoRiparCriterio' , 'none' );
        ShowCol( 'OFFERTE_TEC' , 'PunteggioTecnicoRiparTotale' , 'none' );

	}

	//Nel caso in cui per il lotto la valutazione è al prezzo e NON è economicamente vantaggiosa E NON E' COSTO FISSO si nasconde la colonna per la valutazione
	// e se lo statoriga non è Valutato o ValutatoECO
	if ( 
			//( getObjValue('val_CriterioAggiudicazioneGara') != '15532' && getObjValue('val_CriterioAggiudicazioneGara') != '25532' ) 
			//	|| 
			//( strStatoRiga != 'Valutato' && strStatoRiga != 'ValutatoECO' && strStatoRiga != 'Completo' 
			
			getObjValue('val_CriterioAggiudicazioneGara') == '25532'
			
			 
		)
	{
		try
		{
			ShowCol( 'OFFERTE_ECO' , 'FNZ_CONTROLLI' , 'none' );
		}
		catch(e)
		{
		}
	}
	
	//-- nascondo le colonne dei punteggi riparametrati in coerenza con il criterio scelto
	var PUNTEGGI_ORIGINALI = getObjValue( 'PUNTEGGI_ORIGINALI' );
	var PunteggioTEC_TipoRip ; 
	try{
		PunteggioTEC_TipoRip = getObjValue( 'PunteggioTEC_TipoRip' );
	}catch(e){
		PunteggioTEC_TipoRip = getObjValue( ' PunteggioTEC_TipoRip' );
	}
	
	var PunteggioECO_TipoRip ; 	
	try{
		PunteggioECO_TipoRip = getObjValue( 'PunteggioECO_TipoRip' );
	}catch(e){
		PunteggioECO_TipoRip = getObjValue( ' PunteggioECO_TipoRip' );
	}
	
	var PunteggioTEC_100 ; 
	try{
		PunteggioTEC_100 = getObjValue( 'PunteggioTEC_100' );
	}catch(e){
		PunteggioTEC_100 = getObjValue( ' PunteggioTEC_100' );
	}
    
	if (Divisione_lotti=='0' )
	{
		if( PunteggioTEC_100 == '0'  )
		{
			//try{ ShowCol( 'OFFERTE_TEC' , 'PunteggioTecnicoAssegnato' , 'none' ); }catch(e){}
			try{ ShowCol( 'OFFERTE_TEC' , 'PunteggioTecnicoRiparCriterio' , 'none' ); }catch(e){}
			try{ ShowCol( 'OFFERTE_TEC' , 'PunteggioTecnicoRiparTotale' , 'none' ); }catch(e){}

		}
		else
		{
			//SE LA PROPRIETA' NON RICHIEDE LA VISUALIZZAZIONE DEI PUNTEGGI ORIGINALI NASCONDO LA COLONNA
			if ( PUNTEGGI_ORIGINALI != 'YES' )
			{
				ShowCol( 'OFFERTE_TEC' , 'PunteggioTecnicoAssegnato' , 'none' );
			}
			if ( PunteggioTEC_TipoRip == '1' ) //-- solo lotto
			{
				ShowCol( 'OFFERTE_TEC' , 'PunteggioTecnicoRiparCriterio' , 'none' );	
			}
			if ( PunteggioTEC_TipoRip == '2'  ) //-- solo criterio
			{
				ShowCol( 'OFFERTE_TEC' , 'PunteggioTecnicoRiparTotale' , 'none' );
			}
		}
		//SE NON CI STA LA RIPAREMETRAZIONE ECONOMICA OPPURE SE LA PROPRIETA' NON RICHIEDE LA VISUALIZZAZIONE DEI PUNTEGGI ORIGINALI NASCONDO LA COLONNA
		
		
		if ( PunteggioECO_TipoRip == 'No' || PunteggioECO_TipoRip == '')
			ShowCol( 'OFFERTE_ECO' , 'PunteggioEconomicoAssegnato' , 'none' );  
		else if  ( PUNTEGGI_ORIGINALI != 'YES' )
			ShowCol( 'OFFERTE_ECO' , 'PunteggioEconomicoAssegnato' , 'none' );  
		
	}
	
	if ( getObj('TipoAggiudicazione') )
	{
		var TipoAggiudicazione = getObjValue('TipoAggiudicazione');
		
		if ( TipoAggiudicazione != 'multifornitore' )
		{
			try{ShowCol( 'OFFERTE_ECO' , 'PercAgg' , 'none' );}catch(e){}
		}

	}
	
	//-- cerco di ripristinare una selezione precedente
	try{
		if ( getCookie('PDA_MICROLOTTI_IDDOC') == getObj( 'IDDOC' ).value )
		{
			var Sel;
			var idx;
			try{
				Sel = document.getElementsByName('Selezione');//getObj( 'Selezione');
				idx = getCookie('PDA_MICROLOTTI_SELEZIONE');
				Sel[idx].checked = true;
			}catch(e){}
			
			try{
				Sel = document.getElementsByName('Selezione2');//getObj( 'Selezione');
				idx = getCookie('PDA_MICROLOTTI_SELEZIONE_2');
				Sel[idx].checked = true;
			}catch(e){}
		}
		
	}catch(e){}
	
	//-- associo la funzione di onchange per conservare la selezione del radio button
	$('input[type="radio"]').on('change',OnChangeSelezione );
	
	
	sedute_di_gara();
	
	//SE PERCENTUALE MOSTRA LA COLONNA VALORESCONTO 
	if (getObjValue('val_CriterioFormulazioneOfferte') == '15537')
	{
		ShowCol( 'OFFERTE_ECO' , 'ValoreImportoLotto' , 'none' ); 	
	}
	else
	{
		ShowCol( 'OFFERTE_ECO' , 'ValoreSconto' , 'none' ); 	
	}
	
	
	var AttivaFilePending = getObj('AttivaFilePending');
	
	/* SE IL CAMPO ESISTE */
	if ( AttivaFilePending )
	{
		//Se non è richiesta la verifica pending dei file nascondiamo la colonna statoFirma
		if (AttivaFilePending.value != 'si' )
		{
			try
			{
				ShowCol('OFFERTE_ECO', 'Stato_Firma_PDA_AMM', 'none');
			}
			catch(e){}
		}
	}
}

function StoreSelection()
{
	try{
		var Selezione = document.getElementsByName('Selezione');
		var Selezione2 = document.getElementsByName('Selezione2');
		
		//-- recupera la riga selezionata
		//var indRow = getCheckedValueRow( Selezione ); 	
		var indRow = getIdRowChecked( Selezione ); 	
		var indRow2 = getIdRowChecked( Selezione2 ); 	
		
		//-- la memorizzo nel cooky
		setCookie2('PDA_MICROLOTTI_IDDOC', getObj( 'IDDOC' ).value  );
		setCookie2('PDA_MICROLOTTI_SELEZIONE', indRow );
		setCookie2('PDA_MICROLOTTI_SELEZIONE_2', indRow2 );
		
	}catch(e){}
}

function OnChangeSelezione ( e ) 
{
	if ( e.type == 'change' && ( e.target.id == 'Selezione' || e.target.id == 'Selezione2' ) )
		StoreSelection();
	else 
		return false;	
}

function OFFERTE_OnLoad()
{

	
	//-- aggiungo un evento di onchange per la selezione dell'offerta
	$('input[type="radio"]').on('change',OnChangeSelezione );
	/*
	$('input[type="radio"]').on('change', function(e) {
				if ( e.type == 'change' && e.target.id == 'Selezione' )
					StoreSelection();
				else 
					return false;
				
		});	
	*/
	DisplaySection();
    	
    AUTO_CheckOfferta();	
	
	
    
}
//function OFFERTE_AFTER_COMMAND( param )
//{
//    AUTO_CheckOfferta();
//}

function AUTO_CheckOfferta()
{
    //-- determino che riga selezionare
    for( i = OFFERTEGrid_StartRow ; i <= OFFERTEGrid_EndRow ; i++ )
    {
        //-- se trovo almeno una busta non letta devo controllare sulla busta documentazione
        if ( getObjValue( 'val_R' + ( i ) + '_bReadDocumentazione' ) == '1' )
        {
            i--;
            if(  i < 0 ) i = 0;
				document.getElementsByName('Selezione')[i].checked = true;
            //getObj( 'Selezione')[i].checked = true;
            return;
        }
    }
    
    for( i = OFFERTEGrid_StartRow ; i <= OFFERTEGrid_EndRow ; i++ )
    {
        //-- se trovo almeno una busta non letta devo controllare sulla busta documentazione
        if ( getObjValue( 'val_R' + ( i ) + '_bReadEconomica' ) == '1' )
        {
            i--;
            if(  i < 0 ) i = 0;
				document.getElementsByName('Selezione')[i].checked = true;
            //getObj( 'Selezione')[i].checked = true;
            return;
        }
    }
}



function DrillMotivazioniTec( objGrid , Row , c )
{
    var idRow = getObjValue( 'ROFFERTE_TECGrid_' + Row +  '_idRow' );
    var w;
    var h;
    var Left;
    var Top;
    var altro;

    w = screen.availWidth * 0.5;
    h = screen.availHeight  * 0.4;
    Left= (screen.availWidth - w) / 2;
    Top= (screen.availHeight - h ) / 2;


    //apro la lista  delle motivazioni
    var strURL='Viewer.asp?lo=base&TOOLBAR=PDA_LISTA_MOTIVAZIONE_ESITI_TOOLBAR&Table=PDA_LISTA_MOTIVAZIONE_ESITI_LOTTO&ModGriglia=PDA_LISTA_MOTIVAZIONE_ESITIGriglia&JSCRIPT=&IDENTITY=Id&DOCUMENT=ESITO&PATHTOOLBAR=../customdoc/&AreaAdd=no&Caption=Lista Motivazioni di Esito&Height=0,100*,0&numRowForPag=20&Sort=DataInvio&SortOrder=desc&Exit=si&FilterHide=LinkedDoc=' + idRow  ;
    //ExecFunction(  strURL , 'ListaEsito'  , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h + altro );
    OpenViewer( strURL );
  
}

function DrillAnomalie( objGrid , Row , c )
{
    var idRow = getObjValue( 'R' + Row +  '_idRow' );
    var w;
    var h;
    var Left;
    var Top;
    var altro;
    
    
    
    //se ci sono anomalie apro il doc di riepilog
    //R2_Warning_V
    //alert( getObj( 'R' + Row +  '_Warning' ) );
    
    ShowDocument( 'PDA_RIEPILOGO_ANOMALIE' , idRow );
    
}

function DrillMotivazioniEco( objGrid , Row , c )
{
    var idRow = getObjValue( 'ROFFERTE_ECOGrid_' + Row +  '_IdOffertaLotto' );
    var w;
    var h;
    var Left;
    var Top;
    var altro;

    w = screen.availWidth * 0.5;
    h = screen.availHeight  * 0.4;
    Left= (screen.availWidth - w) / 2;
    Top= (screen.availHeight - h ) / 2;


    //apro la lista  delle motivazioni
    var strURL='Viewer.asp?lo=base&ModGriglia=PDA_LISTA_MOTIVAZIONE_ESITIGriglia&TOOLBAR=PDA_LISTA_MOTIVAZIONE_ESITI_TOOLBAR&Table=PDA_LISTA_AZIONI_LOTTO&JSCRIPT=&IDENTITY=Id&DOCUMENT=DECADENZA&PATHTOOLBAR=../customdoc/&AreaAdd=no&Caption=Lista documenti&Height=0,100*,0&numRowForPag=20&Sort=DataInvio&SortOrder=desc&Exit=si&FilterHide=LinkedDoc=' + idRow  ;
    //ExecFunction(  strURL , 'ListaEsito'  , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h + altro );
    OpenViewer( strURL );
  
}

function OpenSchedaTec( objGrid , Row , c )
{
    LocalMakeDocFrom( 'PDA_VALUTA_LOTTO_TEC#900,800#LOTTO#' + getObjValue( 'ROFFERTE_TECGrid_' + Row  + '_idRow' ) );
}

function OpenSchedaEco( objGrid , Row , c )
{
    LocalMakeDocFrom( 'PDA_VALUTA_LOTTO_ECO#900,800#LOTTO#' + getObjValue( 'OFFERTE_ECOGrid_idRow_' + Row ) );
}

function EsitoTec( stato )
{


    var Selezione = document.getElementsByName('Selezione');
    
    //-- recupera la riga selezionata
    var indRow = getCheckedValueRow( Selezione ); 
    
      
    if( indRow  == '' ) 
    {
        alert(  CNV( '../../' ,  'E\' necessario selezionare prima una riga' ));
        return; 
    }
    
    //-- verifica se lo stato richiesto è ammissibile
    var StatoPDA = getObjValue( 'val_R' + indRow +  '_StatoRiga' );
    var idRow = getObjValue( 'R' + indRow +  '_idRow' );
    
    //-- se viene richiesta l'esclusione lo stato di partenza puo essere:in verifica o davalutare
    if( stato == 'escluso' && ( StatoPDA == 'daValutare' || StatoPDA == 'inVerifica' ) )
    {
        DOC_NewDocumentFrom( 'ESITO_LOTTO_ESCLUSA#LOTTO,' + idRow + '#800,600##&UpdateParentX=no' );
        return;
    }

    //-- se viene richiesta la verifica lo stato di partenza puo essere:daValutare
    if( stato == 'inVerifica' && ( StatoPDA == 'daValutare'  ) )
    {
        DOC_NewDocumentFrom( 'ESITO_LOTTO_VERIFICA#LOTTO,' + idRow + '#800,600##&UpdateParentX=no' );
        return;
    }
  

    //-- se viene richiesta l'annullamento lo stato di partenza non puo essere da valutare
    if( stato == 'annulla' && ( StatoPDA != 'daValutare' ) )
    {
        DOC_NewDocumentFrom( 'ESITO_LOTTO_ANNULLA#LOTTO,' + idRow + '#800,600##&UpdateParentX=no' );
        return;
    }

     //-- se viene richiesta l'ammissione / conformità lo stato puo essere : daValutare o in verifica
    if( stato == 'Conforme' && ( StatoPDA == 'daValutare'  || StatoPDA == 'inVerifica' ) )
    {
    
        DOC_NewDocumentFrom( 'ESITO_LOTTO_AMMESSA#LOTTO,' + idRow + '#800,600##&UpdateParentX=no' );
        return;
    }

 
    alert(  CNV( '../../' ,  'Il cambiamento richiesto non è coerente con lo stato del documento' ));
	
}


function EsitoECO( stato )
{
/*
	if( getObjValue( 'RRIEPILOGO_MONOLOTTO_MODEL_StatoRiga' ) != 'Valutato' && getObjValue( 'RRIEPILOGO_MONOLOTTO_MODEL_StatoRiga' ) != 'Completo' )
	{
        alert(  CNV( '../../' ,  'Il cambiamento richiesto non e\' coerente con lo stato del documento' ));
        return; 
	}
*/


    var Selezione = document.getElementsByName('Selezione2');
    
    //-- recupera la riga selezionata
    var indRow = getCheckedValueRow( Selezione );   
    if( indRow  == '' ) 
    {
        alert(  CNV( '../../' ,  'E\' necessario selezionare prima una riga' ));
        return; 
    }
    
	
    //-- verifica se lo stato richiesto è ammissibile
    var StatoPDA = getObjValue( 'val_R' + indRow +  '_StatoRiga' );
    var idRow = getObjValue( 'R' + indRow +  '_id' );
    
    //-- se viene richiesta l'esclusione lo stato di partenza puo essere:in verifica o davalutare
    if( stato == 'escluso' && ( StatoPDA == 'Valutato' || StatoPDA == 'inVerificaEco' ) )
    {
        DOC_NewDocumentFrom( 'ESITO_ECO_LOTTO_ESCLUSA#LOTTO,' + idRow + '#800,600##&UpdateParentX=no' );
        return;
    }

    //-- se viene richiesta la verifica lo stato di partenza puo essere:daValutare
    if( stato == 'inVerifica' && ( StatoPDA == 'Valutato'  ) )
    {
        DOC_NewDocumentFrom( 'ESITO_ECO_LOTTO_VERIFICA#LOTTO,' + idRow + '#800,600##&UpdateParentX=no' );
        return;
    }
  

    //-- se viene richiesta l'annullamento lo stato di partenza non puo essere da valutare
    if( stato == 'annulla' && ( StatoPDA != 'Valutato' ) )
    {
        DOC_NewDocumentFrom( 'ESITO_ECO_LOTTO_ANNULLA#LOTTO,' + idRow + '#800,600##&UpdateParentX=no' );
        return;
    }

     //-- se viene richiesta l'ammissione / conformità lo stato puo essere : daValutare o in verifica
    if( stato == 'VerificaSuperata' && (  StatoPDA == 'inVerificaEco' ) )
    {
    
        DOC_NewDocumentFrom( 'ESITO_ECO_LOTTO_AMMESSA#LOTTO,' + idRow + '#800,600##&UpdateParentX=no' );
        return;
    }

 
    alert(  CNV( '../../' ,  'Il cambiamento richiesto non e\' coerente con lo stato del documento' ));
	
}




function DrillMotivazioni( objGrid , Row , c )
{
    var idRow = getObjValue( 'R' + Row +  '_idRow' );
    var w;
    var h;
    var Left;
    var Top;
    var altro;

    w = screen.availWidth * 0.5;
    h = screen.availHeight  * 0.4;
    Left= (screen.availWidth - w) / 2;
    Top= (screen.availHeight - h ) / 2;


    //apro la lista  delle motivazioni
    var strURL='Viewer.asp?lo=base&TOOLBAR=PDA_LISTA_MOTIVAZIONE_ESITI_TOOLBAR&Table=PDA_LISTA_MOTIVAZIONE_ESITI&JSCRIPT=&IDENTITY=Id&DOCUMENT=ESITO&PATHTOOLBAR=../customdoc/&AreaAdd=no&Caption=Lista Motivazioni di Esito&Height=0,100*,0&numRowForPag=20&Sort=DataInvio&SortOrder=desc&Exit=si&FilterHide=LinkedDoc=' + idRow  ;
    //ExecFunction(  strURL , 'ListaEsito'  , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h + altro );
    OpenViewer( strURL );
}

function DrillPosizionamento( objGrid , Row , c )
{
    
	//-- recupero il codice della riga passata
    //var idRow = getObjValue( 'R' + Row +  '_idRow' );
	//ShowDocument( 'PDA_DRILL_OFFERTE' , idRow );
	
	ShowDocumentFromAttrib( 'PDA_DRILL_OFFERTE,R' + Row +  '_idRow,800,650' );

}





function OpenOfferta( objGrid , Row , c )
{

//DOCUMENTAZIONE
//ECONOMICA

    var Busta = '_bReadEconomica';
    var BustaName = 'MicroLotti'; //'ECONOMICA';
    
    
    if( getObjValue( 'val_R' + ( Row  ) + '_StatoPDA' ) == '99' )
	{
		alert( CNV( '../../' , 'Non e\' possibile aprire documenti invalidati' ));
		return;
	}
//    //-- determino se controlloare sulla documentazioe o sulla busta ecnomica
//    for( i = OFFERTEGrid_StartRow ; i <= OFFERTEGrid_EndRow ; i++ )
//    {
//        //-- se trovo almeno una busta non letta devo controllare sulla busta documentazione
//        if ( getObjValue( 'val_R' + ( Row ) + '_bReadDocumentazione' ) == '1' )
//        {
//            Busta = '_bReadDocumentazione';
//            BustaName = 'DOCUMENTAZIONE';
//        }
//    }

    if( c == 1 )
    {
        Busta = '_bReadDocumentazione';
        BustaName = 'DOCUMENTAZIONE';
    }
    
    //-- per aprire la busta di documentazionelo stato deve essere valuatzione economica
    if( BustaName == 'MicroLotti' )
    {
		var stFunzionale;
		
		try
		{
			stFunzionale = getObjValue('StatoFunzionale');
		}
		catch(e)
		{
			stFunzionale = getObjValue( 'val_StatoFunzionale' );
		}
	
        if( stFunzionale == 'VERIFICA_AMMINISTRATIVA' )
        {
            alert( CNV( '../../' , 'Non e\' possibile aprire il documento, e\' necessario avviare la valutazione economica' ));
            return;
        }
    
    }
    

    getObj( 'Valutazione_griglia_SECTION_TO_OPEN' ).value = BustaName;
    //-- controlla se il documuento che si vuole aprire è quello corretto
    if ( Row > 0 )
    {
		var ix = 1;
		
        //-- risale sul primo documento valido
		while( Row - ix >= 0 && (  getObjValue( 'val_R' + ( Row - ix ) + '_StatoPDA' ) == '99' || getObjValue( 'val_R' + ( Row - ix ) + '_StatoPDA' ) == '999' || getObjValue( 'val_R' + ( Row - ix ) + '_StatoPDA' ) == '1' ) )
		{
			ix++; 
		}
		
        //-- se non ha aperto il documento precedente esce con errore
		if (  Row - ix >= 0 && getObjValue( 'val_R' + ( Row - ix ) + Busta ) == '1' )
        {
            alert( CNV( '../../' , 'Non e\' possibile aprire il documento, non e\' nella giusta sequenza' ));
            return;
        }
    }
    
    //-- se il documento è stato escluso posso riaprire la busta solo se era già aperta
    if( getObjValue( 'val_R' + ( Row  ) + '_StatoPDA' ) == '1' && getObjValue( 'val_R' + ( Row  ) + Busta ) == '1' )
	{
		alert( CNV( '../../' , 'Non e\' possibile aprire documenti esclusi' ));
		return;
	}
	
	
	//-- prende l'ID del documento
	if( getObjValue( 'val_R' + ( Row  ) + '_StatoPDA' ) == '999' )
	{    
		var idMsg =  getObjValue( 'R' + Row  + '_id_ritira_offerta' );
		var TipoDoc =  'RITIRA_OFFERTA';
		
	}
	else
	{
		var idMsg =  getObjValue( 'R' + Row  + '_idMsg' );
		var TipoDoc =  getObjValue( 'R' + Row  + '_TipoDoc' );
	}
	
	

	//-- mette la spunta sulla riga dell'offerta che si sta aprendo
    try
    {
		var Sel = document.getElementsByName('Selezione');
		Sel[Row].checked = true;
		StoreSelection();
    }catch(e){};		
    

	
    //-- apre il documento
    if( TipoDoc == '' )
        OpenAnyDoc( idMsg , '' , '../' );
    else 
	{
        if( getObjValue( 'val_R' + ( Row  ) + '_StatoPDA' ) == '999' )		 	
			ShowDocumentFromAttrib( TipoDoc + ',' +  'R' + Row  + '_id_ritira_offerta' );
		else
		{
			if ( BustaName == 'DOCUMENTAZIONE')
				ShowDocumentFromAttrib( TipoDoc+ '#&CUR_FLD_SELECTED_ON_DOC=FLD_BUSTA_DOCUMENTAZIONE' + ',' +  'R' + Row  + '_idMsg' );
			else
				ShowDocumentFromAttrib( TipoDoc + ',' +  'R' + Row  + '_idMsg' );
		
			//-- imposta come aperta la busta del documento
			getObj( 'val_R' + Row + Busta ).innerHTML = '<img border="0" src="../images/Domain/bread0.gif" >';
			SetProperty(getObj( 'val_R' + Row + Busta ), 'value', '0' );
		}
			
	}	
        


}

function OpenOffertaTec( objGrid , Row , c )
{

	//-- mette la spunta sulla riga dell'offerta che si sta aprendo
    try
    {
		var Sel = document.getElementsByName('Selezione');
		var indRow = getRadioOfValue(Sel , 'OFFERTE_TECGrid_' + Row )
		Sel[indRow].checked = true;
		StoreSelection();
    }catch(e){};		
    

	
	//AGGIUNTA LA CHIAMATA ALLA STORED PER INTERCETTARE LA RICHIESTA ESPLICITA DI APERTURA BUSTA
    LocalMakeDocFrom( 'OFFERTA#900,800#BUSTA_TEC#' + getObjValue('ROFFERTE_TECGrid_' + Row  + '_idMsg') );
	
	/*
	var TipoDoc =  'OFFERTA#&CUR_FLD_SELECTED_ON_DOC=FLD_BUSTA_TECNICA'
    ShowDocumentFromAttrib( TipoDoc + ',' +  'ROFFERTE_TECGrid_' + Row  + '_idMsg' );
        
        
    //-- imposta come aperta la busta del documento
    getObj( 'val_ROFFERTE_TECGrid_' + Row + '_bReadDocumentazione' ).innerHTML = '<img border="0" src="../images/Domain/bread0.gif" >';
	*/


}



function OpenBustaEco( objGrid , Row , c )
{
	//-- mette la spunta sulla riga dell'offerta che si sta aprendo
    try
    {
		var Sel = document.getElementsByName('Selezione2');
		Sel[Row].checked = true;
		StoreSelection();
    }catch(e){};		
    
    
	//AGGIUNTA LA CHIAMATA ALLA STORED PER INTERCETTARE LA RICHIESTA ESPLICITA DI APERTURA BUSTA
    LocalMakeDocFrom( 'OFFERTA#900,800#BUSTA_ECO#' + getObjValue('ROFFERTE_ECOGrid_' + Row  + '_idMsg') );
	/*
	var TipoDoc =  'OFFERTA#&CUR_FLD_SELECTED_ON_DOC=FLD_BUSTA_ECONOMICA'
    ShowDocumentFromAttrib( TipoDoc + ',' +  'ROFFERTE_ECOGrid_' + Row  + '_idMsg' );
        
        
    //-- imposta come aperta la busta del documento
    getObj( 'val_ROFFERTE_ECOGrid_' + Row + '_bReadEconomica' ).innerHTML = '<img border="0" src="../images/Domain/bread0.gif" >';
	*/

}


function riammettiOfferta( )
{
	var Selezione = document.getElementsByName('Selezione');
    
    //-- recupera la riga selezionata
    var indRow = getCheckedValue( Selezione );
	
    if ( indRow == '' )
	{
		alert(  CNV( '../../' ,  'E\' necessario selezionare prima una riga' ) );
		return;
    }

	var StatoPDA = getObjValue( 'val_R' + indRow +  '_StatoPDA' );
    var idRow = getObjValue( 'R' + indRow +  '_idRow' );

	//if( StatoPDA == '1' )
    //{
		LocalMakeDocFrom( 'ESITO_RIAMMISSIONE#900,800#RIGA_PDA#' + idRow );
		return;
	//}
	//else
	//{
	//	alert(  CNV( '../../' ,  'Per riammettere un offerta deve essere prima esclusa' ) );
	//	return;
	//}

}

function Esito( stato , Descrizione )
{
	ShowWorkInProgress( true );
	
	setTimeout(function()
		{ 
			EsitoDelay( stato , Descrizione  ); 
		}, 1 );
	
}

function EsitoDelay( stato , Descrizione )
{

  //-- posiziona la scheda di valutazione
	//DocShowFolder( 'FLD_OFF' );
	//tdoc();

    var Selezione = document.getElementsByName('Selezione');
    
    //-- recupera la riga selezionata
    var indRow = getCheckedValue( Selezione );   
    if ( indRow == '' )
	{
		ShowWorkInProgress( false );
		alert(  CNV( '../../' ,  'E\' necessario selezionare prima una riga' ) );
		return;
    }
  
    
    //prima di innescare un esito verifico se richiestacampionatura=si se ho terminato la fase di verifica campioni
    var RichiestaCampionatura = getObjValue( 'val_RichiestaCampionatura' );
    
	var proceduraGara = '';
	var TipoBandoGara = '';
	
	if ( getObj('ProceduraGara') )
	{
		proceduraGara = getObjValue('ProceduraGara');
	}
	
	if ( getObj('TipoBandoGara') ) 
	{
		TipoBandoGara = getObjValue('TipoBandoGara');
	}

	
	var VerificaCampionatura = getExtraAttrib( 'val_R' + indRow +  '_VerificaCampionatura' , 'value' );
	
	//NELLA PREQUALIFICA NON SERVE IL CONTROLLO DELLA CAMPIONATURA NON CI SONO I LOTTI
	//if ( TipoBandoGara != '2' && proceduraGara  != '15477' ){
	//SE NON STO FACENDO ANNULLA ESITO 
	if ( stato != '8' ){
		
		if ( !( TipoBandoGara == '2' && proceduraGara  == '15477' ) )
		{
		
			if ( RichiestaCampionatura == '1' )
			{
			  
				if (VerificaCampionatura == '')
				{
					ShowWorkInProgress( false );
				  
					alert(  CNV( '../../' ,  'Per eseguire Il cambiamento richiesto occorre terminare la fase di verifica campionatura' ));  
					return;
				}  
			}
		
		}	
		
	}
	
    //-- verifica se lo stato richiesto è ammissibile
    var StatoPDA = getObjValue( 'val_R' + indRow +  '_StatoPDA' );
    var idRow = getObjValue( 'R' + indRow +  '_idRow' );
    var InversioneBuste = getObjValue( 'InversioneBuste' );
    
    //-- se viene richiesta l'esclusione
    if( stato == '1' )
	{
		
		//-- se viene richiesta l'esclusione lo stato di partenza puo essere:in verifica(9) o vuoto(8) o sorteggiata (4) o ammessa con riserva (22) o ammessa ex art 133 (222) o ammessa (2)
		if(  StatoPDA == '8' || StatoPDA == '9' || StatoPDA == '4' || StatoPDA == '22' ||  StatoPDA == '222' || StatoPDA == '2'   )
		{
			LocalMakeDocFrom( 'ESITO_ESCLUSA#900,800#RIGA_PDA#' + idRow );
			return;
		}

	}
	
    //-- se viene richiesta la verifica lo stato di partenza puo essere:vuoto(8) -- si aggiunge lo stato (222) ex art 133 e ammessa con riserva (22) 
    if( stato == '9' && ( StatoPDA == '8'  || StatoPDA == '22' || StatoPDA == '222' ) )  //  ||  StatoPDA == '222' 
    {
        DOC_NewDocumentFrom( 'ESITO_VERIFICA#RIGA_PDA,' + idRow + '#800,600##&UpdateParent=no' );
        return;
    }
  

    //-- se viene richiesta l'esclusione lo stato di partenza puo essere:in verifica(9) o vuoto(8)  o sorteggiata (4)
    if( stato == '8' && ( StatoPDA == '1' || StatoPDA == '9' || StatoPDA == '4' || StatoPDA == '2' || StatoPDA == '22') && InversioneBuste != '1' )
    {
        
		var strReturn = SUB_AJAX( '../../customdoc/Esito_PDA.asp?ESITO=ESITO_ANNULLA&IDROW=' + idRow );
		if ( strReturn == 'blocco')
		{
			ShowWorkInProgress( false );
			DMessageBox( '../../' , 'Operazione non consentita:presente documento esito per lotti' , 'Errore' , 2 , 400 , 300 );
			return;
		}
		else
		{
			DOC_NewDocumentFrom( 'ESITO_ANNULLA#RIGA_PDA,' + idRow + '#800,600##&UpdateParent=no' );
			return;
		}
    }
	
	

     //-- se viene richiesta l'ammessa lo stato di partenza puo essere:in verifica(9) o vuoto(8)  o sorteggiata (4) ( 222 si aggiunge ammessa ex art 133
    if( stato == '2' )
	{
		if( ( StatoPDA == '8'  || StatoPDA == '9' || StatoPDA == '4'  || StatoPDA == '222'  ) )
		{
			//NELLA SELECT DIETRO IL PROCESSO DI AMMETTI TUTTE (PDA_MICROLOTTI-AMMETTI_TUTTE) RIPETO LE STESSE LOGICHE DEL JS E DELLA Esito_PDA.asp, NEL CASO DI EVOLUZIONI CAMBIARLE ANCHE LA
			if( StatoPDA == '8' || StatoPDA == '222' )
			{
				if ( RichiestaCampionatura == '1' )
				{
				  
					if (VerificaCampionatura == 'ko'){
						ShowWorkInProgress( false );

						alert(  CNV( '../../' ,  'ammissione non possibile in quanto nessun campione ricevuto' ));
						return;
					}
				  
					if (VerificaCampionatura == 'warning'){
					
						LocalMakeDocFrom( 'ESITO_AMMESSA#900,800#RIGA_PDA#' + idRow );
						return;
					  
					}
				  
				} 
				   
				//-- invoca il cambio di stato ( gestire l'errore )
				var strReturn = SUB_AJAX( '../../customdoc/Esito_PDA.asp?ESITO=AMMESSA&IDROW=' + idRow );
				
				//alert(strReturn);
				
				if ( strReturn == ''){
					//-- ho cambiato stato in ammessa e ricarico la sezione delle offerte
					ExecDocCommand( 'OFFERTE#Reload#' );			
					return;
				}
				
				if ( strReturn == 'makedocfrom'){
					//ho trovato un documento di escludi lotti confermato     
					LocalMakeDocFrom( 'ESITO_AMMESSA#900,800#RIGA_PDA#' + idRow );
					return;
				}
				
				if ( strReturn == 'blocco'){
					//ho trovato un documento di escludi lotti in lavorazione e blocco
					//alert(  CNV( '../../' ,  'Operazione non consentita:presente documento escludi lotti inlavorazione' ));
					ShowWorkInProgress( false );
					DMessageBox( '../../' , 'Operazione non consentita:presente documento escludi lotti inlavorazione' , 'Errore' , 2 , 400 , 300 );
					return;
				}
				
				
			}
			else
			{
				//DOC_NewDocumentFrom( 'ESITO_AMMESSA#RIGA_PDA,' + idRow + '#800,600##&UpdateParent=no' );
				//cambiato in LocalMakeDocFrom
				//alert(idRow);
				LocalMakeDocFrom( 'ESITO_AMMESSA#900,800#RIGA_PDA#' + idRow );
			}
			
			return;
		}
		
		//-- da ammessa con riserva superati i controlli si deve mettere una motivazione
		if( StatoPDA == '22'  )
		{
		
		  
			if ( RichiestaCampionatura == '1' )
			{
			  
				  if (VerificaCampionatura == 'ko')
				  {
					ShowWorkInProgress( false );
					alert(  CNV( '../../' ,  'ammissione non possibile in quanto nessun campione ricevuto' ));
					return;
				  }
				  
					LocalMakeDocFrom( 'ESITO_AMMESSA#900,800#RIGA_PDA#' + idRow );
					return;
				  
			 }       
		   
			else
			{
				
				LocalMakeDocFrom( 'ESITO_AMMESSA#900,800#RIGA_PDA#' + idRow );
			}
			
			return;
		}
		
	}
	
	
	//-- Ammessa con riserva è consentito se non ho emesso un esito  
    if( stato == '3' && ( StatoPDA == '8'  || StatoPDA == '9' || StatoPDA == '4'  ) )
    {
    
        if( StatoPDA == '8' )
        {
            if ( RichiestaCampionatura == '1' )
			{
              
				  if (VerificaCampionatura == 'ko')
				  {
					ShowWorkInProgress( false );
					alert(  CNV( '../../' ,  'ammissione non possibile in quanto nessun campione ricevuto' ));
					return;
				  }
				  
					LocalMakeDocFrom( 'ESITO_AMMESSA_CON_RISERVA#900,800#RIGA_PDA#' + idRow );
					return;
                  
            }
             else
			{
				
				LocalMakeDocFrom( 'ESITO_AMMESSA_CON_RISERVA#900,800#RIGA_PDA#' + idRow );
			} 
        }
		else
		{
			
			LocalMakeDocFrom( 'ESITO_AMMESSA_CON_RISERVA#900,800#RIGA_PDA#' + idRow );
		} 
   
        
        return;
    }

	
	ShowWorkInProgress( false );
    alert(  CNV( '../../' ,  'Il cambiamento richiesto non e coerente con lo stato del documento' ));
	
	  
}





function getCheckedValue(radioObj) {
	if(!radioObj)
		return "";
	var radioLength = radioObj.length;
	if(radioLength == undefined)
		if(radioObj.checked)
			return radioObj.value;
		else
			return "";
	for(var i = 0; i < radioLength; i++) {
		if(radioObj[i].checked) {
		
		    if( isNumeric( radioObj[i].value ) == true )
			    return radioObj[i].value;
			else
			    return"";
		}
	}
	return "";
}


function getCheckedValueRow(radioObj) 
{
	if(!radioObj)
		return "";
	var radioLength = radioObj.length;
	if(radioLength == undefined)
		if(radioObj.checked)
			return radioObj.value;
		else
			return "";
	for(var i = 0; i < radioLength; i++) {
		if(radioObj[i].checked) {
		
		    //if( isNumeric( radioObj[i].value ) == false )
			    return radioObj[i].value;
			//else
			//    return"";
		}
	}
	return "";
}

//-- recupera l'indice del radio button con il valore passato
function getRadioOfValue(radioObj , value) 
{
	if(!radioObj)
		return "";
	var radioLength = radioObj.length;
	if(radioLength == undefined)
		if(radioObj.value == value )
			return 0;
		else
			return -1;
	for(var i = 0; i < radioLength; i++) {
		if(radioObj[i].value == value ) {
			    return i;
		}
	}
	return -1;
}

function isNumeric(n) { 
      return !isNaN(parseFloat(n)) && isFinite(n); 
}


function getIdRowChecked(radioObj) 
{
	if(!radioObj)
		return "";
	var radioLength = radioObj.length;
	if(radioLength == undefined)
		return -1;
	for(var i = 0; i < radioLength; i++) {
		if(radioObj[i].checked) {
			return i;
		}
	}
	return -1;
}


function LISTA_MICROLOTTI_OnLoad()
{

	var stFunzionale;
		
	try
	{
		stFunzionale = getObjValue('StatoFunzionale');
	}
	catch(e)
	{
		stFunzionale = getObjValue( 'val_StatoFunzionale' );
	}
	
    if( stFunzionale != 'VERIFICA_AMMINISTRATIVA' )
    {
        var NomeModelloPDA = getObj( 'ModelloPDA' ).value;
        
        LISTA_MICROLOTTI.location = '../../DASHBOARD/Viewer.asp?TOOLBAR=&Table=PDA_LISTA_MICROLOTTI_VIEW&ModGriglia=' + NomeModelloPDA + '&JSCRIPT=PDA_MICROLOTTI&IDENTITY=Id&DOCUMENT=PDA_DRILL_MICROLOTTO&PATHTOOLBAR=../customdoc/&AreaAdd=no&Caption=&Height=0,100*,0&numRowForPag=15&Sort=Ordinamento&SortOrder=asc&Exit=no&ShowExit=0&ROWCONDITION=BLACK,bRead=1~&FilterHide=idDoc = ' + getObj('IDDOC').value ;
    }
    else
    {
        LISTA_MICROLOTTI.location = '../../CustomDoc/PDA_ListaMicrolotti.asp';
    }

}

function LISTA_DOCUMENTI_OnLoad()
{

    LISTA_DOCUMENTI.location = '../../DASHBOARD/Viewer.asp?TOOLBAR=PDA_MICROLOTTI_LISTA_DOCUMENTI_TOOLBAR&Table=PDA_MICROLOTTI_LISTA_DOCUMENTI&JSCRIPT=PDA_MICROLOTTI&IDENTITY=Id&DOCUMENT=PDA_DRILL_MICROLOTTO&PATHTOOLBAR=../customdoc/&AreaAdd=no&Caption=&Height=0,100*,0&numRowForPag=15&Sort=data&ActiveSel=2&SortOrder=asc&Exit=no&ShowExit=0&FilterHide=LinkedDoc = ' + getObj('IDDOC').value ;
 
    DisplaySection();
}


function OpenPosizionamentoFornitori(objGrid , Row , c)
{
    //PDA_DRILL_MICROLOTTO
    
}

function OpenSeduta(objGrid , Row , c) 
{
    var cod = getObj( 'R' + Row + '_idSeduta').value;

    GridSecOpenDoc(objGrid , Row , c) 
    
}


function RefreshContent(tipo,param)
{
    //se ho innescato apertura busta documentazione
    if (tipo == 'ViewerExecProcess' && ( param == 'APERTURA_BUSTE_DOCUMENTAZIONE_MULTIPLA,PDA_MICROLOTTI' || param == 'VERIFICA_FILE_BUSTA_AMM,PDA_MICROLOTTI' ) )
	{
		ExecDocCommand( 'OFFERTE#Reload#' );	
		return;
	}	

	//se ho innescato apertura busta TECNICHE
	if ( tipo == 'ViewerExecProcess' && ( param == 'APERTURA_BUSTE_TECNICHE_MONO_LOTTO_MULTIPLA,PDA_MICROLOTTI' || param == 'VERIFICA_FILE_MONO_TEC,PDA_MICROLOTTI' ) )
	{
		ExecDocCommand( 'OFFERTE_TEC#Reload#' );
		return;
	}
	
	//se ho innescato apertura busta economica
    if (tipo == 'ViewerExecProcess' && ( param == 'APERTURA_BUSTE_ECONOMICA_MULTIPLA,PDA_MICROLOTTI' || param == 'VERIFICA_FILE_MONO_ECO,PDA_MICROLOTTI' ) )
	{
		ExecDocCommand( 'OFFERTE_ECO#Reload#' );	
		return;
	}


	if ( tipo == 'ViewerExecProcess' && param == 'DELETE,LISTA_DOCUMENTI' )
	{
		ExecDocCommand( 'LISTA_DOCUMENTI#Reload#' );
		return;
	}

	//ExecDocCommand( 'RIEPILOGO_FINALE#Reload#' );

    
}


/*
function afterProcess(param) 
{

	
	if ( param == 'VALUTAZIONE_LOTTI' ){
		ExecDocCommand( 'OFFERTE_ECO#Reload#' );	
		return;
	}
	
	
}
*/




function COMMISSIONE_GIUDICATRICE_T_OnLoad(){
	    InitCommissione();
}  


function RIEPILOGO_MONOLOTTO_OnLoad()
{
	
}


function InitCommissione(){
	
	var valueCriterio;
	var CriterioAggiudicazioneGara;
	try
	{
		CriterioAggiudicazioneGara = getObj( 'val_CriterioAggiudicazioneGara') ;
		valueCriterio =  GetProperty( CriterioAggiudicazioneGara , 'value' );
		if ( valueCriterio == '15531' )
		{
			getObj('cap_Static').innerHTML = CNV( '../../' , 'Commissione (soggetto incaricato)' );
			var objRow=getObj('RCOMMISSIONE_GIUDICATRICE_T_MODEL_AttoNomina').parentNode.parentNode;
			objRow.style.display='none';
		}
	}catch(e){};
}



function DisplaySection( obj )
{
    var crit = '';
    var conf = '';
	var Divisione_lotti = ''
	var proceduraGara = '';
	var TipoBandoGara = '';
	
    try{ crit = getObjValue( 'CriterioAggiudicazioneGara' ); }catch(e){ crit = ''; };
    try{ conf = getObjValue( 'Conformita' ); }catch(e){ conf = ''; };
    try{ Divisione_lotti = getObjValue( 'Divisione_lotti' ); }catch(e){ Divisione_lotti = ''; };
	
	if ( getObj('ProceduraGara') )
	{
		proceduraGara = getObjValue('ProceduraGara');
	}
	
	if ( getObj('TipoBandoGara') ) 
	{
		TipoBandoGara = getObjValue('TipoBandoGara');
	}
	
	
    //-- se è privista la conformita Ex-Ante oppure è economicamente più vantaggiosa oppure COSTO FISSO oppure gara a lotti oppure ristretta
    if( conf == 'Ex-Ante' || crit == '15532' || crit == '25532' || Divisione_lotti != '0' || proceduraGara  == '15477' )
    {
        //DocDisplayFolder(  'VAL_TEC' ,'' );

        ShowCol( 'OFFERTE' , 'bReadEconomica' , 'none' );

    }
    else
    {
        //DocDisplayFolder(  'VAL_TEC' ,'none' );
    }
	
	
	if ( proceduraGara  == '15477' )
	{
		ShowCol( 'OFFERTE' , 'FNZ_ADD' , 'none' );
	}	
	
	//Bando - ristretta
	if ( TipoBandoGara == '2' && proceduraGara  == '15477' ) 
	{
		getObj('COMMISSIONE_GIUDICATRICE_D').style.display = 'none';
		getObj('COMMISSIONE_ECONOMICA_T').style.display = 'none';
		getObj('COMMISSIONE_GIUDICATRICE_T').style.display = 'none';
		getObj('ATTIC').style.display = 'none';
		getObj('ATTIG').style.display = 'none';
		getObj('COMMISSIONE_ECONOMICA_C').style.display = 'none';
		
		//nascono la colonna della campionatura nella PREQUALIFICA
		ShowCol( 'OFFERTE' , 'VerificaCampionatura' , 'none' );
		
		
	}
    
    //se si trattat di RDP/IDM nascondo sezione Valutazione amministrativa
//    try{ ProcGara = getObjValue( 'ProceduraGara' ); }catch(e){ ProcGara = ''; }
//    if ( ProcGara == '15581' || ProcGara == '15479' )
//       DocDisplayFolder(  'OFF' ,'none' );
       
}



function OpenBusteTec( objGrid , Row , c )
{

 
    var idMsg =  getObjValue( 'RLST_LOTTI_TECGrid_' + Row  + '_id' );
    var TipoDoc =  'PDA_LST_BUSTE_TEC';
    
    //ShowDocumentFromAttrib( TipoDoc + ',' +  'RLST_LOTTI_TECGrid_' + Row  + '_id' );
    LocalMakeDocFrom( 'PDA_LST_BUSTE_TEC#900,800#PDA#' + idMsg );

}


function FineAmministrativa()
{
    var crit = '';
    var conf = '';
    var Divisione_lotti = ''
    try{ crit = getObjValue( 'CriterioAggiudicazioneGara' ); }catch(e){ crit = ''; };
    try{ conf = getObjValue( 'Conformita' ); }catch(e){ conf = ''; };
    try{ Divisione_lotti = getObjValue( 'Divisione_lotti' ); }catch(e){ Divisione_lotti = ''; };
     

    //-- se è privista la conformita Ex-Ante oppure è economicamente più vantaggiosa
    //if( conf == 'Ex-Ante' || crit == '15532' ) //|| Divisione_lotti == '0')
    {
        //DocShowFolder( 'FLD_VAL_TEC' );tdoc();
        ExecDocProcess( 'VALUTAZIONE_LOTTI,PDA_MICROLOTTI' );
    
    }
    //else
    //{
        //DocShowFolder( 'FLD_RIEP' );tdoc();
    //    ExecDocProcess( 'VALUTAZIONE_ECONOMICA,PDA_MICROLOTTI' );
    //}
    

}






function OpenRiepilogo( objGrid , Row , c )
{

    var idMsg =  getObjValue( 'RRIEPILOGO_FINALEGrid_' + Row  + '_id' );
    var TipoDoc =  'PDA_RIEPILOGO_LOTTO';
    try{ conf = getObjValue( 'Conformita' ); }catch(e){ conf = ''; };

    var crit = getObjValue( 'CriterioAggiudicazioneGara' );
    
    //-- se è economicamente più vantaggiosa oppure COSTO FISSO
    if( conf == 'Ex-Ante' ||  crit == '15532' ||  crit == '25532' )
    {
		ShowDocumentFromAttrib( 'PDA_RIEPILOGO_LOTTO#&UpdateParent=no,' +  'RRIEPILOGO_FINALEGrid_' + Row  + '_id' );
    }
    else
    {
		ShowDocumentFromAttrib( 'PDA_RIEPILOGO_LOTTO#&UpdateParent=no,' +  'RRIEPILOGO_FINALEGrid_' + Row  + '_id' );
        //ShowDocumentFromAttrib( 'PDA_DRILL_MICROLOTTO,' +  'RRIEPILOGO_FINALEGrid_' + Row  + '_id' );
    }

}



function OFFERTE_AFTER_COMMAND( p )
{
	try{ AUTO_CheckOfferta(); } catch(e){};
    try{ DisplaySection(); } catch(e){};
	try{ rimuovi_OpenOfferta_Allegati(); } catch(e){};
	
	ShowWorkInProgress( false );
}


//per modifiare una RTI relativa ad una offerta
function ModificaPartecipanti( param )
{

  
  //-- posiziona la scheda di valutazione
	//DocShowFolder( 'FLD_OFF' );
	//tdoc();
  
    var Selezione = document.getElementsByName('Selezione');
    
    //-- recupera la riga selezionata
    var indRow = getCheckedValue( Selezione );   
    
    if ( indRow != '' ){
    
    //-- verifica se lo stato richiesto è ammissibile
    //var StatoPDA = getObjValue( 'val_R' + indRow +  '_StatoPDA' );
      //var idRow = getObjValue( 'R' + indRow +  '_idRow' );
      var idDocOff = getObjValue( 'R' + indRow +  '_idMsg' );
      
      LocalMakeDocFrom( 'OFFERTA_PARTECIPANTI#900,800#OFFERTA#' + idDocOff );
      
    }else{
      
      alert(  CNV( '../../' ,  'E\' necessario selezionare prima una riga' ) );
    }
    //-- se viene richiesta l'esclusione lo stato di partenza puo essere:in verifica(9) o vuoto(8)
    //if( stato == '1' && ( StatoPDA == '8' || StatoPDA == '9' ) )
    //{
    //    DOC_NewDocumentFrom( 'ESITO_ESCLUSA#RIGA_PDA,' + idRow + '#800,600##&UpdateParent=no' );
    //    return;
    //}

    //alert(  CNV( '../../' ,  'Il cambiamento richiesto non è coerente con lo stato del documento' ));
	 
	 
}

//per modifiare una RTI relativa ad una offerta
function RicezioneCampioni( param )
{

  var Selezione = document.getElementsByName('Selezione');
  
  //-- recupera la riga selezionata
  var indRow = getCheckedValue( Selezione );   
  
  if ( indRow != '' ){
  
    var idDocOff = getObjValue( 'R' + indRow +  '_idMsg' );
    //alert(idDocOff);
    LocalMakeDocFrom( 'RICEZIONE_CAMPIONI#900,800#OFFERTA#' + idDocOff );
    
  }else{
    
    alert(  CNV( '../../' ,  'E\' necessario selezionare prima una riga' ) );
  }
	 
}

function COMMISSIONE_ECONOMICA_T_OnLoad()
{
}




function AnnullaRicezioneCampioni( param )
{

  var Selezione = document.getElementsByName('Selezione');
  
  //-- recupera la riga selezionata
  var indRow = getCheckedValue( Selezione );   
  
  if ( indRow != '' ){
  
    var idDocOff = getObjValue( 'R' + indRow +  '_idMsg' );
    //alert(idDocOff);
    LocalMakeDocFrom( 'ANNULLA_RICEZIONE_CAMPIONI#900,800#OFFERTA#' + idDocOff );
    
  }else{
    
    alert(  CNV( '../../' ,  'E\' necessario selezionare prima una riga' ) );
  }
	 
}



function EscludiLotti( param )
{

	var Selezione = document.getElementsByName('Selezione');

	//-- recupera la riga selezionata
	var indRow = getCheckedValue( Selezione );  
	
  
	if ( indRow != '' )
	{

		var idDocOff = getObjValue( 'R' + indRow +  '_idMsg' );
		//alert(idDocOff);
		LocalMakeDocFrom( 'ESCLUDI_LOTTI#900,800#OFFERTA#' + idDocOff );

	}
	else
	{
		alert(  CNV( '../../' ,  'E\' necessario selezionare prima una riga' ) );
	}
	 
}


function AnnullaEscludiLotti( param )
{

  var Selezione = document.getElementsByName('Selezione');
  
  //-- recupera la riga selezionata
  var indRow = getCheckedValue( Selezione );   
  
  if ( indRow != '' ){
  
    var idDocOff = getObjValue( 'R' + indRow +  '_idMsg' );
    //alert(idDocOff);
    LocalMakeDocFrom( 'ANNULLA_ESCLUDI_LOTTI#900,800#OFFERTA#' + idDocOff );
    
  }else{
    
    alert(  CNV( '../../' ,  'E\' necessario selezionare prima una riga' ) );
  }
	 
}



function RIEPILOGO_FINALE_OnLoad()
{
    var ValTipoSceltaContraente = '';
    
    try{ ValTipoSceltaContraente = getObjValue( 'TipoSceltaContraente' ); }catch(e){ crit = ''; };
    
    //alert(ValTipoSceltaContraente);
    
    //-- se è privista la conformita Ex-Ante oppure è economicamente più vantaggiosa si devono aprire i singoli lotti
    if( ValTipoSceltaContraente == 'ACCORDOQUADRO' )
    {   
        ShowCol( 'RIEPILOGO_FINALE' , 'aziRagioneSociale' , 'none' );
        
    }else{
    
        ShowCol( 'RIEPILOGO_FINALE' , 'StatoRiga' , 'none' );
    }
    
}

function RIEPILOGO_FINALE_AFTER_COMMAND( param )
{
    //alert('after command riepilogo');
    RIEPILOGO_FINALE_OnLoad();
}






function RettificaValore( param )
{
	
     
	var Selezione = document.getElementsByName('Selezione2');
    
  //-- recupera la riga selezionata
  var indRow = getCheckedValueRow( Selezione );
  
  
  if( indRow  == '' ) 
  {
      alert(  CNV( '../../' ,  'E\' necessario selezionare prima una riga' ));
      return; 
  }
  
  
  var StatoOfferta = getObjValue( 'val_R' + indRow +  '_StatoRiga' );
  var idRow = getObjValue( 'R' + indRow +  '_id' );
  
  //alert(idRow);
  if(   StatoOfferta != 'escluso' && StatoOfferta != 'esclusoEco' ) //non deve essere ne escluso ne esclusoeco
  {
    DOC_NewDocumentFrom( 'RETT_VALORE_LOTTO_AGG#PDA_RIEPILOGO_MONOLOTTO_ROW,' + idRow + '#800,600##&UpdateParentX=no' );
    return;
  }
  
  alert(  CNV( '../../' ,  'rettifica valore non e\' coerente con lo stato del documento' ));
  
}



function RettificaValoreEconomico( param )
{
	
     
	var Selezione = document.getElementsByName('Selezione2');
    
  //-- recupera la riga selezionata
  var indRow = getCheckedValueRow( Selezione );
  
  
  if( indRow  == '' ) 
  {
      alert(  CNV( '../../' ,  'E\' necessario selezionare prima una riga' ));
      return; 
  }
  
  
  var StatoOfferta = getObjValue( 'val_R' + indRow +  '_StatoRiga' );
  var idRow = getObjValue( 'R' + indRow +  '_id' );
  
  //alert(idRow);
  if(   StatoOfferta != 'escluso' && StatoOfferta != 'esclusoEco' ) //non deve essere ne escluso ne esclusoeco
  {
    //DOC_NewDocumentFrom( 'RETT_VALORE_ECONOMICO#PDA_RIEPILOGO_MONOLOTTO_ROW,' + idRow + '#800,600##&UpdateParentX=no' );
    LocalMakeDocFrom( 'RETT_VALORE_ECONOMICO#800,800#PDA_RIEPILOGO_MONOLOTTO_ROW#' + idRow );
    return;
  }
  
  alert(  CNV( '../../' ,  'rettifica valore non e\' coerente con lo stato del documento' ));
  
}



var G_p1 , G_p2 , G_p3;
function LocalMakeDocFrom( p1 , p2 , p3 ) 
{
	//-- l'invocazione della nuova pagina è stata posticipata per dare il tempo alla pagina di 
	//-- visualizzare l'elaborazione in corso
	G_p1 = p1;
	G_p2 = p2;
	G_p3 = p3;

	ShowWorkInProgress();
	setTimeout(function()
		{ 
			MakeDocFrom( G_p1 , G_p2 , 'no' ); 
		}, 1 );
	
}

function getNumeroOfferte()
{
	var i = 0;
	var totOfferte = getObjValue( 'NumeroOfferte' );
	/*
	for (i = 0; i <= GetProperty(getObj('OFFERTEGrid'), 'numrow'); i++) 
	{
		var statoOfferta = '';
		
		if ( getObj('val_R' + i + '_StatoPDA') )
		{
			statoOfferta = getObjValue('val_R' + i + '_StatoPDA');
		}
		else
		{
			statoOfferta = getObjValue('R' + i + '_StatoPDA');
		}
		
		Se l'offerta è valida. cioè ha uno stato diverso da 'invalidata' e ritirata (999)
		if ( statoOfferta != '99' &&  statoOfferta != '999' )
		{
			totOfferte = totOfferte + 1;
		}	
	}
	*/
	return totOfferte;
}


function EsitoVerificaAnomalia( param )
{
	var Selezione = document.getElementsByName('Selezione2');
    
    //-- recupera la riga selezionata
    var indRow = getCheckedValueRow( Selezione ); 

	if( indRow  == '' ) 
	{
		alert(  CNV( '../../' ,  'E\' necessario selezionare prima una riga' ));
		return; 
	}

	var StatoOfferta = getObjValue( 'val_R' + indRow +  '_StatoRiga' );
	var idRow = getObjValue( 'R' + indRow +  '_id' );

	if(   StatoOfferta == 'SospettoAnomalo'  )
	{							//ESITO_LOTTO_ANOMALIA_OFFERTA#PDA_RIEPILOGO_MONOLOTTO ?
		DOC_NewDocumentFrom( 'ESITO_LOTTO_ANOMALIA_OFFERTA#PDA_RIEPILOGO_LOTTO_ROW,' + idRow + '#800,600##&UpdateParentX=no' );
		return;
	}

	alert(  CNV( '../../' ,  'EsitoVerificaAnomalia non e\' coerente con lo stato del documento' ));

}



function OpenOfferta_Allegati( objGrid , Row , c )
{
	
	 var idRow = getObjValue( 'R' + Row +  '_idMsg' );	 
	 LocalMakeDocFrom( 'OFFERTA_ALLEGATI#800,800#OFFERTA#' + idRow );
     return;

}
function rimuovi_OpenOfferta_Allegati()
{
  // rimuove la funzione di onclick quando non ci sta un esito
  var onclick = '';  
  var numeroRighe0 = GetProperty( getObj('OFFERTEGrid') , 'numrow');
	
		for( i = 0 ; i <= numeroRighe0 ; i++ )
		{
		 try{
				if( getObjValue('val_R' + i + '_Stato_Firma_PDA_AMM') == '' )
				{
					
					getObj( 'OFFERTEGrid_r' + i + '_c8' ).style.cursor='default';					
					getObj('val_R' + i + '_Stato_Firma_PDA_AMM').className='';
					getObj('val_R' + i + '_Stato_Firma_PDA_AMM').innerHTML = '';
					
				}
			}
		  catch(e){};
		}
}

 
function My_Dash_ExecProcessDoc( param , ID_Griglia)
{
	
	
	
	var w;
	var h;
	var Left;
	var Top;
	var parametri;
	var CONTESTO;

	w = 800;
	h = 600;	
	Left = (screen.availWidth-w)/2;
	Top  = (screen.availHeight-h)/2;	
	ID_Griglia = ID_Griglia + 'Grid';
	
	if (ID_Griglia == 'OFFERTEGrid' ) 
	{
		CONTESTO = 'BUSTE_VALUTAZIONE_AMMINISTRATIVA';
	}
	
	if (ID_Griglia == 'OFFERTE_ECOGrid' ) 
	{
		CONTESTO = 'BUSTE_ECONOMICA_MONOLOTTO';
	}
	if (ID_Griglia == 'OFFERTE_TECGrid' ) 
	{
		CONTESTO = 'BUSTE_TECNICA_MONOLOTTO';
	}
	
	parametri='CONTESTO=' + CONTESTO + '&IDDOC=' + getObj('IDDOC').value + '&PROCESS_PARAM=' + encodeURIComponent(param);
	
	ExecFunction(  pathRoot + 'customDoc/Apri_Buste_Offerte.asp?' + parametri,  '_blank',  ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h );
	
}	
	/*
	
	//Dash_ExecProcessDoc( param , 'OFFERTE');
	//-- determino che riga selezionare
	//ID_Griglia = 'OFFERTEGrid';
	ID_Griglia = ID_Griglia + 'Grid';
	
	var i;
	var result = '';
	var NumRow = eval( ID_Griglia + '_EndRow;' );
	var nStartRow=eval( ID_Griglia + '_StartRow;' );
	var strDoc = '';
	var StatoPDA;
	
    for( i = nStartRow ; i <= NumRow ; i++ )
    {
		
		//busta amministraztiva	
		if (ID_Griglia == 'OFFERTEGrid' ) 
		{	
			
			StatoPDA = getObjValue( 'val_R' + ( i ) + '_StatoPDA' );
			bReadDocumentazione = '';
			bReadDocumentazione = getObjValue( 'val_R' + ( i ) + '_bReadDocumentazione' );
			//alert(bReadDocumentazione);
			if ( StatoPDA != '1' &&  StatoPDA != '99'  && StatoPDA != '999'  && bReadDocumentazione == '1' )
			{
			
				strDoc = getObj( ID_Griglia + '_idRow_' + i ).value; //OFFERTEGrid_idRow_0	
			
				if ( result != '' ) 
					result = result +  '~~~';

				result = result + strDoc;
				
			}
		}
		
		//busta economica monolotto
		if (ID_Griglia == 'OFFERTE_ECOGrid' ) 
		{	
			bReadEconomica = '';
			bReadEconomica = getObjValue( 'val_ROFFERTE_ECOGrid_' + ( i ) + '_bReadEconomica' );
			//alert(bReadEconomica);
			if (bReadEconomica == '1')
			{
			
				strDoc = getObj( 'R' + ID_Griglia + '_' + i + '_idMsg' ).value; //OFFERTEGrid_idRow_0	
		
				if ( result != '' ) 
					result = result +  '~~~';

				result = result + strDoc;
			
			}
			
		}
			
    }
	//alert(result);
	if (result == '')
	{
		alert( CNV( '../../' , 'Non ci sono buste da aprire' ));
		return;
	}	
			
	
	parent.ExcelDocument.location =  '../../dashboard/ViewerCommand.asp?IDLISTA=' + result +'&PROCESS_PARAM=' + param ;
	
	
}*/

function EsportaRiepilogo(param)
{
	
	
	var strHideCol='';
	var CriterioAggiudicazioneGara; 
	var num_criteri_eco='';	
	
	try{ num_criteri_eco = getObjValue( 'num_criteri_eco' ); }catch(e){ num_criteri_eco = ''; };
	
	try{
		CriterioAggiudicazioneGara = getObjValue( 'CriterioAggiudicazioneGara' );
	}catch(e){
		CriterioAggiudicazioneGara = getObjValue( ' CriterioAggiudicazioneGara' );
	}
	
	try{ ValutazioneSoggettiva = getObjValue( 'ValutazioneSoggettiva' ); }catch(e){ ValutazioneSoggettiva = ''; };
	 

    //se è al costo fisso nascondo  le colonne scheda valutazione,punteggio tecnico,punteggio economico
	if ( CriterioAggiudicazioneGara == '25532' )
	{
		//ShowCol( 'OFFERTE_ECO' , 'ValoreImportoLotto' , 'none' );
		//ShowCol( 'OFFERTE_ECO' , 'PunteggioEconomicoAssegnato' , 'none' );        
		strHideCol =  'ValoreSconto,ValoreImportoLotto,PunteggioEconomicoAssegnato'

	}
	
    //-- al prezzo più alto
    if ( CriterioAggiudicazioneGara == '16291' )
	{
		strHideCol =  'ValoreImportoLotto,PercentualeRibasso,Ribasso'
		
		//se un solo criterio nascondiamo il punteggio altrimenti nascondo la percentuale
		if ( num_criteri_eco == '1' && getObjValue('val_CriterioFormulazioneOfferte') == '15537' )
		{
			
			strHideCol =  'ValoreOfferta,ValoreImportoLotto,PercentualeRibasso,Ribasso'
		}
		else
		{
			
			strHideCol =  'ValoreSconto,ValoreImportoLotto,PercentualeRibasso,Ribasso'
		}
		
		   
	}
	if ( CriterioAggiudicazioneGara == '15531' )
    {		
	  
	  //--se è al prezzo ed ho un solo criterio economico e non si è scelta una valutazione soggettiva nasconodo anche la colonna del punteggio e Scheda Valutazione
		if (num_criteri_eco == '1' && ValutazioneSoggettiva == '0')
		{
			strHideCol =  'ValoreOfferta'
		}
	}
	
	
	try{ var concessione = getObjValue( 'Concessione' ); }catch(e){ concessione = ''; };
	
	if ( concessione == 'si' )
	{
		if (strHideCol != '')
			strHideCol = strHideCol + ','
		
		strHideCol = strHideCol + 'ValoreImportoLotto';
		
	}
	//SE PERCENTUALE MOSTRA LA COLONNA VALORESCONTO 
	if (getObjValue('val_CriterioFormulazioneOfferte') == '15537')
	{
		if (strHideCol != '')
			strHideCol = strHideCol + ','
		
		strHideCol = strHideCol + 'ValoreImportoLotto';
	}
	else
	{
		if (strHideCol != '')
			strHideCol = strHideCol + ','
		
		strHideCol = strHideCol + 'ValoreSconto';
	}
	
	
	param = param + '&HIDECOL=' + strHideCol ;
	
	//alert(param);
	
	ExecDownloadSelf(param);
}
//cicla su tutte le righe del folder Sedute di gara e dove serve mette icona ZIP
function sedute_di_gara()
{
	try{
	
		var numeroRighe0 = GetProperty( getObj('SEDUTEGrid') , 'numrow');
	
		for( i = 0 ; i <= numeroRighe0 ; i++ )
		{
			try{
				if ( getObjValue('R' + i + '_Allegato').indexOf("DOWNLOAD_ZIP@@@") >= 0 )
				{
					try{ getObjValue('R' + i + '_Allegato')='';}catch( e ) {};					
					try{ getObj('R' + i + '_Allegato_V_N').innerHTML = 'SCARICA VERBALI SEDUTA';}catch( e ) {};
					try{ getObj('R' + i + '_Allegato_V_I').setAttribute("src", "../../CTL_Library/images/Domain/Ext_zip.gif" );}catch( e ) {};
					try{ getObj('R' + i + '_Allegato_V_I').setAttribute("onclick", "ScaricaAllegati('IDDOC=" + getObjValue('R' + i + '_idSeduta') + "&DOCUMENT=SEDUTA_PDA');" );}catch( e ) {};
					try{ getObj('R' + i + '_Allegato_V_N').setAttribute("onclick", "ScaricaAllegati('IDDOC=" + getObjValue('R' + i + '_idSeduta') + "&DOCUMENT=SEDUTA_PDA');" );}catch( e ) {};
					try{ getObj('R' + i + '_Allegato_V_I').setAttribute("title", "Scarica Allegati" );}catch( e ) {};
					try{ getObj('R' + i + '_Allegato_V_N').setAttribute("title", "Scarica Allegati" );}catch( e ) {};
					
				}
				
			}
			catch(e){};
		}
	}
	catch(e){};

}

//-- sovrascrivo la funzione per il cambio di table
var semaforoDocShowFolderLoc = 0;
function DocShowFolderLoc( F )
{
	ShowWorkInProgress( true );

	if ( semaforoDocShowFolderLoc == 0 )
	{
		var strDoc = 'PDA_MICROLOTTI_' + F.replace( 'FLD_' , '' ) ;
		var cod = getObjValue( 'IDDOC' );

		if( strDoc == 'PDA_MICROLOTTI_COP' )
		{
			 strDoc = 'PDA_MICROLOTTI';
		}
			
		
		url = pathRoot + 'ctl_library/document/document.asp?lo=base&JScript=' + strDoc + '&DOCUMENT=' + strDoc + '&MODE=OPEN&IDDOC=' + cod;
		
	
		document.location = url;
		
		semaforoDocShowFolderLoc = 1;
		
	}
	//alert( 'DOCUMENT_PDA_' + F );
	
}

function OFFERTE_ECO_AFTER_COMMAND(p)
{
	
	OnLoadPage();
}