var flag = 0;
var OldValueTipoBando = '';
var gModAttribPunteggio = '';
var oldDivisione_lotti='';
var oldCriterioAggiudicazioneGara='';
var oldConformita='';
//var OnClickCreaQuestionario ;

//window.onload = OnLoadPage;

$( document ).ready(function() {
    OnLoadPage();
});

function OnLoadPage() 
{
	
	try //Serve ad eliminare lo spazio sul modello BANDO_GARA_PARAMETRI tra AttivaFilePending e ControlloFirmaBuste funziona se nel modello sono uno dopo l'altro
	{
		var AttivaFilePending = getObj('cap_AttivaFilePending');
		/* SE IL CAMPO ESISTE */
		if ( AttivaFilePending )
		{
			$("#cap_AttivaFilePending").parents("table:first").parents("td:first").width(236);
		}
		else
		{
			$("#cap_ControlloFirmaBuste").parents("table:first").parents("tr:first").children("td:first").remove();
		}		
		
	}
	catch(e){}
	
	
	
	//DMessageBox( '' , 'prova modale' , 'Attenzione' , 2 , 400 , 300 );
	
	var DOCUMENT_READONLY_LOCAL = '0';
	var CriterioAggiudicazione;
	
	
	//-- se lo stato funzionale � quello di creazione della RDA deve creare il modello da associare alla gestione
	if ( getObjValue( 'StatoFunzionale' ) == 'InLavorazioneCreaModello' )
	{
		ExecDocProcess('PRE_SELECT_MODELLO_BANDO,BANDO,,NO_MSG');
	}
	
	try
	{		
		if ( typeof InToPrintDocument !== 'undefined' || getObjValue('StatoFunzionale') == 'InApprove')
		{
			DOCUMENT_READONLY_LOCAL = '1';
		}
		else
		{
										
			DOCUMENT_READONLY_LOCAL = getObj('DOCUMENT_READONLY').value;
		}
		
		CriterioAggiudicazione = getObjValue('CriterioAggiudicazioneGara');
		
	}
	catch(e)
	{
	}
	
	
	
	//-- determino se visualizzare il campo InversioneBuste
	ShowInversioneBuste();
	
	//Se esiste l'attributo 'attivoSimog'
	if ( getObj('attivoSimog') )
	{
		
		//Se non � attivo il simog  oppure siamo sul primo giro delle gare ( Avviso - Negoziata oppure se Bando - Ristretta )
		//nascondiamo il campo a dominio 'RichiestaCigSimog' ed il campo "Invio GUUE" ('RichiestaTED')
		//
		if 
		( 
			( getObjValue('attivoSimog') != '1' && getObjValue('attivoSimog') != 'True' ) 
				|| 
			( getObjValue('ProceduraGara') == '15478' && getObjValue('TipoBandoGara') == '1' ) 
				|| 
			( getObjValue('ProceduraGara') == '15477' && getObjValue('TipoBandoGara') == '2' )
				||
			( getObjValue('ProceduraGara') == '15583' && (getObjValue('TipoBandoGara') == '4' || getObjValue('TipoBandoGara') == '5'))
		)
		{
			getObj('attivoSimog').value = 'no';
			$("#cap_RichiestaCigSimog").parents("table:first").css({"display": "none"});
			getObj('RichiestaTED').value = 'no';
			$("#cap_RichiestaTED").parents("table:first").css({"display": "none"});
		}
	}
	
	//Se esiste il campo che mi dice se la procedura verr� inviata o meno all'osservatorio dei contratti pubblici
	if ( getObj('Attiva_OCP') )
	{
		try
		{
			if ( getObjValue('Attiva_OCP') == 'si' )
			{
				var objMod;
			
				if ( getObj('Cell_UserRUP') )
					objMod = getObj('Cell_UserRUP').parentNode.parentNode.parentNode.parentNode;
				else
					objMod = getObj('val_UserRUP').parentNode.parentNode.parentNode.parentNode;

				objMod.innerHTML = objMod.innerHTML + '<div style="margin-top: 15px;font-weight: bold;"><span class="VerticalModel_Help">' + CNV(pathRoot, 'help per segnalare che la procedura viene inviata ad ocp') + '</span></div>';
			}
		}
		catch(e){}
	}
	
	//-- inizializzo il filtro dei cig validi
	REQUISITI_AFTER_COMMAND('');
	
	try
	{
		if ( getObjValue('TipoBandoGara') == '1' )  //per gli avvisi nascosto Richiesta_terna_subappalto
		{
			$("#cap_Richiesta_terna_subappalto").parents("table:first").css({"display": "none"});
		}
	}
	catch(e){}
	
	try
	{
		//disableGeoField('DESC_LUOGO_ISTAT', true);
	}
	catch(e){}
	
	try
	{
		if ( getObjValue( 'DGUEAttivo') != 'si' )
			document.getElementById('DGUE').style.display = "none";
		
	}catch(e){}
	
	try
	{
		//nasconde gli altri domini se Presenza DGUE diveso da si OPPURE mi trovo sul primo giro della ristretta e sulla domanda non ho la composizione RTI,ecc. OPPURE primo giro di negoziata con avviso e sulla manifestazione non ho la composizione RTI,ecc.
		if ( 
			getObjValue( 'PresenzaDGUE') != 'si' 
			|| 
			( getObjValue('ProceduraGara') == '15477'  && getObjValue('TipoBandoGara') == '2' &&  getObjValue('ATTIVA_COMPOSIZIONE_AZI_DOMANDA') == '0'  ) 
			|| 
			( getObjValue('ProceduraGara') == '15478' && getObjValue('TipoBandoGara') == '1' && getObjValue('ATTIVA_COMPOSIZIONE_AZI_MANIFESTAZIONE') == '0'   ) 
			)
		{
			$("#cap_PresenzaDGUE_Mandanti").parents("table:first").css({"display": "none"});	
			$("#cap_PresenzaDGUE_Ausiliarie").parents("table:first").css({"display": "none"});
			$("#cap_PresenzaDGUE_Subappaltarici").parents("table:first").css({"display": "none"});			
			$("#cap_FNZ_UPD_Mandanti").parents("table:first").css({"display": "none"});
			$("#cap_FNZ_UPD_Ausiliarie").parents("table:first").css({"display": "none"});	
			$("#cap_FNZ_UPD_Subappaltarici").parents("table:first").css({"display": "none"});
			$("#cap_PresenzaDGUE_SubAppalto").parents("table:first").css({"display": "none"});
			$("#cap_FNZ_UPD_Subappalto").parents("table:first").css({"display": "none"});
        }
        
        //-- se il documento non � una negoziata con avviso nascondo il campo per escludere la documentazione 
        if ( !( getObjValue('ProceduraGara') == '15478' && getObjValue('TipoBandoGara') == '1' ) )
        {
            try{	$("#cap_RichiediDocumentazione").parents("table:first").css({"display": "none"}); } catch(e){}
		}

		
		if ( getObjValue('SYS_OFFERTA_PRESENZA_ESECUTRICI') == 'NO' )
		{
			$("#cap_PresenzaDGUE_Subappaltarici").parents("table:first").css({"display": "none"});
			$("#cap_FNZ_UPD_Subappaltarici").parents("table:first").css({"display": "none"});	
			
		}
		
		
		var Richiesta_terna_subappalto ='';
		try{  Richiesta_terna_subappalto = getObjValue('Richiesta_terna_subappalto') } catch(e){};
		
		if ( Richiesta_terna_subappalto != '1' )
		{
			$("#cap_PresenzaDGUE_SubAppalto").parents("table:first").css({"display": "none"});
			$("#cap_FNZ_UPD_Subappalto").parents("table:first").css({"display": "none"});	
			
		}
		
		try{
		
				getObj( 'STRUTTURA' ).style.display='none';
			}catch(e){};
		
	}catch(e){}
	
	
	if ( !getObj('ProceduraGara') )
	{
		//Se non esiste questo attributo vuol dire che sto eseguendo un comando su una griglia e non serve eseguire queste istruzioni non essendo un ricarico del documento
		return;
	}

    //cambia la tooltip della matita per Aprire il dettaglio del modello	
    var tmpMlg = '';
    try {
        tmpMlg = CNV(pathRoot, 'Modifica Modello Gara');
        getObj('RTESTATA_PRODOTTI_MODEL_FNZ_UPD_link').firstChild.alt = tmpMlg;
        getObj('RTESTATA_PRODOTTI_MODEL_FNZ_UPD_link').firstChild.title = tmpMlg;
    } catch (e) {}

		
	if ( DOCUMENT_READONLY_LOCAL == '0' && getObjValue('StatoFunzionale') != 'InApprove') 
	{
        FiltraModelli();
		getObj('CategoriaSOA_CHANGE_TECNICA').value = '0' ;

    }
    

    //-- visualizza le date e le relative descrizioni in coerenza con la tipologia di documento
    if (getObjValue('ProceduraGara') == '15478' && getObjValue('TipoBandoGara') == '4') //-- Negoziata - Avviso con risposta
    {

        getObj('cap_DataRiferimentoInizio').innerHTML = CNV('../', 'Inizio Presentazioni Manifestazione di Interesse');
        getObj('cap_DataScadenzaOfferta').innerHTML = CNV('../', 'Termine Presentazione Manifestazione di Interesse');

        setVisibility(getObj('cap_DataAperturaOfferte').offsetParent.offsetParent, 'none');

    }

	/*	Avendo specializzato il modello ( BANDO_GARA_TESTATA_AVVISO ) non serve pi� nascondere in js e cambiare il multilinguismo
	
    if (getObjValue('ProceduraGara') == '15478' && getObjValue('TipoBandoGara') == '1') //-- Negoziata - Avviso 
    {

        getObj('cap_DataAperturaOfferte').innerHTML = CNV('../', 'Data Presunta Pubblicazione Invito');

        setVisibility(getObj('cap_DataRiferimentoInizio').offsetParent.offsetParent, 'none');
        setVisibility(getObj('cap_DataScadenzaOfferta').offsetParent.offsetParent, 'none');

    }
	*/
	
	
	
	
    if (getObjValue('ProceduraGara') == '15477' && getObjValue('TipoBandoGara') == '1') //-- Ristretta - Bando
    {

        getObj('cap_DataRiferimentoInizio').innerHTML = CNV('../', 'Inizio Presentazioni Domanda di Partecipazione');
        getObj('cap_DataScadenzaOfferta').innerHTML = CNV('../', 'Termine Presentazione Domanda di Partecipazione');

    }

    DisplaySection();

    //gestisco i campi per gli appalti verdi
    try {
        if (getObjValue('Appalto_Verde') != 'si') {
            getObj('Motivazione_Appalto_Verde').value = '';
            //getObj('Motivazione_Appalto_Verde').disabled = true;
			ReadOnlyObj('Motivazione_Appalto_Verde' , true) ;

        }

    } catch (e) {}

	//gestisco i campi per l'acquisto sociale
    try {
        if (getObjValue('Acquisto_Sociale') != 'si') {
            getObj('Motivazione_Acquisto_Sociale').value = '';
            // getObj('Motivazione_Acquisto_Sociale').disabled = true;
			ReadOnlyObj('Motivazione_Acquisto_Sociale' , true) ;

        }
    } catch (e) {}
	
	
    //gestisco i campi per Appalto In Emergenza
    try {
        if (getObjValue('AppaltoInEmergenza') != 'si' && getObj( 'AppaltoInEmergenza' ).type == 'select-one' ) 
		{
            getObj('MotivazioneDiEmergenza').value = '';
            //getObj('MotivazioneDiEmergenza').disabled = true;
			ReadOnlyObj('MotivazioneDiEmergenza' , true) ;

        }

    } catch (e) {}   
	
	//gestisco i campi per il gender equality
    try {
        if (getObjValue('GenderEquality') != 'si') {
            getObj('GenderEqualityMotivazione').value = '';
            //getObj('GenderEqualityMotivazione').disabled = true;
			ReadOnlyObj('GenderEqualityMotivazione' , true) ;

        }
    } catch (e) {}

    OnChange_Riparametrazione();

    //Se il documento � editabile
    if ( DOCUMENT_READONLY_LOCAL == '0') 
	{

        try {

            var filter = '';
            if (CriterioAggiudicazione == '15532' || CriterioAggiudicazione == '25532') { //OEV oppure CostoFISSO

                if (getObjValue('CriterioFormulazioneOfferte') == '15537') {
                    filter = 'SQL_WHERE= CategorieUSO like \'%,sconto,%\' '
                }

                if (getObjValue('CriterioFormulazioneOfferte') == '15536') {
                    filter = 'SQL_WHERE= CategorieUSO like \'%,prezzo,%\' '
                }

                FilterDom('FormulaEcoSDA', 'FormulaEcoSDA', getObjValue('FormulaEcoSDA'), filter, '', 'OnChangeFormula( this );flagmodifica();');
                FilterDom('OffAnomale', 'OffAnomale', getObjValue('OffAnomale'), 'SQL_WHERE= tdrcodice = \'16310\' ', '', '');


            }
			
			//setto coerentemente OffAnomale			
			onChangeCalcoloSoglia();
			
        } catch (e) {}
		
		setRegExpCIG();

		// Commento il controllo perchè il campo è nascosta per il BANDO_CONCORSO
		//per il costo fisso oppure prezzo pi� alto blocco a no calcolo soglia anomalia
		// if ( CriterioAggiudicazione == '25532' || CriterioAggiudicazione == '16291' ) 
		// {
			// FilterDom( 'CalcoloAnomalia' ,  'CalcoloAnomalia' , '0' , 'SQL_WHERE=tdrcodice = \'0\' ' , '' , ''); //-- solo no
			// SelectreadOnly( 'CalcoloAnomalia' , true );
			// SelectreadOnly('OffAnomale',true);
		// }

    }
	else
	{
		verifyModalitaDiCalcoloAnomalia();
	}

    try
	{
		if (getObj('TipoProceduraCaratteristica').value == 'RDO')
		{
            //per le RDO se Lista Albi � vuoto allora disabilito le classi di iscrizione
            if (getObj('ListaAlbi').value == '') {
                DisableObj('ClasseIscriz', true);
            } else {
                DisableObj('ClasseIscriz', false);
            }
            //filtro le classi iscrizione in base all'albo scelto solo se il documento � in lavorazione
            if (getObjValue('StatoFunzionale') == 'InLavorazione') {

                var class_bando = getObj('ClasseIscriz_Bando').value;
                var filter = '';

                filter = GetProperty(getObj('ClasseIscriz'), 'filter');

                if (filter == '' || filter == undefined || filter == null) {
                    SetProperty(getObj('ClasseIscriz'), 'filter', 'SQL_WHERE= dmv_cod in (  select top 1000000  B.dmv_cod  from ClasseIscriz a  INNER JOIN ClasseIscriz B ON a.dmv_father = left( b.dmv_father , len ( a.dmv_father ) )  or  b.dmv_father = \'000.\'  or b.dmv_father = left( a.dmv_father , len ( b.dmv_father ) )     where  \'' + class_bando + '\' like \'%###\' + A.DMV_COD + \'###%\'    )');

                }
            }

        }

    } catch (e) {}

    //nascondo la busta tecnica per i lotti che non ne hanno bisogno
    try{HideBustaTecnicaLotti();}catch(e){};

    //Se il documento � editabile
    if ( DOCUMENT_READONLY_LOCAL == '0' ) { 
        
		var filter='';
        //se diverso da COTTIMO tolgo LAVORI dall'ambito
        /*if (getObj('TipoProceduraCaratteristica').value != 'Cottimo') {
            var filter = 'SQL_WHERE=  DMV_Cod <> 6';
            
        }*/
		
		
        
        //solo per le RDO nascondi i farmaci e LAVORI dall'ambito
        if (getObj('TipoProceduraCaratteristica').value == 'RDO') {
            filter = 'SQL_WHERE=  DMV_Cod <> 1 and DMV_Cod <> 6';
            //FilterDom('RTESTATA_PRODOTTI_MODEL_Ambito', 'Ambito', getObjValue('RTESTATA_PRODOTTI_MODEL_Ambito'), filter, 'TESTATA_PRODOTTI_MODEL', 'OnChangeAmbito( this );');
        }
        
        
		try
		{
			FilterDom('RTESTATA_PRODOTTI_MODEL_Ambito', 'Ambito', getObjValue('RTESTATA_PRODOTTI_MODEL_Ambito'), filter, 'TESTATA_PRODOTTI_MODEL', 'OnChangeAmbito( this );');
		}
		catch(e)
		{
		}
        
    }

    //nascondo le sezioni delle SOA se tipoappalto non � lavori

    if ( getObj('TipoAppaltoGara').value != '2') 
	{
		try
		{
			setVisibility(getObj('InfoTec_CategoriaPrevalente'), 'none');
		}
		catch(e)
		{}
        
		try
		{
			setVisibility(getObj('InfoTec_CategoriaScorporabile'), 'none');
		}
		catch(e)
		{}
    }

    //Se il documento � editabile
   // if (DOCUMENT_READONLY == '0') {
        FilterDominio();
    //}

    //-- abilito il coefficiente X in funzione della formula
    OnChangeFormula(this);
	
	//OPERAZIONI PER COSTO FISSO
	if ( CriterioAggiudicazione == '25532' )
	{
	  //nascondere 'PunteggioEconomico' e porre a zero, rendere readonly PunteggioTecnico e porlo a 100
	  //Se il documento � editabile
	  if ( DOCUMENT_READONLY_LOCAL == '0') 
	  {
		  SetNumericValue('PunteggioEconomico', 0);
		  SetNumericValue('PunteggioTecnico', 100);
		  NumberreadOnly( 'PunteggioTecnico' , true );
	  }
	  $("#cap_PunteggioEconomico").parents("table:first").css({"display": "none"})	  	  
	  //vengono nascoste le sezioni dei criteri economici CRITERI_ECO_TESTATA e CRITERI_ECO_RIGHE
	  setVisibility(getObj('CRITERI_ECO_TESTATA'), 'none');
	  setVisibility(getObj('CRITERI_ECO_RIGHE'), 'none');
	}
	
	//OPERAZIONI PER PREZZO ALTO O BASSO
	if ( CriterioAggiudicazione == '15531' ||  CriterioAggiudicazione == '16291')
	{
        try{
            //nascondere 'PunteggioEconomico' e porre a zero, rendere readonly PunteggioTecnico e porlo a 100
            //Se il documento � editabile
            if ( DOCUMENT_READONLY_LOCAL == '0') 
            {
                SetNumericValue('PunteggioEconomico', 100);
                SetNumericValue('PunteggioTecnico', 0);
				SetNumericValue('PunteggioTecMin', 0);
                NumberreadOnly( 'PunteggioEconomico' , true );
            }
            
            $("#cap_PunteggioTecnico").parents("table:first").css({"display": "none"})	  	  
            $("#cap_PunteggioTecMin").parents("table:first").css({"display": "none"})	  	  
            
            //vengono nascoste le sezioni dei criteri TEC
            
			try{ setVisibility(getObj('div_CRITERIGrid'), 'none'); }catch (e) {}
			try{ setVisibility(getObj('CRITERI'), 'none'); }catch (e) {}
			
            
            //-- vengono nascoste le aree relative ai criteri tecnici
            try {
                getObj('BANDO_SEMPLIFICATO_CRITERI_ECO').rows[7].style.display = 'none';
                getObj('BANDO_SEMPLIFICATO_CRITERI_ECO').rows[8].style.display = 'none';
                getObj('BANDO_SEMPLIFICATO_CRITERI_ECO').rows[9].style.display = 'none';
                getObj('BANDO_SEMPLIFICATO_CRITERI_ECO').rows[10].style.display = 'none';
                getObj('BANDO_SEMPLIFICATO_CRITERI_ECO').rows[11].style.display = 'none';
                getObj('BANDO_SEMPLIFICATO_CRITERI_ECO').rows[12].style.display = 'none';
                getObj('BANDO_SEMPLIFICATO_CRITERI_ECO').rows[2].style.display = 'none';
            } catch (e) {}      

        } catch (e) {}      

	}
	
	try
	{
		if (getObjValue('Divisione_lotti') == '0') 
		{
			$("#cap_Num_max_lotti_offerti").parents("table:first").css({"display": "none"})	
			
			//Se la gara � senza lotti nascondo la colonna 'Lotti' all'interno della sezione 'offerte ricevute' 
			ShowCol( 'LISTA_OFFERTE' , 'lottiOfferti' , 'none' );
			
		}
	 } catch (e) {}
	 
	 
	 try
	{
		if( getObjValue( 'DOCUMENT_READONLY') == '0' )
		{
			getObj('PresenzaDGUE' ).onchange = DGUE_Request_Active;
			getObj('PresenzaDGUE_Mandanti' ).onchange = DGUE_Request_Active_Mandanti;
			getObj('PresenzaDGUE_Ausiliarie' ).onchange = DGUE_Request_Active_Ausiliarie;
			getObj('PresenzaDGUE_Subappaltarici' ).onchange = DGUE_Request_Active_Subappaltarici;
			getObj('PresenzaDGUE_SubAppalto' ).onchange = DGUE_Request_Active_Subappalto;
		}
	}catch(e){}

	if ( DOCUMENT_READONLY_LOCAL == '0') 
	{	
		if ( getObj('RTESTATA_PRODOTTI_MODEL_EsitoRiga') )
		{
			if ( getObj('RTESTATA_PRODOTTI_MODEL_EsitoRiga').value.indexOf('State_ERR.gif') >= 0)
				document.getElementById('Cell_EsitoRiga').className='Evidenzia_Bordo_Cella';
		}
		
	}
	
	
	onChangeGeneraConvenzione( 0 );
	
	if (getObjValue('ProceduraGara') == '15583' || getObjValue('ProceduraGara') == '15479' ) //-- AFFIDAMENTO DIRETTO oppure RICHIESTA DI PREVENTIVO
    {
		//sulla gara, nell'elenco lotti , nascondere la colonna che consente di specializzare il criterio di valutazione per singolo lotto.
		ShowCol( 'LISTA_BUSTE' , 'Criteri_di_valutaz' , 'none' );
	}
	//try{OnChangeSedutaVirtuale();}catch(e){}
	
	
	//se doc non � readonly applico filtro ai riferimenti
	if ( DOCUMENT_READONLY_LOCAL == '0') {
		
		try{
			FilterRiferimenti();
			
		}catch(e){}
			
        //IMPOSTO UN EVENTO DI ONCHANGESULLEDATE PER LE QUALI E' RICHIESTO UN CONTROLLO CHE NON RICADONO IN UN FERMO SISTEMA
		//CONSERVANDO UNO PRECEDENTE SE LO TROVA		
		try{
			onchangepresente = GetProperty(getObj('DataTermineQuesiti_V'),'onchange');		
			if ( onchangepresente == null )
			{
				onchangepresente='';
			}
			if (  onchangepresente != '' && onchangepresente.indexOf(";",onchangepresente.length-1) < 0 )
			{
				onchangepresente=onchangepresente + ';';
			}	
			onchangepresente=onchangepresente + 'onChangeCheckFermoSistema(this);';
			getObj('DataTermineQuesiti_V' ).setAttribute('onchange', onchangepresente );		
			getObj('DataTermineQuesiti_HH_V' ).setAttribute('onchange', 'onChangeCheckFermoSistema(this);');		
			getObj('DataTermineQuesiti_MM_V' ).setAttribute('onchange', 'onChangeCheckFermoSistema(this);');	
			
		}catch(e){}	
		
		try{
			
			onchangepresente = GetProperty(getObj('DataScadenzaOfferta_V'),'onchange');
			if ( onchangepresente == null )
			{
				onchangepresente='';
			}
			if (  onchangepresente != '' && onchangepresente.indexOf(";",onchangepresente.length-1) < 0 )
			{
				onchangepresente=onchangepresente + ';';
			}
			onchangepresente=onchangepresente + 'onChangeCheckFermoSistema(this);';
			getObj('DataScadenzaOfferta_V' ).setAttribute('onchange', onchangepresente);  
			getObj('DataScadenzaOfferta_HH_V' ).setAttribute('onchange', 'onChangeCheckFermoSistema(this);');		
			getObj('DataScadenzaOfferta_MM_V' ).setAttribute('onchange', 'onChangeCheckFermoSistema(this);');		
			
		}catch(e){}	
		
		//SULLA RDO NON PRESENTE
		try
		{
			onchangepresente = GetProperty(getObj('DataAperturaOfferte_V'),'onchange');
			if ( onchangepresente == null )
			{
				onchangepresente='';
			}
			
			if (  onchangepresente != '' && onchangepresente.indexOf(";",onchangepresente.length-1) < 0 )
			{
				onchangepresente=onchangepresente + ';';
			}	
			onchangepresente=onchangepresente + 'onChangeCheckFermoSistema(this);';
			getObj('DataAperturaOfferte_V' ).setAttribute('onchange', onchangepresente );  
			getObj('DataAperturaOfferte_HH_V' ).setAttribute('onchange','onChangeCheckFermoSistema(this);');		
			getObj('DataAperturaOfferte_MM_V' ).setAttribute('onchange','onChangeCheckFermoSistema(this);');		
	
		}catch(e){}

		try
		{
		//SETTO onChangeCheckFermoSistema anche sul campo Data Termine Risposta Quesiti
			onchangepresente = GetProperty(getObj('DataTermineRispostaQuesiti_V'),'onchange');
			if ( onchangepresente == null )
			{
				onchangepresente='';
			}
			
			if (  onchangepresente != '' && onchangepresente.indexOf(";",onchangepresente.length-1) < 0 )
			{
				onchangepresente=onchangepresente + ';';
			}	
			onchangepresente = onchangepresente + 'onChangeCheckFermoSistema(this);';
			getObj('DataTermineRispostaQuesiti_V' ).setAttribute('onchange', onchangepresente );  
			getObj('DataTermineRispostaQuesiti_HH_V' ).setAttribute('onchange','onChangeCheckFermoSistema(this);');		
			getObj('DataTermineRispostaQuesiti_MM_V' ).setAttribute('onchange','onChangeCheckFermoSistema(this);');
			
		}catch(e){}
	}	
	
	
	try
	{
		if (getObjValue('ProceduraGara') == '15477' && getObjValue('TipoBandoGara') == '2')
		{		
			setVisibility(getObj('cap_DataAperturaOfferte').offsetParent.offsetParent, 'none');
		}
	}catch(e){}
	
	//GESTIONE ENTE PROPONENTE
	try
	{
		if ( DOCUMENT_READONLY_LOCAL == '0' ) 
		{
			filtraRupProponente();
			
		}
	}catch(e){}
	
	//PER LE GARE CHE NON SONO economicamente vantaggiose 15532  e non sono costo fisso 25532 oppure nei primi giri delle gare : ristretta bando e negoziata avviso
	//NASCONDIAMO il campo visualizzazione offerta tecnica
	if ( ( CriterioAggiudicazione != '15532' && CriterioAggiudicazione != '25532' )|| ( getObjValue('ProceduraGara') == '15477' && getObjValue('TipoBandoGara') == '2' ) || ( getObjValue('ProceduraGara') == '1548' && getObjValue('TipoBandoGara') == '1' ) )
	{
		$("#cap_Visualizzazione_Offerta_Tecnica").parents("table:first").css({"display": "none"});
	}
	
	
	//-- conservo il valore iniziale del criterio attribuzione punteggio per controllare cosa aveva nel caso in cui dovesse cambiare
	if (getObj('ModAttribPunteggio') )
		gModAttribPunteggio = getObjValue('ModAttribPunteggio'); 
	
	//-- conservo il valore iniziale di Divisione_lotti
	oldDivisione_lotti = getObjValue('Divisione_lotti');
	
	//-- conservo il valore iniziale di CriterioAggiudicazioneGara
	oldCriterioAggiudicazioneGara = getObjValue('CriterioAggiudicazioneGara');
	
	//-- conservo il valore iniziale di CriterioAggiudicazioneGara
	oldConformita = getObjValue('Conformita');	
	
	onChange_Visualizzazione_Offerta_Tecnica('onload');
	
	
	//Azione per recuperare il modello selezionato solo se il documento editabile
	//se TipoBandoScelta � vuoto
	//se TipoBando valorizzato allora deduco TipoBandoScelta da TipoBando
	if ( DOCUMENT_READONLY_LOCAL == '0' ) 
	{
		
		var strValueTipoBandoScelta ='';
		var strTipoBando = getObjValue('TipoBando');
		
		//getObj('val_Appalto_Verde').innerHTML=getObj('val_RTESTATA_PRODOTTI_MODEL_TipoBandoScelta').innerHTML;
		
		if ( strTipoBando != '' )
		{
			strValueTipoBandoScelta = ReplaceExtended(strTipoBando, '_' + getObj('IDDOC').value , '');
			//strValueTipoBandoScelta = strValueTipoBandoScelta + 'old';
			
			if ( getObjValue('RTESTATA_PRODOTTI_MODEL_TipoBandoScelta') == '' )
			{ 
					
				//SetTextValue( 'RTESTATA_PRODOTTI_MODEL_TipoBandoScelta', strValueTipoBandoScelta );
				SetDomValue( 'RTESTATA_PRODOTTI_MODEL_TipoBandoScelta', strValueTipoBandoScelta );
				
				//se cmq vuoto messaggio "il modello precedentemente selezionato non risulta pi� valido".
				//effettuare di nuovo la selezione sulla sezione Prodotti nel campo 
				if ( getObjValue('RTESTATA_PRODOTTI_MODEL_TipoBandoScelta') == '' )
						
					DMessageBox('../', 'il modello precedentemente selezionato non risulta valido.riselezionare nei prodotti', 'Attenzione', 1, 400, 300);

           
			}
		}
	}
	
	try
	{
		var tpc = getObjValue('TipoProceduraCaratteristica');
		var LD = getObjValue('LinkedDoc');
	
		if ( tpc == 'RFQ'  && LD != '0' )
		{
			setVisibility(getObj('RTESTATA_PRODOTTI_MODEL_FNZ_OPEN'), 'none');
			setVisibility(getObj('cap_FNZ_OPEN'), 'none');
			// per nascondere elemento di help privo di ID
			setVisibility(getObj('RTESTATA_PRODOTTI_MODEL_FNZ_OPEN').parentNode.parentNode, 'none');
		
			ShowCol( 'PRODOTTI' , 'FNZ_DEL','none');
		}
		
		//se affidamento diretto semplificato nascondo AttivaFilePending
		//i campi della testata prodotti per la selezione del foglio excel
		if ( tpc == 'AffidamentoSemplificato' ) 
		{
			setVisibility(getObj('PARAMETRI'), 'none');
			setVisibility(getObj('cap_FNZ_OPEN'), 'none');
			setVisibility(getObj('RTESTATA_PRODOTTI_MODEL_FNZ_OPEN').parentNode.parentNode, 'none');
			setVisibility(getObj('cap_FNZ_ADD'), 'none');
			setVisibility(getObj('RTESTATA_PRODOTTI_MODEL_FNZ_ADD').parentNode.parentNode, 'none');
			setVisibility(getObj('cap_Allegato'), 'none');
			
		}
		
	}catch(e){}
	
	
	
	//nascondo i campi per OCP se non richiesti
	if ( getObj('Show_Attrib_OCP')  ) 
	{
		if ( getObj('Show_Attrib_OCP').value == '0' )
		{
			try
			{
				//$("#cap_NumeroIndizione").parents("table:first").css({"display": "none"});
				//$("#cap_DataIndizione").parents("table:first").css({"display": "none"});
				$("#cap_AllegatoPerOCP").parents("table:first").css({"display": "none"});
			}catch(e){}
		}
	}
	
	
	if ( DOCUMENT_READONLY_LOCAL == '0' ) 
	{
		set_Complex();
		set_Criteri();
		
		ActiveDrag();	
		
	}else
	{
		HideColDrag();
	}	
	
	//nascondo/visualizzo i campi del modulo MODULO_APPALTO_PNRR_PNC	 
	Handle_Attrib_MODULO_APPALTO_PNRR_PNC( 0 );	 
	
	
	//Se il documento � editabile e sono visibili setto il filtro sui campi "Stazione Appaltante" e "U. O. Espletante"
	Handle_Attrib_Struttura_Appartenenza ( ) ;
	
	//SETTA IL CAMPO "Presunto Importo Appalto"
	//solo per AFFIDAMENTO DIRETTO SEMPLIFICATO
	if ( DOCUMENT_READONLY_LOCAL == '0' ) 
	{	
		if ( getObj('TipoProceduraCaratteristica').value == 'AffidamentoSemplificato' )
			SetPresuntoImporto();
	}
	
	//gestione dell'opzione superamento base asta su tuTte le Tipologie di gare 
	CheckControlloSuperamentoImportoGara()
	
	//setto il filtro sul campo Identificativoiniziativa se attivo il modulo GROUP_PROGRAMMAZIONI_INIZIATIVE
	SetFilterIniziative_FromRup();
	
	//Controllo se il valore di DPCM è da cambiare dopo aver importato il campo dall'iniziativa
	try
	{
		OnChangeCategorieMerceologiche();
	}
	catch(e){}
	
	AllineaQuestionario_PresenzaDGUE();

	ChangeImportoConcorso();
}

