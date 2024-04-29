var flag=0;
var gModAttribPunteggio = '';

//window.onload = OnLoadPage; //SpecializzaModello;

$( document ).ready(function() {
    OnLoadPage();
});


function SetFieldIfEmpty( Field , Value )
{
	try{
		if ( getObj(Field) )
		{
			if ( getObjValue(Field) == '' )
			{
				getObj(Field).value = Value;
			}
		}
	}catch(e){}
}

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
	
	
	//INIZIO MOD PER CN16
	try
	{
		// - Se il campo esiste
		if ( getObj('cn16_ExecutionRequirementCode_reserved_execution') )
		{
			SelectreadOnly('cn16_ExecutionRequirementCode_reserved_execution', true);
		}
		
		var valProcAccelerated = '';
		
		//Se a video viene visualizzato il campo "E' stata utilizzata la procedura accelerata?" nella testata della gara ( custom per IC ), allora nascondo quello nella sez. INTEROP
		if ( getObj('val_W3PROCEDUR') )
		{
			getObj('cn16_ProcessJustification_accelerated_procedure').value = '';
			getObj('val_cn16_ProcessJustification_accelerated_procedure').style.display = 'none';
			getObj('cap_cn16_ProcessJustification_accelerated_procedure').style.display = 'none';
			
			valProcAccelerated = getObjValue('W3PROCEDUR');
		}
		else
		{
			valProcAccelerated = getObjValue('cn16_ProcessJustification_accelerated_procedure');
		}
		
		if ( valProcAccelerated == 'false' )
		{
			getObj('cn16_ProcessJustification_ProcessReason').value = '';
			SelectreadOnly('cn16_ProcessJustification_ProcessReason', true);
		}
		if ( valProcAccelerated == 'true' )
		{
			SelectreadOnly('cn16_ProcessJustification_ProcessReason', false);
		}

	}
	catch(e){}

	//FINE MOD PER CN16

	//PCP
	try 
	{
		if (hasPCP() && ((getObj('isSimogGgap') === null || getObj('isSimogGgap') === undefined))) 
		{
		  
		  PCP_showOrHideFields();
		  
		  //Richiamo la funzione per il centro di costo per entrambi gli enti
		  PCP_CodiceCentroDiCosto('Appaltante');	  
		  PCP_CodiceCentroDiCosto('Proponente');
		  
		  PCP_obbligatoryFields();
		}
	} catch { }
    //FINE PCP
	
	var DOCUMENT_READONLY_LOCAL = '0';
	
	try
	{
		if( getObjValue( 'StatoFunzionale' ) == 'InLavorazione'  && getObjValue( 'BANDO_REVOCATO') == 'si')
		{
			ExecDocProcess( 'CHECK_REVOCA,BANDO_SEMPLIFICATO');
			return;
		}  
	}
	catch(e){}
	
	
	try 
	{
	  
		DOCUMENT_READONLY_LOCAL = isDocumentReadonly();	  
		//CriterioAggiudicazione = getObjValue('CriterioAggiudicazioneGara');
	}
	catch (e) 
	{
	}
	
	
	//gestisco la presenza dell'ampiezza di gamma sulla tabella lotti
	presenzaAmpiezzaDiGamma()


	// Per GGAP: se il modulo GGAP e' abbilitato
	if(getObj('isSimogGgap') !== null && getObj('isSimogGgap') !== undefined)
	{
		if (DOCUMENT_READONLY_LOCAL == '0') // il documento e' il lavorazione cioe editabile
		{	
			try {
				getObj('RichiestaCigSimog').value = 'si';
				getObj('val_RichiestaCigSimog').textContent = 'si';
				getObj('val_RichiestaCigSimog_extraAttrib').value = 'value#=#si';

				getObj("cap_RichiestaCigSimog").closest("td").parentElement.closest("td").style.display = '';
				
				SetTextValue('CIG', '');
				SelectreadOnly('CIG', true);
			} catch (error) {}
		}
		
		// Prendo la lista delle unita organizzative
		if (getObj('GgapUnitaOrganizzative') !== null && getObj('GgapUnitaOrganizzative') !== undefined)
		{
			var ggapUnitaOrganizzative = getObj('GgapUnitaOrganizzative'); // il dominio: la select con le options
			var ggapUnitaOrganizzativeValue = getObj('val_GgapUnitaOrganizzative_extraAttrib').value.split('#=#')[1] // un input: campo nascosto che contiene il valore selezionato dall'utente (e salvato)

			if (DOCUMENT_READONLY_LOCAL == '0') // il documento e' in lavorazione cioe editabile
			{
				// Rimuovo le options non necessarie
				for (var j = 0; j < ggapUnitaOrganizzative.options.length; j++)
				{
					if (ggapUnitaOrganizzative.options[j].text === '' || ggapUnitaOrganizzative.options[j].text === null)
						ggapUnitaOrganizzative.remove(j);
				}
			
				var idAzi=idaziAziendaCollegata;
				var idAziParam = 'idAzi=' + idAzi; // idAzi e' il nome del parametro che si aspetta il servizio del backend che interagisce con GGAP.

				var userRup = getObjValue('UserRUP');
				var userRupParam = 'userRup=' + userRup; // userRup e' il nome del parametro che si aspetta il servizio del backend che interagisce con GGAP.

				var url = "/SimogGgapApi/SmartCig/LeggiUOByCfEnte_Auth?" + idAziParam + "&" + userRupParam;

				ajax = GetXMLHttpRequest();
				ajax.open("GET", url, false);

				ajax.send(null);

				if (ajax.readyState == 4) 
				{
					if (ajax.status === 200)
					{
						var responseArray = ajax.responseText.split('#');
						var responseData = JSON.parse(responseArray[1]);
					
						for (var i = 0; i < responseData.length; i++)
						{
							var newOption = new Option(responseData[i].descrizione, responseData[i].id);
							getObj('GgapUnitaOrganizzative').add(newOption);

							if(responseData[i].id == ggapUnitaOrganizzativeValue)
								ggapUnitaOrganizzative.selectedIndex = i + 1; // +1 perche' nel tag select c'e' gia' una option ed e' quella di default con text="Select"
						}
					}
					else
					{
						var ajaxStatus = "Error: " + ajax.status;
						DMessageBox('../', 'NO_ML###Errore nel prendere le unita organizzative. ' + ajaxStatus, 'Attenzione', 1, 400, 300);
					}
				}
			}
			else // il documento non e' editabile
			{
				// Rimuovo tutte le options non necessarie
				for (var j = 0; j < ggapUnitaOrganizzative.options.length; j++)
				{
					if (ggapUnitaOrganizzative.options[j].text === '' || ggapUnitaOrganizzative.options[j].text === null)
						ggapUnitaOrganizzative.remove(j);
				}
			
				// Aggiungi solo l'opzione salvata
				var newOption = new Option(getObj('Descrizione').value, ggapUnitaOrganizzativeValue);
				getObj('GgapUnitaOrganizzative').add(newOption);
			
				ggapUnitaOrganizzative.selectedIndex = getObj('GgapUnitaOrganizzative').options.length - 1;
			}

			if (getObj('idGaraGgap') !== null && getObj('idGaraGgap') !== undefined && getObj('idGaraGgap').value !== '')
			{
    	        SelectreadOnly('val_GgapUnitaOrganizzative', true);
			}
		}
		else // Il documento e' pubblicato
		{
			// Aggiungi solo l'opzione salvata
			getObj('val_GgapUnitaOrganizzative').textContent = getObj('Descrizione').value;
		}
	}
	
	
	var DOCUMENT_READONLY = isDocumentReadonly();	 //getObj('DOCUMENT_READONLY').value;

	//nascondo la busta tecnica per i lotti che non ne hanno bisogno
	try{ HideBustaTecnicaLotti(); 	}catch(e){}

	//Se esiste l'attributo 'attivoSimog'
	if ( getObj('attivoSimog') )
	{
		//Se non � attivo il simog nascondiamo il campo a dominio 'RichiestaCigSimog'
		if ( getObjValue('attivoSimog') != '1' && getObjValue('attivoSimog') != 'True' )
		{
			getObj('attivoSimog').value = 'no';
			$("#cap_RichiestaCigSimog").parents("table:first").css({"display": "none"});
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
			else
			{
				try
				{				
					$("#cap_AllegatoPerOCP").parents("table:first").css({"display": "none"});
				}catch(e){}
			}
		}
		catch(e){}
	}
	
  
	//FiltraModelli();
	if (DOCUMENT_READONLY == '0' && getObjValue('StatoFunzionale') != 'InApprove') 
	{
        FiltraModelli();
    }
    
	

	//-- inizializzo il filtro dei cig validi
	REQUISITI_AFTER_COMMAND('');

  
	//gestisco i campi per gli appalti verdi
	onchangeAppalto_Verde();
	onchangeAcquisto_Sociale();
	onchangeGenderEquality();

	
	//Se i campi data sono vuoti preimpostare l'orario con le 12:00:00 ( Termini + quesiti )
	SetFieldIfEmpty( 'DataScadenzaOffIndicativa_HH_V' , '12');
	SetFieldIfEmpty( 'DataScadenzaOffIndicativa_MM_V' , '00');
	SetFieldIfEmpty( 'DataTermineQuesiti_HH_V' , '12' );
	SetFieldIfEmpty( 'DataTermineQuesiti_MM_V' , '00' );
	
	
	//cambia la tooltip della matita per Aprire il dettaglio del modello	
    var tmpMlg = '';
    try {
        tmpMlg = CNV(pathRoot, 'Modifica Modello Gara');
        getObj('RTESTATA_PRODOTTI_MODEL_FNZ_UPD_link').firstChild.alt = tmpMlg;
        getObj('RTESTATA_PRODOTTI_MODEL_FNZ_UPD_link').firstChild.title = tmpMlg;
    } catch (e) {}
	
	
	try {OnChange_Riparametrazione();} catch (e) {}
	
	try {DisplaySection();} catch (e) {}
	
	try {FilterDominio();} catch (e) {} //-- attributi criteri di valutazione

	 
	//gestisco i campi per elenco categorie
	//quando ci sono filtro l'elenco con le categorie dispobibili in base allo sda di proveniena LINKEDDOC 
	//EVOLUZIONE 25/10/2019 se non ci sono elenco_categorie_sda ma ci sono Elenco_Categorie_Merceologiche e Livello_Categorie_Merceologiche sullo sda filtriamo come fatto sullo sda
	//EVOLUZIONE DEL 28/11/2019 GESTIAMO QUANTO FATTO SOPRA CON UN PARAMETRO	 
	
	try
	{ 
	   //se non sono richieste sullo sda allora disabilito la scelta  && Get_CTL_PARAMETRI('SDA','EMPTY_IS_ALL','DefaultValue','true','-1') == 'false' 
	   if (  ( getObjValue( 'elenco_categorie_sda' ) == '' )  &&  ( getObjValue( 'Elenco_Categorie_Merceologiche' ) == ''  || getObjValue( 'Livello_Categorie_Merceologiche' ) == ''  || Get_CTL_PARAMETRI('SDA','EMPTY_IS_ALL','DefaultValue','true','-1') == 'false' ) ) 
	   {
			SelectreadOnly( 'Criteriio_scelta_fornitori' , true );
			getObj('Categorie_Merceologiche_button').style.display='none';	
			getObj('Categorie_Merceologiche_edit_new').className = 'readonly';
			
	   }
	   else  //quando ci sono filtro l'elenco con le categorie dispobibili in base allo sda di proveniena LINKEDDOC
	   {
			var id_sda=getObjValue( 'LinkedDoc' );
			var filtro='';

			if ( getObjValue( 'Elenco_Categorie_Merceologiche' ) != ''  && getObjValue( 'Livello_Categorie_Merceologiche' ) != ''  )
			{
				filtro= 'SQL_WHERE= DMV_DM_ID = \'' + getObjValue( 'Elenco_Categorie_Merceologiche' ) + '\' and DMV_LEVEL <= ' + getObjValue( 'Livello_Categorie_Merceologiche' ) 
			}
						
			if  ( getObjValue( 'elenco_categorie_sda' ) != '' )
			{
				filtro= 'SQL_WHERE= dmv_cod in ( select dmv_cod from SDA_Categorie_Merceologiche_SELECTED where idheader = ' + id_sda + ' ) ';
			}

			SetProperty( getObj('Categorie_Merceologiche'),'filter',filtro);
	   }
	}
	catch(e){}
	
	onChangeCalcoloSoglia();	
	
	try
	{
		//if( getObjValue( 'DOCUMENT_READONLY') == '0' )
		if ( isDocumentReadonly() == '0' )	
		{
			getObj('PresenzaDGUE' ).onchange = DGUE_Request_Active;
			getObj('PresenzaDGUE_Mandanti' ).onchange = DGUE_Request_Active_Mandanti;
			getObj('PresenzaDGUE_Ausiliarie' ).onchange = DGUE_Request_Active_Ausiliarie;
			getObj('PresenzaDGUE_Subappaltarici' ).onchange = DGUE_Request_Active_Subappaltarici;
			getObj('PresenzaDGUE_Subappalto' ).onchange = DGUE_Request_Active_Subappalto;
		}
	}catch(e){}
	
	try
	{
		if ( getObjValue( 'DGUEAttivo') != 'si' )
			document.getElementById('DGUE').style.display = "none";
		
	}catch(e){}
	
	try
	{
		//nasconde gli altri domini se Presenza DGUE diveso da si
		if ( getObjValue( 'PresenzaDGUE') != 'si' )
		{
			try
			{
				$("#cap_PresenzaDGUE_Mandanti").parents("table:first").css({"display": "none"});	
				$("#cap_PresenzaDGUE_Ausiliarie").parents("table:first").css({"display": "none"});
				$("#cap_PresenzaDGUE_Subappaltarici").parents("table:first").css({"display": "none"});
				$("#cap_FNZ_UPD_Mandanti").parents("table:first").css({"display": "none"});
				$("#cap_FNZ_UPD_Ausiliarie").parents("table:first").css({"display": "none"});	
				$("#cap_FNZ_UPD_Subappaltarici").parents("table:first").css({"display": "none"});
				$("#cap_PresenzaDGUE_SubAppalto").parents("table:first").css({"display": "none"});
				$("#cap_FNZ_UPD_Subappalto").parents("table:first").css({"display": "none"});
			}catch(e){}
			
		}
		
		if ( getObjValue('SYS_OFFERTA_PRESENZA_ESECUTRICI') == 'NO' )
		{
			$("#cap_PresenzaDGUE_Subappaltarici").parents("table:first").css({"display": "none"});
			$("#cap_FNZ_UPD_Subappaltarici").parents("table:first").css({"display": "none"});	
			
		}
		
		try
		{
			if ( getObjValue('Richiesta_terna_subappalto') == '0' || getObjValue('Richiesta_terna_subappalto') == '' )
			{
				$("#cap_PresenzaDGUE_SubAppalto").parents("table:first").css({"display": "none"});
				$("#cap_FNZ_UPD_Subappalto").parents("table:first").css({"display": "none"});	
				
			}
			
		}catch(e){}
		
	}catch(e){}
	
	try
	{
		if (getObjValue('Divisione_lotti') == '0') 
		{
			//Se la gara � senza lotti nascondo la colonna 'Lotti' all'interno della sezione 'offerte ricevute' 
			ShowCol( 'LISTA_OFFERTE' , 'lottiOfferti' , 'none' );			
		}
	 } 
	 catch (e) 
	 {
	 }
	 
	if ( DOCUMENT_READONLY == '0' )
	{
		setRegExpCIG();
	}

	if (DOCUMENT_READONLY == '0')
	{
		if( getObj('RTESTATA_PRODOTTI_MODEL_EsitoRiga').value.indexOf('State_ERR.gif') >= 0 )			
			document.getElementById('Cell_EsitoRiga').className='Evidenzia_Bordo_Cella';
		
	}
	try
	{
		if (DOCUMENT_READONLY == '0' )
		{	
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
	}catch (e) {}
	onChangeGeneraConvenzione();
	//try{OnChangeSedutaVirtuale();}catch(e){}
	onchange_SetCriteri( 1 );
	
	//GESTIONE ENTE PROPONENTE
	try
	{
		if (DOCUMENT_READONLY == '0' ) 
		{
			filtraRupProponente();
			
		}
	}catch(e){}
	
	
	try{visualizzazione_offerta_tecnica();}catch(e){}
	

	//-- conservo il valore iniziale del criterio attribuzione punteggio per controllare cosa aveva nel caso in cui dovesse cambiare
	gModAttribPunteggio = getObjValue('ModAttribPunteggio') 

	
	try{onChange_Visualizzazione_Offerta_Tecnica('onload');}catch(e){}
	
	try
	{
		if (DOCUMENT_READONLY == '0' ) 
		{
			FilterRiferimenti();
		}
	}catch(e){}
	
	//gestisco i campi per Appalto In Emergenza
    try {
        if (getObjValue('AppaltoInEmergenza') != 'si' && getObj( 'AppaltoInEmergenza' ).type == 'select-one' ) 
		{
            getObj('MotivazioneDiEmergenza').value = '';
            getObj('MotivazioneDiEmergenza').disabled = true;

        }

    } catch (e) {}   
	
	
	//Azione per recuperare il modello selezionato solo se il documento editabile
	//se TipoBandoScelta � vuoto
	//se TipoBando valorizzato allora deduco TipoBandoScelta da TipoBando
	if (DOCUMENT_READONLY == '0' && getObjValue('StatoFunzionale') != 'InApprove' ) 
	{
		
		var strValueTipoBandoScelta ='';
		var strTipoBando = getObjValue('TipoBando');
		
		if ( strTipoBando != '' )
		{
			strValueTipoBandoScelta = ReplaceExtended(strTipoBando, '_' + getObj('IDDOC').value , '');
			//strValueTipoBandoScelta = strValueTipoBandoScelta + 'old';
			
			if ( getObjValue('RTESTATA_PRODOTTI_MODEL_TipoBandoScelta') == '' )
			{ 
					
				
				SetDomValue( 'RTESTATA_PRODOTTI_MODEL_TipoBandoScelta', strValueTipoBandoScelta );
				
				//se cmq vuoto messaggio "il modello precedentemente selezionato non risulta pi� valido".
				//effettuare di nuovo la selezione sulla sezione Prodotti nel campo 
				if ( getObjValue('RTESTATA_PRODOTTI_MODEL_TipoBandoScelta') == '' )
						
					DMessageBox('../', 'il modello precedentemente selezionato non risulta valido.riselezionare nei prodotti', 'Attenzione', 1, 400, 300);

           
			}
		}
		
		
	}
	
	/*Richiamo la on chenge del campo merceologia per precaricare il campo Cetegoria merceologica */
	//onChangeMerceologia(this);
	
	if( ( DOCUMENT_READONLY == '0'  || getObjValue('StatoFunzionale') == 'InApprove' ) && ( getQSParam('COMMAND') != 'PROCESS') )
	{
		//se lo sda di riferimento � chiuso mostro un messaggio att.336345 
		if ( getObjValue('StatoFunzionaleSDA') == 'Chiuso')
		{
			DMessageBox('../', 'Invio non possibile in quanto lo SDA di riferimento risulta "Chiuso"', 'Attenzione', 1, 400, 300);
		}
	}
	
	
	if (DOCUMENT_READONLY == '0' ) 
	{
			
		ActiveDrag();	
		
	}else
	{
		HideColDrag();
	}
	
	
	//nascondo/visualizzo i campi del modulo MODULO_APPALTO_PNRR_PNC	 
	Handle_Attrib_MODULO_APPALTO_PNRR_PNC();	
	
	//Se il documento � editabile e sono visibili setto il filtro sui campi "Stazione Appaltante" e "U. O. Espletante"
	Handle_Attrib_Struttura_Appartenenza ( ) ;
	
	// if( DOCUMENT_READONLY_LOCAL == '0' )
	// {
		// controlliCombinatorieCalcoloAnomalie();
	// }
	
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

function filtraRupProponente()
{
	var filter=''
	var EnteProponente=getObjValue('EnteProponente').split('#')[0];	
	var enteappaltante=getObjValue('Azienda');
	if ( EnteProponente == enteappaltante ) //se coincidono stesso filtro presente sul RUP anche su RUP proponente ed il campo � bloccato
	{
		filter =  'SQL_WHERE=  dmv_cod in (Select DMV_COD from ELENCO_RESPONSABILI where idpfu =  <ID_USER>  and RUOLO in (\'RUP_PDG\') )';
		FilterDom( 'RupProponente' , 'RupProponente' , getObj('val_UserRUP_extraAttrib').value.split('#=#')[1] , filter ,'', '','TD','','');
		//SelectreadOnly( 'RupProponente' , true );
	}
	else
	{
		//SelectreadOnly( 'RupProponente' , false );
		filter =  'SQL_WHERE= dmv_cod in (Select DMV_COD from ELENCO_RESPONSABILI_AZI  where RUOLO in (\'RUP\',\'RUP_PDG\') and idpfu = (select top 1 idpfu from ProfiliUtente where pfuIdAzi=' + EnteProponente + ') )';
		FilterDom( 'RupProponente' , 'RupProponente' , getObj('val_RupProponente_extraAttrib').value.split('#=#')[1] , filter ,'', '');
	}
	
	
}

function onchangeEnteProponente()
{
	filtraRupProponente();
	
	 //Eseguo la funzione per comporre la DDL del centro di costo Proponente
	PCP_CodiceCentroDiCosto("Proponente");
}


function RefreshContent()
{
	//RefreshDocument('');
	ExecDocCommand( 'LISTA_BUSTE#RELOAD' );
}


function CreateBandoSemplificato( objGrid , Row , c )
{
	var cod;
	//-- recupero il codice della riga passata
	cod = GetIdRow( objGrid , Row , 'self' );
	var w = screen.availWidth;
    var h = screen.availHeight;
    
	MakeDocFrom( 'BANDO_SEMPLIFICATO##BANDO_SDA#' + cod + '#');
    
}


function OnChangePrimaSeduta(obj)
{
    try
    {
        if ( getObj('GG_PrimaSeduta').value > 3 ) 
        {
        		DMessageBox( '../' , 'La data di prima seduta viene calcolata sommando il numero di giorni inseriti alla data scadenza offerta' , 'Attenzione' , 1 , 400 , 300 );
        }
    }catch(e){};

}

function OnChangeQuesito(obj)
{
    try
    {
        if ( getObj('RichiestaQuesito').value == '2' ) 
        {
            getObj( 'gg_QuesitiScadenza_V' ).disabled= true;
            SetNumericValue( 'gg_QuesitiScadenza' , 0 );
        }
        else
        {
            getObj( 'gg_QuesitiScadenza_V' ).disabled= false;
        }
    }catch(e){};

}

function OnChangeTipoBando( obj )
{
    //-- aggiorna il modello da usare per la sezione prodotti
    ExecDocProcess( 'SELECT_MODELLO_SDA,BANDO_SDA');
}

function OnClickProdotti( obj )
{
    var DOCUMENT_READONLY = isDocumentReadonly(); //getObj( 'DOCUMENT_READONLY' ).value;
    if ( DOCUMENT_READONLY == "1" )
        DMessageBox( '../' , 'Documento in sola lettura' , 'Attenzione' , 1 , 400 , 300 );
    else
        ImportExcel( 'CAPTION_ROW=yes&TITLE=Upload Excel&TABLE=CTL_Import&FIELD=RTESTATA_PRODOTTI_MODEL_Allegato&SHEET=0&PARAM=posizionale&PROCESS=LOAD_PRODOTTI,BANDO_SEMPLIFICATO&OWNER_FIELD=Idpfu&OPERATION=INSERT#new#600,450' );
}


function LISTA_DOCUMENTI_OnLoad()
{
    OnChangeQuesito();
    
    if (getObj('IDDOC').value.substring(0,3) == 'new' )
	{
		LISTA_DOCUMENTI.location = '../../DASHBOARD/Viewer.asp?TOOLBAR=&Table=BANDO_SDA_LISTA_DOCUMENTI&JSCRIPT=BANDO_SDA&IDENTITY=Id&DOCUMENT=BANDO_SDA&PATHTOOLBAR=../customdoc/&AreaAdd=no&Caption=&Height=0,100*,0&numRowForPag=15&Sort=data&ActiveSel=2&SortOrder=asc&Exit=no&ShowExit=0&FilterHide=IdDoc = 0 ';
	}
	else
	{
		LISTA_DOCUMENTI.location = '../../DASHBOARD/Viewer.asp?TOOLBAR=&Table=BANDO_SDA_LISTA_DOCUMENTI&JSCRIPT=BANDO_SDA&IDENTITY=Id&DOCUMENT=BANDO_SDA&PATHTOOLBAR=../customdoc/&AreaAdd=no&Caption=&Height=0,100*,0&numRowForPag=15&Sort=data&ActiveSel=2&SortOrder=asc&Exit=no&ShowExit=0&FilterHide=LinkedDoc =' + getObj('IDDOC').value ;;	
	}
	
	
}

function DESTINATARI_OnLoad()
{
    DisplaySection();
}

function flagmodifica()
{
	flag=1;
}


function onchangeAppalto_Verde()
{
	try
	{
		if (  getObjValue( 'Appalto_Verde' ) != 'si' )
		{	
			getObj( 'Motivazione_Appalto_Verde').value='';
			getObj( 'Motivazione_Appalto_Verde').disabled=true;
			
		}
	 }catch(e){}  
	try
	{
		if (  getObjValue( 'Appalto_Verde' ) == 'si' )
		 {	
			
			getObj( 'Motivazione_Appalto_Verde').disabled=false;
			
		 }
	}catch(e){}  	
	
}
function onchangeAcquisto_Sociale()
{
	try
	{
		if (  getObjValue( 'Acquisto_Sociale' ) != 'si' )
		 {	
			getObj( 'Motivazione_Acquisto_Sociale').value='';
			getObj( 'Motivazione_Acquisto_Sociale').disabled=true;
			
		 }
	}catch(e){}  		
	try
	{
		if (  getObjValue( 'Acquisto_Sociale' ) == 'si' )
		 {			
			getObj( 'Motivazione_Acquisto_Sociale').disabled=false;
			
		 }
	}catch(e){}  		
	
}

function onchangeGenderEquality()
{
	try
	{
		if (  getObjValue( 'GenderEquality' ) != 'si' )
		 {	
			getObj( 'GenderEqualityMotivazione').value='';
			getObj( 'GenderEqualityMotivazione').disabled=true;
			
		 }
	}catch(e){}  		
	try
	{
		if (  getObjValue( 'GenderEquality' ) == 'si' )
		 {			
			getObj( 'GenderEqualityMotivazione').disabled=false;
			
		 }
	}catch(e){}  		
	
}

function MySend(param,param2,NoProcess) 
{



	var isDocReadOnly = isDocumentReadonly();
	
	
	//Se mi trovo nel giro PCP/Interop e la gara è diventata readonly ( quindi ho fatto una conferma appalto su pcp )
	//	allora non devo fare più questi controlli, sono stati già effettuati dal comando di conferma appalto
	//	e qui avrei troppe incoerenze nel cercare campo editabili che sono passati a readonly ( html differente )
	if ( hasPCP() && isDocReadOnly == '1' )
	{
		//chiamo il processo per INVIO a meno che non richiesto 
		if ( NoProcess == 1 )
			return;
		
		ExecDocProcess(param);
		return;
	}
	
	//se doc editabile ed attiva PCP allora controllo i campi della PCP
	if ( isDocReadOnly == '0' && hasPCP() )
	{  
		if ( PCP_obbligatoryFields(true) == -1  ) 
		{ 
			DMessageBox('../', 'Prima di procedere con il download compilare tutti i campi obbligatori', 'Attenzione', 1, 400, 300);
			return -1;
			
		}
		
		//Eseguo i controlli sul PNRR
		if (!validaDatiSimogPNRR())
		{
			return;
		}
	}

    if (param2 == undefined )
		param2='';
	
	var flag_warning_emergenza='';
	if ( param2 != '' )
	{
		flag_warning_emergenza = param2.split( '@@@' )[1]
	}
	
	var strVersione;
	try 
	{
		strVersione = getObjValue('Versione');
	} 
	catch (e) 
	{
		strVersione = '';
	}
	
	var criterio = getObjValue( 'CriterioAggiudicazioneGara' );
	
	//alert (getObjValue( 'FormulaEcoSDA' ));
	//alert(criterio);
	

	//Per i campi "Termine Richiesta Quesiti", "Termine Presentazione Offerta" e "Data Prima Seduta" se valorizzati controlliamo se l'orario presenti valore vuoto oppure 0
	try
	{
		if ( getObjValue('DataTermineQuesiti') !='')cap_DataScadenzaOfferta
		{
			if (CheckDataOrarioOK('DataTermineQuesiti', 'Indicare un orario per il campo "' + getObj('cap_DataTermineQuesiti').innerHTML + '" diverso da zero') == -1) return -1;
		}
		if ( getObjValue('DataScadenzaOfferta') !='')
		{
			if (CheckDataOrarioOK('DataScadenzaOfferta', 'Indicare un orario per il campo "' + getObj('cap_DataScadenzaOfferta').innerHTML + '" diverso da zero') == -1) return -1;
		}
		if ( getObjValue('DataAperturaOfferte') !='')
		{
			if (CheckDataOrarioOK('DataAperturaOfferte', 'Indicare un orario per il campo "' + getObj('cap_DataAperturaOfferte').innerHTML + '" diverso da zero') == -1) return -1;
		}		
		
	}catch (e){}
	
	
	
	
	
	var dateObj = new Date();
    
	var Riferimento = zero(dateObj.getFullYear(), 4) + '-' + zero((dateObj.getMonth() + 1), 2) + '-' + zero(dateObj.getDate(), 2) ;

	//AGGIUNGO QUESTO CONTROLLO SOLO SE SULLA GARA IL CAMPO AppaltoInEmergena � nascosto
	//Le date del Bando non rispettano i requisiti minimi di distanza tra loro. Se si ci trova in un caso di emergenza premere il tasto �conferma�, altrimenti premere il tasto �Ignora� e controllare le date
	try {

		if ( getObj( 'AppaltoInEmergenza' ).type != 'select-one'  && flag_warning_emergenza != 'no')
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
			
			
			if ( getObjValue('DataScadenzaOfferta') !='' &&  getObjValue('DataScadenzaOfferta').substring(0,10) <= Riferimento ) 
			{
				warning_emergenza=true;
			}
			
			if ( getObjValue('DataAperturaOfferte') !='' &&  getObjValue('DataAperturaOfferte').substring(0,10) <= Riferimento ) 
			{
				warning_emergenza=true;
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
	} catch (e) { };
	
	
	
//--OPERAZIONI che non sono PREZZO ALTO O BASSO controllo che sia stata selezionata se rieseguire i calcoli tecnici con esclusioni automatiche
	if ( criterio != '15531' &&  criterio != '16291')
	{
		//Verifico l'esistenza del campo RicalcolaPerEsclusioni
		if ( getObj('RicalcolaPerEsclusioni') )
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
	}
		
	
	if ( criterio == '15532' || criterio == '25532' ) //coorisponde offerta economica vantaggiosa oppure COSTOFISSO
	{
		var PunteggioEconomico=parseFloat(getObjValue( 'PunteggioEconomico' ));
		var PunteggioTecnico=parseFloat(getObjValue( 'PunteggioTecnico' ));
			if ( criterio == '15532' )
			{
				if ( PunteggioEconomico == 0 || getObjValue( 'PunteggioEconomico_V' ) == '')	
				{
					DocShowFolder( 'FLD_CRITERI' );	   
					tdoc();
					DMessageBox( '../' , 'Digitare un punteggio Economico superiore a 0' , 'Attenzione' , 1 , 400 , 300 );
					getObj('PunteggioEconomico_V').focus();
					return -1;
				}
			}
			if ( PunteggioTecnico == 0 || getObjValue( 'PunteggioTecnico_V' ) == '' )	
			{
				DocShowFolder( 'FLD_CRITERI' );	   
				tdoc();
				DMessageBox( '../' , 'Digitare un punteggio Tecnico superiore a 0' , 'Attenzione' , 1 , 400 , 300 );
				getObj('PunteggioTecnico_V').focus();
				return -1;
			}	
			
			if ( PunteggioEconomico + PunteggioTecnico != 100 )	
			{
				DocShowFolder( 'FLD_CRITERI' );	   
				tdoc();
				DMessageBox( '../' , 'La somma del punteggio tecnico e del punteggio economico deve essere 100' , 'Attenzione' , 1 , 400 , 300 );
				getObj('PunteggioEconomico_V').focus();
				return -1;
			}
			if ( getObjValue( 'PunteggioTecMin' ) != '' &&  getObjValue( 'PunteggioTecMin' ) > PunteggioTecnico )
			{
				DocShowFolder( 'FLD_CRITERI' );	   
				tdoc();
				DMessageBox( '../' , 'La soglia minima del punteggio Tecnico non puo\' essere maggiore del punteggio tecnico' , 'Attenzione' , 1 , 400 , 300 );
				getObj('PunteggioTecMin_V').focus();
				return -1;
			}
		
			//if (getObj('ModalitadiPartecipazione').value != '16307' && strVersione == '') 
			if ( strVersione == '' ) 
			{

				if ( getObjValue( 'FormulaEcoSDA' )== '')
				{
					DocShowFolder( 'FLD_CRITERI' );	   
					tdoc();
					DMessageBox( '../' , 'Nella sezione dei criteri per la valutazione della busta economica selezionare il "Criterio Economica"' , 'Attenzione' , 1 , 400 , 300 );
					getObj('FormulaEcoSDA').focus();
					return -1;
				}	

			}
			
			//solo per le gare diverse da tradizionale
			//if (getObj('ModalitadiPartecipazione').value != '16307' && strVersione == '') 
			if ( strVersione == '' ) 
			{
				if( getObj('FormulaEcoSDA').value.indexOf( ' Coefficiente X ' ) >= 0 )
				{
					if( getObjValue('Coefficiente_X') == '' )
					{
						DocShowFolder( 'FLD_CRITERI' );	   
						tdoc();
						DMessageBox( '../' , 'Nella sezione dei criteri per la valutazione della busta economica selezionare un valore per il campo "Coefficiente X"' , 'Attenzione' , 1 , 400 , 300 );
						getObj('Coefficiente_X').focus();
						return -1;
					}
				}

			}
			
			//controlli sulla griglia
			if( GetProperty( getObj('CRITERIGrid') , 'numrow')==-1)
			{
				DocShowFolder( 'FLD_CRITERI' );	   
				tdoc();
				DMessageBox( '../' , 'Nella griglia Criteri di valutazione busta tecnica deve essere presente almeno una riga.' , 'Attenzione' , 1 , 400 , 300 );
				return -1;
			
			}
			if( GetProperty( getObj('CRITERIGrid') , 'numrow')!=-1)
			{
				var numrighe=GetProperty( getObj('CRITERIGrid') , 'numrow');
				var i=0;
				var k=0;
				var totpunteggiorighe=0;

				for( i = 0 ; i <= numrighe ; i++ )
				{		
					
				    if(getObjValue('RCRITERIGrid_'+i+'_CriterioValutazione') == '')
					{
						DocShowFolder( 'FLD_CRITERI' );	   
						tdoc();
						DMessageBox( '../' , 'Sulla griglia Criteri di valutazione il "Criterio" su ogni riga.' , 'Attenzione' , 1 , 400 , 300 );
						getObj('RCRITERIGrid_'+i+'_CriterioValutazione').focus();
						return -1;	
					}
					if (isNaN(parseFloat(getObjValue('RCRITERIGrid_'+i+'_PunteggioMax'))) || parseFloat(getObjValue('RCRITERIGrid_'+i+'_PunteggioMax')) == 0 )
					{
						DocShowFolder( 'FLD_CRITERI' );	   
						tdoc();
						DMessageBox( '../' , 'Sulla griglia Criteri di valutazione il punteggio per ogni singola riga deve essere maggiore di zero.' , 'Attenzione' , 1 , 400 , 300 );
						getObj('RCRITERIGrid_'+i+'_PunteggioMax_V').focus();
						return -1;	
					}					
					totpunteggiorighe=totpunteggiorighe+parseFloat(getObjValue('RCRITERIGrid_'+i+'_PunteggioMax'));
					if (getObjValue('RCRITERIGrid_'+i+'_DescrizioneCriterio')=='')
					{
						DocShowFolder( 'FLD_CRITERI' );	   
						tdoc();
						DMessageBox( '../' , 'Sulla griglia Criteri di valutazione busta tecnica inserire una descrizione su ogni riga' , 'Attenzione' , 1 , 400 , 300 );
						getObj('RCRITERIGrid_'+i+'_DescrizioneCriterio').focus();
						return -1;
					}
					if(getObjValue('RCRITERIGrid_'+i+'_CriterioValutazione') == 'quiz')
					{
						if(getObjValue('RCRITERIGrid_'+i+'_AttributoCriterio') == '')
						{
							DocShowFolder( 'FLD_CRITERI' );	   
							tdoc();
							DMessageBox( '../' , 'Sulla griglia Criteri di valutazione busta tecnica selezionare un valore per la colonna attributo se il criterio e\' quiz.' , 'Attenzione' , 1 , 400 , 300 );
							getObj('RCRITERIGrid_'+i+'_AttributoCriterio').focus();
							return -1;
						}
						else
						{
							for(k=0;k<i;k++)
							{
								if(getObjValue('RCRITERIGrid_'+k+'_AttributoCriterio') == getObjValue('RCRITERIGrid_'+i+'_AttributoCriterio') )
								{
								DocShowFolder( 'FLD_CRITERI' );	   
								tdoc();
								DMessageBox( '../' , 'Sulla griglia Criteri di valutazione busta tecnica l\'attributo deve essere univoco.' , 'Attenzione' , 1 , 400 , 300 );
								getObj('RCRITERIGrid_'+i+'_AttributoCriterio').focus();
								return -1;	
								}
							}
						}
					}
					
					
				}
				if( PunteggioTecnico != totpunteggiorighe )
				{
					DocShowFolder( 'FLD_CRITERI' );	   
					tdoc();
					DMessageBox( '../' , 'Il Punteggio Tecnico deve essere uguale alla somma dei punteggi presenti sulle righe. ' , 'Attenzione' , 1 , 400 , 300 );
					return -1;
				}
				
				
			
			
			}
			
			
			var numrowlotto=0
			var z=0
			numrowlotto=GetProperty( getObj('LISTA_BUSTEGrid') , 'numrow');
			for(z=0;z<=numrowlotto;z++)
			{
			  //commentato perch� adesso ilpunteggio tecnico potrebbe essere specializzato e la vista ritorna sempre quello del bando 
				//if ( !isNaN(parseFloat(getObjValue('R'+z+'_somma_punt_lotto'))) && parseFloat(getObjValue('R'+z+'_somma_punt_lotto')) != PunteggioTecnico ) 
				
				//Se l'oggetto esiste
				if ( getObj('val_R' + z +'_Criteri_di_valutaz') )
				{
					if ( getObjValue('val_R' + z +'_Criteri_di_valutaz') == 'valutato_err' )
					{
						DocShowFolder( 'FLD_LISTA_LOTTI' );	   
						tdoc();
						DMessageBox( '../' , 'Sono presenti dei lotti con un punteggio sbagliato' , 'Attenzione' , 1 , 400 , 300 );
						return -1;
					}
				}
			}
			
						
			//controllo che siano presenti le motivazioni per un appalto verde oppure per un acquisto sociale
			try
			{
				if ( getObjValue( 'Appalto_Verde' ) == 'si')
				{
					if ( getObjValue( 'Motivazione_Appalto_Verde' ) == '')
					{	
						DocShowFolder( 'FLD_COPERTINA' );	   
						tdoc();
						DMessageBox( '../' , 'Per un bando con "Appalto Verde" indicare una motivazione' , 'Attenzione' , 1 , 400 , 300 );
						getObj('Motivazione_Appalto_Verde').focus();
						return -1;
					}
				}	
			}catch(e){}  
			
			try
			{
				if ( getObjValue( 'Acquisto_Sociale' ) == 'si')
				{
					if ( getObjValue( 'Motivazione_Acquisto_Sociale' ) == '')
					{	
						DocShowFolder( 'FLD_COPERTINA' );	   
						tdoc();
						DMessageBox( '../' , 'Per un bando con "Acquisto_Sociale" indicare una motivazione' , 'Attenzione' , 1 , 400 , 300 );
						getObj('Motivazione_Acquisto_Sociale').focus();
						return -1;
					}
				}	
			}catch(e){}  			
			
			try
			{
				if ( getObjValue( 'GenderEquality' ) == 'si')
				{
					if ( getObjValue( 'GenderEqualityMotivazione' ) == '')
					{	
						DocShowFolder( 'FLD_COPERTINA' );	   
						tdoc();
						DMessageBox( '../' , 'Per un bando con "Gender Equality" indicare una motivazione' , 'Attenzione' , 1 , 400 , 300 );
						getObj('GenderEqualityMotivazione').focus();
						return -1;
					}
				}	
			}catch(e){}  	
			
			
	
		
		if ( criterio == '15532' || criterio == '15531'  || criterio == '16291'  )        
		{	
				//-- controlla le righe delle formule economiche
				if (strVersione != '') 
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

							if (descrCriterioEco == '') MancaValore = 'RCRITERI_ECO_RIGHEGrid_' + i + '_DescrizioneCriterio';
							if (punteggioMaxEco == '') MancaValore = 'RCRITERI_ECO_RIGHEGrid_' + i + '_PunteggioMax';
							if (strFormulaEco == '') MancaValore = 'RCRITERI_ECO_RIGHEGrid_' + i + '_FormulaEcoSDA';
							
							//if (getObjValue('RCRITERI_ECO_RIGHEGrid_' + i + '_AttributoBase') == '') MancaValore = 'RCRITERI_ECO_RIGHEGrid_' + i + '_AttributoBase';
							if (getObjValue('RCRITERI_ECO_RIGHEGrid_' + i + '_AttributoValore') == '') MancaValore = 'RCRITERI_ECO_RIGHEGrid_' + i + '_AttributoValore';
							if (getObjValue('RCRITERI_ECO_RIGHEGrid_' + i + '_CriterioFormulazioneOfferte') == '') MancaValore = 'RCRITERI_ECO_RIGHEGrid_' + i + '_CriterioFormulazioneOfferte';
							if (strFormulaEco.indexOf(' Coefficiente X ') >= 0 && getObjValue('RCRITERI_ECO_RIGHEGrid_' + i + '_Coefficiente_X') == '') MancaValore = 'RCRITERI_ECO_RIGHEGrid_' + i + '_Coefficiente_X';
							if (strFormulaEco.indexOf(' Alfa ') >= 0 && getObjValue('RCRITERI_ECO_RIGHEGrid_' + i + '_Alfa') == '') MancaValore = 'RCRITERI_ECO_RIGHEGrid_' + i + '_Alfa_V';
							
							//-- l'attributo di confronto � necessario se la formula lo prevede
    						if ( getObjValue('RCRITERI_ECO_RIGHEGrid_' + i + '_AttributoBase') == '' 
                                 &&
                                 BaseAstaNecessaria( strFormulaEco , getObjValue('RCRITERI_ECO_RIGHEGrid_' + i + '_CriterioFormulazioneOfferte') )    
                                )
                            { 
                                MancaValore = 'RCRITERI_ECO_RIGHEGrid_' + i + '_AttributoBase';
                            }
						}
							
						if (MancaValore != '') {
							DocShowFolder('FLD_CRITERI');
							tdoc();
							DMessageBox('../', 'Per ogni riga nella griglia "Criteri di valutazione busta economica" e\' necessario compilare tutti i campi', 'Attenzione', 1, 400, 300);
							getObj(MancaValore).focus();
							return -1;
						}

						SommaPunteggiEco += parseFloat(getObjValue('RCRITERI_ECO_RIGHEGrid_' + i + '_PunteggioMax'));


					}

					//--la somma dei punti deve essere uguale al valore di testata
					if ( Math.round( SommaPunteggiEco * 100 ) != Math.round ( parseFloat(getObjValue('PunteggioEconomico')) * 100 ) ) {
						DocShowFolder('FLD_CRITERI');
						tdoc();
						DMessageBox('../', 'Il Punteggio Economico deve essere uguale alla somma dei punteggi presenti sulle righe. ', 'Attenzione', 1, 400, 300);
						return -1;
					}
				}
		}
			
		
	}

	try
	{
		if( getObj('FormulaEcoSDA').value.indexOf( ' Coefficiente X ' ) >= 0 &&  getObj('Coefficiente_X').value == '' && strVersione == '')
		{
			DocShowFolder( 'FLD_CRITERI' );	   
			tdoc();
			DMessageBox( '../' , 'Per la formula selezionata e\' necessario indicare un valore per il Coefficiente X' , 'Attenzione' , 1 , 400 , 300 );
			getObj('Coefficiente_X').focus();
			return -1;
		}
		
	}
	catch(e)
	{
	}

	if( GetProperty( getObj('PRODOTTIGrid') , 'numrow')==-1)
	{
	    DocShowFolder( 'FLD_PRODOTTI' );
		tdoc();
		DMessageBox( '../' , 'Compilare correttamente la sezione dei prodotti' , 'Attenzione' , 1 , 400 , 300 );
		return -1;
	}

	if( GetProperty( getObj('RIFERIMENTIGrid') , 'numrow')==-1)
	{
		
	    DocShowFolder( 'FLD_RIFERIMENTI' );	   
		tdoc();
		DMessageBox( '../' , 'Compilare correttamente la sezione dei Riferimenti' , 'Attenzione' , 1 , 400 , 300 );
		return -1;
	}	

    if( getObjValue( 'UserRUP' ) == '' )
	{
		DMessageBox( '../' , 'Compilare il campo R.U.P.' , 'Attenzione' , 1 , 400 , 300 );
		getObj( 'UserRUP' ).focus();
		return -1;
	
	}
	
	var tmpCalcoloAnomalia = getObjValue('CalcoloAnomalia');
	var tmpCriterioAggiudicazione = getObjValue('CriterioAggiudicazioneGara');

	try
	{
		
		/* se la gara � economicamente vantaggiosa e si � scelto "Calcolo Anomalia" = 'si' 
			ed i campi ModalitaAnomalia_TEC e ModalitaAnomalia_ECO sono presenti sul modello */
		if ( ( tmpCriterioAggiudicazione == '15532' || tmpCriterioAggiudicazione == '25532' ) && tmpCalcoloAnomalia == '1' )
		{
			if ( getObj('ModalitaAnomalia_TEC') )
			{
				if ( getObjValue('ModalitaAnomalia_TEC') == '' || getObjValue('ModalitaAnomalia_ECO') == '')
				{
					DMessageBox('../', 'Compilare i campi \'Modalit� di calcolo PT\' e \'Modalit� calcolo PE\'', 'Attenzione', 1, 400, 300);
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
	
	//-- verifico una incompatibilit� dei punteggi sulle righe dei criteri
	if ( CheckCriteriPunteggi() == -1 ){
		DMessageBox( '../' , 'Verificare i punteggi dei criteri oggettivi, sono presenti domini o range con valori superiori rispetto al punteggio del criterio' , 'Attenzione' , 1 , 400 , 300 );
		return -1;
	}
	
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
	
	//SE NON RICHIESTO NON INNESCO INVIO CON IL PROCESSO
	if ( NoProcess == 1 )
		return 1;
	
  	//invio il documento con processo server
	ExecDocProcess(param);
}

function OpenSeduta(objGrid , Row , c) 
{
    var cod = getObj( 'R' + Row + '_idSeduta').value;

    GridSecOpenDoc(objGrid , Row , c) 
    
}

function ChangeImpAppalto( obj )
{
    var Oneri = Number( getObj( 'Oneri' ).value ) ;
    var importoBaseAsta2 = Number( getObj( 'importoBaseAsta2' ).value ) ;

	var impTotal = Oneri + importoBaseAsta2;
	
	if ( getObj( 'Opzioni' ) )
	{
		var opzioni = Number( getObj( 'Opzioni' ).value ) ;
		impTotal = impTotal + opzioni;
	}
	
	var ulterioriSomme;
	var sommeRipetizioni;

	try
	{
		ulterioriSomme = Number( getObj( 'pcp_UlterioriSommeNoRibasso' ).value );
		sommeRipetizioni = Number( getObj( 'pcp_SommeRipetizioni' ).value );

		impTotal = impTotal + ulterioriSomme + sommeRipetizioni;
	}
	catch(e)
	{
	}
    
    SetNumericValue( 'importoBaseAsta' , impTotal );
}

function DisplaySection(obj)
{
    var crit = getObjValue('CriterioAggiudicazioneGara');
    var conf = getObjValue('Conformita');

    //--  nel caso di economicamente vantaggiosa si filtra la conformit�
    var Conformita = getObj('Conformita');
   
    
    var strVersione;

    try {  ShowCol( 'CRITERI' , 'Eredita' , 'none' );  } catch (e) {};

	
	try { SetCostoFisso(); } catch (e) {};
	
	
    try {
        strVersione = getObjValue('Versione');
    } catch (e) {
        strVersione = '';
    }
	
	
    if (strVersione == '')
	{
        try {
            setVisibility(getObj('CRITERI_ECO_TESTATA'), 'none');
        } catch (e) {}
        try {
            setVisibility(getObj('CRITERI_ECO_RIGHE'), 'none');
        } catch (e) {}
    }
	else 
	{
        try 
		{
            getObj('BANDO_SEMPLIFICATO_CRITERI_ECO').rows[3].style.display = 'none';
            getObj('BANDO_SEMPLIFICATO_CRITERI_ECO').rows[4].style.display = 'none';
            getObj('BANDO_SEMPLIFICATO_CRITERI_ECO').rows[5].style.display = 'none';
            getObj('BANDO_SEMPLIFICATO_CRITERI_ECO').rows[6].style.display = 'none';
        } catch (e) {}
    }

	//--  nel caso di economicamente vantaggiosa si filtra la conformit�
            
    if( crit == '15532' || crit == '25532' ) //OEV oppure costo fisso
    {
        DocDisplayFolder(  'CRITERI'   ,'' );
        //commentata in quanto per le gare miste ci deve essere sempre
        //try{ShowCol( 'LISTA_BUSTE' , 'FNZ_CONTROLLI'  , '' );}catch(e){};
		
		//if ( getObj('DOCUMENT_READONLY').value == '0' ){
		if ( isDocumentReadonly() == '0' ){
			
			Conformita.value = 'No' ;
			//Conformita.disabled = true;
			SelectreadOnly('Conformita',true);
		}	
		
    }
    else
    {
       // DocDisplayFolder(  'CRITERI'   ,'none' );
        //commentata in quanto per le gare miste ci deve essere sempre
        //try{ShowCol( 'LISTA_BUSTE' , 'FNZ_CONTROLLI'  , 'none' );}catch(e){};

        //Conformita.disabled = false;
		if ( isDocumentReadonly() == '0' ){
			
			SelectreadOnly('Conformita',false);
			
		}
    }
	
	  //SE OEPV 
	
	
	
		
  	if ( crit == '15532' || crit == '25532' && isDocumentReadonly() == '0' ) //OEV oppure costo fisso
  	{
		//Se c'�
		if ( getObj('CriterioFormulazioneOfferte') )
		{
		
			if ( getObjValue('CriterioFormulazioneOfferte') == '15537' )
			{
				filter ='SQL_WHERE= CategorieUSO like \'%,sconto,%\' ';
			}
			if ( getObjValue('CriterioFormulazioneOfferte') == '15536' )
			{
				filter ='SQL_WHERE= CategorieUSO like \'%,prezzo,%\' ';
			}
			
			try
			{
				FilterDom( 'FormulaEcoSDA' , 'FormulaEcoSDA' , getObjValue('FormulaEcoSDA') , filter , ''  , 'OnChangeFormula( this );flagmodifica();');
			}
			catch(e){}
			
			try
			{
				FilterDom( 'OffAnomale' , 'OffAnomale' , getObjValue('OffAnomale') , 'SQL_WHERE= tdrcodice = \'16310\' ' , ''  , '');	
			}
			catch(e){}

		}
  	}
	
	
	//SE NON OEPV e non � costo fisso
	if ( crit != '15532' &&  crit != '25532' && isDocumentReadonly() == '0' )
	{
		FilterDom( 'OffAnomale' , 'OffAnomale' , getObjValue('OffAnomale') , '' , ''  , '');
	}
	
	//SE PREZZO + BASSO calcoloanomalia a no bloccato
	/*var objCalcoloAnomalia = getObj('CalcoloAnomalia');
	if ( crit == '15531' )
	{
	 
		objCalcoloAnomalia.value = '0' ;
    SelectreadOnly('CalcoloAnomalia',true);
    
	}else{
    
    SelectreadOnly('CalcoloAnomalia',false);*/
  
  //}
	
    
    
	
	verifyModalitaDiCalcoloAnomalia();
	
	
	
	
}

function DownLoadCSV()
{

    var TipoBando = getObjValue( 'TipoBando' );
    //var LinkedDoc = getObjValue( 'LinkedDoc' );
    
    //ExecFunction('../../Report/CSV_LOTTI.asp?IDDOC=' + LinkedDoc + '&TIPODOC=BANDO_SDA&MODEL=MODELLI_LOTTI_' + TipoBando + '_MOD_BandoSempl' );
	
	var TipoBando = getObjValue('TipoBando');

    if (TipoBando == '') {
        alert(CNV('../', 'E\' necessario selezionare prima il modello'));
        return;
    }
	
	var HIDECOL='ESITORIGA';
	var prsenzaModuloAmpiezzaGamma = '';

	try { prsenzaModuloAmpiezzaGamma = getObj('PresenzaModuloAmpiezzaGamma').value;} catch (error) { }
	
	if (prsenzaModuloAmpiezzaGamma == 'si') 
	{
		try 
		{
		  var presenzaampiezzaGamma = getObj('PresenzaAmpiezzaDiGamma').value;
		  
		  if ( presenzaampiezzaGamma == 'si' ) 
		  {
			HIDECOL= HIDECOL;
		  } else 
		  {
			HIDECOL= HIDECOL + ',AmpiezzaGamma';
		  }
		}
		catch
		{

		}
	}
	else 
	{
		HIDECOL= HIDECOL + ',AmpiezzaGamma';
	}
	
	ExecFunction('../../Report/CSV_LOTTI.asp?IDDOC=' + getObjValue('IDDOC')  + '&TIPODOC=BANDO_SEMPLIFICATO&MODEL=MODELLI_LOTTI_' + TipoBando + '_MOD_BandoSempl&HIDECOL=' + HIDECOL );
     
}


function OpenEconomica(objGrid , Row , c) 
{
    var cod = getObj( 'R' + Row + '_id').value;

    ShowDocumentPath( 'BANDO_SEMP_OFF_ECO' , cod ,'../');
    
}

function OpenTecnica(objGrid , Row , c) 
{
    var cod = getObj( 'R' + Row + '_id').value;

    ShowDocumentPath( 'BANDO_SEMP_OFF_TEC' , cod ,'../');
    
}

function OpenCriteri(objGrid , Row , c) 
{
    if( flag == 1 )
	{
			if( confirm(CNV( '../','Sono state effettuare delle modifiche al documento prima di procedere e richiesto un salvataggio.Vuoi procedere?')))
			{
			SaveDoc();
			return;
			}
			else return -1;
	}
	var cod = getObj( 'R' + Row + '_id').value;
  
  //aggiungo al cod il command per forzare il reload
  
    if ( isSingleWin() == true ) 
    {
        ReloadDocFromDB( cod , 'BANDO_SEMP_OFF_EVAL' );
        ShowDocument( 'BANDO_SEMP_OFF_EVAL' , cod  );
    }
    else
    {
        ReloadDocFromDB( cod , 'BANDO_SEMP_OFF_EVAL' );
        ShowDocumentPath( 'BANDO_SEMP_OFF_EVAL' , cod ,'../');
    }

    
}

function EditCriterio(objGrid, Row, c) 
{
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
            Open_Quiz('../', 'RCRITERIGrid_' + Row + '_Formula', 'C', getObjValue('RCRITERIGrid_' + Row + '_DescrizioneCriterio'), TipoGiudizioTecnico, 'RCRITERIGrid_' + Row + '_AttributoCriterio' , PunteggioMax) ;
        } else {
            Open_Quiz('../', 'RCRITERIGrid_' + Row + '_Formula', 'V', getObjValue('RCRITERIGrid_' + Row + '_DescrizioneCriterio'), TipoGiudizioTecnico, 'RCRITERIGrid_' + Row + '_AttributoCriterio' , PunteggioMax);
        }

    }

}

function CRITERI_OnLoad()
{
/*
    FilterDominio();

	//--filtro il dominio Conformita in funzione dei criteri espressi sul modello selezionato
    FilterDom(  'Conformita' , 'Conformita' , getObjValue( 'Conformita' ), 'SQL_WHERE= DMV_COD in ( select Conformita  from VIEW_FILTER_CONFORMITA_BANDO_SEMPLIFICATO where Codice =  \'' + getObjValue( 'TipoBando' ) + '\' ) ' , '' , '')

    //-- abilito il coefficiente X in funzione della formula
    OnChangeFormula(this);
*/
}

function CRITERI_AFTER_COMMAND( param )
{
    FilterDominio();
	OnChange_Riparametrazione();
	onChange_Visualizzazione_Offerta_Tecnica();
}

function OnChangeCriterio( obj )
{

	var DOCUMENT_READONLY = isDocumentReadonly(); //getObj('DOCUMENT_READONLY').value;

    var i = obj.id.split('_');

    //FilterDom(  'RCRITERIGrid_' + i[1] + '_AttributoCriterio' , 'AttributoCriterio' , getObjValue( 'RCRITERIGrid_' + i[1] + '_AttributoCriterio' ), 'SQL_WHERE= TipoBando = \'' + getObjValue( 'TipoBando' ) + '\' and DZT_NAME = \'MOD_OffertaTec\' and DZT_Type not in ( 18 ) ' , 'CRITERIGrid_' + i[1]  , '')

    if( getObjValue(  'RCRITERIGrid_' + i[1] + '_CriterioValutazione' ) == 'quiz' )
    {
          setVisibility( getObj( 'RCRITERIGrid_' + i[1] + '_AttributoCriterio' ) , '' );
          setVisibility( getObj( 'RCRITERIGrid_' + i[1] + '_FNZ_OPEN' ) , '' );   
		  setVisibility(getObj('RCRITERIGrid_' + i[1] + '_Allegati_da_oscurare_edit_new'), '');
		  setVisibility(getObj('RCRITERIGrid_' + i[1] + '_Allegati_da_oscurare_button'), '');

          try{ 
            
            //getObj( 'RCRITERIGrid_' + i[1] + '_PunteggioMax_V' ).disabled = true; 
            
            //disabilito il punteggio solo se la tipologia di giudizio � a dominio 
            var TipoGiudizioTecnico  ='';
            
            try{
              var TipoGiudizioTecnico  = getObj( 'TipoGiudizioTecnico').value;
            }catch(e){};
            
            if ( TipoGiudizioTecnico != 'domain')
              getObj( 'RCRITERIGrid_' + i[1] + '_PunteggioMax_V' ).disabled = true; 
            
            
          }catch(e){};

		AggiornaCriteriTecnici( 'RCRITERIGrid_' + i[1] + '_Formula' , '' , '' );

		//Se il documento � editabile
		if (DOCUMENT_READONLY == '0') 
		{
			//FilterDom(  'RCRITERIGrid_' + i[1] + '_AttributoCriterio' , 'AttributoCriterio' , getObjValue( 'RCRITERIGrid_' + i[1] + '_CampoTesto_1' ), 'SQL_WHERE= TipoBando = \'' + getObjValue( 'TipoBando' ) + '\' and DZT_NAME = \'MOD_OffertaTec\' and DZT_Type not in ( 18,4,5,8 ) ' , 'CRITERIGrid_' + i[1]  , '')
			FilterDom(  'RCRITERIGrid_' + i[1] + '_AttributoCriterio' , 'AttributoCriterio' , getObjValue( 'RCRITERIGrid_' + i[1] + '_CampoTesto_1' ), 'SQL_WHERE= TipoBando = \'' + getObjValue( 'TipoBando' ) + '\' and DZT_NAME = \'MOD_OffertaTec\' and DZT_Type not in ( 18,5,8 ) ' , 'CRITERIGrid_' + i[1]  , '')
			
			//SE SIAMO SULLE 2 fasifaccio il filtro sull'attributo altrimenti la colonna non � visibile
			if ( getObjValue('Visualizzazione_Offerta_Tecnica')  == 'due_fasi' )
			{										
				var filtro='';
				filtro= 'SQL_WHERE= TipoBando = \'' + getObjValue('TipoBando') + '\' and DZT_NAME = \'MOD_OffertaTec\' and DZT_Type  in ( 18 )' ;
				SetProperty( getObj('RCRITERIGrid_' + i[1] + '_Allegati_da_oscurare'),'filter',filtro);							

			}
		}
		
    }
    else
    {
          setVisibility( getObj( 'RCRITERIGrid_' + i[1] + '_AttributoCriterio' ) , 'none' );
          setVisibility( getObj( 'RCRITERIGrid_' + i[1] + '_FNZ_OPEN' ) , 'none' );
		  setVisibility(getObj('RCRITERIGrid_' + i[1] + '_Allegati_da_oscurare_edit_new'), 'none');
		  setVisibility(getObj('RCRITERIGrid_' + i[1] + '_Allegati_da_oscurare_button'), 'none');
          
          try{ 
            getObj( 'RCRITERIGrid_' + i[1] + '_PunteggioMax_V' ).disabled = false; 
          }catch(e){};


    }
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
			DOCUMENT_READONLY = isDocumentReadonly() ; //getObj('DOCUMENT_READONLY').value;
		}
	}
	catch(e)
	{
	}

    try {

        var statFunz;
        var statFunzVal;

        try {
            //Se FilterDominio() viene chiamato dall'iframe dei comandi non avremo il campo statoFunzionale.
            //quindi assumo un default 'InLavorazione'
            statFunz = getObj('StatoFunzionale').value;
        } catch (e) {
            statFunz = 'InLavorazione';
        }


        for (i = 0; i < n && getObj('RCRITERIGrid_' + i + '_CriterioValutazione') != null; i++) {
            if ( DOCUMENT_READONLY == '0' && getObjValue('RCRITERIGrid_' + i + '_CriterioValutazione') == 'quiz') {
                //FilterDom('RCRITERIGrid_' + i + '_AttributoCriterio', 'AttributoCriterio', getObjValue('RCRITERIGrid_' + i + '_CampoTesto_1'), 'SQL_WHERE= TipoBando = \'' + getObjValue('TipoBando') + '\' and DZT_NAME = \'MOD_OffertaTec\' and DZT_Type not in ( 18,4,5,8 )  ', 'CRITERIGrid_' + i, '')
                FilterDom('RCRITERIGrid_' + i + '_AttributoCriterio', 'AttributoCriterio', getObjValue('RCRITERIGrid_' + i + '_CampoTesto_1'), 'SQL_WHERE= TipoBando = \'' + getObjValue('TipoBando') + '\' and DZT_NAME = \'MOD_OffertaTec\' and DZT_Type not in ( 18,5,8 )  ', 'CRITERIGrid_' + i, '')
				
				//SE SIAMO SULLE 2 fasifaccio il filtro sull'attributo altrimenti la colonna non � visibile
				if ( getObjValue('Visualizzazione_Offerta_Tecnica')  == 'due_fasi' )
				{										
					var filtro='';
					filtro= 'SQL_WHERE= TipoBando = \'' + getObjValue('TipoBando') + '\' and DZT_NAME = \'MOD_OffertaTec\' and DZT_Type  in ( 18 )' ;
					SetProperty( getObj('RCRITERIGrid_' + i + '_Allegati_da_oscurare'),'filter',filtro);							

				}
            }

            if (getObjValue('RCRITERIGrid_' + i + '_CriterioValutazione') == 'quiz') {
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
            } else {
                try {setVisibility(getObj('RCRITERIGrid_' + i + '_AttributoCriterio'), 'none');} catch (e) {};
				try {setVisibility(getObj('RCRITERIGrid_' + i + '_Allegati_da_oscurare_edit_new'), 'none');} catch (e) {};
				try {setVisibility(getObj('RCRITERIGrid_' + i + '_Allegati_da_oscurare_button'), 'none');} catch (e) {};
				try {setVisibility(getObj('RCRITERIGrid_' + i + '_Allegati_da_oscurare_label'), 'none');} catch (e) {};
                setVisibility(getObj('RCRITERIGrid_' + i + '_FNZ_OPEN'), 'none');

            }

        }

    } catch (e) {
        //alert( 'error ' + e);
    }


    var strVersione;
    try {
        strVersione = getObjValue('Versione');
    } catch (e) {
        strVersione = '';
    }


    if (strVersione != '' && DOCUMENT_READONLY == '0') 
	{

        try {


            var filter;

            for (i = 0; i < n && getObj('RCRITERI_ECO_RIGHEGrid_' + i + '_DescrizioneCriterio') != null; i++) 
			{
				FilterDom('RCRITERI_ECO_RIGHEGrid_' + i + '_AttributoBase', 'AttributoBase', getObjValue('RCRITERI_ECO_RIGHEGrid_' + i + '_CampoTesto_1'), 'SQL_WHERE= TipoBando = \'' + getObjValue('TipoBando') + '\' and DZT_NAME = \'MOD_BandoSempl\' and DZT_Type in ( 2 ) ', 'CRITERI_ECO_RIGHEGrid_' + i, '');
				FilterDom('RCRITERI_ECO_RIGHEGrid_' + i + '_AttributoValore', 'AttributoValore', getObjValue('RCRITERI_ECO_RIGHEGrid_' + i + '_CampoTesto_2'), 'SQL_WHERE= TipoBando = \'' + getObjValue('TipoBando') + '\' and DZT_NAME = \'MOD_Offerta\' and DZT_Type in ( 2 ) ', 'CRITERI_ECO_RIGHEGrid_' + i, '');

				if ( isDocumentReadonly() == '0')
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
            alert('error FilterDominio:' + e);
        }

    }

}
/*
function SetCriterioFormulazioneOfferteRow( i )
{
	var filter;
	var CVO = getObjValue('RCRITERI_ECO_RIGHEGrid_' + i +'_CriterioFormulazioneOfferte') ;

	if ( CVO == '15537') {
		filter = 'SQL_WHERE= CategorieUSO like \'%,sconto,%\' ';
	}
	if ( CVO == '15536') {
		filter = 'SQL_WHERE= CategorieUSO like \'%,prezzo,%\' ';
	}

	FilterDom('RCRITERI_ECO_RIGHEGrid_' + i + '_FormulaEcoSDA', 'FormulaEcoSDA', getObjValue('RCRITERI_ECO_RIGHEGrid_' + i + '_FormulaEcoSDA'), filter, 'CRITERI_ECO_RIGHEGrid_' + i, 'OnChangeFormula( this , \'RCRITERI_ECO_RIGHEGrid_' + i + '_\' );flagmodifica();');
	OnChangeFormula(this, 'RCRITERI_ECO_RIGHEGrid_' + i + '_');

}
*/
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
		//alert(strFormula);
		
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
	
	
			//if ( getObjValue( 'Versione' ) == '' )
			{
				if ( strFormula.indexOf(' Coefficiente X ') >= 0) {
					getObj(Row + 'Coefficiente_X').style.display = '';
					try {
						getObj('cap_Coefficiente_X').style.display = '';
					} catch (e) {}

				} else {

					getObj(Row + 'Coefficiente_X').style.display = 'none';
					try {
						getObj(Row + 'cap_Coefficiente_X').style.display = 'none';
					} catch (e) {}
					getObj(Row + 'Coefficiente_X').value = '';

				}
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

    } catch (e) {}


}


