//window.onload = onLoadFunc;
$( document ).ready(function() {
    onLoadFunc();
});

function onLoadFunc()
{
	
	var indexCollaborazione = getObjValue('indexCollaborazione');
	var TipoDoc_collegato = getObjValue('TipoDoc_collegato');
	var DOCUMENT_READONLY = '0';
	DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;
	

	//-- display colonne con pertinenza se non è una modifica vanno nascoste le colonne per la cancellazione e l'azione proposta
	if( getObjValue( 'JumpCheck' ) == '' )
	{
		ShowCol( 'LOTTI' , 'AzioneProposta' , 'none' );		
		ShowCol( 'LOTTI' , 'MOTIVO_CANCELLAZIONE_LOTTO' , 'none' );		
		ShowCol( 'LOTTI' , 'note_canc' , 'none' );		
		
		$("#cap_AzioneProposta").parents("table:first").css({"display": "none"})	 
	}
	
	/* Se non è stato ancora scelto l'ufficio di appartenenza */
	/*
	if (DOCUMENT_READONLY == '0')
	{
		
		if ( indexCollaborazione == '' )
			getUffici();
	}
	*/
	
	//l'ambito degli ordinativi di fornitura, nel documento di richiesta del CIG derivato a 
	//cui si accede da "Gestione CIG>>Richiesta CIG", nascondere dalla tabella "Elenco Lotti" 
	//le colonne “Di Cui Per Opzioni” e “Di Cui Per Attuazione Della Sicurezza”.
	if ( TipoDoc_collegato == 'ODC' )
	{
		ShowCol( 'LOTTI' , 'IMPORTO_OPZIONI' , 'none' );	
		ShowCol( 'LOTTI' , 'IMPORTO_ATTUAZIONE_SICUREZZA' , 'none' );	
	}
	
	var versioneDoc = getObj('Versione');
	
	if ( versioneDoc )
	{
		
		if ( versioneDoc.value == 'SIMOG_GET' )
		{
			ShowCol( 'LOTTI' , 'NumeroLotto' , 'none' );
		}
		
	}
	
	//var numrow = GetProperty( getObj('LOTTIGrid') , 'numrow');
	var NumRow = eval( 'LOTTIGrid_EndRow;' );
	var nStartRow=eval( 'LOTTIGrid_StartRow;' );	
	try
	{
		
		for ( i = nStartRow ; i <= NumRow ; i++ )
	
		{	
			Onchange_Tipocontratto(getObj('RLOTTIGrid_' + i + '_TIPO_CONTRATTO'));
		}
	}catch(e){}
	

	
}

function afterProcess( param )
{
}

