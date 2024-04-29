var grigliaProdottiVariata = 'NO';
var conf_num_max_lot_sup = 'NO';
var ML_CHANGE_DOCUMENT = '';
var orig_Set_Change_Document;

//Variabile di appoggio per contenere l'idpfu dell'utente collegato e gestire l'applicazione sia se accessibile sia no
var tmp_idpfuUtenteCollegato;

var LstAttrib = [

	'NomeRapLeg',
	'CognomeRapLeg',
	'LocalitaRapLeg',
	'ProvinciaRapLeg',

];

var NumControlli = LstAttrib.length;

function trim(str) {
	return str.replace(/^\s+|\s+$/g, "");
}

function LocDMessageBox(path, Text, Title, ICO, w, h) {
	//alert(CNV('../../', Text));
	ML_text = Text
	Title = 'Informazione';
	ICO = 1;
	page = 'ctl_library/MessageBoxWin.asp?MODALE=YES&ML=YES&MSG=' + encodeURIComponent(ML_text) + '&CAPTION=' + encodeURIComponent(Title) + '&ICO=' + encodeURIComponent(ICO);

	ExecFunctionModale(page, null, 200, 420, null);

}

function InvioOfferta(param) {

	//alert(param);
	//la chiamata a ControlliOfferta() commentata perch� la coerenza della RTI viene controllata prima di firmare ogni busta
	//e dopo la prima firma le aree RTI diventano a sola lettura per garantire la coerenza con quanto firmato nelle buste

	/*
	var bret = false;
	var bret = ControlliOfferta('');
	//alert(bret);
	if (!bret) {
		return;
	}
	*/

	ExecDocProcess('SEND,OFFERTA,,NO_MSG');

}

function afterProcess(param) {
	//alert(param);
	if (param == 'SIGN_ERASE') {
		OnChange_Allegato_TEC_ECO_SIGN_ERASE();
	}

	if (param == 'VERIFICA_AND_3CLICK') {
		DownloadZipBuste();
	}

	if (param == 'FITTIZIO') {
		ShowWorkInProgress();

		setTimeout(function () {

			ShowWorkInProgress();
			MakeDocFrom('MODULO_TEMPLATE_REQUEST##MANIFESTAZIONE_INTERESSE');

		}, 1);
	}

	if (param == 'FITTIZIO3') {
		ShowWorkInProgress();

		setTimeout(function () {

			ShowWorkInProgress();
			MakeDocFrom('MODULO_QUESTIONARIO_AMMINISTRATIVO##OFFERTA');
		}, 1);
	}

	if (param == 'FITTIZIO2') {
		var cod = getObjValue('idDocR');

		if (cod == '' || cod == undefined) {
			alert('Errore tecnico - IdDocRicDGUE - non trovato');
			return;
		}

		param = 'RICHIESTA_COMPILAZIONE_DGUE_RISPOSTA##OFFERTA#' + cod + '#';

		MakeDocFrom(param);
	}

	if (param == 'BUSTA_DOCUMENTAZIONE_WARNING') {
		DisplaySection();
	}

	if (param == 'SEND') {


		if (getObjValue("StatoFunzionale") == 'Inviato') {

			var Title = 'Informazione';
			var ML_text = 'Invio offerta eseguito correttamente';
			var ICO = 1;
			var page = 'ctl_library/MessageBoxWin.asp?MODALE=YES&ML=YES&MSG=' + encodeURIComponent(ML_text) + '&CAPTION=' + encodeURIComponent(Title) + '&ICO=' + encodeURIComponent(ICO);
			ExecFunctionModaleWithAction(page, null, 200, 420, null, '');

		}
	}

	if (param == 'SAVE_DOC') {
		ElabAIC();
	}

	if (param == 'SAVE_DOC_AMP_GAMMA') {
		ElabAICAmpiezza();
	}



	if (param == 'SAVE_DOC_DM_OFF') {
		Elab_DM();
	}

	if (param == 'SAVE_DOC_DM_AMP_GAMMA') {
		Elab_DMAmpiezza();
	}




	presenzaAmpiezzaGamma()





}

function GeneraPDF() {
	var value2 = controlli('');
	if (value2 == -1)
		return;

	Stato = getObjValue('StatoDoc');

	if (Stato == '') {
		//alert( 'Per effettuare la stampa si richiede prima un salvataggio. Verra\' effettuato in automatico, successivamente effettuare nuovamente il comando di stampa');
		LocDMessageBox('../', 'Per procedere si richiede prima un salvataggio, successivamente effettuare nuovamente il comando genera pdf.', 'Attenzione', 1, 400, 300);
		MySaveDoc();
		return;
	}
	scroll(0, 0);

	//	ReplaceSepClasseIscriz('ClasseIscriz');
	//	ReplaceSepClasseIscriz('SettoriCCNL');

	PrintPdfSign('URL=/report/prn_OFFERTA.ASP?SIGN=YES');

	//RefreshDocument('./');

}

function TogliFirma() {

	/*
		LocDMessageBox('../', 'Si stanno per eliminare tutti i file firmati.', 'Attenzione', 1, 400, 300);	
		ExecDocProcess('SIGN_ERASE,MULTI_SIGN');
	*/
	ML_text = 'CONFIRM_MODIFICA_OFFERTA';
	Title = 'Informazione';
	ICO = 1;
	page = 'ctl_library/MessageBoxWin.asp?MODALE=YES&ML=YES&MSG=' + encodeURIComponent(ML_text) + '&CAPTION=' + encodeURIComponent(Title) + '&ICO=' + encodeURIComponent(ICO);

	ExecFunctionModaleConfirm(page, Title, 200, 420, null, 'TogliFirma_OK', '');
}

function TogliFirma_OK() {
	var ControlloFirmaBuste = getObj('ControlloFirmaBuste');
	var no_msg = 'NO';
	/* SE IL CAMPO ESISTE */
	if (ControlloFirmaBuste) {
		//Se � richiesta la mancata verifica dei controlli di firma ( eccezione del hash di tra il file generato e quello allegato )
		if (ControlloFirmaBuste.value == 'no') {
			no_msg = 'YES';
		}
	}

	//NON MOSTRA IL MESSAGGIO IN QUANTO LO FA IL PROCESSO CHIAMATO DOPO
	if (no_msg == 'YES') {
		ExecDocProcess('SIGN_ERASE,MULTI_SIGN,,NO_MSG');
	}
	else {
		ExecDocProcess('SIGN_ERASE,MULTI_SIGN');
	}


}

function TogliFirmaTEC() {
	/*
		LocDMessageBox('../', 'Si stanno per eliminare tutti i file firmati.', 'Attenzione', 1, 400, 300);
		ExecDocProcess('SIGN_ERASE,MULTI_SIGN');
	*/
	ML_text = 'CONFIRM_MODIFICA_OFFERTA';
	Title = 'Informazione';
	ICO = 1;
	page = 'ctl_library/MessageBoxWin.asp?MODALE=YES&ML=YES&MSG=' + encodeURIComponent(ML_text) + '&CAPTION=' + encodeURIComponent(Title) + '&ICO=' + encodeURIComponent(ICO);

	ExecFunctionModaleConfirm(page, Title, 200, 420, null, 'TogliFirma_OK', '');
}