//-- determino il punteggio massimo del criterio oggettivo
function AggiornaCriteriTecnici( strField , p1 , p2 )
{
    var obj = getObj( strField );
    var R = strField.split( '_' );
    var M = 0;
    var i;

    try{    
        var v = obj.value.split( '#=#' )[2].split( '#~#' )
    var l = v.length;
        for( i = 3 ; i < l ; i += 4 )
        {
            if( Number( v[i] ) > M ) M = Number( v[i] ) ;
        }
    }catch(e){};
    //aggiorno il punteggio solo se tipogiudiziotecnico � edit
    var TipoGiudizioTecnico  ='';
    try{
      var TipoGiudizioTecnico  = getObj( 'TipoGiudizioTecnico').value;
    }catch(e){};
    if ( TipoGiudizioTecnico != 'domain')
      SetNumericValue( R[0] + '_' + R[1] + '_PunteggioMax' , M );


}
//aggiorna il tipoBando se cambia questo valore
function onChangeComplesso()
{
	var numeroRighe=0;
	var TipoBando = getObjValue( 'TipoBando' );
	var Complex = getObjValue( 'Complex' );
	try{ numeroRighe = GetProperty( getObj('PRODOTTIGrid') , 'numrow');}catch(e){numeroRighe=-1};
	
	try
	{
		if( Complex == '1')  //1=si 0=no
		{
			//se ci sono righe nella sezione prodotti chiamo il processo per svuotarla
			if ( numeroRighe > -1 )
			{
				if( confirm(CNV( '../','Attenzione proseguendo con l\'operazione si sta per svuotare nella sezione \"Lotti\" l\'elelenco dei prodotti. Sei sicuro?')) ) 
				{
					getObj( 'TipoBando' ).value=TipoBando + '_COMPLEX';
					//Chiamo il processo per far svuotare i prodotti e caricare il nuovo tipoBando
					ExecDocProcess( 'CHANGE_COMPLEX,BANDO_SEMPLIFICATO');
				}
			}
			else
			{
				getObj( 'TipoBando' ).value=TipoBando + '_COMPLEX';
				//Chiamo il processo per far svuotare i prodotti e caricare il nuovo tipoBando
				ExecDocProcess( 'CHANGE_COMPLEX,BANDO_SEMPLIFICATO');
			}
		}
		
		if( Complex == '0')
		{
			//se ci sono righe nella sezione prodotti chiamo il processo per svuotarla
			if ( numeroRighe > -1 )
			{
				if( confirm(CNV( '../','Attenzione proseguendo con l\'operazione si sta per svuotare nella sezione \"Lotti\" l\'elelenco dei prodotti. Sei sicuro?')) ) 
				{
					//toglie _COMPLEX dal tipoBando
					if( TipoBando.substr(TipoBando.length - 8)=='_COMPLEX' )
					getObj( 'TipoBando' ).value=TipoBando.substr(0,TipoBando.length - 8);
					//Chiamo il processo per far svuotare i prodotti e caricare il nuovo tipoBando
					ExecDocProcess( 'CHANGE_COMPLEX,BANDO_SEMPLIFICATO');
				}
			}
			else
			{	
				//toglie _COMPLEX dal tipoBando
				if( TipoBando.substr(TipoBando.length - 8)=='_COMPLEX' )
				getObj( 'TipoBando' ).value=TipoBando.substr(0,TipoBando.length - 8);
				//Chiamo il processo per far svuotare i prodotti e caricare il nuovo tipoBando
				ExecDocProcess( 'CHANGE_COMPLEX,BANDO_SEMPLIFICATO');
				
			}		
					
		}
		
	}catch(e){};
	
}

