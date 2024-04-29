window.onload = onLoadFunc;

function onLoadFunc()
{
	var DOCUMENT_READONLY = '0';
	DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;
	
	/* Se non è stato ancora scelto l'ufficio di appartenenza */
/*	
	var indexCollaborazione = getObjValue('indexCollaborazione');
	if (DOCUMENT_READONLY == '0')
	{
		
		if ( indexCollaborazione == '' )
			getUffici();
	}
*/

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

								DMessageBox( '../ctl_library/' , 'Trovato un unico ufficio di collaborazione, assegnato automaticamente' , 'Attenzione' , 2 , 400 , 300 );
								
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
							
							//$( "#finestra_modale" ).dialog();
							
							//Init della dialog per evitare l'errore di jquery cannot call methods on dialog prior to initialization; attempted to call method 'close'
							$( "#finestra_modale" ).dialog({
								  resizable: false,
								  //height:140,
								  modal: true,
								});
							
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
	
	strout = ReplaceExtended(value, '\\','\\\\');
	strout = ReplaceExtended(strout, '\'','\\\'');

	return strout;
	
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
	ExecDocProcess( 'SEND:-1:CHECKOBBLIG,RICHIESTA_SMART_CIG');
}
