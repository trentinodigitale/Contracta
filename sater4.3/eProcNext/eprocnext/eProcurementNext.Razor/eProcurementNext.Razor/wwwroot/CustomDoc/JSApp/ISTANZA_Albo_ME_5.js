var LstAttrib = [
	'NomeRapLeg',
	'CognomeRapLeg',
	'LocalitaRapLeg',
	'ProvinciaRapLeg',
	'StatoRapLeg',
	'DataRapLeg',
	'CFRapLeg',
	'TelefonoRapLeg',
	'ResidenzaRapLeg',
	'ProvResidenzaRapLeg',
	'StatoResidenzaRapLeg',
	'IndResidenzaRapLeg',
	'CapResidenzaRapLeg',
	'RagSoc',
	//'NaGi',
	'INDIRIZZOLEG',
	'LOCALITALEG',
	'CAPLEG',
	'PROVINCIALEG',
	'STATOLOCALITALEG',
	'NUMTEL',
	//'NUMFAX',
	'codicefiscale',
	'PIVA',
	'ClasseIscriz',
];


var NumControlli = LstAttrib.length;

function trim(str) {
	return str.replace(/^\s+|\s+$/g, "");
}

function InvioIstanza(param) {
	if (getObjValue('RichiestaFirma') == 'no') {
		if (getObjValue('JumpCheck') != 'Conferma') {
			var value = controlli(param);
		}

		if (value == -1)
			return;

		if (verifyCap('ResidenzaRapLeg2', getObj('CapResidenzaRapLeg')) && verifyCap('LOCALITALEG2', getObj('CAPLEG'))) {
			ExecDocProcess('PRE_SEND,ISTANZA_AlboOperaEco');
		}
	}
	if (getObjValue('Attach') == "" && getObjValue('RichiestaFirma') != 'no') {
		DMessageBox('../', 'Prima di Inviare il documento allegare il file firmato.', 'Attenzione', 1, 400, 300);
		return;
	}


	if (getObjValue('Attach') != "") {
		if (verifyCap('ResidenzaRapLeg2', getObj('CapResidenzaRapLeg')) && verifyCap('LOCALITALEG2', getObj('CAPLEG'))) {
			ExecDocProcess('PRE_SEND,ISTANZA_AlboOperaEco');
		}

	}

}

function GeneraPDF() {
	var value2 = controlli('');

	if (value2 == -1)
		return;

	scroll(0, 0);
	PrintPdfSign('URL=/report/prn_' + getObj('TYPEDOC').value + '.ASP?SIGN=YES&PROCESS=ISTANZA@@@VERIFICHE_PRE_PDF');

}

function TogliFirma() {
	DMessageBox('../', 'Si sta per eliminare il file firmato.', 'Attenzione', 1, 400, 300);
	ExecDocProcess('SIGN_ERASE,FirmaDigitale');
}

function SetInitField() {

	var i = 0;
	for (i = 0; i < NumControlli; i++) {
		if (getObjValue('Not_Editable').indexOf(LstAttrib[i] + ' ,') < 0) {
			TxtOK(LstAttrib[i]);
		}
	}




}


function IsNumeric2(sText) {
	var ValidChars = '0123456789.';
	var IsNumber = true;
	var Char;

	for (i = 0; i < sText.length && IsNumber == true; i++) {
		Char = sText.charAt(i);
		if (ValidChars.indexOf(Char) == -1) {
			IsNumber = false;
		}
	}

	return IsNumber;

}


function roundTo(X, decimalpositions) {
	var i = X * Math.pow(10, decimalpositions);
	i = Math.round(i);
	return i / Math.pow(10, decimalpositions);
}

