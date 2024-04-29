//var lstAttribObblig = [	'StatoRapLeg',	'ProvinciaRapLeg',	'LocalitaRapLeg',	'DataRapLeg',	'StatoResidenzaRapLeg',	'ProvResidenzaRapLeg',	'ResidenzaRapLeg',	'IndResidenzaRapLeg',	'CapResidenzaRapLeg'  ];
var lstAttribObblig = [	'StatoRapLeg',	'ProvinciaRapLeg',	'LocalitaRapLeg',	'DataRapLeg' ];

var NumControlli = lstAttribObblig.length;

window.onload = DISPLAY_FIRMA_OnLoad;

function trim(str)
{
   return str.replace(/^\s+|\s+$/g,"");
}

function GeneraPDF()
{
	var statoDoc;
	var value2=controlli('');
	
	if (value2 == -1)
		return;  

	var utenteUno = getObjValue('utente_uno');
	//var RichiediFirma = getObjValue('RichiediFirma');
	var RichiediFirma = getObj('RichiediFirma');

	var jumpcheck = getObjValue('JumpCheck');
	
	statoDoc = getObj('DOCUMENT_READONLY').value;
	
	var nocache = new Date().getTime();
	
	/* Se è il primo utente dell'azienda a richiedere l'accesso a notier */
	if ( utenteUno == '1' )
	{
		//alert('primo utente');
		
		/*
		if ( jumpcheck == 'FATTURE' )
			PrintPdfSign('TABLE_SIGN=CTL_DOC&PDF_NAME=ISCR_NOTIER_1&PROCESS=&MODULO=ISCR_NOTIER_FATTURE_1.pdf&MODULO_VIEW=VIEW_MODULO_PDF_NOTIER_ISCRIZ');
		else
			PrintPdfSign('TABLE_SIGN=CTL_DOC&PDF_NAME=ISCR_NOTIER_1&PROCESS=&MODULO=ISCR_NOTIER_1.pdf&MODULO_VIEW=VIEW_MODULO_PDF_NOTIER_ISCRIZ');
		*/
		
		PrintPdfSign('URL=/report/prn_notier_iscriz_pa_1.ASP?SIGN=YES&PDF_NAME=ISCR_NOTIER_PA_1&nocache=' + nocache);
	}
	else
	{
		
		//Se la spunta sul possesso della firma è si
		//if ( RichiediFirma == '1' )
		if ( RichiediFirma.checked )
		{
			/*
			if ( jumpcheck == 'FATTURE' )
				PrintPdfSign('TABLE_SIGN=CTL_DOC&PDF_NAME=ISCR_NOTIER_N&PROCESS=&MODULO=ISCR_NOTIER_FATTURE_N.pdf&MODULO_VIEW=VIEW_MODULO_PDF_NOTIER_ISCRIZ');
			else
				PrintPdfSign('TABLE_SIGN=CTL_DOC&PDF_NAME=ISCR_NOTIER_N&PROCESS=&MODULO=ISCR_NOTIER_N.pdf&MODULO_VIEW=VIEW_MODULO_PDF_NOTIER_ISCRIZ'); 
			*/
			
			PrintPdfSign('URL=/report/prn_notier_iscriz_pa_N.ASP?SIGN=YES&PDF_NAME=ISCR_NOTIER_PA_N');
			//PrintPdfSign('URL=/report/prn_notier_iscriz_pa_1.ASP?SIGN=YES&PDF_NAME=ISCR_NOTIER_PA_1');
		}
		else
		{
			/*
			if ( jumpcheck == 'FATTURE' )
				PrintPdfSign('TABLE_SIGN=CTL_DOC&PDF_NAME=ISCR_NOTIER_N_NOSIGN&PROCESS=NOTIER_ISCRIZ%40%40%40VERIFICA_CESSATO&MODULO=ISCR_NOTIER_FATTURE_N_NOSIGN.pdf&MODULO_VIEW=VIEW_MODULO_PDF_NOTIER_ISCRIZ');
			else
				PrintPdfSign('TABLE_SIGN=CTL_DOC&PDF_NAME=ISCR_NOTIER_N_NOSIGN&PROCESS=NOTIER_ISCRIZ%40%40%40VERIFICA_CESSATO&MODULO=ISCR_NOTIER_N_NOSIGN.pdf&MODULO_VIEW=VIEW_MODULO_PDF_NOTIER_ISCRIZ');
			*/
			PrintPdfSign('PROCESS=NOTIER_ISCRIZ%40%40%40VERIFICA_CESSATO&URL=/report/prn_notier_iscriz_pa_N_NOSIGN.ASP?SIGN=YES&PDF_NAME=ISCR_NOTIER_PA_N_NOSIGN');
			//PrintPdfSign('PROCESS=NOTIER_ISCRIZ%40%40%40VERIFICA_CESSATO&URL=/report/prn_notier_iscriz_pa_1.ASP?SIGN=YES&PDF_NAME=ISCR_NOTIER_PA_N_NOSIGN');
		}
			
	}

}