function CheckControlloSuperamentoImportoGara()
{	
	var superamentoIportoGara = document.getElementById('Controllo_superamento_importo_gara');
	var TipoProcedura = getObj('TipoProceduraCaratteristica').value
	var proceduragara = document.getElementById('ProceduraGara').value;
	var TipoBandoGara = document.getElementById('TipoBandoGara').value;

	//-- se non sono in una di queste combinazioni di gara devo nascondere il campo
	if (!(
		(proceduragara == '15476' && TipoBandoGara == '2') //aperta - offerta
		||
		(proceduragara == '15477' && TipoBandoGara == '3') //ristretta - invito
		||
		(proceduragara == '15478' && TipoBandoGara == '3') //negoziata - invito
		||
		!TipoProcedura == 'RDO'
	))
	{
		try{
			
			// setVisibility(getObj('Controllo_superamento_importo_gara'), 'none');
			//setVisibility(getObj('Cell_Controllo_superamento_importo_gara').offsetParent.offsetParent, '');
			setVisibility(getObj('Cell_Controllo_superamento_importo_gara').parentNode.parentNode.parentNode.parentNode.parentNode.parentNode, 'none');
		}
		catch(e){}
	}
	
	
}

function SetPresuntoImporto()
{
	
	var importo = document.getElementById('RPRODOTTIGrid_0_VALORE_BASE_ASTA_IVA_ESCLUSA').value;
	var campoPresuntoImporto = document.getElementById('importoBaseAsta2');
	var campoPresuntoImporto2 = document.getElementById('importoBaseAsta2_V');
	
	campoPresuntoImporto.value = importo;
	campoPresuntoImporto2.value = importo;
}

function onChange_Visualizzazione_Offerta_Tecnica(param)
{
	if ( getObjValue('Visualizzazione_Offerta_Tecnica')  != 'due_fasi' )
	{
		ShowCol( 'CRITERI' , 'Allegati_da_oscurare' , 'none' );
	}
	else
	{
		ShowCol( 'CRITERI' , 'Allegati_da_oscurare' , '' );
	}
	if ( param != 'onload' )
		flagmodifica();
}
//FINE ONLOADPAGE SQL_WHERE=  dmv_cod in (Select DMV_COD from ELENCO_RESPONSABILI where idpfu =  <ID_USER>  and RUOLO in ('RUP_PDG') )
function filtraRupProponente()
{
	var filter=''
	var EnteProponente=getObjValue('EnteProponente').split('#')[0];	
	var enteappaltante=getObjValue('Azienda');
	
	//if ( EnteProponente == enteappaltante ) //se coincidono stesso filtro presente sul RUP anche su RUP proponente ed il campo � bloccato
	//{
	//	filter =  'SQL_WHERE=  dmv_cod in (Select DMV_COD from ELENCO_RESPONSABILI where idpfu =  <ID_USER>  and RUOLO in (\'RUP_PDG\') )';
	//	FilterDom( 'RupProponente' , 'RupProponente' , getObj('val_UserRUP_extraAttrib').value.split('#=#')[1] , filter ,'', '','TD','','');
	//	//SelectreadOnly( 'RupProponente' , true );
	//}
	//else
	{
		//SelectreadOnly( 'RupProponente' , false );
		
		
		//gestito il caso in cui 'EnteProponente' non è avvalorato, svuotando quindi la select del RUP
		if (EnteProponente != '' && EnteProponente != null)
			filter =  'SQL_WHERE= dmv_cod in (Select DMV_COD from ELENCO_RESPONSABILI_AZI  where RUOLO in (\'RUP\',\'RUP_PDG\') and idpfu = (select top 1 idpfu from ProfiliUtente where pfuIdAzi=' + EnteProponente + ') )';
		else
			filter =  'SQL_WHERE= dmv_cod in (Select DMV_COD from ELENCO_RESPONSABILI_AZI  where RUOLO in (\'RUP\',\'RUP_PDG\') and idpfu = (select top 1 idpfu from ProfiliUtente where pfuIdAzi= -1) )';

		//filter =  'SQL_WHERE= dmv_cod in (Select DMV_COD from ELENCO_RESPONSABILI_AZI  where RUOLO in (\'RUP\',\'RUP_PDG\') and idpfu = (select top 1 idpfu from ProfiliUtente where pfuIdAzi=' + EnteProponente + ') )';
		FilterDom( 'RupProponente' , 'RupProponente' , getObj('val_RupProponente_extraAttrib').value.split('#=#')[1] , filter ,'', '');
	}
	
	
}

function onchangeEnteProponente ()
{
	filtraRupProponente();
}


function onchangeAppalto_Verde() {
    try {
        if (getObjValue('Appalto_Verde') != 'si') {
            getObj('Motivazione_Appalto_Verde').value = '';
            //getObj('Motivazione_Appalto_Verde').disabled = true;
			ReadOnlyObj('Motivazione_Appalto_Verde',true);

        }
    } catch (e) {}
    try {
        if (getObjValue('Appalto_Verde') == 'si') {

            //getObj('Motivazione_Appalto_Verde').disabled = false;
			ReadOnlyObj('Motivazione_Appalto_Verde',false);

        }
    } catch (e) {}

}

function onchangeAcquisto_Sociale() {
    try {
        if (getObjValue('Acquisto_Sociale') != 'si') {
            getObj('Motivazione_Acquisto_Sociale').value = '';
            //getObj('Motivazione_Acquisto_Sociale').disabled = true;
			ReadOnlyObj('Motivazione_Acquisto_Sociale',true);

        }
    } catch (e) {}
    try {
        if (getObjValue('Acquisto_Sociale') == 'si') {
            //getObj('Motivazione_Acquisto_Sociale').disabled = false;
			ReadOnlyObj('Motivazione_Acquisto_Sociale',false);

        }
    } catch (e) {}

}

function onchangeGenderEquality() {
    try {
        if (getObjValue('GenderEquality') != 'si') {
            getObj('GenderEqualityMotivazione').value = '';
            //getObj('GenderEqualityMotivazione').disabled = true;
			ReadOnlyObj('GenderEqualityMotivazione',true);

        }
    } catch (e) {}
    try {
        if (getObjValue('GenderEquality') == 'si') {
            //getObj('GenderEqualityMotivazione').disabled = false;
			ReadOnlyObj('GenderEqualityMotivazione',false);

        }
    } catch (e) {}

}


function OnChangeAmbito() 
{
    var iddoc = getObj('IDDOC').value;

    var Ambito = getObjValue('RTESTATA_PRODOTTI_MODEL_Ambito');

    if (getObjValue('TipoBando') != '') 
	{
        alert(CNV('../', 'Il cambio dell\'ambito comporta un azzeramento del modello dei prodotti'));

        ExecDocProcess('SVUOTA_SOLO_MODELLO_PRODOTTI,BANDO_GARA');

    } 
	else 
	{
		if ( getObjValue('CriterioFormulazioneOfferte') == '' )
			alert(CNV('../', 'Per proseguire con la selezione del modello scegliere un valore per il campo Criterio Formulazione Offerta Economica'));
		
        FiltraModelli();
    }
}


function FiltraModelli() {
    try {
        if (getObjValue('StatoFunzionale') == 'InLavorazione') {

            var Ambito = getObjValue('RTESTATA_PRODOTTI_MODEL_Ambito');
            var Criterio = getObjValue('CriterioFormulazioneOfferte');
            var Conform = getObjValue('Conformita');
            var CriterioAggiudicazione = getObjValue('CriterioAggiudicazioneGara');
			try{ var TipoProceduraCaratteristica=getObj('TipoProceduraCaratteristica').value;}catch(e){ TipoProceduraCaratteristica = '';};
			var ProceduraGara=getObjValue('ProceduraGara');
            var Complex = getObjValue('Complex');
            var Monolotto = 0;
            if (Complex == '') {
                Complex = 0;
            }
			var TipoBandoGara = getObjValue('TipoBandoGara')

            if (getObjValue('Divisione_lotti') == '0') {
                Monolotto = 1
            }

            //var filter = 'SQL_WHERE= DMV_Father  <> \'1\' and DMV_Cod in ( select codice  from View_Modelli_Lotti where  CriterioFormulazioneOfferte = \'' + Criterio + '\'  and CriterioAggiudicazioneGara like \'%###' + CriterioAggiudicazione + '###%\' and Conformita like \'%###' + Conform + '###%\' and Complex = ' + Complex + ' and Ambito = \'' + Ambito + '\' and Monolotto = ' + Monolotto + ' )';
			
			var filter = 'SQL_WHERE= DMV_Father  <> \'1\' and DMV_Cod in ( select codice  from View_Modelli_Lotti where  TipoProcedureApplicate like \'%###\' + dbo.GetDescTipoProcedura( \'BANDO_GARA\' , \'' + TipoProceduraCaratteristica + '\' , \'' + ProceduraGara + '\', \'' + TipoBandoGara + '\' ) + \'###%\' and  CriterioFormulazioneOfferte = \'' + Criterio + '\'  and CriterioAggiudicazioneGara like \'%###' + CriterioAggiudicazione + '###%\' and Complex = ' + Complex + ' and Ambito = \'' + Ambito + '\' and Monolotto = ' + Monolotto ;
			
			//se OEPV oppure costo fisso non applico la condizione della conformita al filtro
			if ( CriterioAggiudicazione == '15532' || CriterioAggiudicazione == '25532' ){
			
				filter = filter  +	' )';
			
			}else{
				
				filter = filter  + ' and Conformita like \'%###' + Conform + '###%\'' + ' )';
			}
			
			
            FilterDom('RTESTATA_PRODOTTI_MODEL_TipoBandoScelta', 'TipoBandoScelta', getObjValue('RTESTATA_PRODOTTI_MODEL_TipoBandoScelta'), filter, 'TESTATA_PRODOTTI_MODEL', 'OnChangeModello( this );');
        }
    } catch (e) {};

}



function RefreshContent() {

    if (getObjValue('StatoFunzionale') != 'InLavorazione') {
        RefreshDocument('');
    } else {
        ExecDocCommand('LISTA_BUSTE#RELOAD');
        ExecDocCommand('DESTINATARI_1#RELOAD');

    }
}


function CreateBandoSemplificato(objGrid, Row, c) {
    var cod;
    //-- recupero il codice della riga passata
    cod = GetIdRow(objGrid, Row, 'self');
    var w = screen.availWidth;
    var h = screen.availHeight;
    parent.opener.DOC_NewDocumentFrom('BANDO_SEMPLIFICATO#BANDO_SDA_ADERENTE,' + cod + '#' + w + ',' + h + '###../ctl_library/document/document.asp?');

    parent.parent.close();
}

function OnChangePrimaSeduta(obj) {
    try {
        if (getObj('GG_PrimaSeduta').value > 3) {
            //DMessageBox( '../' , 'La data di prima seduta viene calcolata sommando il numero di giorni inseriti alla data scadenza offerta' , 'Attenzione' , 1 , 400 , 300 );
        }
    } catch (e) {};

}

function OnChangeQuesito(obj) {
    try {
        if (getObj('RichiestaQuesito').value == '2') {
            getObj('gg_QuesitiScadenza_V').disabled = true;
            SetNumericValue('gg_QuesitiScadenza', 0);
        } else {
            getObj('gg_QuesitiScadenza_V').disabled = false;
        }
    } catch (e) {};

}

function OnChangeTipoBando(obj) {

    //-- aggiorna il modello da usare per la sezione prodotti
    //ExecDocProcess( 'SELECT_MODELLO_SDA,BANDO_SDA');
}

//-- associo il nuovo modello al documento 
function OnChangeModello(o) {
   
	//-- verifico che siano state selezioante delle classi di iscrizione prima di proseguire
    if (getObj('TipoProceduraCaratteristica').value == 'RDO') {
        if (getObj('ClasseIscriz').value == '') {
            getObj('TipoBando').value = '';
            //getObj('RTESTATA_PRODOTTI_MODEL_TipoBando').value = '';

            DocShowFolder('FLD_COPERTINA');
            getObj('ClasseIscriz_button').focus();
            DMessageBox('../', 'E\' necessario selezionare prima le Classi merceologiche', 'Attenzione', 1, 400, 300);

            return;
        }
    }
	
	//GESTIONE FATTA PER EVITARE DI LASCIARE VALORI ERRATI IN TipoBandoScelta quando il conferma del modello va in eccezione
	 try 
	 {
		SetTextValue( 'TipoBandoSceltaHide',getObjValue('RTESTATA_PRODOTTI_MODEL_TipoBandoScelta') );

		SetTextValue( 'RTESTATA_PRODOTTI_MODEL_TipoBandoScelta',getObjValue('TipoBandoSceltaOLD') );
	
	 } catch (e) { };
	

    //-- aggiorna il modello da usare per la sezione prodotti
    // ExecDocProcess( 'SELECT_MODELLO_SDA,BANDO_SDA');
    ExecDocProcess('SELECT_MODELLO_BANDO,BANDO');
}

function OnClickProdotti(obj) {
    var TipoBando = getObjValue('TipoBando');

    if (TipoBando == '') {
        //alert( CNV( '../','E\' necessario selezionare prima il modello'));
        DMessageBox('../', 'E\' necessario selezionare prima il modello', 'Attenzione', 1, 400, 300);
        return;
    }

    //-- verifico che siano state selezioante delle classi di iscrizione prima di proseguire
    if (getObj('TipoProceduraCaratteristica').value == 'RDO') {
        if (getObj('ClasseIscriz').value == '') {
            getObj('TipoBando').value = '';
            //getObj('RTESTATA_PRODOTTI_MODEL_TipoBando').value = '';

            DocShowFolder('FLD_COPERTINA');
            getObj('ClasseIscriz_button').focus();
            DMessageBox('../', 'E\' necessario selezionare prima le Classi merceologiche', 'Attenzione', 1, 400, 300);

            return;
        }
    }

	var DOCUMENT_READONLY;
    try{DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;}catch(e){ DOCUMENT_READONLY = '1'};
	
    if (DOCUMENT_READONLY == "1")
        DMessageBox('../', 'Documento in sola lettura', 'Attenzione', 1, 400, 300);
    else
        ImportExcel('CAPTION_ROW=yes&TITLE=Upload Excel&TABLE=CTL_Import&FIELD=RTESTATA_PRODOTTI_MODEL_Allegato&SHEET=0&PARAM=posizionale&PROCESS=LOAD_PRODOTTI,BANDO_GARA&OWNER_FIELD=Idpfu&OPERATION=INSERT#new#600,450');
}


function OnChangeClassIscriz(obj) {
    //-- svuoto i prodotti caricati ed il modello selezionato perch� potrebbe essere incoerente con le classi caricate
    //if( getObj( 'TipoBando').value != '' || DESTINATARI_1Grid_NumRow != -1 )
		
	
	
	var TPC  = getObj('TipoProceduraCaratteristica').value; //== 'RFQ')
	if ( TPC != 'RFQ' ) 
    {
        ExecDocProcess('SVUOTA_MODELLO_PRODOTTI,BANDO_GARA');
    }

}

function ChangeOE(param) {
    //-- verifico che siano state selezioante delle classi di iscrizione prima di proseguire
    if (getObj('TipoProceduraCaratteristica').value == 'RDO') {
        if (getObj('ClasseIscriz').value == '') {
            getObj('TipoBando').value = '';
            //getObj('RTESTATA_PRODOTTI_MODEL_TipoBando').value = '';

            DocShowFolder('FLD_COPERTINA');
            getObj('ClasseIscriz_button').focus();
            DMessageBox('../', 'E\' necessario selezionare prima le Classi merceologiche', 'Attenzione', 1, 400, 300);

            return;
        }
    }
	//VALE SOLO PER I LAVORI IL RAGIONAMENTO
	if ( getObj('TipoAppaltoGara').value == '2') 
	{
		//SE LA SENTINELLA VALE 1 faccio prima un SAVE
		if ( getObj('CategoriaSOA_CHANGE_TECNICA').value == '1' )
		{
			ExecDocProcess('FITTIZIO2,DOCUMENT,,NO_MSG');
			return;
		}
	}		
    MakeDocFrom(param);
}

function LISTA_DOCUMENTI_OnLoad() {
    OnChangeQuesito();

}

function DESTINATARI_1_OnLoad() {
    //DisplaySection();
}

function flagmodifica() 
{
	//alert(1);
    flag = 1;
}