function getUffici(daBottone, daSend)
{
	
	try
	{
		
		if (daBottone === undefined)	daBottone = '0';
		if (daSend === undefined)	daSend = '0';
		
		/* RICARICO I PERMESSI DELL'UTENTE COLLEGATO */
		ajax = GetXMLHttpRequest(); 
		var nocache = new Date().getTime();

		var idpfuRup = getObjValue('idpfuRup');
		
		if(ajax)
		{
			ajax.open("GET", pathRoot + 'simog/selezionaUfficio.aspx?TEST_PWD=0&ufp=' + idpfuRup + '&nocache=' + nocache, false);
			ajax.send(null);
			
			if(ajax.readyState == 4) 
			{
				
				var res = ajax.responseText;

				//Se non ci sono stati errori di runtime
				if(ajax.status == 200)
				{
					if ( res!= '' ) 
					{
						var objOutputUffici = JSON.parse(res);
						
						var numeroUffici = objOutputUffici.uffici.collaborazioni.length;
						
						//Se il numero degli uffici di collaborazione associati all'utenza rup è di 1 unità, lo seleziono in automatico 
						//	( a meno che non è stato cliccato il bottone di seleziona ufficio, in quel caso mostreremo la lista anche con un unico elemento )
						if ( numeroUffici == 1 ) //&& daBottone == '0' )
						{
							var azienda_codiceFiscale = objOutputUffici.uffici.collaborazioni[0].azienda_codiceFiscale;
							
							//Se è prevista la password per il login SIMOG e per il rup scelto non è presente, attiviamo il meccanismo di richiesta PWD SIMOG
							if ( azienda_codiceFiscale == 'PASSWORD' )
							{
								alertSendToSimogPwd();
							}
							else
							{
								var azienda_denominazione  = objOutputUffici.uffici.collaborazioni[0].azienda_denominazione;
								//var idOsservatorio  = objOutputUffici.uffici.collaborazioni[0].idOsservatorio;
								var index  = objOutputUffici.uffici.collaborazioni[0].index;
								var ufficio_denominazione  = objOutputUffici.uffici.collaborazioni[0].ufficio_denominazione;
								var ufficio_id  = objOutputUffici.uffici.collaborazioni[0].ufficio_id;
								//var ufficio_profilo  = objOutputUffici.uffici.collaborazioni[0].ufficio_profilo;

								assegnaUfficio(ufficio_id,ufficio_denominazione,azienda_codiceFiscale,azienda_denominazione,index,daSend);

								DMessageBox( '../ctl_library/' , 'Trovato un unico ufficio di collaborazione, assegnato automaticamente' , 'Attenzione' , 1 , 400 , 300 );
								
							}
							
						}
						else
						{
							/* DISEGNO LA LISTA DI SCELTA UFFICI */
							//alert('GESTIONE UFFICI MULTIPLI DA IMPLEMENTARE');
							
							var htmlUffici = '<div id="div_scelta_ufficio_simog"><span id="help_scelta_ufficio_simog">' + CNV( pathRoot,'Selezionare sull\'ufficio di pertinenza per effettuare le richieste CIG al SIMOG') + '</span><hr/><ul>';
							
							for (i = 0; i < numeroUffici; i++) 
							{
								var ufficio = objOutputUffici.uffici.collaborazioni[i];
								
								var azienda_codiceFiscale = ufficio.azienda_codiceFiscale;
								var azienda_denominazione  = ufficio.azienda_denominazione;
								var index  = ufficio.index;
								var ufficio_denominazione  = ufficio.ufficio_denominazione;
								var ufficio_id  = ufficio.ufficio_id;
								
								htmlUffici += '<li>';
								
								htmlUffici += '<a href="#" onClick="assegnaUfficio(\'' + escapeLocalJS(ufficio_id) + '\',\'' + escapeLocalJS(ufficio_denominazione) + '\',\'' + escapeLocalJS(azienda_codiceFiscale) + '\',\'' + escapeLocalJS(azienda_denominazione) + '\',' + index + ', \'' + daSend + '\')">' + ufficio_denominazione + '</a>';
								
								htmlUffici += '</li>';
								
								htmlUffici += '<br/>';
								
							}
							
							htmlUffici += '</ul></div>';
							
							getObj('finestra_modale').innerHTML = htmlUffici;
							getObj('finestra_modale').setAttribute('title','Scelta ufficio');
							
							//$( "#finestra_modale" ).dialog('destroy').remove();
							
							//Init della dialog per evitare l'errore di jquery cannot call methods on dialog prior to initialization; attempted to call method 'close'
							$( "#finestra_modale" ).dialog({
								  resizable: false,
								  //height:140,
								  modal: true,
								});
							
							//$( "#finestra_modale" ).dialog("open");
							

						}
						
					}
				}
				else
				{
					alert('ERRORE NEL RECUPERO DEGLI UFFICI : ' + res);
				}
			}
		}
	}
	catch(e)
	{
		alert(e.message);
	}	
	
}

function setHiddenAndVisual(nomeCampo, value)
{
	
	getObj(nomeCampo).value = value;
	
	if ( getObj(nomeCampo + '_V') )
	{
		getObj(nomeCampo + '_V').innerHTML = value;
	}

}