function ControllaCF(cf) {
	var validi, i, s, set1, set2, setpari, setdisp;
	if (cf == '') return '';
	cf = cf.toUpperCase();
	if (cf.length != 16)
		return "La lunghezza del codice fiscale non e'\n"
			+ "corretta: il codice fiscale dovrebbe essere lungo\n"
			+ "esattamente 16 caratteri.";
	validi = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
	for (i = 0; i < 16; i++) {
		if (validi.indexOf(cf.charAt(i)) == -1)
			return "Il codice fiscale contiene un carattere non valido \'" +
				cf.charAt(i) +
				"\'.\nI caratteri validi sono le lettere e le cifre.";
	}
	set1 = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	set2 = "ABCDEFGHIJABCDEFGHIJKLMNOPQRSTUVWXYZ";
	setpari = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	setdisp = "BAKPLCQDREVOSFTGUHMINJWZYX";
	s = 0;
	for (i = 1; i <= 13; i += 2)
		s += setpari.indexOf(set2.charAt(set1.indexOf(cf.charAt(i))));
	for (i = 0; i <= 14; i += 2)
		s += setdisp.indexOf(set2.charAt(set1.indexOf(cf.charAt(i))));
	if (s % 26 != cf.charCodeAt(15) - 'A'.charCodeAt(0))
		return "Il codice fiscale non e\' corretto:\n" +
			"il codice di controllo non corrisponde.";
	return "";
}

function ControllaPIVA(pi) {
	if (pi == '') return '';
	if (pi.length != 11)
		return "La lunghezza della partita IVA non e\'\n" +
			"corretta: la partita IVA dovrebbe essere lunga\n" +
			"esattamente 11 caratteri.";
	validi = "0123456789";
	for (i = 0; i < 11; i++) {
		if (validi.indexOf(pi.charAt(i)) == -1)
			return "La partita IVA contiene un carattere non valido \'" +
				pi.charAt(i) + "'.\nI caratteri validi sono le cifre.";
	}
	s = 0;
	for (i = 0; i <= 9; i += 2)
		s += pi.charCodeAt(i) - '0'.charCodeAt(0);
	for (i = 1; i <= 9; i += 2) {
		c = 2 * (pi.charCodeAt(i) - '0'.charCodeAt(0));
		if (c > 9) c = c - 9;
		s += c;
	}
	if ((10 - s % 10) % 10 != pi.charCodeAt(10) - '0'.charCodeAt(0))
		return "La partita IVA non e\' valida:\n" +
			"il codice di controllo non corrisponde.";
	return '';
}


function LocalPrintPdf(param) {

	Stato = getObjValue('StatoDoc');
	param = '/report/prn_' + getObj('TYPEDOC').value + '.ASP?'
	if (Stato == '') {
		//alert( 'Per effettuare la stampa si richiede prima un salvataggio. Verra\' effettuato in automatico, successivamente effettuare nuovamente il comando di stampa');
		DMessageBox('../', 'Per effettuare la stampa si richiede prima un salvataggio. Verra\' effettuato in automatico, successivamente effettuare nuovamente il comando di stampa.', 'Attenzione', 1, 400, 300);

		MySaveDoc();
		return;
	}
	PrintPdf(param);

}
function DISPLAY_FIRMA_OnLoad() {
	//test per verificare se sono su reload di una sezione non faccio niente
	if (getObj('LinkedDoc')) {
		HideCestinodoc();
		FormatAllegato();
		Filtro_Classe_Iscrizione();
	}

	Stato = '';
	Stato = getObjValue('StatoDoc');
	IdpfuInCharge = getObjValue('IdpfuInCharge');
	try {
		if (getObj('DOCUMENT_READONLY').value != '1') {
			OnChange_ClasseIscriz();
		}
		else {
			if (getObjValue('Richiesta_Info') == '1') {
				document.getElementById('INFO_ADD').style.display = "block";
			}
		}
	} catch (e) { }


	if (getObjValue('RichiestaFirma') == 'no') {
		document.getElementById('DIV_FIRMA').style.display = "none";
	}
	

	if ((getObjValue('SIGN_LOCK') == '0' || getObjValue('SIGN_LOCK') == '') && (Stato == 'Saved' || Stato == "") && IdpfuInCharge == idpfuUtenteCollegato) {
		document.getElementById('generapdf').disabled = false;
		document.getElementById('generapdf').className = "generapdf";
	}
	else {
		document.getElementById('generapdf').disabled = true;
		document.getElementById('generapdf').className = "generapdfdisabled";
	}

	if (getObjValue('SIGN_LOCK') != '0' && (Stato == 'Saved') && IdpfuInCharge == idpfuUtenteCollegato) {
		document.getElementById('editistanza').disabled = false;
		document.getElementById('editistanza').className = "attachpdf";
	}
	else {
		document.getElementById('editistanza').disabled = true;
		document.getElementById('editistanza').className = "attachpdfdisabled";
	}
	if (getObjValue('SIGN_ATTACH') == '' && (Stato == 'Saved') && getObjValue('SIGN_LOCK') != '0' && IdpfuInCharge == idpfuUtenteCollegato) {
		document.getElementById('attachpdf').disabled = false;
		document.getElementById('attachpdf').className = "editistanza";
	}
	else {
		document.getElementById('attachpdf').disabled = true;
		document.getElementById('attachpdf').className = "editistanzadisabled";
	}


	if (IdpfuInCharge != idpfuUtenteCollegato) {
		getObj('apriGEO' + '_link').setAttribute("onclick", "return false;");
		getObj('apriGEO').className = "";
		getObj('apriGEO' + '_link').style.cursor = "default";

		getObj('apriGEO2' + '_link').setAttribute("onclick", "return false;");
		getObj('apriGEO2').className = "";
		getObj('apriGEO2' + '_link').style.cursor = "default";

		getObj('apriGEO3' + '_link').setAttribute("onclick", "return false;");
		getObj('apriGEO3').className = "";
		getObj('apriGEO3' + '_link').style.cursor = "default";
	}



	initAziEnte();
	Messaggio_Readonly();

	var statoFunzionale;
	statoFunzionale = getExtraAttrib('val_StatoFunzionale', 'value');
	//AGGIUNTO IL CONTROLLO CHE MOSTRA IL MSG SOLO QUANDO NON VENGO DA UN PROCESSO, in questo modo mostro il msg su riapertura 
	//e dopo l'allega pdf ma non va in conflitto con msg di sistema
	if (getObjValue('SIGN_ATTACH') != '' && Stato != 'Sended' && statoFunzionale != 'Variato' && getQSParam('COMMAND') != 'PROCESS') {
		alert('Per effettuare l\'invio dell\'istanza cliccare sul comando "Invia" in alto sul documento');
		return;
	}


}