function MySend(param) {
    //alert(param);
    if (ControlliSend(param,'wrng_data@@@no') == -1) return -1;
    ExecDocProcess(param);

}
function ControlliSend(param,param2) {

	if (param2 == undefined )
		param2='';
	
    var CriterioAggiudicazione = getObjValue('CriterioAggiudicazioneGara');
	var flag_warning_emergenza='';
	
	if ( param2 != '' )
	{
		flag_warning_emergenza = param2.split( '@@@' )[1]
	}
	var nCheckCottimoSoa = -1;
    var i = 0;
    var SommaPunteggiEreditati = 0.0;
	
	
	
	var dateObj = new Date();
    
	var Riferimento = zero(dateObj.getFullYear(), 4) + '-' + zero((dateObj.getMonth() + 1), 2) + '-' + zero(dateObj.getDate(), 2) ;

	//AGGIUNGO QUESTO CONTROLLO SOLO SE SULLA GARA IL CAMPO AppaltoInEmergena � nascosto
	//Le date del Bando non rispettano i requisiti minimi di distanza tra loro. Se si ci trova in un caso di emergenza premere il tasto �conferma�, altrimenti premere il tasto �Ignora� e controllare le date
	try{
			
		if ( getObj( 'AppaltoInEmergenza' ).type != 'select-one'  && flag_warning_emergenza != 'no' && getObj('TipoProceduraCaratteristica').value != 'AffidamentoSemplificato' )
		{
			var warning_emergenza;
			warning_emergenza=false;
			
			//Controllo se Data Termine Risposta quesiti sia superiore ad oggi 
			if ( getObjValue('DataTermineRispostaQuesiti') !='' &&  getObjValue('DataTermineRispostaQuesiti').substring(0,10) <= Riferimento ) 
			{
				warning_emergenza=true;
			}
			
			//Controllo se Data Termine Quesiti quesiti sia superiore ad oggi 
			if ( getObjValue('DataTermineQuesiti') !='' && getObjValue('DataTermineQuesiti').substring(0,10) <= Riferimento ) 
			{
				warning_emergenza=true;
			}
			
			//Controllo se Data Termine Quesiti quesiti sia superiore ad oggi 
			if ( getObjValue('DataScadenzaOfferta') !='' &&  getObjValue('DataScadenzaOfferta').substring(0,10) <= Riferimento ) 
			{
				warning_emergenza=true;
			}
			
			
			//-- controllo le date in coerenza con la tipologia di documento
			if (getObjValue('ProceduraGara') == '15478' && ( getObjValue('TipoBandoGara') == '4' || getObjValue('TipoBandoGara') == '1' ) ) //-- Negoziata - Avviso con risposta
			{
				if ( getObjValue('DataRiferimentoInizio') !='' &&  getObjValue('DataRiferimentoInizio').substring(0,10) <= Riferimento ) 
				{
					warning_emergenza=true;
				}
			}	

			if ( warning_emergenza == true )
			{
				var ML_text = 'Le date del Bando non rispettano i termini minimi per la proposizione delle risposte. Se si ci trova in un caso di emergenza premere il tasto "conferma", altrimenti premere il tasto "Ignora" e controllare le date.';
				var Title = 'Informazione';					
				var ICO = 3;
				var page = 'ctl_library/MessageBoxWin.asp?MODALE=YES&ML=YES&MSG=' + encodeURIComponent( ML_text ) +'&CAPTION=' + encodeURIComponent(Title) + '&ICO=' + encodeURIComponent(ICO);
						
				ExecFunctionModaleConfirm( page, Title , 200 , 400 , null , 'conferma_warning_emergenza@@@@' + param ,'cancel_warning_emergenza');
				return -1;
			}
			
		}
	}catch(e){};
	
	
	
	
	
	if( checkDataTermineQuesiti() == -1 ) return -1;
	if( checkDataScadenzaOfferta() == -1 ) return -1;


    //-- controlliamo che se gli avvisi non richiedono documentazione non deve essere com pilatra la scheda dei documenti richiesti
    /*
	try
    {
        if ( getObjValue( 'TipoBandoGara' ) == '1'   && getObjValue( 'RichiediDocumentazione' ) == '0' &&  getObj( 'DOCUMENTAZIONE_RICHIESTAGrid' ).rows.length > 1 )
        {
            DMessageBox('../', 'Quando "Richiedi Documentazione" e\' incato a "no" non e\' consentito compilare la scheda "Busta Documentazione"', 'Attenzione', 1, 400, 300);
            return -1;
        }    
    
    }
    catch(e){}
    */

	//se attivo Modulo MODULO_APPALTO_PNRR_PNC ed ho messo la spunta
	//verifico che ho selezionato almento 1 dei due campi "Appalto PNRR", "Appalto PNC" con il relativo commento
	try
	{
		var nMakeAlertPNRR_PNC;
		var Modulo_Attivo = getObj('ATTIVA_MODULO_PNRR_PNC').value  ;
		nMakeAlertPNRR_PNC = 0;
		
		if ( Modulo_Attivo == 'yes' )
		{	
			//recupero il valore della spunta
			if ( getObj('Appalto_PNRR_PNC').checked )
			{
				//se nessuno dei due selezionato avviso
				if ( 
					 ( getObj('Appalto_PNRR').value == '' && getObj('Appalto_PNC').value == '' ) 
						|| 
					 ( getObj('Appalto_PNRR').value == 'si' && getObjValue('Motivazione_Appalto_PNRR') == '' )
						||
					 ( getObj('Appalto_PNRR').value == '' && getObjValue('Motivazione_Appalto_PNRR') != '' )	
						||
					 ( getObj('Appalto_PNC').value == 'si' && getObjValue('Motivazione_Appalto_PNC') == '' )
						||	
					 ( getObj('Appalto_PNC').value == '' && getObjValue('Motivazione_Appalto_PNC') != '' )
					)		
					
					nMakeAlertPNRR_PNC = 1;
				
				
				
				
			}
				
			if ( nMakeAlertPNRR_PNC == 1)
			{	
					DMessageBox( '../' , 'Valorizzare Appalto_PNRR e/o Appalto_PNC con la relativa motivazione' , 'Attenzione' , 1 , 400 , 300 );
					return -1;
			}
			
		}
	}catch(e){}
	
	//se la sezione dei criteri � presente 
	if ( getObj('FLD_CRITERI') )
	{						 
		//-- verifico una incompatibilit� dei punteggi sulle righe dei criteri
		if ( CheckCriteriPunteggi() == -1 ){
			DMessageBox( '../' , 'Verificare i punteggi dei criteri oggettivi, sono presenti domini o range con valori superiori rispetto al punteggio del criterio' , 'Attenzione' , 1 , 400 , 300 );
			return -1;
		}
	}

	
	var AQ_RILANCIO_COMPETITVO = '';
	try { AQ_RILANCIO_COMPETITVO = getObjValue( 'AQ_RILANCIO_COMPETITVO') } catch( e ){};
	

    //IN CASO DI COTTIMO CONTROLLO CHE CI SIA ALMENO UNA CATEGORIA PREVALENTE SELEZIONATA
    if (getObj('TipoProceduraCaratteristica').value == 'Cottimo') {

        //alert ( GetProperty( getObj('InfoTec_CategoriaPrevalenteGrid') , 'numrow') );
        if (GetProperty(getObj('InfoTec_CategoriaPrevalenteGrid'), 'numrow') != -1) {

            var k = 0;
            //alert(numrighe);
            for (i = 0; i <= GetProperty(getObj('InfoTec_CategoriaPrevalenteGrid'), 'numrow'); i++) {
                //alert(getObjValue('RInfoTec_CategoriaPrevalenteGrid_'+i+'_CategoriaSOA_edit'));
                if (getObjValue('RInfoTec_CategoriaPrevalenteGrid_' + i + '_CategoriaSOA_edit') != '' && getObjValue('RInfoTec_CategoriaPrevalenteGrid_' + i + '_ClassificaSOA') != '') {
                    nCheckCottimoSoa = 0;
                    break;
                }
            }
        }

        //alert(nCheckCottimoSoa);

        if (nCheckCottimoSoa == -1) {
            DocShowFolder('FLD_TECH_INFO');
            tdoc();
            DMessageBox('../', 'Per un bando Cottimo selezionare almeno una categoria prevalente', 'Attenzione', 1, 400, 300);
            return -1;

        }

    }

	//se ho un importo appalto devo avere la base asta
	if (getObjValue('importoBaseAsta') != 0.0 ) {
		// if (getObjValue('importoBaseAsta2') == 0.0 ) 
		// {
			// getObj('importoBaseAsta2_V').focus();
			// DMessageBox('../', 'La presenza di un importo per i campi "Importo Opzioni" o di "Oneri" necessita\' anche un valore per "Importo Base Asta"', 'Attenzione', 1, 400, 300);
			// return -1;
		// }
		
		if (getObjValue('TipoIVA') == '' ) {

			getObj('TipoIVA').focus();
			DMessageBox('../', 'In presenza di un valore per Importo del Concorso e necessario selezionare un valore per il campo Iva', 'Attenzione', 1, 400, 300);
			return -1;
		}
		
	}	

    var criterio = getObjValue('CriterioAggiudicazioneGara');


   	//IF CHE EFFETTUA I CONTROLLI SUI CRITERI DI VALUTAZIONE, DA NON FARE LE GARE INFORMALI 
	
   // if ( //( criterio == '15532' || criterio == '25532' ) //-- coorisponde offerta economica vantaggiosa  oppure COSTOFISSO
	if ( 
		//( getObjValue('ProceduraGara') != '15583' && getObjValue('ProceduraGara') != '15479' ) //-- AFFIDAMENTO DIRETTO oppure RICHIESTA DI PREVENTIVO
		getObjValue('ProceduraGara') != '15583' //NON DEVE ESSERE AFFIDAMENTO DIRETTO
        &&
        //-- non deve essere "ristretta bando" o "negoziata avviso"
        !(getObjValue('ProceduraGara') == '15477' && getObjValue('TipoBandoGara') == '2') //-- ristretta Bando
        &&
        !(getObjValue('ProceduraGara') == '15478' && getObjValue('TipoBandoGara') == '1') //-- negoziata avviso
		&&
		!(getObjValue('ProceduraGara') == '15583' && (getObjValue('TipoBandoGara') == '4' || getObjValue('TipoBandoGara') == '5')) //affidamento diretto a due fase
	   ) 
	   {
		   
		//--OPERAZIONI che non sono PREZZO ALTO O BASSO controllo che sia stata selezionata se rieseguire i calcoli tecnici con esclusioni automatiche
		if ( criterio != '15531' &&  criterio != '16291')
		{
			if ( getObjValue('RicalcolaPerEsclusioni') == '' ) 
			{
				DocShowFolder('FLD_CRITERI');
				tdoc();
				DMessageBox('../', 'Selezionare un valore per "Ricalcola Punteggi Dopo Esclusioni"', 'Attenzione', 1, 400, 300);
				getObj('RicalcolaPerEsclusioni').focus();
				return -1;
			
			}
		}
		   
		   
        var PunteggioEconomico = parseFloat(getObjValue('PunteggioEconomico'));
        var PunteggioTecnico = parseFloat(getObjValue('PunteggioTecnico'));
        //solo per le gare diverse da tradizionale
        if (getObj('ModalitadiPartecipazione').value != '16307') {
            if ( criterio == '15532' )
			{
				if (PunteggioEconomico == 0 || getObjValue('PunteggioEconomico_V') == '') {
					DocShowFolder('FLD_CRITERI');
					tdoc();
					DMessageBox('../', 'Digitare un punteggio Economico superiore a 0', 'Attenzione', 1, 400, 300);
					getObj('PunteggioEconomico_V').focus();
					return -1;
				}
			}

			if ( criterio == '15532' || criterio == '25532' )  
            {
				//if (PunteggioTecnico == 0 || getObjValue('PunteggioTecnico_V') == '') {
				//modificato perchè nel modello messo il campo bloccato a 100
				if ( PunteggioTecnico == 0 ) {
					DocShowFolder('FLD_CRITERI');
					tdoc();
					DMessageBox('../', 'Digitare un punteggio Tecnico superiore a 0', 'Attenzione', 1, 400, 300);
					getObj('PunteggioTecnico_V').focus();
					return -1;
				}
			}

            if (PunteggioEconomico + PunteggioTecnico != 100) {
                DocShowFolder('FLD_CRITERI');
                tdoc();
                DMessageBox('../', 'La somma del punteggio tecnico e del punteggio economico deve essere 100', 'Attenzione', 1, 400, 300);
                getObj('PunteggioEconomico_V').focus();
                return -1;
            }
        }

		//per le gare al prezzo pi� basso non serve		
        if ( criterio != '15531' && getObjValue('PunteggioTecMin') != '' && getObjValue('PunteggioTecMin') > PunteggioTecnico) 
		{
            DocShowFolder('FLD_CRITERI');
            tdoc();
            DMessageBox('../', 'La soglia minima del punteggio Tecnico non puo\' essere maggiore del punteggio tecnico', 'Attenzione', 1, 400, 300);
            getObj('PunteggioTecMin_V').focus();
            return -1;
        }
        //solo per le gare diverse da tradizionale


        var strVersione;
        try {
            strVersione = getObjValue('Versione');
        } catch (e) {
            strVersione = '';
        }

		// Commentato perchè nel modello il campo è nascosato con valore 16308 (Telematica)
        // if (getObj('ModalitadiPartecipazione').value != '16307' && strVersione == '') {
            // if (getObjValue('FormulaEcoSDA') == '') {
                // DocShowFolder('FLD_CRITERI');
                // tdoc();
                // DMessageBox('../', 'Nella sezione dei criteri per la valutazione della busta economica selezionare il "Criterio Economica"', 'Attenzione', 1, 400, 300);
                // getObj('FormulaEcoSDA').focus();
                // return -1;
            // }
        // }

        //solo per le gare diverse da tradizionale
        if (getObj('ModalitadiPartecipazione').value != '16307' && strVersione == '') 
		{
            if (getObj('FormulaEcoSDA').value.indexOf(' Coefficiente X ') >= 0) 
			{
			
                if (getObjValue('Coefficiente_X') == '') 
				{
                    DocShowFolder('FLD_CRITERI');
                    tdoc();
                    DMessageBox('../', 'Nella sezione dei criteri per la valutazione della busta economica selezionare un valore per il campo "Coefficiente X"', 'Attenzione', 1, 400, 300);
                    getObj('Coefficiente_X').focus();
                    return -1;
                }
            }
			
        }
        //controlli sulla griglia
        //solo per le gare diverse da tradizionale
        if (getObj('ModalitadiPartecipazione').value != '16307' && ( criterio == '15532' || criterio == '25532' )  )  {
            if (GetProperty(getObj('CRITERIGrid'), 'numrow') == -1) {
                DocShowFolder('FLD_CRITERI');
                tdoc();
                DMessageBox('../', 'Nella griglia Criteri di valutazione busta tecnica deve essere presente almeno una riga.', 'Attenzione', 1, 400, 300);
                return -1;

            }
        }

        if ( GetProperty(getObj('CRITERIGrid'), 'numrow') != -1 && CriterioAggiudicazione != '15531' &&  CriterioAggiudicazione != '16291' ) {
            var numrighe = GetProperty(getObj('CRITERIGrid'), 'numrow');
            i = 0;
            var k = 0;
            var totpunteggiorighe = 0;
            SommaPunteggiEreditati = 0.0;
            
            //alert(numrighe);
            for (i = 0; i <= numrighe; i++) {
				
				//se esiste la colonna eredita 
				if ( getObj( 'R' + i + '_Eredita' ) ){
					
					if(  getObj( 'R' + i + '_Eredita' ).checked  )
					{
					   SommaPunteggiEreditati += parseFloat(getObjValue('R'+i+'_PunteggioMax'));
					}
				}
				
				// Commentato perchè il campo CriterioValutazione sul modello è nascosto con valore soggettivo
                // if (getObjValue('RCRITERIGrid_' + i + '_CriterioValutazione') == '') {
                    // DocShowFolder('FLD_CRITERI');
                    // tdoc();
                    // DMessageBox('../', 'Sulla griglia Criteri di valutazione il "Criterio" su ogni riga.', 'Attenzione', 1, 400, 300);
                    
					// getObj('RCRITERIGrid_' + i + '_CriterioValutazione').focus();
                    // return -1;
                // }
                
                if ( (isNaN(parseFloat(getObjValue('RCRITERIGrid_' + i + '_PunteggioMax'))) || parseFloat(getObjValue('RCRITERIGrid_' + i + '_PunteggioMax')) == 0) && (getObjValue('RCRITERIGrid_'+i+'_CriterioValutazione') != 'ereditato') )  {
                    DocShowFolder('FLD_CRITERI');
                    tdoc();
                    DMessageBox('../', 'Sulla griglia Criteri di valutazione il punteggio per ogni singola riga deve essere maggiore di zero.', 'Attenzione', 1, 400, 300);
                    getObj('RCRITERIGrid_' + i + '_PunteggioMax_V').focus();
                    return -1;
                }
                
                totpunteggiorighe = totpunteggiorighe + parseFloat(getObjValue('RCRITERIGrid_' + i + '_PunteggioMax'));
                
                if (getObjValue('RCRITERIGrid_' + i + '_DescrizioneCriterio') == '') {
                    DocShowFolder('FLD_CRITERI');
                    tdoc();
                    DMessageBox('../', 'Sulla griglia Criteri di valutazione busta tecnica inserire una descrizione su ogni riga', 'Attenzione', 1, 400, 300);
                    getObj('RCRITERIGrid_' + i + '_DescrizioneCriterio').focus();
                    return -1;
                }
                
                if (getObjValue('RCRITERIGrid_' + i + '_CriterioValutazione') == 'quiz') {
					
					
                    if (getObjValue('RCRITERIGrid_' + i + '_AttributoCriterio') == '') {
                        DocShowFolder('FLD_CRITERI');
                        tdoc();
                        DMessageBox('../', 'Sulla griglia Criteri di valutazione busta tecnica selezionare un valore per la colonna attributo se il criterio e\' quiz.', 'Attenzione', 1, 400, 300);
                        getObj('RCRITERIGrid_' + i + '_AttributoCriterio').focus();
                        return -1;
                    } else {
                        for (k = 0; k < i; k++) {
                            if (getObjValue('RCRITERIGrid_' + k + '_AttributoCriterio') == getObjValue('RCRITERIGrid_' + i + '_AttributoCriterio')) {
                                DocShowFolder('FLD_CRITERI');
                                tdoc();
                                DMessageBox('../', 'Sulla griglia Criteri di valutazione busta tecnica l\'attributo deve essere univoco.', 'Attenzione', 1, 400, 300);
                                getObj('RCRITERIGrid_' + i + '_AttributoCriterio').focus();
                                return -1;
                            }
                        }
                    }
					
					
					TxtOK( 'RCRITERIGrid_' + i + '_FNZ_OPEN' );
					
					if (getObjValue('RCRITERIGrid_' + i + '_Formula') == '') {
						DocShowFolder('FLD_CRITERI');
						tdoc();
						DMessageBox('../', 'Sulla griglia Criteri di valutazione busta tecnica compilare il criterio Oggettivo evidenziato', 'Attenzione', 1, 400, 300);
						//getObj('RCRITERIGrid_' + i + '_DescrizioneCriterio').focus();
						TxtErr( 'RCRITERIGrid_' + i + '_FNZ_OPEN' );
						return -1;
					}	
					
                }


            }
            if ( Math.round( PunteggioTecnico * 10000 ) != Math.round( totpunteggiorighe * 10000 ) ) {
                DocShowFolder('FLD_CRITERI');
                tdoc();
                DMessageBox('../', 'Il Punteggio Tecnico deve essere uguale alla somma dei punteggi presenti sulle righe. ', 'Attenzione', 1, 400, 300);
                return -1;
            }
        }

        if (getObj('FormulaEcoSDA').value.indexOf(' Coefficiente X ') >= 0 && getObj('Coefficiente_X').value == '' && strVersione == '') {
            DocShowFolder('FLD_CRITERI');
            tdoc();
            DMessageBox('../', 'Per la formula selezionata e\' necessario indicare un valore per il Coefficiente X', 'Attenzione', 1, 400, 300);
            getObj('Coefficiente_X').focus();
            return -1;

        }
		if ( criterio == '15532' || criterio == '15531'  || criterio == '16291'  )
		{
			//-- controlla le righe delle formule economiche se la modalit� di partecipazione non � tradizionale
			if (strVersione != '' && getObj('ModalitadiPartecipazione').value != '16307' ) 
			{
				var SommaPunteggiEco = 0.0;
				var MancaValore = '';
				var n = 1000;
				var strFormulaEco = '';
				var descrCriterioEco = '';
				var punteggioMaxEco = '';

				//--almeno una riga deve esistere
				if (getObj('RCRITERI_ECO_RIGHEGrid_0_DescrizioneCriterio') == null) {
					DocShowFolder('FLD_CRITERI');
					tdoc();
					DMessageBox('../', 'Per il criterio di aggiudicazione gara "Offerta economicamente piu\' vantaggiosa" e\' necessario che ci sia almeno una riga nella griglia "Criteri di valutazione busta economica" ', 'Attenzione', 1, 400, 300);
					getObj('Coefficiente_X').focus();
					return -1;
				}

				//-- tutti i campi devono essere avvalorati ( eccezione per la soglia)
				for (i = 0; i < n && getObj('RCRITERI_ECO_RIGHEGrid_' + i + '_DescrizioneCriterio') != null; i++) 
				{
					MancaValore = 0;

					// Se "Valutazione soggettiva" non sono obbligatori i campi soliti ma solo la descrizione ed il punteggio

					strFormulaEco = getObjValue('RCRITERI_ECO_RIGHEGrid_' + i + '_FormulaEcoSDA');
					descrCriterioEco = getObjValue('RCRITERI_ECO_RIGHEGrid_' + i + '_DescrizioneCriterio');
					punteggioMaxEco = getObjValue('RCRITERI_ECO_RIGHEGrid_' + i + '_PunteggioMax');

					if ( strFormulaEco == 'Valutazione soggettiva' )
					{
						if ( descrCriterioEco == '' || punteggioMaxEco == '' )
							MancaValore = 'RCRITERI_ECO_RIGHEGrid_' + i + '_DescrizioneCriterio';
					}
					else
					{
						/* CONTROLLI DI OBBLIGATORIETA PER TUTTE LE FORMULE TRANNE PER LA 'VALUTAZIONE SOGGETTIVA' */
						if ( strFormulaEco == '') MancaValore = 'RCRITERI_ECO_RIGHEGrid_' + i + '_FormulaEcoSDA';				
						if ( descrCriterioEco == '') MancaValore = 'RCRITERI_ECO_RIGHEGrid_' + i + '_DescrizioneCriterio';
						if ( punteggioMaxEco == '') MancaValore = 'RCRITERI_ECO_RIGHEGrid_' + i + '_PunteggioMax';
						//if ( getObjValue('RCRITERI_ECO_RIGHEGrid_' + i + '_AttributoBase') == '') MancaValore = 'RCRITERI_ECO_RIGHEGrid_' + i + '_AttributoBase';
						if ( getObjValue('RCRITERI_ECO_RIGHEGrid_' + i + '_AttributoValore') == '') MancaValore = 'RCRITERI_ECO_RIGHEGrid_' + i + '_AttributoValore';
						if ( getObjValue('RCRITERI_ECO_RIGHEGrid_' + i + '_CriterioFormulazioneOfferte') == '') MancaValore = 'RCRITERI_ECO_RIGHEGrid_' + i + '_CriterioFormulazioneOfferte';
						if ( strFormulaEco.indexOf(' Coefficiente X ') >= 0 && getObjValue('RCRITERI_ECO_RIGHEGrid_' + i + '_Coefficiente_X') == '') MancaValore = 'RCRITERI_ECO_RIGHEGrid_' + i + '_Coefficiente_X';
						if ( strFormulaEco.indexOf(' Alfa ') >= 0 && getObjValue('RCRITERI_ECO_RIGHEGrid_' + i + '_Alfa') == '') MancaValore = 'RCRITERI_ECO_RIGHEGrid_' + i + '_Alfa_V';
						
						
						
						 //-- l'attributo di confronto � necessario se la formula lo prevede
						if ( getObjValue('RCRITERI_ECO_RIGHEGrid_' + i + '_AttributoBase') == '' 
                             &&
                             BaseAstaNecessaria( strFormulaEco , getObjValue('RCRITERI_ECO_RIGHEGrid_' + i + '_CriterioFormulazioneOfferte') )    
                            )
                        { 
                            MancaValore = 'RCRITERI_ECO_RIGHEGrid_' + i + '_AttributoBase';
                        }
					}
					
					 
					if (MancaValore != '') 
					{
						DocShowFolder('FLD_CRITERI');
						tdoc();
						DMessageBox('../', 'Per ogni riga nella griglia "Criteri di valutazione busta economica" e\' necessario compilare tutti i campi', 'Attenzione', 1, 400, 300);
						getObj(MancaValore).focus();
						return -1;
					}

					SommaPunteggiEco += parseFloat(getObjValue('RCRITERI_ECO_RIGHEGrid_' + i + '_PunteggioMax'));


				}

				//--la somma dei punti deve essere uguale al valore di testata
				if ( Math.round( SommaPunteggiEco * 100 ) != Math.round ( parseFloat(getObjValue('PunteggioEconomico')) * 100 ) ) 
				{
					
					DocShowFolder('FLD_CRITERI');
					tdoc();
					DMessageBox('../', 'Il Punteggio Economico deve essere uguale alla somma dei punteggi presenti sulle righe. ', 'Attenzione', 1, 400, 300);
					return -1;
				}

			}
		}
        
		
		
        //-- se siamo su un rilancio competitivo la somma dei punteggi da ereditare � presente nella sezione specifica
        if( AQ_RILANCIO_COMPETITVO == 'yes' )
        {

			var numrighe=GetProperty( getObj('CRITERI_AQ_EREDITA_TECGrid') , 'numrow');
			var i=0;
            SommaPunteggiEreditati = 0.0;

			//alert(numrighe);
			for( i = 0 ; i <= numrighe ; i++ )
			{		
                if(  getObj( 'RCRITERI_AQ_EREDITA_TECGrid_' + i + '_Eredita' ).checked  )
                {
				   SommaPunteggiEreditati += parseFloat(getObjValue('RCRITERI_AQ_EREDITA_TECGrid_'+i+'_PunteggioMax'));
                }
            }
			
			PunteggioTecPercEredit = parseFloat( getObjValue('PunteggioTecPercEredit'));
                
			if( PunteggioTecPercEredit < 0  || PunteggioTecPercEredit >  100 || isNaN(PunteggioTecPercEredit) )
			{
				DMessageBox('../', 'La "\%Ereditata" deve essere un valore compreso fra 0 e 100 compresi', 'Attenzione', 1, 400, 300);
				return -1;
			}
				
                        
        }   
        
        //-- se la gara  � un accordo quadro o un rilancio  
        try
        {
            if ( getObj('TipoSceltaContraente').value == 'ACCORDOQUADRO' || AQ_RILANCIO_COMPETITVO == 'yes'  ) 
            {
                PunteggioTecMinEredit = parseFloat( getObjValue('PunteggioTecMinEredit'));
                PunteggioTecMaxEredit = parseFloat( getObjValue('PunteggioTecMaxEredit'));
                PunteggioTecPercEredit = parseFloat( getObjValue('PunteggioTecPercEredit'));
                
				//alert(PunteggioTecPercEredit);
				
                //-- minimo ereditabile   0 <= min <= max 
                //-- massimo ereditabile  min < max <= somma( punti ereditati )
                //-- % ereditabile        0 < % <= 100
                
			
				if ( isNaN(PunteggioTecMinEredit) || isNaN(PunteggioTecMaxEredit) )
				{
					DMessageBox('../', 'Minima percentuale ereditabile e Massima percentuale ereditabile devono essere un valore compreso fra 0 e 100 compresi', 'Attenzione', 1, 400, 300);
					return -1;
				}				
				
                if( PunteggioTecMinEredit < 0  || PunteggioTecMinEredit  >  PunteggioTecMaxEredit )
                {
					//ShowError( 'IL "Minimo valore ereditabile" deve essere un valore compreso fra 0 ed il "Massimo valore ereditabile"' );
					DMessageBox('../', 'IL "Minimo valore ereditabile" deve essere un valore compreso fra 0 ed il "Massimo valore ereditabile"', 'Attenzione', 1, 400, 300);
					return -1;
                }
                
              

               /* if( ( PunteggioTecMaxEredit <=  PunteggioTecMinEredit  || PunteggioTecMaxEredit > ( SommaPunteggiEreditati * ( PunteggioTecPercEredit / 100.0 )) ) && AQ_RILANCIO_COMPETITVO == 'yes'  &&  PunteggioTecPercEredit != 0  )
                {
					//ShowError( 'IL "Massimo valore ereditabile" deve essere un valore compreso fra il "Minimo valore ereditabile" e la percentuale della somma dei punteggi ereditati' );
					DMessageBox('../', 'IL "Massimo valore ereditabile" deve essere un valore compreso fra il "Minimo valore ereditabile" e la percentuale della somma dei punteggi ereditati', 'Attenzione', 1, 400, 300);
					return -1;
                }*/
            
            }
        }
        catch( e){}        
             
        
    }





    var numrowlotto = -1;
    var z = 0;

    //-- SOLO GARE CHE PREVEDONO I PRODOTTI
    if ( //-- non deve essere "ristretta bando" o "negoziata avviso"
        !(getObjValue('ProceduraGara') == '15477' && getObjValue('TipoBandoGara') == '2') //-- ristretta Bando
        &&
        !(getObjValue('ProceduraGara') == '15478' && getObjValue('TipoBandoGara') == '1') //-- negoziata avviso
		&&
		!(getObjValue('ProceduraGara') == '15583' && (getObjValue('TipoBandoGara') == '4' || getObjValue('TipoBandoGara') == '5')) //affidamento diretto a due fase
    ) {


        //-- divisione_lotti <> 0 non � monolotto 
        try {
            if (getObjValue('Divisione_lotti') != '0')
                numrowlotto = GetProperty(getObj('LISTA_BUSTEGrid'), 'numrow');
        } catch (e) {}


        for (z = 0; z <= numrowlotto; z++) {

            //commentato perch� adesso ilpunteggio tecnico potrebbe essere specializzato e la vista ritorna sempre quello del bando 
            //if ( !isNaN(parseFloat(getObjValue('RLISTA_BUSTEGrid_'+z+'_somma_punt_lotto'))) && parseFloat(getObjValue('RLISTA_BUSTEGrid_'+z+'_somma_punt_lotto')) != PunteggioTecnico ) 
            //alert(getObjValue('val_RLISTA_BUSTEGrid_'+z+'_Criteri_di_valutaz'));
            if (getObjValue('val_RLISTA_BUSTEGrid_' + z + '_Criteri_di_valutaz') == 'valutato_err') {
                DocShowFolder('FLD_LISTA_LOTTI');
                tdoc();
                //DMessageBox( '../' , 'Sono presenti dei lotti con un punteggio sbagliato' , 'Attenzione' , 1 , 400 , 300 );
                DMessageBox('../', 'Sono presenti dei lotti non compilati correttamente', 'Attenzione', 1, 400, 300);
                return -1;
            }
        }

		// Commento perchè non ci sono i prodotti sul BANDO_CONCORSO
        //se ModalitadiPartecipazione non � tradizionale 16307 faccio i controlli sui prodotti
        // if (getObj('ModalitadiPartecipazione').value != '16307') {
            // if (GetProperty(getObj('PRODOTTIGrid'), 'numrow') == -1) {

                // DocShowFolder('FLD_PRODOTTI');
                // tdoc();
                // DMessageBox('../', 'Compilare correttamente la sezione dei prodotti', 'Attenzione', 1, 400, 300);
                // return -1;
            // }
        // }


        //se ModalitadiPartecipazione non � tradizionale 16307 faccio i controlli sui prodotti
        // if (getObj('ModalitadiPartecipazione').value != '16307') {
            // if (getObjValue('TipoBando') == '') {

                // DocShowFolder('FLD_PRODOTTI');
                // tdoc();
                // DMessageBox('../', 'Compilare correttamente la sezione dei prodotti', 'Attenzione', 1, 400, 300);
                // return -1;
            // }
        // }

    }

    if (getObj('RIFERIMENTIGrid') != null) {


        if (GetProperty(getObj('RIFERIMENTIGrid'), 'numrow') == -1) {

            DocShowFolder('FLD_RIFERIMENTI');
            tdoc();
            DMessageBox('../', 'Compilare correttamente la sezione dei Riferimenti', 'Attenzione', 1, 400, 300);
            return -1;

        }

        if (GetProperty(getObj('RIFERIMENTIGrid'), 'numrow') >= 0) {
            var numeroRighe = parseFloat(GetProperty(getObj('RIFERIMENTIGrid'), 'numrow')) + 1;
            for (var r = 0; r < numeroRighe; r++) {
                var idpfuSelectedIndex = document.getElementById('RRIFERIMENTIGrid_' + r + '_IdPfu').selectedIndex;
                //var ruoloSelectedIndex = document.getElementById('RRIFERIMENTIGrid_' + r + '_RuoloRiferimenti').selectedIndex;
                var idpfu = document.getElementById('RRIFERIMENTIGrid_' + r + '_IdPfu').options[idpfuSelectedIndex].value;
               // var ruolo = document.getElementById('RRIFERIMENTIGrid_' + r + '_RuoloRiferimenti').options[ruoloSelectedIndex].value;
				var ruolo = getObjValue( 'RRIFERIMENTIGrid_' + r + '_RuoloRiferimenti' )
                if (idpfu == '' && ruolo == 'Quesiti') {
                    DocShowFolder('FLD_RIFERIMENTI');
                    tdoc();
                    DMessageBox('../', 'Selezionare almeno un riferimento per i quesiti', 'Attenzione', 1, 400, 300);
                    return -1;
                    //break;
                }
            }
        }
    }
	try 
	{
		if (getObj('DESTINATARI_1Grid') != null) 
		{
			if (GetProperty(getObj('DESTINATARI_1Grid'), 'numrow') == -1) 
			{
				DocShowFolder('FLD_DESTINATARI_1');
				tdoc();
				DMessageBox('../', 'Compilare la sezione dei Destinatari', 'Attenzione', 1, 400, 300);
				return -1;
			}				
			
		}
	} catch (e) {}

    if (getObjValue('UserRUP') == '') {
        DocShowFolder('FLD_COPERTINA');
        tdoc();
        DMessageBox('../', 'Compilare il campo R.U.P.', 'Attenzione', 1, 400, 300);
        return -1;

    }
	
	
	var TPC  = getObj('TipoProceduraCaratteristica').value; //== 'RFQ')


    //-- controllo le date in coerenza con la tipologia di documento
	if  ( TPC == 'RFQ'  ) 
	{
		
	}
    else if (getObjValue('ProceduraGara') == '15478' && getObjValue('TipoBandoGara') == '4') //-- Negoziata - Avviso con risposta
    {
        if (CheckData('DataRiferimentoInizio', Riferimento, 'Compilare Inizio Presentazioni Manifestazione di Interesse', 'Inizio Presentazioni Manifestazione di Interesse deve essere maggiore di oggi','day') == -1) return -1;
        if (CheckData('DataTermineQuesiti', getObjValue('DataRiferimentoInizio'), 'Compilare Termine Richiesta Quesiti', 'Termine Richiesta Quesiti deve essere maggiore di Inizio Presentazioni Manifestazione di Interesse') == -1) return -1;
        if (CheckData('DataScadenzaOfferta', getObjValue('DataTermineQuesiti'), 'Compilare Termine Presentazione Manifestazione di Interesse', 'Termine Presentazione Manifestazione di Interesse deve essere maggiore di Termine Richiesta Quesiti') == -1) return -1;

    } else if ( 
				(getObjValue('ProceduraGara') == '15478' && getObjValue('TipoBandoGara') == '1') //-- Negoziata - Avviso 
				|| 
				( getObjValue('ProceduraGara') == '15583' && (getObjValue('TipoBandoGara') == '4' || getObjValue('TipoBandoGara') == '5')) //affidamento diretto a due fasi
			) 
    {
		
		//se valorizzata controllo DataRiferimentoInizio
		if ( getObjValue('DataRiferimentoInizio') !=''){
			if (CheckData('DataRiferimentoInizio', Riferimento, 'Compilare Inizio Presentazioni Domanda di Partecipazione', 'Inizio Presentazioni Domanda di Partecipazione deve essere maggiore di oggi','day') == -1) return -1;
			Riferimento = getObjValue('DataRiferimentoInizio') ;
		}
		
        if (CheckData('DataTermineQuesiti', Riferimento, 'Compilare Termine Richiesta Quesiti', 'Termine Richiesta Quesiti deve essere maggiore di oggi','day') == -1) return -1;
        if (CheckData('DataScadenzaOfferta', getObjValue('DataTermineQuesiti'), 'Compilare Termine Presentazione Domanda di Partecipazione', 'Termine Presentazione Domanda di Partecipazione deve essere maggiore di Termine Richiesta Quesiti') == -1) return -1;
		
		//se volorizzata controllo DataAperturaOfferte
		if ( getObjValue('DataAperturaOfferte') !=''){
		 if (CheckData('DataAperturaOfferte', getObjValue('DataScadenzaOfferta'), 'Compilare Data Presunta Pubblicazione Invito', 'Data Presunta Pubblicazione Invito deve essere maggiore di Termine Presentazione Risposte') == 1) return -1;
		}
		
        //-- riporta la data apertura sulla data scadenza che risulta nascosta
        //getObj('DataScadenzaOfferta').value = getObj('DataAperturaOfferte').value;

    } else if (getObjValue('ProceduraGara') == '15477' && getObjValue('TipoBandoGara') == '2') //-- Ristretta - Bando
    {
        //if (CheckData('DataRiferimentoInizio', Riferimento, 'Compilare Inizio Presentazioni Domanda di Partecipazione', 'Inizio Presentazioni Domanda di Partecipazione deve essere maggiore di oggi') == -1) return -1;
        if (CheckData('DataTermineQuesiti', getObjValue('DataRiferimentoInizio'), 'Compilare Termine Richiesta Quesiti', 'Termine Richiesta Quesiti deve essere maggiore di Inizio Presentazioni Domanda di Partecipazione') == -1) return -1;
        if (CheckData('DataScadenzaOfferta', getObjValue('DataTermineQuesiti'), 'Compilare Termine Presentazione Domanda di Partecipazione', 'Termine Presentazione Domanda di Partecipazione deve essere maggiore di Termine Richiesta Quesiti') == -1) return -1;
        //if (CheckData('DataAperturaOfferte', getObjValue('DataScadenzaOfferta'), 'Compilare Data Prima Seduta', 'Data Prima Seduta deve essere maggiore di Termine Presentazione Domanda di Partecipazione') == -1) return -1;

    } else //-- per i restanti casi
    {

		if ( getObjValue('DataRiferimentoInizio') !='' && TPC != 'AffidamentoSemplificato' )
		{
			if (CheckData('DataRiferimentoInizio', Riferimento, 'Compilare Inizio Presentazioni Risposte', 'Inizio Presentazioni Risposte deve essere maggiore di oggi','day') == -1) return -1;
		}
		
		//se affidamento diretto semplificato non controllo DataTermineQuesiti e DataAperturaOfferte
		if ( TPC != 'AffidamentoSemplificato' )
			if (CheckData('DataTermineQuesiti', getObjValue('DataRiferimentoInizio'), 'Compilare Termine Richiesta Quesiti', 'Termine Richiesta Quesiti deve essere maggiore di Inizio Presentazioni Richieste') == -1) return -1;
        
		if (CheckData('DataScadenzaOfferta', getObjValue('DataTermineQuesiti'), 'Compilare Termine Presentazione Risposte', 'Termine Presentazione Risposte deve essere maggiore di Termine Richiesta Quesiti') == -1) return -1;
		
        if ( TPC != 'AffidamentoSemplificato' )
			if (CheckData('DataAperturaOfferte', getObjValue('DataScadenzaOfferta'), 'Compilare Data Prima Seduta', 'Data Prima Seduta deve essere maggiore di Termine Presentazione Risposte') == -1) return -1;

    }
	
	//Per i campi "Termine Richiesta Quesiti", "Termine Presentazione Offerta" e "Data Prima Seduta" se valorizzati controlliamo se l'orario presenti valore vuoto oppure 0
	//Per i campi "Termine Richiesta Quesiti", "Termine Presentazione Offerta" e "Data Prima Seduta" se valorizzati controlliamo se ricade in un fermo sistema
	try
	{
		if ( getObjValue('DataTermineQuesiti') !='' && TPC != 'RFQ' )
		{
			if (CheckDataOrarioOK('DataTermineQuesiti', 'Indicare un orario per il campo "' + getObj('cap_DataTermineQuesiti').innerHTML + '" diverso da zero') == -1) return -1;
			
		}
		if ( getObjValue('DataScadenzaOfferta') !='')
		{
			if (CheckDataOrarioOK('DataScadenzaOfferta', 'Indicare un orario per il campo "' + getObj('cap_DataScadenzaOfferta').innerHTML + '" diverso da zero') == -1) return -1;
			
		}
		if ( getObjValue('DataAperturaOfferte') !=''  && TPC != 'RFQ' )
		{
			if (CheckDataOrarioOK('DataAperturaOfferte', 'Indicare un orario per il campo "' + getObj('cap_DataAperturaOfferte').innerHTML + '" diverso da zero') == -1) return -1;
			
		}		
		
	}catch (e){}
	
	

    //controllo che siano presenti le motivazioni per un appalto verde oppure per un acquisto sociale
    try {
        if (getObjValue('Appalto_Verde') == 'si') {
            if (getObjValue('Motivazione_Appalto_Verde') == '') {
                DocShowFolder('FLD_COPERTINA');
                tdoc();
                DMessageBox('../', 'Per un bando con "Appalto Verde" indicare una motivazione', 'Attenzione', 1, 400, 300);
                getObj('Motivazione_Appalto_Verde').focus();
                return -1;
            }
        }
    } catch (e) {}
	
	
    try {
        if (getObjValue('Acquisto_Sociale') == 'si') {
            if (getObjValue('Motivazione_Acquisto_Sociale') == '') {
                DocShowFolder('FLD_COPERTINA');
                tdoc();
                DMessageBox('../', 'Per un bando con "Acquisto_Sociale" indicare una motivazione', 'Attenzione', 1, 400, 300);
                getObj('Motivazione_Acquisto_Sociale').focus();
                return -1;
            }
        }
    } catch (e) {}
	
	
	 //controllo che siano presenti le motivazioni per un appalto in emergenza
    try {
        if (getObjValue('AppaltoInEmergenza') == 'si') {
            if (getObjValue('MotivazioneDiEmergenza') == '') {
                DocShowFolder('FLD_COPERTINA');
                tdoc();
                DMessageBox('../', 'Per un bando con "Appalto In Emergenza" indicare una motivazione', 'Attenzione', 1, 400, 300);
                getObj('MotivazioneDiEmergenza').focus();
                return -1;
            }
        }
    } catch (e) {}
	
	
	//controllo che siano presenti le motivazioni per gender equality
    try {
        if (getObjValue('GenderEquality') == 'si') {
            if (getObjValue('GenderEqualityMotivazione') == '') {
                DocShowFolder('FLD_COPERTINA');
                tdoc();
                DMessageBox('../', 'Per un bando con "Gender Equality" indicare una motivazione', 'Attenzione', 1, 400, 300);
                getObj('GenderEqualityMotivazione').focus();
                return -1;
            }
        }
    } catch (e) {}
	
	var tmpCalcoloAnomalia = getObjValue('CalcoloAnomalia');
	
	
	//controllo di coerenza anomalia
	
	if (  tmpCalcoloAnomalia == '1' ){
    
		if (getObj( 'OffAnomale').value == '' ){
		  DMessageBox( '../' , 'Effettuare una selezione per il campo Offerte Anomale' , 'Attenzione' , 1 , 400 , 300 );
		  getObj('OffAnomale').focus();
		  return -1;
		}
	  
	}
	
	
	var tmpCriterioAggiudicazione = getObjValue('CriterioAggiudicazioneGara');

	try
	{
		
		/* se la gara � economicamente vantaggiosa oppure COSTOFISSO e si � scelto "Calcolo Anomalia" = 'si' 
			ed i campi ModalitaAnomalia_TEC e ModalitaAnomalia_ECO sono presenti sul modello */
		if ( ( tmpCriterioAggiudicazione == '15532' || tmpCriterioAggiudicazione == '25532' ) && tmpCalcoloAnomalia == '1' )
		{
			if ( getObj('ModalitaAnomalia_TEC') )
			{
				if ( getObjValue('ModalitaAnomalia_TEC') == '' || getObjValue('ModalitaAnomalia_ECO') == '')
				{
					DMessageBox('../', 'Compilare i campi \'Modalita di calcolo PT\' e \'Modalita calcolo PE\'', 'Attenzione', 1, 400, 300);
					getObj('ModalitaAnomalia_TEC').focus();
					return -1;
				}
			}
		}
	}
	catch(e)
	{
	}
	
	
	// ODIROS -- controllo sulla sezione Busta documentazione richiesta
	// function ControlliSend
	// numero di criteri 0-based
	try
	{
		var NumDocRic =  GetProperty(getObj('DOCUMENTAZIONE_RICHIESTAGrid'), 'numrow')  ;
		var RichiediFirma;
		var TipoFile;
		
		if (NumDocRic >= 0)
		{
			for (indice = 0; indice <= NumDocRic; indice++) 
			{
					  
				RichiediFirma = getObj('RDOCUMENTAZIONE_RICHIESTAGrid_' + indice + '_RichiediFirma').checked;
				TipoFile = getObj('RDOCUMENTAZIONE_RICHIESTAGrid_' + indice + '_TipoFile').value;
				
				TipoFile = TipoFile.toUpperCase();
				
				if ( (RichiediFirma == true) && (TipoFile.indexOf('###PDF###') < 0 || TipoFile.indexOf('###P7M###') < 0) )
				{
					DocShowFolder('FLD_DOCUMENTAZIONE_RICHIESTA');
					tdoc();
					DMessageBox('../', 'Nella Busta Documentazione sulle righe con Richiedi Firma = SI il Tipo File deve contenere obbligatoriamente almeno i tipi P7M e PDF', 'Attenzione', 1, 400, 300);
					//getObj('Motivazione_Acquisto_Sociale').focus();
					return -1;
				}
				//alert (RichiediFirma);
				//alert (TipoFile);
			}
		}
		
	}
	catch(e)
	{
	}
	
	//-- controlli sul tipo soggetto 
	try
	{
		if ( getObj('ISPBMInstalled').value == '1' && getObj('TIPO_SOGGETTO_ART').value == '' ) 
		{
			DMessageBox('../', 'campo Tipo Soggetto obbligatorio', 'Attenzione', 1, 400, 300);					
			return -1;			
		}
	}
	catch(e)
	{
	}
  
	try 
	{
		CheckImportiConcorsi();
	}
	catch(e)
	{
		
	}
}

function CheckData( FieldData, Riferimento, msgVuoto, msgMinoreRif, tipoconfronto ) 
{
	if (tipoconfronto == undefined )
		tipoconfronto='';
	
	if (getObjValue(FieldData) == '') {
        DocShowFolder('FLD_COPERTINA');
        tdoc();
        try {
            getObj(FieldData + '_V').focus();
        } catch (e) {};
        DMessageBox('../', msgVuoto, 'Attenzione', 1, 400, 300);
        return -1;
    }
	try
	{
		if ( tipoconfronto == 'day' && getObj( 'AppaltoInEmergenza' ).value != 'si' )  //fa il confronto se richiesto esplicitamente per day e sul bando per il campo Appalto in Emergenza non si � scelto "si"
		{
			if (getObjValue(FieldData).substring(0,10) <= Riferimento) 
			{
				DocShowFolder('FLD_COPERTINA');
				tdoc();
				try {
					getObj(FieldData + '_V').focus();
				} catch (e) {};
				DMessageBox('../', msgMinoreRif, 'Attenzione', 1, 400, 300);
				return -1;
			}
			
		}
		else
		{
			if (getObjValue(FieldData) <= Riferimento) 
			{
				DocShowFolder('FLD_COPERTINA');
				tdoc();
				try {
					getObj(FieldData + '_V').focus();
				} catch (e) {};
				DMessageBox('../', msgMinoreRif, 'Attenzione', 1, 400, 300);
				return -1;
			}
		}
	}	catch(e){};
    return 0;
}



function OpenSeduta(objGrid, Row, c) {
    var cod = getObj('R' + Row + '_idSeduta').value;

    GridSecOpenDoc(objGrid, Row, c)

}

// function ChangeImpAppalto(obj) {
    // var Oneri = Number(getObj('Oneri').value);
    // var importoBaseAsta2 = Number(getObj('importoBaseAsta2').value);
    // var Opzioni = Number(getObj('Opzioni').value);
	
	

    
	// // se presente la forma visuale
	// if (getObj('importoBaseAsta_V'))
		// SetNumericValue('importoBaseAsta', Oneri + importoBaseAsta2 + Opzioni);
	// else
		// getObj('importoBaseAsta').value=Oneri + importoBaseAsta2 + Opzioni;

