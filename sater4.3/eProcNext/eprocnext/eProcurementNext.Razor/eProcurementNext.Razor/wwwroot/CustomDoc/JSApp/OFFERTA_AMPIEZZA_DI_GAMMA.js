//Variabile di appoggio per contenere l'idpfu dell'utente collegato e gestire l'applicazione sia se accessibile sia no
var tmp_idpfuUtenteCollegato;

function FIRMA_OnLoad() {

	var Stato = '';
	var IdpfuInCharge = 0;

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

window.onload = FIRMA_OnLoad;

function GeneraPDFAmpiezza() {
	var Check_DM_Enabled = getObj('Check_DM_Enabled').value;
	var Check_DM_Elaborato = getObj('Check_DM_Elaborato').value;
	var PresenzaDM = getObj('PresenzaDM').value;
	var Check_AIC_Enabled = getObj('Check_AIC_Enabled').value;
	var Check_AIC_Elaborato = getObj('Check_AIC_Elaborato').value;
	var PresenzaAIC = getObj('PresenzaAIC').value;

	if ((Check_DM_Enabled == "1" && PresenzaDM == "1") && Check_DM_Elaborato == "0") {
		DMessageBox('../', 'Attenzione, non � statta eseguita la funzione di completa informazioni.', 'Attenzione', 1, 400, 300);
	}

	if ((Check_AIC_Enabled == "1" && PresenzaAIC == "1") && Check_AIC_Elaborato == "0") {
		DMessageBox('../', 'Attenzione, non � statta eseguita la funzione di completa informazioni.', 'Attenzione', 1, 400, 300);
	}


	ExecDocProcess('CONTROLLO_PRODOTTI,OFFERTA_AMPIEZZA_DI_GAMMA');
}


function afterProcess(param) {

	var value = '';
	var JumpCheck = getObjValue('JumpCheck');
	if (param == 'CONTROLLO_PRODOTTI') {
		value = controlloEsitoRiga('');

		if (value == -1) {
			return;
		}
		else {
			PrintPdfSign('URL=/Report/prn_AMPIEZZA_DI_GAMMA.asp?SIGN=YES&PDF_NAME=AmpiezzadiGamma');
			return;
		}
	}


	if (param == 'SAVE_DOC') {
		ElabAIC();
	}

	if (param == 'SAVE_DOC_DM_OFF') {
		Elab_DM();
	}

}


function controlloEsitoRiga() {
	var numeroRighe = GetProperty(getObj('PRODOTTIGrid'), 'numrow');

	if (numeroRighe == '-1') {
		DMessageBox('../', 'Attenzione, inserire almeno un prodotto', 'Attenzione', 1, 400, 300);
		return -1;
	}
	else {
		for (i = 0; i <= numeroRighe; i++) {
			try {
				if (getObj('RPRODOTTIGrid_' + i + '_EsitoRiga').value.indexOf('State_ERR.gif') > 0) {
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


function DownLoadCSVAmpiezza() {

	var Tipomod = getObjValue('Tipo_Modello_AmpiezzaGamma');
	var iddoc = getObj('IDDOC').value;


	if (Tipomod == '') {
		DMessageBox('../', 'Errore', 'Attenzione', 1, 400, 300);
		return;
	}

	ExecFunction('../../Report/CSV_LOTTI.asp?IDDOC=' + iddoc + '&TIPODOC=OFFERTA_AMPIEZZA_DI_GAMMA&HIDECOL=TipoDoc,ESITORIGA&OPERATION=&MODEL=' + Tipomod, '_blank', '');

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
		ImportExcel('CAPTION_ROW=yes&TITLE=Upload Excel&TABLE=CTL_Import&FIELD=RTESTATA_PRODOTTI_MODEL_Allegato&SHEET=0&PARAM=posizionale&PROCESS=LOAD_PRODOTTI,OFFERTA_AMPIEZZA_DI_GAMMA&OWNER_FIELD=Idpfu&OPERATION=INSERT#new#600,450');
}

function RefreshContent() {

}



function GetDatiAICAmpiezza() {
	ExecDocProcess('SAVE_DOC,AIC,,NO_MSG');
}


function ElabAIC() {
	// IdOfferta
	var IDDOC = getObjValue('IDDOC');



	if (isSingleWin()) {
		var url;

		url = encodeURIComponent('CustomDoc/AIC_LOAD.asp?IDDOC=' + IDDOC + '&TYPEDOC=OFFERTA_AMPIEZZA_DI_GAMMA&lo=base');
		NewWin = ExecFunctionSelf(pathRoot + 'ctl_library/path.asp?url=' + url + '&KEY=document', '', '');

	}
	else {
		ExecFunctionCenter('../../CustomDoc/AIC_LOAD.asp?IDDOC=' + IDDOC + '&TYPEDOC=OFFERTA_AMPIEZZA_DI_GAMMA');
	}



	//alert(IDDOC);
}




function GetDatiDMAmpiezza() {
	ExecDocProcess('SAVE_DOC_DM_OFF,DM,,NO_MSG');
}




function Elab_DM() {
	// IdOfferta
	var IDDOC = getObjValue('IDDOC');



	if (isSingleWin()) {
		var url;

		url = encodeURIComponent('CustomDoc/DM_LOAD.asp?IDDOC=' + IDDOC + '&TYPEDOC=OFFERTA_AMPIEZZA_DI_GAMMA&lo=base');
		NewWin = ExecFunctionSelf(pathRoot + 'ctl_library/path.asp?url=' + url + '&KEY=document', '', '');

	}
	else {
		ExecFunctionCenter('../../CustomDoc/DM_LOAD.asp?IDDOC=' + IDDOC + '&TYPEDOC=OFFERTA_AMPIEZZA_DI_GAMMA');
	}



	//alert(IDDOC);
}



function AddProdotto() {
	var strCommand = 'PRODOTTI#ADDFROM#IDROW=' + getObjValue('IDDOC') + '&TABLEFROMADD=DOCUMENT_ADD_PRODOTTO'

	ExecDocCommand(strCommand);

}

function OFFDettagliDel(x, y, z) {
	return DettagliDel(x, y, z);
}