function NascondiDatiResidenza()
{
	var sezione = getObj('NOTIER_ISCRIZ_PA_FIRMATARIO').rows[4].style.display = 'none'
	var sezione = getObj('NOTIER_ISCRIZ_PA_FIRMATARIO').rows[5].style.display = 'none'
	var sezione = getObj('NOTIER_ISCRIZ_PA_FIRMATARIO').rows[6].style.display = 'none'
	var sezione = getObj('NOTIER_ISCRIZ_PA_FIRMATARIO').rows[7].style.display = 'none'	
}

function afterProcess( param )
{
	//alert(param);

	try
	{
		/* RICARICO I PERMESSI DELL'UTENTE COLLEGATO */
		ajax = GetXMLHttpRequest(); 
		var nocache = new Date().getTime();

		if(ajax)
		{
			ajax.open("GET", '../../ctl_library/reloadFunz.asp?nocache=' + nocache, false);
			ajax.send(null);
			
			if(ajax.readyState == 4) 
			{
				//Se non ci sono stati errori di runtime
				if(ajax.status == 200)
				{
					var res = ajax.responseText;
					
					if ( res!= '' ) 
					{
						
						//Se l'esito della chiamata è stato positivo
						if ( res.substring(0, 2) == '1#' ) 
						{
							RefreshDocument( './' );
						}
					}
				}
			}
		}
	}
	catch(e)
	{
	}
}

function TogliFirma () 
{
	//DMessageBox( '../' , 'Si sta per eliminare il file firmato.' , 'Attenzione' , 1 , 400 , 300 );
	ExecDocProcess( 'SIGN_ERASE,FirmaDigitale');
}

function SetInitField()
{
	var i = 0;
	for( i = 0 ; i < NumControlli ; i++ )
	{
		TxtOK( lstAttribObblig[i] );
	}
}

function DISPLAY_FIRMA_OnLoad()
{
	var Stato ='';
	var IdpfuInCharge = getObjValue('IdpfuInCharge');

	try
	{
		initGEO();
	}
	catch(e)
	{
	}
	
	if ( getObjValue('DOCUMENT_READONLY') == '0' )
	{
		var RichiediFirma = getObj('RichiediFirma');
		var cf2 = getObjValue('CFRapLeg');
		
		/* SE NON SONO IL PRIMO UTENTE DELL'AZIENDA A RICHIEDERE IL PROFILO NOTIER */
		if ( cf2 == '' )
		{
			RichiediFirma.setAttribute('onclick','return false');
			RichiediFirma.disabled = true;
			//RichiediFirma.disabled  = true;
		}
		else
		{
			RichiediFirma.setAttribute('onclick','');
		}
		
		try
		{
			var utenteUno = getObjValue('utente_uno');
			
			if ( utenteUno == '1' )
			{
				onChangePossessoIPA();
			}
			else
			{
				getObj('AssenzaCodiceIPA').setAttribute('onclick','return false');
				getObj('AssenzaCodiceIPA').disabled = true;
				
				getObj('div_IPAGrid').innerHTML = '<span class="VerticalModel_Help">Selezionare gli uffici per i quali si intende operare</span>' + getObj('div_IPAGrid').innerHTML;
				
				
			}
			
			
			
		}
		catch(e) {}
		
		
	}


	if ( getObj('StatoDoc') )
	{

		Stato = getObj('StatoDoc').value;
	
		if ( (getObjValue('SIGN_LOCK') =='0' || getObjValue('SIGN_LOCK') =='')   && (Stato=='Saved' || Stato=="") && IdpfuInCharge == idpfuUtenteCollegato )
		{
			document.getElementById('generapdf').disabled = false; 
			document.getElementById('generapdf').className ="generapdf";
		}
		else
		{
			document.getElementById('generapdf').disabled = true; 
			document.getElementById('generapdf').className ="generapdfdisabled";
		}	
		if ( getObjValue('SIGN_LOCK') != '0'   && (Stato=='Saved') && IdpfuInCharge == idpfuUtenteCollegato )
		{
			document.getElementById('editistanza').disabled = false; 
			document.getElementById('editistanza').className ="attachpdf";
		}
		else
		{
			document.getElementById('editistanza').disabled = true; 
			document.getElementById('editistanza').className ="attachpdfdisabled";
		} 
		if (getObjValue('SIGN_ATTACH') ==''  &&  (Stato=='Saved') && getObjValue('SIGN_LOCK') != '0' && IdpfuInCharge == idpfuUtenteCollegato )
		{
			document.getElementById('attachpdf').disabled = false; 
			document.getElementById('attachpdf').className ="editistanza";
		}
		else
		{
			document.getElementById('attachpdf').disabled = true; 
			document.getElementById('attachpdf').className ="editistanzadisabled";
		}
	}
	NascondiDatiResidenza()

}