// }


function DisplaySection(obj) {
    
	var crit = getObjValue('CriterioAggiudicazioneGara');
    var conf = getObjValue('Conformita');
    var TipoSceltaContraente = '';
    var AQ_RILANCIO_COMPETITVO = '';

    try { TipoSceltaContraente = getObj('TipoSceltaContraente').value  }  catch( e) {}
    try { AQ_RILANCIO_COMPETITVO = getObjValue( 'AQ_RILANCIO_COMPETITVO') } catch( e ){};    

    //--  nel caso di economicamente vantaggiosa si filtra la conformit�
    var Conformita = getObj('Conformita');


    if (getObjValue('TipoBandoGara') == '3') 
	{
        //DocDisplayFolder(  'DESTINATARI'   ,'' );

        var StatoFunzionale = getObjValue('StatoFunzionale');
        if (StatoFunzionale == 'InLavorazione') 
		{
			
            /*
            if (getObjValue('ProceduraGara') == '15477') //la  ristretta prevede solo gli OE che hanno fatto domanda di partecipazione
            {
                setVisibility(getObj('DESTINATARI_1'), 'none');
            }
			*/

            //-- se non esiste il documento di avviso nascondo i partecipanti dell'avviso  //  -- NON VALIDO RIMOSSO CON ATTIVITA' 226189 O se mi trovo nel giro RISTRETTA FASE INVITO
            if (getObjValue('LinkedDoc') == '' || getObjValue('LinkedDoc') == '0' || AQ_RILANCIO_COMPETITVO == 'yes' )//|| getObjValue('ProceduraGara') == '15477' )
			{
                try {
                    setVisibility(getObj('DESTINATARI_INT'), 'none');
                    
                } catch (e) {}
            }


        } else {
            try {
                setVisibility(getObj('DESTINATARI_INT'), 'none');
            } catch (e) {}
        }
		
		
		//DestinatariNotifica - Nel caso di procedure ad Invito il campo verr� nascosto, perch� la scelta non andrebbe ad influenzare l�elenco dei destinatari. 
		try {$("#cap_DestinatariNotifica").parents("table:first").css({"display": "none"});} catch (e) {}
		

    }
	
	//se TIPOBANDOGARA = 5 (avviso con destinatari affidamento a 2 fasi nascondo la griglia DESTINATARI_INT)
	if (getObjValue('TipoBandoGara') == '5') 
	{
		try {
			setVisibility(getObj('DESTINATARI_INT'), 'none');
		} catch (e) {}
	} 
	 
    var strVersione;
    try {
        strVersione = getObjValue('Versione');
    } catch (e) {
        strVersione = '';
    }

    if (strVersione == '') {
        try {
            setVisibility(getObj('CRITERI_ECO_TESTATA'), 'none');
        } catch (e) {}
        try {
            setVisibility(getObj('CRITERI_ECO_RIGHE'), 'none');
        } catch (e) {}
    } else {
        try {
            getObj('BANDO_SEMPLIFICATO_CRITERI_ECO').rows[3].style.display = 'none';
            getObj('BANDO_SEMPLIFICATO_CRITERI_ECO').rows[4].style.display = 'none';
            getObj('BANDO_SEMPLIFICATO_CRITERI_ECO').rows[5].style.display = 'none';
            getObj('BANDO_SEMPLIFICATO_CRITERI_ECO').rows[6].style.display = 'none';
        } catch (e) {}


    }
	
	
	//nascondo la busta di documentazione se non richiesta
	try { OnChangeRichiediDocumentazione(); } catch( e ) {};
    
    
    //-- se la gara non � un accordo quadro vanno nascoste le aree per l'ereditariet� dei punteggi

    //alert(TipoSceltaContraente);
	//alert(AQ_RILANCIO_COMPETITVO);
        
    Handle_Eredita_AQ();

}



function DownLoadCSV() {

    var TipoBando = getObjValue('TipoBando');

    if (TipoBando == '') {
        alert(CNV('../', 'E\' necessario selezionare prima il modello'));
        return;
    }
	
    ExecFunction('../../Report/CSV_LOTTI.asp?IDDOC=' + getObjValue('IDDOC') + '&TIPODOC=BANDO_GARA&MODEL=MODELLI_LOTTI_' + TipoBando + '_MOD_BANDO_LOTTI&HIDECOL=ESITORIGA', '_blank', '');

}


function OpenEconomica(objGrid, Row, c) {
    var cod;
    try {
        cod = getObj('R' + Row + '_id').value;
    } catch (e) {
        cod = getObj('RLISTA_BUSTEGrid_' + Row + '_id').value;
    }

    ShowDocumentPath('BANDO_SEMP_OFF_ECO', cod, '../');

}

function OpenTecnica(objGrid, Row, c) {
    var cod;
    try {
        cod = getObj('R' + Row + '_id').value;
    } catch (e) {
        cod = getObj('RLISTA_BUSTEGrid_' + Row + '_id').value;
    }

    ShowDocumentPath('BANDO_SEMP_OFF_TEC', cod, '../');

}

function OpenCriteri(objGrid, Row, c) {
    if (flag == 1) {
        if (confirm(CNV('../', 'Sono state effettuare delle modifiche al documento prima di procedere e richiesto un salvataggio.Vuoi procedere?'))) {
            SaveDoc();
            return;
        } else return -1;
    }
    var cod = getObj('RLISTA_BUSTEGrid_' + Row + '_id').value;
	
	MakeDocFrom( 'BANDO_SEMP_OFF_EVAL#900,800#BANDO_GARA#' + cod );
    return;
	

    /*if (isSingleWin() == true) {
        ReloadDocFromDB(cod, 'BANDO_SEMP_OFF_EVAL');
        ShowDocument('BANDO_SEMP_OFF_EVAL', cod);
    } else {
        ReloadDocFromDB(cod, 'BANDO_SEMP_OFF_EVAL');
        ShowDocumentPath('BANDO_SEMP_OFF_EVAL', cod, '../');
    }*/
}



function EditCriterio(objGrid, Row, c) {
	
    if (getObjValue('RCRITERIGrid_' + Row + '_CriterioValutazione') == 'quiz') {
        //recupero TipoGiudizioTecnico
        var TipoGiudizioTecnico = '';
		var PunteggioMax = 1;

        try {
            var TipoGiudizioTecnico = getObj('TipoGiudizioTecnico').value;

            if (document.getElementById('ModAttribPunteggio')) {
                var criterio = getObjValue('ModAttribPunteggio');

                if (criterio != '' && criterio != 'giudizio') {
                    TipoGiudizioTecnico = 'number';
					if (criterio == 'punteggio' ) 
						PunteggioMax = getObjValue('RCRITERIGrid_' + Row + '_PunteggioMax')
                }

            }

        } catch (e) {}
		
		
        if ( getObjValue('StatoFunzionale') == 'InLavorazione' || getObjValue('StatoFunzionale') == 'InRettifica' ) {
            Open_Quiz('../', 'RCRITERIGrid_' + Row + '_Formula', 'C', getObjValue('RCRITERIGrid_' + Row + '_DescrizioneCriterio'), TipoGiudizioTecnico, 'RCRITERIGrid_' + Row + '_AttributoCriterio' , PunteggioMax );
        } else {
            Open_Quiz('../', 'RCRITERIGrid_' + Row + '_Formula', 'V', getObjValue('RCRITERIGrid_' + Row + '_DescrizioneCriterio'), TipoGiudizioTecnico, 'RCRITERIGrid_' + Row + '_AttributoCriterio' , PunteggioMax);
        }

    }

}

function CRITERI_OnLoad() {

}

function InfoTec_CategoriaPrevalente_AFTER_COMMAND()
{
	getObj('CategoriaSOA_CHANGE_TECNICA').value='1';
}
function onchangeCategoria_SOA()
{
	getObj('CategoriaSOA_CHANGE_TECNICA').value='1';
}
function onchangeClassifica_SOA()
{
	getObj('CategoriaSOA_CHANGE_TECNICA').value='1';
}

function CRITERI_AFTER_COMMAND(param) 
{
    FilterDominio();
	
	/*
	try { 
        if( getObjValue( 'AQ_RILANCIO_COMPETITVO') == 'yes' )
        {
            ShowCol( 'CRITERI' , 'Eredita' , 'none' );
        }
    } catch( e ){};
	*/
	
	Handle_Eredita_AQ();
	
	//ripristinaAttribCriteri();
	OnChange_Riparametrazione();
	onChange_Visualizzazione_Offerta_Tecnica();
}

function ripristinaAttribCriteri()
{

	var i;
	var n = 100;


	for (i = 0; i < n && getObj('RCRITERIGrid_' + i + '_CriterioValutazione') != null; i++)
	{
		getObj('RCRITERIGrid_' + i + '_AttributoCriterio').value = getObjValue('RCRITERIGrid_' + riga + '_CampoTesto_1');
	}
	
}

function CRITERI_ECO_RIGHE_AFTER_COMMAND(param) {
    FilterDominio();
}

function OnChangeCriterio(obj) {

	var DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;

    try {
        var i = obj.id.split('_');

        //FilterDom(  'RCRITERIGrid_' + i[1] + '_AttributoCriterio' , 'AttributoCriterio' , getObjValue( 'RCRITERIGrid_' + i[1] + '_AttributoCriterio' ), 'SQL_WHERE= TipoBando = \'' + getObjValue( 'TipoBando' ) + '\' and DZT_NAME = \'MOD_OffertaTec\' and DZT_Type not in ( 18 ) ' , 'CRITERIGrid_' + i[1]  , '')

        if (getObjValue('RCRITERIGrid_' + i[1] + '_CriterioValutazione') == 'quiz') {
            setVisibility(getObj('RCRITERIGrid_' + i[1] + '_AttributoCriterio'), '');
            setVisibility(getObj('RCRITERIGrid_' + i[1] + '_FNZ_OPEN'), '');
			setVisibility(getObj('RCRITERIGrid_' + i[1] + '_Allegati_da_oscurare_edit_new'), '');
			setVisibility(getObj('RCRITERIGrid_' + i[1] + '_Allegati_da_oscurare_button'), '');

            try {

                //disabilito il punteggio solo se la tipologia di giudizio � a dominio 
                var TipoGiudizioTecnico = '';

                try {
                    var TipoGiudizioTecnico = getObj('TipoGiudizioTecnico').value;
                } catch (e) {};

				/*
					if (TipoGiudizioTecnico != 'domain')
						getObj('RCRITERIGrid_' + i[1] + '_PunteggioMax_V').disabled = true;
						
				*/

            } catch (e) {};
            AggiornaCriteriTecnici('RCRITERIGrid_' + i[1] + '_Formula', '', '');

            //FilterDom('RCRITERIGrid_' + i[1] + '_AttributoCriterio', 'AttributoCriterio', getObjValue('RCRITERIGrid_' + i[1] + '_CampoTesto_1'), 'SQL_WHERE= TipoBando = \'' + getObjValue('TipoBando') + '\' and DZT_NAME = \'MOD_OffertaTec\' and DZT_Type not in ( 18,4,5,8 ) ', 'CRITERIGrid_' + i[1], 'onChangeDomAttribCriterio( this, \'CampoTesto_1\' );');
			if (DOCUMENT_READONLY == '0') 
			{
				FilterDom('RCRITERIGrid_' + i[1] + '_AttributoCriterio', 'AttributoCriterio', getObjValue('RCRITERIGrid_' + i[1] + '_CampoTesto_1'), 'SQL_WHERE= TipoBando = \'' + getObjValue('TipoBando') + '\' and DZT_NAME = \'MOD_OffertaTec\' and DZT_Type not in ( 18,5,8 ) ', 'CRITERIGrid_' + i[1], 'onChangeDomAttribCriterio( this, \'CampoTesto_1\' );');
				
				//SE SIAMO SULLE 2 fasifaccio il filtro sull'attributo altrimenti la colonna non � visibile
				if ( getObjValue('Visualizzazione_Offerta_Tecnica')  == 'due_fasi' )
				{										
					var filtro='';
					filtro= 'SQL_WHERE= TipoBando = \'' + getObjValue('TipoBando') + '\' and DZT_NAME = \'MOD_OffertaTec\' and DZT_Type  in ( 18 )' ;
					SetProperty( getObj('RCRITERIGrid_' + i[1] + '_Allegati_da_oscurare'),'filter',filtro);							

				}
			
			}
			
			
			

        } else {
            setVisibility(getObj('RCRITERIGrid_' + i[1] + '_AttributoCriterio'), 'none');
            setVisibility(getObj('RCRITERIGrid_' + i[1] + '_FNZ_OPEN'), 'none');
			setVisibility(getObj('RCRITERIGrid_' + i[1] + '_Allegati_da_oscurare_edit_new'), 'none');
			setVisibility(getObj('RCRITERIGrid_' + i[1] + '_Allegati_da_oscurare_button'), 'none');

            try {
                getObj('RCRITERIGrid_' + i[1] + '_PunteggioMax_V').disabled = false;
            } catch (e) {};


        }
    } catch (e) {};

    flagmodifica();

    //FilterDominio();
}

function FilterDominio() {
    //-- per tutte le righe definisco il filtro sul dominio e la presenza del comando per aprire il dialogo
    var n = 100 //-- numero righe
    var i;
	
	
	var DOCUMENT_READONLY = '0';
	try
	{
		if ( typeof InToPrintDocument !== 'undefined' || getObjValue('StatoFunzionale') == 'InApprove')
		{
			DOCUMENT_READONLY='1';
		}
		else
		{
			DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;
		}
	}
	catch(e)
	{
	}
	
	
    try {

        /*
		var statFunz;
        var statFunzVal;

        try {
            //Se FilterDominio() viene chiamato dall'iframe dei comandi non avremo il campo statoFunzionale.
            //quindi assumo un default 'InLavorazione'
            statFunz = getObj('StatoFunzionale').value;
        } catch (e) {
            statFunz = 'InLavorazione';
        }
		*/
		

        for (i = 0; i < n && getObj('RCRITERIGrid_' + i + '_CriterioValutazione') != null; i++) 
		{
            if ( DOCUMENT_READONLY == '0' && getObjValue('RCRITERIGrid_' + i + '_CriterioValutazione') == 'quiz' ) 
			{
				
                //FilterDom('RCRITERIGrid_' + i + '_AttributoCriterio', 'AttributoCriterio', getObjValue('RCRITERIGrid_' + i + '_CampoTesto_1'), 'SQL_WHERE= TipoBando = \'' + getObjValue('TipoBando') + '\' and DZT_NAME = \'MOD_OffertaTec\' and DZT_Type not in ( 18,4,5,8 ) ', 'CRITERIGrid_' + i, 'onChangeDomAttribCriterio( this, , \'CampoTesto_1\' );');
                FilterDom('RCRITERIGrid_' + i + '_AttributoCriterio', 'AttributoCriterio', getObjValue('RCRITERIGrid_' + i + '_CampoTesto_1'), 'SQL_WHERE= TipoBando = \'' + getObjValue('TipoBando') + '\' and DZT_NAME = \'MOD_OffertaTec\' and DZT_Type not in ( 18,5,8 ) ', 'CRITERIGrid_' + i, 'onChangeDomAttribCriterio( this, , \'CampoTesto_1\' );');
				
				//SE SIAMO SULLE 2 fasifaccio il filtro sull'attributo altrimenti la colonna non � visibile
				if ( getObjValue('Visualizzazione_Offerta_Tecnica')  == 'due_fasi' )
				{										
					var filtro='';
					filtro= 'SQL_WHERE= TipoBando = \'' + getObjValue('TipoBando') + '\' and DZT_NAME = \'MOD_OffertaTec\' and DZT_Type  in ( 18 )' ;
					SetProperty( getObj('RCRITERIGrid_' + i + '_Allegati_da_oscurare'),'filter',filtro);							

				}
			}

            if (getObjValue('RCRITERIGrid_' + i + '_CriterioValutazione') == 'quiz') 
			{
                try {setVisibility(getObj('RCRITERIGrid_' + i + '_AttributoCriterio'), '');} catch (e) {};
				try {setVisibility(getObj('RCRITERIGrid_' + i + '_Allegati_da_oscurare_edit_new'), '');} catch (e) {};
				try {setVisibility(getObj('RCRITERIGrid_' + i + '_Allegati_da_oscurare_button'), '');} catch (e) {};
				try {setVisibility(getObj('RCRITERIGrid_' + i + '_Allegati_da_oscurare_label'), '');} catch (e) {};
                setVisibility(getObj('RCRITERIGrid_' + i + '_FNZ_OPEN'), '');

                var TipoGiudizioTecnico = '';

                try {
                    var TipoGiudizioTecnico = getObj('TipoGiudizioTecnico').value;
                } catch (e) {};

                try {
                    if (TipoGiudizioTecnico != 'domain')
                        getObj('RCRITERIGrid_' + i + '_PunteggioMax_V').disabled = true;
                } catch (e) {};
            } 
			else 
			{
                try {
                    setVisibility(getObj('RCRITERIGrid_' + i + '_AttributoCriterio'), 'none');
                } catch (e) {};
				
                try {setVisibility(getObj('RCRITERIGrid_' + i + '_Allegati_da_oscurare_edit_new'), 'none');} catch (e) {};
				try {setVisibility(getObj('RCRITERIGrid_' + i + '_Allegati_da_oscurare_button'), 'none');} catch (e) {};
				try {setVisibility(getObj('RCRITERIGrid_' + i + '_Allegati_da_oscurare_label'), 'none');} catch (e) {};
				try {setVisibility(getObj('RCRITERIGrid_' + i + '_FNZ_OPEN'), 'none');} catch (e) {};
				

            }


            if( getObjValue('RCRITERIGrid_' + i + '_CriterioValutazione') == 'ereditato' )
            {
                  try {setVisibility( getObj( 'RCRITERIGrid_' + i + '_FNZ_DEL' ) , 'none' );} catch (e) {};
                  try {setVisibility( getObj( 'RCRITERIGrid_' + i + '_FNZ_COPY' ) , 'none' );} catch (e) {};
            }
			
			

        }

    } catch (e) {
        //alert( 'error ' + e);
    }
	
	for (i = 0; i < n && getObj('RCRITERI_AQ_EREDITA_TECGrid_' + i + '_CriterioValutazione') != null; i++) 
	{
		try 
		{
			 if (getObjValue('RCRITERI_AQ_EREDITA_TECGrid_' + i + '_CriterioValutazione') != 'quiz') 
			 {
				try {setVisibility(getObj('RCRITERI_AQ_EREDITA_TECGrid_' + i + '_AttributoCriterio'), 'none');} catch (e) {};				
				try {setVisibility(getObj('RCRITERI_AQ_EREDITA_TECGrid_' + i + '_FNZ_OPEN'), 'none');} catch (e) {};	
				
			 }
		} catch (e) {}
	}

    var strVersione;
    try {
        strVersione = getObjValue('Versione');
    } catch (e) {
        strVersione = '';
    }


    if ( strVersione != '' && DOCUMENT_READONLY == '0' )
	{

        try {


            var filter;

            for (i = 0; i < n && getObj('RCRITERI_ECO_RIGHEGrid_' + i + '_DescrizioneCriterio') != null; i++) 
			{
                FilterDom('RCRITERI_ECO_RIGHEGrid_' + i + '_AttributoBase', 'AttributoBase', getObjValue('RCRITERI_ECO_RIGHEGrid_' + i + '_CampoTesto_1'), 'SQL_WHERE= TipoBando = \'' + getObjValue('TipoBando') + '\' and DZT_NAME = \'MOD_BandoSempl\' and DZT_Type in ( 2 ) ', 'CRITERI_ECO_RIGHEGrid_' + i, 'onChangeDomAttribCriterio( this, \'CampoTesto_1\' );' );
                FilterDom('RCRITERI_ECO_RIGHEGrid_' + i + '_AttributoValore', 'AttributoValore', getObjValue('RCRITERI_ECO_RIGHEGrid_' + i + '_CampoTesto_2'), 'SQL_WHERE= TipoBando = \'' + getObjValue('TipoBando') + '\' and DZT_NAME = \'MOD_Offerta\' and DZT_Type in ( 2 ) ', 'CRITERI_ECO_RIGHEGrid_' + i, 'onChangeDomAttribCriterio( this, \'CampoTesto_2\' );' );

				SetCriterioFormulazioneOfferteRow( i );
				
				/*
                if (getObjValue('CriterioFormulazioneOfferte') == '15537') {
                    filter = 'SQL_WHERE= CategorieUSO like \'%,sconto,%\' ';
                }
                if (getObjValue('CriterioFormulazioneOfferte') == '15536') {
                    filter = 'SQL_WHERE= CategorieUSO like \'%,prezzo,%\' ';
                }

                FilterDom('RCRITERI_ECO_RIGHEGrid_' + i + '_FormulaEcoSDA', 'FormulaEcoSDA', getObjValue('RCRITERI_ECO_RIGHEGrid_' + i + '_FormulaEcoSDA'), filter, 'CRITERI_ECO_RIGHEGrid_' + i, 'OnChangeFormula( this , \'RCRITERI_ECO_RIGHEGrid_' + i + '_\' );flagmodifica();');
                OnChangeFormula(this, 'RCRITERI_ECO_RIGHEGrid_' + i + '_');
*/
				}

        } catch (e) {
            alert('error ' + e);
        }

    }

}


function SetCriterioFormulazioneOfferteRow( i )
{
	var filter;
	var Concessione = 'no'

	var CVO = getObjValue('RCRITERI_ECO_RIGHEGrid_' + i +'_CriterioFormulazioneOfferte') ;
    
    try { Concessione = getObjValue('Concessione') ; } catch( e ){}
    if ( Concessione == '' )
        Concessione = 'no'

	if ( CVO == '15537') {
		filter = 'SQL_WHERE= CategorieUSO like \'%,sconto,%\' and CategorieUSO like \'%,Concessioni_' + Concessione + ',%\' ';
	}

	if ( CVO == '15536') {
		filter = 'SQL_WHERE= CategorieUSO like \'%,prezzo,%\' and CategorieUSO like \'%,Concessioni_' + Concessione + ',%\' ';
	}

	//se richiesta di preventivo/affidamento diretto aggiungo la condizione per considerare tutte quelle che non hanno
	//la dicitura "RichiestaPreventivo_no"
	
	if ( getObjValue('ProceduraGara') == '15479' || getObjValue('ProceduraGara') == '15583' )
	{
		filter = filter + ' and CategorieUSO not like \'%,RichiestaPreventivo_no,%\' ';
	}

	FilterDom('RCRITERI_ECO_RIGHEGrid_' + i + '_FormulaEcoSDA', 'FormulaEcoSDA', getObjValue('RCRITERI_ECO_RIGHEGrid_' + i + '_FormulaEcoSDA'), filter, 'CRITERI_ECO_RIGHEGrid_' + i, 'OnChangeFormula( this , \'RCRITERI_ECO_RIGHEGrid_' + i + '_\' );flagmodifica();');
	OnChangeFormula(this, 'RCRITERI_ECO_RIGHEGrid_' + i + '_');

}


function OnChangeCriterioFormulazioneOfferte( obj )
{
	var v = obj.name.split( '_' );
	SetCriterioFormulazioneOfferteRow( v[3] );
}


function OnChangeFormula(obj, Row) 
{
	try 
	{
		var strFormula = getObjValue(Row + 'FormulaEcoSDA');
		SetTextValue(Row + 'FormulaEconomica', strFormula);

		if ( strFormula == 'Valutazione soggettiva' )
		{
			//Se la formula economica selezionata � Valutazione soggettiva nascondiamo i campi non utili
			try { getObj(Row + 'Coefficiente_X').style.display = 'none'; } catch(e) {}
			try { getObj(Row + 'cap_Coefficiente_X').style.display = 'none'; } catch(e) {}
			try { getObj(Row + 'Alfa_V').style.display = 'none'; } catch(e) {}
			try { getObj(Row + 'AttributoBase').style.display = 'none'; } catch(e) {}
			try { getObj(Row + 'CriterioFormulazioneOfferte').style.display = 'none'; } catch(e) {}
			try { getObj(Row + 'AttributoValore').style.display = 'none'; } catch(e) {}

		}
		else
        {
			
			try { getObj(Row + 'Coefficiente_X').style.display = ''; } catch(e) {}
			try { getObj(Row + 'cap_Coefficiente_X').style.display = ''; } catch(e) {}
			try { getObj(Row + 'Alfa_V').style.display = ''; } catch(e) {}
			try { getObj(Row + 'AttributoBase').style.display = ''; } catch(e) {}
			try { getObj(Row + 'CriterioFormulazioneOfferte').style.display = ''; } catch(e) {}
			try { getObj(Row + 'AttributoValore').style.display = ''; } catch(e) {}
			
			/* GESTIONE DEL COEFFICIENTE X  */
            if (strFormula.indexOf(' Coefficiente X ') >= 0) 
			{
			
                getObj(Row + 'Coefficiente_X').style.display = '';
				
                try 
				{
                    getObj('cap_Coefficiente_X').style.display = '';
                }
				catch (e) 
				{
				}

            } 
			else 
			{

                getObj(Row + 'Coefficiente_X').style.display = 'none';

                try 
				{
                    getObj(Row + 'cap_Coefficiente_X').style.display = 'none';
                }
				catch (e) 
				{
				}

                getObj(Row + 'Coefficiente_X').value = '';

            }
			
			/* GESTIONE DELLA COSTANTE ALFA */
			if (strFormula.indexOf(' Alfa ') >= 0) 
			{
			
                getObj(Row + 'Alfa_V').style.display = '';

            } 
			else 
			{

                getObj(Row + 'Alfa_V').style.display = 'none';
                getObj(Row + 'Alfa_V').value = '';
				getObj(Row + 'Alfa').value = '';

            }
			
        }

    }
	catch (e) 
	{
	}

}


//-- determino il punteggio massimo del criterio oggettivo
function AggiornaCriteriTecnici(strField, p1, p2) {
    var obj = getObj(strField);
    var R = strField.split('_');
    var M = 0;
    var i;

    try {
        var v = obj.value.split('#=#')[2].split('#~#')
        var l = v.length;
        for (i = 3; i < l; i += 4) {
            if (Number(v[i]) > M) M = Number(v[i]);
        }
    } catch (e) {};

    //aggiorno il punteggio solo se tipogiudiziotecnico � edit
    var TipoGiudizioTecnico = '';
    try {
        var TipoGiudizioTecnico = getObj('TipoGiudizioTecnico').value;
    } catch (e) {};


    if (TipoGiudizioTecnico != 'domain')
        SetNumericValue(R[0] + '_' + R[1] + '_PunteggioMax', M);


}

function PrintAndSend(param,param2) {
	
	if (param2 == undefined )
		param2='';
    //avvalora Dataprimaseduta se RDO
    if (getObj('TipoProceduraCaratteristica').value == 'RDO' || getObj('TipoProceduraCaratteristica').value == 'RFQ') {
        try {
            getObj('DataAperturaOfferte').value = getObj('DataScadenzaOfferta').value.substr(0, 17) + '01';
        } catch (e) {};
    }

	
    if (ControlliSend(param,param2) == -1) return -1;

	
	if ( getObj('TipoProceduraCaratteristica').value == 'RFQ' )
	{
		//PRE_SEND:-1:CHECKOBBLIG,BANDO_SEMPLIFICATO
		MySend( 'PRE_SEND,BANDO_SEMPLIFICATO');
		
	}
	else
	{
		ShowWorkInProgress(true);

		ToPrint(param);
	}
}



//-- 0 -- no
//-- 1 -- Dopo la soglia di sbarramento
//-- 2 -- Prima della soglia di sbarramento
function OnChange_Riparametrazione(obj) {
    try {
		
		
		
        if (getObjValue('PunteggioTEC_100') <= '0') {
			
            //-- se non viene chiesta la riparametrazione si nasconde il criterio    
            /*
			try{
				
				setVisibility(getObj('PunteggioTEC_TipoRip'), 'none');
				setVisibility(getObj('cap_PunteggioTEC_TipoRip'), 'none');
				
			}catch(e){
				
				//documento non editabile 
				//setVisibility(getObj('Cell_PunteggioTEC_TipoRip').offsetParent.offsetParent, 'none');
				
				
				
			}
			*/
			
            $("#cap_PunteggioTEC_TipoRip").parents("table:first").css({"display": "none"});
			
            ShowCol( 'CRITERI' , 'Riparametra' , 'none' );
			
			
        } else {
			
            //setVisibility(getObj('PunteggioTEC_TipoRip'), '');
            //setVisibility(getObj('cap_PunteggioTEC_TipoRip'), '');
			
			$("#cap_PunteggioTEC_TipoRip").parents("table:first").css({"display": ""});
			
            if (getObjValue('PunteggioTEC_TipoRip') < 1) {
                getObj('PunteggioTEC_TipoRip').value = '1';
            }

			if ( getObj( 'PunteggioTEC_TipoRip' ).value == '1' )
				ShowCol( 'CRITERI' , 'Riparametra' , 'none' );
			else
				ShowCol( 'CRITERI' , 'Riparametra' , '' );			
			
        }
    } catch (e) {};
}

function onChangeCalcoloSoglia(obj) 
{
    try 
	{
        if (getObjValue('CalcoloAnomalia') != '1') 
		{
            getObj('OffAnomale').value = '';
            //getObj('OffAnomale').disabled = true;
			SelectreadOnly('OffAnomale',true);
        }
		else 
		{
            //getObj('OffAnomale').disabled = false;
			SelectreadOnly('OffAnomale',false);
        }

		verifyModalitaDiCalcoloAnomalia();

    } 
	catch (e)
	{
		
	}
}

//-- 1 - Riparametro per punteggio Lotto
//-- 2 - Riparametro per punteggio parametro
//-- 3 - Riparametro per punteggio parametro e per punteggio Lotto
function OnChange_RiparametrazioneCriterio(obj) 
{

    if (getObjValue('PunteggioTEC_TipoRip') < 1) {
        getObj('PunteggioTEC_TipoRip').value = '1';
    }
	
	if ( getObj( 'PunteggioTEC_TipoRip' ).value == '1' )
		ShowCol( 'CRITERI' , 'Riparametra' , 'none' );
	else
		ShowCol( 'CRITERI' , 'Riparametra' , '' );	
}

function AddProdotto() {
    var strCommand = 'PRODOTTI#ADDFROM#IDROW=' + getObjValue('IDDOC') + '&TABLEFROMADD=DOCUMENT_ADD_PRODOTTO'

    ExecDocCommand(strCommand);

}

function UpdateModelloBando() {
    var TipoBando = getObjValue('TipoBando');
    var cod = getObjValue('id_modello');
    var docReadonly = getObjValue('DOCUMENT_READONLY');

    if (TipoBando == '' || cod == '') {
        DMessageBox('../', 'E\' necessario selezionare prima il modello', 'Attenzione', 1, 400, 300);
        return;
    }

    //Se il documento non � readonly e ci sono state delle modifiche l'apertura del documento CONFIG_MODELLI_LOTTI la posticipiamo al reload del documento, nell'after process
    if (docReadonly == '1' || ( typeof (FLAG_CHANGE_DOCUMENT) != "undefined" && FLAG_CHANGE_DOCUMENT != 1) )
        ShowDocumentPath('CONFIG_MODELLI_LOTTI', cod, '../');
    else		
		ExecDocProcess('FITTIZIO,DOCUMENT,,NO_MSG');
		
			

}

function OnChangeListaAlbi() {

    DisableObj('ClasseIscriz', false);
    ExecDocProcess('CHANGE_LISTA_ALBI,BANDO_GARA,,NO_MSG');
}

function OnChangeDataTermineQuesiti() 
{
	return;
}

function checkDataTermineQuesiti()
{
	
	
	
	
	//se valorizzata controllo DataTermineRispostaQuesiti	
	if ( getObjValue('DataTermineRispostaQuesiti') !='' )
	{
	
		var dateObj = new Date();
			
		var Riferimento = zero(dateObj.getFullYear(), 4) + '-' + zero((dateObj.getMonth() + 1), 2) + '-' + zero(dateObj.getDate(), 2) ;

		
		if (CheckData('DataTermineRispostaQuesiti', Riferimento, 'Compilare Data Termine Risposta Quesiti', 'Data Termine Risposta Quesiti deve essere maggiore di oggi' , 'day' ) == -1) return -1;
		
		// if ( getObjValue('TipoBandoGara') == '1' ) //-- per l'avviso cambiano le descrizioni dei campi
		// {
			// if (CheckData('DataScadenzaOfferta', getObjValue('DataTermineRispostaQuesiti'), 'Compilare Termine Presentazione Risposte', 'Data Termine Risposta Quesiti deve essere minore di Termine Presentazione Risposte') == -1) return -1;
		// }
		// else
		//{
			//if (CheckData('DataScadenzaOfferta', getObjValue('DataTermineRispostaQuesiti'), 'Compilare Termine Presentazione Risposte', 'Data Termine Risposta Quesiti deve essere minore di Termine Presentazione Risposte') == -1) return -1;
		//}
		if (CheckData('DataScadenzaOfferta', getObjValue('DataTermineRispostaQuesiti'), 'Compilare Termine Presentazione Risposte', 'Data Termine Risposta Quesiti deve essere minore di Termine Presentazione Risposte') == -1) return -1;
	}
}

