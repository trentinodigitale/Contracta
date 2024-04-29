window.onload = initRegistrazioneFornitore;

function initRegistrazioneFornitore()
{
	localEnableDisableAziGeo(true);
}


function localEnableDisableAziGeo(bool)
{
    enableDisableAziGeo('aziLocalitaLeg','aziProvinciaLeg','aziStatoLeg','apriGEO',bool,'aziRegioneLeg');
}

/**
 * Apre la popup per la selezione del comune
 */
function openGEO()
{
	codApertura = 'M-1-11-ITA-ITH-ITH5';
	
	var tmp = getObj('aziLocalitaLeg2').value;
	
	if ( tmp !== '' )
	{
		codApertura = tmp;
	}
	else
	{
		var tmp = getObj('aziProvinciaLeg2').value;
		
		if ( tmp !== '' )
			codApertura = tmp;
	}
	
	//aggiunto il parametro cod_to_exclude per non visualizzare i codici che finiscono con XXX, quindi gli elementi 'altro' del dominio
	ExecFunction(  '../../Ctl_Library/gerarchici.asp?lo=content&portale=no&cod_to_exclude=%25XXX&fieldname=localita&path_filtra=GEO&caption=Dominio GEO&help=help_geo_ente&path_start=GEO&lvl_sel=,3,6,7,&lvl_max=7&cod=' + codApertura + '&js=impostaLocalita' , 'DOMINIO_GEO' , ',width=700,height=750' );
}

/**
 * CallBack della openGEO per settare i campi nel FORM
 * @param {*} cod 
 * @param {*} fieldName 
 */
function impostaLocalita(cod,fieldName)
{
	ajax = GetXMLHttpRequest(); 

	if(ajax)
	{
		ajax.open("GET", '../../ctl_library/functions/infoNodoGeo.asp?fldname=localita&cod=' + escape(cod), false);
		//output nella forma : COD-COMUNE#@#DESC-COMUNE#@#COD-PROVINCIA#@#DESC-PROVINCIA#@#COD-STATO#@#DESC-STATO#@#COD-REGIONE#@#DESC-REGIONE
		ajax.send(null);

		if(ajax.readyState == 4) 
		{
			//Se non ci sono stati errori di runtime
			if(ajax.status == 200)
			{
				if ( ajax.responseText != '' ) 
				{
					var res = ajax.responseText;
					
					//Se l'esito della chiamata è stato positivo
					if ( res.substring(0, 2) == '1#' ) 
					{
						try
						{
							var vet = res.substring(4).split( '#@#' );
							
							var codLoc;
							var descLoc;
							var codProv;
							var descProv;
							var codStato;
							var descStato;
							var codRegione;
							var descRegione;

							codLoc = vet[0];
							descLoc = vet[1];
							codProv = vet[2];
							descProv = vet[3];
							codStato = vet[4];
							descStato = vet[5];
							codRegione = vet[6];
							descRegione = vet[7];
							

							getObj('aziLocalitaLeg2').value = codLoc;
							getObj('aziLocalitaLeg').value = descLoc;

							if ( codLoc == '' || codLoc.substring( codLoc.length-3, codLoc.length ) == 'XXX' )
								disableGeoField('aziLocalitaLeg', false);
							else
								disableGeoField('aziLocalitaLeg', true);

							getObj('aziProvinciaLeg2').value = codProv;
							getObj('aziProvinciaLeg').value = descProv;

							if ( codProv == '' || codProv.substring( codProv.length-3, codProv.length ) == 'XXX' )
								disableGeoField('aziProvinciaLeg', false);
							else
								disableGeoField('aziProvinciaLeg', true);

							getObj('aziStatoLeg2').value = codStato;
							getObj('aziStatoLeg').value = descStato;

							if ( codStato == ''  || codStato.substring( codStato.length-3, codStato.length ) == 'XXX' )
								disableGeoField('aziStatoLeg', false);
							else
								disableGeoField('aziStatoLeg', true);
								
							if ( codRegione == ''  || codRegione.substring( codRegione.length-3, codRegione.length ) == 'XXX' )
								getObj('aziRegioneLeg').readOnly = false;
							else
								getObj('aziRegioneLeg').readOnly = true;
							
							getObj('aziRegioneLeg2').value = codRegione;
							getObj('aziRegioneLeg').value = descRegione;
								
						}
						catch(e)
						{
							alert('Errore:' + e.message);
							//localEnableDisableAziGeo(false);
						}
					}
					else
					{
						alert('errore.msg:' + res.substring(2));
						localEnableDisableAziGeo(false);
					}
				}
			}
			else
			{
				alert('errore.status:' + ajax.status);
				localEnableDisableAziGeo(false);
			}
		}
		else
		{
			alert('errore in impostaLocalita');
			localEnableDisableAziGeo(false);
		}
	}
}