function assegnaUfficio(ufficio_id,ufficio_denominazione,azienda_codiceFiscale,azienda_denominazione,index, daSend)
{
	setHiddenAndVisual('ID_STAZIONE_APPALTANTE', ufficio_id);
	setHiddenAndVisual('DENOM_STAZIONE_APPALTANTE', ufficio_denominazione);
	setHiddenAndVisual('CF_AMMINISTRAZIONE', azienda_codiceFiscale);
	setHiddenAndVisual('DENOM_AMMINISTRAZIONE', azienda_denominazione);
	
	getObj('indexCollaborazione').value = index;
	
	try
	{
		$( "#finestra_modale" ).dialog( "close" );
	}
	catch(e){}
	
	if ( daSend == '1' )
	{
		mySendDocProcess();
	}
	
}

function escapeLocalJS(value)
{
	var strout;
	
	strout = localReplaceAll(value, '\\','\\\\');
	strout = localReplaceAll(strout, '\'','\\\'');

	return strout;
	
}

function localReplaceAll(str, find, replace) 
{
  return str.replace(new RegExp(escapeRegExp(find), 'g'), replace);
}

function escapeRegExp(string) 
{
  return string.replace(/[.*+\-?^${}()|[\]\\]/g, '\\$&'); // $& means the whole matched string
}

function mySendDoc()
{
	var indexCollaborazione = getObjValue('indexCollaborazione');
	
	/* Se non è stato ancora scelto l'ufficio di appartenenza */
	if ( indexCollaborazione == '' )
		getUffici('0','1');
	else
		mySendDocProcess();

}

function alertSendToSimogPwd()
{
	var ml_text = 'Per inviare e\' richiesta l\'imputazione della password simog del rup';
	var page = 'ctl_library/MessageBoxWin.asp?MODALE=YES&ML=YES&MSG=' + encodeURIComponent( ml_text ) +'&CAPTION=Informazione&ICO=1';

	ExecFunctionModaleWithAction( page, null , 200 , 420 , null , 'sendToSimogPwd' );
}

function sendToSimogPwd()
{
	MakeDocFrom ( 'SIMOG_PWD##RICHIESTA_CIG' );
}


function mySendDocProcess()
{
	
	var Val_Warning_Scelta_Contraente = Get_Warning_Scelta_Contraente();
	
	if ( Val_Warning_Scelta_Contraente == 1 )
	{
		var ML_text = 'Verificare la coerenza tra la procedura di scelta del contraente e il motivo della somma urgenza: per proseguire clicca ok.';
		var Title = 'Attenzione';					
		var ICO = 3;
		var page = 'ctl_library/MessageBoxWin.asp?MODALE=YES&ML=YES&MSG=' + encodeURIComponent( ML_text ) +'&CAPTION=' + encodeURIComponent(Title) + '&ICO=' + encodeURIComponent(ICO);
		var param = '';
		
		ExecFunctionModaleConfirm( page, Title , 200 , 400 , null , 'Confirm_mySendDocProcess@@@@' + param ,'');
	}			
	else
	{	
		Confirm_mySendDocProcess();
	}
	
}


//ritorna 1 se visualizzare il warning altrimenti 0
function Get_Warning_Scelta_Contraente()
{
	
	//se nuova versione verifico se presentare warning su Scelta_Contraente
	var versioneDoc = getObj('Versione');
	
	var valSceltaContraente ; 
	var valURGENZA_DL133 ; 
	var valESTREMA_URGENZA ; 
	
	var nRet = 0 ;
	
	if ( versioneDoc )
	{
		
		if ( versioneDoc.value >= '3.4.8' )
		{
			valSceltaContraente = getObjValue('ID_SCELTA_CONTRAENTE');
			valURGENZA_DL133 = getObjValue('URGENZA_DL133'); 
			valESTREMA_URGENZA = getObjValue('ESTREMA_URGENZA');  
			
			if ( valSceltaContraente != '15' && valURGENZA_DL133 == 'S' &&  valESTREMA_URGENZA == '2' )
			{
				nRet = 1 ;
				
			}
		}	
		
	}
	
	return nRet ;
	
}