function OnChangeDataScadenzaOfferta() 
{
	return;
}

function checkDataScadenzaOfferta()
{
	var dateObj = new Date();
    
	var Riferimento = zero(dateObj.getFullYear(), 4) + '-' + zero((dateObj.getMonth() + 1), 2) + '-' + zero(dateObj.getDate(), 2) ;

	// if ( getObjValue('TipoBandoGara') == '1' ) //-- per l'avviso cambiano le descrizioni dei campi
	// {
		// if (CheckData('DataScadenzaOfferta', Riferimento, 'Compilare Termine Presentazione Risposte', 'Termine Presentazione Risposte deve essere maggiore di oggi','day') == -1) return -1;
		// if (CheckData('DataScadenzaOfferta', getObjValue('DataTermineRispostaQuesiti'), 'Compilare Data Termine Risposta Quesiti', 'Termine Presentazione Risposte deve essere maggiore di Data Termine Risposta Quesiti') == -1) return -1;
	// }
	// else
	//{
	//	if (CheckData('DataScadenzaOfferta', Riferimento, 'Compilare Data Scadenza Offerta', 'Data Scadenza Offerta deve essere maggiore di oggi','day') == -1) return -1;
	//	if (CheckData('DataScadenzaOfferta', getObjValue('DataTermineRispostaQuesiti'), 'Compilare Data Termine Risposta Quesiti', 'Data Scadenza Offerta deve essere maggiore di Data Termine Risposta Quesiti') == -1) return -1;
	//}
	
	if (CheckData('DataScadenzaOfferta', Riferimento, 'Compilare Termine Presentazione Risposte', 'Termine Presentazione Risposte deve essere maggiore di oggi','day') == -1) return -1;
	if (CheckData('DataScadenzaOfferta', getObjValue('DataTermineRispostaQuesiti'), 'Compilare Data Termine Risposta Quesiti', 'Termine Presentazione Risposte deve essere maggiore di Data Termine Risposta Quesiti') == -1) return -1;
}

//per nascondere il contenuto della colonna Busta Tecnica per quei lotti che non ne hanno bisogno
function HideBustaTecnicaLotti() {

    //-- divisione_lotti <> 0 non � monolotto 
    var numrowlotto = -1;

    try {
        if (getObjValue('Divisione_lotti') != '0')
            numrowlotto = GetProperty(getObj('LISTA_BUSTEGrid'), 'numrow');
    } catch (e) {}


    for (z = 0; z <= numrowlotto; z++) {
		
        if (getObjValue('RLISTA_BUSTEGrid_' + z + '_PresenzaBustaTecnica') == '0') {

            getObj('LISTA_BUSTEGrid_r' + z + '_c3').innerHTML = '';

        }
    }

}

function onChangeDomAttribCriterio(obj, dest)
{
	//obj.id = RCRITERIGrid_0_AttributoCriterio	 ( prima )
	var riga = obj.id.split('_')[1];
	
	if ( isNumeric(riga) == false )
	{
		//obj.id = RCRITERI_ECO_RIGHEGrid_0_AttributoBase ( ora )
		riga = obj.id.split('_')[3];
	}
	
	
	var value = obj.value;

	//Travaso la selezione effettuata sul dominio 'attributo', nel campo tecnico nascosto. per poi recuperarlo nell'afterprocess
	//getObj('RCRITERIGrid_' + riga + '_CampoTesto_1').value = value;
		//RCRITERI_ECO_RIGHEGrid_3_CampoTesto_2
	try
	{
		getObj('RCRITERIGrid_' + riga + '_' + dest).value = value;
	}
	catch(e)
	{
		getObj('RCRITERI_ECO_RIGHEGrid_' + riga + '_' + dest).value = value;
	}

}

function MyOpenViewer(param)
{	
	//processo fittizio che non fa niente usato solo per far eseguire un salvataggio al documento
	ExecDocProcess( 'SAVE_AND_GO,CODIFICA_PRODOTTI,,NO_MSG');
}

function selezionaMetaprodotto(objGrid, Row, c)
{
  
  ShowWorkInProgress();
  var idRow;
  var DOC_TO_UPD=getQSParam('doc_to_upd');
	if ( objGrid == '' )
	{
		//-- recupera il codice delle righe selezionate
		idRow = Grid_GetIdSelectedRow( 'GridViewer' );
	}
	else
	{
		idRow = getObj('GridViewer_idRow_' + Row ).value;
	}
	
	if( idRow == '' )
	{
	  DMessageBox( '../' , 'E\' necessario selezionare prima una riga' , 'Attenzione' , 2 , 400 , 300 );  
	}
	else
	{		
		var parametri =  'PRODOTTI#ADDFROM#IDROW=' + idRow + '&IDDOC='+ DOC_TO_UPD +'&RESPONSE_ESITO=YES&TABLEFROMADD=DASHBOARD_VIEW_ELENCO_CODIFICHE_META_PRODOTTI_ADDTO_BANDO_GARA&DOCUMENT=BANDO_GARA';
		Viewer_Dettagli_AddSel( parametri);				
		
	}  
}
function cercaperambito(tipoProd)
{
	var ambito = getObjValue('MacroAreaMerc');
	
	tipoProd = tipoProd || 'meta'; //Default per il parametro opzionale tipoProd
	
	if ( ambito == '' )
	{
		DMessageBox( '../' , 'E\' necessario selezionare prima un ambito' , 'Attenzione' , 1 , 400 , 300 );
		return false;
	}
	else
	{
		var oldAction = document.forms[0].action;
		
		var oldDocument = getQSParamNew(oldAction, 'document');
		var oldMod = getQSParamNew(oldAction, 'modgriglia');

		var newDocument = 'DOCUMENT_CODIFICA_PRODOTTO_' + ambito;
		var newMod = '';
		
		if ( tipoProd == 'meta' )
			newMod = 'ELENCO_CODIFICHE_META_PRODOTTI_' + ambito + '_MOD_Griglia';
		else
			newMod = 'ELENCO_CODIFICHE_PRODOTTI_' + ambito + '_MOD_Griglia';

		var newAction = ReplaceExtended(oldAction,'document=' + oldDocument, 'document=' + newDocument);
		newAction = ReplaceExtended(newAction,'modgriglia=' + oldMod,'modgriglia=' + newMod);		
		document.forms[0].action = newAction;
	}
	
	
}

function afterProcess(param) 
{

	if ( param == 'SAVE_DOC' )
	{
		ElabAIC();  
	}
	
	if (param == 'FITTIZIO') 
	{
		var cod = getObjValue('id_modello');
		ShowDocumentPath('CONFIG_MODELLI_LOTTI', cod, '../');
	}

	if ( param == 'SAVE_AND_GO' )
	{
		var filter='MacroAreaMerc = \'' + getObjValue('RTESTATA_PRODOTTI_MODEL_Ambito') + '\'';		
		OpenViewer('Viewer.asp?OWNER=&Table=DASHBOARD_VIEW_ELENCO_CODIFICHE_META_PRODOTTI&ModelloFiltro=DASHBOARD_VIEW_ELENCO_CODIFICHE_PRODOTTIFiltro&ModGriglia=ELENCO_CODIFICHE_META_PRODOTTI_' + getObjValue('RTESTATA_PRODOTTI_MODEL_Ambito') + '_MOD_Griglia&Filter='+encodeURIComponent(filter)+'&IDENTITY=ID&lo=base&HIDE_COL=&DOCUMENT=DOCUMENT_CODIFICA_PRODOTTO_' + getObjValue('RTESTATA_PRODOTTI_MODEL_Ambito') +'&PATHTOOLBAR=../CustomDoc/&JSCRIPT=BANDO_GARA&AreaAdd=no&Caption=Ricerca Meta Prodotti&Height=180,100*,210&numRowForPag=20&Sort=Id&SortOrder=asc&Exit=si&AreaFiltro=&AreaFiltroWin=1&TOOLBAR=TOOLBAR_VIEW_RICERCA_METAPRODOTTI&ACTIVESEL=2&FilterHide=&ONSUBMIT=return cercaperambito()&doc_to_upd='+ getObj('IDDOC').value);
		
	}

	if (param == 'SELEZIONA') 
	{
		var iddoc = getObj('IDDOC').value;
		//ReloadDocFromDB( getObj('IDDOC').value , 'BANDO_RICHIESTA_CODIFICA' );
		ShowDocument('BANDO_RICHIESTA_CODIFICA', iddoc, 'YES');
	}
	if (param == 'FITTIZIO2') 
	{

		MakeDocFrom('RICERCA_OE#1024,768#BANDO_GARA#'+ getObj('IDDOC').value + '#./../');	
	}
	
	if (param == 'FITTIZIO3') 
	{
		MakeDocFrom ( 'RICHIESTA_SMART_CIG##BANDO' );
	}
	
	if (param == 'FITTIZIO4') 
	{
		MakeDocFrom ( 'RICHIESTA_CIG##BANDO' );	
	}
	
	if (param == 'FITTIZIO5') 
	{
		//MakeDocFrom ( 'RICHIESTA_CIG##AFFIDAMENTOSEMPLIFICATO' );	
		MakeDocFrom ( 'RICHIESTA_CIG##BANDO_CONCORSO');	
	}
	
	if ( param == 'FLUSH_PRODOTTI' )
	{
		FiltraModelli();
	}
	
	if (param == 'RICHIEDI_PUBBLICA_TED')
	{
		MakeDocFrom ( 'PUBBLICA_GARA_TED##BANDO' );	
	}
	
	/*
	if (param == 'SELEZIONA_RAPIDA') 
	{
		var iddoc = getObj('IDDOC').value;
		//ReloadDocFromDB( getObj('IDDOC').value , 'BANDO_RICHIESTA_CODIFICA' );
		ShowDocument('BANDO_RICHIESTA_CODIFICA_RAPIDA', iddoc, 'YES');
	}
	*/
	
}


function MyOpenViewerAziende(){

  
  //aggiorno documento in meoria
  UpdateDocInMem( getObj( 'IDDOC' ).value, getObj( 'TYPEDOC' ).value );

  //apro il viewer per selezionare azienda
  OpenViewer('Viewer.asp?OWNER=&Table=dashboard_view_aziende&ModelloFiltro=&ModGriglia=&Filter=&IDENTITY=IDAZI&lo=base&HIDE_COL=&DOCUMENT=BANDO_GARA&PATHTOOLBAR=../CustomDoc/&JSCRIPT=BANDO_GARA&AreaAdd=no&Caption=Ricerca Ente&Height=180,100*,210&numRowForPag=20&Sort=aziragionesociale&SortOrder=asc&Exit=si&AreaFiltro=&AreaFiltroWin=1&TOOLBAR=dashboard_view_aziende_toolbar&ACTIVESEL=1&FilterHide=Aziacquirente<>0&ONSUBMIT=&doc_to_upd='+ getObj('IDDOC').value );

}


function ChangeMittenteSelRow  ( objGrid , Row , c ){
  
  
  var idRow;
  var DOC_TO_UPD=getQSParam('doc_to_upd');
	
		
	idRow = getObj('GridViewer_idRow_' + Row ).value;
	
  	
	var nocache = new Date().getTime();
	var param;
		
	param='IDDOC=' + DOC_TO_UPD + '&TYPEDOC=BANDO_GARA&SECTION=TESTATA&FIELD=Azienda&FIELD_VALUE=' + idRow ;
	
	ajax = GetXMLHttpRequest();		
	
	ajax.open("GET",'../ctl_library/document/Upd_Field_Document_InMem.asp?' + param + '&nocache=' + nocache , false);
	ajax.send(null);
	//alert(ajax.readyState);
	
	if(ajax.readyState == 4) 
	{
	  //alert(ajax.status); 
		if(ajax.status == 404 || ajax.status == 500)
		{
		  alert('Errore invocazione pagina');				  
		}
	  //alert(ajax.responseText); 
		if ( ajax.responseText == 'OK' ) 
		{
			//ritorno al documento di codifica prodotti se tutto ok
			breadCrumbPop('');
		}
		
		if ( ajax.responseText == 'ERRORE_DOCUMENTO_DA_AGGIORNARE' ) 
		{
		 alert('Errore: Stato del documento da aggiornare diverso da in lavorazione');				  
		}
	 
	 }
		 

  
}

function setRegExpCIG()
{
	try
	{
		var DOCUMENT_READONLY = '0';

		try
		{
			DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;
		}
		catch(e){DOCUMENT_READONLY = '1'}

		if (DOCUMENT_READONLY == '0') 
		{
			var divisioneLotti = getObjValue('Divisione_lotti');
			var oldOnChange = getObj('CIG').getAttribute('onchange');
			//alert(oldOnChange);
			var newOnChange = '';

			// Se divisione in lotti NO, obbligo un CIG di lunghezza 10. Altrimenti Se divisione in lotti <> 0 lo imposto su 7
			if ( divisioneLotti == '0' )
			{
				//newOnChange = ReplaceExtended(oldOnChange,'^[\da-zA-Z]{7,7}$', '^[\da-zA-Z]{10,10}$');
				//newOnChange = ReplaceExtended(newOnChange,'^[\da-zA-Z]{7,10}$', '^[\da-zA-Z]{10,10}$');
				newOnChange = "if ( validateField('^[\\\\da-zA-Z]{10,10}$',this) ) OnChangeNumeroGara ( this );" ;
			}
			else
			{
				//newOnChange = ReplaceExtended(oldOnChange,'^[\da-zA-Z]{7,10}$', '^[\da-zA-Z]{7,7}$');
				//newOnChange = ReplaceExtended(newOnChange,'^[\da-zA-Z]{10,10}$', '^[\da-zA-Z]{7,7}$');
				newOnChange = "if ( validateField('^[\\\\da-zA-Z]{7,7}$',this) ) OnChangeNumeroGara ( this ); " ;
			}

			getObj('CIG').setAttribute('onchange', newOnChange);
		}

	}
	catch(e)
	{
	}
}

function OnChangeAlfa(obj) 
{
	var idAlfa = obj.id.replace('_V','');
	var alfa = getObjValue(idAlfa);

	if ( alfa != '' )
	{
		var numberAlfa = parseFloat(alfa);
			
		/* ACCETTO VALORI > DI 0 E <> DA 1 */
		if ( numberAlfa <= 0 || numberAlfa == 1 )
		{
			obj.value = '';
			getObj(idAlfa).value = '';
			DMessageBox( '../' , 'La costante alfa deve essere un valore maggiore di 0 e diverso da 1' , 'Attenzione' , 1 , 400 , 300 );
		}
		
		
	}
	
	
}

function verifyModalitaDiCalcoloAnomalia()
{

	//Gli attributi ModalitaAnomalia_TEC e ModalitaAnomalia_ECO, potrebbero non esserci , gestisco con try catch
	try
	{
		var CalcoloAnomalia = getObjValue('CalcoloAnomalia');
		var CriterioAggiudicazione = getObjValue('CriterioAggiudicazioneGara');
		
		/* se la gara � economicamente vantaggiosa oppure COSTO FISSO e si � scelto "Calcolo Anomalia" = 'si' 
			visualizzo i campi ModalitaAnomalia_TEC e ModalitaAnomalia_ECO*/
		if ( ( CriterioAggiudicazione == '15532' || CriterioAggiudicazione == '25532' ) && CalcoloAnomalia == '1' )
		{
			try
			{
				setVisibility(getObj('Cell_ModalitaAnomalia_TEC').offsetParent.offsetParent, '');
				setVisibility(getObj('Cell_ModalitaAnomalia_ECO').offsetParent.offsetParent, '');
			}
			catch(e)
			{
			}

			getObj('cap_ModalitaAnomalia_TEC').style.display = '';
			getObj('ModalitaAnomalia_TEC').style.display = '';
			
			getObj('cap_ModalitaAnomalia_ECO').style.display = '';
			getObj('ModalitaAnomalia_ECO').style.display = '';
		}
		else
		{
			getObj('cap_ModalitaAnomalia_TEC').style.display = 'none';
			getObj('ModalitaAnomalia_TEC').style.display = 'none';
			getObj('ModalitaAnomalia_TEC').value = '';
			
			try
			{
				setVisibility(getObj('Cell_ModalitaAnomalia_TEC').offsetParent.offsetParent, 'none');
			}
			catch(e)
			{
			}
			
			getObj('cap_ModalitaAnomalia_ECO').style.display = 'none';
			getObj('ModalitaAnomalia_ECO').style.display = 'none';
			getObj('ModalitaAnomalia_ECO').value = '';
			
			try
			{
				setVisibility(getObj('Cell_ModalitaAnomalia_ECO').offsetParent.offsetParent, 'none');
			}
			catch(e)
			{
			}
			
		}
	}
	catch(e)
	{
	}

}

function OnChangePunteggio(obj)
{
	
	var idpunteggio = obj.id.replace('_V','');
	var idpunteggiomin = idpunteggio.replace('PunteggioMax','PunteggioMin');
	var idpunteggiomax = idpunteggio.replace('PunteggioMin','PunteggioMax');
	var punteggiomin = getObjValue(idpunteggiomin);
	var punteggiomax = getObjValue(idpunteggiomax);
	//controllo da fare solo se ho appena digitato Punteggio min
	if ( idpunteggio.indexOf('PunteggioMin') >= 0 )
	{
		if (parseFloat(punteggiomin) < 0) 
		{
			getObj(idpunteggiomin).value='';
			getObj(idpunteggiomin + '_V').value='';
			DMessageBox('../', 'Sulla griglia Criteri di valutazione Soglia Minima Punteggio per ogni singola riga non deve essere minore di zero.', 'Attenzione', 1, 400, 300);        
			return -1;
		}
	}
	if ( idpunteggio.indexOf('PunteggioMax') >= 0 )
	{
		if (isNaN(parseFloat(punteggiomax)) || parseFloat(punteggiomax) == 0 || parseFloat(punteggiomax) <= 0) 
		{
			getObj(idpunteggiomax).value='';
			getObj(idpunteggiomax + '_V').value='';
			DMessageBox('../', 'Sulla griglia Criteri di valutazione Punteggio per ogni singola riga deve essere maggiore di zero.', 'Attenzione', 1, 400, 300);        
			return -1;
		}
	}
	if ( idpunteggio.indexOf('PunteggioMin') >= 0 )
	{
		if ( parseFloat(punteggiomax) < parseFloat(punteggiomin) ) 
		{
			getObj(idpunteggiomin).value='';
			getObj(idpunteggiomin + '_V').value='';
			DMessageBox('../', 'Inserire una soglia minima minore o uguale al punteggio', 'Attenzione', 1, 400, 300);        
			return -1;
			
		}
	}
	if ( idpunteggio.indexOf('PunteggioMax') >= 0 )
	{
		if ( parseFloat(punteggiomax) < parseFloat(punteggiomin) ) 
		{
			getObj(idpunteggiomin).value=punteggiomax;
			getObj(idpunteggiomin + '_V').value=punteggiomax;
			return -1;
			
		}	
	}
}

function Esito( comando )
{
	var Selezione = document.getElementsByName('Selezione');
    var indRow = getCheckedValueRow( Selezione );

    if ( indRow == '' )
	{
      alert(  CNV( '../../' ,  'E\' necessario selezionare prima una riga' ) );
      return;
    }

	var idRow = getObjValue( 'R' + indRow +  '_idRow' );
	
	var statIscrizione = getObjValue('val_R' + indRow + '_StatoManifestazioneInteresse');
	
	
	if ( comando == 'Esclusa' && statIscrizione == 'Iscritto' )
	{
		MakeDocFrom( 'ESITO_ESCLUSA_MANIFESTAZIONE_INTERESSE#900,800#BANDO_GARA#' + idRow );
        return;
	}

	if ( comando == 'Annulla' && statIscrizione != 'Iscritto' )
	{
		MakeDocFrom( 'ESITO_ANNULLA_MANIFESTAZIONE_INTERESSE#900,800#BANDO_GARA#' + idRow );
        return;
	}

	alert(  CNV( '../../' ,  'Il cambiamento richiesto non e coerente con lo stato del documento' ));

}

function Valutazione( comando )
{
	var Selezione = document.getElementsByName('Selezione');
    var indRow = getCheckedValueRow( Selezione );

    if ( indRow == '' )
	{
      alert(  CNV( '../../' ,  'E\' necessario selezionare prima una riga' ) );
      return;
    }

	var idRow = getObjValue( 'R' + indRow +  '_idRow' );
	
	var statIscrizione = getObjValue('val_R' + indRow + '_StatoManifestazioneInteresse');
	
	
	if ( comando == 'Selezionato' && statIscrizione == 'Valutato' )
	{
		MakeDocFrom( 'ESITO_SELEZIONATO_MANIFESTAZIONE_INTERESSE#900,800#BANDO_GARA#' + idRow );
        return;
	}

	if ( comando == 'Annulla' && statIscrizione != 'Valutato' )
	{
		MakeDocFrom( 'ESITO_ANNULLA_MANIFESTAZIONE_INTERESSE#900,800#BANDO_GARA#' + idRow );
        return;
	}

	alert(  CNV( '../../' ,  'Il cambiamento richiesto non e coerente con lo stato del documento' ));

}

function getCheckedValue(radioObj) 
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
function DGUE_Request_Active()
{
	//--- attiva la presenza del template che se assente viene creato con un processo
	if( getObjValue( 'PresenzaDGUE' ) == 'si' && getObjValue( 'idTemplate') == '' )
	{
		ExecDocProcess( 'ATTIVA_DGUE,BANDO_GARA_MANDATARIA,,NO_MSG');
	}
	if( getObjValue( 'PresenzaDGUE' ) == 'si' )
	{
		$("#cap_PresenzaDGUE_Mandanti").parents("table:first").css({"display": ""});	
		$("#cap_PresenzaDGUE_Ausiliarie").parents("table:first").css({"display": ""});
		
		$("#cap_FNZ_UPD_Mandanti").parents("table:first").css({"display": ""});
		$("#cap_FNZ_UPD_Ausiliarie").parents("table:first").css({"display": ""});	
		
		if ( getObjValue('SYS_OFFERTA_PRESENZA_ESECUTRICI') == 'YES' )
		{
			$("#cap_PresenzaDGUE_Subappaltarici").parents("table:first").css({"display": ""});
			$("#cap_FNZ_UPD_Subappaltarici").parents("table:first").css({"display": ""});	
			
		}
		
		var Richiesta_terna_subappalto = '';
		try{  Richiesta_terna_subappalto = getObjValue('Richiesta_terna_subappalto') } catch(e){};
		
		
		if ( Richiesta_terna_subappalto == '1' )
		{		
			$("#cap_PresenzaDGUE_SubAppalto").parents("table:first").css({"display": ""});
			$("#cap_FNZ_UPD_Subappalto").parents("table:first").css({"display": ""});
		}
		else
		{
			$("#cap_PresenzaDGUE_SubAppalto").parents("table:first").css({"display": "none"});
			$("#cap_FNZ_UPD_Subappalto").parents("table:first").css({"display": "none"});
		}
			
		
		
	}	
	if( getObjValue( 'PresenzaDGUE' ) == 'no' )
	{
		
		//se "Invio GUEE" si blocco con un messaggio
		var RichiestaTED = getObjValue('RichiestaTED');
		if ( RichiestaTED == 'si' )
		{
			getObj('PresenzaDGUE').value = 'si';	
			
			DMessageBox('../', 'Per disattivare la richiesta del DGUE e necessario disattivare l\'invio alla GUEE', 'Attenzione', 1, 400, 300);
			return;
		}
		
		$("#cap_PresenzaDGUE_Mandanti").parents("table:first").css({"display": "none"});	
		$("#cap_PresenzaDGUE_Ausiliarie").parents("table:first").css({"display": "none"});
		$("#cap_PresenzaDGUE_Subappaltarici").parents("table:first").css({"display": "none"});
		$("#cap_FNZ_UPD_Mandanti").parents("table:first").css({"display": "none"});
		$("#cap_FNZ_UPD_Ausiliarie").parents("table:first").css({"display": "none"});	
		$("#cap_FNZ_UPD_Subappaltarici").parents("table:first").css({"display": "none"});
		$("#cap_PresenzaDGUE_SubAppalto").parents("table:first").css({"display": "none"});
		$("#cap_FNZ_UPD_Subappalto").parents("table:first").css({"display": "none"});
			
	}
	
}

function DGUE_Request_Active_Mandanti()
{
	if( getObjValue( 'PresenzaDGUE_Mandanti' ) == 'si' && getObjValue( 'idTemplate_Mandanti') == '' )
	{
		ExecDocProcess( 'ATTIVA_DGUE,BANDO_GARA_MANDANTI,,NO_MSG');
	}
}
function DGUE_Request_Active_Ausiliarie()
{
	if( getObjValue( 'PresenzaDGUE_Ausiliarie' ) == 'si' && getObjValue( 'idTemplate_Ausiliarie') == '' )
	{
		ExecDocProcess( 'ATTIVA_DGUE,BANDO_GARA_Ausiliarie,,NO_MSG');
	}
}
function DGUE_Request_Active_Subappaltarici()
{
	if( getObjValue( 'PresenzaDGUE_Subappaltarici' ) == 'si' && getObjValue( 'idTemplate_Subappaltarici') == '' )
	{
		ExecDocProcess( 'ATTIVA_DGUE,BANDO_GARA_SUBAPPALTATRICI,,NO_MSG');
	}
}

function DGUE_Request_Active_Subappalto()
{
	if( getObjValue( 'PresenzaDGUE_SubAppalto' ) == 'si' && getObjValue( 'idTemplate_Subappalto') == '' )
	{
		ExecDocProcess( 'ATTIVA_DGUE,BANDO_GARA_Subappalto,,NO_MSG');
	}
}

function DGUE_Request()
{	
	if( getObjValue( 'PresenzaDGUE' ) == 'si' )
	{
		MakeDocFrom ( 'TEMPLATE_CONTEST##BANDO_GARA_MANDATARIA' );		
	}
	else
	{
		DMessageBox('../', 'E\' necessario aver selezionato la presenza del DGUE', 'Attenzione', 1, 400, 300);
	}

}
function DGUE_Request_Mandanti()
{	
	if( getObjValue( 'PresenzaDGUE_Mandanti' ) == 'si' )
	{
		MakeDocFrom ( 'TEMPLATE_CONTEST##BANDO_GARA_MANDANTI' ) ;		
	}
	else
	{
		DMessageBox('../', 'E\' necessario aver selezionato la presenza del DGUE', 'Attenzione', 1, 400, 300);
	}
}
function DGUE_Request_Ausiliarie()
{	
	if( getObjValue( 'PresenzaDGUE_Ausiliarie' ) == 'si' )
	{
		MakeDocFrom ( 'TEMPLATE_CONTEST##BANDO_GARA_AUSILIARIE' ) ;		
	}
	else
	{
		DMessageBox('../', 'E\' necessario aver selezionato la presenza del DGUE', 'Attenzione', 1, 400, 300);
	}
}
function DGUE_Request_Subappalt()
{	
	if( getObjValue( 'PresenzaDGUE_Subappaltarici' ) == 'si' )
	{
		MakeDocFrom ( 'TEMPLATE_CONTEST##BANDO_GARA_SUBAPPALTATRICI' ) ;	
	}
	else
	{
		DMessageBox('../', 'E\' necessario aver selezionato la presenza del DGUE', 'Attenzione', 1, 400, 300);
	}
	
}

function DGUE_Request_Subappalto()
{	
	if( getObjValue( 'PresenzaDGUE_SubAppalto' ) == 'si' )
	{
		MakeDocFrom ( 'TEMPLATE_CONTEST##BANDO_GARA_SUBAPPALTO' ) ;	
	}
	else
	{
		DMessageBox('../', 'E\' necessario aver selezionato la presenza del DGUE', 'Attenzione', 1, 400, 300);
	}
	
}

function EsportaOfferteInXLSX() 
{
	var extraHideCol = '';
	var TipoDoc = 'OFFERTA';
	
	if (getObjValue('Divisione_lotti') == '0') 
	{
		extraHideCol = ',lottiOfferti';		
	}
	
	//BANDO di RISTRETTA rispondono con le domande di partecipazione
	if ( getObjValue( 'ProceduraGara' ) == '15477' &&  getObjValue('TipoBandoGara') == '2'  )
	{
		TipoDoc = 'DOMANDA_PARTECIPAZIONE';
	}		
	
	
    ExecFunction('../../CTL_Library/accessBarrier.asp?goto=xlsx.aspx&TitoloFile=offerte&FILTER=linkeddoc%3D' + getObjValue('IDDOC') + '&TIPODOC=' + TipoDoc + '&MODEL=BANDO_SDA_LISTA_OFFERTEGriglia&VIEW=BANDO_SDA_LISTA_OFFERTE&HIDECOL=FNZ_OPEN,Name' + extraHideCol + '&Sort=DataInvio%20asc&IDDOC=' + getObjValue('IDDOC'), '_blank', '');
}

function EsportaManInterInXLSX() 
{
    ExecFunction('../../CTL_Library/accessBarrier.asp?goto=xlsx.aspx&TitoloFile=Manifestazioni_di_interesse&&FILTER=linkeddoc%3D' + getObjValue('IDDOC') + '&TIPODOC=MANIFESTAZIONE_INTERESSE&MODEL=LISTA_MANIF_INTERESGriglia&VIEW=VIEW_LISTA_MANIF_INTERES&HIDECOL=FNZ_OPEN,Name,bReadDocumentazione,Selezione&Sort=ordina%20asc&IDDOC=' + getObjValue('IDDOC'), '_blank', '');
}

function EsportaPartecipantiLottiInXLSX()
{
   ExecFunction('../../CTL_Library/accessBarrier.asp?goto=xlsx.aspx&TitoloFile=Partecipanti_per_lotto&FILTER=linkeddoc%3D' + getObjValue('IDDOC') + '&TIPODOC=OFFERTA&MODEL=PARTECIPANTI_LOTTI_GRIGLIA&VIEW=LISTA_OFFERTE_PER_LOTTO&HIDECOL=FNZ_OPEN,Name,lottiOfferti&Sort=aziRagioneSociale%20asc%2CNumeroLotto%20asc&IDDOC=' + getObjValue('IDDOC'), '_blank', '');
}

function OpenManInteresse(objGrid,Row,c)
{
	var cod;
	var nq;

	//-- recupero il codice della riga passata
	cod = GetIdRow( objGrid , Row , 'self' );
	
	ShowDocument( 'MANIFESTAZIONE_INTERESSE' , cod );
}


function EsportaDestinatariInXLSX() 
{
	var extraHideCol = '';
	
	
    ExecFunction('../../CTL_Library/accessBarrier.asp?goto=xlsx.aspx&TitoloFile=Destinatari&FILTER=idheader%3D' + getObjValue('IDDOC') + '&MODEL=BANDO_GARA_DESTINATARI&table=CTL_DOC_Destinatari&HIDECOL=&Sort=idRow%20asc&IDDOC=' + getObjValue('IDDOC'), '_blank', '');
}


function OnChangeRichiediDocumentazione()
{
	
	if (getObjValue('RichiediDocumentazione') == '0') 
	{
		DocDisplayFolder(  'DOCUMENTAZIONE_RICHIESTA' ,'none' );	
		
	}else
	{
		DocDisplayFolder(  'DOCUMENTAZIONE_RICHIESTA' ,'' );	
	}		
	
	
}	



function CriterioDel( g , r , c )
{
    if ( getObjValue( 'RCRITERIGrid_' + r + '_CriterioValutazione' ) == 'ereditato')
        return;
    else
        return DettagliDel(g , r , c)
}

function CriterioCopy ( g , r , c )
{
    if ( getObjValue( 'RCRITERIGrid_' + r + '_CriterioValutazione' ) == 'ereditato')
        return;
    else
        return DettagliCopy( g , r , c )
}



function OnChangeMaxEreditato( obj )
{
    //-- sul rilancio competitivo se � cambiato il massimo ereditabile lo riportiamo sulla riga del criterio ereditato
    if ( getObjValue( 'RCRITERIGrid_0_CriterioValutazione' ) == 'ereditato' )
    {
        SetNumericValue( 'RCRITERIGrid_0_PunteggioMax' , getObjValue( 'PunteggioTecMaxEredit' ) );
    }  
}