function RefreshContent()
{
	RefreshDocument('');	
}

//GESTIONE DEI CAMPI LOCALITA PROVINCIA E STATO

function initGEO()
{
	enableDisableAziGeo('LocalitaRapLeg','ProvinciaRapLeg','StatoRapLeg','apriGEO',true);
	enableDisableAziGeo('ResidenzaRapLeg','ProvResidenzaRapLeg','StatoResidenzaRapLeg','apriGEO2',true);
}


function impostaLocalita(cod,fieldname)
{
	ajax = GetXMLHttpRequest(); 
	
	var comuneTec;
	var provinciaTec;
	var statoTec;
	var comuneDesc; 
	var provinciaDesc;
	var statoDesc;
	
	if ( fieldname == 'RapLeg' )
	{
		comuneTec='LocalitaRapLeg2';
		provinciaTec='ProvinciaRapLeg2';
		statoTec='StatoRapLeg2';
		comuneDesc='LocalitaRapLeg';
		provinciaDesc='ProvinciaRapLeg';
		statoDesc='StatoRapLeg';
		geo='apriGEO'
	}
	if ( fieldname == 'ResidenzaRapLeg' )
	{
		comuneTec='ResidenzaRapLeg2';
		provinciaTec='ProvResidenzaRapLeg2';
		statoTec='StatoResidenzaRapLeg2';
		comuneDesc='ResidenzaRapLeg';
		provinciaDesc='ProvResidenzaRapLeg';
		statoDesc='StatoResidenzaRapLeg';
		geo='apriGEO2'
	}
	
	

	if(ajax)
	{
		ajax.open("GET", '../../ctl_library/functions/infoNodoGeo.asp?fldname=localita&cod=' + escape(cod), false);
		//output nella forma : COD-COMUNE#@#DESC-COMUNE#@#COD-PROVINCIA#@#DESC-PROVINCIA#@#COD-STATO#@#DESC-STATO
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

							codLoc = vet[0];
							descLoc = vet[1];
							codProv = vet[2];
							descProv = vet[3];
							codStato = vet[4];
							descStato = vet[5];

							getObj(comuneTec).value = codLoc;
							getObj(comuneDesc).value = descLoc;

							if ( codLoc == '' || codLoc.substring( codLoc.length-3, codLoc.length ) == 'XXX' )
								disableGeoField( comuneDesc, false);
							else
								disableGeoField( comuneDesc, true);

							getObj(provinciaTec).value = codProv;
							getObj(provinciaDesc).value = descProv;

							if ( codProv == '' || codProv.substring( codProv.length-3, codProv.length ) == 'XXX' )
								disableGeoField( provinciaDesc, false);
							else
								disableGeoField( provinciaDesc, true);

							getObj(statoTec).value = codStato;
							getObj(statoDesc).value = descStato;

							if ( codStato == ''  || codStato.substring( codStato.length-3, codStato.length ) == 'XXX' )
								disableGeoField( statoDesc, false);
							else
								disableGeoField( statoDesc, true);
							
							if ( fieldname == 'RapLeg' ) {
								//Verifica il codice istat del CF con il comune selezionato
								ExecDocProcess('CHECKCODISTAT,NOTIER_ISCRIZ_PA');
							}	
						}
						catch(e)
						{
							alert('Errore:' + e.message);
							
						}
					}
					else
					{
						alert('errore.msg:' + res.substring(2));
						enableDisableAziGeo(comuneDesc,provinciaDesc,statoDesc,geo,false);
					}
				}
			}
			else
			{
				alert('errore.status:' + ajax.status);
				enableDisableAziGeo(comuneDesc,provinciaDesc,statoDesc,geo,false);
				
			}
		}
		else
		{
			alert('errore in impostaLocalita');
			enableDisableAziGeo(comuneDesc,provinciaDesc,statoDesc,geo,false);
		}
	}
}