//-- 0 -- no
//-- 1 -- Dopo la soglia di sbarramento
//-- 2 -- Prima della soglia di sbarramento
function OnChange_Riparametrazione( obj )
{
    try{
        if( getObjValue( 'PunteggioTEC_100' ) <= '0' )
        {
            //-- se non viene chiesta la riparametrazione si nasconde il criterio    
            setVisibility( getObj( 'PunteggioTEC_TipoRip' ), 'none' );
            setVisibility( getObj( 'cap_PunteggioTEC_TipoRip' ), 'none' );
        
            ShowCol( 'CRITERI' , 'Riparametra' , 'none' );
        }
        else
        {
            setVisibility( getObj( 'PunteggioTEC_TipoRip' ), '' );
            setVisibility( getObj( 'cap_PunteggioTEC_TipoRip' ), '' );
            if( getObjValue( 'PunteggioTEC_TipoRip' ) < 1  )
            {
                getObj( 'PunteggioTEC_TipoRip' ).value = '1';
            }
			
			if ( getObj( 'PunteggioTEC_TipoRip' ).value == '1' )
				ShowCol( 'CRITERI' , 'Riparametra' , 'none' );
			else
				ShowCol( 'CRITERI' , 'Riparametra' , '' );
        }
    }catch(e){};    
}