function Calc_Max_Ereditabile()
{
	var AQ_RILANCIO_COMPETITVO = '';
	var check;
    try { AQ_RILANCIO_COMPETITVO = getObjValue( 'AQ_RILANCIO_COMPETITVO') } catch( e ){};    
	
	try
	{
		var DOCUMENT_READONLY;
		try{DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;}catch(e){ DOCUMENT_READONLY = '1'};
		if ( AQ_RILANCIO_COMPETITVO == 'yes' && DOCUMENT_READONLY == '0' ) 
		 {
			
			var numrighe = GetProperty(getObj('CRITERI_AQ_EREDITA_TECGrid'), 'numrow');
			
			PunteggioTecPercEredit = parseFloat( getObjValue('PunteggioTecPercEredit'));
			PunteggioTecMinEredit = parseFloat( getObjValue('PunteggioTecMinEredit'));
            PunteggioTecMaxEredit = parseFloat( getObjValue('PunteggioTecMaxEredit'));
			 //PunteggioTecMinEredit <= PunteggioTecPercEredit <= PunteggioTecMaxEredit
			if( PunteggioTecPercEredit < 0  || PunteggioTecPercEredit  >  PunteggioTecMaxEredit ||  PunteggioTecPercEredit < PunteggioTecMinEredit)
			{				
				DMessageBox('../', 'La "% Ereditata" deve essere un valore compreso fra la "Minima percentuale ereditabile" ed la "Massima percentuale ereditabile"', 'Attenzione', 1, 400, 300);
				return -1;
			}
            
			
			SommaMax_Ereditabile = 0.0;

			  for (i = 0; i <= numrighe; i++) 
			  {
				   
				   try {
						check = getObj( 'RCRITERI_AQ_EREDITA_TECGrid_' + i + '_Eredita_V' ).checked;
					} catch (e) {
						check = getObj( 'RCRITERI_AQ_EREDITA_TECGrid_' + i + '_Eredita' ).checked;
					}
					
				   if (check)
					{
					   SommaMax_Ereditabile += parseFloat(getObjValue('RCRITERI_AQ_EREDITA_TECGrid_'+i+'_PunteggioMax'));
					}
					
					
			  }
			  
			 SommaMax_Ereditabile= roundTo(( SommaMax_Ereditabile * ( PunteggioTecPercEredit / 100.0 )),2);
			 
			if ( isNaN(parseFloat(SommaMax_Ereditabile)) )
			{
				SommaMax_Ereditabile=0.0;
			}
			//-- sul rilancio competitivo se � cambiato il massimo ereditabile lo riportiamo sulla riga del criterio ereditato
			if ( getObjValue( 'RCRITERIGrid_0_CriterioValutazione' ) == 'ereditato' )
			{
				SetNumericValue( 'RCRITERIGrid_0_PunteggioMax' , SommaMax_Ereditabile );
			}
		 }			
	} catch(e){};
}


function roundTo(X , decimalpositions)
{
    var i = X * Math.pow(10,decimalpositions);
    i = Math.round(i);
    return i / Math.pow(10,decimalpositions);
}


function ActiveSelStruttura()
 {
	 getObj( 'TIPO_AMM_ER_button' ).onclick();
 }
 
  function ADD_Enti( obj)
 {
	 ExecDocProcess( 'ADD_ENTI,BANDO_GARA,,NO_MSG' );
 }
 
 
function EditCriterioAQ(objGrid, Row, c) {
	
    if (getObjValue('RCRITERI_AQ_EREDITA_TECGrid_' + Row + '_CriterioValutazione') == 'quiz') {
        //recupero TipoGiudizioTecnico
        var TipoGiudizioTecnico = '';

        try {
            var TipoGiudizioTecnico = getObj('TipoGiudizioTecnico').value;

            if (document.getElementById('ModAttribPunteggio')) {
                var criterio = getObjValue('ModAttribPunteggio');

                if (criterio != '' && criterio != 'giudizio') {
                    TipoGiudizioTecnico = 'number';
                }
            }

        } catch (e) {}
		
		
        if ( getObjValue('StatoFunzionale') == 'InLavorazione' || getObjValue('StatoFunzionale') == 'InRettifica' ) {
            Open_Quiz('../', 'RCRITERI_AQ_EREDITA_TECGrid_' + Row + '_Formula', 'C', getObjValue('RCRITERI_AQ_EREDITA_TECGrid_' + Row + '_DescrizioneCriterio'), TipoGiudizioTecnico, 'RCRITERI_AQ_EREDITA_TECGrid_' + Row + '_AttributoCriterio' );
        } else {
            Open_Quiz('../', 'RCRITERI_AQ_EREDITA_TECGrid_' + Row + '_Formula', 'V', getObjValue('RCRITERI_AQ_EREDITA_TECGrid_' + Row + '_DescrizioneCriterio'), TipoGiudizioTecnico, 'RCRITERI_AQ_EREDITA_TECGrid_' + Row + '_AttributoCriterio' );
        }

    }

}

//nChanged indica se cambiata la selezione
function onChangeGeneraConvenzione( nChanged )
{
	//Se esistono gli attributi 'GeneraConvenzione' e 'TipoAggiudicazione'
	//e 'Genera Convenzione completa' � diverso da si, nascondiamo 'TipoAggiudicazione'
	var DOCUMENT_READONLY;
	try{DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;}catch(e){ DOCUMENT_READONLY = '1'};
	
	if ( getObj('GeneraConvenzione') && getObj('TipoAggiudicazione') && getObj('TipoSceltaContraente').value != 'ACCORDOQUADRO' )
	{
		if ( getObjValue('GeneraConvenzione') != '1' )
		{

			if ( DOCUMENT_READONLY == '0' )
				getObj('TipoAggiudicazione').value = 'monofornitore';

			$("#cap_TipoAggiudicazione").parents("table:first").css({"display": "none"});
		}
		else
		{
			$("#cap_TipoAggiudicazione").parents("table:first").css({"display": ""});
		}
	}
	
	try
	{
		if ( getObjValue('GeneraConvenzione') == '1' )
			getObj( 'Accordo_di_Servizio' ).value ='no'; 
	}catch(e){};
	
	//nel caso procedura a lotti ed � cambiata generaconvezione innesco processo server
	if ( getObjValue('Divisione_lotti') != '0' )
	{	
		if ( nChanged == 1)
			ExecDocProcess('CHANGE_GENERACONVENZIONE,BANDO_GARA');
	}
}


function Handle_Eredita_AQ(){
	
	var TipoSceltaContraente = '';
    var AQ_RILANCIO_COMPETITVO = '';

    try { TipoSceltaContraente = getObj('TipoSceltaContraente').value  }  catch( e) {}
    try { AQ_RILANCIO_COMPETITVO = getObjValue( 'AQ_RILANCIO_COMPETITVO') } catch( e ){};    
	
	
	//se NON ACCORDO QUANDRO e NON RILANCIO COMPETITIVO OPPURE E' ACCORDO QUANDRO AL PREZZO PIU' BASSO
	if ( ( TipoSceltaContraente != 'ACCORDOQUADRO' && AQ_RILANCIO_COMPETITVO != 'yes' ) ||  ( TipoSceltaContraente == 'ACCORDOQUADRO' && getObjValue('CriterioAggiudicazioneGara') == '15531' ) ) 
    {
        try {
            setVisibility(getObj('AQ_EREDITA_TEC'), 'none');
            ShowCol( 'CRITERI' , 'Eredita' , 'none' );
        } catch (e) {};
    }

    if( AQ_RILANCIO_COMPETITVO != 'yes' )
    {
        try {
            setVisibility(getObj('CRITERI_AQ_EREDITA_TEC'), 'none');
			$("#cap_PunteggioTecPercEredit").parents("table:first").css({"display": "none"});
        } catch (e) {};
    }
    else
    {
        ShowCol( 'CRITERI' , 'Eredita' , 'none' );
    }
	
}	

function OnChangeSedutaVirtuale() 
{
    var sceltaVirtuale = getObj('Scelta_Seduta_Virtuale');
    if (sceltaVirtuale != null)
    {
        if (sceltaVirtuale.value == 'si') 
	    {
            getObj('TipoSedutaGara').value = 'virtuale';
		    return;
        }
        if (sceltaVirtuale.value == 'no') 
	    {
            getObj('TipoSedutaGara').value = 'no';
		    return;
        }
        else 
	    {
            getObj('TipoSedutaGara').value = 'null';
		    return;
        }
    }

}


//--seleziono PREZZO - 15536
//--------------------------
//-- uno dei seguenti dati � calcolati ed ha bisogno della base asta
//--------------------------
var BaseAstaPrezzo  = [
' Sconto Corrente ',
' Massimo Sconto Offerto ',
' Sconto Offerto ',
' Sconto Migliore ',
' Sconto Peggiore ',
' Media Sconti Offerti ',
' Ribasso Corrente ',
' Massimo Ribasso Offerto ',
' Ribasso Offerto ',
' Ribasso Migliore ',
' Ribasso Peggiore ',
' Media Ribassi Offerti ',
' Valore Base Asta ',
' Percentuale Corrente ',
' Massima Percentuale Offerta ',
' Percentuale Offerta ',
' Percentuale Migliore ',
' Percentuale Peggiore ',
' Media Percentuali Offerte '
]


//--seleziono PERCENTUALE - 15537
//--------------------------
//-- uno dei seguenti dati � calcolati ed ha bisogno della base asta
//--------------------------
var BaseAstaPercentuale  =[
' Media Valori Offerti ' ,
' Massimo Valore Offerta ',
' Minimo Valore Offerta ',
' Offerta Migliore ',
' Offerta Corrente ',
' Valore Offerta ',
' Ribasso Corrente ',
' Massimo Ribasso Offerto ',
' Ribasso Offerto ',
' Ribasso Migliore ',
' Ribasso Peggiore ',
' Media Ribassi Offerti ',
' Valore Base Asta '
]

//-- se all'interno della formula trova una delle parole chiavi indicate significa che la formula ha bisogno della base asta per il calcolo
function BaseAstaNecessaria( strFormulaEco , CriterioFormulazioneOfferte )
{
    var vet ;

    if ( CriterioFormulazioneOfferte == '15536' )
    {
         vet = BaseAstaPrezzo;
    }
    else
    {
         vet = BaseAstaPercentuale;
    }

	var i = 0;
    var NumControlli = vet.length;
	for( i = 0 ; i < NumControlli ; i++ )
	{
		if ( strFormulaEco.indexOf( vet[i] ) >= 0 )
            return true;
    }
    return false;
}

function openGEO_simog()
{
	codApertura = 'M-1-11-ITA';
	
	var tmp = getObjValue('COD_LUOGO_ISTAT');
	
	if ( tmp !== '' )
	{
		codApertura = tmp;
	}
	
	//aggiunto il parametro cod_to_exclude per non visualizzare i codici che finiscono con XXX, quindi gli elementi 'altro' del dominio
	ExecFunction(  '../../Ctl_Library/gerarchici.asp?lo=content&portale=no&cod_to_exclude=%25XXX&fieldname=localita&path_filtra=GEO&caption=Dominio GEO&help=help_geo_ente&path_start=GEO&lvl_sel=,5,6,7,&lvl_max=7&sel_all=1&cod=' + codApertura + '&js=impostaLuogoIstat' , 'DOMINIO_GEO' , ',width=700,height=750' );
}


function impostaLuogoIstat(cod,fieldName)
{

	ajax = GetXMLHttpRequest(); 

	if(ajax)
	{
		ajax.open("GET", '../../ctl_library/functions/infoNodoGeo.asp?fldname=stato&cod=' + escape(cod), false);

		ajax.send(null);

		if(ajax.readyState == 4) 
		{
			//Se non ci sono stati errori di runtime
			if(ajax.status == 200)
			{
				if ( ajax.responseText != '' ) 
				{
					var res = ajax.responseText;
					
					//Se l'esito della chiamata � stato positivo
					if ( res.substring(0, 2) == '1#' ) 
					{
						try
						{
							var vet = res.split( '###' );
							
							var desc;

							desc = vet[1];

							getObj('DESC_LUOGO_ISTAT').value = desc;
							getObj('DESC_LUOGO_ISTAT_V').innerHTML = desc;
							getObj('COD_LUOGO_ISTAT').value = cod;

						}
						catch(e)
						{
							alert('Errore:' + e.message);
						}
					}
				}
			}

		}

	}
}



function REQUISITI_AFTER_COMMAND( param )
{
	
	var DOCUMENT_READONLY;
	try{DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;}catch(e){ DOCUMENT_READONLY = '1'};
	try
	{
		if (  DOCUMENT_READONLY == 0 )
		{
			var r = 0;
			var n = getObj('REQUISITIGrid').rows.length;
			while( r < n )
			{

				SetProperty(getObj('RREQUISITIGrid_' + r + '_ElencoCIG'), 'filter', 'SQL_WHERE= idHEader  = \'' + getObjValue('IDDOC') + '\' ');

				r++;
			}
		
		}
	}catch(e){}
}



function RIFERIMENTI_AFTER_COMMAND( param )
{
  FilterRiferimenti();
}

function FilterRiferimenti(){
	
	
	var filterUser = '';	
	var i;
	var numrighe=GetProperty( getObj('RIFERIMENTIGrid') , 'numrow');

	
	
	
	//filterUser = 'SQL_WHERE= idpfu in ( select idpfu from RiferimentiForBando where DOC_ID = \'BANDO_GARA\'  and  OWNER = <ID_USER> )';
	
	
	try
	{
		
		for( i = 0 ; i < numrighe+1 ; i++ )
		{
			

			try
			{
				//AGGIUNGO IL FILTRO QUANDO LA RIGA E' ReferenteTecnico per mostrare  gli utenti con il profilo di ReferenteTecnico di tutte le aziende
				if ( getObjValue( 'RRIFERIMENTIGrid_' + i + '_RuoloRiferimenti' ) == 'ReferenteTecnico' )
				{
					filterUser = 'SQL_WHERE= idpfu in ( select ID_FROM from USER_DOC_PROFILI_FROM_UTENTI where profilo =\'Referente_Tecnico\' )';
					FilterDom(  'RRIFERIMENTIGrid_' + i + '_IdPfu' , 'IdPfu' , getObjValue( 'val_RRIFERIMENTIGrid_' + i + '_IdPfu' ), filterUser , 'RIFERIMENTIGrid_' + i  , '')
				}
				/*
				else
				{				
					filterUser = 'SQL_WHERE= idpfu in ( select idpfu from RiferimentiForBando where DOC_ID = \'BANDO_GARA\'  and  OWNER = <ID_USER> )';
				}
				*/
				
			}
			catch(e)
			{
			}

		}
		
	}catch(e){};

}

/* INIZIO GESTIONE SIMOG */

function onChangeRichiestaSimog()
{
	var docRichiestaCig;
	var RichiestaCigSimog;
	
	if ( getObj('docRichiestaCig') )
	{
		docRichiestaCig = getObjValue('docRichiestaCig');
		RichiestaCigSimog = getObjValue('RichiestaCigSimog');
		
		/* SE E' PRESENTE UN DOCUMENTO DI RICHIESTA CIG E SI STA PASSANDO ALLA SCELTA DI NON AVERE L'INTEGRAZIONE CON IL SIMOG */
		if ( docRichiestaCig == '1' && RichiestaCigSimog == 'no' )
		{
			//Setto preventivamente il valore al suo precedente per evitare che se l'utente clicca sulla 'X' della finestra modale 
			//riesca a cambiare la scelta senza attivare il processo di onChange
			getObj('RichiestaCigSimog').value = 'si';
			
			
			//se alla gara associato un pregara allora visualizzo un messaggio diverso perch� verr� solo disassociata la ricehista cig dalla gara
			//e non verr� annullata la richiesta CIG al SIMOG
			
			var IdDocPreGara = getObjValue('IdDocPreGara');
			//alert(IdDocPreGara);
			var ml_text ;
			if ( IdDocPreGara == '')
				ml_text = 'Cambiando questa scelta verranno annullate tutte le richieste SIMOG effettuate sulla procedura. Proseguire ?';
			else
				ml_text = 'Cambiando questa scelta verra disassociata la richiesta cig dalla procedura. Proseguire ?';
			
			var page = 'ctl_library/MessageBoxWin.asp?MODALE=YES&ML=YES&MSG=' + encodeURIComponent( ml_text ) +'&CAPTION=Informazione&ICO=1';
			
			ExecFunctionModaleConfirm( page, null , 200 , 420 , null , 'confermaCambioRichiestaSimog' );
		}
		else
		{
			
			if ( RichiestaCigSimog == 'no' )
						
				ExecDocProcess('CAMBIA_RICHIESTA_SIMOG_NO,SIMOG');
				
			else
				ExecDocProcess('CAMBIA_RICHIESTA_SIMOG_SI,SIMOG');	
		}
	}
}

function confermaCambioRichiestaSimog()
{
	//Ripristino la scelta dell'utente
	getObj('RichiestaCigSimog').value = 'no';
	
	ExecDocProcess('CAMBIA_RICHIESTA_SIMOG_NO,SIMOG');
	
}

/* FINE GESTIONE SIMOG */

/* INIZIO GESTIONE TED */

function onChangeRichiestaTED()
{
	var RichiestaTED = getObjValue('RichiestaTED');
	var RichiestaCigSimog = getObjValue('RichiestaCigSimog');
	var docRichiestaTED;
	var PresenzaDGUE;
	docRichiestaTED = getObjValue('docRichiestaTED');
	PresenzaDGUE = getObjValue('PresenzaDGUE');
	
	//se sto impostando "Invio GUEE" a si ma "Richiesta CIG su SIMOG" = no oppure "DGUE Strutturato" = no
	//allora visualizzo un messaggio per confermare l'operazione
	if ( ( RichiestaCigSimog == 'no' || PresenzaDGUE == 'no' )  && RichiestaTED == 'si' )
	{
		
		//Setto preventivamente il valore al suo precedente per evitare che se l'utente clicca sulla 'X' della finestra modale 
		//riesca a cambiare la scelta senza attivare il processo di onChange
		getObj('RichiestaTED').value = 'no';
		
		//DMessageBox( '../' , 'La richiesta di \'Invio GUUE\' e\' possibile solo con \'Richiesta CIG su SIMOG\' a si' , 'Attenzione' , 1 , 400 , 300 );
		var ml_text = 'La richiesta di \'Invio GUUE\' e\' possibile solo con \'Richiesta CIG su SIMOG\' a si e con \'DGUE Strutturato\' a si';
		var page = 'ctl_library/MessageBoxWin.asp?MODALE=YES&ML=YES&MSG=' + encodeURIComponent( ml_text ) +'&CAPTION=Informazione&ICO=1';
			
		ExecFunctionModaleConfirm( page, null , 200 , 420 , null , 'confermaCambioRichiestaTED_SI' );
			
	}
	else
	{
		
		/* SE E' PRESENTE UN DOCUMENTO DI RICHIESTA INVIO DATI GUUE/TED E SI STA PASSANDO ALLA SCELTA DI NON AVERE L'INTEGRAZIONE CON IL GUUE */
		if ( docRichiestaTED == '1' && RichiestaTED == 'no' )
		{
			//Setto preventivamente il valore al suo precedente per evitare che se l'utente clicca sulla 'X' della finestra modale 
			//riesca a cambiare la scelta senza attivare il processo di onChange
			getObj('RichiestaTED').value = 'si';
			
			var ml_text = 'Cambiando questa scelta verranno annullate tutte le richieste GUUE effettuate sulla procedura. Proseguire ?';
			var page = 'ctl_library/MessageBoxWin.asp?MODALE=YES&ML=YES&MSG=' + encodeURIComponent( ml_text ) +'&CAPTION=Informazione&ICO=1';
			
			ExecFunctionModaleConfirm( page, null , 200 , 420 , null , 'confermaCambioRichiestaTED' );
		}
		else
		{
			if ( RichiestaTED == 'no' )
				ExecDocProcess('CAMBIA_RICHIESTA_TED_NO,TED');
			else
				ExecDocProcess('CAMBIA_RICHIESTA_TED_SI,TED');	
		}
		
	}
}

function confermaCambioRichiestaTED()
{
	//Ripristino la scelta dell'utente
	getObj('RichiestaTED').value = 'no';
	
	ExecDocProcess('CAMBIA_RICHIESTA_TED_NO,TED');
	
}

function confermaCambioRichiestaTED_SI()
{
	//Ripristino la scelta dell'utente
	getObj('RichiestaTED').value = 'si';
	
	ExecDocProcess('CAMBIA_RICHIESTA_TED_SI_EXT,TED');
	
}

/* FINE GESTIONE TED */

function onChangeUserRUP()
{
	
	var TipoProceduraCaratteristica = getObj('TipoProceduraCaratteristica').value 
	var EnteProponente=getObjValue('EnteProponente').split('#')[0];	
	var enteappaltante=getObjValue('Azienda');
	
	//vado ad aggiornare il campo DirezioneEspletante in funzione della struttura di appartenenza 
	//associata al rup espletante
	//sui campi gerarchici non � implemtnata la funziuone UpdateFieldVisual
	//UpdateFieldVisual(getObj('UserRUP'),'DIREZIONEESPLETANTE_FROM_RUP','STRUTTURAAPPARTENENZA_FROM_RUP','no','=','parent','filtro_StrutturaAppartenenza( \'DirezioneEspletante\' )');
	
	//faccio una chiamata ajax per aggiornare il campo DirezioneEpletante
	if ( getObj('UserRUP').value != '' )
	{
		var nocache = new Date().getTime();
				
		ajax = GetXMLHttpRequest();		

		ajax.open("GET",'../../ctl_library/functions/Get_StrutturaAppartenenza_User.asp?IdPfu=' + getObj('UserRUP').value  + '&nocache=' + nocache , false);
		ajax.send(null);
		
		if(ajax.readyState == 4) 
		{
			//alert(ajax.status); 
			if(ajax.status == 404 || ajax.status == 500)
			{
			  alert('Errore invocazione pagina');	
			  return;
			}
			//alert(ajax.responseText); 
			if ( ajax.responseText != '' ) 
			{
				
				var vet = ajax.responseText.split( '@@@' );
				
				getObj('DirezioneEspletante').value = vet[0];
				//getObj('DirezioneEspletante_edit').value = vet[1];
				//getObj('DirezioneEspletante_edit_new').value = vet[1];
				getObj('Cell_DirezioneEspletante').innerHTML = getObj('DirezioneEspletante').outerHTML ;
				
				if ( vet[1] != 'Seleziona')
					getObj('Cell_DirezioneEspletante').innerHTML = getObj('Cell_DirezioneEspletante').innerHTML + vet[1];
				
				
			}
		}	
	}
	else
	{
		getObj('DirezioneEspletante').value = '';
		//getObj('DirezioneEspletante_edit').value = 'Seleziona';
		//getObj('DirezioneEspletante_edit_new').value ='Seleziona';
		getObj('Cell_DirezioneEspletante').innerHTML = getObj('DirezioneEspletante').outerHTML ;
				
	}
	
	//aggiorno strutturaaziendale con lo stesso valore di direzioneespletante
	getObj('StrutturaAziendale').value = getObj('DirezioneEspletante').value ;
	
	if ( EnteProponente == enteappaltante ) //se coincidono valorizzo RupProponente con lo stesso valore Selezionando il rup espletante pu� cambiare il RUP proponente solo se vuoto, nel caso di pieno do un warning se diverso 
	{
			
		if ( getObj('RupProponente').value == '' && getObj('RupProponente').type == 'select-one'  )  //vuoto ed editable
		{
			//setto il rup proponente	
			SetDomValue( 'RupProponente' , getObj('UserRUP').value );
			
			//setto la struttura proponente in funzione del rup proponente
			//onChangeRUP_Prop();
			
			//chiamo un processo fittizio per salvare tutto
			ExecDocProcess('CAMBIO_RUP,DOCUMENT');
		}
		else
		{
			if ( getObj('RupProponente').value !=  getObj('UserRUP').value )
			{
				//se non sono nel caso di AFFIDAMENTO DIRETTO SEMPLIFICATO COME PRIMA
				if  ( TipoProceduraCaratteristica != 'AffidamentoSemplificato')
				{	
					ML_text = 'Si evidenzia che il riferimento selezionato come RUP non coincide con la selezione del RUP Proponente.';
					Title = 'Informazione';					
					ICO = 1;
					page = 'ctl_library/MessageBoxWin.asp?MODALE=YES&ML=YES&MSG=' + encodeURIComponent( ML_text ) +'&CAPTION=' + encodeURIComponent(Title) + '&ICO=' + encodeURIComponent(ICO);

					ExecFunctionModale( page, null , 200 , 420 , null  );
				}
				else
				{
					//riporto in RUPPROPONENTE RUP PER COERENZA
					getObj('RupProponente').value = getObj('UserRUP').value ;
					
				}
			}
		
		}
		
	}
	
	SetFilterIniziative_FromRup();
	
}

function onChangeCPV()
{
	var valCodiceCPV = getObjValue('CODICE_CPV');
	
	if ( valCodiceCPV != '' )
	{
	
		var ultimi6 = valCodiceCPV.substr(valCodiceCPV.length - 6);
		var ultimi5 = valCodiceCPV.substr(valCodiceCPV.length - 5);
		
		// Consentiamo la selezione solo dei livelli maggiori o uguale al 3
		if ( ultimi6 == '000000' || ultimi5 == '00000' ) 
		{
			
			//per i livelli inferiore al terzo consento la selezione solo dei nodi foglie
			//effettuo il controllo con chiamata ajax
			var nocache = new Date().getTime();
			
			ajax = GetXMLHttpRequest();		
	
			ajax.open("GET",'../../ctl_library/functions/FIELD/CK_FldHierarchy_ChildNode.asp?DOMAIN=CODICE_CPV&CODICE=' + valCodiceCPV + '&nocache=' + nocache , false);
			ajax.send(null);
			
			if(ajax.readyState == 4) 
			{
			    //alert(ajax.status); 
				if(ajax.status == 404 || ajax.status == 500)
				{
				  alert('Errore invocazione pagina');	
				  return;
				}
			    //alert(ajax.responseText); 
				if ( ajax.responseText != 'YES' ) 
				{
					getObj('CODICE_CPV').value = '';
					getObj('CODICE_CPV_edit_new').value = '';
				
					//DMessageBox( '../' , 'Selezione non valida. Selezionare un voce con un livello di profondita\' maggiore o uguale al terzo' , 'Attenzione' , 1 , 400 , 300 );
					DMessageBox( '../' , 'Selezione non valida. Selezionare un nodo con un livello maggiore o uguale al terzo oppure un nodo foglia di livello minore al terzo' , 'Attenzione' , 1 , 400 , 300 );
				}
			}	
		}
		
	} 

}


function CheckDataOrarioOK(FieldData, msgVuoto) 
{
    var ORE=0;
	try
	{
		var ORARIO = getObjValue(FieldData).split('T')[1];
		var ORE = ORARIO.split(':')[0];
	}catch(e){}
	
	if ( ORE > 0 ) 
	{
		return 0;
	}
	else
	{
        DocShowFolder('FLD_COPERTINA');
        tdoc();
        try {
            getObj(FieldData + '_V').focus();
        } catch (e) {};
        DMessageBox('../', msgVuoto, 'Attenzione', 1, 400, 300);
        return -1;
    }

    

    
}
function onChangeCheckFermoSistema(obj )
{
	
	
	
	//INVOCAZIONE SU ONCHANGE DEL CAMPO
	try
	{
		if ( obj.name != '' && obj.name != null )
		{
			
			var NameControlloData = obj.id;
			
			NameControlloData = NameControlloData.replace('_HH_V','_V');
			NameControlloData = NameControlloData.replace('_MM_V','_V');  
			var objFieldData = getObj(NameControlloData);
			//SOLO SE DATA E ORA E MIN SONO VALORIZZATI FACCIO IL CONTROLLO DEL FERMO SISTEMA ALTRIMENTI LO FARA' IL PROCESSO DI INVIO
			//SE LO AVREI FATTO SOLO CON LA DATA RISCHIAMO DI NON CONSENTIRE AGLI UTENTI DI METTERE UN ORARIO OLTRE IL FERMO SISTEMA
			NameControlloORA = NameControlloData.replace('_V','_HH_V');  	
			NameControlloMIN = NameControlloData.replace('_V','_MM_V');  				
			if (  getObj(NameControlloData).value != '' && getObj(NameControlloORA).value != '' && getObj(NameControlloMIN).value != '' )
			{
				//aggiunto 3 parametro a si per far gestire anche il messaggio di warnign
				Get_CheckFermoSistema ( '../../', objFieldData , 'si' );				
				
				
			}
			
		}
		
	}catch(e){}
}



function OnChangeModAttribPunteggio(obj)
{
	var ModAttribPunteggio = getObjValue('ModAttribPunteggio');
	
	//-- rettifico eventuali selezioni
	
	
	if ( ModAttribPunteggio ==  '' ) ModAttribPunteggio = 'coefficiente';
	if ( gModAttribPunteggio ==  '' ) gModAttribPunteggio = 'coefficiente';
	
	if ( gModAttribPunteggio ==  'giudizio' ) gModAttribPunteggio = 'coefficiente';
	
	//-- nel caso non sia necessaria una conversione esco
	if ( ModAttribPunteggio == gModAttribPunteggio)
	{
		return;
	}

	gModAttribPunteggio = ModAttribPunteggio;

	


	//-- verifico la presenza di criteri di valutazione tecnica oggettivi che siano per range o dominio, in tal caso rettifico ed informo l'utente
	if (GetProperty(getObj('CRITERIGrid'), 'numrow') != -1) 
	{
		
		
		var bFound = false;
		
		
		var numrighe = GetProperty(getObj('CRITERIGrid'), 'numrow');
		i = 0;
		var k = 0;
		
		for (i = 0; i <= numrighe; i++) 
		{
				
			if ( getObjValue('RCRITERIGrid_' + i + '_CriterioValutazione') == 'quiz' )
			{
				
				var Formula = getObjValue('RCRITERIGrid_' + i + '_Formula');
				var vet = Formula.split( '#=#' );

				if ( vet[1] == 'dominio' || vet[1] == 'range' )
				{
					bFound = true;
					var PunteggioMax = getObjValue('RCRITERIGrid_' + i + '_PunteggioMax');
					var vetG = vet[2].split( '#~#' );
					var l =  vetG.length  / 4;
					var V;
					var Newformula = vet[0] + '#=#' + vet[1] + '#=#';
					
					for( j = 0 ; j < l ; j++ )
					{
						if ( j > 0 )
							Newformula = Newformula + '#~#';
						
						V = Number(vetG[j*4+3])
						
						//-- trasformo il valore
						if ( ModAttribPunteggio == 'coefficiente' )
						{
							if ( PunteggioMax == 0 )
								vetG[j*4+3] = 0;
							else
								vetG[j*4+3] = V / PunteggioMax;
						}

						if ( ModAttribPunteggio == 'punteggio' ) 						
						{
							vetG[j*4+3] = V * PunteggioMax;
						}

						
						Newformula = Newformula + vetG[j*4+0] + '#~#' + vetG[j*4+1] + '#~#' + vetG[j*4+2] + '#~#' + vetG[j*4+3] ;

					}
					
					//-- ricompongo la formula
					getObj('RCRITERIGrid_' + i + '_Formula').value = Newformula;
				}
	
			}
		}
		
		if ( bFound == true )
		{
            DMessageBox('../', 'Il cambio di \"Modalita Attribuzione Punteggio\" comporta una modifica ai criteri di valutazione tecnica oggettivi. la modifica dei punteggi inseriti � stata eseguita in automatico, si prega di verificare che il contenuto sia corretto.', 'Attenzione', 1, 400, 300);
		}
		
	}
	
}



function CheckCriteriPunteggi()
{
	var ModAttribPunteggio = getObjValue('ModAttribPunteggio');
	if( ModAttribPunteggio == '' ) ModAttribPunteggio = 'coefficiente';

	//-- verifico la presenza di criteri di valutazione tecnica oggettivi che siano per range o dominio con punteggi non corretti
	if (GetProperty(getObj('CRITERIGrid'), 'numrow') != -1) 
	{
		
		
		var numrighe = GetProperty(getObj('CRITERIGrid'), 'numrow');
		i = 0;
		var k = 0;
		
		for (i = 0; i <= numrighe; i++) 
		{
				
			if ( getObjValue('RCRITERIGrid_' + i + '_CriterioValutazione') == 'quiz' )
			{
				
				var Formula = getObjValue('RCRITERIGrid_' + i + '_Formula');
				var vet = Formula.split( '#=#' );

				if ( vet[1] == 'dominio' || vet[1] == 'range' )
				{
					bFound = true;
					var PunteggioMax = getObjValue('RCRITERIGrid_' + i + '_PunteggioMax');
					var vetG = vet[2].split( '#~#' );
					var l =  vetG.length  / 4;
					
					for( j = 0 ; j < l ; j++ )
					{
						
						
						if ( ModAttribPunteggio == 'coefficiente' )
						{
							if ( Number( vetG[j*4+3] )  > 1 )
								return -1
						}

						if ( ModAttribPunteggio == 'punteggio' ) 						
						{
							if ( PunteggioMax < Number( vetG[j*4+3] ) )
								return -1
						}

						

					}
					
				}
	
			}
		}
		
		
	}
	return 0;
	
}