function controlli() 
{

	var numRowIPA = GetProperty( getObj('IPAGrid') , 'numrow');
	var err = false;

	var flagIPA = getObj('AssenzaCodiceIPA');
	
	if(  Number( numRowIPA ) >= 1 && flagIPA.checked )
	{
		DMessageBox('../', 'Non essendo in possesso di un codice univoco ufficio IPA è richiesta la presenza di un unica riga ufficio', 'Attenzione', 1, 400, 300);
        return -1;
	}

	var utenteUno = getObjValue('utente_uno');
	
	if(  Number( numRowIPA ) >= 0 )
	{
		var selChecked = false;
		
		for( i = 0 ; i <= numRowIPA ; i++ )
		{
			if ( utenteUno != '1' ) 
			{
				try
				{
					var selRow = getObj('RIPAGrid_' + i + '_SelRow');
					
					if ( selRow.checked )
					{
						selChecked = true;
						break;
					}
					
				}
				catch(e){}
			}
			else
			{
				var checkSendOrd = getObj('RIPAGrid_' + i + '_Peppol_Invio_Ordine');
				var checkGetOrd = getObj('RIPAGrid_' + i + '_Peppol_Ricezione_Ordine');
				var checkSendDDT = getObj('RIPAGrid_' + i + '_Peppol_Invio_DDT');
				var checkGetDDT = getObj('RIPAGrid_' + i + '_Peppol_Ricezione_DDT');

				//controllo sotto
				var checkSendFatture = getObj('RIPAGrid_' + i + '_Peppol_Invio_Fatture');
				
				if ( !checkSendOrd.checked && !checkGetOrd.checked && !checkSendDDT.checked && !checkGetDDT.checked && !checkSendFatture.checked)
				{
					DMessageBox('../', 'Per ogni IPA spuntare almeno un check di Invio/Ricezione peppol', 'Attenzione', 1, 400, 300);
					return -1;
				}

				if (checkSendOrd.checked && !checkGetDDT.checked)
				{
					DMessageBox('../', 'Se viene selezionato Invio Ordine deve essere selezionato anche Ricezione DDT', 'Attenzione', 1, 400, 300);
					return -1;
				}
				
				if (checkSendDDT.checked && !checkGetOrd.checked)
				{
					DMessageBox('../', 'Se viene selezionato Invio DDT deve essere selezionato almeno una Ricezione Ordini', 'Attenzione', 1, 400, 300);
					return -1;
				}

				if ( !checkGetOrd.checked && !checkGetDDT.checked && !checkSendFatture.checked)
				{
					DMessageBox('../', 'Per ogni IPA spuntare almeno un check di Ricezione peppol', 'Attenzione', 1, 400, 300);
					return -1;
				}
				
				
			
			}
		}
	
		if ( utenteUno != '1' && selChecked == false ) 
		{
			DMessageBox('../', 'Selezionare almeno una riga ufficio', 'Attenzione', 1, 400, 300);
			return -1;
		}
	
	}
	else
	{
		DMessageBox('../', 'La griglia \'Codici IPA\' deve contenere almeno una riga', 'Attenzione', 1, 400, 300);
		return -1;
	}
	
	
    var err = false;

    SetInitField();

    //-- controllo i dati della richiesta
    var i = 0;

    for (i = 0; i < NumControlli; i++) 
	{

        try 
		{


            if (getObj(lstAttribObblig[i]).type == 'text' || getObj(lstAttribObblig[i]).type == 'hidden' ||
                getObj(lstAttribObblig[i]).type == 'select-one' || getObj(lstAttribObblig[i]).type == 'textarea') {
				
                if (trim(getObjValue(lstAttribObblig[i])) == '') 
				{
                    err = true;
                    TxtErr(lstAttribObblig[i]);
                }
				
            }

            if (getObj(lstAttribObblig[i]).type == 'checkbox') 
			{
                if (getObj(lstAttribObblig[i]).checked == false)
				{
                    err = true;
                    TxtErr(lstAttribObblig[i]);
                }
            }

        } 
		catch (e) 
		{
            alert(i + ' - ' + lstAttribObblig[i]);
        }

    }
	
	err = err || checkObbligGrigliaIPA();

    if ( err ) 
	{

        DMessageBox('../', 'Per proseguire e\' necessaria la compilazione di tutti i campi evidenziati', 'Attenzione', 1, 400, 300);
        return -1;
    }
	else
	{
		return 1;
	}
}