window.onload = DISPLAY_FIRMA_OnLoad;

function Messaggio_Readonly() {
	if (getObj("StatoFunzionale").value == 'InLavorazione' && getObj("BANDO_SCADUTO").value == 'si') {
		DMessageBox('../', 'I termini di presentazione dell\'istanza sono scaduti', 'Attenzione', 1, 400, 300);
	}
}

function controlli(param) {
	if (getObj('DOCUMENT_READONLY').value != '1') {
		var err = 0;
		var cod = getObj("IDDOC").value;

		var strRet = CNV('../', 'ok');

		SetInitField();

		//-- controllo i dati della richiesta
		var i = 0;
		var err = 0;

		var strPIVA_Obbligatoria = getObjValue('PIVA_Obbligatoria');
		//alert(strPIVA_Obbligatoria);
		for (i = 0; i < NumControlli; i++) {
			//se l'azienda non aveva la PIVA allora è facoltativo altrimenti obbligatorio
			if (LstAttrib[i] != 'PIVA' || (LstAttrib[i] == 'PIVA' && strPIVA_Obbligatoria == 'si')) {
				try {
					if (getObjValue('Not_Editable').indexOf(LstAttrib[i] + ' ,') < 0) {


						if (getObj(LstAttrib[i]).type == 'text' || getObj(LstAttrib[i]).type == 'hidden'
							|| getObj(LstAttrib[i]).type == 'select-one' || getObj(LstAttrib[i]).type == 'textarea'

						) {
							if (trim(getObjValue(LstAttrib[i])) == '') {
								err = 1;
								TxtErr(LstAttrib[i]);
							}
						}

						if (getObj(LstAttrib[i]).type == 'checkbox') {
							if (getObj(LstAttrib[i]).checked == false) {
								err = 1;
								TxtErr(LstAttrib[i]);
							}
						}

					}
				} catch (e) {
					alert(i + ' - ' + LstAttrib[i]);
				}

			}
			//alert(getObjValue( LstAttrib[i] ));

		}



		if (GetProperty(getObj('val_RuoloRapLeg'), 'value').indexOf('PROCURATORE SPECIALE') > -1) {
			if (trim(getObjValue('Procura')) == '') { err = 1; TxtErr('Procura'); } else { TxtOK('Procura') }
			if (trim(getObjValue('DelProcura')) == '') { err = 1; TxtErr('DelProcura'); } else { TxtOK('DelProcura') }
			if (trim(getObjValue('NumProcura')) == '') { err = 1; TxtErr('NumProcura'); } else { TxtOK('NumProcura') }
			if (trim(getObjValue('NumRaccolta')) == '') { err = 1; TxtErr('NumRaccolta'); } else { TxtOK('NumRaccolta') }
		}




		var numrrowdoc = Number(GetProperty(getObj('DOCUMENTAZIONEGrid'), 'numrow'));
		if (numrrowdoc >= 0) {

			var t = 0;
			for (t = 0; t < numrrowdoc + 1; t++) {
				if (getObj('RDOCUMENTAZIONEGrid_' + t + '_Obbligatorio').value == '1') {
					if (getObj('RDOCUMENTAZIONEGrid_' + t + '_Allegato').value == '') {
						err = 1;
						TxtErr('RDOCUMENTAZIONEGrid_' + t + '_Allegato');
					}
					else {
						TxtOK('RDOCUMENTAZIONEGrid_' + t + '_Allegato');
					}

				}


			}

		}

		


		if (err > 0) {

			DMessageBox('../', 'Per proseguire e\' necessaria la compilazione di tutti i campi evidenziati', 'Attenzione', 1, 400, 300);
			return -1;
		}
	}
}