function OnChangeCriterioFormulazioneOfferteTestata( obj ) 
{
	
	// cambio il filtro sui modelli selezionabili se il valore precedente � mantenuto vuol dire che il modello � ancora buono per essere utilizzato
	// altrimenti svuoto i dati relativi al modello
	
	var OldV = getObjValue('RTESTATA_PRODOTTI_MODEL_TipoBandoScelta');
	
	FiltraModelli();
	
	if( getObjValue('RTESTATA_PRODOTTI_MODEL_TipoBandoScelta') != OldV )
	{
	    alert(CNV('../', 'La selezione effettuata comporta l\'eliminazione del modello adottato e di tutte le informazioni ad esso collegate perche\' incorente con il valore scelto'));
		ExecDocProcess('SVUOTA_SOLO_MODELLO_PRODOTTI,BANDO_GARA');
	}
		
	
}

function OnchangeGestioneQuote()
{
	ExecDocProcess('GESTIONE_QUOTE,DOCUMENT,,NO_MSG');
}



//-- determino se visualizzare il campo InversioneBuste
function ShowInversioneBuste()
{



	try
	{
		//- di base nascondo il controllo
		//getObj('cap_InversioneBuste').style.display = 'none';
		//getObj('InversioneBuste').style.display = 'none';					
		try{$("#cap_InversioneBuste").parents("table:first").css({"display": "none"});}catch(e){}
		
		//-- recupera le regole
		var InversioneBusteRegole = JSON.parse( getObjValue( 'InversioneBusteRegole' ) );
		
		//-- di base � nascosto ci deve essere almeno una regola anche vuota per attivarlo
		var bShow = false;
		
		//-- cicla sulle regole
		var nR = InversioneBusteRegole.SHOW.length;
		for ( r = 0 ; r <  nR ;  r++ )
		{
			bShow = true;

			var nA = InversioneBusteRegole.SHOW[r].Attributi.length;
			for( a = 0 ; a < nA ; a++ )
			{
				var nV = InversioneBusteRegole.SHOW[r].Valori[a].length;
				bFound = false;
				for( v = 0 ; v < nV && bFound == false ; v++ )
				{
					if ( getObjValue( InversioneBusteRegole.SHOW[r].Attributi[a] ) == InversioneBusteRegole.SHOW[r].Valori[a][v] )
						bFound = true;
				}
				
				//-- se su un attributo non trovo almeno un valore valido allora la regola � fallita
				if ( bFound == false )
					bShow = false;
			}
			
		}
		
		//-- se almeno una regola risulta vera allora visualizziamo il campo InversioneBuste 
		if ( bShow == true )
		{
			//getObj('cap_InversioneBuste').style.display = '';
			//getObj('InversioneBuste').style.display = '';		
			try{$("#cap_InversioneBuste").parents("table:first").css({"display": ""});}catch(e){}
		}
		
		if (getObjValue('DOCUMENT_READONLY') != "1" ) 
		{
		
			//-- se RichiestaCampionatura non � ammessa l'inversione delle buste
			if ( getObjValue( 'RichiestaCampionatura' ) == '1' )
			{
				setObjValue( 'InversioneBuste' , '0' );
				SelectreadOnly('InversioneBuste',true);
			}
			else
			{
				SelectreadOnly('InversioneBuste',false);
			}
		}
		
	}catch( e ) {}
		
	
}

function PRODOTTI_AFTER_COMMAND( param )
{
		//alert(param);
		var numrighe = GetProperty(getObj('PRODOTTIGrid'), 'numrow');
		//alert(numrighe);
		if ( getObj('RPRODOTTIGrid_' + numrighe + '_CODICE_REGIONALE').value != '' && param == 'ADDFROM')
			ExecDocProcess('CONTROLLO_PRODOTTI,BANDO_GARA');
		
}



function onChangeAccordoServizio()
{
	try
	{
		
		if ( getObj( 'Accordo_di_Servizio' ).value == 'si' )
		{
			getObj( 'GeneraConvenzione' ) .value = '0';
			onChangeGeneraConvenzione( 1 );
		}
	
	}catch(e){};
	
}


function onchangeAppaltoInEmergenza() {
    try {
        if (getObjValue('AppaltoInEmergenza') != 'si') {
            getObj('MotivazioneDiEmergenza').value = '';
            //getObj('MotivazioneDiEmergenza').disabled = true;
			ReadOnlyObj('MotivazioneDiEmergenza' , true) ;

        }
    } catch (e) {}
    try {
        if (getObjValue('AppaltoInEmergenza') == 'si') {

            //getObj('MotivazioneDiEmergenza').disabled = false;
			ReadOnlyObj('MotivazioneDiEmergenza' , false) ;

        }
    } catch (e) {}

}

function conferma_warning_emergenza(param)
{
	
	//flag_warning_emergenza=1;
	
	SetDomValue('AppaltoInEmergenza' , 'si' , 'si');
	SetTextValue('MotivazioneDiEmergenza', 'Appalto di Emergenza');
	$( "#finestra_modale_confirm" ).dialog( "close" );
	PrintAndSend(param,'wrng_data@@@no');
}

function cancel_warning_emergenza()
{
	SetDomValue('AppaltoInEmergenza' , 'no' , 'no');
	SetTextValue('MotivazioneDiEmergenza', '');
    
	return-1;
}


function GetDatiAIC()
{
	ExecDocProcess('SAVE_DOC,AIC,,NO_MSG');
}


function ElabAIC()
{
	// IdOfferta
	var IDDOC = getObjValue('IDDOC');
	
	
	
	if ( isSingleWin() )
	{
		var url;
		
		url = encodeURIComponent( 'CustomDoc/AIC_LOAD.asp?IDDOC=' + IDDOC + '&TYPEDOC=BANDO_GARA&lo=base' );
		NewWin = ExecFunctionSelf(pathRoot + 'ctl_library/path.asp?url=' + url + '&KEY=document'   ,  '' , '');
		
	}
	else
	{
		ExecFunctionCenter('../../CustomDoc/AIC_LOAD.asp?IDDOC=' + IDDOC + '&TYPEDOC=BANDO_GARA' );
	}  
	
	
	
	//alert(IDDOC);
}

function onChangeDivisione_lotti()
{
	
	var TipoBando = getObjValue('TipoBando');
	
	if ( getObj('id_modello') )
	{
		
		var cod = getObjValue('id_modello');
		
		setRegExpCIG();
		
		set_Complex();
		
		
		//SE PRESENTE LA RICHIESTA SIMOG NON CONSENTO
		var docRichiestaCig = getObjValue('docRichiestaCig');
		
		if ( docRichiestaCig == '1')
		{
			ML_text = 'Operazione non consentita sulla procedura presente una richiesta CIG';
			Title = 'Informazione';					
			ICO = 1;
			page = 'ctl_library/MessageBoxWin.asp?MODALE=YES&ML=YES&MSG=' + encodeURIComponent( ML_text ) +'&CAPTION=' + encodeURIComponent(Title) + '&ICO=' + encodeURIComponent(ICO);

			ExecFunctionModale( page, null , 200 , 420 , null  );
			return -1;
		}
		//SE NON PRESENTE LA RICHIESTA SIMOG SVUOTO NUMERO GARA
		else
		{
			if ( getObj('RichiestaCigSimog').value == 'no' )
			{
				SetTextValue('CIG', '');
				
			}
		}
		//TEST SE E' STATO SCELTO IL MODELLO 	
		if ( ( TipoBando != '' || cod != '' ) && cod != 0) 
		{
			 ML_text = 'La selezione effettuata comporta l\'eliminazione del modello adottato e di tutte le informazioni ad esso collegate perche\' incorente con il valore scelto. Sei sicuro?';
			 Title = 'Informazione';					
			 ICO = 3;
			 page = 'ctl_library/MessageBoxWin.asp?MODALE=YES&ML=YES&MSG=' + encodeURIComponent( ML_text ) +'&CAPTION=' + encodeURIComponent(Title) + '&ICO=' + encodeURIComponent(ICO);
					
			ExecFunctionModaleConfirm( page, Title , 200 , 400 , null , 'conferma_flush_prodotti','cancel_flush_prodotti');
			return -1;
		}
		else
		{
			ExecDocProcess('RELOAD_STRUTTURA,BANDO_GARA,,NO_MSG');
		}
		
		oldDivisione_lotti = getObjValue('Divisione_lotti');
	}
	else
	{
		ExecDocProcess('RELOAD_STRUTTURA,BANDO_GARA,,NO_MSG');
	}
	
}

function conferma_flush_prodotti()
{
	//ExecDocProcess('RELOAD_STRUTTURA,BANDO_GARA,,NO_MSG');
	ExecDocProcess('FLUSH_PRODOTTI,BANDO_GARA,,NO_MSG');
}
function cancel_flush_prodotti()
{
	Divisione_lotti=getObjValue('Divisione_lotti');
	
	getObj( 'Divisione_lotti' ).value=oldDivisione_lotti;
	oldDivisione_lotti = getObj( 'Divisione_lotti' ).value;
	set_Complex();
	return -1;
}

function cancel_flush_prodotti_complex()
{
	var Complex = getObjValue( 'Complex' );
	
	if( Complex == '1')  //1=si 0=no
	{
		SetDomValue( 'Complex' , '0' );
	}
	else
	{
		SetDomValue( 'Complex' , '1' );
	}
		
	return -1;
}
function cancel_flush_prodotti_CriterioAggiudicazioneGara()
{
	
	CriterioAggiudicazioneGara=getObjValue('CriterioAggiudicazioneGara');	
	getObj( 'CriterioAggiudicazioneGara' ).value=oldCriterioAggiudicazioneGara;
	oldCriterioAggiudicazioneGara = getObj( 'CriterioAggiudicazioneGara' ).value;
	
	return -1;
	
	
}
function set_Complex()
{
	//se divisioneLotti non � multivoce <> 1 il campo impostato a no not editable
	Divisione_lotti=getObjValue('Divisione_lotti');
	if ( Divisione_lotti != '1' )
	{
		SetDomValue( 'Complex' , '0' );
		SelectreadOnly('Complex',true);
	}
	else
	{
		SelectreadOnly('Complex',false);
	}
}

function OnChangeComplex()
{
	var TipoBando = getObjValue('TipoBando');
    var cod = getObjValue('id_modello');
	
	//TEST SE E' STATO SCELTO IL MODELLO 	
	if ( ( TipoBando != '' || cod != '' ) && cod != 0) 
	{
		 ML_text = 'La selezione effettuata comporta l\'eliminazione del modello adottato e di tutte le informazioni ad esso collegate perche\' incorente con il valore scelto. Sei sicuro?';
		 Title = 'Informazione';					
		 ICO = 3;
		 page = 'ctl_library/MessageBoxWin.asp?MODALE=YES&ML=YES&MSG=' + encodeURIComponent( ML_text ) +'&CAPTION=' + encodeURIComponent(Title) + '&ICO=' + encodeURIComponent(ICO);
				
		ExecFunctionModaleConfirm( page, Title , 200 , 400 , null , 'conferma_flush_prodotti','cancel_flush_prodotti_complex');
		return -1;
	}
	else
	{
		ExecDocProcess('RELOAD_STRUTTURA,BANDO_GARA,,NO_MSG');
	}
}

function OnChangeCriterioAggiudicazioneGara()
{
	var TipoBando = getObjValue('TipoBando');
    var cod = getObjValue('id_modello');
	
	if( ( getObjValue( 'CriterioAggiudicazioneGara' ) == '15532' ) || ( getObjValue( 'CriterioAggiudicazioneGara' ) == '25532' ) ) //-- vantaggiosa or costo fisso
			FilterDom( 'Conformita' ,  'Conformita' , 'No' , 'SQL_WHERE=  DMV_COD = \'No\' ' , '' , 'OnchangeConformita(this);'); //-- solo no
	else
		FilterDom( 'Conformita' ,  'Conformita' , getObjValue( 'Conformita' ) , '' , '' , 'OnchangeConformita(this);'); //-- tutto	
	
	//TEST SE E' STATO SCELTO IL MODELLO 	
	if ( ( TipoBando != '' || cod != '' ) && cod != 0) 
	{
		 ML_text = 'La selezione effettuata comporta l\'eliminazione del modello adottato e di tutte le informazioni ad esso collegate perche\' incorente con il valore scelto. Sei sicuro?';
		 Title = 'Informazione';					
		 ICO = 3;
		 page = 'ctl_library/MessageBoxWin.asp?MODALE=YES&ML=YES&MSG=' + encodeURIComponent( ML_text ) +'&CAPTION=' + encodeURIComponent(Title) + '&ICO=' + encodeURIComponent(ICO);
				
		ExecFunctionModaleConfirm( page, Title , 200 , 400 , null , 'conferma_flush_prodotti','cancel_flush_prodotti_CriterioAggiudicazioneGara');
		return -1;
	}
	else
	{
		ExecDocProcess('RELOAD_STRUTTURA,BANDO_GARA,,NO_MSG');
	}

}

function set_Criteri()
{
	// N.B. Verificato con enrico che nel caso del bando concorso per adesso questi controlli non servono
	
	// if  ( getObj('TipoProceduraCaratteristica').value != 'AffidamentoSemplificato')
	// {
		// if(  getObjValue( 'ProceduraGara' ) == '15476' || getObjValue( 'ProceduraGara' ) == '15477' || getObjValue( 'ProceduraGara' ) == '' ) //-- Aperta o Ristretta
		// {
			// if( getObjValue( 'Concessione' ) == 'si' )
				// FilterDom( 'CriterioAggiudicazioneGara' ,  'CriterioAggiudicazioneGara' , getObjValue( 'CriterioAggiudicazioneGara') , 'SQL_WHERE=DMV_COD <> \'\' ' , '' , 'OnChangeCriterioAggiudicazioneGara(this);'); //-- RIMUOVE il filtro
			// else
				// FilterDom( 'CriterioAggiudicazioneGara' ,  'CriterioAggiudicazioneGara' , getObjValue( 'CriterioAggiudicazioneGara') , 'SQL_WHERE=DMV_COD <> \'16291\' ' , '' , 'OnChangeCriterioAggiudicazioneGara(this);'); //-- filtro il prezzo pi� alto
		// }
		
		// else if ( getObjValue( 'ProceduraGara' ) == '15583' || getObjValue( 'ProceduraGara' ) == '15479' )//-- Affidamento Diretto  o Richiesta Preventivo
		// {
			// FilterDom( 'CriterioAggiudicazioneGara' ,  'CriterioAggiudicazioneGara' , '15531' , 'SQL_WHERE=DMV_COD = \'15531\' ' , '' , 'OnChangeCriterioAggiudicazioneGara(this);'); //-- SOLO Prezzo pi� basso
			// SelectreadOnly( 'CriterioAggiudicazioneGara' , true );

			// try{
				// FilterDom( 'Conformita' ,  'Conformita' , 'No' , 'SQL_WHERE=  DMV_COD = \'No\' ' , '' , 'OnchangeConformita(this);'); //-- solo no
				// SelectreadOnly( 'Conformita' , true );
			   // } catch(e){}	

			// FilterDom( 'Divisione_lotti' ,  'Divisione_lotti' , getObjValue( 'Divisione_lotti' ) , 'SQL_WHERE=  DMV_COD <> \'1\' ' , '' , 'onChangeDivisione_lotti( this );'); //--FILTRO   MULTIVOCE
		// }
		// else
		// {
			
			// FilterDom( 'CriterioAggiudicazioneGara' ,  'CriterioAggiudicazioneGara' , getObjValue( 'CriterioAggiudicazioneGara') , 'SQL_WHERE=DMV_COD <> \'16291\' ' , '' , 'OnChangeCriterioAggiudicazioneGara(this);'); //-- filtro il prezzo pi� alto		
			   
		 // }
		 
		// if( ( getObjValue( 'CriterioAggiudicazioneGara' ) == '15532' ) || ( getObjValue( 'CriterioAggiudicazioneGara' ) == '25532' ) ) //-- vantaggiosa or costo fisso
		// {
			// try{
				// FilterDom( 'Conformita' ,  'Conformita' , 'No' , 'SQL_WHERE=  DMV_COD = \'No\' ' , '' , 'OnchangeConformita(this);'); //-- solo no
				// SelectreadOnly( 'Conformita' , true );
			// } catch(e){}	
		// }
		// else
		// {
			// try{
				// FilterDom( 'Conformita' ,  'Conformita' , getObjValue( 'Conformita' ) , '' , '' , 'OnchangeConformita(this);'); //-- tutto	
				// SelectreadOnly( 'Conformita' , false );
				// } catch(e){}	
		// }
	// }

}

function OnchangeConformita()
{
	var TipoBando = getObjValue('TipoBando');
    var cod = getObjValue('id_modello');
	
	
	//TEST SE E' STATO SCELTO IL MODELLO 	
	if ( ( TipoBando != '' || cod != '' ) && cod != 0) 
	{
		 ML_text = 'La selezione effettuata comporta l\'eliminazione del modello adottato e di tutte le informazioni ad esso collegate perche\' incorente con il valore scelto. Sei sicuro?';
		 Title = 'Informazione';					
		 ICO = 3;
		 page = 'ctl_library/MessageBoxWin.asp?MODALE=YES&ML=YES&MSG=' + encodeURIComponent( ML_text ) +'&CAPTION=' + encodeURIComponent(Title) + '&ICO=' + encodeURIComponent(ICO);
				
		ExecFunctionModaleConfirm( page, Title , 200 , 400 , null , 'conferma_flush_prodotti','cancel_flush_prodotti_conformita');
		return -1;
	}
	else
	{
		ExecDocProcess('RELOAD_STRUTTURA,BANDO_GARA,,NO_MSG');
	}
}

function cancel_flush_prodotti_conformita()
{
	
	Conformita=getObjValue('Conformita');	
	getObj( 'Conformita' ).value=oldConformita;
	oldConformita = getObj( 'Conformita' ).value;
	
	return -1;
	
	
}

function GeneraModelloBustaECO(loaderUrl, modalTitle)
{
	
	//Se monolotto
	if (getObjValue('Divisione_lotti') == '0') 
	{
		
				
		try
		{
			
			if (GetProperty(getObj('PRODOTTIGrid'), 'numrow') == -1  || getObjValue('RTESTATA_PRODOTTI_MODEL_EsitoRiga') != '' ) 
			{

                DocShowFolder('FLD_PRODOTTI');
                tdoc();
                DMessageBox('../', 'Compilare correttamente la sezione dei prodotti', 'Attenzione', 1, 400, 300);
                return;
            }
			
		}
		catch(e){}		
		
	}
	else
	{
		
		try
		{
			
			if (GetProperty(getObj('PRODOTTIGrid'), 'numrow') == -1) {

                DocShowFolder('FLD_PRODOTTI');
                tdoc();
                DMessageBox('../', 'Compilare correttamente la sezione dei lotti', 'Attenzione', 1, 400, 300);
                return;
            }
			
			if ( getObjValue('RTESTATA_PRODOTTI_MODEL_EsitoRiga') != '' )
			{
				DocShowFolder('FLD_PRODOTTI');
                tdoc()
				DMessageBox('../', 'Sono presenti delle anomalie sui lotti', 'Attenzione', 1, 400, 300);
				return;
			}
			
		}
		catch(e){}		

	}
	
	AF_Loader(loaderUrl, modalTitle);	
	
}

//verifico che i campi di controllo siano valorizzati prima di invocare la stored 
function richiedi_documento_smart_cig()
{	
	if( getObjValue( 'Body' ) != '' ) 
	{
		if ( getObjValue( 'UserRUP' ) != '' ) 
		{
			ExecDocProcess('FITTIZIO3,DOCUMENT,,NO_MSG');
		
		}	
		else
		{
			DMessageBox('../', 'Per effettuare la richiesta dei CIG Occorre aver indicato il RUP', 'Attenzione', 1, 400, 300);
		}
	}
	else
	{
		DMessageBox('../', 'Per effettuare la richiesta dei CIG Occorre aver inserito l\'oggetto della gara', 'Attenzione', 1, 400, 300);
	}

}

//verifico che i campi di controllo siano valorizzati prima di invocare la stored 
function richiedi_documento_cig()
{	
	//var tpc = getObjValue('TipoProceduraCaratteristica');
	
	//if ( TPC = 'AffidamentoSemplificato' )
	//{
		if ( getObjValue( 'UserRUP' ) != '' ) 
		{
			if ( getObjValue( 'importoBaseAsta' ) != '' )  
			{
				if ( validaDatiSimogPNRR() )
						ExecDocProcess('FITTIZIO5,DOCUMENT,,NO_MSG');			
			}
			else
			{
				DMessageBox('../', 'Per effettuare la richiesta dei CIG Occorre aver indicato l\'Importo del Concorso', 'Attenzione', 1, 400, 300);
			}
		}
		else 
		{
			DMessageBox('../', 'Per effettuare la richiesta dei CIG Occorre aver indicato il RUP', 'Attenzione', 1, 400, 300);
		}
	/*}
	else
	{
		if( getObjValue( 'COD_LUOGO_ISTAT' ) != '' ) 
		{
			if ( getObjValue( 'CODICE_CPV' ) != '' ) 
			{
				
				if ( getObjValue( 'UserRUP' ) != '' ) 
				{
					if ( getObjValue( 'importoBaseAsta' ) != '' )  
					{
						if ( validaDatiSimogPNRR() )
							ExecDocProcess('FITTIZIO4,DOCUMENT,,NO_MSG');			
					}
					else
					{
						DMessageBox('../', 'Per effettuare la richiesta dei CIG Occorre aver indicato l\'Importo Appalto', 'Attenzione', 1, 400, 300);
					}
				}
				else 
				{
					DMessageBox('../', 'Per effettuare la richiesta dei CIG Occorre aver indicato il RUP', 'Attenzione', 1, 400, 300);
				}
			}	
			else
			{
				DMessageBox('../', 'Per effettuare la richiesta dei CIG Occorre aver indicato il Codice identificativo corrispondente al sistema di codifica CPV nella scheda "Informazioni Tecniche"', 'Attenzione', 1, 400, 300);
			}
		}
		else
		{
			DMessageBox('../', 'Per effettuare la richiesta dei CIG Occorre aver indicato il Luogo ISTAT nella scheda "Informazioni Tecniche"', 'Attenzione', 1, 400, 300);
		}
	}
	*/
  
}


function onChangeMerceologia( obj )
{

    //Se il documento � editabile
    if (getObj('DOCUMENT_READONLY').value == '0') 
	{

		try
		{
			//- se il campo � visualizzato filtriamo il contenuto in funzione della merceologia
			if ( getObj( 'cap_CATEGORIE_MERC' ) !== null )
			{
				var filter = 'SQL_WHERE=  DMV_Father like \'' + getObjValue( 'Merceologia' ) + '-%\' ';
				
                FilterDom('CATEGORIE_MERC', 'CATEGORIE_MERC', getObjValue('CATEGORIE_MERC'), filter, '', '');
			}
			
			
		}catch(e)
		{}	
	}
	
	
}




function OnChangeNumeroGara ( obj )
{
	
	//se sono sul primogiro esco e non faccio nulla
	if ( ( getObjValue('ProceduraGara') == '15478' && getObjValue('TipoBandoGara') == '1' ) 
			|| 
		 ( getObjValue('ProceduraGara') == '15477' && getObjValue('TipoBandoGara') == '2' ) 
	   )
		
		return;
	
	ExecDocProcess('ONCHANGE_NUMERO_GARA,BANDO_GARA,,NO_MSG');
}


function ClickDown( grid , r , c )
{
	
	MoveAllAtti(  r , 1 )
	
	
}

function ClickUp( grid , r , c )
{
	MoveAllAtti(  r , -1 )
	
}

//funzione che sposta tutti campi della griglia
function MoveAllAtti(  r , verso )
{

	move_Descrizione_Atti( 'Descrizione' , r  , verso );
	
	Move_Abstract( 'DOCUMENTAZIONEGrid', 'AnagDoc' , r  , verso );
	Move_Abstract( 'DOCUMENTAZIONEGrid', 'NotEditable' , r  , verso );
	
	move_Allegati_Atti( 'Allegato' , r  , verso );
	move_Allegati_Atti( 'TemplateAllegato' , r  , verso );

}


//inverte il campo descrizione di due righe
//contemplando anche i casi in cui su una riga il campo � editabile e su un'altra no
function move_Descrizione_Atti( field , row , verso ) 
{

	try
    {
        var f1 = getObj( 'RDOCUMENTAZIONEGrid_' + row + '_' + field );
        var f2 = getObj( 'RDOCUMENTAZIONEGrid_' + ( row + verso ) + '_' + field ) ;
        var app;
		
		var f1_edit =0 ;
		var f2_edit =0 ;
		
		
		
		f1_V = getObj( 'RDOCUMENTAZIONEGrid_' + row + '_' + field + '_V');
			
		if ( f1_V == null ){
			
			f1_edit = 1 ; 
		}
		
		f2_V = getObj( 'RDOCUMENTAZIONEGrid_' + ( row + verso ) + '_' + field + '_V') ;
		
		
		if ( f2_V == null ){
			
			f2_edit = 1 ;
		}
		
		//alert(f1_edit + '---' + f2_edit);
		//sorgente non editabile e destinazione editabile
		if ( f1_edit != f2_edit )
		{
			if ( f1_edit == 0)
			{	
				
				
				//la destinazione diventa non editabile con il valore di f1
				f2.parentNode.innerHTML = Descrizione_NotEditable ( ( row + verso )  , f1.value );
				
				
				//la sorgente diventa editabile con il valore di f2
				f1.parentNode.innerHTML =  Descrizione_Editable (    row  , f2.value );
				
			}
			else
			{	
				
				
				//la destinazione diventa  editabile con il valore di f1
				f2.parentNode.innerHTML = Descrizione_Editable ( ( row + verso )  , f1.value );
				
				
				//la sorgente diventa non editabile con il valore di f2
				f1.parentNode.innerHTML =  Descrizione_NotEditable (    row  , f2.value );
				
			}
			
		}
		else
		{
			//inverte i valori dei campi (visuali/nascosti) se entrambi editabili oppure no
			app = f1.value;
			f1.value = f2.value;
			f2.value = app;
			
			f1 = getObj( 'RDOCUMENTAZIONEGrid_' + row + '_' + field + '_V');
			f2 = getObj( 'RDOCUMENTAZIONEGrid_' + ( row + verso ) + '_' + field + '_V') ;


			app = f1.value;
			
			f1.value = f2.value;
			f2.value = app
			
			if ( app == undefined )
			{
				try{
					app = f1.innerHTML;
					
					f1.innerHTML = f2.innerHTML;
					f2.innerHTML = app;
					
				}catch(e){}
			}
		}
		
	}
	catch(e)
	{
	}
}



function Descrizione_NotEditable ( rowRiga , strValue )
{
	var StrHtml =''
	StrHtml = '<span class="Text" id="RDOCUMENTAZIONEGrid_' + rowRiga + '_Descrizione_V">' +  strValue + '</span>';
	StrHtml = StrHtml  + '<input type="hidden" name="RDOCUMENTAZIONEGrid_' +  rowRiga  + '_Descrizione" id="RDOCUMENTAZIONEGrid_' +  rowRiga  + '_Descrizione" value="' + strValue + '">';
	return StrHtml;
}	

function Descrizione_Editable ( rowRiga , strValue )
{
	var StrHtml =''
	StrHtml = '<input type="text" name="RDOCUMENTAZIONEGrid_' +  rowRiga  + '_Descrizione" id="RDOCUMENTAZIONEGrid_' +  rowRiga  + '_Descrizione" class="Text" maxlength="250" size="50" value="' + strValue + '">';
	return StrHtml;
}	

	

function move_Allegati_Atti( field , row , verso ) 
{
	//parte tecnica
	var f1 = getObj( 'RDOCUMENTAZIONEGrid_' + row + '_' + field );
	var f2 = getObj( 'RDOCUMENTAZIONEGrid_' + ( row + verso ) + '_' + field ) ;
	var app;
	var f1_empty = 0;
	var f2_empty = 0;
	app = f1.value;

	f1.value = f2.value;
	f2.value = app;
	
	//per gestire la parte visuale allegato
	try{
		//DIV_RDOCUMENTAZIONEGrid_0_Allegato_Multivalore se contiene un valore 
		//DIV_RDOCUMENTAZIONEGrid_1_Allegato_ATTACH_EMPTY se vuoto
		f1 = getObj( 'DIV_RDOCUMENTAZIONEGrid_' + row + '_' + field + '_Multivalore');
		//se non presente allora vuol dire che � vuoto
		if ( f1 == undefined )
		{
			
			f1 = getObj( 'DIV_RDOCUMENTAZIONEGrid_' + row + '_' + field + '_ATTACH_EMPTY');
			f1_empty = 1 ;
		}
		
		f2 = getObj( 'DIV_RDOCUMENTAZIONEGrid_' + ( row + verso ) + '_' + field + '_Multivalore') ;
		//se non presente allora vuol dire che � vuoto
		if ( f2 == undefined )
		{
			f2 = getObj( 'DIV_RDOCUMENTAZIONEGrid_' + ( row + verso ) + '_' + field + '_ATTACH_EMPTY');
			f2_empty = 1
		}
		
		app = f1.innerHTML;
		//alert(app);
		f1.innerHTML = f2.innerHTML;
		f2.innerHTML = app
		
		//inverto le classi di stile se uno dei 2 era vuoto
		if ( f1_empty != f2_empty )
		{
			//recupero classe di f1
			//recupero classe di f2
			strClassf1 = GetProperty(f1, 'class') ;
			strClassf2 = GetProperty(f2, 'class') ;
			SetProperty(f1, 'class', strClassf2) ;
			SetProperty(f2, 'class', strClassf1) ;
		}
		
		
		//inverto le div del bottone per selezionare l'allegato
		//DIV_RDOCUMENTAZIONEGrid_1_Allegato_BTN
		f1 = getObj( 'DIV_RDOCUMENTAZIONEGrid_' + row + '_' + field + '_BTN');
		f2 = getObj( 'DIV_RDOCUMENTAZIONEGrid_' + ( row + verso ) + '_' + field + '_BTN') ;
			
		app = f1.innerHTML;
		//alert(app);
			
		f1.innerHTML = f2.innerHTML;
		f2.innerHTML = app;
		
		//cambio il nome del campo per associarlo alla riga giusta
		f1.innerHTML = ReplaceExtended ( f1.innerHTML,  'RDOCUMENTAZIONEGrid_' + ( row + verso ) + '_' + field , 'RDOCUMENTAZIONEGrid_' + row + '_' + field  ) ;
		f2.innerHTML = ReplaceExtended ( f2.innerHTML,  'RDOCUMENTAZIONEGrid_' +  row  + '_' + field , 'RDOCUMENTAZIONEGrid_' + ( row + verso ) + '_' + field  ) ;
	}catch(e){}
}


function DOCUMENTAZIONE_AFTER_COMMAND( param )
{
	//attivo DRAG&DROP sulla griglia Atti
	ActiveGridDrag (  'DOCUMENTAZIONEGrid' , MoveAllAtti );
	
	//fInitDrag_Drop ( 'DOCUMENTAZIONEGrid' );
}


function ClickDownDoc( grid , r , c )
{
	
	MoveAllDoc(  r , 1 )
	
	
}

function ClickUpDoc( grid , r , c )
{
	MoveAllDoc(  r , -1 )
	
}


//funzione che sposta tutti campi della griglia
function MoveAllDoc(  r , verso )
{

	
	
	Move_Abstract( 'DOCUMENTAZIONE_RICHIESTAGrid', 'LineaDocumentazione' , r  , verso );
	Move_Abstract( 'DOCUMENTAZIONE_RICHIESTAGrid', 'TipoInterventoDocumentazione' , r  , verso );
	Move_Abstract( 'DOCUMENTAZIONE_RICHIESTAGrid', 'AllegatoRichiesto' , r  , verso );
	Move_Abstract( 'DOCUMENTAZIONE_RICHIESTAGrid', 'AnagDoc' , r  , verso );
	Move_Abstract( 'DOCUMENTAZIONE_RICHIESTAGrid', 'NotEditable' , r  , verso );
	Move_Abstract( 'DOCUMENTAZIONE_RICHIESTAGrid', 'Obbligatorio' , r  , verso );
	Move_Abstract( 'DOCUMENTAZIONE_RICHIESTAGrid', 'RichiediFirma' , r  , verso );
	Move_Abstract( 'DOCUMENTAZIONE_RICHIESTAGrid', 'TipoFile' , r  , verso );
	
	move_Descrizione_Doc( 'DescrizioneRichiesta' , r  , verso );
	

}