function allegaFileFirmato()
{
	var varIdDoc = getObjValue('IDDOC');
	var cf = getObjValue('codicefiscale');
	var RichiediFirma = getObjValue('RichiediFirma');
	var cf1 = getObjValue('CFRapLeg');

	/* SE NON SONO IL PRIMO UTENTE DELL'AZIENDA A RICHIEDERE IL PROFILO NOTIER E TOLTO IL CHECK DI POSSESSO DEL KIT DI FIRMA */
	if ( cf1 != '' && ( RichiediFirma == '0' || RichiediFirma == '' )  )
	{
		// Richiedo che il firmatario del pdf sia il 1o utente dell'azienda che ha richiesto il censimento in notier
		cf = cf1;
	}

	ExecFunctionCenterDoc('../functions/field/uploadattachsigned.asp?TABLE=ctl_doc&IDDOC=' + varIdDoc + '&OPERATION=INSERTSIGN&CF=' + cf + '&IDENTITY=Id&AREA=&DOMAIN=FileExtention&FORMAT=#AllegaFirma#600,400');
}

function checkObbligGrigliaIPA()
{
	var numRowIPA = GetProperty( getObj('IPAGrid') , 'numrow');
	var err = false;
	
	if(  Number( numRowIPA ) >= 0 )
	{
		var flagIPA = getObj('AssenzaCodiceIPA');
		var utenteUno = getObjValue('utente_uno');
		
		for( i = 0 ; i <= numRowIPA ; i++ )
		{
			try
			{
				var nomeCampoGrid = 'RIPAGrid_' + i + '_CodiceIPA';

				if ( !flagIPA.checked && utenteUno == '1' )
				{
					err = checkCampoObblig(nomeCampoGrid) || err;
				}

				nomeCampoGrid = 'RIPAGrid_' + i + '_DenominazioneIPA';
				
				err = checkCampoObblig(nomeCampoGrid) || err;
				
				//nomeCampoGrid = 'RIPAGrid_' + i + '_IndirizzoIPA';
				//err = checkCampoObblig(nomeCampoGrid) || err;
				
				nomeCampoGrid = 'RIPAGrid_' + i + '_TelefonoIPA';
				
				err = checkCampoObblig(nomeCampoGrid) || err;
				
				//nomeCampoGrid = 'RIPAGrid_' + i + '_pecIPA';
				//err = checkCampoObblig(nomeCampoGrid) || err;
				
				nomeCampoGrid = 'RIPAGrid_' + i + '_ReferenteIPA';
				
				err = checkCampoObblig(nomeCampoGrid) || err;
				
				nomeCampoGrid = 'RIPAGrid_' + i + '_EmailReferenteIPA';
				
				err = checkCampoObblig(nomeCampoGrid) || err;
				
			}catch(e){}
		}
	}

	return err;

}

function checkCampoObblig(nomeCampo)
{
	var campoErr = false;
	
	try
	{
		if( getObjValue( nomeCampo ) == '' )
		{
			campoErr = true;
			TxtErr(nomeCampo);
		}
		else
		{
			TxtOK(nomeCampo);
		}
	}
	catch(e){}
	
	return campoErr;
}

function onChangePossessoIPA()
{
	var flagIPA = getObj('AssenzaCodiceIPA');
	var numRowIPA = GetProperty( getObj('IPAGrid') , 'numrow');
	
	if(  Number( numRowIPA ) >= 0 )
	{
		for( i = 0 ; i <= numRowIPA ; i++ )
		{
			try
			{
				var nomeCampoGrid = 'RIPAGrid_' + i + '_CodiceIPA';
				
				if ( flagIPA.checked )
				{
					getObj(nomeCampoGrid).value = '';
					getObj(nomeCampoGrid).readOnly = true;
				}
				else
				{
					getObj(nomeCampoGrid).readOnly = false;
				}

			}catch(e){}
		}
	}
}

function addNewIPA()
{
	var flagIPA = getObj('AssenzaCodiceIPA');
	var numRowIPA = GetProperty( getObj('IPAGrid') , 'numrow');
	
	if ( flagIPA.checked && Number( numRowIPA ) >= 0 )
	{
		DMessageBox('../', 'In assenza di un Codice Univoco ufficio IPA non è possibile aggiungere righe', 'Attenzione', 1, 400, 300);
	}
	else
	{
		ExecDocCommand( 'IPA#AddNew#');
	}
	
	
}

function IPA_AFTER_COMMAND( param )
{
	onChangePossessoIPA();
}