function SetInitField() {

	var i = 0;
	for (i = 0; i < NumControlli; i++) {
		TxtOK(LstAttrib[i]);
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

function OFFDettagliDel(x, y, z) {
	//alert(getObj('R' + y + '_FNZ_DEL').innerHTML);
	if (getObj('R' + y + '_FNZ_DEL').innerHTML.indexOf('nodisegno.gif') > 0) {
		AF_Alert('Attenzione per il lotto in corso la firma.');
	}
	else {
		//if (getObjValue('R' + y + '_NotEditable') == '') {
		OnChangeEdit(this);
		return DettagliDel(x, y, z);
	}
}

function OffExecDocCommand(param) {
	OnChangeEdit(this);
	return ExecDocCommand(param);
}

function GeneraPDF_ECO() {

	//chiamata ai controlli del documento
	var bret = false;
	var bret = ControlliOfferta('');
	if (!bret) {
		return;
	}

	//LocalPrintPdf('/report/OFFERTA_PRODOTTI.asp?BUSTA=BUSTA_ECONOMICA%26&PAGEORIENTATION=landscape&TO_SIGN=YES&TABLE_SIGN=CTL_DOC_SIGN&IDENTITY_SIGN=idHeader&PDF_NAME=BustaEconomica&AREA_SIGN=F1');
	LocalPrintPdf('URL=/report/OFFERTA_PRODOTTI.asp?BUSTA=BUSTA_ECONOMICA%26&PAGEORIENTATION=landscape&TABLE_SIGN=CTL_DOC_SIGN&IDENTITY_SIGN=idHeader&PDF_NAME=BustaEconomica&AREA_SIGN=F1&PROCESS=OFFERTA%40%40%40VERIFICA_GENERA_PDF');

}

function GeneraPDF_TEC() {

	//chiamata ai controlli del documento
	var bret = false;
	var bret = ControlliOfferta('');
	if (!bret) {
		return;
	}
	//LocalPrintPdf('/report/OFFERTA_PRODOTTI.asp?BUSTA=BUSTA_TECNICA%26&PAGEORIENTATION=landscape&TO_SIGN=YES&TABLE_SIGN=CTL_DOC_SIGN&IDENTITY_SIGN=idHeader&PDF_NAME=BustaTecnica&AREA_SIGN=F3');
	LocalPrintPdf('URL=/report/OFFERTA_PRODOTTI.asp?BUSTA=BUSTA_TECNICA%26&PAGEORIENTATION=landscape&TABLE_SIGN=CTL_DOC_SIGN&IDENTITY_SIGN=idHeader&PDF_NAME=BustaTecnica&AREA_SIGN=F3&PROCESS=OFFERTA%40%40%40VERIFICA_GENERA_PDF');
}

function GeneraPDF_FID() {
	//chiamata ai controlli del documento
	var bret = false;
	var bret = ControlliOfferta('');
	if (!bret) {
		return;
	}

	if (getObjValue('STATE_PDF_BUSTE') == 'all')
		//LocalPrintPdf('/report/OFFERTA_CAUZIONE.asp?&TO_SIGN=YES&TABLE_SIGN=CTL_DOC_SIGN&IDENTITY_SIGN=idHeader&PDF_NAME=Fideiussione&AREA_SIGN=F2');
		LocalPrintPdf('URL=/report/OFFERTA_CAUZIONE.asp?&TABLE_SIGN=CTL_DOC_SIGN&IDENTITY_SIGN=idHeader&PDF_NAME=Attestato di partecipazione&AREA_SIGN=F2');
	else {
		LocDMessageBox('../', 'Per creare il PDF necessario aver generato il pdf di tutte le buste', 'Attenzione', 1, 400, 300);
		return;
	}


}

function LocalPrintPdf(param) {

	//if( SP_NumTotRow == 0 )
	if (PRODOTTIGrid_NumRow == -1) {

		LocDMessageBox('../', 'Per creare il PDF e\' necessario aver compilato la sezione prodotti', 'Attenzione', 1, 400, 300);
		//mi posiziono sul folder prodotti
		DocShowFolder('FLD_PRODOTTI');
		tdoc();
		return;

	}


	//if (getObjValue('RTESTATA_PRODOTTI_MODEL_EsitoRiga') != '') {
	if (getObjValue('RTESTATA_PRODOTTI_MODEL_EsitoRiga').indexOf('State_ERR.gif') > 0) {

		LocDMessageBox('../', 'Per creare il PDF e\' necessario aver compilato la sezione prodotti senza errori', 'Attenzione', 1, 400, 300);
		//mi posiziono sul folder prodotti
		DocShowFolder('FLD_PRODOTTI');
		tdoc();
		return;

	}


	Stato = getObjValue('StatoDoc');

	if (Stato == '') {
		LocDMessageBox('../', 'Per effettuare la stampa si richiede prima un salvataggio. Verra\' effettuato in automatico, successivamente effettuare nuovamente il comando di stampa.', 'Attenzione', 1, 400, 300);
		MySaveDoc();
		return;
	}

	//PrintPdf(param);
	PrintPdfSign(param);
}

function HideProdotti() {

	if (getObjValue('RichiediProdotti') == '0') {

		document.getElementById('PRODOTTI').style.display = "none";
	}


}

//funzione per inserire nella sezione documentazione i tipi allegati consentiti scelti in creazione del BANDO
function FormatAllegato() {

	var numDocu = GetProperty(getObj('DOCUMENTAZIONEGrid'), 'numrow');
	var tipofile;
	var richiestaFirma;
	var onclick;
	var obj;
	var strFormat;



	for (i = 0; i <= numDocu; i++) {
		try {

			tipofile = '';
			tipofile = getObj('RDOCUMENTAZIONEGrid_' + i + '_TipoFile').value;

			try {
				richiestaFirma = getObj('RDOCUMENTAZIONEGrid_' + i + '_RichiediFirma').value;
			} catch (e) {
				richiestaFirma = '';
			}

			if (tipofile != '') {

				tipofile = ReplaceExtended(tipofile, '###', ',');
				tipofile = 'EXT:' + tipofile.substring(1, tipofile.length);
				tipofile = tipofile.substring(0, tipofile.length - 1) + '-';
			}


			//RECUPERO DINAMICAMENTE LA Format			
			obj = getObj('RDOCUMENTAZIONEGrid_' + i + '_Allegato_V_BTN').parentElement;
			onclick = obj.innerHTML;
			nPosStartFormat = onclick.indexOf('&amp;FORMAT=');
			strTailOnclick = onclick.substring(nPosStartFormat + 12, nPosStartFormat + 100);
			nPosEndParametri = strTailOnclick.indexOf('\' ');

			nPosEndFormat = strTailOnclick.indexOf('&amp;');
			if (nPosEndFormat == -1)
				nPosEndFormat = nPosEndParametri;

			strHeadFormat = strTailOnclick.substring(0, nPosEndFormat);
			strPatternFormat = 'FORMAT=' + strHeadFormat;
			if (richiestaFirma == '1') {
				strHeadFormat = strHeadFormat + 'B'; //format per forzare la verifica di firma bloccante in caso di mancata firma o file corrotto
			}
			tipofile = strHeadFormat + tipofile;
			strExt = 'FORMAT=' + tipofile;
			onclick = onclick.replace(new RegExp(strPatternFormat, 'g'), strExt);

			obj.innerHTML = onclick;

		} catch (e) { }
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
		//DMessageBox( '../' , 'La documentazione � obbligatoria' , 'Attenzione' , 1 , 400 , 300 );
	} else {
		DettagliDel(grid, r, c);
	}
}

function DOCUMENTAZIONE_AFTER_COMMAND() {
	HideCestinodoc();
	FormatAllegato();
	FormatNumDec();

	attachFilePending();
	ControlloFirmaBuste();

	try {
		getObj('DOCUMENTAZIONEGrid').onchange = OnChangeEdit_DOC;
	} catch (e) { };

	try {
		// Con il settaggio precedente l'evento di onchange si propaga solo sui field visuali che prevedono l'evento onchange.
		// Lasciando fuori quindi, ad esempio, i campi hidden. Vado ad aggiungere una funzione specifica per questi ultimi 
		// cos� da accorgerci di un cambiamento effettuato anche sui campi attach (che fanno scattare programmaticamente l'evento di onchange
		// sul campo tecnico nascosto )
		$('#DOCUMENTAZIONEGrid').find("input[type='hidden']").each(function (index) {
			$(this).get()[0].onchange = OnChangeEdit_DOC;
		});

	} catch (e) { alert(e.message); }

}



function HideCestinodoc() {

	var DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;

	if (DOCUMENT_READONLY == '1')
		return;

	try {
		var i = 0;

		if (getObj('StatoDoc').value == 'Saved' || getObj('StatoDoc').value == '') {
			for (i = 0; i < DOCUMENTAZIONEGrid_EndRow + 1; i++) {
				if (getObj('RDOCUMENTAZIONEGrid_' + i + '_Obbligatorio').value == '1') {
					getObj('DOCUMENTAZIONEGrid_r' + i + '_c0').innerHTML = '&nbsp;';
				}
			}
		}
	} catch (e) { }

}

function HideCestinoProdotti() {

	var DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;

	if (DOCUMENT_READONLY == '1')
		return;

	try {
		var i = 0;

		if (getObj('Complex').value != '1') {
			for (i = 0; i < PRODOTTIGrid_EndRow + 1; i++) {
				ShowCol('PRODOTTI', 'FNZ_DEL', 'none');
			}
		}
		//per i complex lascio le funzionalit� sul cestino solo se non � in corso la firma del lotto
		else {
			for (i = 0; i < PRODOTTIGrid_EndRow + 1; i++) {
				if (getObj('R' + i + '_FNZ_DEL').innerHTML.indexOf('nodisegno.gif') > 0) {
					//nascondo il cestino sulla  riga
					getObjGrid('R' + i + '_FNZ_DEL').style.display = 'none';

				}
			}
		}
	} catch (e) { }

}


function OnClickProdotti(obj) {
	var Stato = '';
	Stato = getObjValue('StatoDoc');

	if (Stato == '') {
		LocDMessageBox('../', 'Prima di procedere con l\'importazione dei prodotti � necessario effettuare un salvataggio del documento', 'Attenzione', 1, 400, 300);
	} else {

		if (getObjValue('FIRMA_IN_CORSO') == '1') {
			LocDMessageBox('../', 'L\'operazione di caricamento file offerte togliera\' tutte le firme attualmente inserite', 'Attenzione', 1, 400, 300);

		}


		var DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;
		if (DOCUMENT_READONLY == "1")
			DMessageBox('../', 'Documento in sola lettura', 'Attenzione', 1, 400, 300);
		else
			ImportExcel('CAPTION_ROW=yes&TITLE=Upload Excel&TABLE=CTL_Import&FIELD=RTESTATA_PRODOTTI_MODEL_Allegato&SHEET=0&PARAM=posizionale&PROCESS=LOAD_PRODOTTI,OFFERTA&OWNER_FIELD=Idpfu&OPERATION=INSERT#new#600,450');
	}


}


function RefreshContent() {


	//alert('ciao');

	RefreshDocument('');


}


function FIRMA_ECONOMICA_OnLoad() {

	DisplaySection();

	try {

		if (getObjValue('RichiestaFirma') == 'no') {
			document.getElementById('DIV_FIRMA_ECO').style.display = "none";
			return;
		}
		//alert('F1');
		FieldToSign('F1');
	} catch (e) { };
}

function FIRMA_TECNICA_OnLoad() {


	try {

		if (getObjValue('RichiestaFirma') == 'no') {
			document.getElementById('DIV_FIRMA_TEC').style.display = "none";
			return;
		}
		//alert('F3');
		FieldToSign('F3');
	} catch (e) { };
}


function FIRMA_FIDEUSSIONE_OnLoad() {
	try {

		if (getObjValue('RichiestaFirma') == 'no' || getObjValue('ClausolaFideiussoria') != '1') {
			document.getElementById('DIV_FIRMA_FID').style.display = "none";
		} else {
			FieldToSign('F2');
		}
		FormatAllegato();

	} catch (e) { };

}

function FieldToSign(Field) {

	var Stato = '';
	Stato = getObjValue('StatoDoc');
	try { var DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value; } catch (e) { DOCUMENT_READONLY = 0; }
	//alert(DOCUMENT_READONLY);
	if ((getObjValue(Field + '_SIGN_LOCK') == '0' || getObjValue(Field + '_SIGN_LOCK') == '') && (Stato == 'Saved' || Stato == "") && (DOCUMENT_READONLY != '1')) {
		document.getElementById(Field + '_generapdf').disabled = false;
		document.getElementById(Field + '_generapdf').className = "generapdf";
	} else {
		document.getElementById(Field + '_generapdf').disabled = true;
		document.getElementById(Field + '_generapdf').className = "generapdfdisabled";
	}


	if ((getObjValue(Field + '_SIGN_LOCK') != '0' && getObjValue(Field + '_SIGN_LOCK') != '') && (Stato == 'Saved') && (DOCUMENT_READONLY != '1')) {
		document.getElementById(Field + '_editistanza').disabled = false;
		document.getElementById(Field + '_editistanza').className = "attachpdf";
	} else {
		document.getElementById(Field + '_editistanza').disabled = true;
		document.getElementById(Field + '_editistanza').className = "attachpdfdisabled";
	}

	if (getObjValue(Field + '_SIGN_ATTACH') == '' && (Stato == 'Saved') && (getObjValue(Field + '_SIGN_LOCK') != '0' && getObjValue(Field + '_SIGN_LOCK') != '') && (DOCUMENT_READONLY != '1')) {
		document.getElementById(Field + '_attachpdf').disabled = false;
		document.getElementById(Field + '_attachpdf').className = "editistanza";
	} else {
		document.getElementById(Field + '_attachpdf').disabled = true;
		document.getElementById(Field + '_attachpdf').className = "editistanzadisabled";
	}

}


function DownLoadCSV() {

	//SE ANCORA NON SONO PRESENTI LOTTI SULLA MIA OFFERTA 
	//ESPORTO TUTTI I LOTTI DEL BANDO ALTRIMENTI SOLO QUELLI PRESENTI SUL DOC OFFERTA  SFRUTTANDO LA VISTA COSTRUITA PER IL CASO
	//-- ATTIVITA' 237397	
	var TipoBando = getObjValue('TipoBando');
	var LinkedDoc = getObjValue('LinkedDoc');
	//var DocBANDO = getObjValue( 'JumpCheck' );
	var DocBANDO = getObjValue('TipoDocBando');
	if (DocBANDO == '') DocBANDO = 'BANDO_SEMPLIFICATO'

	var IDDOC = getObjValue('IDDOC');
	var VIEW = '';


	if (PRODOTTIGrid_EndRow > -1) {
		var VIEW = 'DownLoadCSV_OFFERTA_LOTTI_SCELTI';
		ExecFunction('../../Report/CSV_LOTTI.asp?IDDOC=' + LinkedDoc + '&VIEW=' + VIEW + '&TIPODOC=' + DocBANDO + '&MODEL=' + getObjValue('ModelloOfferta') + '&FilterHide=idoff=' + getObjValue('IDDOC') + '&HIDECOL=ValoreImportoLotto,ESITORIGA');
	}
	else {
		//ExecFunction('../../Report/CSV_LOTTI.asp?IDDOC=' + LinkedDoc + '&TIPODOC=' + DocBANDO + '&MODEL=MODELLI_LOTTI_' + TipoBando + '_MOD_OffertaINPUT');
		ExecFunction('../../Report/CSV_LOTTI.asp?IDDOC=' + LinkedDoc + '&VIEW=' + VIEW + '&TIPODOC=' + DocBANDO + '&MODEL=' + getObjValue('ModelloOfferta') + '&HIDECOL=ValoreImportoLotto,ESITORIGA');
		//ExecFunction('../../Report/CSV_LOTTI.asp?IDDOC=' + IDDOC + '&TIPODOC=OFFERTA&MODEL=' + getObjValue('ModelloOfferta') );
	}
}

window.onload = DisplaySection;

function OnChangeEdit(obj) {
	grigliaProdottiVariata = 'YES';



	try {
		SetTextValue('RTESTATA_PRODOTTI_MODEL_EsitoRiga', '<img src="../images/Domain/State_ERR.gif"><br>' + CNV('../../', 'L\'elenco Prodotti e\' stato modificato, e\' necessario eseguire il comando Verifica Informazioni'));
	}
	catch (e) { }

	try {
		var targ = '';

		//Se l'evento di onchange non � scattato da un iterazione utente
		if (obj == undefined)
			targ = this.id;
		else
			targ = obj.srcElement.id;

		//alert(targ);

		sganciaEsitoRiga(targ);

	}
	catch (e) {
	}

}


function OnChangeEdit_DOC(obj) {




	try {
		SetTextValue('RTESTATA_DOCUMENTAZIONE_MODEL_EsitoRiga', '<img src="../images/Domain/State_Warning.gif"><br>' + CNV('../../', 'La Lista Allegati e\' stata modificata, e\' necessario eseguire il comando Verifica Informazioni'));
	}
	catch (e) { }

	try {
		var targ = '';

		//Se l'evento di onchange non � scattato da un iterazione utente
		if (obj == undefined)
			targ = this.id;
		else
			targ = obj.srcElement.id;

		//		alert(targ);

		sganciaEsitoRiga_DOC(targ);

	}
	catch (e) {
	}

}

function DisplaySection(obj) {
	//sezione codice Ampiezza di gamma 
	presenzaAmpiezzaGamma()

	//visualizzo messaggio se rettificato
	if (getObjValue('Versione') == 'RETTIFICA')
		AF_Alert('Attenzione offerta economica rettificata in fase di valutazione economica');

	if (!getObj('DOCUMENT_READONLY'))
		return;

	var bVisualMessageDataSuperata;

	bVisualMessageDataSuperata = 0;

	//SE OFFERTA IN QUESTO CASO APRO ANOMALIA AMMINISTRATIVA
	if (getObjValue("StatoFunzionale") == 'InvioInCorso_amministrativa') {
		//apro ildoc di anomalia se: la data di invio superata ed � consentito il fuori termine oppure se la data di invio non � superata	
		if ((getObjValue("CONSENTI_INVIO_FT") == '1' && getObjValue("DATA_INVIO_SUPERATA") == '1') || getObjValue("DATA_INVIO_SUPERATA") == '0') {

			var IDDOC = getObjValue('IDDOC');
			param = 'OFFERTA_ANOMALIE_AMMINISTRATIVA##OFFERTA#' + IDDOC + '#';
			MakeDocFrom(param);
			return;
		} else {
			bVisualMessageDataSuperata = 1;
		}

	}

	if (getObjValue("StatoFunzionale") == 'InvioInCorso_prodotti') {
		//apro ildoc di anomalia se: la data di invio superata ed � consentito il fuori termine oppure se la data di invio non � superata		
		if ((getObjValue("CONSENTI_INVIO_FT") == '1' && getObjValue("DATA_INVIO_SUPERATA") == '1') || getObjValue("DATA_INVIO_SUPERATA") == '0') {
			var IDDOC = getObjValue('IDDOC');
			param = 'OFFERTA_ANOMALIE_PRODOTTI##OFFERTA#' + IDDOC + '#';
			MakeDocFrom(param);
			return;
		} else {
			bVisualMessageDataSuperata = 1;
		}
	}

	//se staofunzionale in lavorazione e se la data di invio superata e non previsto fuori termine visualizzo messaggio termini scaduti
	if (getObjValue("StatoFunzionale") == 'InLavorazione' && getObjValue("DATA_INVIO_SUPERATA") == '1' && getObjValue("CONSENTI_INVIO_FT") == '0') {

		bVisualMessageDataSuperata = 1;
	}

	if (bVisualMessageDataSuperata == 1) {

		AF_Alert('i termini di presentazione dell\'offerta sono superati');

	}


	try {
		getObj('DOCUMENTAZIONEGrid').onchange = OnChangeEdit_DOC;
	} catch (e) { };

	try {
		// Con il settaggio precedente l'evento di onchange si propaga solo sui field visuali che prevedono l'evento onchange.
		// Lasciando fuori quindi, ad esempio, i campi hidden. Vado ad aggiungere una funzione specifica per questi ultimi 
		// cos� da accorgerci di un cambiamento effettuato anche sui campi attach (che fanno scattare programmaticamente l'evento di onchange
		// sul campo tecnico nascosto )
		$('#DOCUMENTAZIONEGrid').find("input[type='hidden']").each(function (index) {
			$(this).get()[0].onchange = OnChangeEdit_DOC;
		});

	} catch (e) { alert(e.message); }



	try {
		getObj('PRODOTTIGrid').onchange = OnChangeEdit;
	} catch (e) { };

	try {
		// Con il settaggio precedente l'evento di onchange si propaga solo sui field visuali che prevedono l'evento onchange.
		// Lasciando fuori quindi, ad esempio, i campi hidden. Vado ad aggiungere una funzione specifica per questi ultimi 
		// cos� da accorgerci di un cambiamento effettuato anche sui campi attach (che fanno scattare programmaticamente l'evento di onchange
		// sul campo tecnico nascosto )
		$('#PRODOTTIGrid').find("input[type='hidden']").each(function (index) {
			$(this).get()[0].onchange = OnChangeEdit;
		});

	} catch (e) { alert(e.message); }


	if (getObj('CriterioAggiudicazioneGara')) {

		var crit = getObjValue('CriterioAggiudicazioneGara');
		var conf = getObjValue('Conformita');
		var Divisione_lotti = getObjValue('Divisione_lotti');
		var Concessione = getObjValue('Concessione');

		try {
			//-- le gare al prezzo pi� alto o concessione non devono mostrare il ribasso
			if (crit == '16291' || Concessione == 'si') {
				$("#cap_ValoreEconomico").parents("table:first").css({ "display": "none" })
				$("#cap_ValoreRibasso").parents("table:first").css({ "display": "none" })

				$("#Cell_ValoreEconomico").parents("table:first").css({ "display": "none" })
				$("#Cell_ValoreRibasso").parents("table:first").css({ "display": "none" })
			}

		} catch (e) { };

		//-- se � privista la conformita Ex-Ante oppure � economicamente pi� vantaggiosa
		//if( ( conf == 'Ex-Ante' || crit == '15532' ) && Divisione_lotti != '0' )
		if (Divisione_lotti != '0') {
			//SE GARA A LOTTI

			/*
			Enrico: gestione spostata nella STORED CK_SEC_DOC_OFFERTA
			if( getObjValue('ProceduraGara') != '15583' && getObjValue('ProceduraGara') != '15479' ) //NE AFFIDAMENTO E NE RICHIESTA PREVENTIVO
			{
				try{	
					DocDisplayFolder('BUSTA_ECONOMICA', 'none');
				}catch(e){}
			}
		    
			try{
				DocDisplayFolder('LISTA_LOTTI', '');
			}catch(e){}
			*/

			//se non ho la parte tecnica nascondo la colonan della busta tecnica
			//if (conf != 'Ex-Ante' && crit != '15532')
			//    ShowCol('LISTA_BUSTE', 'Esito_Busta_Tec', 'none');
			//-- SE PER TUTTA LA COLONNA NON � NECESSARIA LA BUSTA TECNICA RIMUOVO LA COLONNA

			try {
				var i;
				var ShowTec = '';
				var NumRow_Buste = SP_NumTotRow_SP_LISTA_BUSTE;

				//alert(NumRow_Buste);

				//for( i = 0 ; getObj( 'RLISTA_BUSTEGrid_' + i + '_Esito_Busta_Tec') != undefined ; i++ )
				for (i = 0; i < NumRow_Buste; i++) {
					try {
						if (getObjValue('RLISTA_BUSTEGrid_' + i + '_Esito_Busta_Tec') == '')
							getObj('LISTA_BUSTEGrid_r' + i + '_c3').innerHTML = '';
						else
							ShowTec = 'Presente Colonna';

					} catch (e) { }

				}

				if (ShowTec == '')
					ShowCol('LISTA_BUSTE', 'Esito_Busta_Tec', 'none');

			} catch (e) { }



		}
		/*
		//Enrico - questa gestione non serve perch� presente nella stored ed anche pi� completa
		else {
			
			//SE GARA NON A LOTTI
			
			//questa gestione non serve perch� presente nella stored ed anche pi� completa
			try{
				DocDisplayFolder('BUSTA_ECONOMICA', '');
				DocDisplayFolder('LISTA_LOTTI', 'none');
			}catch(e){}
			
		}
		
		//-- a fronte di un bando di Ristretta le sole buste presenti saranno copertina e documentazione
		try {
			if (getObjValue('ProceduraGara') == '15477' && getObjValue('TipoBandoGara') == '2') {
				try{
					//ragionamenti spostati nella STORED CK_SEC_DOC_OFFERTA
					//DocDisplayFolder('BUSTA_ECONOMICA', 'none');
					//DocDisplayFolder('LISTA_LOTTI', 'none');
					//questo non serve perch� apro la domanda per una ristretta-bando e mai una offerta
					DocDisplayFolder('PRODOTTI', 'none');
				}catch(e){}
			}

		} catch (e) {};

		*/


		HideShowAreeRTI();
		HideCestinodoc();
		FormatAllegato();
		FormatNumDec();
		Show_Hide_dgue_COL();
		HideCestinoProdotti();
		attachFilePending();
		ControlloFirmaBuste();

		//innescate le funzioni per gestire i bottoni di genera pdf perch� la variabile DOCUMENT_READONLY non � ancora disponibile al caricamento delle varie sezioni 
		try { FieldToSign('F1'); } catch (e) { };
		try { FieldToSign('F2'); } catch (e) { };
		try { FieldToSign('F3'); } catch (e) { };
		try { TESTATA_LISTA_BUSTE_OnLoad(); } catch (e) { };


	}


	try {
		//if ( getObjValue('RTESTATA_PRODOTTI_MODEL_EsitoRiga') != '' && getObjValue('RTESTATA_PRODOTTI_MODEL_EsitoRiga') != '<img src="../images/Domain/State_OK.gif">' )
		if (getObjValue('RTESTATA_PRODOTTI_MODEL_EsitoRiga').indexOf('State_ERR.gif') > 0) {
			document.getElementById('RTESTATA_PRODOTTI_MODEL_EsitoRiga_V').className = "Text_Esito_Errore";
		}
		else {
			document.getElementById('RTESTATA_PRODOTTI_MODEL_EsitoRiga_V').className = "Text";
		}
	} catch (e) { };

	if (getObjValue('PresenzaDGUE') != 'si') {
		document.getElementById('DIV_DGUE').style.display = "none";
	}

	if (getObjValue('PresenzaDGUE') == 'si') {
		document.getElementById('CompilaDGUE').disabled = false;
		document.getElementById('CompilaDGUE').className = "CompilaDGUE";
	}

	if (getObjValue('PresenzaQuestionario') !== 'si') {
		document.getElementById('DIV_QUESTIONARIO_AMMINISTRATIVO').style.display = "none";
	}

	if (getObjValue('PresenzaQuestionario') === 'si') {
		document.getElementById('CompilaQuestionarioAmministrativo').disabled = false;
		document.getElementById('CompilaQuestionarioAmministrativo').className = "compilaQuestionario";
	}

	if (getObjValue('Richiesta_terna_subappalto_sul_bando') != '1') {
		getObj('div_SUBAPPALTOGRIDGrid').style.display = 'none';
		$("#cap_Richiesta_terna_subappalto").parents("table:first").css({ "display": "none" });
		$("#Richiesta_terna_subappalto").parents("table:first").css({ "display": "none" });

	}

	//-- controlli su associazione RTI
	try {
		if (getObj('PartecipaFormaRTI').value == '1') {
			document.getElementById('Associazione_RTI').style.display = "";
			document.getElementById('cap_Associazione_RTI').style.display = "";
		}
		else {
			document.getElementById('Associazione_RTI').style.display = "none";
			document.getElementById('cap_Associazione_RTI').style.display = "none";
		}

	}
	catch (e) {
	}



	icona_folder_documento();
	label_controllo_firma_buste();

	//imposto filtro sul campo scegli_lotti e lo nascondo
	try {
		var id_bando = getObjValue('LinkedDoc');
		var filtro = '';
		filtro = 'SQL_WHERE= idHEader  = ' + id_bando;
		SetProperty(getObj('RSCEGLI_LOTTI_MODEL_Scegli_Lotti'), 'filter', filtro);



	}
	catch (e) { }

	//se documento non editabile non invoca la funzione LOAD_DominiCriteri
	try {
		if (getObjValue('DOCUMENT_READONLY') == '0') {
			LOAD_DominiCriteri();
		}
	}
	catch (e) { }

	//vado a settare il messaggio di uscita 
	//quando l'utente abbandona il documento
	//e quando lo stesso � pronto per invio
	//e rimappo la funzione  Set_Change_Document
	//per cambiare messaggio se ho fatto modifiche e doc pronto per invio
	Init_Msg_For_AlertAbandon();

	//ampiezza di gamma
	try {
		if (typeof idpfuUtenteCollegato === 'undefined')
			tmp_idpfuUtenteCollegato = getObjValue('IdpfuInCharge');
		else
			tmp_idpfuUtenteCollegato = idpfuUtenteCollegato;

		if ((getObjValue('SIGN_LOCK') == '0' || getObjValue('SIGN_LOCK') == '')) {
			document.getElementById('generapdf').disabled = false;
			document.getElementById('generapdf').className = "generapdf";
		}
		else {
			document.getElementById('generapdf').disabled = true;
			document.getElementById('generapdf').className = "generapdfdisabled";
		}


		if (getObjValue('SIGN_LOCK') != '0') {
			document.getElementById('editistanza').disabled = false;
			document.getElementById('editistanza').className = "attachpdf";
		}
		else {
			document.getElementById('editistanza').disabled = true;
			document.getElementById('editistanza').className = "attachpdfdisabled";
		}
		if (getObjValue('SIGN_LOCK') != '0') {
			document.getElementById('attachpdf').disabled = false;
			document.getElementById('attachpdf').className = "editistanza";
		}
		else {
			document.getElementById('attachpdf').disabled = true;
			document.getElementById('attachpdf').className = "editistanzadisabled";
		}
	}
	catch (e) {

	}


}

function OpenAmpiezzaDiGamma(objGrid, Row, c) {
	var voce;
	var lotto;
	var ampiezzaGamma

	var tabellaSelezinataEcoTec = 0
	if (objGrid == 'BUSTA_ECONOMICAGrid' || objGrid == 'BUSTA_TECNICAGrid') {
		tabellaSelezinataEcoTec = 1
	}

	if (tabellaSelezinataEcoTec == 0) {
		ampiezzaGamma = getObj('R' + Row + '_AmpiezzaGamma').value;
		try {
			voce = getObj('R' + Row + '_Voce').value;
			lotto = getObj('R' + Row + '_NumeroLotto').value;
		}
		catch (e) { //-- le gare senza lotti non hanno lotto voce
			voce = getObj('R' + Row + '_NumeroRiga').value;
			lotto = '1';
		}
	}
	else {
		if (objGrid == 'BUSTA_ECONOMICAGrid') {
			ampiezzaGamma = getObj('RBUSTA_ECONOMICAGrid_' + Row + '_AmpiezzaGamma').value;
			try {
				voce = getObj('RBUSTA_ECONOMICAGrid_' + Row + '_Voce').value;
				lotto = getObj('RBUSTA_ECONOMICAGrid_' + Row + '_NumeroLotto').value;
			}
			catch (e) { //-- le gare senza lotti non hanno lotto voce
				voce = getObj('RBUSTA_ECONOMICAGrid_' + Row + '_NumeroRiga').value;
				lotto = '1';
			}
		}

		if (objGrid == 'BUSTA_TECNICAGrid') {
			ampiezzaGamma = getObj('RBUSTA_TECNICAGrid_' + Row + '_AmpiezzaGamma').value;
			try {
				voce = getObj('RBUSTA_TECNICAGrid_' + Row + '_Voce').value;
				lotto = getObj('RBUSTA_TECNICAGrid_' + Row + '_NumeroLotto').value;
			}
			catch (e) { //-- le gare senza lotti non hanno lotto voce
				voce = getObj('RBUSTA_TECNICAGrid_' + Row + '_NumeroRiga').value;
				lotto = '1';
			}
		}
	}



	var lotto_voce = lotto + '-' + voce
	var IDDOC = getObj('IDDOC').value;

	if (ampiezzaGamma == '0') {
		LocDMessageBox('../', 'Ampiezza di gamma non prevista per la riga', 'Attenzione', 1, 400, 300);
	}
	else {

		param = 'OFFERTA_AMPIEZZA_DI_GAMMA##OFFERTA#' + IDDOC + '###' + lotto_voce + '#';


		if (objGrid == 'BUSTA_ECONOMICAGrid')
			param = 'OFFERTA_AMPIEZZA_DI_GAMMA_ECO##OFFERTA#' + IDDOC + '###' + lotto_voce + '#';

		if (objGrid == 'BUSTA_TECNICAGrid')
			param = 'OFFERTA_AMPIEZZA_DI_GAMMA_TEC##OFFERTA#' + IDDOC + '###' + lotto_voce + '#';


		MakeDocFrom(param);
	}


}

function nascondiDettaglioAmpiezzaGamma() {
	var numrow = GetProperty(getObj('PRODOTTIGrid'), 'numrow');
	var ampiezzaGammaAttiva = 0
	for (i = 0; i <= numrow; i++) {

		// var voce = getObj('R'+ i +'_Voce').value;
		var ampiezzaGamma = getObj('R' + i + '_AmpiezzaGamma').value;

		if (ampiezzaGamma == '0') {
			try {
				var bottone = getObj('R' + i + '_FNZ_OPEN');
				bottone.remove();
			}
			catch (e) { }

		}
		else {
			ampiezzaGammaAttiva = 1
		}

	}

	if (ampiezzaGammaAttiva == 0) {
		ShowCol('PRODOTTI', 'FNZ_OPEN', 'none');
	}
}


function OpenEconomica(objGrid, Row, c) {

	//permetto apertura della tecnica per generare pdf solo se ho composto RTI in modo corretto
	var bret = false;

	//se documento non editabile non faccio i controlli
	if (getObjValue('DOCUMENT_READONLY') != '0')
		bret = true;
	else
		bret = CanSendRTI();


	if (!bret) {
		DocShowFolder('FLD_BUSTA_DOCUMENTAZIONE');
		tdoc();
		return;
	}

	//se ho fatto modifiche alla RTI e non ho salvato avviso
	if (getObj('DenominazioneATI_DB').value != getObj('DenominazioneATI').value) {

		/*	if ( confirm( CNV('../../', 'Sono stati modificati i dati della RTI.Per procedere si richiede prima un salvataggio.') ) ){
					SaveDoc('');
					return ;
			}else
				return ;	
		*/

		ML_text = 'Sono stati modificati i dati della RTI.Per procedere si richiede prima un salvataggio.';
		Title = 'Informazione';
		ICO = 1;
		page = 'ctl_library/MessageBoxWin.asp?MODALE=YES&ML=YES&MSG=' + encodeURIComponent(ML_text) + '&CAPTION=' + encodeURIComponent(Title) + '&ICO=' + encodeURIComponent(ICO);

		ExecFunctionModaleConfirm(page, Title, 200, 420, null, 'SaveDoc', '');
		return;
	}


	var apri = 'SI';

	//if ( getObjValue('RLISTA_BUSTEGrid_' + Row + '_EsitoRiga') == '<img src="../images/Domain/State_OK.gif">' )
	//if ( getObjValue('RLISTA_BUSTEGrid_' + Row + '_EsitoRiga') != '<img src="../images/Domain/State_ERR.gif">' )
	if (getObjValue('RLISTA_BUSTEGrid_' + Row + '_EsitoRiga').indexOf('State_ERR.gif') == -1) {
		//Se la griglia dei prodotti � stata modificata senza salvare
		if (grigliaProdottiVariata == 'YES') {

			/*
			if( confirm(CNV( '../../','Attenzione sono stati modificati i dati sul foglio per il Caricamento Lotti proseguendo senza effettuare un salvataggio i dati modificati verranno persi, si desidera proseguire?')) )
				apri = 'SI';
			else
				apri = 'NO';
			*/
			ML_text = 'Attenzione sono stati modificati i dati sul foglio per il Caricamento Lotti proseguendo senza effettuare un salvataggio i dati modificati verranno persi, si desidera proseguire?';
			Title = 'Informazione';
			ICO = 1;
			page = 'ctl_library/MessageBoxWin.asp?MODALE=YES&ML=YES&MSG=' + encodeURIComponent(ML_text) + '&CAPTION=' + encodeURIComponent(Title) + '&ICO=' + encodeURIComponent(ICO);

			ExecFunctionModaleConfirm(page, Title, 200, 420, null, 'APRI_OK@@@@' + Row, '');
			return;
		}

		if (apri == 'SI') {
			//aggiorno il doc in mem 
			UpdateDocInMem(getObj('IDDOC').value, getObj('TYPEDOC').value);

			var cod = getObj('RLISTA_BUSTEGrid_' + Row + '_id').value;
			ShowDocumentPath('OFFERTA_BUSTA_ECO', cod, '../');
		}
	}
	else {
		AF_Alert('Prima di procedere e\' necessario risolvere le anomalie presenti sui prodotti del lotto');
	}
}
function APRI_OK(Row) {
	//aggiorno il doc in mem 
	UpdateDocInMem(getObj('IDDOC').value, getObj('TYPEDOC').value);
	var cod = getObj('RLISTA_BUSTEGrid_' + Row + '_id').value;
	ShowDocumentPath('OFFERTA_BUSTA_ECO', cod, '../');
}

function OpenTecnica(objGrid, Row, c) {

	//permetto apertura della tecnica per generare pdf solo se ho composto RTI in modo corretto
	var bret = false;

	//se documento non editabile non faccio i controlli
	if (getObjValue('DOCUMENT_READONLY') != '0')
		bret = true;
	else
		bret = CanSendRTI();


	if (!bret) {
		DocShowFolder('FLD_BUSTA_DOCUMENTAZIONE');
		tdoc();
		return;
	}

	//se ho fatto modifiche alla RTI e non ho salvato avviso
	if (getObj('DenominazioneATI_DB').value != getObj('DenominazioneATI').value) {

		/*
		if ( confirm( CNV('../../', 'Sono stati modificati i dati della RTI.Per procedere si richiede prima un salvataggio.') ) ){
				SaveDoc('');
				return ;
		}else
			return ;	
		*/

		ML_text = 'Sono stati modificati i dati della RTI.Per procedere si richiede prima un salvataggio.';
		Title = 'Informazione';
		ICO = 1;
		page = 'ctl_library/MessageBoxWin.asp?MODALE=YES&ML=YES&MSG=' + encodeURIComponent(ML_text) + '&CAPTION=' + encodeURIComponent(Title) + '&ICO=' + encodeURIComponent(ICO);

		ExecFunctionModaleConfirm(page, Title, 200, 420, null, 'SaveDoc', '');
		return;

	}


	var apri = 'SI';

	//Permetto l'apertura della tecnica solo se il lotto relativo ha un esito ok sulla riga
	//var numLotto = getObjValue('RLISTA_BUSTEGrid_' + Row + '_NumeroLotto');

	//if ( getObjValue('RLISTA_BUSTEGrid_' + Row + '_EsitoRiga') == '<img src="../images/Domain/State_OK.gif">' )

	//if ( getObjValue('RLISTA_BUSTEGrid_' + Row + '_EsitoRiga') != '<img src="../images/Domain/State_ERR.gif">' )
	if (getObjValue('RLISTA_BUSTEGrid_' + Row + '_EsitoRiga').indexOf('State_ERR.gif') == -1) {
		//Se la griglia dei prodotti � stata modificata senza salvare
		if (grigliaProdottiVariata == 'YES') {
			/*if( confirm(CNV( '../../','Attenzione sono stati modificati i dati sul foglio per il Caricamento Lotti proseguendo senza effettuare un salvataggio i dati modificati verranno persi, si desidera proseguire?')) )
				apri = 'SI';
			else
				apri = 'NO';
			*/
			ML_text = 'Attenzione sono stati modificati i dati sul foglio per il Caricamento Lotti proseguendo senza effettuare un salvataggio i dati modificati verranno persi, si desidera proseguire?';
			Title = 'Informazione';
			ICO = 1;
			page = 'ctl_library/MessageBoxWin.asp?MODALE=YES&ML=YES&MSG=' + encodeURIComponent(ML_text) + '&CAPTION=' + encodeURIComponent(Title) + '&ICO=' + encodeURIComponent(ICO);

			ExecFunctionModaleConfirm(page, Title, 200, 420, null, 'APRI_OK2@@@@' + Row, '');
			return;
		}

		if (apri == 'SI') {
			//aggiorno il doc in mem 
			UpdateDocInMem(getObj('IDDOC').value, getObj('TYPEDOC').value);

			var cod = getObj('RLISTA_BUSTEGrid_' + Row + '_id').value;
			ShowDocumentPath('OFFERTA_BUSTA_TEC', cod, '../');
		}
	}
	else {
		AF_Alert('Prima di procedere e\' necessario risolvere le anomalie presenti sui prodotti del lotto');
	}

}
function APRI_OK2(Row) {
	//aggiorno il doc in mem 
	UpdateDocInMem(getObj('IDDOC').value, getObj('TYPEDOC').value);
	var cod = getObj('RLISTA_BUSTEGrid_' + Row + '_id').value;
	ShowDocumentPath('OFFERTA_BUSTA_TEC', cod, '../');
}
function DownloadZipBuste() {

	//permetto apertura della tecnica per generare pdf solo se ho composto RTI in modo corretto
	var bret = false;
	var GENERA_CON_WARNIG = 'NO';
	var bret = CanSendRTI();

	if (!bret) {
		DocShowFolder('FLD_BUSTA_DOCUMENTAZIONE');
		tdoc();
		return;
	}


	//se ho fatto modifiche alla RTI e non ho salvato avviso
	if (getObj('DenominazioneATI_DB').value != getObj('DenominazioneATI').value) {
		/*		
			if ( confirm( CNV('../../', 'Sono stati modificati i dati della RTI.Per procedere si richiede prima un salvataggio.') ) ){
					SaveDoc('');
					return ;
			}else
				return ;
		*/
		ML_text = 'Sono stati modificati i dati della RTI.Per procedere si richiede prima un salvataggio.';
		Title = 'Informazione';
		ICO = 1;
		page = 'ctl_library/MessageBoxWin.asp?MODALE=YES&ML=YES&MSG=' + encodeURIComponent(ML_text) + '&CAPTION=' + encodeURIComponent(Title) + '&ICO=' + encodeURIComponent(ICO);

		ExecFunctionModaleConfirm(page, Title, 200, 420, null, 'SaveDoc', '');
		return;

	}


	var IDDOC = getObjValue('IDDOC');

	var tmpVirtualDir;
	tmpVirtualDir = '/Application';

	if (isSingleWin())
		tmpVirtualDir = urlPortale;

	//controllo se numero lotti offerta non � superiore a quello ammesso
	var Num_max_lotti_offerti;
	var numero_lotti_off;

	Num_max_lotti_offerti = Number(getObj('Num_max_lotti_offerti').value);
	numero_lotti_off = Number(GetProperty(getObj('LISTA_BUSTEGrid'), 'numrow')) + 1;

	if (numero_lotti_off > Num_max_lotti_offerti && Num_max_lotti_offerti > 0 && grigliaProdottiVariata != 'YES') {
		//DMessageBox( '../' , 'Il numero dei lotti a cui si sta partecipando e superiore rispetto al numero massimo previsto nel bando' , 'Attenzione' , 1 , 400 , 300 );
		//return;		
		if (conf_num_max_lot_sup != 'YES') {
			var ML_text = 'Il numero dei lotti a cui si sta partecipando e superiore rispetto al numero massimo previsto nel bando. Vuoi proseguire nella generazione delle buste?';
			var Title = 'Informazione';
			var ICO = 1;
			var page = 'ctl_library/MessageBoxWin.asp?MODALE=YES&ML=YES&MSG=' + encodeURIComponent(ML_text) + '&CAPTION=' + encodeURIComponent(Title) + '&ICO=' + encodeURIComponent(ICO);

			var ret_value = ExecFunctionModaleConfirm(page, Title, 200, 420, null, 'conferma_numero_max_lotti_superiore', '');
			return;
		}
	}


	//Se i prodotti hanno subito una modifica (senza salvataggio) passo ad effettuare la verifica informazioni. Al ricarico del documento apro il 3clickSign
	if (grigliaProdottiVariata == 'NO') {
		//aggiorno il doc in mem 
		UpdateDocInMem(getObj('IDDOC').value, getObj('TYPEDOC').value);
		ExecFunctionCenter(tmpVirtualDir + '/CTL_LIBRARY/pdf/genera_buste.asp?ID_OFFERTA=' + IDDOC + '#DownloadZip#480,360');
	}
	else
		ExecDocProcess('VERIFICA_AND_3CLICK,OFFERTA,,NO_MSG');

}
function conferma_numero_max_lotti_superiore() {
	//aggiorno il doc in mem 
	UpdateDocInMem(getObj('IDDOC').value, getObj('TYPEDOC').value);
	conf_num_max_lot_sup = 'YES';
	DownloadZipBuste();
}

function UploadBusteFirmate() {

	//se documento non editabile non faccio i controlli
	if (getObjValue('DOCUMENT_READONLY') != '0') {
		LocDMessageBox('../', 'Operazione non consentita per lo stato del documento', 'Attenzione', 1, 400, 300);
		return;
	}

	ShowWorkInProgress();
	var IDDOC = getObjValue('IDDOC');

	var tmpVirtualDir;
	tmpVirtualDir = '/Application';

	if (isSingleWin())
		tmpVirtualDir = urlPortale;

	var jumpCheck;
	var AttivaFilePending = getObj('AttivaFilePending');

	jumpCheck = '&JUMP_CHECK=NO';

	/* SE IL CAMPO ESISTE */
	if (AttivaFilePending) {
		//Se richiesta la verifica pending dei file
		if (AttivaFilePending.value == 'si') {
			jumpCheck = '&JUMP_CHECK=YES';
		}
	}

	var ControlloOnlyHash;
	var ControlloFirmaBuste = getObj('ControlloFirmaBuste');

	ControlloOnlyHash = '&ControlloOnlyHash=NO';

	/* SE IL CAMPO ESISTE */
	if (ControlloFirmaBuste) {
		//Se richiesta la verifica solo per la bont� hash
		if (ControlloFirmaBuste.value == 'no') {
			ControlloOnlyHash = '&ControlloOnlyHash=YES';
		}
	}


	ExecFunctionCenter(tmpVirtualDir + '/ctl_Library/functions/FIELD/UploadAttach.asp?PAGE=../../pdf/importaBusteFirmate.asp&ID_OFFERTA=' + IDDOC + jumpCheck + ControlloOnlyHash + '#UploadZip#480,360');

}



//nasconde le griglie secondo i campi settati si/no per le RTI
function HideShowAreeRTI() {


	//alert('HideShowAreeRTI');	
	try {
		//se settata RTI disabilito la possibilit� di cancellare la prima riga
		if (getObj('PartecipaFormaRTI').value == '1') {
			//visualizzo help RTI			
			try { $("#cap_label1").parents("table:first").css({ "display": "block" }); } catch (e) { }
			try { $("#cap_label1").parents("table:first").css({ "max-width": "20px" }); } catch (e) { }

			try {
				getObj('RTIGRIDGrid_r0_c1').onclick = '';
				try {
					getObjGrid('RRTIGRIDGrid_0_FNZ_DEL').style.display = 'none';
					TextreadOnly('RRTIGRIDGrid_0_codicefiscale', true);
				} catch (e) { }
			} catch (e) { }

			try { getObj('div_RTIGRIDGrid').style.display = ''; } catch (e) { }
			try { getObj('RTIGRID').style.display = ''; } catch (e) { }
		}
		else {

			//nascondo help RTI
			try { $("#cap_label1").parents("table:first").css({ "display": "none" }); } catch (e) { }

			//nascondo area relativa
			try { getObj('div_RTIGRIDGrid').style.display = 'none'; } catch (e) { }
			try { getObj('RTIGRID').style.display = 'none'; } catch (e) { }
			try {
				getObj('OFFERTA_PARTECIPANTI_RTI_TOOLBAR_ADDNEW').style.display = 'none';
			} catch (e) { }
		}
	} catch (e) { }

	//SE la configurazione di sistema prevede le subappaltatrici SYS_OFFERTA_PRESENZA_ESECUTRICI ( YES/NO) default NO
	try {
		if (getObjValue('SYS_OFFERTA_PRESENZA_ESECUTRICI') == 'NO') {
			try { getObj('ESECUTRICI').style.display = 'none'; } catch (e) { }
			try { getObj('ESECUTRICIGRID').style.display = 'none'; } catch (e) { }
			try { getObj('div_ESECUTRICIGRIDGrid').style.display = 'none'; } catch (e) { }
			try { getObj('OFFERTA_PARTECIPANTI_ESECUTRICI_TOOLBAR_ADDFROM').style.display = 'none'; } catch (e) { }
		}
		else {
			//se non settata CONSORZIO nascondo area relativa

			if (getObj('InserisciEsecutriciLavori') && getObj('InserisciEsecutriciLavori').value == '1') {

				//visualizzo help
				try { $("#cap_label2").parents("table:first").css({ "display": "block" }); } catch (e) { }
				try { $("#cap_label2").parents("table:first").css({ "width": "20px" }); } catch (e) { }
				getObj('div_ESECUTRICIGRIDGrid').style.display = '';
				getObj('ESECUTRICIGRID').style.display = '';
				getObj('ESECUTRICI').style.display = '';
				try {
					getObj('OFFERTA_PARTECIPANTI_ESECUTRICI_TOOLBAR_ADDFROM').style.display = '';
				} catch (e) { }

			}
			else {

				if (getObj('div_ESECUTRICIGRIDGrid')) {

					//nascondo help
					try { $("#cap_label2").parents("table:first").css({ "display": "none" }); } catch (e) { }
					//nascondo area relativa
					//try{getObj('ESECUTRICI').style.display = 'none';}catch (e) {}	
					try { getObj('ESECUTRICIGRID').style.display = 'none'; } catch (e) { }
					try { getObj('div_ESECUTRICIGRIDGrid').style.display = 'none'; } catch (e) { }

					try {
						getObj('OFFERTA_PARTECIPANTI_ESECUTRICI_TOOLBAR_ADDFROM').style.display = 'none';
					} catch (e) { }

				}

			}
		}
	} catch (e) { }


	//gestione AVVALIMENTO 
	if (getObj('RicorriAvvalimento') && getObj('RicorriAvvalimento').value == '1') {
		//visualizzo help
		try { $("#cap_label3").parents("table:first").css({ "display": "block" }); } catch (e) { }
		try { $("#cap_label3").parents("table:first").css({ "width": "20px" }); } catch (e) { }
		getObj('div_AUSILIARIEGRIDGrid').style.display = '';
		getObj('AUSILIARIEGRID').style.display = '';
		try {
			getObj('OFFERTA_PARTECIPANTI_AUSILIARIE_TOOLBAR_ADDFROM').style.display = '';
		} catch (e) { }

	}
	else {
		//nascondo help
		try { $("#cap_label3").parents("table:first").css({ "display": "none" }); } catch (e) { }
		//nascondo area relativa
		try { getObj('div_AUSILIARIEGRIDGrid').style.display = 'none'; } catch (e) { }
		try { getObj('AUSILIARIEGRID').style.display = 'none'; } catch (e) { }
		try {
			getObj('OFFERTA_PARTECIPANTI_AUSILIARIE_TOOLBAR_ADDFROM').style.display = 'none';
		} catch (e) { }
	}

	//gestione SUBAPPALTO 
	if (getObj('Richiesta_terna_subappalto') && getObj('Richiesta_terna_subappalto').value == '1') {
		//visualizzo help
		try { $("#cap_label4").parents("table:first").css({ "display": "block" }); } catch (e) { }
		try { $("#cap_label4").parents("table:first").css({ "width": "20px" }); } catch (e) { }
		getObj('div_SUBAPPALTOGRIDGrid').style.display = '';
		getObj('SUBAPPALTOGRID').style.display = '';
		try {
			getObj('OFFERTA_PARTECIPANTI_SUBAPPALTO_TOOLBAR_ADDFROM').style.display = '';
		} catch (e) { }

	}
	else {
		//nascondo help
		try { $("#cap_label4").parents("table:first").css({ "display": "none" }); } catch (e) { }
		//nascondo area relativa
		try { getObj('div_SUBAPPALTOGRIDGrid').style.display = 'none'; } catch (e) { }
		try { getObj('SUBAPPALTOGRID').style.display = 'none'; } catch (e) { }

	}

	try {

		//setto onchange sulla colonna codice fiscale
		SetOnChangeOnCodiceFiscale('RTIGRIDGrid');
		SetOnChangeOnCodiceFiscale('AUSILIARIEGRIDGrid');
		SetOnChangeOnCodiceFiscale('ESECUTRICIGRIDGrid');
		SetOnChangeOnCodiceFiscale('SUBAPPALTOGRIDGrid');

	} catch (e) { }
	if (getObj('DOCUMENT_READONLY').value == "1") {
		try { $("#cap_label1").parents("table:first").css({ "display": "none" }); } catch (e) { }
		try { $("#cap_label2").parents("table:first").css({ "display": "none" }); } catch (e) { }
		try { $("#cap_label3").parents("table:first").css({ "display": "none" }); } catch (e) { }
		try { $("#cap_label4").parents("table:first").css({ "display": "none" }); } catch (e) { }
	}

}


//cancella tutte le righe di una griglia
function MyDelete_RTIGrid(grid, obj) {

	if (obj.value == '0') {

		ML_text = 'Sei sicuro di cancellare ' + grid
		Title = 'Informazione';
		ICO = 1;
		page = 'ctl_library/MessageBoxWin.asp?MODALE=YES&ML=YES&MSG=' + encodeURIComponent(ML_text) + '&CAPTION=' + encodeURIComponent(Title) + '&ICO=' + encodeURIComponent(ICO);

		ExecFunctionModaleConfirm(page, Title, 200, 420, null, 'MyDelete_RTIGrid_OK@@@@' + grid, 'MyDelete_RTIGrid_CANCEL@@@@' + obj.id);



		/*
	   if (confirm(CNV('../../', 'Sei sicuro di cancellare ' + grid)) == true) 
		{

			var sec = getObj(grid + '_SECTION_DETTAGLI_NAME').value;
			if( grid != 'SUBAPPALTOGRIDGrid' )
				ExecDocCommand(sec + '#DELETE_ALL#');
			
			else{
				Reset_SUBAPPALTOGRID();
			}	
			//ShowLoading( sec );

		} 
		else
			obj.value = '1';
		*/
	}
	else {

		//se sono sulla griglia RTI � vuota allora inserisco in automatico prima riga con azienda loggata
		if (grid == 'RTIGRIDGrid' && obj.value == '1') {

			//recupero azienda fornitore che ha fatto il documento
			var Azienda = getObj('Azienda').value;

			var sec = getObj(grid + '_SECTION_DETTAGLI_NAME').value;

			var Param = 'IDROW=' + Azienda + '&TABLEFROMADD=Seleziona_Fornitore_RTI';

			ExecDocCommand(sec + '#ADDFROM#' + Param);

			//ShowLoading( sec );

		}

		pros_MyDelete_RTIGrid();

	}
}
function pros_MyDelete_RTIGrid() {
	//-- controlli su associazione RTI
	try {
		if (getObj('PartecipaFormaRTI').value == '1') {
			document.getElementById('Associazione_RTI').style.display = "";
			document.getElementById('cap_Associazione_RTI').style.display = "";
		}
		else {
			document.getElementById('Associazione_RTI').style.display = "none";
			document.getElementById('cap_Associazione_RTI').style.display = "none";
		}

	}
	catch (e) {
	}


	HideShowAreeRTI();


}

function MyDelete_RTIGrid_OK(grid) {

	var sec = getObj(grid + '_SECTION_DETTAGLI_NAME').value;
	if (grid != 'SUBAPPALTOGRIDGrid')
		ExecDocCommand(sec + '#DELETE_ALL#');

	else {
		Reset_SUBAPPALTOGRID();
	}

	pros_MyDelete_RTIGrid();

}
function MyDelete_RTIGrid_CANCEL(param) {

	getObj(param).value = '1';
	pros_MyDelete_RTIGrid();
}

//viene eseguita dopo i comandio sulla griglia RTI
function RTIGRID_AFTER_COMMAND(command) {


	//alert(command);
	if (command == 'DELETE_ALL') {

		//se ho cancellato la griglia nascondo area relativa
		getObj('div_RTIGRIDGrid').style.display = 'none';
		getObj('OFFERTA_PARTECIPANTI_RTI_TOOLBAR_ADDNEW').style.display = 'none';

	} else {

		getObj('div_RTIGRIDGrid').style.display = '';
		getObj('OFFERTA_PARTECIPANTI_RTI_TOOLBAR_ADDNEW').style.display = '';

	}


	var NumRowRti = GetProperty(getObj('RTIGRIDGrid'), 'numrow');

	if (NumRowRti != -1) {
		//alert( GetProperty ( getObjGrid('val_RRTIGRIDGrid_0_Ruolo_Impresa'), 'value'));
		//se � la prima riga
		if (GetProperty(getObjGrid('val_RRTIGRIDGrid_0_Ruolo_Impresa'), 'value') == '') {

			//alert('setto la mandataria');
			//setto il ruolo a mandataria
			SetProperty(getObjGrid('val_RRTIGRIDGrid_0_Ruolo_Impresa'), 'value', 'Mandataria');
			getObjGrid('val_RRTIGRIDGrid_0_Ruolo_Impresa').innerHTML = 'Mandataria';
			getObjGrid('RRTIGRIDGrid_0_Ruolo_Impresa').value = 'Mandataria';
		}



		//nascondo il cestino prima riga
		getObjGrid('RRTIGRIDGrid_0_FNZ_DEL').style.display = 'none';
		//disabilito onclick sul cestino prima riga
		getObj('RTIGRIDGrid_r0_c1').onclick = '';
		//disabilito onchange su codice fiscale prima riga
		getObjGrid('RRTIGRIDGrid_0_codicefiscale').onchange = '';
		TextreadOnly('RRTIGRIDGrid_0_codicefiscale', true);


		for (nIndRrow = 1; nIndRrow <= NumRowRti; nIndRrow++) {

			SetProperty(getObjGrid('val_RRTIGRIDGrid_' + nIndRrow + '_Ruolo_Impresa'), 'value', 'Mandante');
			getObjGrid('val_RRTIGRIDGrid_' + nIndRrow + '_Ruolo_Impresa').innerHTML = 'Mandante';

		}
	}

	//setto onkeyup
	SetOnChangeOnCodiceFiscale('RTIGRIDGrid');

	//aggiorno il campo denominazioneATI
	UpgradeDenominazioneRTI();

	//funzione per gestire le colonne dgue
	Show_Hide_dgue_COL();
}



//SETTO EVENTO ON CHANGE SULLA COLONNA CODICE FISCALE DELLE GRIGLIE RTI
function SetOnChangeOnCodiceFiscale(strFullNameArea) {

	var nNumRow = GetProperty(getObj(strFullNameArea), 'numrow');
	var nIndRrow;
	for (nIndRrow = 0; nIndRrow <= nNumRow; nIndRrow++) {

		if (nIndRrow == 0 && strFullNameArea == 'RTIGRIDGrid') {

			//disabilito onkeyup su codice fiscale
			getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_codicefiscale').onkeyup = '';

		} else {
			getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_codicefiscale').onkeyup = GetInfoAziendaFromCF;
			//getObjGrid( 'R' + strFullNameArea + '_' + nIndRrow + '_codicefiscale').onblur = MakeAlertAzienda ;
		}

	}

}




//ricostruisce il campo denominazione
function UpgradeDenominazioneRTI() {

	//se doc non editabile non faccio nulla
	if (getObjValue('DOCUMENT_READONLY') != '0')
		return;

	var strTempValue;
	//aggiorno campo nascosto con la denominazione
	var objDenominazioneATI = getObj('DenominazioneATI');
	objDenominazioneATI.value = '';

	var nIndRrow;
	var strFullNameArea;
	var nNumRow;


	//controllo se partecipacomeRTI � settato
	if (getObj('PartecipaFormaRTI').value == '1') {

		strFullNameArea = 'RTIGRIDGrid';
		nNumRow = -1;

		try {
			nNumRow = Number(GetProperty(getObj(strFullNameArea), 'numrow'));
		}
		catch (e) {
		}

		if (nNumRow >= 0 && getObjGrid('R' + strFullNameArea + '_0_RagSoc').value != '') {

			objDenominazioneATI.value = 'RTI ';

			for (nIndRrow = 0; nIndRrow <= nNumRow; nIndRrow++) {

				strTempValue = getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_RagSoc').value;

				if (strTempValue != '') {
					if (nIndRrow == 0)
						objDenominazioneATI.value = objDenominazioneATI.value + strTempValue;
					else
						objDenominazioneATI.value = objDenominazioneATI.value + ' - ' + strTempValue;
				}

			}
		}
	}




	//controllo se InserisciEsecutriciLavori � settato
	if (getObj('InserisciEsecutriciLavori') && getObj('InserisciEsecutriciLavori').value == '1') {

		strFullNameArea = 'ESECUTRICIGRIDGrid';

		nNumRow = 0

		try {
			nNumRow = Number(GetProperty(getObj(strFullNameArea), 'numrow'));
		} catch (e) { }

		if (nNumRow >= 0 && getObjGrid('R' + strFullNameArea + '_0_RagSoc').value != '') {

			objDenominazioneATI.value = objDenominazioneATI.value + ' Esecutrice ';

			for (nIndRrow = 0; nIndRrow <= nNumRow; nIndRrow++) {

				strTempValue = getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_RagSoc').value;

				if (strTempValue != '') {
					if (nIndRrow == 0)
						objDenominazioneATI.value = objDenominazioneATI.value + strTempValue;
					else
						objDenominazioneATI.value = objDenominazioneATI.value + ' - ' + strTempValue;
				}

			}

			//se non � settata RTI aggiungo all'inizio la ragsoc del consorzio
			if (getObj('PartecipaFormaRTI').value != '1') {
				objDenominazioneATI.value = getObjGrid('R' + strFullNameArea + '_0_RagSocRiferimento').value + ' ' + objDenominazioneATI.value;
			}

		}
	}


	//se il campo DenominazioneATI � vuoto setto la ragione sociale del fornitore che ha fatto l'offerta

	if (objDenominazioneATI.value == '') {

		ajax = GetXMLHttpRequest();

		if (ajax) {

			ajax.open("GET", '../../ctl_library/functions/InfoAziFromCF.asp?IdAzi=' + getObj('Azienda').value, false);

			ajax.send(null);

			if (ajax.readyState == 4) {

				if (ajax.status == 200) {
					if (ajax.responseText != '') {

						//alert(ajax.responseText);
						var strTempValue = ajax.responseText;
						var ainfo = strTempValue.split('#');
						objDenominazioneATI.value = ainfo[0];

					}
				}
			}

		}


	}


	//aggiorno il campo visuale
	getObj('DenominazioneATI_V').innerHTML = objDenominazioneATI.value;

	//se il campo tecnico di confronto � vuoto inizializzo anche quello con lo stesso valore
	if (getObj('DenominazioneATI_DB').value == '')
		getObj('DenominazioneATI_DB').value = objDenominazioneATI.value;


}




//per eseguire aggiungi esecutrici e aggiungi ausiliarie
function My_Detail_AddFrom(param) {

	//recupero le aziende della griglia RTI
	var strIdaziRTI = GetAziRTI();
	//alert(strIdaziRTI);

	var strIdAziEsecutrici = GetEsecutriciConsorzio();
	//alert(strIdAziEsecutrici);
	if (strIdAziEsecutrici != '')
		strIdaziRTI = strIdaziRTI + ',' + strIdAziEsecutrici;

	var npos = strIdaziRTI.indexOf(',');

	if (npos == -1) {

		//aggiungo direttamente l'azienda loggata

		//recupero azienda fornitore che ha fatto il documento
		var Azienda = getObj('Azienda').value;
		var strDoc = getQSParamFromString(param, 'DOCUMENT');
		v = strDoc.split('.');

		//-- compone il comando per aggiungere la riga
		strCommand = v[0] + '#' + v[1] + '#' + 'IDROW=' + Azienda + '&TABLEFROMADD=' + v[2];
		ExecDocCommand(strCommand);

		//ShowLoading( sec );

	} else {

		vet = param.split('#');

		var w;
		var h;
		var Left;
		var Top;
		var altro;

		if (vet.length < 3) {
			w = screen.availWidth;
			h = screen.availHeight;
			Left = 0;
			Top = 0;
		} else {
			var d;
			d = vet[2].split(',');
			w = d[0];
			h = d[1];
			Left = (screen.availWidth - w) / 2;
			Top = (screen.availHeight - h) / 2;

			if (vet.length > 3) {
				altro = vet[3];
			}
		}

		var strUrl = vet[0];

		strUrl = strUrl + '&FilterHide= id in (' + strIdaziRTI + ')';

		return window.open(strUrl, vet[1], 'toolbar=no,location=no,directories=no,status=no,menubar=no,resizable=yes,copyhistory=yes,scrollbars=yes,left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h + altro);
	}
}



//recupera la lista delle aziende della griglia RTI
function GetAziRTI() {

	var strTempList = '';
	var strTempValue = '';

	var nIndRrow;

	var nNumRow = GetProperty(getObj('RTIGRIDGrid'), 'numrow');

	//alert(nNumRow)
	if (nNumRow >= 0) {

		for (nIndRrow = 0; nIndRrow <= nNumRow; nIndRrow++) {

			strTempValue = getObjGrid('RRTIGRIDGrid_' + nIndRrow + '_IdAzi').value;
			if (strTempValue != '') {
				if (strTempList == '')
					strTempList = strTempValue;
				else
					strTempList = strTempList + ',' + strTempValue;
			}
		}
	} else {

		//recupero idazi azienda loggata
		strTempList = getObj('Azienda').value;
	}

	return strTempList;

}



//recupera la lista delle aziende esecutrici nei CONSORZI
function GetEsecutriciConsorzio() {

	var strTempList = '';
	var strTempValue = '';

	var nIndRrow;

	var nNumRow = -1;

	try {
		nNumRow = GetProperty(getObj('ESECUTRICIGRIDGrid'), 'numrow');
	}
	catch (e) {
	}

	if (nNumRow >= 0) {

		for (nIndRrow = 0; nIndRrow <= nNumRow; nIndRrow++) {
			strTempValue = getObjGrid('RESECUTRICIGRIDGrid_' + nIndRrow + '_IdAzi').value;
			if (strTempValue != '') {
				if (strTempList == '')
					strTempList = strTempValue;
				else
					strTempList = strTempList + ',' + strTempValue;
			}
		}
	} else {

		//recupero idazi azienda loggata
		strTempList = getObj('Azienda').value;
	}

	return strTempList;


}




//a partire dal codice fiscale ritorna le info di azienda
function GetInfoAziendaFromCF() {


	var IDDOC = getObjValue('IDDOC');
	//RRTIGRIDGrid_0_codicefiscale
	var strNameCtl = this.name;
	//alert(strNameCtl);
	var aInfo = strNameCtl.split('_');


	var nIndRrow = aInfo[1];

	var strCF = this.value;

	var Grid = aInfo[0].substr(1, aInfo[0].length);

	var bIsUnique_blocco = false;



	var ValoreListaAlbi = '';

	//tranne che per le aziende avvalimento considero ListaAlbi
	if (Grid != 'AUSILIARIEGRIDGrid' && Grid != 'SUBAPPALTOGRIDGrid') {
		try {
			ValoreListaAlbi = getObj('ListaAlbi').value;
		} catch (e) { }
	}


	if (strCF.length >= 7) {

		//if  ( bIsUnique ){

		//provo a ricercare le info azienda
		ajax = GetXMLHttpRequest();

		if (ajax) {
			ajax.open("GET", '../../ctl_library/functions/InfoAziFromCF.asp?ListaAlbi=' + encodeURIComponent(ValoreListaAlbi) + '&AZIPROFILO=S&CodiceFiscale=' + encodeURIComponent(strCF) + '&IDDOC=' + IDDOC + '&Grid=' + encodeURIComponent(Grid), false);

			ajax.send(null);

			if (ajax.readyState == 4) {
				//alert(ajax.status);
				if (ajax.status == 200) {
					//alert(ajax.responseText);
					if (ajax.responseText != '' && ajax.responseText.indexOf('#', 0) > 0) {

						//alert(ajax.responseText);    
						this.style.color = 'black';
						var strresult = ajax.responseText;

						//blocco se cf gia presente in griglia RTI
						if (Grid == 'SUBAPPALTOGRIDGrid')
							bIsUnique_blocco = AziIsUnique_blocco(Grid, nIndRrow, strCF);

						if (bIsUnique_blocco != true) {
							SetInfoAziendaRow(Grid, nIndRrow, strresult);

							//faccio alert se azienda presente in altra griglia
							var bIsUnique = AziIsUnique(Grid, nIndRrow, strCF);
						}


					}
					else {

						if (ajax.responseText != '')
							LocDMessageBox('../', ajax.responseText, 'Attenzione', 1, 400, 300);

						//setto i caratteri in rosso
						this.style.color = 'red';

						//svuoto i campi
						SetInfoAziendaRow(Grid, nIndRrow, '#######');


					}
				}
			}

		}
		//}else{

		//svuoto il campo del CF che non � univoco
		//  this.value='';
		//  SetInfoAziendaRow( Grid , nIndRrow ,'#####' );
		//}
	} else {
		//setto i caratteri in rosso
		this.style.color = 'red';

		//svuoto i campi
		SetInfoAziendaRow(Grid, nIndRrow, '#######');
	}

	//aggiorno campo denominazione
	UpgradeDenominazioneRTI();
}




//controlla che questo codice fiscale non sia gi� presente
function AziIsUnique(strNameAreaCurrent, nRowCurrent, strCF) {

	var bIsUnique = true;

	//griglia RTI
	var nIndRrow;
	var strFullNameArea = 'RTIGRIDGrid';

	var nNumRow = -1;

	try {
		nNumRow = Number(GetProperty(getObj(strFullNameArea), 'numrow'));
	}
	catch (e) {
	}

	for (nIndRrow = 0; nIndRrow <= nNumRow; nIndRrow++) {

		if (strFullNameArea != strNameAreaCurrent || (strFullNameArea == strNameAreaCurrent && Number(nIndRrow) != Number(nRowCurrent))) {

			if (getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_codicefiscale').value.toUpperCase() == strCF.toUpperCase()) {
				//alert( CNV ('../../' , 'azienda gia inserita nella griglia RTI') );
				LocDMessageBox('../', 'azienda gia inserita nella griglia RTI', 'Attenzione', 1, 400, 300);
				bIsUnique = false;
				return bIsUnique;

			}
		}
	}



	//griglia Consorzio
	strFullNameArea = 'ESECUTRICIGRIDGrid';
	nNumRow = -1;

	try {
		nNumRow = Number(GetProperty(getObj(strFullNameArea), 'numrow'));
	}
	catch (e) {
	}

	for (nIndRrow = 0; nIndRrow <= nNumRow; nIndRrow++) {

		if (strFullNameArea != strNameAreaCurrent || (strFullNameArea == strNameAreaCurrent && Number(nIndRrow) != Number(nRowCurrent))) {

			if (getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_codicefiscale').value.toUpperCase() == strCF.toUpperCase()) {
				//alert( CNV ('../../' , 'azienda gia inserita nella griglia Consorzio') );
				LocDMessageBox('../', 'azienda gia inserita nella griglia Consorzio', 'Attenzione', 1, 400, 300);
				bIsUnique = false;
				return bIsUnique;
			}
		}
	}


	//griglia Avvalimento
	strFullNameArea = 'AUSILIARIEGRIDGrid';
	nNumRow = -1;

	try {
		nNumRow = Number(GetProperty(getObj(strFullNameArea), 'numrow'));
	}
	catch (e) {
	}

	for (nIndRrow = 0; nIndRrow <= nNumRow; nIndRrow++) {

		if (strFullNameArea != strNameAreaCurrent || (strFullNameArea == strNameAreaCurrent && Number(nIndRrow) != Number(nRowCurrent))) {

			if (getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_codicefiscale').value.toUpperCase() == strCF.toUpperCase()) {
				//alert( CNV ('../../' , 'azienda gia inserita nella griglia Avvalimento') );
				LocDMessageBox('../', 'azienda gia inserita nella griglia Avvalimento', 'Attenzione', 1, 400, 300);
				bIsUnique = false;
				return bIsUnique;
			}
		}
	}

	//griglia SUBAPPALTO codice fiscale univoco per appaltatore
	strFullNameArea = 'SUBAPPALTOGRIDGrid';
	nNumRow = -1;

	try {
		nNumRow = Number(GetProperty(getObj(strFullNameArea), 'numrow'));
	}
	catch (e) {
	}
	//alert (IdAziRiferimento);
	for (nIndRrow = 0; nIndRrow <= nNumRow; nIndRrow++) {
		if (strFullNameArea != strNameAreaCurrent || (strFullNameArea == strNameAreaCurrent && Number(nIndRrow) != Number(nRowCurrent))) {

			if (getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_codicefiscale').value.toUpperCase() == strCF.toUpperCase()) {
				//alert( CNV ('../../' , 'azienda gia inserita nella griglia Avvalimento') );
				LocDMessageBox('../', 'Azienda gia inserita nella griglia Subappalto', 'Attenzione', 1, 400, 300);
				bIsUnique = false;
				return bIsUnique;
			}
		}
	}



	return bIsUnique;

}



//controlla che questo codice fiscale non sia gi� presente
function AziIsUnique_blocco(strNameAreaCurrent, nRowCurrent, strCF) {

	var bIsUnique_blocco = false;

	//griglia RTI
	var nIndRrow;
	var strFullNameArea = 'RTIGRIDGrid';

	var nNumRow = -1;

	try {
		nNumRow = Number(GetProperty(getObj(strFullNameArea), 'numrow'));
	}
	catch (e) {
	}

	for (nIndRrow = 0; nIndRrow <= nNumRow; nIndRrow++) {

		if (strFullNameArea != strNameAreaCurrent || (strFullNameArea == strNameAreaCurrent && Number(nIndRrow) != Number(nRowCurrent))) {

			if (getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_codicefiscale').value.toUpperCase() == strCF.toUpperCase()) {
				//alert( CNV ('../../' , 'azienda gia inserita nella griglia RTI') );
				LocDMessageBox('../', 'Azienda gia inserita nella griglia RTI, non puo essere inserita in Subappalto', 'Attenzione', 1, 400, 300);
				bIsUnique_blocco = true;
				break;
				return bIsUnique_blocco;
			}
		}
	}

	//griglia Consorzio
	strFullNameArea = 'ESECUTRICIGRIDGrid';
	nNumRow = -1;

	try {
		nNumRow = Number(GetProperty(getObj(strFullNameArea), 'numrow'));
	}
	catch (e) {
	}

	for (nIndRrow = 0; nIndRrow <= nNumRow; nIndRrow++) {

		if (strFullNameArea != strNameAreaCurrent || (strFullNameArea == strNameAreaCurrent && Number(nIndRrow) != Number(nRowCurrent))) {

			if (getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_codicefiscale').value.toUpperCase() == strCF.toUpperCase()) {
				//alert( CNV ('../../' , 'azienda gia inserita nella griglia Consorzio') );
				LocDMessageBox('../', 'azienda gia inserita nella griglia Consorzio', 'Attenzione', 1, 400, 300);
				bIsUnique_blocco = true;
				break;
				return bIsUnique_blocco;
			}
		}
	}


	//griglia Avvalimento
	strFullNameArea = 'AUSILIARIEGRIDGrid';
	nNumRow = -1;

	try {
		nNumRow = Number(GetProperty(getObj(strFullNameArea), 'numrow'));
	}
	catch (e) {
	}

	for (nIndRrow = 0; nIndRrow <= nNumRow; nIndRrow++) {

		if (strFullNameArea != strNameAreaCurrent || (strFullNameArea == strNameAreaCurrent && Number(nIndRrow) != Number(nRowCurrent))) {

			if (getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_codicefiscale').value.toUpperCase() == strCF.toUpperCase()) {
				//alert( CNV ('../../' , 'azienda gia inserita nella griglia Avvalimento') );
				LocDMessageBox('../', 'azienda gia inserita nella griglia Avvalimento', 'Attenzione', 1, 400, 300);
				bIsUnique_blocco = true;
				break;
				return bIsUnique_blocco;
			}
		}
	}





	return bIsUnique_blocco;

}



//setta le info di una azienda su una riga di una griglia
function SetInfoAziendaRow(strFullNameArea, nIndRrow, strresult) {


	var nPos;
	var ainfoAzi = strresult.split('#');

	var strRagSoc = ainfoAzi[0];

	getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_RagSoc').value = strRagSoc;
	getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_RagSoc_V').innerHTML = strRagSoc;


	/*
	if (strFullNameArea == 'DOCUMENTAZIONE_ATIgriglia' && nIndRrow==0){
	  var strCodicefiscale = ainfoAzi[4];
	  getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_codicefiscale').value=strCodicefiscale;
	}*/

	var strIndLeg = ainfoAzi[1];
	getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_INDIRIZZOLEG').value = strIndLeg;
	getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_INDIRIZZOLEG_V').innerHTML = strIndLeg;

	var strLocLeg = ainfoAzi[2];
	getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_LOCALITALEG').value = strLocLeg;
	getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_LOCALITALEG_V').innerHTML = strLocLeg;


	var strProvLeg = ainfoAzi[3];
	getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_PROVINCIALEG').value = strProvLeg;
	getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_PROVINCIALEG_V').innerHTML = strProvLeg;



	var strIdazi = ainfoAzi[5];
	getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_IdAzi').value = strIdazi;


	var strRuolo = 'Mandataria';
	var strTechRuolo = 'Mandataria';
	if (nIndRrow != 0) {
		strRuolo = 'Mandante';
		strTechRuolo = 'Mandante';
	}

	try {
		//SetProperty(getObjGrid('val_R' + strFullNameArea + '_' + nIndRrow + '_Ruolo_Impresa'),'value',strTechRuolo);

		getObjGrid('val_R' + strFullNameArea + '_' + nIndRrow + '_Ruolo_Impresa').innerHTML = strRuolo;
		getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_Ruolo_Impresa').value = strTechRuolo;

	} catch (e) { }

	var IdDocRicDGUE = ainfoAzi[6];
	try {
		try { getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_IdDocRicDGUE').value = IdDocRicDGUE; } catch (e) { }
		//getObjGrid('val_R' + strFullNameArea + '_' + nIndRrow + '_IdDocRicDGUE').value = IdDocRicDGUE;		
	} catch (e) { }


	var StatoRichiesta = ainfoAzi[7];
	try {


		if (StatoRichiesta == 'Ricevuto') {
			try { SetDomValue('R' + strFullNameArea + '_' + nIndRrow + '_StatoDGUE', 'InviataRichiesta', 'InviataRichiesta'); } catch (e) { }

			ExecDocProcess('RECUPERO_DOCUMENTI_RICHIESTI,DOCUMENTO,,NO_MSG');
		}
		else {
			try { SetDomValue('R' + strFullNameArea + '_' + nIndRrow + '_StatoDGUE', StatoRichiesta, StatoRichiesta); } catch (e) { }

		}
	} catch (e) { }

	if (strresult == '#######') {
		strRuolo = '';
		strTechRuolo = '';


		try { getObjGrid('val_R' + strFullNameArea + '_' + nIndRrow + '_StatoDGUE').innerHTML = ''; } catch (e) { }
		try { getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_StatoDGUE').value = ''; } catch (e) { }
		try { getObjGrid('val_R' + strFullNameArea + '_' + nIndRrow + '_StatoDGUE').innerHTML = '<input type=\"hidden\" name=\"R' + strFullNameArea + '_' + nIndRrow + '_StatoDGUE\" id=\"R' + strFullNameArea + '_' + nIndRrow + '_StatoDGUE\"  >'; } catch (e) { }



		try { getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_AllegatoDGUE').value = ''; } catch (e) { }
		try { getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_AllegatoDGUE_V').innerHTML = ''; } catch (e) { }
		try { getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_AllegatoDGUE_V_N').value = ''; } catch (e) { }

		try { SetTextValue('R' + strFullNameArea + '_' + nIndRrow + '_FNZ_OPEN', ''); } catch (e) { }
		try { getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_FNZ_OPEN').innerHTML = ''; } catch (e) { }

		// try{SetTextValue('R' + strFullNameArea + '_' + nIndRrow + '_IdDocRicDGUE','');} catch (e) {} 


	}

	//getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_Ruolo_Impresa').value=strRuolo;
	//getObjGrid('val_R' + strFullNameArea + '_' + nIndRrow + '_Ruolo_Impresa').innerHTML=strTechRuolo;   




}


//viene eseguita dopo i comandio sulla griglia RTI
function ESECUTRICIGRID_AFTER_COMMAND(command) {



	if (command == 'DELETE_ALL') {

		//se ho cancellato la griglia nascondo area relativa
		getObj('div_ESECUTRICIGRIDGrid').style.display = 'none';
		getObj('OFFERTA_PARTECIPANTI_ESECUTRICI_TOOLBAR_ADDFROM').style.display = 'none';

	} else {

		getObj('div_ESECUTRICIGRIDGrid').style.display = '';
		getObj('OFFERTA_PARTECIPANTI_ESECUTRICI_TOOLBAR_ADDFROM').style.display = '';

	}

	//setto onkeyup
	SetOnChangeOnCodiceFiscale('ESECUTRICIGRIDGrid');

	//aggiorno il campo denominazioneATI
	UpgradeDenominazioneRTI();

	//funzione per gestire le colonne dgue
	Show_Hide_dgue_COL();

}


//viene eseguita dopo i comandio sulla griglia RTI
function AUSILIARIEGRID_AFTER_COMMAND(command) {



	if (command == 'DELETE_ALL') {

		//se ho cancellato la griglia nascondo area relativa
		getObj('div_AUSILIARIEGRIDGrid').style.display = 'none';
		getObj('OFFERTA_PARTECIPANTI_AUSILIARIE_TOOLBAR_ADDFROM').style.display = 'none';

	} else {

		getObj('div_AUSILIARIEGRIDGrid').style.display = '';
		getObj('OFFERTA_PARTECIPANTI_AUSILIARIE_TOOLBAR_ADDFROM').style.display = '';

	}

	//setto onkeyup
	SetOnChangeOnCodiceFiscale('AUSILIARIEGRIDGrid');

	//aggiorno il campo denominazioneATI
	UpgradeDenominazioneRTI();

	//funzione per gestire le colonne dgue
	Show_Hide_dgue_COL();

}

//viene eseguita dopo i comandio sulla griglia RTI
function SUBAPPALTOGRID_AFTER_COMMAND(command) {


	//setto onkeyup
	SetOnChangeOnCodiceFiscale('SUBAPPALTOGRIDGrid');

	//aggiorno il campo denominazioneATI
	UpgradeDenominazioneRTI();

	//funzione per gestire le colonne dgue
	Show_Hide_dgue_COL();

}



//alert se azienda non trovata su onblur dal campo codicefiscale
function MakeAlertAzienda() {

	var strNameCtl = this.name;

	var aInfo = strNameCtl.split('_');

	var nIndRrow = aInfo[1];

	var strCF = this.value;

	var strFullNameArea = aInfo[0].substr(1, aInfo[0].length);

	//alert(getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_RagSoc').value);

	if (getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_RagSoc').value == '')
		//alert(CNV ('../../' , 'codice fiscale azienda non esistente') );
		LocDMessageBox('../', 'codice fiscale azienda non esistente', 'Attenzione', 1, 400, 300);
}




//CONTROLLA CHE IN CASO DI RTI LA COMPILAZIONE E' OK
function CanSendRTI() {

	var bret = false;

	//se non ho il campo PartecipaFormaRTI le aree della RTI sono bloccate ed esco
	if (!getObj('PartecipaFormaRTI'))
		return true;



	//controllo se partecipacomeRTI � settato che la griglia RTi � compilata correttamente
	bret = CanSendGridRTI('RTIGRIDGrid', 'PartecipaFormaRTI', 'mandante');
	if (!bret) {
		return false;
	}

	//controllo che per la RTI le righe devo essere almeno 2
	strFullNameArea = 'RTIGRIDGrid';

	nNumRow = Number(GetProperty(getObj(strFullNameArea), 'numrow'));

	if (nNumRow == 0) {
		//alert( CNV ('../../' , 'inserire almeno una mandante') );
		LocDMessageBox('../', 'inserire almeno una mandante', 'Attenzione', 1, 400, 300);
		return false;
	}

	//se ho le esecutrici faccio i controlli sulle aree preposte
	if (getObjValue('SYS_OFFERTA_PRESENZA_ESECUTRICI') != 'NO') {

		//se ho settato Consorzio a si controllo che la griglia consorzio � compilata correttamente
		bret = false;
		bret = CanSendGridRTI('ESECUTRICIGRIDGrid', 'InserisciEsecutriciLavori', 'esecutrice')
		if (!bret) {
			return false;
		}

		//controllo che i consorzi della griglia Consorzio sono tutti nella griglia RTI
		bret = false;
		bret = RiferimentiGridIsInRTI('ESECUTRICIGRIDGrid', 'RagSocRiferimento', 'IdAziRiferimento');
		if (!bret) {
			return false;
		}

	}



	//se ho settatto RicorriAvvalimento controllo che la griglia avvalimento � compilata correttamente
	bret = false;
	bret = CanSendGridRTI('AUSILIARIEGRIDGrid', 'RicorriAvvalimento', 'ausiliaria')
	if (!bret) {
		return false;
	}

	//controllo che le ausiliate  della griglia Avvalimenti sono tutti nella griglia RTI
	bret = false;
	bret = RiferimentiGridIsInRTI('AUSILIARIEGRIDGrid', 'RagSocRiferimento', 'IdAziRiferimento');
	if (!bret) {
		return false;
	}


	//aggiorno coerentemente il campo denominazione ati
	UpgradeDenominazioneRTI();

	return true;

}



//controlla che una griglia � compilata correttamente
function CanSendGridRTI(strFullNameArea, strAttrib, strCnv) {


	var iddztAttrib;
	var objAttrib;

	if (getObj(strAttrib) && getObj(strAttrib).value == '1') {

		nNumRow = 0;

		try {
			nNumRow = Number(GetProperty(getObj(strFullNameArea), 'numrow'));
		}
		catch (e) {
		}

		if (nNumRow == -1) {

			alert(CNV('../../', 'inserire almeno una ' + strCnv));
			return false;

		} else {

			for (nIndRrow = 0; nIndRrow <= nNumRow; nIndRrow++) {

				if (getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_RagSoc').value == '') {

					//alert( CNV ('../../' , 'inserire codice fiscale della ' + strCnv ) );
					LocDMessageBox('../', 'inserire codice fiscale della ' + strCnv, 'Attenzione', 1, 400, 300);

					return false;

				}
			}
		}
	}

	return true;

}



//CONTROLLA CHE LE AZIENDE DI RIFERIMENTO DELLA GRIGLIA IN INPUT SIANO PRESENTI NELLA GRIGLIA RTI
//OPPURE DEVE ESSERE SOLO L'AZIENDA LOGGATA
function RiferimentiGridIsInRTI(strFullNameArea, strAttribRagSoc, strAttribIdAzi) {

	var strListAziendeRTI = GetAziRTI();

	var strIdAziEsecutrici = GetEsecutriciConsorzio();

	if (strIdAziEsecutrici != '')
		strListAziendeRTI = strListAziendeRTI + ',' + strIdAziEsecutrici;

	strListAziendeRTI = ',' + strListAziendeRTI + ','


	//determino se esiste un raggruppamento RTI
	var bRTI = true;
	var strFullNameAreaRTI = 'RTIGRIDGrid';
	var nNumRowRTI = Number(GetProperty(getObj(strFullNameAreaRTI), 'numrow'));

	if (nNumRowRTI == -1)
		bRTI = false;


	var nNumRow = -1;

	try {
		nNumRow = Number(GetProperty(getObj(strFullNameArea), 'numrow'));
	}
	catch (e) {
	}

	var strCurrIdAzi = '';

	if (nNumRow >= 0) {

		var nIndRrow;

		for (nIndRrow = 0; nIndRrow <= nNumRow; nIndRrow++) {

			strCurrIdAzi = ',' + getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_' + strAttribIdAzi).value + ',';
			strCurrRagSoc = getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_' + strAttribRagSoc).value;

			if (strListAziendeRTI.indexOf(strCurrIdAzi, 0) < 0) {
				if (bRTI)
					alert(CNV('../../', 'attenzione azienda area ' + strFullNameArea) + ' "' + strCurrRagSoc + '" ' + CNV('../../', 'non presente in rti'));
				//DMessageBox( '../' , 'attenzione azienda area ' + strFullNameArea  , 'Attenzione' , 1 , 400 , 300 ) 
				else
					alert(CNV('../../', 'attenzione azienda area ' + strFullNameArea) + ' "' + strCurrRagSoc + '" ' + CNV('../../', 'non azienda loggata'));

				return false;

			}


		}
	}

	return true;

}


function ControlliOfferta(param) {

	//CONTROLLO IN CASO DI RTI
	var bret = false;

	//se non ho il campo editabile PartecipaFormaRTI vuol dire che le aree della RTI sono bloccate
	bret = CanSendRTI();

	if (!bret) {

		DocShowFolder('FLD_BUSTA_DOCUMENTAZIONE');
		tdoc();
		return false;

	}


	return true;


}

//Funzione per gestire la format dei decimale e la format degli allegati
function FormatNumDec() {


	var colonna = getObj('colonnatecnica').value;
	var numdec = getObj('NumDec').value;
	var blur = '';
	var blurtmp = '';
	var blurtmp2 = '';
	var onclick;
	var tipofile;

	var onclick2;

	//********************************************************************************
	//*** PER OGNI COLONNA DI TIPO ALLEGATO SE PREVISTA SETTO LE ESTENSIONI AMMESSE **
	//********************************************************************************
	/*
	var strEstensioni_Prodotti_Gara = getObj('Estensioni_Prodotti_Gara').value;
	var aInfoAttach = strEstensioni_Prodotti_Gara.split('@@@');
	var nNumAttach = aInfoAttach.length;
	*/
	try {
		var numrrowprod = Number(GetProperty(getObj('PRODOTTIGrid'), 'numrow'));
		if (numrrowprod >= 0) {
			var t = 0;
			for (t = 0; t < numrrowprod + 1; t++) {

				/*
				blur = getObj('R' + t + '_' + colonna + '_V').getAttribute('onblur');
				blurtmp = blur.substring(0,blur.indexOf(';')+1);
				blurtmp2 = blur.substring(blur.indexOf(';')+1,blur.length);
				blurtmp = blurtmp.substring(0,blurtmp.lastIndexOf(',')+1) + numdec + ');';
				//ck_VN( this ,',',6 );
				blur=blurtmp+blurtmp2;
				getObj('R' + t + '_' + colonna + '_V').setAttribute('onblur',blur);
				*/

				if (numdec > 0) {
					tipofile = 'format#=####,###,##0.' + pad(0, numdec);
				}
				else {
					tipofile = 'format#=####,###,##0';
				}
				obj = getObj('R' + t + '_' + colonna + '_V').parentElement;


				onclick = obj.innerHTML;
				onclick = onclick.replace(/format#=####,###,##0.00###/g, tipofile);
				obj.innerHTML = onclick;

				/*
				//alert(strEstensioni_Prodotti_Gara);
	    
				//se ci sono attributi di tipo allegato procedo a settare per ognuno le estensinoi ammesse
				//COMMENTATA
				//PERCHE LA FORMAT DEGLI ATTRIBUTI ATTACH E STATA COSTRUITA 
				//QUANDO CREAIMO IL MODELLO
				if ( strEstensioni_Prodotti_Gara != '')
				{
				  
				  for (j = 0; j <= nNumAttach -1 ; j++) 
				  {   
					
					try 
					{
					
						aInfoExt = aInfoAttach[j].split(';');
						strAttribAttach =  aInfoExt[0];
						strExt = aInfoExt[1];
						
						//se non ci sono restrizioni non faccio nulla
						if ( strExt != '' ){
							
							
							obj2 = getObj('R' + t + '_' + strAttribAttach + '_V_BTN').parentElement;
							
							onclick2 = obj2.innerHTML;
							
							nPosStartFormat = onclick2.indexOf('&amp;FORMAT=');
							
							strTailOnclick2 = onclick2.substring(nPosStartFormat+12, nPosStartFormat+100);
							
							nPosEndParametri = strTailOnclick2.indexOf('\' ');
							
							nPosEndFormat = strTailOnclick2.indexOf('&amp;');
							if (nPosEndFormat == -1)
									nPosEndFormat = nPosEndParametri;
								
							strHeadFormat =  strTailOnclick2.substring(0 , nPosEndFormat);
							
							
							strExt = ReplaceExtended(strExt, '###', ',');
							//strExt = 'INTCEXT:' + strExt.substring(1, strExt.length);
							strExt = strHeadFormat + 'EXT:' + strExt.substring(1, strExt.length);
							strExt = strExt.substring(0, strExt.length - 1) + '-';
							strExt = 'FORMAT=' + strExt;
							
														
							strPatternFormat = 'FORMAT=' + strHeadFormat;
							//onclick2=onclick2.replace(/FORMAT=INTC/g , strExt);
														
							onclick2=onclick2.replace(new RegExp(strPatternFormat, 'g'), strExt);
							
							obj2.innerHTML = onclick2;
						}
						
						
				   } catch (e) {}
					
				  }
				
				}
				*/

			}

		}
	} catch (e) { }

}

function PRODOTTI_AFTER_COMMAND() {

	FormatNumDec();

	presenzaAmpiezzaGamma()
}

function pad(number, length) {

	var str = '' + number;
	while (str.length < length) {
		str = '0' + str;
	}

	return str;

}
function sganciaEsitoRiga_DOC(idCampo) {
	var i = idCampo.split('_');
	var row = i[0];

	row = row.replace('R', '') + '_' + i[1];

	var msg = '<img src="../images/Domain/State_Warning.gif"><br>La Riga e\' stata modificata.<br/>E\' necessario eseguire il comando "Verifica Informazioni"';

	getObj('R' + row + '_EsitoRiga_V').innerHTML = msg;
	getObj('R' + row + '_EsitoRiga').value = msg;

}

function sganciaEsitoRiga(idCampo) {
	var i = idCampo.split('_');
	var row = i[0];

	row = row.replace('R', '');

	//Lavoro sulle righe per andare a svuotare l'esito della voce 0 del lotto
	try {
		var numeroLotto = '-1';
		var voce = '0';

		if (getObj('R' + row + '_NumeroLotto'))
			numeroLotto = getObjValue('R' + row + '_NumeroLotto');

		//Svuoto l'esito riga
		svuotaEsito(row, numeroLotto);

		//Se esiste il campo voce
		if (getObj('R' + row + '_Voce')) {
			voce = getObjValue('R' + row + '_Voce');

			//Se non mi trovo sulla riga a voce 0 risalgo le righe per arrivare, a parit� di lotto, alla voce 0&PARAM
			if (voce != '0') {

				var numrrowprod = Number(GetProperty(getObj('PRODOTTIGrid'), 'numrow'));
				if (numrrowprod >= 0) {
					var r = 0;
					var voceRigaN;
					var numeroLottoRigaN;

					for (r = 0; r < numrrowprod + 1; r++) {
						//Se non mi trovo sulla riga che ho gi� lavorato
						if (r != row) {
							voceRigaN = getObjValue('R' + r + '_Voce');
							numeroLottoRigaN = getObjValue('R' + r + '_NumeroLotto');

							//Se mi trovo sul lotto giusto e la voce � la 0
							if (numeroLottoRigaN == numeroLotto && voceRigaN == '0') {
								svuotaEsito(r, numeroLottoRigaN);
								break;
							}

						}
					}

				}

			}

		}
	}
	catch (e) {
	}

}

function svuotaEsito(row, numeroLotto) {
	var msg = '<img src="../images/Domain/State_ERR.gif"><br>L\'elenco Prodotti e\' stato modificato.<br/>E\' necessario eseguire il comando "Verifica Informazioni"';

	getObj('R' + row + '_EsitoRiga_V').innerHTML = msg;
	getObj('R' + row + '_EsitoRiga').value = msg;

	try {
		if (numeroLotto != '-1') {
			var numrrowprod = Number(GetProperty(getObj('LISTA_BUSTEGrid'), 'numrow'));
			var esito = '<img src="../images/Domain/State_OK.gif">';

			if (numrrowprod >= 0) {
				var r = 0;
				var voceRigaN;
				var numeroLottoRigaN;

				for (r = 0; r < numrrowprod + 1; r++) {

					numeroLottoRigaN = getObjValue('RLISTA_BUSTEGrid_' + r + '_NumeroLotto');

					if (numeroLottoRigaN == numeroLotto) {
						getObj('RLISTA_BUSTEGrid_' + r + '_EsitoRiga_V').innerHTML = msg;
						getObj('RLISTA_BUSTEGrid_' + r + '_EsitoRiga').value = msg;
						break;
					}

				}

			}
		}
	}
	catch (e) {
	}
}

function getEsitoLotto(numeroLotto) {
	var numrrowprod = Number(GetProperty(getObj('PRODOTTIGrid'), 'numrow'));
	var esito = '<img src="../images/Domain/State_OK.gif">';

	if (numrrowprod >= 0) {
		var r = 0;
		var voceRigaN;
		var numeroLottoRigaN;

		for (r = 0; r < numrrowprod + 1; r++) {
			if (getObj('R' + r + '_Voce'))
				voceRigaN = getObjValue('R' + r + '_Voce');
			else
				voceRigaN = '0';

			numeroLottoRigaN = getObjValue('R' + r + '_NumeroLotto');

			//Se mi trovo sul lotto giusto e la voce � la 0
			if (numeroLottoRigaN == numeroLotto && voceRigaN == '0') {
				esito = getObjValue('R' + r + '_EsitoRiga');
				break;
			}

		}

	}

	return esito;

}
function MyMakeDocFrom(param) {

	ML_text = 'OFFERTE_UTENTE_TOOLBAR_NEW';
	Title = 'Informazione';
	ICO = 1;
	page = 'ctl_library/MessageBoxWin.asp?MODALE=YES&ML=YES&MSG=' + encodeURIComponent(ML_text) + '&CAPTION=' + encodeURIComponent(Title) + '&ICO=' + encodeURIComponent(ICO);

	ExecFunctionModaleConfirm(page, Title, 200, 420, null, 'MakeDocFrom@@@@' + param, '');


	/*
	if( confirm(CNV( '../','OFFERTE_UTENTE_TOOLBAR_NEW')) )
	{
		MakeDocFrom(param);
	}
	*/
}


function TESTATA_LISTA_BUSTE_OnLoad() {

	try {

		if (getObjValue('RichiestaFirma') == 'no') {
			document.getElementById('TESTATA_LISTA_BUSTE').style.display = "none";

		} else {

			document.getElementById('TESTATA_LISTA_BUSTE').style.display = "";

			try {


				var DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;

				if (DOCUMENT_READONLY != '0') {
					document.getElementById('genera_pdf_buste').disabled = true;
					document.getElementById('genera_pdf_buste').className = "generapdfdisabled";
					document.getElementById('importa_pdf_buste').disabled = true;
					document.getElementById('importa_pdf_buste').className = "generapdfdisabled";

				}
			} catch (e) { };

		}

		return;

	} catch (e) { };
}


function Compila_DOC_DGUE() {


	var DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;
	if (DOCUMENT_READONLY == "1") {
		MakeDocFrom('MODULO_TEMPLATE_REQUEST##MANIFESTAZIONE_INTERESSE');
	}
	else {
		ExecDocProcess('FITTIZIO,DOCUMENT,,NO_MSG');
	}

}

function Compila_Questionario_Amministrativo() {
	var DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;
	if (DOCUMENT_READONLY == "1") {
		MakeDocFrom('MODULO_QUESTIONARIO_AMMINISTRATIVO##OFFERTA');
	}
	else {
		ExecDocProcess('FITTIZIO3,DOCUMENT,,NO_MSG');
	}
}


function Show_Hide_dgue_COL() {
	try {
		if (getObjValue('PresenzaDGUE') != 'si') {

			try { nNumRowRTI = Number(GetProperty(getObj('RTIGRIDGrid'), 'numrow')); } catch (e) { }
			try { nNumRowESECU = Number(GetProperty(getObj('ESECUTRICIGRIDGrid'), 'numrow')); } catch (e) { }
			try { nNumRowAUSI = Number(GetProperty(getObj('AUSILIARIEGRIDGrid'), 'numrow')); } catch (e) { }
			try { nNumRowSUB = Number(GetProperty(getObj('SUBAPPALTOGRIDGrid'), 'numrow')); } catch (e) { }
			//se sono presenti righe nascondo le colonne DGUE
			if (nNumRowRTI > -1) {
				ShowCol('RTIGRID', 'StatoDGUE', 'none');
				ShowCol('RTIGRID', 'AllegatoDGUE', 'none');
				ShowCol('RTIGRID', 'FNZ_OPEN', 'none');
			}
			if (nNumRowESECU > -1) {
				ShowCol('ESECUTRICIGRID', 'StatoDGUE', 'none');
				ShowCol('ESECUTRICIGRID', 'AllegatoDGUE', 'none');
				ShowCol('ESECUTRICIGRID', 'FNZ_OPEN', 'none');
			}
			if (nNumRowAUSI > -1) {
				ShowCol('AUSILIARIEGRID', 'StatoDGUE', 'none');
				ShowCol('AUSILIARIEGRID', 'AllegatoDGUE', 'none');
				ShowCol('AUSILIARIEGRID', 'FNZ_OPEN', 'none');
			}
			if (nNumRowSUB > -1) {
				ShowCol('SUBAPPALTOGRID', 'StatoDGUE', 'none');
				ShowCol('SUBAPPALTOGRID', 'AllegatoDGUE', 'none');
				ShowCol('SUBAPPALTOGRID', 'FNZ_OPEN', 'none');
			}

		}
	} catch (e) { }
	//CICLO SULLE GRIGLIE RTI E Avvalimenti QUANDO TROVA INVIATA RICHIESTA per statodgue rende la colonna codicefiscale not edit
	try {
		if (getObjValue('PresenzaDGUE') == 'si') {
			try { nNumRowRTI = Number(GetProperty(getObj('RTIGRIDGrid'), 'numrow')); } catch (e) { }
			try { nNumRowESECU = Number(GetProperty(getObj('ESECUTRICIGRIDGrid'), 'numrow')); } catch (e) { }
			try { nNumRowAUSI = Number(GetProperty(getObj('AUSILIARIEGRIDGrid'), 'numrow')); } catch (e) { }
			try { nNumRowSUB = Number(GetProperty(getObj('SUBAPPALTOGRIDGrid'), 'numrow')); } catch (e) { }
			if (nNumRowRTI > -1) {
				for (i = 0; i <= nNumRowRTI; i++) {
					if (getObjValue('RRTIGRIDGrid_' + i + '_StatoDGUE') == 'InviataRichiesta') {
						TextreadOnly('RRTIGRIDGrid_' + i + '_codicefiscale', true);
					}
					if (getObjValue('RRTIGRIDGrid_' + i + '_StatoDGUE') != 'Ricevuto') {
						getObj('RRTIGRIDGrid_' + i + '_FNZ_OPEN').innerHTML = '';
					}

				}
			}
			if (nNumRowESECU > -1) {
				for (i = 0; i <= nNumRowESECU; i++) {
					if (getObjValue('RESECUTRICIGRIDGrid_' + i + '_StatoDGUE') == 'InviataRichiesta') {
						TextreadOnly('RESECUTRICIGRIDGrid_' + i + '_codicefiscale', true);
					}
					if (getObjValue('RESECUTRICIGRIDGrid_' + i + '_StatoDGUE') != 'Ricevuto') {
						getObj('RESECUTRICIGRIDGrid_' + i + '_FNZ_OPEN').innerHTML = '';
					}

				}
			}
			if (nNumRowAUSI > -1) {
				for (i = 0; i <= nNumRowAUSI; i++) {
					if (getObjValue('RAUSILIARIEGRIDGrid_' + i + '_StatoDGUE') == 'InviataRichiesta') {
						TextreadOnly('RAUSILIARIEGRIDGrid_' + i + '_codicefiscale', true);
					}
					if (getObjValue('RAUSILIARIEGRIDGrid_' + i + '_StatoDGUE') != 'Ricevuto') {
						getObj('RAUSILIARIEGRIDGrid_' + i + '_FNZ_OPEN').innerHTML = '';
					}

				}
			}
			if (nNumRowSUB > -1) {
				for (i = 0; i <= nNumRowSUB; i++) {
					if (getObjValue('RSUBAPPALTOGRIDGrid_' + i + '_StatoDGUE') == 'InviataRichiesta') {
						TextreadOnly('RSUBAPPALTOGRIDGrid_' + i + '_codicefiscale', true);
					}
					if (getObjValue('RSUBAPPALTOGRIDGrid_' + i + '_StatoDGUE') != 'Ricevuto') {
						getObj('RSUBAPPALTOGRIDGrid_' + i + '_FNZ_OPEN').innerHTML = '';
					}

				}
			}

		}
	} catch (e) { }

}

function MyMakeDocFrom2(objGrid, Row, c) {
	var DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;
	var cod = getObj('R' + objGrid + '_' + Row + '_IdDocRicDGUE').value;
	var param = '';
	if (DOCUMENT_READONLY == "1") {

		if (cod == '' || cod == undefined) {
			alert('Errore tecnico - IdDocRicDGUE - non trovato');
			return;
		}
		param = 'RICHIESTA_COMPILAZIONE_DGUE_RISPOSTA##OFFERTA#' + cod + '#';
		MakeDocFrom(param);
	}
	else {

		getObj('idDocR').value = cod;
		ExecDocProcess('FITTIZIO2,DOCUMENT,,NO_MSG');
	}

}



function RitiraOfferta(param) {
	if (getObjValue('id_ritira_offerta') == '0') {

		ML_text = 'MSG_ALERT_RITIRA_OFFERTA';
		Title = 'Informazione';
		ICO = 1;
		page = 'ctl_library/MessageBoxWin.asp?MODALE=YES&ML=YES&MSG=' + encodeURIComponent(ML_text) + '&CAPTION=' + encodeURIComponent(Title) + '&ICO=' + encodeURIComponent(ICO);

		ExecFunctionModaleConfirm(page, Title, 200, 420, null, 'MakeDocFrom@@@@' + param, '');
		/*
		if( confirm(CNV( '../../','MSG_ALERT_RITIRA_OFFERTA')) )
		{
			MakeDocFrom(param);
		}
		*/
	}
	else
		MakeDocFrom(param);

}


function Reset_SUBAPPALTOGRID() {

	try { nNumRowSUB = Number(GetProperty(getObj('SUBAPPALTOGRIDGrid'), 'numrow')); } catch (e) { }
	for (i = 0; i <= nNumRowSUB; i++) {
		getObj('RSUBAPPALTOGRIDGrid_' + i + '_codicefiscale').value = '';
		getObj('RSUBAPPALTOGRIDGrid_' + i + '_RagSoc_V').innerHTML = '';
		getObj('RSUBAPPALTOGRIDGrid_' + i + '_RagSoc').value = '';
		getObj('RSUBAPPALTOGRIDGrid_' + i + '_INDIRIZZOLEG_V').innerHTML = '';
		getObj('RSUBAPPALTOGRIDGrid_' + i + '_INDIRIZZOLEG').value = '';
		getObj('RSUBAPPALTOGRIDGrid_' + i + '_LOCALITALEG_V').innerHTML = '';
		getObj('RSUBAPPALTOGRIDGrid_' + i + '_LOCALITALEG').value = '';
		getObj('RSUBAPPALTOGRIDGrid_' + i + '_PROVINCIALEG_V').innerHTML = '';
		getObj('RSUBAPPALTOGRIDGrid_' + i + '_PROVINCIALEG').value = '';
		getObj('RSUBAPPALTOGRIDGrid_' + i + '_IdAzi').value = '';
	}
}

function icona_folder_documento() {

	var Divisione_lotti = getObjValue('Divisione_lotti');


	//SE E' PREVISTO IL DGUE INSERISCE ICONA DI WARNING SE NON E' PRESENTE
	if (getObjValue('PresenzaDGUE') == 'si') {
		if (getObj('RDISPLAY_DGUE_MODEL_Allegato').value == '') {
			var val = $('#CompilaDGUE').parent().siblings('td:first').text();
			$('#CompilaDGUE').parent().siblings('td:first').html('<img src="../images/Domain/State_Warning.png"> <strong>' + val + '</strong>');
		}
	}

	//SE E' PREVISTO IL QUESTIONARIO_AMMINISTRATIVO INSERISCE ICONA DI WARNING SE NON E' PRESENTE
	if (getObjValue('PresenzaQuestionario') === 'si') {
		if (getObj('RDISPLAY_QUESTIONARIO_MODEL_AllegatoQuestionario').value == '') {
			var val = $('#CompilaQuestionarioAmministrativo').parent().siblings('td:first').text();
			$('#CompilaQuestionarioAmministrativo').parent().siblings('td:first').html('<img src="../images/Domain/State_Warning.png"> <strong>' + val + '</strong>');
		}
	}

	//SE E' PREVISTO ATTESTATO DI PARTECIPAZIONE INSERISCE ICONA DI WARNING SE NON E' PRESENTE
	if (getObjValue('ClausolaFideiussoria') == '1') {
		if (getObj('F2_SIGN_ATTACH').value == '') {
			var val = $('#table_file_attestazione_partecipazione').text();
			$('#table_file_attestazione_partecipazione').html('<img src="../images/Domain/State_Warning.png"> ' + val);
		}
	}

	//--SUL FOLDER BUSTA DOCUMENTAZIONE SE CI SONO WARNING LO INSERISCO ANCHE PRIMA DEL TITOLO DEL FOLDER
	var value = document.getElementsByName("folder_button_BUSTA_DOCUMENTAZIONE")[0].innerHTML;

	if (getObj('RTESTATA_DOCUMENTAZIONE_MODEL_EsitoRiga').value.indexOf('State_Warning.gif') > 0) {
		$("button[name='folder_button_BUSTA_DOCUMENTAZIONE']").html('<img src="../images/Domain/State_Warning.png"> ' + value);
	}
	else if (getObj('RTESTATA_DOCUMENTAZIONE_MODEL_EsitoRiga').value.indexOf('State_Err.gif') > 0) {
		$("button[name='folder_button_BUSTA_DOCUMENTAZIONE']").html('<img src="../images/Domain/State_Err.png"> ' + value);
	}
	else {
		$("button[name='folder_button_BUSTA_DOCUMENTAZIONE']").html('<img src="../images/Domain/State_OK.png"> ' + value);
	}

	//SULLA PRIMA APERTURA METTE ERRORE PER FAR FARE VERIFICA INFORMAZIONI
	try {
		if (getObj('RTESTATA_PRODOTTI_MODEL_EsitoRiga').value == '<img src="../images/Domain/State_Err.gif"><br/>E\' necessario eseguire il comando "Verifica Informazioni"') {
			try {
				var value = document.getElementsByName("folder_button_PRODOTTI")[0].innerHTML;
				$("button[name='folder_button_PRODOTTI']").html('<img src="../images/Domain/State_ERR.png"> ' + value);
			} catch (e) { }

			try {
				var value = document.getElementsByName("folder_button_BUSTA_TECNICA")[0].innerHTML;
				$("button[name='folder_button_BUSTA_TECNICA']").html('<img src="../images/Domain/State_ERR.png"> ' + value);
			} catch (e) { }

			try {
				var value = document.getElementsByName("folder_button_BUSTA_ECONOMICA")[0].innerHTML;
				$("button[name='folder_button_BUSTA_ECONOMICA']").html('<img src="../images/Domain/State_ERR.png"> ' + value);
			} catch (e) { }
			try {
				var value = document.getElementsByName("folder_button_LISTA_LOTTI")[0].innerHTML;
				$("button[name='folder_button_LISTA_LOTTI']").html('<img src="../images/Domain/State_ERR.png"> ' + value);
			} catch (e) { }

		}
		else {


			//SUL FOLDER DEI PRODOTTI SE SONO PRESENTI TUTTI LOTTI IN ERRORE METTO ICONA DI ERRORE ALTRIMENTI WARNING
			var errore_prod = 0;
			var warning_prod = 0;
			var numrrowprod = Number(GetProperty(getObj('PRODOTTIGrid'), 'numrow'));

			if (numrrowprod >= 0) {
				var t = 0;
				for (t = 0; t < numrrowprod + 1; t++) {
					//PER LE OFFERTE A LOTTI CONTROLLO LA VOCE ZERO, ALMENO UN LOTTO OK
					if (Divisione_lotti != '0') {
						if (getObj('R' + t + '_Voce').value == '0') {
							if (getObj('R' + t + '_EsitoRiga').value.indexOf('State_ERR.gif') > 0) {
								errore_prod = 1;
								break;
							}
							else {
								if (getObj('R' + t + '_EsitoRiga').value.indexOf('State_Warning.gif') > 0) {
									warning_prod = 1;
									break;
								}
							}
						}
					}
					else //CONTROLLO PER LE GARE NON A LOTTI, TUTTE LE RIGHE OK
					{
						if (getObj('R' + t + '_EsitoRiga').value.indexOf('State_ERR.gif') > 0) {
							errore_prod = 1;
							break;
						}
						else {
							if (getObj('R' + t + '_EsitoRiga').value.indexOf('State_Warning.gif') > 0) {
								warning_prod = 1;
								break;
							}
						}
					}
				}
			}


			//TUTTI I LOTTI CON ERRORI
			var value = document.getElementsByName("folder_button_PRODOTTI")[0].innerHTML;

			if (warning_prod == 0 && errore_prod == 1) {
				$("button[name='folder_button_PRODOTTI']").html('<img src="../images/Domain/State_ERR.png"> ' + value);

			}
			else {

				//ALMENO UN LOTTO VALIDO OPPURE ESITO COMPLESSIVO VALORIZZATO			
				if (warning_prod == 1) {
					$("button[name='folder_button_PRODOTTI']").html('<img src="../images/Domain/State_Warning.png"> ' + value);
				}
				else {
					//CORREZIONE: prima il warning sui prodotti non usciva mai perch� se c'� solo il warning, finiremmo comunque l'if dell'OK che sovrascrive la precedente icona di warning.
					// Per mettere l'ok il ragionamento era che se non c'erano errori allora mettevamo ok ( facendo quindi perdere il warning ). abbiamo messo quindi quest'if sotto ELSE rispetto al warning

					//NEMMENO UN LOTTO IN ERRORE
					if (errore_prod == 0 && getObjValue('RTESTATA_PRODOTTI_MODEL_EsitoRiga').indexOf('State_ERR.gif') < 0) {
						$("button[name='folder_button_PRODOTTI']").html('<img src="../images/Domain/State_OK.png"> ' + value);
					}
				}

			}


			var ControlloFirmaBuste = getObj('ControlloFirmaBuste');
			var ControlloFirmaBuste_RESULT = 0;
			/* SE IL CAMPO ESISTE */
			if (ControlloFirmaBuste) {
				//Se � richiesta la mancata verifica dei controlli di firma ( eccezione del hash di tra il file generato e quello allegato )
				if (ControlloFirmaBuste.value == 'no') {
					ControlloFirmaBuste_RESULT = 1;
				}
			}


			//SUL FOLDER ELENCO LOTTI SE SONO PRESENTI TUTTI LOTTI IN ERRORE METTO ICONA DI ERRORE ALTRIMENTI WARNING
			try {

				if (Divisione_lotti != '0' && getObjValue('ProceduraGara') != '15583' && getObjValue('ProceduraGara') != '15479') {
					var errore_ELE = 0;
					var warning_ELE = 0;
					var busta_tec = '';
					var busta_eco = '';
					var numrrowELENCO_LOTTI = Number(GetProperty(getObj('LISTA_BUSTEGrid'), 'numrow'));
					if (numrrowELENCO_LOTTI >= 0) {
						var t = 0;
						for (t = 0; t < numrrowELENCO_LOTTI + 1; t++) {

							//RECUPERO I VALORI, NEL CASO NON RICHIESTA LA BUSTA ASSUMO CHE SIA BUONA, QUINDI FIRMATO
							try { busta_tec = getObj('RLISTA_BUSTEGrid_' + t + '_Esito_Busta_Tec').value } catch (e) { busta_tec = 'firmato' }
							try { busta_eco = getObj('RLISTA_BUSTEGrid_' + t + '_Esito_Busta_Eco').value } catch (e) { busta_eco = 'firmato' }


							if ((busta_tec != 'firmato' && busta_tec != 'pending' && busta_tec != 'pdf_allegato') ||
								(busta_eco != 'firmato' && busta_eco != 'pending' && busta_tec != 'pdf_allegato') ||
								getObj('RLISTA_BUSTEGrid_' + t + '_EsitoRiga').value.indexOf('State_ERR.gif') > 0
							) {
								errore_ELE = 1;
							}
							else {
								warning_ELE = 1;
							}

						}

					}

					var value = document.getElementsByName("folder_button_LISTA_LOTTI")[0].innerHTML;
					//TUTTI I LOTTI CON ERRORI
					if (warning_ELE == 0 && errore_ELE == 1) {
						$("button[name='folder_button_LISTA_LOTTI']").html('<img src="../images/Domain/State_ERR.png"> ' + value);
					}
					//ALMENO UN LOTTO VALIDO
					if (warning_ELE == 1 && errore_ELE == 1) {

						$("button[name='folder_button_LISTA_LOTTI']").html('<img src="../images/Domain/State_Warning.png"> ' + value);
					}
					//NEMMENO UN LOTTO IN ERRORE
					if (errore_ELE == 0) {

						$("button[name='folder_button_LISTA_LOTTI']").html('<img src="../images/Domain/State_OK.png"> ' + value);

					}
					//QUANDO NON SONO RICHIESTI i controlli sulle firme buste ed ho i warning e non ho errori allora metto il warnign
					if (ControlloFirmaBuste_RESULT == 1 && errore_ELE == 0 && warning_ELE == 1) {
						$("button[name='folder_button_LISTA_LOTTI']").html('<img src="../images/Domain/State_Warning.png"> ' + value);
					}
				}
				//QUANDO SONO SENZA LOTTI controlliamo se presente l'allegato firmato nella busta
				else {




					try {
						var value = document.getElementsByName("folder_button_BUSTA_TECNICA")[0].innerHTML;

						if (getObj('F3_SIGN_ATTACH').value != '')  //folder_button_BUSTA_TECNICA
						{
							if (ControlloFirmaBuste_RESULT == 1 && $("#F3_SIGN_ATTACH_V tr:first-child").html().indexOf('sign_not_ok.png') > 0) //Se non � richiesta la firma buste e non ho messo un file firmato
							{
								$("button[name='folder_button_BUSTA_TECNICA']").html('<img src="../images/Domain/State_Warning.png"> ' + value);
							}
							else {
								$("button[name='folder_button_BUSTA_TECNICA']").html('<img src="../images/Domain/State_OK.png"> ' + value);
							}
						}
						else {
							$("button[name='folder_button_BUSTA_TECNICA']").html('<img src="../images/Domain/State_ERR.png"> ' + value);
						}
					} catch (e) { }

					try {
						var value = document.getElementsByName("folder_button_BUSTA_ECONOMICA")[0].innerHTML;

						if (getObj('F1_SIGN_ATTACH').value != '') {
							if (ControlloFirmaBuste_RESULT == 1 && $("#F1_SIGN_ATTACH_V tr:first-child").html().indexOf('sign_not_ok.png') > 0) //Se non � richiesta la firma buste e non ho messo un file firmato
							{
								$("button[name='folder_button_BUSTA_ECONOMICA']").html('<img src="../images/Domain/State_Warning.png"> ' + value);
							}
							else {
								$("button[name='folder_button_BUSTA_ECONOMICA']").html('<img src="../images/Domain/State_OK.png"> ' + value);
							}
						}
						else {
							$("button[name='folder_button_BUSTA_ECONOMICA']").html('<img src="../images/Domain/State_ERR.png"> ' + value);
						}
					} catch (e) { }

				}
			} catch (e) { }
		}
	} catch (e) { }


	var PresenzaModAmpiezzaGamma;

	try {
		PresenzaModAmpiezzaGamma = getObj('PresenzaModuloAmpiezzaGamma').value;
	}
	catch { };


	if (PresenzaModAmpiezzaGamma == 'si')
		icona_folder_documento_AmpGamma();

}


function icona_folder_documento_AmpGamma() {

	var Divisione_lotti = getObjValue('Divisione_lotti');




	//SULLA PRIMA APERTURA METTE ERRORE PER FAR FARE VERIFICA INFORMAZIONI
	try {
		if (getObj('RTESTATA_PRODOTTI_AMPIEZZA_GAMMA_MODEL_EsitoRiga').value == '<img src="../images/Domain/State_Err.gif"><br/>E\' necessario eseguire il comando "Verifica Informazioni"') {
			try {
				var value = document.getElementsByName("folder_button_PRODOTTI")[0].innerHTML;
				$("button[name='folder_button_PRODOTTI']").html('<img src="../images/Domain/State_ERR.png"> ' + value);
			} catch (e) { }
			/*
			try
			{
			   var value = document.getElementsByName("folder_button_BUSTA_TECNICA")[0].innerHTML;
			   $( "button[name='folder_button_BUSTA_TECNICA']" ).html('<img src="../images/Domain/State_ERR.png"> ' + value );
			}catch(e){}
	   	
		   try
		   {		
			   var value = document.getElementsByName("folder_button_BUSTA_ECONOMICA")[0].innerHTML;
			   $( "button[name='folder_button_BUSTA_ECONOMICA']" ).html('<img src="../images/Domain/State_ERR.png"> ' + value );
		   }catch(e){}
		   */
			try {
				var value = document.getElementsByName("folder_button_LISTA_LOTTI")[0].innerHTML;
				$("button[name='folder_button_LISTA_LOTTI']").html('<img src="../images/Domain/State_ERR.png"> ' + value);
			} catch (e) { }

		}
		else {


			//SUL FOLDER DEI PRODOTTI SE SONO PRESENTI TUTTI LOTTI IN ERRORE METTO ICONA DI ERRORE ALTRIMENTI WARNING
			var errore_prod = 0;
			var warning_prod = 0;
			var numrrowprod = -1;
			try {
				numrrowprod = Number(GetProperty(getObj('PRODOTTI_AMPIEZZA_GAMMAGrid'), 'numrow'));
			} catch (e) { numrrowprod = -1; }

			if (numrrowprod >= 0) {
				var t = 0;
				for (t = 0; t < numrrowprod + 1; t++) {
					//PER LE OFFERTE A LOTTI CONTROLLO LA VOCE ZERO, ALMENO UN LOTTO OK
					if (Divisione_lotti != '0') {
						//RPRODOTTI_AMPIEZZA_GAMMAGrid_0_Voce
						//if ( getObj('RPRODOTTI_AMPIEZZA_GAMMAGrid' + t + '_Voce').value == '0' )
						//{
						/*
						var aa='';
						try{
							aa=getObj('RPRODOTTI_AMPIEZZA_GAMMAGrid_' + t + '_EsitoRiga').value;
							
						}
						catch(e) {  };
						*/

						if (getObj('RPRODOTTI_AMPIEZZA_GAMMAGrid_' + t + '_EsitoRiga').value.indexOf('State_ERR.gif') > 0) {
							errore_prod = 1;
							break;
						}
						else {
							if (getObj('RPRODOTTI_AMPIEZZA_GAMMAGrid_' + t + '_EsitoRiga').value.indexOf('State_Warning.gif') > 0) {
								warning_prod = 1;
								break;
							}
						}
						//}
					}
					else //CONTROLLO PER LE GARE NON A LOTTI, TUTTE LE RIGHE OK
					{
						if (getObj('RPRODOTTI_AMPIEZZA_GAMMAGrid_' + t + '_EsitoRiga').value.indexOf('State_ERR.gif') > 0) {
							errore_prod = 1;
							break;
						}
						else {
							if (getObj('RPRODOTTI_AMPIEZZA_GAMMAGrid_' + t + '_EsitoRiga').value.indexOf('State_Warning.gif') > 0) {
								warning_prod = 1;
								break;
							}
						}
					}
				}
			}


			//TUTTI I LOTTI CON ERRORI
			var value = document.getElementsByName("folder_button_PRODOTTI_AMPIEZZA_GAMMA")[0].innerHTML;

			if (warning_prod == 0 && errore_prod == 1) {
				try {
					$("button[name='folder_button_PRODOTTI_AMPIEZZA_GAMMA']").html('<img src="../images/Domain/State_ERR.png"> ' + value);
				} catch (e) { }

			}
			else {

				//ALMENO UN LOTTO VALIDO OPPURE ESITO COMPLESSIVO VALORIZZATO			
				if (warning_prod == 1) {
					try {
						$("button[name='folder_button_PRODOTTI_AMPIEZZA_GAMMA']").html('<img src="../images/Domain/State_Warning.png"> ' + value);
					} catch (e) { }
				}
				else {
					//CORREZIONE: prima il warning sui prodotti non usciva mai perch� se c'� solo il warning, finiremmo comunque l'if dell'OK che sovrascrive la precedente icona di warning.
					// Per mettere l'ok il ragionamento era che se non c'erano errori allora mettevamo ok ( facendo quindi perdere il warning ). abbiamo messo quindi quest'if sotto ELSE rispetto al warning

					//NEMMENO UN LOTTO IN ERRORE
					if (errore_prod == 0 && getObjValue('RTESTATA_PRODOTTI_AMPIEZZA_GAMMA_MODEL_EsitoRiga').indexOf('State_ERR.gif') < 0) {
						try {
							$("button[name='folder_button_PRODOTTI_AMPIEZZA_GAMMA']").html('<img src="../images/Domain/State_OK.png"> ' + value);
						} catch (e) { }

					}
				}

			}

		}

	} catch (e) { }

}








function OnChange_ScegliLotti() {
	ExecDocProcess('SCEGLI_LOTTI,OFFERTA,,NO_MSG');
}



function LOAD_DominiCriteri() {

	var i;
	var r;
	var nA
	var type
	//RECUPERO OGGETTO JSON
	try { var LstAttrib_DOMINI_CRITERI = JSON.parse(getObjValue('LstAttrib_DOMINI_CRITERI')); } catch (e) { }

	//RECUPERO NUMERO ATTRIBUTI
	try { nA = LstAttrib_DOMINI_CRITERI.ATTRIBUTI.length; } catch (e) { nA = 0; }

	//CONTROLLA SE CI SONO DOMINI NEI CRITERI TECNICI
	if (nA > 0) {
		//CICLA SU TUTTE LE RIGHE DI PRODOTTI	  
		for (i = 0; i < PRODOTTIGrid_EndRow + 1; i++) {

			try { numeroLotto = getObjValue('R' + i + '_NumeroLotto'); } catch (e) { numeroLotto = ''; }
			bFound = false;

			//VERIFICA SE PER QUEL LOTTO ESISTE IL CRITERIO SPECIALIZZATO
			for (r = 0; r < nA && numeroLotto != ''; r++) {
				if (LstAttrib_DOMINI_CRITERI.ATTRIBUTI[r].Contesto == numeroLotto) {
					bFound = true;
				}
			}

			//CICLA NUOVAMENTE SUI CRITERI PER COSTRUIRE IL DOMINIO
			for (r = 0; r < nA; r++) {

				Contesto = LstAttrib_DOMINI_CRITERI.ATTRIBUTI[r].Contesto;


				//caso di  criterio non specializzato per numeroLotto
				if (bFound == false && Contesto == 'B') {
					Attributo = LstAttrib_DOMINI_CRITERI.ATTRIBUTI[r].Attributo;
					try { type = getObj('R' + i + '_' + Attributo).type; } catch (e) { type = ''; }
					//VERIFICO SE ATTRIBUTO ESISTE e NON SIA READONLY
					//if ( getObj( 'R' + i + '_' + Attributo )  && ( getObj( 'R' + i + '_' + Attributo ).type == 'select-one'  || getObj( 'R' + i + '_' + Attributo ).type == 'text' ) )
					if (getObj('R' + i + '_' + Attributo) && (type == 'select-one' || type == 'text')) {
						Valori = LstAttrib_DOMINI_CRITERI.ATTRIBUTI[r].Valori;
						CRITERIO_Domain(getObj('R' + i + '_' + Attributo), Valori);
					}

				}

				if (bFound == true && Contesto == numeroLotto) {
					Attributo = LstAttrib_DOMINI_CRITERI.ATTRIBUTI[r].Attributo;
					try { type = getObj('R' + i + '_' + Attributo).type; } catch (e) { type = ''; }
					//VERIFICO SE ATTRIBUTO ESISTE e NON SIA READONLY
					if (getObj('R' + i + '_' + Attributo) && (type == 'select-one' || type == 'text')) {
						Valori = LstAttrib_DOMINI_CRITERI.ATTRIBUTI[r].Valori;
						CRITERIO_Domain(getObj('R' + i + '_' + Attributo), Valori);
					}
				}
			}

		}
	}
}


function GetDatiAIC() {
	ExecDocProcess('SAVE_DOC,AIC,,NO_MSG');
}


function ElabAIC() {
	// IdOfferta
	var IDDOC = getObjValue('IDDOC');



	if (isSingleWin()) {
		var url;

		url = encodeURIComponent('CustomDoc/AIC_LOAD.asp?IDDOC=' + IDDOC + '&TYPEDOC=OFFERTA&lo=base');
		NewWin = ExecFunctionSelf(pathRoot + 'ctl_library/path.asp?url=' + url + '&KEY=document', '', '');

	}
	else {
		ExecFunctionCenter('../../CustomDoc/AIC_LOAD.asp?IDDOC=' + IDDOC + '&TYPEDOC=OFFERTA');
	}



	//alert(IDDOC);
}


function attachFilePending() {
	var AttivaFilePending = getObj('AttivaFilePending');

	/* SE IL CAMPO ESISTE */
	if (AttivaFilePending) {
		var DOCUMENT_READONLY = getObjValue('DOCUMENT_READONLY');

		//Se richiesta la verifica pending dei file ed il documento � editabile
		if (AttivaFilePending.value == 'si' && DOCUMENT_READONLY == '0') {

			/* ITERIAMO SU TUTTI I CAMPI DI TIPO INPUT CONTENENTE IN LIKE LA PAROLA UPLOADATTACH NEL LORO ATTRIBUTO ONCLICK, VERIFICA DI TIPO CASE INSENSITIVE ( a prescindere da dove si trovano, documentazione, prodotti, giri di firma ) */

			$("input[onclick*='uploadattach' i]").each(function (index, element) {
				var attachOnClick = $(this).attr('onclick');

				//Se non � gi� presente la format a J ( jump )
				if (attachOnClick.indexOf('&FORMAT=J') == -1) {
					attachOnClick = attachOnClick.replace(new RegExp('&FORMAT=', 'g'), '&FORMAT=J');
					$(this).attr('onclick', attachOnClick); // Sostituiamo l'onlick con il nuovo
				}

			});



		}
	}

}


//inizializza i messaggi per quando l'utente abbandona il documento
function Init_Msg_For_AlertAbandon() {

	var DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;

	//se il documento non in lavorazione 
	if (DOCUMENT_READONLY != '1') {

		var objClickInvio = getObj('OFFERTA_TOOLBAR_DOCUMENT_SEND').onclick;



		//se bottone di invio abilitato
		if (objClickInvio != undefined) {
			//controllo che non ci sia su ancora la classe button_link_disabled
			var strNameClass = GetProperty(getObj('OFFERTA_TOOLBAR_DOCUMENT_SEND'), 'class');

			//alert(strNameClass);
			if (strNameClass != 'button_link_disabled') {
				//var ML_text = 'La compilazione dellofferta consente linvio';
				//breadCrumbPop( ML_text );
				//forzo cambiamenti sul documento
				FLAG_CHANGE_DOCUMENT = 1;
				//sepcializzo la frase
				ML_CHANGE_DOCUMENT = 'La compilazione dellofferta consente linvio';
			}
		}
		//else
		//breadCrumbPop();
	}


	//mi salvo la funzione per settare i cambiamenti
	orig_Set_Change_Document = Set_Change_Document;
	//alert(orig_Set_Change_Document);
	Set_Change_Document = My_Set_Change_Document;

}





//faccio override della Set_Change_Document
function My_Set_Change_Document() {
	//chiamo la versione precedente
	orig_Set_Change_Document();

	//se doc ha subito modifiche 
	if (FLAG_CHANGE_DOCUMENT == 1) {
		var objClickInvio = getObj('OFFERTA_TOOLBAR_DOCUMENT_SEND').onclick;

		//ed ildocumento � pronto per invio cambio key ml
		if (objClickInvio != undefined)
			ML_CHANGE_DOCUMENT = 'Ci sono modifiche non salvate e offerta pronta per invio';
	}

}




function ControlloFirmaBuste() {
	var ControlloFirmaBuste = getObj('ControlloFirmaBuste');

	/* SE IL CAMPO ESISTE */
	if (ControlloFirmaBuste) {
		var DOCUMENT_READONLY = getObjValue('DOCUMENT_READONLY');
		//Se � richiesta la mancata verifica dei controlli di firma ( eccezione del hash di tra il file generato e quello allegato )
		if (ControlloFirmaBuste.value == 'no' && DOCUMENT_READONLY == '0') {

			/* ITERIAMO SU TUTTI I CAMPI MA SOLO PER IL CAMPO DOVE VIENE INSERITO LA BUSTA FIRMATA SETTIAMO LA FORMAT S per evitare il controllo se il file � firmato*/

			$("input[onclick*='uploadattach' i]").each(function (index, element) {
				if (($(this).attr("id")) == 'F1_attachpdf' || ($(this).attr("id")) == 'F3_attachpdf') {
					var attachOnClick = $(this).attr('onclick');

					//Se non � gi� presente la format a J ( jump )
					if (attachOnClick.indexOf('&FORMAT=S') == -1) {
						attachOnClick = attachOnClick.replace(new RegExp('&FORMAT=', 'g'), '&FORMAT=S');
						$(this).attr('onclick', attachOnClick); // Sostituiamo l'onlick con il nuovo
					}
				}

			});



		}
	}

}

function label_controllo_firma_buste() {
	var ControlloFirmaBuste = getObj('ControlloFirmaBuste');
	/* SE IL CAMPO ESISTE */
	if (ControlloFirmaBuste) {
		//Se � richiesta la mancata verifica dei controlli di firma ( eccezione del hash di tra il file generato e quello allegato )
		if (ControlloFirmaBuste.value == 'no') {
			var Divisione_lotti = getObjValue('Divisione_lotti');
			//PER LE OFFERTE A LOTTI CONTROLLO LA VOCE ZERO, ALMENO UN LOTTO OK
			if (Divisione_lotti != '0') {
				a = 1;
			}
			else {
				//SE ABBIAMO RICHIESTO DI EVITARE I CONTROLLI DI FIRMA BUSTA E NON E' FIRMATO ABGGIUNGO  la scritta "Il file allegato non � firmato" 
				try {


					if ($("#F3_SIGN_ATTACH_V tr:first-child").html().indexOf('sign_not_ok.png') > 0) //TEC
					{
						$("#FIRMA_TEC_il_file_allegato_non_firmato").removeAttr("style");
					}
				} catch (e) { }

				try {
					if ($("#F1_SIGN_ATTACH_V tr:first-child").html().indexOf('sign_not_ok.png') > 0) //ECO

					{
						$("#FIRMA_ECO_il_file_allegato_non_firmato").removeAttr("style");
					}
				} catch (e) { }

				//invochiamo il processo di verifica informazioni per inserire in esitoriga dei prodotti 
				//"l�icona di warning ( ) e il messaggio specializzato a seconda che il file non firmato sia relativo alla busta tecnica o economica


			}

		}

	}

}
function OnChange_Allegato_TEC_ECO_SIGN_ERASE() {
	var ControlloFirmaBuste = getObj('ControlloFirmaBuste');
	/* SE IL CAMPO ESISTE */
	if (ControlloFirmaBuste) {
		//Se � richiesta la mancata verifica dei controlli di firma ( eccezione del hash di tra il file generato e quello allegato )
		if (ControlloFirmaBuste.value == 'no') {
			//chiamo un processo cappello che svuota esito_riga e poi chiama LOAD_PRODOTTI_SUB,ISTANZA_SDA_FARMACI
			ExecDocProcess('CONTROLLOFIRMABUSTE,OFFERTA');
		}
	}

}

function OnChange_Allegato_Ampiezza() {
	return;
}

function OnChange_Allegato_TEC_ECO() {
	ExecDocProcess('CONTROLLOFIRMABUSTE,OFFERTA,,NO_MSG');

}

function presenzaAmpiezzaGamma() {
	var PresenzaModuloAmpiezzaGamma = getObj('PresenzaModuloAmpiezzaGamma').value;
	/*
	try
	{ 
		PresenzaModuloAmpiezzaGamma = getObj('PresenzaModuloAmpiezzaGamma').value;
	}
	catch{	};
	*/

	if (PresenzaModuloAmpiezzaGamma == 'si') {
		//TAB PRODOTTI
		try {
			//visualizza nella tabella prodotti la colonna ampiezza di gamma se il campo nascosto in testata "PresenzaAmpiezzaDiGamma" = si
			var presenzaampiezzaGamma = getObj('PresenzaAmpiezzaDiGamma').value;
			if (presenzaampiezzaGamma == 'si') {
				ShowCol('PRODOTTI', 'FNZ_OPEN', '');
			} else {
				ShowCol('PRODOTTI', 'FNZ_OPEN', 'none');
			}

			nascondiDettaglioAmpiezzaGamma()

		} catch {
			ShowCol('PRODOTTI', 'FNZ_OPEN', 'none');
		}

	}
	else {
		ShowCol('PRODOTTI', 'FNZ_OPEN', 'none');
	}

	//TAB bUSTA TEC
	try {
		if (PresenzaModuloAmpiezzaGamma == 'si') {
			var numrow = GetProperty(getObj('BUSTA_TECNICAGrid'), 'numrow');
			var presenzaampiezzaGamma = 0;
			for (i = 0; i <= numrow; i++) {
				var ampiezzaGamma = getObj('RBUSTA_TECNICAGrid_' + i + '_AmpiezzaGamma').value;

				if (ampiezzaGamma == '1') {
					presenzaampiezzaGamma = 1
				}
				else {
					try {
						var bottone = getObj('RBUSTA_TECNICAGrid_' + i + '_FNZ_OPEN');
						bottone.remove();
					}
					catch (e) { }

				}


			}

			if (presenzaampiezzaGamma == 1) {
				ShowCol('BUSTA_TECNICA', 'FNZ_OPEN', '');

			} else {
				ShowCol('BUSTA_TECNICA', 'FNZ_OPEN', 'none');
			}
		}
		else {
			ShowCol('BUSTA_TECNICA', 'FNZ_OPEN', 'none');
		}

	}
	catch
	{

	}
	//TAB bUSTA ECO
	try {
		if (PresenzaModuloAmpiezzaGamma == 'si') {
			var numrow = GetProperty(getObj('BUSTA_ECONOMICAGrid'), 'numrow');
			var presenzaampiezzaGamma = 0;

			for (i = 0; i <= numrow; i++) {
				var ampiezzaGamma = getObj('RBUSTA_ECONOMICAGrid_' + i + '_AmpiezzaGamma').value;

				if (ampiezzaGamma == '1') {
					presenzaampiezzaGamma = 1
				}
				else {
					try {
						var bottone = getObj('RBUSTA_ECONOMICAGrid_' + i + '_FNZ_OPEN');
						bottone.remove();
					}
					catch (e) { }

				}
			}

			if (presenzaampiezzaGamma == 1) {
				ShowCol('BUSTA_ECONOMICA', 'FNZ_OPEN', '');

			} else {
				ShowCol('BUSTA_ECONOMICA', 'FNZ_OPEN', 'none');
			}
		}
		else {
			ShowCol('BUSTA_ECONOMICA', 'FNZ_OPEN', 'none');
		}

	}
	catch
	{

	}

	if (PresenzaModuloAmpiezzaGamma == 'si') {
		try {

			if (getObjValue('Divisione_lotti') != '0') {
				document.getElementById('FIRMA_AMPIEZZA_GAMMA').style.display = "none";
				return;
			}
			//alert('F1');
			//FieldToSign('F1');
		} catch (e) { };
	}
}

function NascondiDettaglioBustaTecEco(tipoBusta) {
	if (tipoBusta == "TEC") {

	}

	if (tipoBusta == "ECO") {

	}
}



function GetDatiDM() {
	ExecDocProcess('SAVE_DOC_DM_OFF,DM,,NO_MSG');
}




function Elab_DM() {
	// IdOfferta
	var IDDOC = getObjValue('IDDOC');

	//alert(IDDOC);

	if (isSingleWin()) {
		var url;

		url = encodeURIComponent('CustomDoc/DM_LOAD.asp?IDDOC=' + IDDOC + '&TYPEDOC=OFFERTA&lo=base');
		NewWin = ExecFunctionSelf(pathRoot + 'ctl_library/path.asp?url=' + url + '&KEY=document', '', '');

	}
	else {
		ExecFunctionCenter('../../CustomDoc/DM_LOAD.asp?IDDOC=' + IDDOC + '&TYPEDOC=OFFERTA');
	}

}


// Tab Offerta Ampiezza di gamma

function DownLoadCSVAmpiezza() {

	var Tipomod = getObjValue('Tipo_Modello_AmpiezzaGamma');
	var iddoc = getObj('IDDOC').value;


	if (Tipomod == '') {
		DMessageBox('../', 'Errore', 'Attenzione', 1, 400, 300);
		return;
	}

	ExecFunction('../../Report/CSV_LOTTI.asp?IDDOC=' + iddoc + '&TIPODOC=OFFERTA_AMPIEZZA&HIDECOL=TipoDoc,ESITORIGA&OPERATION=&MODEL=' + Tipomod, '_blank', '');

}

function OnClickProdottiAmpiezza(obj) {
	var Tipomod = getObjValue('Tipo_Modello_AmpiezzaGamma');

	if (Tipomod == '') {
		//alert( CNV( '../','E\' necessario selezionare prima il modello'));
		DMessageBox('../', 'Errore', 'Attenzione', 1, 400, 300);
		return;
	}

	var DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;
	if (DOCUMENT_READONLY == "1")
		DMessageBox('../', 'Documento in sola lettura', 'Attenzione', 1, 400, 300);
	else
		ImportExcel('CAPTION_ROW=yes&TITLE=Upload Excel&TABLE=CTL_Import&FIELD=RTESTATA_PRODOTTI_MODEL_Allegato&SHEET=0&PARAM=posizionale&PROCESS=LOAD_PRODOTTI,OFFERTA_AMPIEZZA&OWNER_FIELD=Idpfu&OPERATION=INSERT#new#600,450');
}

function GeneraPDFAmpiezza() {
	/*
	var Check_DM_Enabled = getObj('Check_DM_Enabled').value;
	var Check_DM_Elaborato = getObj('Check_DM_Elaborato').value;
	var PresenzaDM = getObj('PresenzaDM').value;
	var Check_AIC_Enabled = getObj('Check_AIC_Enabled').value;
	var Check_AIC_Elaborato = getObj('Check_AIC_Elaborato').value;
	var PresenzaAIC = getObj('PresenzaAIC').value;

	if ((Check_DM_Enabled == "1" && PresenzaDM == "1") && Check_DM_Elaborato == "0")
	{
		DMessageBox( '../' , 'Attenzione, non è statta eseguita la funzione di completa informazioni.' , 'Attenzione' , 1 , 400 , 300 );
	}

	if ((Check_AIC_Enabled == "1" && PresenzaAIC == "1") && Check_AIC_Elaborato == "0")
	{
		DMessageBox( '../' , 'Attenzione, non è statta eseguita la funzione di completa informazioni.' , 'Attenzione' , 1 , 400 , 300 );
	}
	*/

	//ExecDocProcess( 'CONTROLLO_PRODOTTI,OFFERTA_AMPIEZZA_DI_GAMMA');
	var value = '';
	//var JumpCheck = getObjValue('JumpCheck');
	//if ( param == 'CONTROLLO_PRODOTTI' )
	//{
	value = controlloEsitoRiga('');

	if (value == -1) {
		DMessageBox('../', 'Attenzione, ci sono errori da correggere sui prodotti', 'Attenzione', 1, 400, 300);
		return;
	}
	else {
		PrintPdfSign('URL=/Report/OFFERTA_AMPIEZZA.asp?SIGN=YES&PDF_NAME=AmpiezzadiGamma');
		return;
	}
	//}
}

function controlloEsitoRiga() {
	var numeroRighe = GetProperty(getObj('PRODOTTI_AMPIEZZA_GAMMAGrid'), 'numrow');
	var esito = '';
	var esito2 = '';
	var j = 0;

	if (numeroRighe == '-1') {
		DMessageBox('../', 'Attenzione, inserire almeno un prodotto', 'Attenzione', 1, 400, 300);
		return -1;
	}
	else {
		for (i = 0; i <= numeroRighe; i++) {
			try {

				esito = getObj('RPRODOTTI_AMPIEZZA_GAMMAGrid_' + i + '_EsitoRiga').value;

				if (esito.indexOf('State_ERR.gif') > 0) {
					esito2 = '';
					esito = esito.replace('<br><img', '');
					esito = esito.replace('</br><img', '');

					j = esito.indexOf('<br>');
					if (j > 0)
						esito2 = esito.substring(j, esito.length);
					else {
						j = esito.indexOf('</br>');
						if (j > 0)
							esito2 = esito.substring(j, esito.length);
					}

					esito2 = esito2.replace('<br>', '');
					esito2 = esito2.replace('</br>', '');
					esito2 = esito2.replace('<br>', '');
					esito2 = esito2.replace('</br>', '');

					if (esito2 != 'Il file pdf riepilogativo dell\'ampiezza di gamma generato non è firmato digitalmente')
						return -1;
				}

			} catch (e) { }
		}

	}



}


function TogliFirmaAmpiezza() {
	DMessageBox('../', 'Si sta per eliminare il file firmato.', 'Attenzione', 1, 400, 300);
	ExecDocProcess('SIGN_ERASE_LISTINO,OFFERTA_AMPIEZZA_DI_GAMMA');
}

function AddProdotto() {
	var strCommand = 'PRODOTTI_AMPIEZZA_GAMMA#ADDFROM#IDROW=' + getObjValue('IDDOC') + '&TABLEFROMADD=DOCUMENT_ADD_PRODOTTO_AMP_GAMMA';

	ExecDocCommand(strCommand);

}

function GetDatiAICAmpiezza() {
	ExecDocProcess('SAVE_DOC_AMP_GAMMA,AIC,,NO_MSG');
}

function ElabAICAmpiezza() {
	// IdOfferta
	var IDDOC = getObjValue('IDDOC');



	if (isSingleWin()) {
		var url;

		url = encodeURIComponent('CustomDoc/AIC_LOAD.asp?IDDOC=' + IDDOC + '&TYPEDOC=OFFERTA&SUBTYPEDOC=OFFERTA_AMPIEZZA&lo=base');
		NewWin = ExecFunctionSelf(pathRoot + 'ctl_library/path.asp?url=' + url + '&KEY=document', '', '');

	}
	else {
		ExecFunctionCenter('../../CustomDoc/AIC_LOAD.asp?IDDOC=' + IDDOC + '&TYPEDOC=OFFERTA&SUBTYPEDOC=OFFERTA_AMPIEZZA');
	}



	//alert(IDDOC);
}

function GetDatiDMAmpiezza() {
	ExecDocProcess('SAVE_DOC_DM_AMP_GAMMA,DM,,NO_MSG');
}

function Elab_DMAmpiezza() {
	// IdOfferta
	var IDDOC = getObjValue('IDDOC');



	if (isSingleWin()) {
		var url;

		url = encodeURIComponent('CustomDoc/DM_LOAD.asp?IDDOC=' + IDDOC + '&TYPEDOC=OFFERTA&SUBTYPEDOC=OFFERTA_AMPIEZZA&lo=base');
		NewWin = ExecFunctionSelf(pathRoot + 'ctl_library/path.asp?url=' + url + '&KEY=document', '', '');

	}
	else {
		ExecFunctionCenter('../../CustomDoc/DM_LOAD.asp?IDDOC=' + IDDOC + '&TYPEDOC=OFFERTA&SUBTYPEDOC=OFFERTA_AMPIEZZA');
	}



	//alert(IDDOC);
}

function OFFDettagliDel(x, y, z) {
	return DettagliDel(x, y, z);
}
// Fine Tab Offerta Ampiezza di gamma	




function FIRMA_AMPIEZZA_GAMMA_OnLoad() {
	DisplaySection();

	try {

		if (getObjValue('RichiestaFirma') == 'no') {
			document.getElementById('DIV_FIRMA_AMPIEZZA_GAMMA').style.display = "none";
			return;
		}
		//alert('F1');
		FieldToSign('F4');
	} catch (e) { };
}