function Confirm_mySendDocProcess ()
{
	ExecDocProcess( 'SEND:-1:CHECKOBBLIG,RICHIESTA_CIG');
}	

	// TipoAppaltoGara = 1 Forniture
	// TipoAppaltoGara = 2 Lavori
	// TipoAppaltoGara = 3 Servizi
	// nella griglia dei lotti aggiungere due attributi 
    //- da rendere visibile solo per le gare dei lavori: TIPOLOGIA LAVORO
    //- da rendere visibile solo per le gare beni e servizi: modalità acquisizione
	//if ( getObjValue('TipoAppaltoGara') == '2' )
	//{
	//	ShowCol( 'LOTTI' , 'MODALITA_ACQUISIZIONE' , 'none' );	
	//}
	//else
	//{
	//	ShowCol( 'LOTTI' , 'TIPOLOGIA_LAVORO' , 'none' );	
	//}
	


function Onchange_Tipocontratto(obj)
{
	
	var v = obj.id.split('_');
	var Row = v[0] + '_' + v[1];
	
	cell_MODALITA_ACQUISIZIONE = getObj('val_' + Row + '_MODALITA_ACQUISIZIONE');		
	cell_TIPOLOGIA_LAVORO = getObj('val_' + Row + '_TIPOLOGIA_LAVORO');		
	
	if ( getObj( Row + '_TIPO_CONTRATTO').value == 'L' )
	{
		getObj( Row + '_MODALITA_ACQUISIZIONE').value='';
		cell_MODALITA_ACQUISIZIONE.style.display = 'none';
		cell_TIPOLOGIA_LAVORO.style.display = '';
		
	}
	else
	{
		getObj( Row + '_TIPOLOGIA_LAVORO').value='';
		cell_MODALITA_ACQUISIZIONE.style.display = '';
		cell_TIPOLOGIA_LAVORO.style.display = 'none';
		
	}
}


function onChangeCPV(obj)
{
	//var valCodiceCPV = getObjValue('CODICE_CPV');
	
	var idObj = obj.id;
	var nomeTecnico = idObj.replace('_edit','');
	var nomeVisual = nomeTecnico + '_edit_new';
	var valCodiceCPV = getObjValue(nomeTecnico);
	
	
	if ( valCodiceCPV != '' )
	{
	
		var ultimi6 = valCodiceCPV.substr(valCodiceCPV.length - 6);
		var ultimi5 = valCodiceCPV.substr(valCodiceCPV.length - 5);

		// Consentiamo la selezione solo dei livelli maggiori o uguale al 3
		if ( ultimi6 == '000000' || ultimi5 == '00000' ) 
		{
			/*getObj(nomeTecnico).value = '';
			getObj(nomeVisual).value = '';
			
			DMessageBox( '../' , 'Selezione non valida. Selezionare un voce con un livello di profondita\' maggiore o uguale al terzo' , 'Attenzione' , 1 , 400 , 300 );
			*/
			
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
					getObj(nomeTecnico).value = '';
					getObj(nomeVisual).value = '';
				
					//DMessageBox( '../' , 'Selezione non valida. Selezionare un voce con un livello di profondita\' maggiore o uguale al terzo' , 'Attenzione' , 1 , 400 , 300 );
					DMessageBox( '../' , 'Selezione non valida. Selezionare un nodo con un livello maggiore o uguale al terzo oppure un nodo foglia di livello minore al terzo' , 'Attenzione' , 1 , 400 , 300 );
				}
			}	
		}
	
	} 

}