function MyExecDocProcess(param) {

	ExecDocProcess(param);
}

function MySaveDoc() {


	SaveDoc();

}




function Doc_DettagliDel(grid, r, c) {
	var v = '0';
	try {
		v = getObj('RDOCUMENTAZIONEGrid_' + r + '_Obbligatorio').value;
	} catch (e) { };

	if (v == '1') {
		//DMessageBox( '../' , 'La documentazione è obbligatoria' , 'Attenzione' , 1 , 400 , 300 );
	}
	else {
		DettagliDel(grid, r, c);
	}
}


function DOCUMENTAZIONE_AFTER_COMMAND() {
	HideCestinodoc();
	FormatAllegato();
}

function HideCestinodoc() {
	try {
		var i = 0;


		if ((getObj('StatoDoc').value == 'Saved' || getObj('StatoDoc').value == '') && (getObj('SIGN_LOCK').value == '0')) {
			for (i = 0; i < DOCUMENTAZIONEGrid_EndRow + 1; i++) {
				if (getObj('RDOCUMENTAZIONEGrid_' + i + '_Obbligatorio').value == '1') {

					getObj('DOCUMENTAZIONEGrid_r' + i + '_c0').innerHTML = '&nbsp;';
				}
			}
		}
	} catch (e) { }

}
//funzione per inserire nella sezione documentazione i tipi allegati consentiti scelti in creazione del BANDO
function FormatAllegato() {
	var numDocu = GetProperty(getObj('DOCUMENTAZIONEGrid'), 'numrow');
	var tipofile;
	var richiestaFirma;
	var onclick;
	var obj;



	for (i = 0; i <= numDocu; i++) {
		try {
			tipofile = getObj('RDOCUMENTAZIONEGrid_' + i + '_TipoFile').value;

			try {
				richiestaFirma = getObj('RDOCUMENTAZIONEGrid_' + i + '_RichiediFirma').value;
			}
			catch (e) {
				richiestaFirma = '';
			}

			if (tipofile != '') {
				tipofile = ReplaceExtended(tipofile, '###', ',');
				tipofile = 'EXT:' + tipofile.substring(1, tipofile.lenghth);
				tipofile = tipofile.substring(0, tipofile.length - 1) + '-';
				tipofile = 'FORMAT=INTV' + tipofile;

				if (richiestaFirma == '1') {
					tipofile = tipofile + 'INTVB'; //format per forzare la verifica di firma bloccante in caso di mancata firma o file corrotto
				}

				obj = getObj('RDOCUMENTAZIONEGrid_' + i + '_Allegato_V_BTN').parentElement;	//errore
				onclick = obj.innerHTML;
				onclick = onclick.replace(/FORMAT=INTV/g, tipofile);
				onclick = onclick.replace(/FORMAT=INT/g, tipofile);
				obj.innerHTML = onclick;
			}
			//se per qualche motivo tolta INTV nasconde img della pennina

			try {
				if (onclick.indexOf('FORMAT=INTV') < 0) {
					$('#RDOCUMENTAZIONEGrid_' + i + '_Allegato_V_N').siblings('.IMG_SIGNINFO').hide();
				}
			}
			catch (e) {
			}


		}
		catch (e) {
		}
	}


}