/**
 * Verifica il codice fiscale ed avvia il processo per l'estrazione dei dati da srevizi Terzi
 * 
 * @param {*} obj 
 * @returns 
 */
function MyCheckCF(obj) {
    
	if (getObjValue('codicefiscale')  == "" )  
	{
		return ;
	}
	
    ExecDocProcess( 'GETDATA_FROM_EXTSERVICE_BY_CF,REGISTRAZIONE_FORNITORE,,NO_MSG');     
}



function MySend(param)
{
	var nRet = 0 ;
	
	//verifico la bontà del cap rispetto alla località
	if ( verifyCap( 'aziLocalitaLeg2', getObj('aziCAPLeg') ) )
	{
		nRet = 1 ;
	}
	
	if ( nRet == 1 ) 
	{	
		//controllo la coerenza del codice fiscale utente
		var nRet = 	checkCoerenzaCF( 0 );
		
		if ( nRet == 0 )
		{
			
			var Title = 'Attenzione';
			var ML_text = 'Codice fiscale non coerente con nome e cognome. Vuoi Proseguire ?';
			var ICO = 3;
			var page = 'ctl_library/MessageBoxWin.asp?MODALE=YES&ML=YES&MSG=' + encodeURIComponent( ML_text ) +'&CAPTION=' + encodeURIComponent(Title) + '&ICO=' + encodeURIComponent(ICO);
				
			ExecFunctionModaleConfirm( page, null , 200 , 420 , null , 'ExecDocProcess@@@@' + param );
			
		}
		else
			ExecDocProcess(param);
	}
}




function checkCoerenzaCF( nMakeAlert )
{
	
	var nome = getObjValue('NomeRapLeg').replace(/^\s+|\s+$/gm,'');
	var cognome = getObjValue('CognomeRapLeg').replace(/^\s+|\s+$/gm,'');
	var cf = getObjValue('CFRapLeg').replace(/^\s+|\s+$/gm,'');
	
	
	
	
	var resFunct = 1;
	
	/* Se sono avvalorati tutti i campi utili */
	if ( nome !== '' && cognome !== '' && cf !== '')
	{

		n_Made_Check_CF = '1';
		
		if ( !isMyCF('../../', nome , cognome, cf) )
		{
			resFunct = 0;
			
			if ( nMakeAlert != 0 )
				DMessageBox( '../' , 'Codice fiscale non coerente con nome e cognome' , 'Attenzione' , 1 , 400 , 300 );
			
			TxtErr( 'NomeRapLeg' );
			TxtErr( 'CognomeRapLeg' );
			TxtErr( 'CFRapLeg' );
		}
		else
		{
			resFunct = 1;
			
			TxtOK( 'NomeRapLeg' );
			TxtOK( 'CognomeRapLeg' );
			TxtOK( 'CFRapLeg' );
		}

	}else
	{	
		if (nome == '') 
			TxtErr( 'NomeRapLeg' );
		else
			TxtOK( 'NomeRapLeg' );
		
		if (cognome == '') 
			TxtErr( 'CognomeRapLeg' );
		else
			TxtOK( 'CognomeRapLeg' );
		
		if (cf == '') 
			TxtErr( 'CFRapLeg' );
		else
			TxtOK( 'CFRapLeg' );
		
		
		DMessageBox( '../' , 'nome,cognome e codice fiscale utente sono obbligatori' , 'Attenzione' , 1 , 400 , 300 );
	}
	return resFunct;
	
	
	//isMyCF
}