//-- 1 - Riparametro per punteggio Lotto
//-- 2 - Riparametro per punteggio parametro
//-- 3 - Riparametro per punteggio parametro e per punteggio Lotto
function OnChange_RiparametrazioneCriterio( obj )
{
    if( getObjValue( 'PunteggioTEC_TipoRip' ) < 1 )
    {
        getObj( 'PunteggioTEC_TipoRip' ).value = '1';
    }

	if ( getObj( 'PunteggioTEC_TipoRip' ).value == '1' )
		ShowCol( 'CRITERI' , 'Riparametra' , 'none' );
	else
		ShowCol( 'CRITERI' , 'Riparametra' , '' );
	
}



function AddProdotto( )
{
  
  //alert('addprodotto');
  
	var strCommand = 'PRODOTTI#ADDFROM#IDROW=' + getObjValue( 'IDDOC' ) + '&TABLEFROMADD=DOCUMENT_ADD_PRODOTTO' 

	ExecDocCommand( strCommand );

}




//mi fa aggiungere righe prodotti dello sda al bando senmplificato
function Bando_Semplificato_Sec_Dettagli_AddRow(objGrid , Row , c){
  
  var idRow;
  var DOC_TO_UPD=getQSParam('doc_to_upd');
  
	//-- recupera il codice delle righe selezionate
	//idRow = Grid_GetIdSelectedRow( 'GridViewer' );
	
	idRow = GetIdRow( objGrid , Row , 'self' );
			
	var parametri =  'PRODOTTI#ADDFROM#IDROW=' + idRow + '&IDDOC='+ DOC_TO_UPD +'&RESPONSE_ESITO=YES&TABLEFROMADD=DASHBOARD_VIEW_PRODOTTI_SDA&DOCUMENT=BANDO_SEMPLIFICATO';
		
	Viewer_Dettagli_AddSel( parametri);				
	  
}



//mi fa aggiungere righe prodotti dello sda al bando senmplificato
function AggiungiProdotti()
{
  
	var idRow;
	var DOC_TO_UPD=getQSParam('doc_to_upd');

	//-- recupera il codice delle righe selezionate
	idRow = Grid_GetIdSelectedRow( 'GridViewer' );
	
	if( idRow == '' )
	{
	  DMessageBox( '../' , 'E\' necessario selezionare prima una riga' , 'Attenzione' , 2 , 400 , 300 );  
	}
	else
	{		
		var parametri =  'PRODOTTI#ADDFROM#IDROW=' + idRow + '&IDDOC='+ DOC_TO_UPD +'&RESPONSE_ESITO=YES&TABLEFROMADD=DASHBOARD_VIEW_PRODOTTI_SDA&DOCUMENT=BANDO_SEMPLIFICATO';
		
		Viewer_Dettagli_AddSel( parametri);				
		
	}  
}

function CheckCoerenzaTermine( objfield ){

  //alert( objfield.name );
  
  if ( objfield.name == 'gg_QuesitiScadenza_V') {
    
    //se ho imputato numero giorni svuoto DataTermineQuesiti
    if (objfield.value != 0){
      
      getObj('DataTermineQuesiti_V').value = '';
      ck_VD( getObj('DataTermineQuesiti_V') );
      
    }
    
  }else{
    
    //se ho imputato DataTermineQuesiti svuoto gg_QuesitiScadenza
    if (objfield.value != '' ){
      
      getObj('gg_QuesitiScadenza').value = '';
      getObj('gg_QuesitiScadenza_V').value = '';
      
      //chiamo la funzione per controllo data utile
      GetDataUtile ( '', objfield , '' );
       
    }
  }

}


function UpdateModelloBando()
{
    var TipoBando = getObjValue( 'TipoBando' );
	var cod=getObjValue( 'id_modello' );
    var docReadonly = isDocumentReadonly();//getObjValue( 'DOCUMENT_READONLY' );

    if ( TipoBando == '' || cod == '' )
    {
      DMessageBox( '../' , 'E\' necessario selezionare prima il modello' , 'Attenzione' , 1 , 400 , 300 );
	  return;
    }
	
	//Se il documento non � readonly e ci sono state delle modifiche l'apertura del documento CONFIG_MODELLI_LOTTI la posticipiamo al reload del documento, nell'after process
    if (docReadonly == '1' || ( typeof (FLAG_CHANGE_DOCUMENT) != "undefined" && FLAG_CHANGE_DOCUMENT != 1) )
        ShowDocumentPath('CONFIG_MODELLI_LOTTI', cod, '../');
    else		
		ExecDocProcess('FITTIZIO,DOCUMENT,,NO_MSG');
	
}

//per nascondere il contenuto della colonna Busta Tecnica per quei lotti che non ne hanno bisogno
function HideBustaTecnicaLotti(){

  //-- divisione_lotti <> 0 non � monolotto 
    var numrowlotto=-1;
    
    try{
        if ( getObjValue( 'Divisione_lotti' ) != '0' )
            numrowlotto=GetProperty( getObj('LISTA_BUSTEGrid') , 'numrow');
  	}
  	catch( e ) {}
  		
  	
    	
    for(z=0;z<=numrowlotto;z++)
    {
      if ( getObjValue('R' + z + '_PresenzaBustaTecnica') == '0' )
    	{
    		
    		getObj('LISTA_BUSTEGrid_r'+ z + '_c3').innerHTML='';
    		
    	}
    }

}


function ChangeFormulaEcoLotto( obj ){
  
/* -- � oboleto i criteri sono diventati multipli e quindi irrilevante
  var strValueCFO=obj.value;
  
  if( confirm(CNV( pathRoot ,'Se continui verranno modificate le specializzazioni dei Criteri fatte sui lotti. Sei sicuro?')) ){
    
    //innesco processo per modificare le specializzazioni sui lotti
    ExecDocProcess( 'AGGIORNA_FORMULA_LOTTO,BANDO_SEMPLIFICATO,,NO_MSG');
    //alert('')
    
  }else{
    
    if ( strValueCFO == '15536')
      obj.value = '15537';
    else
      obj.value = '15536';
  }
    
*/ 


}