function RefreshContent() {
	RefreshDocument('');
}


//GESTIONE DEI CAMPI LOCALITA PROVINCIA E STATO

function initAziEnte() {
	enableDisableAziGeo('LocalitaRapLeg', 'ProvinciaRapLeg', 'StatoRapLeg', 'apriGEO', true);
	enableDisableAziGeo('ResidenzaRapLeg', 'ProvResidenzaRapLeg', 'StatoResidenzaRapLeg', 'apriGEO2', true);
	enableDisableAziGeo('LOCALITALEG', 'PROVINCIALEG', 'STATOLOCALITALEG', 'apriGEO3', true);
}


function impostaLocalita(cod, fieldname) {
	ajax = GetXMLHttpRequest();

	var comuneTec;
	var provinciaTec;
	var statoTec;
	var comuneDesc;
	var provinciaDesc;
	var statoDesc;

	if (fieldname == 'RapLeg') {
		comuneTec = 'LocalitaRapLeg2';
		provinciaTec = 'ProvinciaRapLeg2';
		statoTec = 'StatoRapLeg2';
		comuneDesc = 'LocalitaRapLeg';
		provinciaDesc = 'ProvinciaRapLeg';
		statoDesc = 'StatoRapLeg';
		geo = 'apriGEO'
	}
	if (fieldname == 'ResidenzaRapLeg') {
		comuneTec = 'ResidenzaRapLeg2';
		provinciaTec = 'ProvResidenzaRapLeg2';
		statoTec = 'StatoResidenzaRapLeg2';
		comuneDesc = 'ResidenzaRapLeg';
		provinciaDesc = 'ProvResidenzaRapLeg';
		statoDesc = 'StatoResidenzaRapLeg';
		geo = 'apriGEO2'
	}
	if (fieldname == 'LOCALITALEG') {
		comuneTec = 'LOCALITALEG2';
		provinciaTec = 'PROVINCIALEG2';
		statoTec = 'STATOLOCALITALEG2';
		comuneDesc = 'LOCALITALEG';
		provinciaDesc = 'PROVINCIALEG';
		statoDesc = 'STATOLOCALITALEG';
		geo = 'apriGEO3'
	}


	if (ajax) {
		ajax.open("GET", '../../ctl_library/functions/infoNodoGeo.asp?fldname=localita&cod=' + escape(cod), false);
		//output nella forma : COD-COMUNE#@#DESC-COMUNE#@#COD-PROVINCIA#@#DESC-PROVINCIA#@#COD-STATO#@#DESC-STATO
		ajax.send(null);

		if (ajax.readyState == 4) {
			//Se non ci sono stati errori di runtime
			if (ajax.status == 200) {
				if (ajax.responseText != '') {
					var res = ajax.responseText;

					//Se l'esito della chiamata è stato positivo
					if (res.substring(0, 2) == '1#') {
						try {
							var vet = res.substring(4).split('#@#');

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

							if (codLoc == '' || codLoc.substring(codLoc.length - 3, codLoc.length) == 'XXX')
								disableGeoField(comuneDesc, false);
							else
								disableGeoField(comuneDesc, true);

							getObj(provinciaTec).value = codProv;
							getObj(provinciaDesc).value = descProv;

							if (codProv == '' || codProv.substring(codProv.length - 3, codProv.length) == 'XXX')
								disableGeoField(provinciaDesc, false);
							else
								disableGeoField(provinciaDesc, true);

							getObj(statoTec).value = codStato;
							getObj(statoDesc).value = descStato;

							if (codStato == '' || codStato.substring(codStato.length - 3, codStato.length) == 'XXX')
								disableGeoField(statoDesc, false);
							else
								disableGeoField(statoDesc, true);

						}
						catch (e) {
							alert('Errore:' + e.message);

						}
					}
					else {
						alert('errore.msg:' + res.substring(2));
						enableDisableAziGeo(comuneDesc, provinciaDesc, statoDesc, geo, false);
					}
				}
			}
			else {
				alert('errore.status:' + ajax.status);
				enableDisableAziGeo(comuneDesc, provinciaDesc, statoDesc, geo, false);

			}
		}
		else {
			alert('errore in impostaLocalita');
			enableDisableAziGeo(comuneDesc, provinciaDesc, statoDesc, geo, false);
		}
	}
}