function onChangeSceltaContraente()
{
	confermaSceltaContraente();
	
	/*	warning rimosso per introduzione versione simog 3.04.5
	
	var valSceltaContraente = getObjValue('ID_SCELTA_CONTRAENTE');
	var TipoDoc_collegato = getObjValue('TipoDoc_collegato');
	
	if ( valSceltaContraente != '' )
	{
		//alert(valSceltaContraente);

		var ML_text = 'Per gli appalti specifici, secondo le direttive ANAC, la scelta del contraente consigliata e\' \'Sistema dinamico di acquisizione\'. Si e\' sicuri di voler proseguire senza effettuare tale modifica ?';
		var Title = 'Attenzione';					
		var ICO = 3;
		var page = 'ctl_library/MessageBoxWin.asp?MODALE=YES&ML=YES&MSG=' + encodeURIComponent( ML_text ) +'&CAPTION=' + encodeURIComponent(Title) + '&ICO=' + encodeURIComponent(ICO);
		var param = '';
		
		if ( valSceltaContraente != '6' && TipoDoc_collegato == 'BANDO_SEMPLIFICATO' )
		{
			ExecFunctionModaleConfirm( page, Title , 200 , 400 , null , 'confermaSceltaContraente@@@@' + param ,'undoSceltaContraente');
		}
		else
		{
			confermaSceltaContraente();
		}
	}
	*/
	
}

function confermaSceltaContraente()
{
	ExecDocProcess( 'ON_CHANGE_SCELTA_CONTRAENTE,RICHIESTA_CIG');
}

function undoSceltaContraente()
{
	getObj('ID_SCELTA_CONTRAENTE').value = '6';
	confermaSceltaContraente();
}

function onChangeStrumentiSvolgimento()
{
	var valStrumentoSvolgimento = getObjValue('STRUMENTO_SVOLGIMENTO');
	var TipoDoc_collegato = getObjValue('TipoDoc_collegato');
	
	if ( valStrumentoSvolgimento != '' )
	{
		//alert(valSceltaContraente);

		var ML_text = 'Per gli appalti specifici, secondo le direttive ANAC, lo strumento per lo svolgimento delle procedure consigliato e\'  \'Sistema dinamico di acquisizione\'. Si e\' sicuri di voler proseguire senza effettuare tale modifica ?';
		var Title = 'Attenzione';					
		var ICO = 3;
		var page = 'ctl_library/MessageBoxWin.asp?MODALE=YES&ML=YES&MSG=' + encodeURIComponent( ML_text ) +'&CAPTION=' + encodeURIComponent(Title) + '&ICO=' + encodeURIComponent(ICO);
		var param = '';
		
		if ( valStrumentoSvolgimento != '7' && TipoDoc_collegato == 'BANDO_SEMPLIFICATO' )
		{
			ExecFunctionModaleConfirm( page, Title , 200 , 400 , null , 'confermaStrumentoSvolgimento@@@@' + param ,'undoStrumentoSvolgimento');
		}
		else
		{
			confermaStrumentoSvolgimento();
		}
	}
}

function confermaStrumentoSvolgimento()
{
	ExecDocProcess( 'ON_CHANGE_STRUMENTO_SVOLGIMENTO,RICHIESTA_CIG');
}

function undoStrumentoSvolgimento()
{
	getObj('STRUMENTO_SVOLGIMENTO').value = '7';
	confermaStrumentoSvolgimento();
}

function onChangeCupLotto(objCup)
{
	//1. Rimuovo gli spazi
	//2. splitto sul carattere ";" e tutti gli elementi dell'array li valido rispetto all'espressione regola ^[\da-zA-Z]{15,15}$
	//3. dove non c'è corrispondenza do il messaggio di errore con chiave ML : Messaggio di errore per cup singolo o multiplo non valido
	//		e svuoto il campo
	
	var cupVal = objCup.value;
	
	cupVal = cupVal.replace(/\s/g, '');
	
	var listaCup = cupVal.split(';');

	for (var i = 0; i < listaCup.length; i++) 
	{
		var cupN = listaCup[i];
		
		var patt = new RegExp( convertRegExp('^[\\da-zA-Z]{15,15}$') );
		
		if (patt.test(cupN) == false)
		{
			objCup.value = '';
			AF_Alert("Messaggio di errore per cup singolo o multiplo non valido");
			return;
		}

	}
	objCup.value = cupVal;
}