function CRITERI_ECO_RIGHE_AFTER_COMMAND(param) 
{
    FilterDominio();
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
		var parametri =  'PRODOTTI#ADDFROM#IDROW=' + idRow + '&IDDOC='+ DOC_TO_UPD +'&RESPONSE_ESITO=YES&TABLEFROMADD=DASHBOARD_VIEW_ELENCO_CODIFICHE_META_PRODOTTI_ADDTO_BANDO_SEMPLIFICATO&DOCUMENT=BANDO_SEMPLIFICATO';
		Viewer_Dettagli_AddSel( parametri);				
		
	}  
}
function cercaperambito(tipoProd)
{
	//var ambito = getObjValue('MacroAreaMerc');
	//var ambito = getObjValue('Ambito');
	var ambito = getObjValue('RTESTATA_PRODOTTI_MODEL_Ambito');
	
	
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

function afterProcess( param )
{
	//if ( param == 'SELECT_MODELLO_BANDO' )
    //{
    //    OnLoadPage();
    //}

	if ( param == 'SAVE_DOC' )
	{
		ElabAIC();  
	}
	
	if ( param == 'FITTIZIO' )
    {
		var cod=getObjValue( 'id_modello' );
		ShowDocumentPath( 'CONFIG_MODELLI_LOTTI' , cod ,'../');
	}
	
	if (param == 'FITTIZIO3') 
	{
		MakeDocFrom ( 'RICHIESTA_SMART_CIG##BANDO' );
	}
	
	if (param == 'FITTIZIO4') 
	{
		if ( validaDatiSimogPNRR() )
			MakeDocFrom ( 'RICHIESTA_CIG##BANDO' );
	}
	
	if ( param == 'SAVE_AND_GO' )
    {      
		var filter='MacroAreaMerc = \'' + getObjValue('RTESTATA_PRODOTTI_MODEL_Ambito') + '\'';	
	   OpenViewer('Viewer.asp?OWNER=&Table=DASHBOARD_VIEW_ELENCO_CODIFICHE_META_PRODOTTI&ModelloFiltro=DASHBOARD_VIEW_ELENCO_CODIFICHE_PRODOTTIFiltro&ModGriglia=ELENCO_CODIFICHE_META_PRODOTTI_' + getObjValue('RTESTATA_PRODOTTI_MODEL_Ambito') + '_MOD_Griglia&Filter='+encodeURIComponent(filter)+'&IDENTITY=ID&lo=base&HIDE_COL=&DOCUMENT=DOCUMENT_CODIFICA_PRODOTTO_' + getObjValue('RTESTATA_PRODOTTI_MODEL_Ambito') +'&PATHTOOLBAR=../CustomDoc/&JSCRIPT=BANDO_SEMPLIFICATO&AreaAdd=no&Caption=Ricerca Meta Prodotti&Height=180,100*,210&numRowForPag=20&Sort=Id&SortOrder=asc&Exit=si&AreaFiltro=&AreaFiltroWin=1&TOOLBAR=TOOLBAR_VIEW_RICERCA_METAPRODOTTI&ACTIVESEL=2&FilterHide=&ONSUBMIT=return cercaperambito()&doc_to_upd='+ getObj('IDDOC').value);
    }
	
	if (param == 'SELEZIONA') 
	{
		var iddoc = getObj('IDDOC').value;
		ShowDocument('BANDO_RICHIESTA_CODIFICA', iddoc, 'YES');
	}
	
	if ( param == 'XML_CN16:-1:CHECKOBBLIG' )
	{
		execDownloadXmlCN16();
	}
	
	if ( param == 'XML_CAN29_DESERTA' )
	{
		execDownloadXmlCAN29();
	}
	

	// Per GGAP: il campo "Richiesta CIG su SIMOG" deve essere valorizzato a 'si'
	if (getObj('RichiestaCigSimog') !== null && getObj('RichiestaCigSimog') !== undefined && getObjValue('RichiestaCigSimog') === 'si')
	{
		if (param == 'RICHIESTA_SMART_CIG_GGAP')
		{
			ExecDocProcess( 'RICHIESTA_SMART_CIG_GGAP_STEP2,BANDO_GARA,,NO_MSG');
		}

		if (param == 'RICHIESTA_SMART_CIG_GGAP_STEP2')
		{
			OpenGgapPageForSmartCig();
		}

		if (param == 'RICHIESTA_CIG_GGAP' || param == 'MODIFICA_RICHIESTA_CIG_GGAP')
		{
			var statoDoc = getObj('StatoDoc').value;
			// var isDocDeleted = getObj('Deleted').value;

			// Se ci sono ancora dati da mandare a GGAP, stato di invio in corso
			if(statoDoc === 'InvioInCorso' || statoDoc === 'InLavorazione')
			{
				var document = 'RICHIESTA_CIG_GGAP';
				var idDocRichiestaCig = getObj('idDocR').value;

				ShowDocument(document, idDocRichiestaCig); // => function ShowDocument(strDoc, cod, Reload)
			}
			// else if (statoDoc === 'Annullato'){
			// 	DMessageBox( '../' , 'Non e\' possibile eseguire la modifica della richiesta perche\' i dati della gara o dei lotti non sono cambiati' , 'Attenzione' , 1 , 400 , 300 );
			// }
			else
			{
				// Apro scheda di richiesta CIG su GGAP
				OpenGgapPageForCig();
			}
		}

		if (param == 'CONTROLLO_PRODOTTI') // if (param == 'CONTROLLO_PRODOTTI' || param == 'LOAD_PRODOTTI_SUB' || param == 'AGGIORNA_CIG')
		{
			if(getObj('isSimogGgap') !== null && getObj('isSimogGgap') !== undefined)
			{
				if(getObjValue('isSimogGgap') === 1 || getObjValue('isSimogGgap') === '1')
				{
					RefreshDocument('');
				}
			}
		}
	}
	
	/*
	if (param == 'PCP_ConfermaAppalto:-1:CHECKOBBLIG') {
		PCP_ConfermaAppalto_End();
	}
	*/
	
	if ( param == 'CONTROLLI_BASE:-1:CHECKOBBLIG' )
	{
		PCP_ConfermaAppalto_End();
	}
	
	
	if (param == 'PCP_PubblicaAvviso') {
		PCP_PubblicaAvviso_End();
	}

	if (param == 'PCP_CancellaAppalto') {
		PCP_CancellaAppalto_End();
	}
  
	if (param == 'PCP_RecuperaCig') {
		PCP_RecuperaCig_End();
	}
  
  
  
}

function setRegExpCIG()
{
	try
	{
		var DOCUMENT_READONLY = '0';

		try
		{
			DOCUMENT_READONLY = isDocumentReadonly(); //getObj('DOCUMENT_READONLY').value;
		}
		catch(e){}

		if (DOCUMENT_READONLY == '0') 
		{
			var divisioneLotti = getObjValue('Divisione_lotti');
			var oldOnChange = getObj('CIG').getAttribute('onchange');
			var newOnChange = '';

			// Se divisione in lotti NO, obbligo un CIG di lunghezza 10. Altrimenti Se divisione in lotti <> 0 lo imposto su 7
			if ( divisioneLotti == '0' || divisioneLotti == '' )
			{
				//newOnChange = ReplaceExtended(oldOnChange,'^[\da-zA-Z]{7,7}$', '^[\da-zA-Z]{10,10}$');
				//newOnChange = ReplaceExtended(newOnChange,'^[\da-zA-Z]{7,10}$', '^[\da-zA-Z]{10,10}$');
				newOnChange = "validateField('^[\\\\da-zA-Z]{10,10}$',this);" ;
				
			}																	 
			else
			{
				//newOnChange = ReplaceExtended(oldOnChange,'^[\da-zA-Z]{7,10}$', '^[\da-zA-Z]{7,7}$');
				//newOnChange = ReplaceExtended(newOnChange,'^[\da-zA-Z]{10,10}$', '^[\da-zA-Z]{7,7}$');
				newOnChange = "validateField('^[\\\\da-zA-Z]{7,7}$',this);" ;
			}

			getObj('CIG').setAttribute('onchange', newOnChange);
		}

	}
	catch(e)
	{
	}	
}
function Anteprima_Invitati()
{
	OpenViewer('Viewer.asp?STORED_SQL=yes&OWNER=&Table=DASHBOARD_SP_ELENCO_PARTECIPANTI_AL_SEMPLIFICATO&ModelloFiltro=NO&ModGriglia=BANDO_GARA_DESTINATARI_ANTEPRIMA&IDENTITY=IDazi&lo=base&HIDE_COL=NumRiga&DOCUMENT=BANDO_SEMPLIFICIATO&PATHTOOLBAR=../CustomDoc/&JSCRIPT=BANDO_SEMPLIFICIATO&AreaAdd=no&Caption=Anteprima Invitati&Height=180,100*,210&numRowForPag=20&Sort=IdAzi&SortOrder=asc&Exit=si&AreaFiltro=&AreaFiltroWin=1&TOOLBAR=BANDO_SEMPLIFICATO_ANTEPRIMA_INVITATI&ACTIVESEL=&FilterHide=' + getObj('IDDOC').value  );
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

function resetForm() {
	getObj('OffAnomale').style.display = 'none';
	getObj('METODO_DI_CALCOLO_ANOMALIA').style.display = 'none';
	getObj('ScontoDiRiferimento_V').style.display = 'none';
	getObj('cap_OffAnomale').style.display = 'none';
	getObj('cap_METODO_DI_CALCOLO_ANOMALIA').style.display = 'none';
	getObj('cap_ScontoDiRiferimento').style.display = 'none';
}

function verifyModalitaDiCalcoloAnomalia()
{
	try{
		//-- recupero i campi per determinare la combinatoria
		var tipoSoglia = getObjValue('TipoSoglia');
		var tipoAppaltoGara = getObjValue('TipoAppaltoGara');
		var criterioAggiudicazioneGara = getObjValue('CriterioAggiudicazioneGara');
		var calcoloAnomalia = getObjValue('CalcoloAnomalia');
		
		var showAnomalia = '1';
		
		//-- se anche uno solo non è valorizzato  oppure CalcoloAnomalia <> 'si', nascondo tutti gli attributi utili all'anomalia ed esco	
		if (calcoloAnomalia != '1' || (tipoSoglia == '' || tipoAppaltoGara == '' || criterioAggiudicazioneGara == ''))
			showAnomalia = '0';
			
		// se il documento non è in lavorazione ed è stata attivata l'anomalia allora devo mostrare i campi
		if ( getObjValue('StatoFunzionale') != 'InLavorazione' && calcoloAnomalia == '1')
			showAnomalia = '1';
		
		if ( showAnomalia  == '0' )
		{
			resetForm();
		}
		else 
		{

			var DOCUMENT_READONLY_LOCAL = isDocumentReadonly(); //getObj('DOCUMENT_READONLY').value;	
			if (DOCUMENT_READONLY_LOCAL == '0') // il documento � il lavorazione cioe editabile
			{
				controlliCombinatorieCalcoloAnomalie();
			} else {
				
				if (getObj('METODO_DI_CALCOLO_ANOMALIA').value == undefined) 
				{ 
					setVisibility(getObj('val_METODO_DI_CALCOLO_ANOMALIA').offsetParent.offsetParent, 'none');
					getObj('cap_METODO_DI_CALCOLO_ANOMALIA').style.display = 'none';
				}
				if (getObj('ScontoDiRiferimento_V').value == undefined) 
				{
					setVisibility(getObj('Cell_ScontoDiRiferimento').offsetParent.offsetParent, 'none');
					getObj('cap_ScontoDiRiferimento').style.display = 'none';
				}
				
				
			}
			
			resetForm();
			
			getObj('cap_OffAnomale').style.display = '';
			getObj('OffAnomale').style.display = '';
			getObj('cap_METODO_DI_CALCOLO_ANOMALIA').style.display = '';
			getObj('METODO_DI_CALCOLO_ANOMALIA').style.display = '';

					
			//-- se algoritmo di calcolo = ''C'
				//-- viasualizzo valore di riferimento
				//altrimenti
				//-- nascondo e svuoto valore di riferimento
			if (getObj('METODO_DI_CALCOLO_ANOMALIA').value == 'Metodo C') 
			{
				getObj('cap_ScontoDiRiferimento').style.display = '';
				getObj('ScontoDiRiferimento_V').style.display = '';
			}
			else 
			{
				getObj('ScontoDiRiferimento_V').value = '';
				getObj('cap_ScontoDiRiferimento').style.display = 'none';
				getObj('ScontoDiRiferimento_V').style.display = 'none';
			}

			//-- se gara al prezzo più basso
			//-- visualizzo algoritmo di calcolo
			//altrimenti
			//-- nascondo algoritmo di calcolo	
			//per il costo fisso oppure prezzo piu alto blocco a no calcolo soglia anomalia
			if ( criterioAggiudicazioneGara == '25532' || criterioAggiudicazioneGara == '16291' ) 
			{
				FilterDom( 'CalcoloAnomalia' ,  'CalcoloAnomalia' , '0' , 'SQL_WHERE=tdrcodice = \'0\' ' , '' , ''); //-- solo no
				getObj('CalcoloAnomalia').style.display = 'none';
				getObj('OffAnomale').value = '';
				getObj('OffAnomale').style.display = 'none';
				getObj('METODO_DI_CALCOLO_ANOMALIA').value = '';
				getObj('METODO_DI_CALCOLO_ANOMALIA').style.display = 'none';
				getObj('cap_CalcoloAnomalia').style.display = 'none';
				getObj('cap_OffAnomale').style.display = 'none';
				getObj('cap_METODO_DI_CALCOLO_ANOMALIA').style.display = 'none';
			} else {
				getObj('CalcoloAnomalia').style.display = '';
				getObj('OffAnomale').style.display = '';
				getObj('cap_CalcoloAnomalia').style.display = '';
				getObj('cap_OffAnomale').style.display = '';		
				//-- se OffAnomale = manuale
				//-- nascondere algoritmo
				//altrimenti
				//--  visualizziamo algoritmo
				if(getObj('OffAnomale').value != '16311') 
				{
					getObj('METODO_DI_CALCOLO_ANOMALIA').style.display = '';
					getObj('cap_METODO_DI_CALCOLO_ANOMALIA').style.display = '';
				}
				else
				{
					getObj('METODO_DI_CALCOLO_ANOMALIA').value = '';
					getObj('METODO_DI_CALCOLO_ANOMALIA').style.display = 'none';
					getObj('cap_METODO_DI_CALCOLO_ANOMALIA').style.display = 'none';
				}			
			}

			//-- applichiamo le restrizioni nelle scelte in base alle combinatorie
			//-- se il documento è editabile invochiamo la funzione [controlliCombinatorieCalcoloAnomalie]
			

		}
		
	}
	catch(e)
	{
	}
	
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

function onChangeCalcoloSoglia(obj) 
{
    try 
	{
		verifyModalitaDiCalcoloAnomalia();

    } 
	catch (e)
	{
		
	}
}

// Il metodo effettua i vari  controlli sulle combinatorie possibili nel calcolo delle anomalie secondo il Dlg 36
function controlliCombinatorieCalcoloAnomalie(obj) {
	
		var _offAnomale = getObjValue( 'OffAnomale');
		if (_offAnomale == undefined || _offAnomale == null) _offAnomale = '';
	
	// Se siamo nel caso di una sotto soglia e non in Appalto PNRR PNC allora verifichiamo 3 possibili scenari
	if (getObj('TipoSoglia').value == 'sotto') {
		// Se il criterio di aggiudicazione è PPB ed il tipo appalto è Lavori o servizi allora come offerte Anomale deve essere selezionato esclusione automatica
		if (getObj('CriterioAggiudicazioneGara').value == '15531'&& (getObj('TipoAppaltoGara').value == '3' || getObj('TipoAppaltoGara').value == '2')) {	
			FilterDom( 'OffAnomale' ,  'OffAnomale' , _offAnomale, 'SQL_WHERE=  tdrCodice = \'16309\' ' , '' , 'verifyModalitaDiCalcoloAnomalia();');
			if(getObj('OffAnomale').value != '16311')  FilterDom( 'METODO_DI_CALCOLO_ANOMALIA' ,  'METODO_DI_CALCOLO_ANOMALIA' , getObjValue( 'METODO_DI_CALCOLO_ANOMALIA'), 'SQL_WHERE=  DMV_Cod <> \'Metodo 4/5\' ' , '' , 'verifyModalitaDiCalcoloAnomalia();');
		}
		
		// Se Il tipo appalto è forniture ed il criterio di aggiudicazione è PPB allora verifico che il metodo di calcolo sia valutazione o manuale
		if (getObj('CriterioAggiudicazioneGara').value == '15531'&& getObj('TipoAppaltoGara').value == '1') {	
			FilterDom( 'OffAnomale' ,  'OffAnomale' , _offAnomale , 'SQL_WHERE=  tdrCodice in ( \'16310\',\'16311\' )' , '' , 'verifyModalitaDiCalcoloAnomalia();');	
			if(getObj('OffAnomale').value != '16311')  FilterDom( 'METODO_DI_CALCOLO_ANOMALIA' ,  'METODO_DI_CALCOLO_ANOMALIA' , getObjValue( 'METODO_DI_CALCOLO_ANOMALIA') , 'SQL_WHERE=  DMV_Cod = \'Metodo A\' ' , '' , 'verifyModalitaDiCalcoloAnomalia();');			
		}
	}
	
	// Se il criterio di aggiudicazione è OEPV allora l'offerta anomala può essere o di Valutazione o Manuale
	if (getObj('CriterioAggiudicazioneGara').value == '15532') {
		// Se è diversa dalle due scelte allora lancia l'errore a video
		FilterDom( 'OffAnomale' ,  'OffAnomale' , _offAnomale , 'SQL_WHERE=  tdrCodice in ( \'16310\',\'16311\' )' , '' , 'verifyModalitaDiCalcoloAnomalia();');
		if(getObj('OffAnomale').value != '16311')  FilterDom( 'METODO_DI_CALCOLO_ANOMALIA' ,  'METODO_DI_CALCOLO_ANOMALIA' , getObjValue( 'METODO_DI_CALCOLO_ANOMALIA') , 'SQL_WHERE=  DMV_Cod = \'Metodo 4/5\' ' , '' , 'verifyModalitaDiCalcoloAnomalia();');
	}
	
	// Se siamo nel caso di una sopra soglia e non in Appalto PNRR PNC allora verifichiamo 2 possibili scenari
	if (getObj('TipoSoglia').value == 'sopra') {
		
		// Se il criterio di aggiudicazione è PPB allora accetterà solo offerta anomala di tipo Valutazione o Manuale
		if (getObj('CriterioAggiudicazioneGara').value == '15531') {
			// Se è diversa dalle due scelte allora lancia l'errore a video
			FilterDom( 'OffAnomale' ,  'OffAnomale' , _offAnomale, 'SQL_WHERE=  tdrCodice in ( \'16310\',\'16311\' )' , '' , 'verifyModalitaDiCalcoloAnomalia();');		
			if(getObj('OffAnomale').value != '16311')  FilterDom( 'METODO_DI_CALCOLO_ANOMALIA' ,  'METODO_DI_CALCOLO_ANOMALIA' , getObjValue( 'METODO_DI_CALCOLO_ANOMALIA') , 'SQL_WHERE=  DMV_Cod = \'Metodo A\' ' , '' , 'verifyModalitaDiCalcoloAnomalia();');			
		}
		
		// Se il criterio di aggiudicazione è OEPV allora accetterà solo offerta anomala di tipo Valutazione o Manuale
		if (getObj('CriterioAggiudicazioneGara').value == '15532') {
			FilterDom( 'OffAnomale' ,  'OffAnomale' , _offAnomale , 'SQL_WHERE=  tdrCodice in ( \'16310\',\'16311\' )', '' , 'verifyModalitaDiCalcoloAnomalia();');		
			if(getObj('OffAnomale').value != '16311')  FilterDom( 'METODO_DI_CALCOLO_ANOMALIA' ,  'METODO_DI_CALCOLO_ANOMALIA' , getObjValue( 'METODO_DI_CALCOLO_ANOMALIA') , 'SQL_WHERE=  DMV_Cod = \'Metodo 4/5\' ' , '' , 'verifyModalitaDiCalcoloAnomalia();');			
		}
	}
}

// Il metodo rende editabile o meno il campo Sconto di riferimento tramite il controllo implementato
function onChangeMetodoDiCalcolo(obj) {
	verifyModalitaDiCalcoloAnomalia();
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

function SetCostoFisso()
{

	var DOCUMENT_READONLY = isDocumentReadonly(); //getObj('DOCUMENT_READONLY').value;

	if ( getObjValue('CriterioAggiudicazioneGara') == '25532' )
	{
		 //nascondere 'PunteggioEconomico' e porre a zero, rendere readonly PunteggioTecnico e porlo a 100
		  if ( DOCUMENT_READONLY == '0' )
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

}

function OnChangeAmbito() 
{
    var iddoc = getObj('IDDOC').value;

    var Ambito = getObjValue('RTESTATA_PRODOTTI_MODEL_Ambito');

    if (getObjValue('TipoBando') != '') {
        alert(CNV('../', 'Il cambio dell\'ambito comporta un azzeramento del modello dei prodotti'));

        ExecDocProcess('SVUOTA_SOLO_MODELLO_PRODOTTI,BANDO_GARA');

    } else {
		
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
			var ProceduraGara=getObjValue('ProceduraGara');
			
            var Complex = getObjValue('Complex');
            var Monolotto = 0;
            if (Complex == '') {
                Complex = 0;
            }

            if (getObjValue('Divisione_lotti') == '0') {
                Monolotto = 1
            }

			
            //var filter = 'SQL_WHERE= DMV_Father  <> \'1\' and DMV_Cod in ( select codice  from View_Modelli_Lotti where  CriterioFormulazioneOfferte = \'' + Criterio + '\'  and CriterioAggiudicazioneGara like \'%###' + CriterioAggiudicazione + '###%\' and Conformita like \'%###' + Conform + '###%\' and Complex = ' + Complex + ' and Ambito = \'' + Ambito + '\' and Monolotto = ' + Monolotto + ' )';
			
			var filter = 'SQL_WHERE= DMV_Father  <> \'1\' and DMV_Cod in ( select codice  from View_Modelli_Lotti where  TipoProcedureApplicate like \'%###\' + dbo.GetDescTipoProcedura( \'BANDO_SEMPLIFICATO\' , \'\' , \'' + ProceduraGara + '\' , \'\' ) + \'###%\' and  CriterioFormulazioneOfferte = \'' + Criterio + '\'  and CriterioAggiudicazioneGara like \'%###' + CriterioAggiudicazione + '###%\' and Complex = ' + Complex + ' and Ambito = \'' + Ambito + '\' and Monolotto = ' + Monolotto ;
			
			//se OEPV oppure costo fisso non applico la condizione della conformita al filtro
			if ( CriterioAggiudicazione == '15532' || CriterioAggiudicazione == '25532' ){
			
				filter = filter  +	' )';
			
			}else{
				
				filter = filter  + ' and Conformita like \'%###' + Conform + '###%\'' + ' )';
			}
			//alert(getExtraAttrib('val_RTESTATA_PRODOTTI_MODEL_TipoBandoScelta','value'));
            //FilterDom('RTESTATA_PRODOTTI_MODEL_TipoBandoScelta', 'TipoBandoScelta', getObjValue('RTESTATA_PRODOTTI_MODEL_TipoBandoScelta'), filter, 'TESTATA_PRODOTTI_MODEL', 'OnChangeModello( this );');
			FilterDom('RTESTATA_PRODOTTI_MODEL_TipoBandoScelta', 'TipoBandoScelta', getExtraAttrib('val_RTESTATA_PRODOTTI_MODEL_TipoBandoScelta','value'), filter, 'TESTATA_PRODOTTI_MODEL', 'OnChangeModello( this );');
        }
    } catch (e) {};

}


//-- associo il nuovo modello al documento 
function OnChangeModello(o) 
{
   	
	//GESTIONE FATTA PER EVITARE DI LASCIARE VALORI ERRATI IN TipoBandoScelta quando il conferma del modello va in eccezione
	 try 
	 {
			SetTextValue( 'TipoBandoSceltaHide',getObjValue('RTESTATA_PRODOTTI_MODEL_TipoBandoScelta') );
	
			SetTextValue( 'RTESTATA_PRODOTTI_MODEL_TipoBandoScelta',getObjValue('TipoBandoSceltaOLD') );
	 } catch (e) {};
   
   //-- aggiorna il modello da usare per la sezione prodotti
    ExecDocProcess('SELECT_MODELLO_BANDO,BANDO');
}



function OnChangeCriterioAggiudicazioneGara( obj ) 
{
	
	// cambio il filtro sui modelli selezionabili se il valore precedente � mantenuto vuol dire che il modello � ancora buono per essere utilizzato
	// altrimenti svuoto i dati relativi al modello
	
	var OldV = getObjValue('RTESTATA_PRODOTTI_MODEL_TipoBandoScelta');
	
	FiltraModelli();
	onchange_SetCriteri( 0 );
	
	if( getObjValue('RTESTATA_PRODOTTI_MODEL_TipoBandoScelta') == OldV )
	{
		DisplaySection( obj );
	}
	else
	{
	    alert(CNV('../', 'La selezione effettuata comporta l\'eliminazione del modello adottato e di tutte le informazioni ad esso collegate perche\' incorente con il valore scelto'));
		ExecDocProcess('SVUOTA_SOLO_MODELLO_PRODOTTI,BANDO_GARA');
	}
	
	try{visualizzazione_offerta_tecnica();}catch(e){};
		
	
}
function onchange_SetCriteri( nLoadPage )
{
	var DOCUMENT_READONLY = isDocumentReadonly(); //getObj( 'DOCUMENT_READONLY' ).value;
    var CriterioAggiudicazioneGara = getObjValue('CriterioAggiudicazioneGara');	
    
    //-- vengono ripristinate le aree relative ai criteri tecnici
    try {
        getObj('BANDO_SEMPLIFICATO_CRITERI_ECO').rows[7].style.display = '';
        getObj('BANDO_SEMPLIFICATO_CRITERI_ECO').rows[8].style.display = '';
        getObj('BANDO_SEMPLIFICATO_CRITERI_ECO').rows[9].style.display = '';
        getObj('BANDO_SEMPLIFICATO_CRITERI_ECO').rows[10].style.display = '';
        getObj('BANDO_SEMPLIFICATO_CRITERI_ECO').rows[11].style.display = '';
        getObj('BANDO_SEMPLIFICATO_CRITERI_ECO').rows[12].style.display = '';
        getObj('BANDO_SEMPLIFICATO_CRITERI_ECO').rows[2].style.display = '';
    } catch (e) {}      
        
            
    
	if ( CriterioAggiudicazioneGara == '25532' ) //-- COSTOFISSO
	{
		//nascondere 'PunteggioEconomico' e porre a zero, rendere readonly PunteggioTecnico e porlo a 100
		if ( DOCUMENT_READONLY == '0' )
		{
			SetNumericValue('PunteggioEconomico', 0);
			SetNumericValue('PunteggioTecnico', 100);
			NumberreadOnly( 'PunteggioTecnico' , true );
		}
		$("#cap_PunteggioEconomico").parents("table:first").css({"display": "none"})		  
        $("#cap_PunteggioTecnico").parents("table:first").css({"display": ""})		
        $("#cap_PunteggioTecMin").parents("table:first").css({"display": ""})		

		//vengono nascoste le sezioni dei criteri economici CRITERI_ECO_TESTATA e CRITERI_ECO_RIGHE
		setVisibility(getObj('CRITERI_ECO_TESTATA'), 'none');
        setVisibility(getObj('CRITERI_ECO_RIGHE'), 'none');

        //-- visualizza la parte tecnica
        setVisibility(getObj('CRITERI'), '');
    }

    if ( CriterioAggiudicazioneGara == '15532' ) //-- OEV
	{
		if ( DOCUMENT_READONLY == '0' )
		{
			//se non vengo dal caricamento iniziale della pagina resetto i valori	
			if (nLoadPage == 0)
			{
				SetNumericValue('PunteggioEconomico', 0);
				SetNumericValue('PunteggioTecnico', 0);
			}
			NumberreadOnly( 'PunteggioEconomico' , false );
			NumberreadOnly( 'PunteggioTecnico' , false );
		}
		$("#cap_PunteggioEconomico").parents("table:first").css({"display": ""})		
        $("#cap_PunteggioTecnico").parents("table:first").css({"display": ""})		
        $("#cap_PunteggioTecMin").parents("table:first").css({"display": ""})		
		setVisibility(getObj('CRITERI_ECO_TESTATA'), '');
		setVisibility(getObj('CRITERI_ECO_RIGHE'), '');

        //-- visualizza la parte tecnica
        setVisibility(getObj('CRITERI'), '');

    }
    
	//alert(CriterioAggiudicazioneGara);

    if ( CriterioAggiudicazioneGara == '15531' || CriterioAggiudicazioneGara == '16291' ) //-- GARE AL PREZZO
    {
		if ( DOCUMENT_READONLY == '0' )
		{
			SetNumericValue('PunteggioEconomico', 100);
			SetNumericValue('PunteggioTecnico', 0);
			SetNumericValue('PunteggioTecMin', 0);
			NumberreadOnly( 'PunteggioEconomico' , true );
		}
		$("#cap_PunteggioEconomico").parents("table:first").css({"display": ""})		
		$("#cap_PunteggioTecnico").parents("table:first").css({"display": "none"})		
		$("#cap_PunteggioTecMin").parents("table:first").css({"display": "none"})		
		setVisibility(getObj('CRITERI_ECO_TESTATA'), '');
		setVisibility(getObj('CRITERI_ECO_RIGHE'), '');
        
        //-- nascondo la parte tecnica
        setVisibility(getObj('CRITERI'), 'none');
        
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
        
	 }
     
}
function OnChangeConformita( obj ) 
{
	OnChangeCriterioAggiudicazioneGara( obj );
}

function OnChangeCriterioFormulazioneOfferteTestata( obj ) 
{
	
	// cambio il filtro sui modelli selezionabili se il valore precedente � mantenuto vuol dire che il modello � ancora buono per essere utilizzato
	// altrimenti svuoto i dati relativi al modello
	
	var OldV = getObjValue('RTESTATA_PRODOTTI_MODEL_TipoBandoScelta');
	
	FiltraModelli();
	
	if( getObjValue('RTESTATA_PRODOTTI_MODEL_TipoBandoScelta') == OldV )
	{
		ChangeFormulaEcoLotto( obj );
	}
	else
	{
	    alert(CNV('../', 'La selezione effettuata comporta l\'eliminazione del modello adottato e di tutte le informazioni ad esso collegate perche\' incorente con il valore scelto'));
		ExecDocProcess('SVUOTA_SOLO_MODELLO_PRODOTTI,BANDO_GARA');
	}
		
	
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
		
		
		if ( getObjValue('Richiesta_terna_subappalto') == '1' )
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
	
	if (getObjValue('Divisione_lotti') == '0') 
	{
		extraHideCol = ',lottiOfferti';		
	}
	
    ExecFunction('../../CTL_Library/accessBarrier.asp?goto=xlsx.aspx&TitoloFile=offerte&FILTER=linkeddoc%3D' + getObjValue('IDDOC') + '&TIPODOC=OFFERTA&MODEL=BANDO_SDA_LISTA_OFFERTEGriglia&VIEW=BANDO_SDA_LISTA_OFFERTE&HIDECOL=FNZ_OPEN,Name' + extraHideCol + '&Sort=DataInvio%20asc&IDDOC=' + getObjValue('IDDOC'), '_blank', '');
}

function EsportaManInterInXLSX() 
{
    ExecFunction('../../CTL_Library/accessBarrier.asp?goto=xlsx.aspx&TitoloFile=Manifestazioni_di_interesse&&FILTER=linkeddoc%3D' + getObjValue('IDDOC') + '&TIPODOC=MANIFESTAZIONE_INTERESSE&MODEL=LISTA_MANIF_INTERESGriglia&VIEW=VIEW_LISTA_MANIF_INTERES&HIDECOL=FNZ_OPEN,Name,bReadDocumentazione,Selezione&Sort=DataInvio%20asc&IDDOC=' + getObjValue('IDDOC'), '_blank', '');
}

function EsportaPartecipantiLottiInXLSX()
{
   ExecFunction('../../CTL_Library/accessBarrier.asp?goto=xlsx.aspx&TitoloFile=Partecipanti_per_lotto&FILTER=linkeddoc%3D' + getObjValue('IDDOC') + '&TIPODOC=OFFERTA&MODEL=PARTECIPANTI_LOTTI_GRIGLIA&VIEW=LISTA_OFFERTE_PER_LOTTO&HIDECOL=FNZ_OPEN,Name,lottiOfferti&Sort=aziRagioneSociale%20asc%2CNumeroLotto%20asc&IDDOC=' + getObjValue('IDDOC'), '_blank', '');
}

function EsportaDestinatariInXLSX() 
{
	var extraHideCol = '';
	
	
    ExecFunction('../../CTL_Library/accessBarrier.asp?goto=xlsx.aspx&TitoloFile=Destinatari&FILTER=idheader%3D' + getObjValue('IDDOC') + '&MODEL=BANDO_SEMPLIFICATO_DESTINATARI&VIEW=CTL_DOC_Destinatari_View&HIDECOL=&Sort=idRow%20asc&IDDOC=' + getObjValue('IDDOC'), '_blank', '');
}

function onChangeGeneraConvenzione()
{
	var DOCUMENT_READONLY;
  
	try 
	{ 
		DOCUMENT_READONLY = isDocumentReadonly();//getObj('DOCUMENT_READONLY').value; 
	} 
	catch (e) 
	{ DOCUMENT_READONLY = '1' };
	
	//Se esistono gli attributi 'GeneraConvenzione' e 'TipoAggiudicazione'
	//e 'Genera Convenzione completa' � diverso da si, nascondiamo 'TipoAggiudicazione'
	try
	{
		if ( getObj('GeneraConvenzione') && getObj('TipoAggiudicazione') )
		{
			if ( getObjValue('GeneraConvenzione') != '1' )
			{
				
				if (DOCUMENT_READONLY == '0')
					getObj('TipoAggiudicazione').value = 'monofornitore';

				$("#cap_TipoAggiudicazione").parents("table:first").css({"display": "none"});
			}
			else
			{
				$("#cap_TipoAggiudicazione").parents("table:first").css({"display": ""});
			}
		}
		
	}catch(e){}
	
	try
	{
		if ( getObjValue('GeneraConvenzione') == '1' )
			getObj( 'Accordo_di_Servizio' ).value ='no'; 
	}catch(e){};
	
	
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


function OnChangeSedutaVirtuale() 
{
    if (getObj('Scelta_Seduta_Virtuale').value == 'si') 
	{
        getObj('TipoSedutaGara').value = 'virtuale';
		return;
    }
	 if (getObj('Scelta_Seduta_Virtuale').value == 'no') 
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


function REQUISITI_AFTER_COMMAND( param )
{
	try
	{
		if (  isDocumentReadonly() == 0 )
		{
			var r = 0;
			var n = getObj('REQUISITIGrid').rows.length;
			while( r < n )
			{

				//RREQUISITIGrid_0_ElencoCIG
				//FilterDom('RREQUISITIGrid_' + r + '_ElencoCIG', 'ElencoCIG', getObjValue('RREQUISITIGrid_' + r+ '_ElencoCIG'), 'SQL_WHERE= idHEader  = \'' + getObjValue('IDDOC') + '\' ', 'REQUISITIGrid_' + r  , '');		
				SetProperty(getObj('RREQUISITIGrid_' + r + '_ElencoCIG'), 'filter', 'SQL_WHERE= idHEader  = \'' + getObjValue('IDDOC') + '\' ');

				r++;
			}
		
		}
	}catch(e){}
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
			
			var ml_text = 'Cambiando questa scelta verranno annullate tutte le richieste SIMOG effettuate sulla procedura. Proseguire ?';
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

/* FINE GESTIONE SIMOG */

function onChangeUserRUP()
{
	var EnteProponente=getObjValue('EnteProponente').split('#')[0];	
	var enteappaltante=getObjValue('Azienda');
	
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
				//adeguata a bando_gara perchè il campo non e editabile
				//getObj('DirezioneEspletante_edit').value = vet[1];
				//getObj('DirezioneEspletante_edit_new').value = vet[1];
				getObj('Cell_DirezioneEspletante').innerHTML = getObj('DirezioneEspletante').outerHTML;

				if (vet[1] != 'Seleziona')
					getObj('Cell_DirezioneEspletante').innerHTML = getObj('Cell_DirezioneEspletante').innerHTML + vet[1];
				
				
			}
		}	
	}
	else
	{
		getObj('DirezioneEspletante').value = '';
		//adeguata a bando_gara perchè il campo non e editabile
		//getObj('DirezioneEspletante_edit').value = 'Seleziona';
		//getObj('DirezioneEspletante_edit_new').value ='Seleziona';
		getObj('Cell_DirezioneEspletante').innerHTML = getObj('DirezioneEspletante').outerHTML;
	}
	
	
	if ( EnteProponente == enteappaltante ) //se coincidono valorizzo RupProponente con lo stesso valore Selezionando il rup espletante pu� cambiare il RUP proponente solo se vuoto, nel caso di pieno do un warning se diverso 
	{
			
		if ( getObj('RupProponente').value == '' && getObj('RupProponente').type == 'select-one'  )  //vuoto ed editable
		{
			SetDomValue( 'RupProponente' , getObj('UserRUP').value , '');
			ExecDocProcess('CAMBIO_RUP,DOCUMENT');
		}
		else
		{
			if ( getObj('RupProponente').value !=  getObj('UserRUP').value )
			{
				ML_text = 'Si evidenzia che il riferimento selezionato come RUP non coincide con la selezione del RUP Proponente.';
				Title = 'Informazione';					
				ICO = 1;
				page = 'ctl_library/MessageBoxWin.asp?MODALE=YES&ML=YES&MSG=' + encodeURIComponent( ML_text ) +'&CAPTION=' + encodeURIComponent(Title) + '&ICO=' + encodeURIComponent(ICO);

				ExecFunctionModale( page, null , 200 , 420 , null  );
			}
		
		}
		
	}
	
	//se attiva la PCP innesco un processo fittizio per far ricaricare il documento 
	//per ridisegnare la toolbar e nello specifico il menu "gestioone pcp" che potrebbe essere visibile/non visibile a seconda del parametro 
	//GESTIONE_PCP_RUP:se vale YES solo il rup vede il menu altrimenti tutti
	if ( hasPCP() )
	{  
		ExecDocProcess('FITTIZIO6,DOCUMENT,,NO_MSG');
	}
	
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



function onChangeCheckFermoSistema(obj)
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

function visualizzazione_offerta_tecnica()
{
	//PER LE GARE CHE NON SONO economicamente vantaggiose 15532  e non sono costo fisso 25532
	//NASCONDIAMO il campo visualizzazione offerta tecnica
	if ( CriterioAggiudicazione != '15532' && CriterioAggiudicazione != '25532' )
	{
		$("#cap_Visualizzazione_Offerta_Tecnica").parents("table:first").css({"display": "none"});
	}	
	else
	{		
		$("#cap_Visualizzazione_Offerta_Tecnica").parents("table:first").css({"display": "block"});
	}
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
						
						V = Number( vetG[j*4+3] );
						
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



function onChangeAccordoServizio()
{
	try
	{
		
		if ( getObj( 'Accordo_di_Servizio' ).value == 'si' )
		{
			getObj( 'GeneraConvenzione' ) .value = '0';
			onChangeGeneraConvenzione();
		}
	
	
	}catch(e){};
	
}
function RIFERIMENTI_AFTER_COMMAND( param )
{
  FilterRiferimenti();
}

function FilterRiferimenti(){
	
	
	var filterUser = '';	
	var i;
	var numrighe=GetProperty( getObj('RIFERIMENTIGrid') , 'numrow');

	
	
	
	filterUser = 'SQL_WHERE= idpfu in ( select idpfu from RiferimentiForBando where DOC_ID = \'BANDO_SEMPLIFICATO\'  and  OWNER = <ID_USER> )';
	
	
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
				}
				else
				{				
					filterUser = 'SQL_WHERE= idpfu in ( select idpfu from RiferimentiForBando where DOC_ID = \'BANDO_SEMPLIFICATO\'  and  OWNER = <ID_USER> )';
				}
				
				FilterDom(  'RRIFERIMENTIGrid_' + i + '_IdPfu' , 'IdPfu' , getObjValue( 'val_RRIFERIMENTIGrid_' + i + '_IdPfu' ), filterUser , 'RIFERIMENTIGrid_' + i  , '')
			}
			catch(e)
			{
			}

		}
		
	}catch(e){};

}

function onchangeAppaltoInEmergenza() {
    try {
        if (getObjValue('AppaltoInEmergenza') != 'si') {
            getObj('MotivazioneDiEmergenza').value = '';
            getObj('MotivazioneDiEmergenza').disabled = true;

        }
    } catch (e) {}
    try {
        if (getObjValue('AppaltoInEmergenza') == 'si') {

            getObj('MotivazioneDiEmergenza').disabled = false;

        }
    } catch (e) {}

}


function conferma_warning_emergenza(param)
{
	
	
	SetDomValue('AppaltoInEmergenza' , 'si' , 'si');
	SetTextValue('MotivazioneDiEmergenza', 'Appalto di Emergenza');
	$( "#finestra_modale_confirm" ).dialog( "close" );
	MySend(param,'wrng_data@@@no');
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
		
		url = encodeURIComponent( 'CustomDoc/AIC_LOAD.asp?IDDOC=' + IDDOC + '&TYPEDOC=BANDO_SEMPLIFICATO&lo=base' );
		NewWin = ExecFunctionSelf(pathRoot + 'ctl_library/path.asp?url=' + url + '&KEY=document'   ,  '' , '');
		
	}
	else
	{
		ExecFunctionCenter('../../CustomDoc/AIC_LOAD.asp?IDDOC=' + IDDOC + '&TYPEDOC=BANDO_SEMPLIFICATO' );
	}  
	
	
	
	//alert(IDDOC);
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
	// Per GGAP
	if(getObj('isSimogGgap') !== null && getObj('isSimogGgap') !== undefined)
	{
		// Il campo "Richiesta CIG su SIMOG" deve essere valorizzato a 'si'
		if(getObj('RichiestaCigSimog') !== null && getObj('RichiestaCigSimog') !== undefined && getObjValue('RichiestaCigSimog') === 'si')
		{
			if(getObjValue('isSimogGgap') === 1 || getObjValue('isSimogGgap') === '1')
			{
				// var ggapUnitaOrganizzative = getObj('GgapUnitaOrganizzative'); // il dominio: la select con le options
				var ggapUnitaOrganizzativeValue = getObj('val_GgapUnitaOrganizzative_extraAttrib').value.split('#=#')[1] // un input: campo nascosto che contiene il valore selezionato dall'utente (e salvato)
			
				if (ggapUnitaOrganizzativeValue !== null && ggapUnitaOrganizzativeValue !== undefined && ggapUnitaOrganizzativeValue !== '')
				{
					var statoDoc = getObj('StatoDoc').value; // ATTENZIONE: deve essere della richiesta_smart_cig
					var isDocDeleted = getObj('Deleted').value; // ATTENZIONE: deve essere della richiesta_smart_cig

					if (statoDoc === 'Inviato' && isDocDeleted == '0'){
						OpenGgapPageForSmartCig();
					}

					ExecDocProcess('RICHIESTA_SMART_CIG_GGAP,BANDO_GARA,,NO_MSG');
				}
				else
				{
					DMessageBox('../', 'NO_ML###Prima di fare la richiesta e\' necessario scegliere l\'unita\' organizativa.', 'Error', 2, 600, 400);
				}
			}
		}
	}
	else
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
}

//verifico che i campi di controllo siano valorizzati prima di invocare la stored 
function richiedi_documento_cig()
{
	// Per GGAP
	if(getObj('isSimogGgap') !== null && getObj('isSimogGgap') !== undefined)
	{
		// Il campo "Richiesta CIG su SIMOG" deve essere valorizzato a 'si'
		if(getObj('RichiestaCigSimog') !== null && getObj('RichiestaCigSimog') !== undefined && getObjValue('RichiestaCigSimog') === 'si')
		{
			if(getObjValue('isSimogGgap') === 1 || getObjValue('isSimogGgap') === '1')
			{
				// var ggapUnitaOrganizzative = getObj('GgapUnitaOrganizzative'); // il dominio: la select con le options
				var ggapUnitaOrganizzativeValue = getObj('val_GgapUnitaOrganizzative_extraAttrib').value.split('#=#')[1] // un input: campo nascosto che contiene il valore selezionato dall'utente (e salvato)
				// var richiestaCigSimog = getObj('RichiestaCigSimog'); // il dominio: la select con le options per il campo "Richiesta CIG su SIMOG"
				var richiestaCigSimog = getObj('val_RichiestaCigSimog_extraAttrib').value.split('#=#')[1] // un input: campo nascosto che contiene il valore selezionato dall'utente (e salvato)

				if ( richiestaCigSimog == 'si' )
				{
					if (ggapUnitaOrganizzativeValue !== null && ggapUnitaOrganizzativeValue !== undefined && ggapUnitaOrganizzativeValue !== '')
					{
						var statoDoc = getObj('StatoDoc').value;
						var isDocDeleted = getObj('Deleted').value;

						// Verifico se il documento RICHIESTA_CIG NON esiste
						if(statoDoc === '' || statoDoc === null || statoDoc === undefined || statoDoc === 'Annullato' || isDocDeleted == '1')
						{
							// Invoco il processo per creare il doc
							ExecDocProcess('RICHIESTA_CIG_GGAP,BANDO_GARA,,NO_MSG');
						}
						else if (statoDoc === 'Inviato') // Se doc RICHIESTA_CIG ha stato Inviato
						{
							OpenGgapPageForCig();
						}
						else
						{ 	// Apro doc RICHIESTA_CIG_GGAP					
	  						var document = 'RICHIESTA_CIG_GGAP';
	  						var idDocRichiestaCig = getObj('idDocR').value;
							ShowDocumentPath(document, idDocRichiestaCig, '../'); // Chiama la ShowDocument
						}
					}
					else
					{
						DMessageBox('../', 'NO_ML###Prima di fare la richiesta e\' necessario scegliere l\'unita\' organizativa.', 'Error', 2, 600, 400);
					}
				}
				else{
					DMessageBox('../', 'NO_ML###Prima di fare la richiesta e\' necessario impostare il campo "Richiesta CIG su SIMOG" a si.', 'Error', 2, 600, 400);
				}
			}
		}
	}
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
}

function onChangeMerceologia( obj )
{

    //Se il documento � editabile
    //if (getObj('DOCUMENT_READONLY').value == '0') 
	if ( isDocumentReadonly() == '0' )
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
	
	InitDrag_Drop ( 'DOCUMENTAZIONEGrid' );
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
	Move_Abstract( 'DOCUMENTAZIONEGrid', 'EvidenzaPubblica' , r  , verso );
	

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



function Handle_Attrib_MODULO_APPALTO_PNRR_PNC()
{
	
	
	DOCUMENT_READONLY = isDocumentReadonly(); //getObj('DOCUMENT_READONLY').value;
	
	//Blocco o sblocco le motivazioni PNRR/PNC a seconda del valore 
	onChangeAppalto_PNC();
	onChangeAppalto_PNRR();
	
	
	if (DOCUMENT_READONLY == 0) 
	{
		//se presente il campo Appalto_PNRR_PNC lo setto a true per PCP
		if (getObj('Appalto_PNRR_PNC')) 
		{
			getObj('Appalto_PNRR_PNC').checked = true ;
		}
	}
	
	
	
  
	
	// GGAP: se abbilitato il modulo SIMOG_GGAP allora nascondi campi per PNRR/PNC altrimenti lascia tutto come prima 
	if(getObj('isSimogGgap') !== null && getObj('isSimogGgap') !== undefined)
	{
		// Allo stesso tempo il campo "Richiesta CIG su SIMOG" deve essere valorizzato a 'si'
		if(getObj('RichiestaCigSimog') !== null && getObj('RichiestaCigSimog') !== undefined && getObjValue('RichiestaCigSimog') === 'si')
		{
			if(getObjValue('isSimogGgap') === 1 || getObjValue('isSimogGgap') === '1') {
				if (areAppaltoPnrrFieldsHidden == false) {
					// Nascondo i campi della sezione PNRR_PNC
					confermaHideCampiSimog();
					areAppaltoPnrrFieldsHidden = true;
				}
			}
		}
	}
	else
	{
	
		var val_SpuntaPNRR_PNC = 0;
		var Modulo_Attivo = 'yes';
		var HideCampi = 'no';
		
		
		Modulo_Attivo = getObj('ATTIVA_MODULO_PNRR_PNC').value  ;
		
		//se il modulo non attivo nascondo i campi
		if ( Modulo_Attivo == 'no' )
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
				val_SpuntaPNRR_PNC = 1 ;
		  }
		  else	
		  {
			// val_SpuntaPNRR_PNC = getObj('Appalto_PNRR_PNC').value;
			val_SpuntaPNRR_PNC = 1; //Cablato a 1 perchè sempre attivo se il modulo è attivo

		  }	

		  if ( val_SpuntaPNRR_PNC != 1)
	  
			  HideCampi = 'yes' ;
		}	


		//alert (val_SpuntaPNRR_PNC);
		//alert( 'Modulo_Attivo=' + Modulo_Attivo );
		//alert( 'HideCampi=' + HideCampi );

		//se ilmodulo attivo vado a nascondere i campi a seconda della spunta
		if ( Modulo_Attivo == 'yes' )
		{
			if ( HideCampi == 'yes')
			{	
				$("#cap_Appalto_PNRR").parents("table:first").parents("tr:first").css({"display": "none"});
				$("#cap_Motivazione_Appalto_PNRR").parents("table:first").parents("tr:first").css({"display": "none"});
				$("#cap_Appalto_PNC").parents("table:first").parents("tr:first").css({"display": "none"});
				$("#cap_Motivazione_Appalto_PNC").parents("table:first").parents("tr:first").css({"display": "none"});

				//Se i nuovi campi del simog esistono
				if ( getObj('cap_FLAG_PREVISIONE_QUOTA') )
				{
				
					$("#cap_FLAG_PREVISIONE_QUOTA").parents("table:first").parents("tr:first").css({"display": "none"});
					$("#cap_QUOTA_FEMMINILE").parents("table:first").parents("tr:first").css({"display": "none"});
					$("#cap_QUOTA_GIOVANILE").parents("table:first").parents("tr:first").css({"display": "none"});
					$("#cap_ID_MOTIVO_DEROGA").parents("table:first").parents("tr:first").css({"display": "none"});
					$("#cap_FLAG_MISURE_PREMIALI").parents("table:first").parents("tr:first").css({"display": "none"});
					$("#cap_ID_MISURA_PREMIALE").parents("table:first").parents("tr:first").css({"display": "none"});
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
}

function validaDatiSimogPNRR()
{
	var Modulo_Attivo = 'yes';
	
	Modulo_Attivo = getObj('ATTIVA_MODULO_PNRR_PNC').value;

	if ( Modulo_Attivo == 'yes' )
	{
		if ( getObj('Appalto_PNRR_PNC').checked )
		{
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
			
			if ( quotaFem == '' && quotaMaggiore == 'S' && ( quotaGio == '' || quotaGio == '0' ) )
			{
				DMessageBox('../', 'Non e stato indicato il valore della Previsione di una quota inferiore con riferimento occupazione femminile' , 'Attenzione', 1, 400, 300);
				DocShowFolder( 'FLD_COPERTINA' );
				return false;
			}
			
			//Se il campo quotaFem � valorizzato con una quota >=30%
			if ( Number(quotaFem) >= 30 )
			{
				DMessageBox('../', 'Il campo quota fem prevede l\'inserimento di una quota inferiore al 30'  , 'Attenzione', 1, 400, 300);
				DocShowFolder( 'FLD_COPERTINA' );
				return false;
			}
			
			//Se il campo 'QUOTA_GIOVANILE' non � valorizzato e il campo 'FLAG_PREVISIONE_QUOTA'= SI e 'QUOTA_FEMMINILE'=0%
			if ( quotaGio == '' && quotaMaggiore == 'S' && ( quotaFem == '' || quotaFem == '0' ) )
			{
				DMessageBox('../', 'Non e stato indicato il valore della Previsione di una quota inferiore con riferimento occupazione giovanile' , 'Attenzione', 1, 400, 300);
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

/* INIZIO Funzioni utili al modulo CN16 - modifiche retrocompatibili nel caso si voglia aggiornare questo JS senza l'attività 544634 */
function ValidateURL()
{
	//Controllo formale sull'url per il campo 'Indirizzo dei documenti di gara (BT-15)'
	
	// definizione dell'espressione regolare per verificare se la stringa è un URL HTTP o HTTPS valido
	var urlPattern = /^(https?):\/\/[^\s/$.?#].[^\s]*$/;
  
	var objUrlExtRef = getObj('cn16_CallForTendersDocumentReference_ExternalRef');
	var urlExtRef = objUrlExtRef.value;
  
	// Se l'url è diverso da vuoto si va a testare rispetto all'espressione regolare
	if ( urlExtRef != '' && !urlPattern.test(urlExtRef) )
	{
		objUrlExtRef.value = ''; //svuoto il campo considerato non valido
		DMessageBox('../', 'URL non valido. Non rispetta il formato richiesto', 'Attenzione', 1, 400, 300);
	}
	
}
function onChangePartecipazioneRiservata()
{
	//Funzione di onChange per il campo 'Partecipazione riservata (BT-71-Lot)'
	
	var valReservedProc = getObjValue('cn16_TendererRequirementTypeCode_reserved_proc');

	if ( valReservedProc == 'res-pub-ser' )
	{
		getObj('cn16_ExecutionRequirementCode_reserved_execution').value = 'false';
	}
	
	if ( valReservedProc == 'none' )
	{
		getObj('cn16_ExecutionRequirementCode_reserved_execution').value = 'false';
	}
	
	if ( valReservedProc == 'res-ws' )
	{
		getObj('cn16_ExecutionRequirementCode_reserved_execution').value = 'true';
	}

}

function downloadXmlCN16()
{

	var docReadOnly = '0';

	try
	{		
		docReadOnly = isDocumentReadonly(); //getObjValue('DOCUMENT_READONLY');
	}
	catch(e){}
	
	//Se il documento è editabile controlliamo la corretta imputazione dei campi, altrimenti procediamo direttamente con la generazione dell'xml
	if (docReadOnly == '0')
	{
		
		var listaCampiObblig = 'cn16_AuctionConstraintIndicator@cn16_ContractingSystemTypeCode_framework@cn16_FundingProgramCode_eu_funded@cn16_TendererRequirementTypeCode_reserved_proc@cn16_ExecutionRequirementCode_reserved_execution@cn16_CallForTendersDocumentReference_DocumentType@cn16_CallForTendersDocumentReference_ExternalRef@cn16_OrgRicorso_Name@cn16_OrgRicorso_ElectronicMail@cn16_OrgRicorso_CompanyID@cn16_OrgRicorso_CityName@cn16_OrgRicorso_Telephone@cn16_OrgRicorso_codnuts@cn16_OrgRicorso_cap';
		var vetObblig = listaCampiObblig.split( '@' );
		var lenVet =  vetObblig.length;
		var bFoundObblig = false;

		for( j = 0 ; j < lenVet ; j++ )
		{
			if ( getObjValue(vetObblig[j]) == '' )
			{
				bFoundObblig = true;
				TxtErr(vetObblig[j]);
			}
			else
			{
				TxtOK(vetObblig[j]);
			}
		}

		if ( bFoundObblig )
		{
			DMessageBox('../', 'Prima di procedere con il download compilare tutti i campi obbligatori della sezione Interoperabilita', 'Attenzione', 1, 400, 300);
		}
		else
		{
			//Eseguiamo il processo fittizio per salvare i campi sul db e nell'after 
			ExecDocProcess('XML_CN16:-1:CHECKOBBLIG,BANDO_GARA,,NO_MSG');
		}
		
		return;
	}

	//execDownloadXmlCN16(); non faccio fare più il download ma ripasso dal processo che fa i controlli e genera l'xml
	ExecDocProcess('XML_CN16:-1:CHECKOBBLIG,BANDO_GARA,,NO_MSG');

}

function execDownloadXmlCN16()
{
	//ExecDownloadSelf
	ExecFunction('../../eforms/cn16.asp?id=' + getObjValue('IDDOC') + '&idpfu=' + idpfuUtenteCollegato + '&operation=download', '_blank', '');
}

function execDownloadXmlCAN29()
{
	//La generazione dell'xml can29 ? stata effettuata dal processo XML_CAN29_DESERTA
	ExecFunction('../../eforms/can29.asp?id=' + getObjValue('IDDOC') + '&idpfu=' + idpfuUtenteCollegato + '&operation=download', '_blank', '');
}

function validaCodiceNUTS() 
{
  // l'espressione regolare che segue assume che un codice NUTS sia composto da lettere e numeri
  // e abbia una lunghezza minima di 3 caratteri e massima di 8

	var regex = /^[A-Za-z0-9]{3,8}$/;
	var objNuts = getObj('cn16_OrgRicorso_codnuts')
	var codiceNUTS = objNuts.value;

	if (codiceNUTS != '' && !regex.test(codiceNUTS))
	{
		objNuts.value = ''; //svuoto il campo considerato non valido
		DMessageBox('../', 'Codice NUTS non valido', 'Attenzione', 1, 400, 300);
	}

}

/* FINE Funzioni utili al modulo CN16 - modifiche retrocompatibili nel caso si voglia aggiornare questo JS senza l'attività 544634 */

function PRODOTTI_AFTER_COMMAND( param )
{
	
	try 
	{
		if (hasPCP()) 
		{
			PCP_showOrHideFields();
		}
	}
	catch (e)
	{
	}
	
	//gestisco la presenza dell'ampiezza di gamma sulla tabella lotti
		presenzaAmpiezzaDiGamma()
		
}

function PCP_CRONOLOGIA_AFTER_COMMAND(param)
{
	try{
		PCP_showOrHideFields()
	}catch{}
	
}

function OpenAmpiezzaDiGamma(objGrid, Row, c)
{	
	var voce = getObj('R'+ Row +'_Voce').value;
	var lotto = getObj('R'+ Row +'_NumeroLotto').value;
	var lotto_voce = lotto + '-' + voce
	var ampiezzaGamma = getObj('R'+ Row +'_AmpiezzaGamma').value;
	var IDDOC = getObj('IDDOC').value;

	if (voce == '0' || ampiezzaGamma == '0')
	{
		LocDMessageBox('../', 'Ampiezza di gamma non prevista per la riga', 'Attenzione', 1, 400, 300);
	}
	else
	{
		param ='OFFERTA_AMPIEZZA_DI_GAMMA##OFFERTA#'+ IDDOC +'###' + lotto_voce + '#' ;
		
		MakeDocFrom ( param ) ; 
	}

	
}

//gestisco la presenza dell'ampiezza di gamma sulla tabella lotti
function presenzaAmpiezzaDiGamma()
{
	var prsenzaModuloAmpiezzaGamma = '';
	
	try {
		prsenzaModuloAmpiezzaGamma= getObj('PresenzaModuloAmpiezzaGamma').value;
	} catch (error) {}
	
	if (prsenzaModuloAmpiezzaGamma == 'si')
	{
		try
		{
			var presenzaampiezzaGamma = getObj('PresenzaAmpiezzaDiGamma').value;
			if (presenzaampiezzaGamma == 'si')
			{
				ShowCol( 'PRODOTTI' , 'AmpiezzaGamma' , '' );
			}else
			{
				ShowCol( 'PRODOTTI' , 'AmpiezzaGamma' , 'none' );
			}
		}
		catch
		{
			
		}
	}
	else
	{
		ShowCol( 'PRODOTTI' , 'AmpiezzaGamma' , 'none' );
	}	
	
	//nascondo a prescindere il tasto perche non vi è alcuna operazione sul bando gara ma ha il modello condiviso con l'aggiudicazione
	try
	{
		ShowCol( 'BUSTA_TECNICA' , 'FNZ_OPEN' , 'none' );
	}
	catch
	{
		
	}
	
	try
	{
		ShowCol( 'BUSTA_ECONOMICA' , 'FNZ_OPEN' , 'none' );
	}
	catch
	{
		
	}
}


// Per salvare la descrizione dell'unita organizzativa scelta nel dropdown della sezione GGAP
function OnChangeGgapUnitaOrganizzative(thisObj)
{
	if(getObj('GgapUnitaOrganizzative') !== null && getObj('GgapUnitaOrganizzative') !== undefined)
	{
		getObj('Descrizione').value = thisObj.options[thisObj.selectedIndex].text;
	}
}

// Apro l'URL fornito da GGAP per completare il lavoro su GGAP
function OpenGgapPageForSmartCig()
{
	var idAzi=idaziAziendaCollegata;
	var idAziParam='idAzi=' + idAzi ;

	var idPfu=idpfuUtenteCollegato;
	var idPfuParam='idPfu=' + idPfu ;
	
	var idDocBandoGara = getObj('IDDOC').value;
	var idBandoGaraParam = 'idBandoGara=' + idDocBandoGara;

	var url = "/SimogGgapApi/SmartCig/GetGgapLandingPage?" + idAziParam + "&" + idPfuParam + "&" + idBandoGaraParam;
	
	ajax = GetXMLHttpRequest();	
	ajax.open("GET", url, false);

	ajax.send(null);
	
	if(ajax.readyState == 4) 
	{
		if (ajax.status === 200)
		{
			var responseArray = ajax.responseText.split('#');
			var response = responseArray[1].replaceAll('"', '');

			if (responseArray[0].includes('1')) {
				console.log('response: ' + response); // TODO
				window.open(response, '_blank');
			}
			else // if (responseArray[0].includes('0'))
			{
				index = response.indexOf('Error');
				if (index > -1)
					var responseError = response.slice(index); // var responseError = response.substr(index);
				else
					var responseError = response;

				DMessageBox('../', 'NO_ML###Errore nel ottenere l\'url per apprire la pagina di GGAP. - ' + responseError, 'Attenzione', 1, 400, 300);
			}
		}
		else
		{
			var ajaxError = "Error: " + JSON.parse(ajax.responseText).Message + ' - Status: ' + ajax.status + ', ' + ajax.statusText;
			DMessageBox('../', 'NO_ML###Errore nel chiamare il web server per ottenere la pagina di GGAP. - ' + ajaxError, 'Attenzione', 1, 600, 400);
		}
	}
}

// Apro l'URL fornito da GGAP per completare il lavoro su GGAP
function OpenGgapPageForCig()
{
	var idPfu=idpfuUtenteCollegato;
	var idPfuParam='idPfu=' + idPfu ;

	var idAzi=idaziAziendaCollegata;
	var idAziParam='idAzi=' + idAzi ;

	var idDocRichiestaCig = getObj('idDocR').value;
	var idRichiestaCigParam = 'idRichiestaCig=' + idDocRichiestaCig;

	var url = "/SimogGgapApi/Gara/GetGgapLandingPage?" + idPfuParam + "&" + idRichiestaCigParam + "&" + idAziParam;
	// var url = "/SimogGgapApi/Gara/GetGgapLandingPage?" + idPfuParam + "&" + idRichiestaCigParam;
	
	ajax = GetXMLHttpRequest();	
	ajax.open("GET", url, false);
	ajax.send(null);
	
	if(ajax.readyState == 4) 
	{
		if (ajax.status === 200)
		{
			var responseArray = ajax.responseText.split('#');
			var response = responseArray[1].replaceAll('"', '');

			if (responseArray[0].includes('1')) {
				console.log('response: ' + response); // TODO
				window.open(response, '_blank');
			}
			else // if (responseArray[0].includes('0'))
			{
				index = response.indexOf('Error');
				if (index > -1)
					var responseError = response.slice(index); // var responseError = response.substr(index);
				else
					 var responseError = response;

				DMessageBox('../', 'NO_ML###Errore nel ottenere l\'url per apprire la pagina di GGAP. - ' + responseError, 'Attenzione', 1, 400, 300);
			}
		}
		else
		{
			var ajaxError = "Error: " + JSON.parse(ajax.responseText).Message + ' - Status: ' + ajax.status + ', ' + ajax.statusText;
			DMessageBox('../', 'NO_ML###Errore nel chiamare il web server per ottenere la pagina di GGAP. - ' + ajaxError, 'Attenzione', 1, 600, 400);
		}
	}
}

// Per GGAP si invoca il processo BANDO_GARA-MODIFICA_RICHIESTA_CIG_GGAP
// Altrimenti si chiama la MakeDocFrom come si faceva in precedenza (com'era configurato nel afscd)
function GestioneCigModifica()
{
	if(getObj('isSimogGgap') !== null && getObj('isSimogGgap') !== undefined)
	{
		// Il campo "Richiesta CIG su SIMOG" deve essere valorizzato a 'si'
		if(getObj('RichiestaCigSimog') !== null && getObj('RichiestaCigSimog') !== undefined && getObjValue('RichiestaCigSimog') === 'si')
		{
			if(getObjValue('isSimogGgap') === 1 || getObjValue('isSimogGgap') === '1')
			{
				ExecDocProcess( 'MODIFICA_RICHIESTA_CIG_GGAP,BANDO_GARA,,NO_MSG');
			}
		}
	}
	else
	{
		MakeDocFrom('RICHIESTA_CIG##BANDO_MODIFICA_CIG');
	}
}

/* Start PCP */

function hasPCP() 
{
  return !!getObj("FLD_INTEROP");
}
function PCP_ConfermaAppalto() 
{
	
	//Effettuiamo prima i controlli che venivano fatti scattare all'invio della gara, superati questi si passa a quelli specifici per la pcp
	if ( MySend('', '', 1) == -1 ) 
		return -1;
	
	var isDocReadOnly = isDocumentReadonly();
	
	if ( isDocReadOnly == '0' )
	{
		if ( PCP_obbligatoryFields(true) == -1 )
		{
			DMessageBox('../', 'Prima di procedere con il download compilare tutti i campi obbligatori', 'Attenzione', 1, 400, 300);
			return ;
		}
		
		//Eseguo i controlli sul PNRR
		if (!validaDatiSimogPNRR())
		{
			return;
		}
	}
	
	//se ho superato tutti i controlli innesco il processo per il conferma appalto
	ExecDocProcess('CONTROLLI_BASE:-1:CHECKOBBLIG,BANDO_SEMPLIFICATO,,NO_MSG');
	
}



function PCP_obbligatoryFields(clicked) 
{
    var bFoundObblig = false;
	let listaCampiObblig ;
	
	TipoScheda = getObjValue('pcp_TipoScheda');
	
	//lista attrigbuti dafault (P1_16)
	//listaCampiObblig = 'CATEGORIE_MERC@DESC_LUOGO_ISTAT@CODICE_CPV@Appalto_PNRR@pcp_CodiceCentroDiCosto@pcp_MotivoUrgenza@pcp_ContrattiDisposizioniParticolari@pcp_PrestazioniComprese@pcp_ServizioPubblicoLocale@pcp_PrevedeRipetizioniCompl@pcp_Dl50@pcp_TipologiaLavoro@pcp_PrevedeRipetizioniOpzioni@pcp_Categoria@MOTIVO_COLLEGAMENTO';
	
	
	//P7_2
    if (TipoScheda == 'P7_2')
	{	
        //listaCampiObblig = 'Categorie_Merceologiche@Criteriio_scelta_fornitori@DESC_LUOGO_ISTAT@pcp_CodiceCentroDiCosto@pcp_CondizioniNegoziata@MOTIVAZIONE_CIG@TIPO_FINANZIAMENTO@MOTIVO_COLLEGAMENTO@pcp_ImportoFinanziamento@pcp_iniziativeNonSoddisfacenti@pcp_Categoria@pcp_lavoroOAcquistoPrevistoInProgrammazione@pcp_PrestazioniComprese@pcp_ServizioPubblicoLocale@pcp_PrevedeRipetizioniCompl@pcp_PrevedeRipetizioniOpzioni@strumentiSvolgimentoProcedure';
		listaCampiObblig = 'Appalto_PNRR@DESC_LUOGO_ISTAT@pcp_CodiceCentroDiCosto@pcp_CondizioniNegoziata@MOTIVAZIONE_CIG@TIPO_FINANZIAMENTO@MOTIVO_COLLEGAMENTO@pcp_ImportoFinanziamento@pcp_iniziativeNonSoddisfacenti@pcp_saNonSoggettaObblighi24Dicembre2015@pcp_Categoria@pcp_lavoroOAcquistoPrevistoInProgrammazione@pcp_PrestazioniComprese@pcp_ServizioPubblicoLocale@pcp_PrevedeRipetizioniCompl@pcp_PrevedeRipetizioniOpzioni@strumentiSvolgimentoProcedure';
		
		//if ( getObj('pcp_VersioneScheda') ) 
		//{
			//se l aversione superiore alla 01.00.01 aggiungo attributo cn16_CallForTendersDocumentReference_ExternalRef
			//if ( getObj('pcp_VersioneScheda').value >= '01.00.01' )
			//{	
			//	listaCampiObblig = listaCampiObblig  + '@cn16_CallForTendersDocumentReference_ExternalRef' ;
			//}
		//}
	}
	
	//Per tutte le schede se necessario setto l'obbligatorietà sul campo pcp_CodiceCentroDiCostoProponente
	var idAziAppaltante = getObjValue("Azienda");
	var idAziProponente_tmp = getObjValue("EnteProponente");
	var idAziProponente = idAziProponente_tmp.split("#")[0];
	
	if((idAziAppaltante.toUpperCase() != idAziProponente.toUpperCase()) && (idAziProponente) && (idAziProponente.length != 0) ){
		listaCampiObblig = listaCampiObblig + '@pcp_CodiceCentroDiCostoProponente ';
	}
	
	//Se il campo Appalto_PNRR è sì allora rendo obbligatori i seguenti campi:	
	//TODO: GESTIONE PER PNRR AD4 E TOGLIERE DALL'ARRAY QUI SOTTO AD4 PER INCLUDERE I CONTROLLI
	var schedeAppalto_PNRR = ['AD4', 'AD5'];
	
	if(!schedeAppalto_PNRR.includes(TipoScheda))
	{
		if(getObjValue('Appalto_PNRR') == 'si')
		{
			listaCampiObblig = listaCampiObblig  + '@FLAG_PREVISIONE_QUOTA@ID_MISURA_PREMIALE@CUP' ;
		}
	}
	
	let listaColonneObblig = ``;
	
    var vetCampiObblig = listaCampiObblig.split('@');
    let vetColonneObblig = listaColonneObblig.split('@');
    var lenVet = vetCampiObblig.length;
    let lenCVet = vetColonneObblig.length;
    

  for (j = 0; j < lenVet; j++) {

    let exception = (vetCampiObblig[j].indexOf("pcp_TipologiaLavoro") != -1 && getObj("val_TipoAppaltoGara_extraAttrib").value != "value#=#2");
    if(getObj(vetCampiObblig[j])){
		if (getObjValue(vetCampiObblig[j]) == '' && !exception) {
		  bFoundObblig = true;
		  if (clicked) {
			TxtErr(vetCampiObblig[j]);
		  }
		}
		else {
		  if (clicked) {
			TxtOK(vetCampiObblig[j]);
		  }
		}

		if (!clicked) {
            let cap_ = `cap_${vetCampiObblig[j]}`;
            try {
                getObj(cap_).parentElement.classList.add("VerticalModel_ObbligCaption");
            } catch { }
        }
	}

  }

  
  


  if (clicked) {
    if (bFoundObblig) {
      //DMessageBox('../', 'Prima di procedere con il download compilare tutti i campi obbligatori', 'Attenzione', 1, 400, 300);
	  return -1 
    }
    else {
      //ExecDocProcess('PCP_ConfermaAppalto,BANDO_GARA,,NO_MSG');
	  //ExecDocProcess('PCP_ConfermaAppalto:-1:CHECKOBBLIG,BANDO_GARA,,NO_MSG');
	  //ExecDocProcess('CONTROLLI_BASE:-1:CHECKOBBLIG,BANDO_SEMPLIFICATO,,NO_MSG');
	  return 0 ;
    }
  }

  return 0;
}




function PCP_RecuperaCig()
{
	ExecDocProcess('PCP_RecuperaCig,BANDO_GARA,,NO_MSG');
}




function PCP_CodiceCentroDiCosto(Ente) {

	var idAziAppaltante = getObjValue("Azienda");
	var idAziProponente_tmp = getObjValue("EnteProponente");
	var idAziProponente = idAziProponente_tmp.split("#")[0]; //Prendo la parte interessata dell'Azienda

	//Controllo se nascondere il campo Ente Proponente
	if((idAziAppaltante.toUpperCase() != idAziProponente.toUpperCase()) && (idAziProponente) && (idAziProponente.length != 0) ){
		//$("#pcp_CodiceCentroDiCostoProponente").parents("table:first").parents("tr:first").css({ "display": "" });
		getObj("cap_pcp_CodiceCentroDiCostoProponente").closest("td").parentElement.closest("td").style.display = '';
		//Lo rendo visivamente obbligatorio
		getObj('cap_pcp_CodiceCentroDiCostoProponente').parentNode.classList.replace("VerticalModel_Caption", "VerticalModel_ObbligCaption");
		
	}
	else{
		//$("#pcp_CodiceCentroDiCostoProponente").parents("table:first").parents("tr:first").css({ "display": "none" });
		getObj("cap_pcp_CodiceCentroDiCostoProponente").closest("td").parentElement.closest("td").style.display = 'none';
	}

	var DOCUMENT_READONLY = isDocumentReadonly();//getObj('DOCUMENT_READONLY').value;

    //se doc non editabile non faccio nulla
    if (DOCUMENT_READONLY == 1) {
        return;
    }

	var CN16_CODICE_APPALTO='';
	try
	{
		CN16_CODICE_APPALTO = getObj( 'CN16_CODICE_APPALTO').value;
	}
	catch(e){}
	
	//-- il codice appalto interno viene generato esclusivamente per le nuove procedure
	if ( CN16_CODICE_APPALTO != '' )
	{	
		var idAzi = '';

		//Recupero l'idAzi corretto a seconda dell'Ente indicato
		if(Ente == 'Proponente'){
			idAzi = idAziProponente
		}
		//Appaltante
		else{
			idAzi = idAziAppaltante;
		}


		ajax = GetXMLHttpRequest(); 
		var nocache = new Date().getTime();
		
		if(ajax)
		{
			const urlParams = new URLSearchParams(window.location.search.toLowerCase());
			const iddoc = urlParams.get('iddoc');
			ajax.open("GET", pathRoot + "../WebApiFramework/api/ConfermaAppalto/recuperaCDC?idDoc=" + iddoc + '&nocache=' + nocache, false);
			ajax.onreadystatechange = function () 
			{

				if(ajax.readyState == 4) 
				{
					var res = ajax.responseText;
					if(ajax.status == 200)
					{
						if ( res!= '' ) 
						{
							//console.table(res)
							var objCDCs = JSON.parse(res);
							var lenCDCs = objCDCs.length;
							var objCDCsToString = "";
							for(let i=0; i < lenCDCs; i++){
								objCDCsToString += objCDCs[i].idCentroDiCosto + "@@@" + objCDCs[i].denominazioneCentroDiCosto;
								if( i != (lenCDCs - 1)){
									objCDCsToString += "#~#";
								}
							}

							//In base all'Ente specificato seleziono un campo
							let objToModify;
							
							if(Ente == 'Proponente'){
								objToModify = getObj("pcp_CodiceCentroDiCostoProponente");
							}
							//Appaltante
							else{
								objToModify = getObj("pcp_CodiceCentroDiCosto");
							}
							
							
							if(DOCUMENT_READONLY == 1){
								let ainfo = objCDCsToString.split('#~#');
								let found = false;
								let denominazione = "";
								for ( k = 0 ; k < ainfo.length ;  k++ )
								{
									if(ainfo[k].split('@@@')[0] == objToModify.value){
										found = true;
										denominazione = ainfo[k].split('@@@')[1];
									}
								
								}
								let tecValue = objToModify.value;
								
								//In base all'Ente specificato seleziono un campo
								let objToModify;
								
								if(Ente == 'Proponente'){
									SetTextValue("pcp_CodiceCentroDiCostoProponente", denominazione);
								}
								//Appaltante
								else{
									SetTextValue("pcp_CodiceCentroDiCosto", denominazione);
								}
								
								objToModify.value = tecValue;
								
							}else{
								CRITERIO_Domain(objToModify, objCDCsToString);
							}
							
						}
					}
				}
			}

			ajax.send();

		}
		
	}
	
}

function PCP_PubblicaAvviso() {
  
   ExecDocProcess('PCP_PubblicaAvviso,BANDO_GARA,,NO_MSG');
}

function PCP_CancellaAppalto() {
  
   ExecDocProcess('PCP_CancellaAppalto,BANDO_GARA,,NO_MSG');
}





function PCP_showOrHideFields() 
{

  //<option value="15583" id="ProceduraGara_15583">   Affidamento Diretto    </option>
  //<option value="15476" id="ProceduraGara_15476">   Aperta                 </option>
  //<option value="15478" id="ProceduraGara_15478">   Negoziata              </option>
  //<option value="15479" id="ProceduraGara_15479">   Richiesta Preventivo   </option>
  //<option value="15477" id="ProceduraGara_15477">   Ristretta              </option>

  //TAB Interoperabilita 
  //Tipologia Lavoro display solo se Tipo di Appalto a Lavori pubblici
  try
  {
	  const val_TipoAppaltoGara_extraAttrib = getObj("val_TipoAppaltoGara_extraAttrib");
	  const pcp_TipologiaLavoro = getObj("pcp_TipologiaLavoro");
	  if (!!val_TipoAppaltoGara_extraAttrib && !!pcp_TipologiaLavoro) {
		if (val_TipoAppaltoGara_extraAttrib?.value != "value#=#2") {
		  if (typeof isFaseII !== 'undefined' && isFaseII) {
			pcp_TipologiaLavoro.closest(".col-12").style.display = "none";
		  } else {
			pcp_TipologiaLavoro.closest("tbody").closest("tbody").style.display = "none";
		  }
		}
	  }
   }catch{}
   
	
  //condizioni negoziata display solo se gara(Tipo di procedura) negoziata oppure Richiesta di preventivo
  /*
  SULL'APPALTO SPECIFICO LASCIO SEMPORE VISIBILE pcp_CondizioniNegoziata
  try
  {
	  const val_ProceduraGara_extraAttrib = getObj("val_ProceduraGara_extraAttrib");
	  const pcp_CondizioniNegoziata = getObj("pcp_CondizioniNegoziata");
	  if (!!val_ProceduraGara_extraAttrib && !!pcp_CondizioniNegoziata) {
		if ( val_ProceduraGara_extraAttrib?.value != "value#=#15478" && val_ProceduraGara_extraAttrib?.value != "value#=#15479" ) {
		  if (typeof isFaseII !== 'undefined' && isFaseII) {
			pcp_CondizioniNegoziata.closest(".col-12").style.display = "none";
		  } else {
			pcp_CondizioniNegoziata.closest("tbody").closest("tbody").style.display = "none";
		  }
		}
	  }
  }catch{}
  */
  
  //"L'esecuzione dell'appalto deve avvenire nel contesto di programmi di lavoro protetti (BT-736-Lot)" (cn16_ExecutionRequirementCode_reserved_execution) display none
  try
  {
	const cn16_ExecutionRequirementCode_reserved_execution = getObj("cn16_ExecutionRequirementCode_reserved_execution");
	  if (!!cn16_ExecutionRequirementCode_reserved_execution) {
		getObj("cap_cn16_ExecutionRequirementCode_reserved_execution").closest("td").parentElement.closest("td").style.display = 'none';
	  }

  }catch{}
  
 

    //End TAB Interoperabilità

  //TAB Lotti (PRODOTTIGrid)
  //Tipologia Lavoro display solo se Tipo di Appalto Lavori pubblici
  //const PRODOTTIGrid = getObj("PRODOTTIGrid");
  //let count = PRODOTTIGrid.firstElementChild.childElementCount - 1;
  
  try
  {
	  //recupero campo di testata
	  let TipoAppaltoGaraValue = getObjValue("TipoAppaltoGara");
	  
	  /*
	  let thPRODOTTIGrid_pcp_TipologiaLavoro = getObj("PRODOTTIGrid_pcp_TipologiaLavoro");
	  let indexpcp_TipologiaLavoro = 0;
	  for (let k = 0; k < thPRODOTTIGrid_pcp_TipologiaLavoro.parentElement.childElementCount; k++) {
		if (thPRODOTTIGrid_pcp_TipologiaLavoro.parentElement.children[k] == thPRODOTTIGrid_pcp_TipologiaLavoro) {
		  indexpcp_TipologiaLavoro = k;
		  break;
		}
	  }
	  */
	  
	  //Se non lavori pubblici nascondo
	  if ( TipoAppaltoGaraValue != 2 ) {
		
		ShowCol('PRODOTTI', 'pcp_TipologiaLavoro', 'none');
		
		/*
		getObj("PRODOTTIGrid_pcp_TipologiaLavoro").style.display = 'none';
		for (let h = 0; h < count; h++) {
		  getObj(`PRODOTTIGrid_r${h}_c${indexpcp_TipologiaLavoro}`).style.display = 'none'
		}
		*/
		
	  }
	  
	  //se la procedura NON e una negoziata oppure una Richiesta di preventivo ( RDP ) nascondo la colonna pcp_CondizioniNegoziata
	  /*SULL'APPALTO SPECIFICO LASCIO SEMPORE VISIBILE pcp_CondizioniNegoziata
	  if ( val_ProceduraGara_extraAttrib?.value != "value#=#15478" && val_ProceduraGara_extraAttrib?.value != "value#=#15479" )
	  {
		ShowCol('PRODOTTI', 'pcp_CondizioniNegoziata', 'none');
	  } 
	  */
  }catch{}
  

  //TipoAppaltoGara display none perche prima era stata chiesta e poi da togliere
  //rimasta nel modello 
  ShowCol('PRODOTTI', 'pcp_TipoAppaltoGara', 'none');
  
  /*
  try
  {
	  let indexpcp_TipoAppaltoGara = 0;
	  let thPRODOTTIGrid_pcp_TipoAppaltoGara = getObj("PRODOTTIGrid_pcp_TipoAppaltoGara");
	  for (let k = 0; k < thPRODOTTIGrid_pcp_TipoAppaltoGara.parentElement.childElementCount; k++) {
		if (thPRODOTTIGrid_pcp_TipoAppaltoGara.parentElement.children[k] == thPRODOTTIGrid_pcp_TipoAppaltoGara) {
		  indexpcp_TipoAppaltoGara = k;
		  break;
		}
	  }
	  getObj("PRODOTTIGrid_pcp_TipoAppaltoGara").style.display = 'none';
	  for (let h = 0; h < count; h++) {
		getObj(`PRODOTTIGrid_r${h}_c${indexpcp_TipoAppaltoGara}`).style.display = 'none'
	  }
  }catch{}
  */

  //Importo Lavori / Servizi / Forniture
  //let addedTH = PRODOTTIGrid.firstElementChild.firstElementChild.appendChild(PRODOTTIGrid.firstElementChild.firstElementChild.lastElementChild.cloneNode());
  //addedTH.innerText = "Importo " + (TipoAppaltoGaraValue == 1 ? "Forniture" : TipoAppaltoGaraValue == 2 ? "Lavori" : "Servizi");
  ////1 -> Forniture
  ////2 -> Lavori Pubblici
  ////3 -> Servizi
  //let indexPRODOTTIGrid_VALORE_BASE_ASTA_IVA_ESCLUSA = 0;
  //let thPRODOTTIGrid_VALORE_BASE_ASTA_IVA_ESCLUSA = getObj("PRODOTTIGrid_VALORE_BASE_ASTA_IVA_ESCLUSA");
  //for (let k = 0; k < thPRODOTTIGrid_VALORE_BASE_ASTA_IVA_ESCLUSA.parentElement.childElementCount; k++) {
  //    if (thPRODOTTIGrid_VALORE_BASE_ASTA_IVA_ESCLUSA.parentElement.children[k] == thPRODOTTIGrid_VALORE_BASE_ASTA_IVA_ESCLUSA) {
  //        indexPRODOTTIGrid_VALORE_BASE_ASTA_IVA_ESCLUSA = k;
  //        break;
  //    }
  //}
  ////per ogni riga della PRODOTTIGrid
  //for (let k = 1; k < (count + 1); k++) {
  //    let addedTD = PRODOTTIGrid.firstElementChild.children[k].appendChild(PRODOTTIGrid.firstElementChild.children[k].children[indexPRODOTTIGrid_VALORE_BASE_ASTA_IVA_ESCLUSA].cloneNode())
  //    PRODOTTIGrid.firstElementChild.children[k].children[indexPRODOTTIGrid_VALORE_BASE_ASTA_IVA_ESCLUSA].onchange = (e) => {
  //        addedTD.querySelectorAll("input[type=text]")[0].value = e.target.value;
  //    }
  //    addedTD.innerHTML = PRODOTTIGrid.firstElementChild.children[k].children[indexPRODOTTIGrid_VALORE_BASE_ASTA_IVA_ESCLUSA].innerHTML;
  //    addedTD.querySelectorAll("input[type=text]")[0].setAttribute("disabled", "true");
  //}

  //Importo Totale Sicurezza
  //let addedTH2 = PRODOTTIGrid.firstElementChild.firstElementChild.appendChild(PRODOTTIGrid.firstElementChild.firstElementChild.lastElementChild.cloneNode());
  //addedTH2.innerText = "Importo Totale Sicurezza";
  //let indexPRODOTTIGrid_IMPORTO_ATTUAZIONE_SICUREZZA = 0;
  //let thPRODOTTIGrid_IMPORTO_ATTUAZIONE_SICUREZZA = getObj("PRODOTTIGrid_IMPORTO_ATTUAZIONE_SICUREZZA");
  //for (let k = 0; k < thPRODOTTIGrid_IMPORTO_ATTUAZIONE_SICUREZZA.parentElement.childElementCount; k++) {
  //    if (thPRODOTTIGrid_IMPORTO_ATTUAZIONE_SICUREZZA.parentElement.children[k] == thPRODOTTIGrid_IMPORTO_ATTUAZIONE_SICUREZZA) {
  //        indexPRODOTTIGrid_IMPORTO_ATTUAZIONE_SICUREZZA = k;
  //        break;
  //    }
  //}
  //per ogni riga della PRODOTTIGrid
  //for (let k = 1; k < (count + 1); k++) {
  //    let addedTD2 = PRODOTTIGrid.firstElementChild.children[k].appendChild(PRODOTTIGrid.firstElementChild.children[k].children[indexPRODOTTIGrid_IMPORTO_ATTUAZIONE_SICUREZZA].cloneNode())
  //    PRODOTTIGrid.firstElementChild.children[k].children[indexPRODOTTIGrid_IMPORTO_ATTUAZIONE_SICUREZZA].onchange = (e) => {
  //        addedTD2.querySelectorAll("input[type=text]")[0].value = e.target.value;
  //    }
  //    addedTD2.innerHTML = PRODOTTIGrid.firstElementChild.children[k].children[indexPRODOTTIGrid_IMPORTO_ATTUAZIONE_SICUREZZA].innerHTML;
  //    addedTD2.querySelectorAll("input[type=text]")[0].setAttribute("disabled", "true");
  //}

  /*
    //SPOSTATA LOGICA NELLA SP CONCATENA_MODELLO_INTEROPERABILITA
    //Somme Opzioni Rinnovi display none se IMPORTO_OPZIONI è presente
    const PRODOTTIGrid_IMPORTO_OPZIONI = getObj("PRODOTTIGrid_IMPORTO_OPZIONI")
    if (!!PRODOTTIGrid_IMPORTO_OPZIONI) {
        let PRODOTTIGrid_pcp_SommeOpzioniRinnovi = getObj("PRODOTTIGrid_pcp_SommeOpzioniRinnovi");
        PRODOTTIGrid_pcp_SommeOpzioniRinnovi.style.display = "none"
        let indexOfPRODOTTIGrid_pcp_SommeOpzioniRinnovi = 0;
        for (let i = 0; i < PRODOTTIGrid_pcp_SommeOpzioniRinnovi.parentElement.childElementCount; i++) {
            if (PRODOTTIGrid_pcp_SommeOpzioniRinnovi.parentElement.children[i] == PRODOTTIGrid_pcp_SommeOpzioniRinnovi) {
                indexOfPRODOTTIGrid_pcp_SommeOpzioniRinnovi = i;
            }
        }
        for (let h = 0; h < count; h++) {
            getObj(`PRODOTTIGrid_r${h}_c${indexOfPRODOTTIGrid_pcp_SommeOpzioniRinnovi}`).style.display = 'none'
        }
    
  }
   */
  //End TAB Lotti


  //TAB Testata
  //Richiesta CIG display none, questo campo deve essere nascosto in quanto con la PCP deve essere sempre settato a false quindi non ha senso mostrarlo
  try
  {
	  const RichiestaCigSimog = getObj("RichiestaCigSimog");
	  if (!!RichiestaCigSimog) {
		getObj("cap_RichiestaCigSimog").closest("td").parentElement.closest("td").style.display = 'none';
	  }
  }catch{}

  //Invio GUUE display none
  try
  {
	  const RichiestaTED = getObj("RichiestaTED");
	  if (!!RichiestaTED) {
		getObj("cap_RichiestaTED").closest("td").parentElement.closest("td").style.display = 'none';
	  }
  }catch{}

  //Appalto PNRR/PNC deve essere sempre visibile
  try
  {
	  const appalto_PNRR_PNC = getObj("Appalto_PNRR_PNC");
	  if (!!appalto_PNRR_PNC) {
		if (getObj('isSimogGgap')) {
		  getObj('isSimogGgap').style.display = "none";
		}
		getObj("Appalto_PNRR_PNC").checked = true;
		
		//getObj("Appalto_PNRR_PNC").disabled = true;
				
		//getObj("Appalto_PNRR_PNC").onchange = Blocca_Appalto_PNRR_PNC ;
		
		$("#cap_Motivazione_Appalto_PNRR").parents("table:first").parents("tr:first").css({ "display": "" });
	  }
  }catch{}
  

  //End TAB Testata

  //TAB CronologiaPCP
  try
  {
	  
	  let thPCP_CRONOLOGIAGrid_StatoFunzionale = getObj("PCP_CRONOLOGIAGrid_StatoFunzionale");
	  let thPCP_CRONOLOGIAGrid_Name = getObj("PCP_CRONOLOGIAGrid_Name");
	  let thPCP_CRONOLOGIAGrid_Titolo = getObj("PCP_CRONOLOGIAGrid_Titolo");
	  let thPCP_CRONOLOGIAGrid_TipoScheda = getObj("PCP_CRONOLOGIAGrid_TipoScheda");
	  let thPCP_CRONOLOGIAGrid_TipoDoc = getObj("PCP_CRONOLOGIAGrid_TipoDoc");
	  let indexOfthPCP_CRONOLOGIAGrid_StatoFunzionale = 0;
	  let indexOfthPCP_CRONOLOGIAGrid_Name = 0;
	  let indexOfthPCP_CRONOLOGIAGrid_Titolo = 0;
	  let indexOfthPCP_CRONOLOGIAGrid_TipoScheda = 0;
	  let indexOfthPCP_CRONOLOGIAGrid_TipoDoc = 0;
	  for (let i = 0; i < thPCP_CRONOLOGIAGrid_StatoFunzionale.parentElement.childElementCount; i++) {
		if (thPCP_CRONOLOGIAGrid_StatoFunzionale.parentElement.children[i] == thPCP_CRONOLOGIAGrid_StatoFunzionale) {
		  indexOfthPCP_CRONOLOGIAGrid_StatoFunzionale = i;
		}
		if (thPCP_CRONOLOGIAGrid_StatoFunzionale.parentElement.children[i] == thPCP_CRONOLOGIAGrid_Name) {
			indexOfthPCP_CRONOLOGIAGrid_Name = i;
		  }
		if (thPCP_CRONOLOGIAGrid_StatoFunzionale.parentElement.children[i] == thPCP_CRONOLOGIAGrid_Titolo){
			indexOfthPCP_CRONOLOGIAGrid_Titolo = i;
		}
		if (thPCP_CRONOLOGIAGrid_StatoFunzionale.parentElement.children[i] == thPCP_CRONOLOGIAGrid_TipoScheda){
			indexOfthPCP_CRONOLOGIAGrid_TipoScheda = i;
		}
		if (thPCP_CRONOLOGIAGrid_StatoFunzionale.parentElement.children[i] == thPCP_CRONOLOGIAGrid_TipoDoc){
			indexOfthPCP_CRONOLOGIAGrid_TipoDoc = i;
		}
	  }
	  trCountCronologiaPCP = getObj("PCP_CRONOLOGIAGrid").firstElementChild.childElementCount - 1;
		const textToDownloadButton = (FldDomainValue, TipoScheda, Operazione, num) => {
			let file = FldDomainValue.innerText;
			if (!!file && `${file}`.trim().length > 0) {
				let extType;
				if (file.indexOf("<?") == 0) {
					extType = "xml";
				} else if (file.indexOf("{") == 0) {
					extType = "json";
				} else {
					extType = "txt";
				}
				FldDomainValue.innerText = "";
				FldDomainValue.innerHTML = ``;
				let a1 = document.createElement("a");
				let img1 = document.createElement("img");
				a1.setAttribute("href", "#");
				a1.setAttribute("class", "fldLabel_link_img");
				a1.onclick = () => {
					let filename;
					if(!!TipoScheda && TipoScheda.trim() != "" && !!Operazione){
						filename = (Operazione + "_" + TipoScheda);
					}else if(!!Operazione){
						filename = Operazione;
					}else{
						filename = file;
					}
					if(num == 1){
						filename += "_Request";
					}else if(num==2){
						filename += "_Response";
					}
					filename = filename + "." + extType;
					
					
					var element = document.createElement('a');
					element.setAttribute('href', 'data:text/plain;charset=utf-8,' + encodeURIComponent(file));
					element.setAttribute('download', filename);

					element.style.display = 'none';
					document.body.appendChild(element);

					element.click();

					document.body.removeChild(element);
				}
				img1.setAttribute("class", "img_label_alt")
				img1.setAttribute("alt", "Download " + extType)
				img1.setAttribute("src", "../../CTL_Library/images/Domain/downloadXml.png")
				img1.setAttribute("title", "Download " + extType)
				img1.setAttribute("style", "width: 25px")
				a1.appendChild(img1);
				FldDomainValue.appendChild(a1);
			}

		}
		
		const textToDownloadButtonLink = (FldDomainValue, idRow, idRic, TipoScheda, Operazione, request, content) => 
		{
			FldDomainValue.innerText = "";
			FldDomainValue.innerHTML = ``;

			if ( content != 'NONE' )
			{

				let a1 = document.createElement("a");
				let img1 = document.createElement("img");
				a1.setAttribute("href", "#");
				a1.setAttribute("class", "fldLabel_link_img");
				
				a1.onclick = () => {
									
					var element = document.createElement('a');
					element.setAttribute('href', '../../pcp/PCP_DownloadPayload.asp?ID=' + idRow + '&IDRIC=' + idRic + '&REQ=' + request + '&SCHEDA=' + TipoScheda + '&OPERATION=' + Operazione);
					element.style.display = 'none';
					document.body.appendChild(element);

					element.click();

					document.body.removeChild(element);
				}
				
				img1.setAttribute("class", "img_label_alt")
				img1.setAttribute("alt", "Download payload")
				img1.setAttribute("src", "../../CTL_Library/images/Domain/downloadXml.png")
				img1.setAttribute("title", "Download payload")
				img1.setAttribute("style", "width: 25px")
				a1.appendChild(img1);
				FldDomainValue.appendChild(a1);
		
			}

		}
		
		
		const textTruncate = (elem) => {
			if (`${elem.innerText}`.trim().length > 50) {
				elem.innerText = elem.innerText.substr(0, 50) + "...";
			}
		}

	  for (let i = 0; i < PCP_CRONOLOGIAGrid_NumRow + 1; i++) 
	  {
		  if(getObj(`PCP_CRONOLOGIAGrid_r${i}_c${indexOfthPCP_CRONOLOGIAGrid_Name}`) == null){ continue; }
		  let TextValueName = getObj(`PCP_CRONOLOGIAGrid_r${i}_c${indexOfthPCP_CRONOLOGIAGrid_Name}`).getElementsByClassName("Text")[0];
		  let FldDomainValueStatoFunzionale = getObj(`PCP_CRONOLOGIAGrid_r${i}_c${indexOfthPCP_CRONOLOGIAGrid_StatoFunzionale}`).getElementsByClassName("FldDomainValue")[0];
		  let TextValueTitolo = getObj(`PCP_CRONOLOGIAGrid_r${i}_c${indexOfthPCP_CRONOLOGIAGrid_Titolo}`).getElementsByClassName("Text")[0];
		  let TipoScheda = getObj(`PCP_CRONOLOGIAGrid_r${i}_c${indexOfthPCP_CRONOLOGIAGrid_TipoScheda}`).getElementsByClassName("Text")[0].innerText;
		  let Operazione = getObj(`PCP_CRONOLOGIAGrid_r${i}_c${indexOfthPCP_CRONOLOGIAGrid_TipoDoc}`).getElementsByClassName("FldDomainValue")[0].innerText;

		  let idRow = getObjValue(`R${i}_idRow`);
		  let idRic = getObjValue('IDDOC');

		  //let respContent = getObjValue('val_R${i}_StatoFunzionale_extraAttrib');
		  let respContent = getExtraAttrib(`val_R${i}_StatoFunzionale`, 'value');
		  //getObjValue('val_R${i}_StatoFunzionale_extraAttrib');

		  let reqContent = getObjValue(`R${i}_Name`);

		  //textToDownloadButton(TextValueName, TipoScheda, Operazione, 1);
		  //textToDownloadButton(FldDomainValueStatoFunzionale, TipoScheda, Operazione, 2);

		  textToDownloadButtonLink(TextValueName, idRow, idRic, TipoScheda.trim(), Operazione, 1, reqContent);
		  textToDownloadButtonLink(FldDomainValueStatoFunzionale, idRow, idRic, TipoScheda.trim(), Operazione, 0, respContent);

		  textTruncate(TextValueTitolo);
		}
   }catch{}

  //End TAB CronologiaPCP

}


function PCP_ConfermaAppalto_End() 
{
	DMessageBox('../', 'Conferma appalto eseguito correttamente', 'Informazione', 1, 400, 300);  
}

function PCP_PubblicaAvviso_End() 
{
	DMessageBox('../', 'Pubblica Avviso eseguito correttamente', 'Informazione', 1, 400, 300); 
}

function PCP_CancellaAppalto_End() 
{
	DMessageBox('../', 'Cancella Appalto eseguito correttamente', 'Informazione', 1, 400, 300);  
}

function PCP_RecuperaCig_End() 
{
	DMessageBox('../', 'Recupera CIG eseguito correttamente', 'Informazione', 1, 400, 300);  
}


/* End PCP */



function isDocumentReadonly()
{
	var docReadonly = '0';
	
	if (typeof InToPrintDocument !== 'undefined' || getObjValue('StatoFunzionale') == 'InApprove')
	{
		docReadonly = '1';
    }
    else
	{
		//Dopo aver introdotto la condizione di readonly su tutte le sezioni meno quella degli atti, la variabile DOCUMENT_READONLY non era più veritiera.
		//	perchè il documento cmq non era readonly ma di fatto tutti i dati si, compresa la testata. sfruttiamo quindi un campo "civetta" di testata
		//	per capirlo. Body_V
		if ( getObj('Body_V') ) //Se esiste il campo "Oggetto" di testata. nella sua forma visuale readonly
			docReadonly = '1';
		else
			docReadonly = getObj('DOCUMENT_READONLY').value;
    }

	return docReadonly;
	
}

function onChangeAppalto_PNRR()
{
	try
	{	
		DOCUMENT_READONLY = isDocumentReadonly();
		
		var Appato_PNRR_val = getObjValue('Appalto_PNRR')
		
		if (DOCUMENT_READONLY == 0)
		{
			if(Appato_PNRR_val == 'si')
			{
				SelectreadOnly('Motivazione_Appalto_PNRR', false);
				
				//Se Appalto_PNRR è valorizzato a si rendo visivamente obbligatori i seguenti campi:
				getObj('cap_FLAG_PREVISIONE_QUOTA').parentNode.classList.replace("VerticalModel_Caption", "VerticalModel_ObbligCaption");
				getObj('cap_ID_MISURA_PREMIALE').parentNode.classList.replace("VerticalModel_Caption", "VerticalModel_ObbligCaption");
				getObj('cap_CUP').parentNode.classList.replace("VerticalModel_Caption", "VerticalModel_ObbligCaption");
				
				//Avvaloro e blocco i seguenti campi
				getObj('FLAG_MISURE_PREMIALI').value = 'S'
				getObj('cap_FLAG_MISURE_PREMIALI').parentNode.classList.replace("VerticalModel_Caption", "VerticalModel_ObbligCaption");
				SelectreadOnly('FLAG_MISURE_PREMIALI', true);
			}
			else
			{
				SelectreadOnly('Motivazione_Appalto_PNRR', true);
				
				//Se Appalto_PNRR è valorizzato a no tolgo l'obbligatorietà dai seguenti campi:
				getObj('cap_FLAG_PREVISIONE_QUOTA').parentNode.classList.replace("VerticalModel_ObbligCaption", "VerticalModel_Caption");
				getObj('cap_ID_MISURA_PREMIALE').parentNode.classList.replace("VerticalModel_ObbligCaption", "VerticalModel_Caption");
				getObj('cap_CUP').parentNode.classList.replace("VerticalModel_ObbligCaption", "VerticalModel_Caption");
				getObj('cap_FLAG_MISURE_PREMIALI').parentNode.classList.replace("VerticalModel_ObbligCaption", "VerticalModel_Caption");
				SelectreadOnly('FLAG_MISURE_PREMIALI', false);
			}
		}
	}
	catch
	{ 
	}
}

function onChangeAppalto_PNC()
{
	DOCUMENT_READONLY = isDocumentReadonly();
	
	if (DOCUMENT_READONLY == 0){
		if(getObj('Appalto_PNC').value != 'si'){
			SelectreadOnly('Motivazione_Appalto_PNC', true);
		}
		else{
			SelectreadOnly('Motivazione_Appalto_PNC', false);
		}
	}
}