function Filtro_Classe_Iscrizione() {

	if (getObjValue('StatoFunzionale') == 'InLavorazione') {
		//alert('Ok');
		var class_bando = getObj('ClasseIscriz_Bando').value;
		//alert(class_bando);

		if (class_bando != '') {
			var filter = '';

			filter = GetProperty(getObj('ClasseIscriz'), 'filter');

			if (filter == '' || filter == undefined || filter == null) {
				SetProperty(getObj('ClasseIscriz'), 'filter', 'SQL_WHERE= dmv_cod in (  select top 1000000  B.dmv_cod  from ClasseIscriz a  INNER JOIN ClasseIscriz B ON a.dmv_father = left( b.dmv_father , len ( a.dmv_father ) )  or  b.dmv_father = \'000.\'  or b.dmv_father = left( a.dmv_father , len ( b.dmv_father ) )     where  \'' + class_bando + '\' like \'%###\' + A.DMV_COD + \'###%\'    )');
			}
		}
	}
}

function DownloadFileSenzaBusta(att_hash, fileName) {
	var hash;
	var attIdObj;
	var url;
	var nomeFile;
	var ext;

	hash = '';
	attIdObj = '';

	if (att_hash === undefined) {
		hash = document.getElementById('ATT_Hash').value;
	}
	else {
		hash = att_hash;
	}

	if (document.getElementById('attIdObj'))
		attIdObj = document.getElementById('attIdObj').value;

	var tmpVirtualDir;
	tmpVirtualDir = '/Application';

	if (isSingleWin())
		tmpVirtualDir = urlPortale;

	//Se stiamo nella scheda di un allegato del vecchio documento
	if (hash == '' || hash == 'NULL') {
		url = tmpVirtualDir + '/pdf.aspx?mode=ESCLUDI_BUSTA&ATT_HASH=&ATTIDOBJ=' + attIdObj;
	}
	else {
		if (fileName === undefined)
			nomeFile = document.getElementById('nomeFile_V').innerHTML;
		else
			nomeFile = fileName;

		ext = nomeFile.split('.').pop();

		url = tmpVirtualDir + '/pdf.aspx?mode=ESCLUDI_BUSTA&ATT_HASH=' + hash + '&ATTIDOBJ=';
		//url = tmpVirtualDir + '/CTL_Library/functions/field/DisplayAttach.ASP?ESCLUDI_BUSTA=YES&OPERATION=DISPLAY&FIELD=&PATH=&TECHVALUE=' + nomeFile + '*' + ext + '*0*' + hash + '&FORMAT=INT';
	}

	ExecFunction(url, 'DownloadAttach', ',height=200,width=500');
}