//inverte il campo descrizione di due righe
//contemplando anche i casi in cui su una riga il campo � editabile e su un'altra no
function move_Descrizione_Doc( field , row , verso ) 
{
				
	try
    {
        var f1 = getObj( 'RDOCUMENTAZIONE_RICHIESTAGrid_' + row + '_' + field );
        var f2 = getObj( 'RDOCUMENTAZIONE_RICHIESTAGrid_' + ( row + verso ) + '_' + field ) ;
        var app;
		
		var f1_edit =0 ;
		var f2_edit =0 ;
		
		
		
		f1_V = getObj( 'RDOCUMENTAZIONE_RICHIESTAGrid_' + row + '_' + field + '_V');
			
		if ( f1_V == null ){
			
			f1_edit = 1 ; 
		}
		
		f2_V = getObj( 'RDOCUMENTAZIONE_RICHIESTAGrid_' + ( row + verso ) + '_' + field + '_V') ;
		
		
		if ( f2_V == null ){
			
			f2_edit = 1 ;
		}
		
		//alert(f1_edit + '---' + f2_edit);
		//sorgente non editabile e destinazione editabile
		if ( f1_edit != f2_edit )
		{
			if ( f1_edit == 0)
			{	
				
				//alert( Descrizione_Doc_NotEditable ( ( row + verso )  , f1_V.innerHTML  ));
				//la destinazione diventa non editabile con il valore di f1
				f2.parentNode.innerHTML = Descrizione_Doc_NotEditable ( ( row + verso )  , f1_V.innerHTML );
				
				//alert(Descrizione_Doc_Editable (    row  , f2.value ))
				//la sorgente diventa editabile con il valore di f2
				f1_V.parentNode.innerHTML =  Descrizione_Doc_Editable (    row  , f2.value );
				
			}
			else
			{	
				
				
				//la destinazione diventa  editabile con il valore di f1
				f2_V.parentNode.innerHTML = Descrizione_Doc_Editable ( ( row + verso )  , f1.value );
				
				
				//la sorgente diventa non editabile con il valore di f2
				f1.parentNode.innerHTML =  Descrizione_Doc_NotEditable (    row  , f2_V.innerHTML );
				
			}
			
		}
		else
		{
			//inverte i valori dei campi (visuali/nascosti) se entrambi editabili oppure no
			
			app = f1.value;
			f1.value = f2.value;
			f2.value = app;
			
			
			f1 = getObj( 'RDOCUMENTAZIONE_RICHIESTAGrid_' + row + '_' + field + '_V');
			f2 = getObj( 'RDOCUMENTAZIONE_RICHIESTAGrid_' + ( row + verso ) + '_' + field + '_V') ;


			app = f1.value;
			
			f1.value = f2.value;
			f2.value = app
			
			if ( app == undefined )
			{
				try{
					app = f1.innerHTML;
					
					f1.innerHTML = f2.innerHTML;
					f2.innerHTML = app;
					
				}catch(e){}
			}
		}
		
	}
	catch(e)
	{
	}
}

function Descrizione_Doc_NotEditable ( rowRiga , strValue )
{
	var StrHtml =''
	StrHtml = '<span class="TextArea_NotEditable" id="RDOCUMENTAZIONE_RICHIESTAGrid_' + rowRiga + '_DescrizioneRichiesta_V">' +  strValue + '</span>';
	StrHtml = StrHtml  + '<textarea class="display_none attrib_base" name="RDOCUMENTAZIONE_RICHIESTAGrid_' +  rowRiga  + '_DescrizioneRichiesta" id="RDOCUMENTAZIONE_RICHIESTAGrid_' +  rowRiga  + '_DescrizioneRichiesta">' + strValue + '</textarea>';
	return StrHtml;
}	

function Descrizione_Doc_Editable ( rowRiga , strValue )
{
	var StrHtml =''
	
	//<textarea width="100%" cols="20" rows="0" name="RDOCUMENTAZIONE_RICHIESTAGrid_2_DescrizioneRichiesta" id="RDOCUMENTAZIONE_RICHIESTAGrid_2_DescrizioneRichiesta" class="TextArea width_100_percent" onkeypress="TA_MaxLen(this,250 );" onblur="TA_MaxLen(this,250 );">terza</textarea>
	
	StrHtml = '<textarea width="100%" cols="20" rows="0" name="RDOCUMENTAZIONE_RICHIESTAGrid_' +  rowRiga  + '_DescrizioneRichiesta" id="RDOCUMENTAZIONE_RICHIESTAGrid_' +  rowRiga  + '_DescrizioneRichiesta" class="TextArea width_100_percent" onkeypress="TA_MaxLen(this,250 );" onblur="TA_MaxLen(this,250 );">' + strValue + '</textarea>';
	return StrHtml;
}	



function DOCUMENTAZIONE_RICHIESTA_AFTER_COMMAND( param )
{
	
	
	//attivo DRAG&DROP sulla griglia Atti
	ActiveGridDrag (  'DOCUMENTAZIONE_RICHIESTAGrid' , MoveAllDoc );
	
}


function ActiveDrag ()
{
	//return;
	//attivo DRAG&DROP sulla griglia degli Atti
	ActiveGridDrag (  'DOCUMENTAZIONEGrid' , MoveAllAtti );
	
	//attivo DRAG&DROP sulla griglia Busta Documentazione 
	ActiveGridDrag (  'DOCUMENTAZIONE_RICHIESTAGrid' , MoveAllDoc );
}


function HideColDrag ()
{
	//nascondo drag_drop quando non editabile
	ShowCol( 'DOCUMENTAZIONE' , 'FNZ_DRAG' , 'none' );
	ShowCol( 'DOCUMENTAZIONE_RICHIESTA' , 'FNZ_DRAG' , 'none' );
	ShowCol( 'DOCUMENTAZIONE_RICHIESTA' , 'FNZ_ADD' , 'none' );
}


function Handle_Attrib_MODULO_APPALTO_PNRR_PNC( nCheckValori )
{
	
	if ( nCheckValori == undefined )
		nCheckValori = 1;
	
	//Se il campo Appalto_PNRR_PNC non esiste usciamo
	if ( !getObj('Appalto_PNRR_PNC') )
	{
		return;
	}
	
	DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;
	
	var val_SpuntaPNRR_PNC = 0;
	var Modulo_Attivo = 'yes';
	var HideCampi = 'no';
	var Campi_Area_PNRR_PNC_Valorizzati = 0;
	
	Modulo_Attivo = getObj('ATTIVA_MODULO_PNRR_PNC').value  ;
	
	//se il modulo non attivo oppure si tratta di una richiesta di preventivo nascondo i campi
	if ( Modulo_Attivo == 'no' || getObj('ProceduraGara').value == '15479' )
	{	
		HideCampi = 'yes' ;
	}
	else
	{
	  // recupero il valore della spunta di selezione
	  if ( DOCUMENT_READONLY == 0 )
      {
		strSpuntaPNRR_PNC = getObj('Appalto_PNRR_PNC').checked ;
		if (strSpuntaPNRR_PNC)
			val_SpuntaPNRR_PNC = 1;
	  }
	  else	
	  {
		val_SpuntaPNRR_PNC = getObj('Appalto_PNRR_PNC').value;
	  }	
	  
	  if ( val_SpuntaPNRR_PNC != 1)
		  HideCampi = 'yes';
	}
	
	
	
	
	//se ilmodulo attivo vado a nascondere i campi a seconda della spunta
	if ( Modulo_Attivo == 'yes' )
	{
		if ( HideCampi == 'yes')
		{	
	
			//se devo nascondere i campi verifico se almeno 1 campo della area di competenza � valorizzato
			//se si devo chiedere ocnferma per procedere
			
			if ( nCheckValori == 1 )
				Campi_Area_PNRR_PNC_Valorizzati = Check_Campi_Area_PNRR_PNC();
			
			//alert(Campi_Area_PNRR_PNC_Valorizzati );
			
			if ( Campi_Area_PNRR_PNC_Valorizzati == 1)
			{	
				var ML_text = 'Se si procede con il tasto "OK" le informazioni predisposte nella sezione "Informazioni PNRR/PNC" verranno svuotate, altrimenti premere il tasto "Cancel"';
				var Title = 'Attenzione';					
				var ICO = 3;
				var page = 'ctl_library/MessageBoxWin.asp?MODALE=YES&ML=YES&MSG=' + encodeURIComponent( ML_text ) +'&CAPTION=' + encodeURIComponent(Title) + '&ICO=' + encodeURIComponent(ICO);
				
				ExecFunctionModaleConfirm( page, Title , 200 , 420 ,null, 'confermaHideCampiSimog' , 'NonConfermaHideCampiSimog' );
			}
			else
			{
				//nascondo i campi della sezione PNRR_PNC
				confermaHideCampiSimog();
			}
						
			
			
		}
		else
		{
			
			$("#cap_Appalto_PNRR").parents("table:first").parents("tr:first").css({"display": ""});
			$("#cap_Motivazione_Appalto_PNRR").parents("table:first").parents("tr:first").css({"display": ""});
			$("#cap_Appalto_PNC").parents("table:first").parents("tr:first").css({"display": ""});
			$("#cap_Motivazione_Appalto_PNC").parents("table:first").parents("tr:first").css({"display": ""});

			//Se i nuovi campi del simog esistono
			if ( getObj('cap_FLAG_PREVISIONE_QUOTA') )
			{
				$("#cap_FLAG_PREVISIONE_QUOTA").parents("table:first").parents("tr:first").css({"display": ""});
				$("#cap_QUOTA_FEMMINILE").parents("table:first").parents("tr:first").css({"display": ""});
				$("#cap_QUOTA_GIOVANILE").parents("table:first").parents("tr:first").css({"display": ""});
				$("#cap_ID_MOTIVO_DEROGA").parents("table:first").parents("tr:first").css({"display": ""});
				$("#cap_FLAG_MISURE_PREMIALI").parents("table:first").parents("tr:first").css({"display": ""});
				$("#cap_ID_MISURA_PREMIALE").parents("table:first").parents("tr:first").css({"display": ""});
			}
		}	
		
	}
	else
	{
		var rigaPilota = $("#cap_Appalto_PNRR_PNC").parents("table:first").parents("tr:first").index();;
		var tabellaContenitore = $("#cap_Appalto_PNRR_PNC").parents("table:first").parents("table:first");
		
		//nascondiamo le 5 righe successive alla rigaPilota per non lasciare un area vuota a video. non c'� altro modo. all'interno di queste righe da nascondere
		//	non c'� nessun elemento che permetta un accesso diretto.
		$('#' + tabellaContenitore.attr('id') + ' > tbody  > tr').each(function(index, tr) 
		{ 
			if ( index > rigaPilota && index <= rigaPilota+5 )
			{
				//console.log(index);
				//console.log(tr);
				tr.style.display = 'none';
			}

		});
		
		
	}
	
}

function validaDatiSimogPNRR()
{
	var Modulo_Attivo = 'yes';
	/* SE IL CAMPO ESISTE */
	if ( getObj('ATTIVA_MODULO_PNRR_PNC'))
	{
		Modulo_Attivo = getObj('ATTIVA_MODULO_PNRR_PNC').value;
	}
	else
	{
		Modulo_Attivo = "no";
	}

	if ( Modulo_Attivo == 'yes' )
	{
		if ( getObj('Appalto_PNRR_PNC').checked )
		{
			
			var Val_SYS_VERSIONE_SIMOG = getObj('SYS_VERSIONE_SIMOG').value;
			var quotaMaggiore = getObj('FLAG_PREVISIONE_QUOTA').value;
			var quotaFem = getObj('QUOTA_FEMMINILE').value;
			var quotaGio = getObj('QUOTA_GIOVANILE').value;
			var motivoDeroga = getObj('ID_MOTIVO_DEROGA').value;
			var flagMisurePremiali = getObj('FLAG_MISURE_PREMIALI').value;
			var misuraPremiali = getObj('ID_MISURA_PREMIALE').value;		
			
			//blocco Se il campo 'Quota >=30% pari opportunit�' non � valorizzato e 'Appalto_PNRR_PNC' � spuntato
			if ( quotaMaggiore == '' )
			{
				DMessageBox('../', 'Valorizzare il campo Quota 30 pari opportunita' , 'Attenzione', 1, 400, 300);
				DocShowFolder( 'FLD_COPERTINA' );
				return false;
			}
			
			if ( quotaFem == '' && quotaMaggiore == 'Q' && ( quotaGio == '' || quotaGio == '0' ) )
			{
				DMessageBox('../', 'Non e stato indicato il valore della Previsione di una quota inferiore con riferimento occupazione femminile' , 'Attenzione', 1, 400, 300);
				DocShowFolder( 'FLD_COPERTINA' );
				return false;
			}
			
			//Per la versione 3.4.7 i controlli su quota femminile e quota giovanile se sono >=30 son a prescindere
			if ( Val_SYS_VERSIONE_SIMOG == '3.4.7' )
			{
				if ( Number(quotaFem) >= 30 )
				{
					DMessageBox('../', 'Il campo quota fem prevede l\'inserimento di una quota inferiore al 30'  , 'Attenzione', 1, 400, 300);
					DocShowFolder( 'FLD_COPERTINA' );
					return false;
				}
				
				//Se il campo quotaFem � valorizzato con una quota >=30%
				if ( Number(quotaGio) >= 30 )
				{
					DMessageBox('../', 'Il campo quota giov prevede l\'inserimento di una quota inferiore al 30' , 'Attenzione', 1, 400, 300);
					DocShowFolder( 'FLD_COPERTINA' );
					return false;
				}
			}
			
			//dalla versione 3.4.8 cambia il controllo su quota femminile e quota giovanile se sono >=30
			//lo facciamo solo se ho scelto FLAG_PREVISIONE_QUOTA= quota inferiore
			if ( Val_SYS_VERSIONE_SIMOG >= '3.4.8' )
			{
				if ( quotaMaggiore == 'Q' && Number(quotaGio) >= 30 && Number(quotaFem) >= 30 )
				{
					DMessageBox('../', 'almeno una quota, tra occupazione femminile e occupazione giovanile, deve essere inferiore al 30' , 'Attenzione', 1, 400, 300);
					DocShowFolder( 'FLD_COPERTINA' );
					return false;
				}
			}
			//Se il campo 'QUOTA_GIOVANILE' non � valorizzato e il campo 'FLAG_PREVISIONE_QUOTA'= SI e 'QUOTA_FEMMINILE'=0%
			if ( quotaGio == '' && quotaMaggiore == 'Q' && ( quotaFem == '' || quotaFem == '0' ) )
			{
				DMessageBox('../', 'Non e stato indicato il valore della Previsione di una quota inferiore con riferimento occupazione giovanile' , 'Attenzione', 1, 400, 300);
				DocShowFolder( 'FLD_COPERTINA' );
				return false;
			}
			
			
			
			//motivo deroga Obbligatorio Se il campo S02.23= SI quota inferiore oppure S02.23= NO
			if ( motivoDeroga == '' && ( quotaMaggiore == 'Q' || quotaMaggiore == 'N' ) )
			{
				DMessageBox('../', 'Il campo Motivo deroga e\' obbligatorio' , 'Attenzione', 1, 400, 300);
				DocShowFolder( 'FLD_COPERTINA' );
				return false;
			}
			
			if ( flagMisurePremiali == 'S' && misuraPremiali == '' )
			{
				DMessageBox('../', 'Il campo Misure premiali e\' obbligatorio' , 'Attenzione', 1, 400, 300);
				DocShowFolder( 'FLD_COPERTINA' );
				return false;
			}
			
			if ( flagMisurePremiali == '' )
			{
				DMessageBox('../', '"Presenza di misure premiali" e\' obbligatorio se "Appalto PNRR/PNC" e\' selezionato' , 'Attenzione', 1, 400, 300);
				DocShowFolder( 'FLD_COPERTINA' );
				return false;
			}

		}
	}
	
	return true;
	
}


//se almeno 1 campo valorizzato dell'area PNRR_PNC ritorna 1 altrimenti 0
function Check_Campi_Area_PNRR_PNC ()
{
	//var nRet = 0 ;
	
	/* campi dell'area PNRR_PNC  sono
	Appalto_PNRR
	Motivazione_Appalto_PNRR
	Appalto_PNC
	Motivazione_Appalto_PNC
	FLAG_PREVISIONE_QUOTA
	QUOTA_FEMMINILE
	QUOTA_GIOVANILE
	ID_MOTIVO_DEROGA
	FLAG_MISURE_PREMIALI
	ID_MISURA_PREMIALE
	*/
	if ( getObj('Appalto_PNRR').value != '' || getObjValue('Motivazione_Appalto_PNRR') != ''  || getObj('Appalto_PNC').value != '' || getObjValue('Motivazione_Appalto_PNC') != '' )
	{	
		return 1 ;
	}
	
	if ( getObj('cap_FLAG_PREVISIONE_QUOTA') )
	{
		if ( getObj('FLAG_PREVISIONE_QUOTA').value != '' || getObj('QUOTA_FEMMINILE').value != '' || getObj('QUOTA_GIOVANILE').value != '' || getObj('ID_MOTIVO_DEROGA').value != '' || getObj('FLAG_MISURE_PREMIALI').value != '' || getObj('ID_MISURA_PREMIALE').value != '')
			return 1 ;
	}
	
	return 0;
	
}


//svuota e nasconde i campi dell'area PNRR_PNC
function confermaHideCampiSimog()
{
	//svuoto i campi
	try
	{
		getObj('Appalto_PNRR').value = '';
		getObj('Motivazione_Appalto_PNRR').value ='';
		getObj('Appalto_PNC').value = '';
		getObj('Motivazione_Appalto_PNC').value ='';
	}catch(e){}
	
	//nascondo i campi
	$("#cap_Appalto_PNRR").parents("table:first").parents("tr:first").css({"display": "none"});
	$("#cap_Motivazione_Appalto_PNRR").parents("table:first").parents("tr:first").css({"display": "none"});
	$("#cap_Appalto_PNC").parents("table:first").parents("tr:first").css({"display": "none"});
	$("#cap_Motivazione_Appalto_PNC").parents("table:first").parents("tr:first").css({"display": "none"});
	
	
	//Se i nuovi campi del simog esistono
	if ( getObj('cap_FLAG_PREVISIONE_QUOTA') )
	{
		//svuoto i campi
		try
		{
			getObj('FLAG_PREVISIONE_QUOTA').value = '';
			getObj('QUOTA_FEMMINILE').value = '';
			getObj('QUOTA_FEMMINILE_V').value = '';
			getObj('QUOTA_GIOVANILE').value = '' ;
			getObj('QUOTA_GIOVANILE_V').value = '' ;
			getObj('ID_MOTIVO_DEROGA').value = '';
			getObj('FLAG_MISURE_PREMIALI').value = '';
			getObj('ID_MISURA_PREMIALE').value = '' ;
			getObj('ID_MISURA_PREMIALE_edit_new').value = '' ;
		}catch(e){}
		
		//nascondo i campi
		$("#cap_FLAG_PREVISIONE_QUOTA").parents("table:first").parents("tr:first").css({"display": "none"});
		$("#cap_QUOTA_FEMMINILE").parents("table:first").parents("tr:first").css({"display": "none"});
		$("#cap_QUOTA_GIOVANILE").parents("table:first").parents("tr:first").css({"display": "none"});
		$("#cap_ID_MOTIVO_DEROGA").parents("table:first").parents("tr:first").css({"display": "none"});
		$("#cap_FLAG_MISURE_PREMIALI").parents("table:first").parents("tr:first").css({"display": "none"});
		$("#cap_ID_MISURA_PREMIALE").parents("table:first").parents("tr:first").css({"display": "none"});
	}
	
	//se proceduragara = ristretta nascondo anche il campo principale e la label che identifica la sezione
	if ( getObj('ProceduraGara').value == '15479' )
	{
		//alert(getObj('ProceduraGara').value);
		$("#cap_Static9").parents("tr:first").css({"display": "none"});
		$("#cap_Appalto_PNRR_PNC").parents("table:first").css({"display": "none"});
		$("#Cell_Appalto_PNRR_PNC").parents("td:first").css({"display": "none"});
		$("#Appalto_PNRR_PNC").parents("td:first").css({"display": "none"});
		
		//nascondo le righe vuote sulla parte sopra
		//getObj('BANDO_GARA_TESTATA_GAREINFORMALI').rows[15].style.display = 'none';
	}
	
}




function NonConfermaHideCampiSimog()
{
	getObj('Appalto_PNRR_PNC').checked = true;
}



function Handle_Attrib_Struttura_Appartenenza()
{
	if ( DOCUMENT_READONLY == '0' ) 
	{ 
		//se i campi delle strutture sono visibili applico i filtri in base ad azienda proponente e azienda espletante	
		var objBtn_Struttura = getObj('DirezioneEspletante_button');
		if (objBtn_Struttura != null)
		{
			//try	{filtro_StrutturaAppartenenza( 'StrutturaAziendale' );	}catch(e){}
			try	{filtro_StrutturaAppartenenza( 'DirezioneEspletante' );	}catch(e){}
			
		}	
	}
}	



function filtro_StrutturaAppartenenza( Attrib  )
{
	var filter = '';
	
	//per la struttura proponente
	if ( Attrib == 'StrutturaAziendale' )
	{	
		
		
		try
		{ 
			
			filter = ' dmv_father like  (\'' + getObj('EnteProponente').value + '%\')' ;
			getObj('StrutturaAziendale_extraAttrib').value= 'strformat#=#D#@#filter#=#SQL_WHERE= ' + filter + '#@#multivalue#=#0';
			
			
		}
		catch(e){};
	}
	
	//per la struttura espletante
	if ( Attrib == 'DirezioneEspletante' )
	{	
		try
		{ 
			
			filter = 'idaz in ( ' + getObj('Azienda').value + ' )' ;
			getObj('DirezioneEspletante_extraAttrib').value= 'strformat#=#D#@#filter#=#SQL_WHERE= ' + filter + '#@#multivalue#=#0';
			
			
		}
		catch(e){};
	}
	
}


function onChangeRUP_Prop()
{
	
	//non faccio nulla esco subito non devo influenzare il campo strutturaaziendale
	return;
	
	
	
	//faccio una chiamata ajax per aggiornare il campo DirezioneEpletante
	/*
	if ( getObj('RupProponente').value != '' )
	{
		var nocache = new Date().getTime();
				
		ajax = GetXMLHttpRequest();		

		ajax.open("GET",'../../ctl_library/functions/Get_StrutturaAppartenenza_User.asp?IdPfu=' + getObj('RupProponente').value  + '&nocache=' + nocache , false);
		ajax.send(null);
		
		if(ajax.readyState == 4) 
		{
			//alert(ajax.status); 
			if(ajax.status == 404 || ajax.status == 500)
			{
			  alert('Errore invocazione pagina');	
			  return;
			}
			//alert(ajax.responseText); 
			if ( ajax.responseText != '' ) 
			{
				
				var vet = ajax.responseText.split( '@@@' );
				
				getObj('StrutturaAziendale').value = vet[0];
				getObj('StrutturaAziendale_edit').value = vet[1];
				getObj('StrutturaAziendale_edit_new').value = vet[1];
				
				
				
			}
		}	
	}
	else
	{
		getObj('StrutturaAziendale').value = '';
		getObj('StrutturaAziendale_edit').value = 'Seleziona';
		getObj('StrutturaAziendale_edit_new').value ='Seleziona';
	}
	*/
	
}


function OnChangeDirezioneEspletante()
{
	//allineo il valore della struttura aziendale con quello della direzione espletante
	getObj('StrutturaAziendale').value = getObj('DirezioneEspletante').value ;
}

function CambiaTipoAppalto()
{	
	ExecDocProcess('ONCHANGETIPOAPPALTOGARA,BANDO_GARA');       
}


function AfterChangeIniziativa()
{
	//Solo se è attivo il modulo GROUP_PROGRAMMAZIONE_INIZIATIVE
	if(getObjValue('isActive_GROUP_PROGRAMMAZIONE_INIZIATIVA') == 'yes')
	{
		ExecDocProcess('CHANGEINIZIATIVA,BANDO_GARA,,NO_MSG');
	}
}



function SetFilterIniziative_FromRup()
{	
	
	//solo se il doc editabile e attivo il modulo PROGRAMMAZIONE_INIZIATIVE
	if(getObj('isActive_GROUP_PROGRAMMAZIONE_INIZIATIVA') &&
   getObj('isActive_GROUP_PROGRAMMAZIONE_INIZIATIVA') !== null &&
   getObjValue('isActive_GROUP_PROGRAMMAZIONE_INIZIATIVA') == 'yes')
	{

		var strFilter = 'SQL_WHERE= dmv_cod in ( select ID_Iniziativa from Rup_Programmazione_Iniziative where UserRUP = \'' + getObjValue ('UserRUP') + '\' )';

		SetProperty(getObj('IdentificativoIniziativa'), 'filter', strFilter );
	}
}


function OnChangeCategorieMerceologiche()
{
	//solo se il doc editabile e attivo il modulo PROGRAMMAZIONE_INIZIATIVE
	if(getObjValue('isActive_GROUP_PROGRAMMAZIONE_INIZIATIVA') == 'yes')
	{
		SelectreadOnly( 'DPCM' , false );
		
		//se CATEGORIE_MERC vale 999 devo settare il campo DPCM a no altrimenti sì
		if (getObjValue('CATEGORIE_MERC') == '999')
		{
			getObj('DPCM').value = 'no'
		}
		else
		{
			getObj('DPCM').value = 'si'
		}
		
		//Bocco il campo rendendolo readonly
		SelectreadOnly( 'DPCM' , true );
	}
}





//per abilitare o disabilitare il comando "Crea Questionario" in funzione del campo "presenza questionario"
/*
function OnChangePresenzaQuestionario ()
{
	//se presente il comando "Crea Questionario" 
	if ( getObj('BANDO_TOOLBAR_DOCUMENT_DOC_RIC_SDA_CreateQuestionarioFrom') )
	{
		
		//se il valore dell'onclick del comando ancora nn è stato salvato me lo prendo
		//per risettarlo se abilito la presenza del questionario
		if (! OnClickCreaQuestionario)
		{	
			
			OnClickCreaQuestionario = GetProperty(getObj('BANDO_TOOLBAR_DOCUMENT_DOC_RIC_SDA_CreateQuestionarioFrom'), 'onclick');
			
		}
		
		
		PresenzaQuestionario = getObj('PresenzaQuestionario').value;
		
		if ( PresenzaQuestionario == 'no')
		{		
			SetProperty(getObj('BANDO_TOOLBAR_DOCUMENT_DOC_RIC_SDA_CreateQuestionarioFrom'), 'onclick', 'function(){return false;}');
			$("#BANDO_TOOLBAR_DOCUMENT_DOC_RIC_SDA_CreateQuestionarioFrom").parents("li:first").attr('class', 'Toolbar_buttonDisabled');			
		}
		else
		{
			SetProperty(getObj('BANDO_TOOLBAR_DOCUMENT_DOC_RIC_SDA_CreateQuestionarioFrom'), 'onclick', OnClickCreaQuestionario );
			$("#BANDO_TOOLBAR_DOCUMENT_DOC_RIC_SDA_CreateQuestionarioFrom").parents("li:first").attr('class', 'Toolbar_button');
		}	
	}
}
*/



function QUESTIONARIO_Request() {
  if (getObjValue('PresenzaQuestionario') == 'si') {
    
	MakeDocFrom('QUESTIONARIO_AMMINISTRATIVO##DOC');
  }
  else {
    DMessageBox('../', 'E\' necessario aver selezionato la presenza del Questionario', 'Attenzione', 1, 400, 300);
  }

}

function QUESTIONARIO_TECNICO_Request() {
  if (getObjValue('PresenzaQuestionarioTecnico') == 'si') {
    
	MakeDocFrom('QUESTIONARIO_AMMINISTRATIVO##DOC_TECNICA');
  }
  else {
    DMessageBox('../', 'E\' necessario aver selezionato la presenza del Questionario', 'Attenzione', 1, 400, 300);
  }

}


//serve ad allineare l'area per il questionario amministrATIVO ALL'AREA DELLa presenza dgue
function AllineaQuestionario_PresenzaDGUE()
{
	if ( getObj('PresenzaQuestionario') )
	{
			//recupero larghezza del contentitore di PresenzaDGUE
			
			//alert( $("#cap_PresenzaDGUE").parents("table:first").width() );
			//alert( $("#cap_PresenzaQuestionario").parents("table:first").width() );
			
			var strWidth ;
			strWidth = $("#cap_PresenzaDGUE").parents("table:first").parents("td:first").width() ;
			//alert(strWidth);
			
			if ( ! strWidth )
				strWidth = '400';
			
			
			$("#cap_PresenzaQuestionario").parents("table:first").parents("td:first").css("width", strWidth );
    }
}



function ChangeImportoConcorso( obj )
{
	try
	{
		var ImportoAltriConcorrenti = Number( getObj( 'Importo_Altri_Concorrenti' ).value ) ;
		var importoBaseAsta2 = Number( getObj( 'importoBaseAsta2' ).value ) ;
		var ImportoProgettazione = Number( getObj( 'Importo_Progettazione_Succ' ).value ) ;
	  

		// se presente la forma visuale
		if (getObj('importoBaseAsta_V'))
			SetNumericValue('importoBaseAsta', ImportoAltriConcorrenti + importoBaseAsta2 + ImportoProgettazione);
		else
			getObj('importoBaseAsta').value = ImportoAltriConcorrenti + importoBaseAsta2 + ImportoProgettazione;
	} 
	catch(e) 
	{
		
	}
}


function VisualizzaBustaDocumentazioneTecnica()
{
	//il controllo sulla presenza della sezione 'BustaDocumentazioneTecnica'
	ExecDocProcess('CHANGE_PREVISTA_ASSEGNAZIONE_PREMI,BANDO_CONCORSO,,NO_MSG');
	return;
	
}

function  CheckImportiConcorsi() 
{
	var PrevistoAssegnazionePremi = getObj( 'PrevistaAssPremi' ).value;
	var ImportoDelConcorso = Number( getObj( 'importoBaseAsta' ).value ) ; // Importo del concorso
	var ImportoAltriConcorrenti = Number( getObj( 'Importo_Altri_Concorrenti' ).value ) ; // Premio altri concorrenti
    var ImportoPrimoVincitore = Number( getObj( 'importoBaseAsta2' ).value ) ; // Premio del primo vincitore
    var ImportoProgettazione = Number( getObj( 'Importo_Progettazione_Succ' ).value ) ; // Valore stimato dei livelli successivi di progettazione
	
	if (ImportoDelConcorso == 0.0)
	{
		DMessageBox('../', 'Errore importo del concorso uguale a zero', 'Attenzione', 1, 400, 300);
		return -1;
	}
	
	if (ImportoPrimoVincitore == 0.0 && ImportoAltriConcorrenti > 0) 
	{
		getObj( 'Importo_Altri_Concorrenti' ).value = '';
		DMessageBox('../', 'Errore importo vincitore uguale a zero e importo altri concorrenti maggiore di zero', 'Attenzione', 1, 400, 300);
		return -1;
	}
	
	if (PrevistoAssegnazionePremi == 'si') 
	{
		return CheckImportiGriglia(ImportoPrimoVincitore, ImportoAltriConcorrenti);
	}
	
	return 1;
}

function  CheckImportiGriglia(ImportoPrimoVincitore, ImportoAltriConcorrenti)  
{
	var nomeGriglia = 'InfoTec_DefinizionePremi_grigliaGrid';
	var primoPremio = 0;
	var altriPremi = 0;
	if (GetProperty(getObj(nomeGriglia), 'numrow') != -1) 
	{
		var numrighe = GetProperty(getObj(nomeGriglia), 'numrow');
		i = 0;
		var k = 0;
		for (i = 0; i <= numrighe; i++) {			
			var valoreCellaClassifica = getObjValue('R' + nomeGriglia + '_' + i + '_Classifica');
			var valoreCellaImporto = getObjValue('R' + nomeGriglia + '_' + i + '_ImportiVari');
			if (valoreCellaClassifica == '1') 
			{
				if (valoreCellaImporto != '') 
					primoPremio += Number(valoreCellaImporto);
			}
			else 
			{
				if (valoreCellaImporto != '') 
					altriPremi += Number(valoreCellaImporto);
			}
		}
	}
		
	if ((altriPremi != ImportoAltriConcorrenti) || (ImportoPrimoVincitore != primoPremio)) 
	{
		DMessageBox('../', 'Gli importi in Definizione Premi nel tab Informazioni tecniche non corrispondono a quelli indicati in testata.', 'Attenzione', 1, 400, 300);
		return -1;
	}		
	return 1;
}