function MyCheckCF(fielcomune, fieldcf, obj) {
	//var obj=this;
	var cf = obj.value;

	var controllo = '';
	controllo = ControllaCF(cf);
	//se il codice fiscale non va bene prova a vedere se va bene come PIVA
	if (controllo != '')
		controllo = ControllaPIVA(cf);
	//se il codice fiscale è valido allora va tutto bene
	if (controllo == '') {
		return;
	}
	else //se non è valido controllo se il comune di nascita è italiano allora mostriamo il messaggio altrimenti non fa niente
	{
		var comune = getObj(obj.id.replace(fieldcf, fielcomune)).value;
		//se il comune è vuoto costringo l'utente ad inserirlo
		if (comune == '') {
			obj.value = '';
			AF_Alert('Prima di inputare il codice fiscale compilare il campo comune di nascita');
		}
		ajax = GetXMLHttpRequest();

		if (ajax) {
			var nocache = new Date().getTime();
			ajax.open("GET", pathRoot + 'customdoc/InfoStatoComune.asp?nocache=' + nocache + '&comune=' + escape(comune), false);
			ajax.send(null);

			if (ajax.readyState == 4) {
				//Se non ci sono stati errori di runtime
				if (ajax.status == 200) {
					if (ajax.responseText != '') {
						var res = ajax.responseText; //1 se italiano 0 altrimenti
					}
				}
				else {
					alert('errore.status:' + ajax.status);
				}
			}
		}
		if (ajax.responseText == 1) {
			controllo = ControllaCF(cf);
			if (controllo != '') {
				obj.value = '';
				AF_Alert(controllo);
			}

		}

	}
}
function ChangedComune(fielcomune, fieldcf, obj) {
	getObj(obj.id.replace(fielcomune, fieldcf)).value = '';
}
function Compila_DOC_DGUE() {
	var DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;
	if (DOCUMENT_READONLY == "1") {
		MakeDocFrom('MODULO_TEMPLATE_REQUEST##ISTANZA');
	}
	else {
		ExecDocProcess('FITTIZIO,DOCUMENT,,NO_MSG');
	}
}
function afterProcess(param) {
	if (param == 'FITTIZIO') {
		ShowWorkInProgress();

		setTimeout(function () {

			ShowWorkInProgress();
			MakeDocFrom('MODULO_TEMPLATE_REQUEST##ISTANZA');

		}, 1);
	}
	if (param == 'FITTIZIO2') {
		ShowWorkInProgress();

		setTimeout(function () {

			ShowWorkInProgress();
			MakeDocFrom('INSTANZA_ME_INFO_AGGIUNTIVE##ISTANZA');

		}, 1);
	}
}

function OnChange_ClasseIscriz() {
	try {
		var classi_sel = getObjValue('ClasseIscriz');

		ajax = GetXMLHttpRequest();

		var nocache = new Date().getTime();

		if (ajax) {
			ajax.open("GET", '../../customdoc/PresenzaInfoAggiuntive.asp?IDDOC=' + getObj('IDDOC').value + '&classi_sel=' + encodeURIComponent(classi_sel) + '&nocache=' + nocache, false);

			ajax.send(null);

			if (ajax.readyState == 4) {
				//alert(ajax.status);
				if (ajax.status == 200) {
					if (ajax.responseText == '1') {
						getObj('Richiesta_Info').value = '1';
						document.getElementById('INFO_ADD').style.display = "block";
					}
					else {
						getObj('Richiesta_Info').value = '';
						document.getElementById('INFO_ADD').style.display = "none";
					}
				}
			}
		}
	} catch (e) { }
}

function Compila_Info_Add() {
	if (getObjValue('Richiesta_Info') == '1') {

		if (getObj('DOCUMENT_READONLY').value == "1") {
			MakeDocFrom('INSTANZA_ME_INFO_AGGIUNTIVE##ISTANZA');
		}
		else {
			ExecDocProcess('FITTIZIO2,DOCUMENT,,NO_MSG');
		}
	}
}

function getQSParam(ParamName) {
	// Memorizzo tutta la QueryString in una variabile
	QS = window.location.toString();
	// Posizione di inizio della variabile richiesta
	var indSta = QS.indexOf(ParamName);
	// Se la variabile passata non esiste o il parametro è vuoto, restituisco null
	if (indSta == -1 || ParamName == "") return null;
	// Posizione finale, determinata da una eventuale &amp; che serve per concatenare più variabili
	var indEnd = QS.indexOf('&', indSta);
	// Se non c'è una &amp;, il punto di fine è la fine della QueryString
	if (indEnd == -1) indEnd = QS.length;
	// Ottengo il solore valore del parametro, ripulito dalle sequenze di escape
	var valore = unescape(QS.substring(indSta + ParamName.length + 1, indEnd));
	// Restituisco il valore associato al parametro 'ParamName'
	return valore;
}