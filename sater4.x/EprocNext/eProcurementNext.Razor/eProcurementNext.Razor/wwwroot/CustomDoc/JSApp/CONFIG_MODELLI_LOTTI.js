window.onload = Onload_Process;

var HIDECOL_XSLX = '';

function GetXMLHttpRequest() {
	var XHR = null,
		browserUtente = navigator.userAgent.toUpperCase();

	if (typeof (XMLHttpRequest) === "function" || typeof (XMLHttpRequest) === "object")
		XHR = new XMLHttpRequest();
	else if (window.ActiveXObject && browserUtente.indexOf("MSIE 4") < 0) {
		if (browserUtente.indexOf("MSIE 5") < 0)
			XHR = new ActiveXObject("Msxml2.XMLHTTP");
		else
			XHR = new ActiveXObject("Microsoft.XMLHTTP");
	}
	return XHR;
};

ajax = GetXMLHttpRequest();

function getQSParam(ParamName) {
	// Memorizzo tutta la QueryString in una variabile
	QS = window.location.toString();
	// Posizione di inizio della variabile richiesta
	var indSta = QS.indexOf(ParamName);
	// Se la variabile passata non esiste o il parametro � vuoto, restituisco null
	if (indSta == -1 || ParamName == "") return null;
	// Posizione finale, determinata da una eventuale &amp; che serve per concatenare pi� variabili
	var indEnd = QS.indexOf('&', indSta);
	// Se non c'� una &amp;, il punto di fine � la fine della QueryString
	if (indEnd == -1) indEnd = QS.length;
	// Ottengo il solore valore del parametro, ripulito dalle sequenze di escape
	var valore = unescape(QS.substring(indSta + ParamName.length + 1, indEnd));
	// Restituisco il valore associato al parametro 'ParamName'
	return valore;
}

function Onload_Process() {
	var Command = getQSParam('COMMAND');
	var Process_Param = getQSParam('PROCESS_PARAM');
	var DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;
	// codice per la gestione dell'ampiezza di gamma

	ChangePresenzaDiGamma()


	if (Command == 'PROCESS' && (Process_Param == 'SEND:-1:CHECKOBBLIG,CONFIG_MODELLI_LOTTI' || Process_Param == 'PRE_SEND_FORMULE:-1:CHECKOBBLIG,CONFIG_MODELLI_LOTTI' || Process_Param == 'SEND,CONFIG_MODELLI_LOTTI')) {
		var nocache = new Date().getTime();
		var cod = getObj("IDDOC").value;

		/* 
		
		***	LA REFRESH DEL MULTILINGUISMO NON DEVE PIU' ESSERE FATTA DOPO L'INTRODUZIONE DELLA CTL_MULTILINGUISMO ***

		var Stored='SP_RECUPERO_KEY_MLG';
		var param='IDDOC='+cod+'&'+'STORED='+Stored;

		ajax.open("GET",   '../../ctl_library/functions/Update_Key_Multilinguismo.asp?' + param + '&nocache=' + nocache, false);
		ajax.send(null);

		if(ajax.readyState == 4) 
		{
			if(ajax.status != 200)
			{
				alert('Errore invocazione Refresh Multilinguismo.Status ' + ajax.status);
			}
		}

		*/

		ajax.open("GET", '../../ctl_library/REFRESH.ASP?COSA=MODEL&nocache=' + nocache, false);
		ajax.send(null);

		if (ajax.readyState == 4) {
			if (ajax.status != 200) {
				alert('Ripetere l\'operazione. Errore invocazione Refresh Modelli.Status ' + ajax.status);
			}
		}
		else {
			alert('Errore chiamata a Refresh Modelli. Ripetere l\'operazione');
		}

		try {
			//ricarico la sezione PRODOTTI del documento chiamante. La matrice in memoria della griglia deve essere aggiornata rispetto alle modifiche effettuate
			ExecDocCommandInMem('PRODOTTI#RELOAD', getObjValue('LinkedDoc'), getObjValue('VersioneLinkedDoc'));
			//ricarico anche il chiamante
			if (isSingleWin() == false) {
				parent.opener.RefreshDocument('');
			}

		}
		catch (e) {
		}

	}

	try {
		CALCOLI_AFTER_COMMAND();
	}
	catch (e) {
	}

	try {
		FORMULE_AFTER_COMMAND();
	}
	catch (e) {
	}
	try {
		Verifica_Formule_griglia();
	}
	catch (e) {
	}
	try {
		Verifica_Vincoli_griglia();
	}
	catch (e) {
	}

	try {
		var TipoProcedureApplicate = getObjValue('TipoProcedureApplicate')

		//Se il modello � dedicato alle procedure di tipo RDO non avremo il giro contratto_gara con relativo perfezionamento del fornitore
		if (TipoProcedureApplicate == '###RDO###') {
			ShowCol('MODELLI', 'MOD_PERFEZIONAMENTO_CONTRATTO', 'none');
			HIDECOL_XSLX = HIDECOL_XSLX + 'MOD_PERFEZIONAMENTO_CONTRATTO,';
		}
	}
	catch (e) {
	}

	getObj('Titolo').onkeyup = OnKeyUpTitolo;

	OnChangeconformita();

	ControlloDescrizione();

	//Nasconde Help_Offerte_Indicativa solo per il modelli custom di Bando_SDA
	if (getObj('VersioneLinkedDoc').value != 'BANDO_SDA' && getObj('VersioneLinkedDoc').value != '') {
		$("#cap_Help_Offerte_Indicativa").parents("table:first").css({ "display": "none" });
	}

	//Li nasconde per i modelli custom e mette a not edit Help_Bando
	if (getObj('VersioneLinkedDoc').value != '') {

		//Se esiste l'attributo di testata GiroContratto
		if (getObj('GiroContratto')) {
			if (getObjValue('GiroContratto') == '0') {
				ShowCol('MODELLI', 'MOD_PERFEZIONAMENTO_CONTRATTO', 'none');
				HIDECOL_XSLX = HIDECOL_XSLX + 'MOD_PERFEZIONAMENTO_CONTRATTO,';
			}
		}

		$("#cap_CriterioAggiudicazioneGara").parents("table:first").css({ "display": "none" });
		$("#cap_CriterioFormulazioneOfferte").parents("table:first").css({ "display": "none" });
		$("#cap_Conformita").parents("table:first").css({ "display": "none" });
		$("#cap_TipoProcedureApplicate").parents("table:first").css({ "display": "none" });

		try {
			getObj('Help_Bando_V_BTN').style.display = 'none';
		}
		catch (e) { }


	}
	if (getObj('LinkedDoc').value != '0' && getObj('LinkedDoc').value != '') {
		//nascondo la colonna presenza Obbligatoria per i modelli custom 
		ShowCol('MODELLI', 'Presenza_Obbligatoria', 'none');
		HIDECOL_XSLX = HIDECOL_XSLX + 'Presenza_Obbligatoria,';
		//funzione per rendere la riga non modificabile se presenza_obbligatoria=1 (si)
		Riga_not_edit();
	}

	//Bando semplificato nasconde le colonne dalla griglia per BANDO_SDA e Offerta Indicativa
	if (getObj('VersioneLinkedDoc').value == 'BANDO_SEMPLIFICATO' || getObj('VersioneLinkedDoc').value == 'BANDO_GARA') {
		//ShowCol( 'MODELLI' , 'MOD_Bando' , 'none' );
		//ShowCol( 'MODELLI' , 'MOD_OffertaInd' , 'none' );
		HIDECOL_XSLX = HIDECOL_XSLX + 'MOD_Bando,MOD_OffertaInd,';


		try {
			//Richiesta Di Abilitazione Al Sistema - MOD_OffertaInd
			getObj('CONFIG_MODELLI_LOTTI_MODELLI_TOOLBAR_s5').style.display = 'none';
			getObj('CONFIG_MODELLI_LOTTI_MODELLI_TOOLBAR_h5').style.display = 'none';
		}
		catch (e) { }

		try {
			//Bando SDA - 'MOD_Bando'
			getObj('CONFIG_MODELLI_LOTTI_MODELLI_TOOLBAR_s4').style.display = 'none';
			getObj('CONFIG_MODELLI_LOTTI_MODELLI_TOOLBAR_h4').style.display = 'none';
		}
		catch (e) { }

		try {
			//Conformit� lista - 'MOD_ConfLista'
			getObj('CONFIG_MODELLI_LOTTI_MODELLI_TOOLBAR_s11').style.display = 'none';
			getObj('CONFIG_MODELLI_LOTTI_MODELLI_TOOLBAR_h11').style.display = 'none';
		}
		catch (e) { }

		try {
			//Conformit� dett - 'MOD_ConfDett'
			getObj('CONFIG_MODELLI_LOTTI_MODELLI_TOOLBAR_s12').style.display = 'none';
			getObj('CONFIG_MODELLI_LOTTI_MODELLI_TOOLBAR_h12').style.display = 'none';
		}
		catch (e) { }

	}

	//se modellolegato all'ASTA lascio solo le colonne bando/bando sem...,offerta tecnica,offerta economica
	if (getObj('VersioneLinkedDoc').value == 'BANDO_ASTA') {
		ShowCol('MODELLI', 'MOD_Bando', 'none');
		ShowCol('MODELLI', 'MOD_OffertaInd', 'none');
		ShowCol('MODELLI', 'MOD_Cauzione', 'none');
		ShowCol('MODELLI', 'MOD_OffertaDrill', 'none');
		ShowCol('MODELLI', 'MOD_ConfLista', 'none');
		ShowCol('MODELLI', 'MOD_ConfDett', 'none');
		ShowCol('MODELLI', 'MOD_SCRITTURA_PRIVATA', 'none');
		ShowCol('MODELLI', 'MOD_PERFEZIONAMENTO_CONTRATTO', 'none');

		HIDECOL_XSLX = HIDECOL_XSLX + 'MOD_Bando,MOD_OffertaInd,MOD_Cauzione,MOD_OffertaDrill,MOD_ConfLista,MOD_ConfDett,MOD_SCRITTURA_PRIVATA,MOD_PERFEZIONAMENTO_CONTRATTO';
	}

	//se documento non editabile nascondo colonna Apri sezione CALCOLI
	//var docReadonly = getObjValue('DOCUMENT_READONLY');
	DOCUMENT_READONLY = '0';
	try {
		if (typeof InToPrintDocument !== 'undefined') {
			DOCUMENT_READONLY = '1';
		}
		else {
			DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;
		}
	}
	catch (e) {
	}
	if (DOCUMENT_READONLY == '0') {
		ActiveDrag();

	} else {
		ShowCol('CALCOLI', 'FNZ_OPEN', 'none');
		HideColDrag();
	}

	//Se esiste l'attributo di testata GeneraConvenzione
	if (getObj('GeneraConvenzione')) {
		if (getObjValue('GeneraConvenzione') == '1') {
			ShowCol('MODELLI', 'MOD_SCRITTURA_PRIVATA', 'none');
			ShowCol('MODELLI', 'MOD_PERFEZIONAMENTO_CONTRATTO', 'none');
			HIDECOL_XSLX = HIDECOL_XSLX + 'MOD_SCRITTURA_PRIVATA,MOD_PERFEZIONAMENTO_CONTRATTO';

			getObj('CONFIG_MODELLI_LOTTI_MODELLI_TOOLBAR_s10').style.display = 'none';
			getObj('CONFIG_MODELLI_LOTTI_MODELLI_TOOLBAR_h10').style.display = 'none';
			getObj('CONFIG_MODELLI_LOTTI_MODELLI_TOOLBAR_s13').style.display = 'none';
			getObj('CONFIG_MODELLI_LOTTI_MODELLI_TOOLBAR_h13').style.display = 'none';
		}
	}



}

function ActiveDrag() {
	ActiveGridDrag('MODELLIGrid', MoveAllRow);
	ActiveGridDrag('CALCOLIGrid', MoveAllRowCalcolo);
}

function HideColDrag() {
	ShowCol('MODELLI', 'FNZ_DRAG', 'none');
	ShowCol('CALCOLI', 'FNZ_DRAG', 'none');
}

function move(field, row, verso) {
	try {
		var f1 = getObj('RMODELLIGrid_' + row + '_' + field);
		var f2 = getObj('RMODELLIGrid_' + (row + verso) + '_' + field);
		var app;

		app = f1.value;

		f1.value = f2.value;

		f2.value = app

	}
	catch (e) {
	}

	try {
		var f1 = getObj('RMODELLIGrid_' + row + '_' + field + '_edit');
		var f2 = getObj('RMODELLIGrid_' + (row + verso) + '_' + field + '_edit');
		var app;

		app = f1.value;

		f1.value = f2.value;

		f2.value = app

	}
	catch (e) {
	}

	try {
		var f1 = getObj('RMODELLIGrid_' + row + '_' + field + '_edit_new');
		var f2 = getObj('RMODELLIGrid_' + (row + verso) + '_' + field + '_edit_new');
		var app;

		app = f1.value;

		f1.value = f2.value;

		f2.value = app

	}
	catch (e) {
	}

	try {
		var f1 = getObj('RMODELLIGrid_' + row + '_' + field + '_extraAttrib');
		var f2 = getObj('RMODELLIGrid_' + (row + verso) + '_' + field + '_extraAttrib');
		var app;

		app = f1.value;

		f1.value = f2.value;

		f2.value = app

	}
	catch (e) {
	}
}

function moveCalcoli(field, row, verso) {
	try {
		var f1 = getObj('RCALCOLIGrid_' + row + '_' + field);
		var f2 = getObj('RCALCOLIGrid_' + (row + verso) + '_' + field);
		var app;
		app = f1.value;
		f1.value = f2.value;
		f2.value = app
	} catch (e) { }

}

function MoveAllRow(r, v) {
	move('DZT_Name', r, v);
	move('Descrizione', r, v);
	move('TipoFile', r, v);
	move('LottoVoce', r, v);
	//move( 'MOD_Bando' , r  , v );
	//move( 'MOD_OffertaInd' , r  , v );
	move('MOD_BandoSempl', r, v);
	move('MOD_Cauzione', r, v);
	move('MOD_OffertaTec', r, v);
	move('MOD_Offerta', r, v);
	move('MOD_PDA', r, v);
	move('MOD_ConfDett', r, v);
	move('NonEditabili', r, v);

	move('MOD_PDADrillTestata', r, v);
	move('MOD_PDADrillLista', r, v);
	move('MOD_OffertaDrill', r, v);
	move('MOD_ConfLista', r, v);
	move('MOD_OffertaINPUT', r, v);
	move('MOD_SCRITTURA_PRIVATA', r, v);
	move('MOD_PERFEZIONAMENTO_CONTRATTO', r, v);

	move('Presenza_Obbligatoria', r, v);
	move('Numero_Decimali', r, v);
	move('NumeroDec', r, v);
	ControlloDescrizione();
	Riga_not_edit();
}

function MoveAllRowCalcolo(r, v) {
	moveCalcoli('EsitoRiga', r, v);
	moveCalcoli('Descrizione', r, v);
	moveCalcoli('DZT_Name', r, v);
	moveCalcoli('MOD_PDA', r, v);
	moveCalcoli('PDADrillTestata', r, v);
	moveCalcoli('MOD_PDADrillLista', r, v);
	moveCalcoli('NonEditabili', r, v);
	moveCalcoli('Formula', r, v);
	moveCalcoli('Aggregazione', r, v);
}

function ClickDown(grid, r, c) {

	if (grid == 'MODELLIGrid') {
		MoveAllRow(r, 1);
		// move( 'DZT_Name' , r  , 1 );
		// move( 'Descrizione' , r  , 1 );
		// move( 'TipoFile' , r  , 1 );
		// move( 'LottoVoce' , r  , 1 );
		// //move( 'MOD_Bando' , r  , 1 );
		// //move( 'MOD_OffertaInd' , r  , 1 );
		// move( 'MOD_BandoSempl' , r  , 1 );
		// move( 'MOD_Cauzione' , r  , 1 );
		// move( 'MOD_OffertaTec' , r  , 1 );
		// move( 'MOD_Offerta' , r  , 1 );
		// move( 'MOD_PDA' , r  , 1 );
		// move( 'MOD_ConfDett' , r  , 1 );
		// move( 'NonEditabili' , r  , 1 );

		// move( 'MOD_PDADrillTestata' , r  , 1 );
		// move( 'MOD_PDADrillLista' , r  , 1 );
		// move( 'MOD_OffertaDrill' , r  , 1 );
		// move( 'MOD_ConfLista' , r  , 1 );
		// move( 'MOD_OffertaINPUT' , r  , 1 );
		// move( 'MOD_SCRITTURA_PRIVATA' , r  , 1 );
		// move( 'MOD_PERFEZIONAMENTO_CONTRATTO' , r  , 1 );

		// move( 'Presenza_Obbligatoria' , r  , 1 );
		// move( 'Numero_Decimali' , r  , 1 );
		// move( 'NumeroDec' , r  , 1 );

		//ControlloDescrizione();
		//ControlloDescrizioneafterupdown(); --> non va bene fare N chiamate ajax al server ogni volta che facciamo uno spostamento di riga
		//Riga_not_edit();
	}
	else if (grid == 'CALCOLIGrid') {
		MoveAllRowCalcolo(r, 1);
		// moveCalcoli( 'EsitoRiga' , r  , 1 );
		// moveCalcoli( 'Descrizione' , r  , 1 );
		// moveCalcoli( 'DZT_Name' , r  , 1 );
		// moveCalcoli( 'MOD_PDA' , r  , 1 );
		// moveCalcoli( 'PDADrillTestata' , r  , 1 );
		// moveCalcoli( 'MOD_PDADrillLista' , r  , 1 );
		// moveCalcoli( 'NonEditabili' , r  , 1 );
		// moveCalcoli( 'Formula' , r  , 1 );
		// moveCalcoli( 'Aggregazione' , r  , 1 );
	}

}

function ClickUp(grid, r, c) {

	if (grid == 'MODELLIGrid') {
		MoveAllRow(r, -1);
		// move( 'DZT_Name' , r  , -1 );
		// move( 'Descrizione' , r  , -1 );
		// move( 'TipoFile' , r  , -1 );
		// move( 'LottoVoce' , r  , -1 );
		// //move( 'MOD_Bando' , r  , -1 );
		// //move( 'MOD_OffertaInd' , r  , -1 );
		// move( 'MOD_BandoSempl' , r  , -1 );
		// move( 'MOD_Cauzione' , r  , -1 );
		// move( 'MOD_OffertaTec' , r  , -1 );
		// move( 'MOD_Offerta' , r  , -1 );
		// move( 'MOD_PDA' , r  , -1 );
		// move( 'MOD_ConfDett' , r  , -1 );
		// move( 'NonEditabili' , r  , -1 );


		// move( 'MOD_PDADrillTestata' , r  , -1 );
		// move( 'MOD_PDADrillLista' , r  , -1 );
		// move( 'MOD_OffertaDrill' , r  , -1 );
		// move( 'MOD_ConfLista' , r  , -1 );
		// move( 'MOD_OffertaINPUT' , r  , -1 );
		// move( 'MOD_SCRITTURA_PRIVATA' , r  , -1 );
		// move( 'MOD_PERFEZIONAMENTO_CONTRATTO' , r  , -1 );

		// move( 'Presenza_Obbligatoria' , r  , -1 );
		// move( 'Numero_Decimali' , r  , -1 );
		// move( 'NumeroDec' , r  , -1 );

		// ControlloDescrizione();
		//ControlloDescrizioneafterupdown(); --> non va bene fare N chiamate ajax al server ogni volta che facciamo uno spostamento di riga
		// Riga_not_edit();

	}
	else if (grid == 'CALCOLIGrid') {
		MoveAllRowCalcolo(r, -1);
		// moveCalcoli( 'EsitoRiga' , r  , -1 );
		// moveCalcoli( 'Descrizione' , r  , -1 );
		// moveCalcoli( 'DZT_Name' , r  , -1 );
		// moveCalcoli( 'MOD_PDA' , r  , -1 );
		// moveCalcoli( 'PDADrillTestata' , r  , -1 );
		// moveCalcoli( 'MOD_PDADrillLista' , r  , -1 );
		// moveCalcoli( 'NonEditabili' , r  , -1 );
		// moveCalcoli( 'Formula' , r  , -1 );
		// moveCalcoli( 'Aggregazione' , r  , -1 );
	}
}

function OnChangeTipo(o) {
	if (getObjValue('TipoModello') == 'SDA') {
		//ShowCol( 'MODELLI' , 'MOD_OffertaInd' , '' );
		ShowCol('MODELLI', 'MOD_BandoSempl', '');

		//HIDECOL_XSLX = HIDECOL_XSLX.replace( 'MOD_OffertaInd,' , '' );
		HIDECOL_XSLX = HIDECOL_XSLX.replace('MOD_BandoSempl,', '');
	}
	else {
		// ShowCol( 'MODELLI' , 'MOD_OffertaInd' , 'none' );
		ShowCol('MODELLI', 'MOD_BandoSempl', 'none');

		HIDECOL_XSLX = HIDECOL_XSLX + 'MOD_OffertaInd,MOD_BandoSempl';
	}

}

function OnKeyUpTitolo() {

	try {
		//recupero il titolo
		var titolo = this.value;
		var test;
		var titoloripulito = '';

		//toglie gli spazi
		titolo = titolo.split(' ').join('');
		//ciclo per togliere i caratteri non validi solo numeri e lettere e _
		for (var i = 0; i < titolo.length; i++) {
			test = titolo.charAt(i);
			if (test.match("[a-zA-Z_]+")) {
				titoloripulito = titoloripulito + test;
			}
		}
		//alert(titoloripulito);
		this.value = titoloripulito;
	} catch (e) { }
}

function OnChangeconformita() {
	var value;
	value = getObj('Conformita').value;

	//se ritorna -1 non � stato selezionato Ex-Post allora vengono nascoste le colonne Conformit� Lista e Conformita Dett
	if (value.indexOf('Ex-Post') == '-1') {
		ShowCol('MODELLI', 'MOD_ConfLista', 'none');
		ShowCol('MODELLI', 'MOD_ConfDett', 'none');

		HIDECOL_XSLX = HIDECOL_XSLX.replace('MOD_ConfLista,', '');
		HIDECOL_XSLX = HIDECOL_XSLX.replace('MOD_ConfDett,', '');
	}
	else {
		ShowCol('MODELLI', 'MOD_ConfLista', '');
		ShowCol('MODELLI', 'MOD_ConfDett', '');

		HIDECOL_XSLX = HIDECOL_XSLX + 'MOD_ConfLista,MOD_ConfDett';
	}
}

function addCriterioOfferte() {
	var valore = '###';
	var numrow = GetProperty(getObj('FORMULEGrid'), 'numrow');

	for (i = 0; i <= numrow; i++) {
		valore = valore + getObj('RFORMULEGrid_' + i + '_CriterioFormulazioneOfferte').value + '###';
	}

	getObj('CriterioFormulazioneOfferte').value = valore;
}

function FORMULE_AFTER_COMMAND() {
	try {
		addCriterioOfferte();
	}
	catch (e) { }

	try {
		ControlloDescrizione();
	}
	catch (e) { }

	try {
		nascondiQTFormule();
	}
	catch (e) { }
}

function CALCOLI_AFTER_COMMAND() {
	var numrow = GetProperty(getObj('CALCOLIGrid'), 'numrow');

	for (i = 0; i <= numrow; i++) {
		getObj('RCALCOLIGrid_' + i + '_Formula').onchange = OnChangeFormula;
	}
}



function OnChangeAttributo(obj) {
	var i = obj.id.split('_');
	var row = i[1];
	var param;
	var nocache = new Date().getTime();

	try {
		hideTipoFile(row);
	}
	catch (e) {
	}

	param = 'ID=' + obj.value;

	ajax.open("GET", '../../customDoc/CONFIG_MODELLI_LOTTI.asp?' + param + '&nocache=' + nocache, false);
	ajax.send(null);

	if (ajax.readyState == 4) {
		if (ajax.status == 404 || ajax.status == 500) {
			alert('Errore invocazione pagina');
		}
		var ainfo = ajax.responseText.split('#@#');
		var editabile = ainfo[0];
		var NumeroDec = ainfo[1];

		if (editabile != 'EDITABLE') {
			getObj('RMODELLIGrid_' + row + '_NonEditabili').value = 'fissa';
			TextreadOnly('RMODELLIGrid_' + row + '_Descrizione', true);
			getObj('RMODELLIGrid_' + row + '_Descrizione').value = editabile;
			getObj('RMODELLIGrid_' + row + '_NumeroDec').value = NumeroDec;
			if (NumeroDec == 0) {
				getObj('RMODELLIGrid_' + row + '_Numero_Decimali').value = '';
			}
		}
		else {
			getObj('RMODELLIGrid_' + row + '_NonEditabili').value = '';
			TextreadOnly('RMODELLIGrid_' + row + '_Descrizione', false);
			getObj('RMODELLIGrid_' + row + '_Descrizione').value = '';
			getObj('RMODELLIGrid_' + row + '_NumeroDec').value = NumeroDec;
			if (NumeroDec == 0) {
				getObj('RMODELLIGrid_' + row + '_Numero_Decimali').value = '';
			}
		}
	}

	try {
		//Se ho selezionato un attributo di tipo Domain Ext o Gerarchico visualizzo accando alla combo attributo un icona che permette all'utente di aprire il dominio
		//E consultarne in sola lettura i valori in esso contenuti

		viewHelpDominio(obj);

	}
	catch (e) {
	}
	try {
		hideNumeroDecimali(row);
	}
	catch (e) {
	}
	try {
		Verifica_Formule_griglia();
	}
	catch (e) {
	}
	try {
		Verifica_Vincoli_griglia();
	}
	catch (e) {
	}

}


function ControlloDescrizioneafterupdown() {
	try {

		var numrow = GetProperty(getObj('MODELLIGrid'), 'numrow');

		for (k = 0; k <= numrow; k++) {

			try {
				hideTipoFile(k);
			}
			catch (e) {
			}

			var i = getObj('RMODELLIGrid_' + k + '_DZT_Name').id.split('_');
			var row = i[1];
			var param;
			var nocache = new Date().getTime();

			param = 'ID=' + getObj('RMODELLIGrid_' + k + '_DZT_Name').value;

			ajax.open("GET", '../../customDoc/CONFIG_MODELLI_LOTTI.asp?' + param + '&nocache=' + nocache, false);
			ajax.send(null);

			if (ajax.readyState == 4) {

				if (ajax.status != 200) {
					alert('Errore invocazione pagina');
				}

				var ainfo = ajax.responseText.split('#@#');
				var editabile = ainfo[0];
				var NumeroDec = ainfo[1];

				if (editabile != 'EDITABLE') {
					getObj('RMODELLIGrid_' + row + '_NonEditabili').value = 'fissa';
					TextreadOnly('RMODELLIGrid_' + row + '_Descrizione', true);
					getObj('RMODELLIGrid_' + row + '_Descrizione').value = editabile;
					getObj('RMODELLIGrid_' + row + '_NumeroDec').value = NumeroDec;
				}
				else {
					TextreadOnly('RMODELLIGrid_' + row + '_Descrizione', false);
					getObj('RMODELLIGrid_' + row + '_NumeroDec').value = NumeroDec;
				}
			}

			try { hideNumeroDecimali(k); } catch (e) { }

		}

	} catch (e) { };

	//ControlloDescrizione();

}

function ControlloDescrizione() {
	try {

		var numrow = GetProperty(getObj('MODELLIGrid'), 'numrow');
		for (i = 0; i <= numrow; i++) {

			try {
				hideTipoFile(i);
			}
			catch (e) {
			}

			try {
				hideNumeroDecimali(i);
			}
			catch (e) {
			}

			try {
				viewHelpDominio(getObj('RMODELLIGrid_' + i + '_DZT_Name'));
			}
			catch (e) {
			}

			if (getObj('RMODELLIGrid_' + i + '_NonEditabili').value == 'fissa') {
				//getObj('RMODELLIGrid_' + i + '_Descrizione').readOnly=true;					
				TextreadOnly('RMODELLIGrid_' + i + '_Descrizione', true);
			}
			else {
				TextreadOnly('RMODELLIGrid_' + i + '_Descrizione', false);
			}

		}

	} catch (e) { };


}

function MODELLI_AFTER_COMMAND() {// alert ('test R');
	ControlloDescrizione();

	try {
		Onload_Process();
	}
	catch (e) { }
}

//-- controlla che la selezione sia coerente
function OnChangeSel(obj) {
	var v = obj.id.split('_');
	var row = v[0] + '_' + v[1];
	if (getObj('VersioneLinkedDoc').value != 'BANDO_SEMPLIFICATO' && getObj('VersioneLinkedDoc').value != 'BANDO_GARA') {
		if (obj.id.indexOf('MOD_BandoSempl') >= 0) {
			if (obj.value == 'lettura' && getObjValue(row + '_MOD_Bando') != 'obblig' && getObjValue(row + '_MOD_Bando') != 'scrittura' && getObjValue(row + '_MOD_Bando') != 'calc')
				AF_Alert('La selezione di lettura prevede che sul Bando ci sia un valore tra "Scrittura","Obbligatorio","Calcolato"');

		}
	}
	if (obj.id.indexOf('MOD_Offerta') >= 0) {
		if (obj.value == 'lettura' && getObjValue(row + '_MOD_BandoSempl') != 'obblig' && getObjValue(row + '_MOD_BandoSempl') != 'scrittura' && getObjValue(row + '_MOD_BandoSempl') != 'calc')
			AF_Alert('La selezione di lettura prevede che sul Bando ci sia un valore tra "Scrittura","Obbligatorio","Calcolato"');

	}

	//RMODELLIGrid_0_MOD_Bando
	//RMODELLIGrid_0_MOD_BandoSempl
	//RMODELLIGrid_0_MOD_OffertaTec
	//RMODELLIGrid_0_MOD_Offerta



}

function OnChangeAttributoCalcolo(obj) {

}
function Verifica_Formule_griglia() {
	var numrow = GetProperty(getObj('CALCOLIGrid'), 'numrow');

	for (i = 0; i <= numrow; i++) {
		CheckFormula('CALCOLIGrid', i, 'NO');
	}
}
function Verifica_Vincoli_griglia() {
	var numrow = GetProperty(getObj('VINCOLIGrid'), 'numrow');

	for (i = 0; i <= numrow; i++) {
		CheckVincolo('VINCOLIGrid', i, 'NO');
	}
}
function OnChangeFormula() {
	var obj = this;
	var riga = obj.id.replace('RCALCOLIGrid_', '').replace('_Formula', '');
	CheckFormula('', riga, '');
}

function CheckFormula(G, R, C) {
	var docReadonly = getObjValue('DOCUMENT_READONLY');

	if (docReadonly != '1') {
		var strFormula = getObj('RCALCOLIGrid_' + R + '_Formula').value;
		var esito = verificaFormula(strFormula, 'no');

		//getObj('RCALCOLIGrid_' + R + '_EsitoRiga_V').innerHTML = esito;
		var OldEsito = getObj('RCALCOLIGrid_' + R + '_EsitoRiga').value;

		//se vengo da onload concateno il vecchio esito al nuovo
		if (C == 'NO' && esito != OldEsito)
			esito = OldEsito + esito;

		SetTextValue('RCALCOLIGrid_' + R + '_EsitoRiga', esito);
		if (esito == '' && C != 'NO') {
			alert('La formula e\' valida');
		}

	}
}


function OnChangeVincolo(obj) {
	//var obj = this;
	var riga = obj.id.replace('RVINCOLIGrid_', '').replace('_Espressione', '');
	CheckVincolo('', riga, '');
}

function CheckVincolo(G, R, C) {
	var docReadonly = getObjValue('DOCUMENT_READONLY');

	if (docReadonly != '1') {
		var strVincolo = getObj('RVINCOLIGrid_' + R + '_Espressione').value;
		var esito = verificaVincolo(strVincolo, 'no');

		var OldEsito = getObj('RVINCOLIGrid_' + R + '_EsitoRiga').value;

		//se vengo da onload concateno il vecchio esito al nuovo
		if (C == 'NO' && esito != OldEsito)
			esito = OldEsito + esito;

		SetTextValue('RVINCOLIGrid_' + R + '_EsitoRiga', esito);

		if (esito == '' && C != 'NO') {
			alert('Il Vincolo e\' valido');
		}



	}
}

function verificaVincolo(strVincolo, output) {
	var esitoVincolo = '';
	var imgEsito = '<img src="../images/Domain/State_ERR.gif"/>';
	var continueCheck = true;
	try {

		if (strVincolo != '') {
			var numrow = GetProperty(getObj('MODELLIGrid'), 'numrow');

			for (k = 0; k <= numrow; k++) {

				var campo = getObj('RMODELLIGrid_' + k + '_DZT_Name');

				var indexSel = campo.selectedIndex;
				var lista = campo.options;
				var valueCampo = campo.value;
				var testoSelezionato = lista[indexSel].text;

				if (testoSelezionato.substring(0, 8) != 'Attach -') //if (testoSelezionato.substring(0, 8) == 'Number -')
				{
					var descSelezionato = getObj('RMODELLIGrid_' + k + '_Descrizione').value;

					try {
						if (testoSelezionato.substring(0, 8) == 'Number -') {
							strVincolo = ReplaceExtended(strVincolo, '[' + descSelezionato + ']', '1');
						} else {
							strVincolo = ReplaceExtended(strVincolo, '[' + descSelezionato + ']', '\'1\'');
						}
					}
					catch (e) { }

				}

			}

			try {
				/* Se nella formula sono ancora presenti delle parentesi quadre vuol dire che sono stati utilizzati attributi non numerici */
				if (strVincolo.indexOf('[') >= 0 || strVincolo.indexOf(']') >= 0) {
					if (output != 'no') {
						alert('Il Vincolo contiene attributi non numerici', 'Attenzione');

					}
					else {
						esitoVincolo = esitoVincolo + imgEsito + 'Il Vincolo contiene attributi non numerici' + '<br/>';
					}

					continueCheck = false;

				}

			}
			catch (e) {
			}


			if (continueCheck) {
				//controllo che nella formula ci sia almeno <,=,>
				if (strVincolo.indexOf('<') == -1 && strVincolo.indexOf('>') == -1 && strVincolo.indexOf('=') == -1) {
					if (output != 'no') {
						alert('Nell\'espressione ci deve essere almeno 1 tra <,>,=', 'Attenzione');
					}
					else {
						esitoVincolo = esitoVincolo + imgEsito + 'Nell\'espressione ci deve essere almeno 1 tra <,>,=' + '<br/>';
					}

					continueCheck = false;

				}
			}


			if (continueCheck) {

				try {
					//alert(strVincolo);
					strVincolo = strVincolo.toLowerCase();
					strVincolo = ReplaceExtended(strVincolo, '==', '=');
					strVincolo = ReplaceExtended(strVincolo, '=', '==');
					strVincolo = ReplaceExtended(strVincolo, '<>', '!=');
					strVincolo = ReplaceExtended(strVincolo, 'and', '&&');
					strVincolo = ReplaceExtended(strVincolo, 'or', '||');

					var a = eval(strVincolo);

					if (output != 'no') {
						alert('Espressione corretta.', 'Attenzione');
					}

				}
				catch (e) {
					if (output != 'no') {
						alert('Espressione non corretta.', 'Attenzione');
					}
					else {
						esitoVincolo = esitoVincolo + imgEsito + 'Espressione non corretta' + '<br/>';
					}
				}

			}

		}
		else {
			if (output != 'no') {
				alert('Espressione non corretta.');
			}
			else {
				esitoVincolo = esitoVincolo + imgEsito + 'Espressione non corretta' + '<br/>';
			}
		}

	}
	catch (e) {
	}


	return esitoVincolo;


}



function ROUND(v, d) {
	return 1.0
}

function verificaFormula(strFormula, output) {
	var esitoFormula = '';
	var imgEsito = '<img src="../images/Domain/State_ERR.gif"/>';
	var continueCheck = true;

	try {

		if (strFormula != '') {
			var numrow = GetProperty(getObj('MODELLIGrid'), 'numrow');

			for (k = 0; k <= numrow; k++) {

				var campo = getObj('RMODELLIGrid_' + k + '_DZT_Name');

				var indexSel = campo.selectedIndex;
				var lista = campo.options;
				var valueCampo = campo.value;
				var testoSelezionato = lista[indexSel].text;

				if (testoSelezionato.substring(0, 8) == 'Number -') {
					var descSelezionato = getObj('RMODELLIGrid_' + k + '_Descrizione').value;

					try {
						//alert(descSelezionato);
						//strFormula = strFormula.replace('[' + descSelezionato + ']', '1');	
						strFormula = ReplaceExtended(strFormula, '[' + descSelezionato + ']', ' 1 ');
					}
					catch (e) { }

				}

			}

			try {
				/* Se nella formula sono ancora presenti delle parentesi quadre vuol dire che sono stati utilizzati attributi non numerici */
				if (strFormula.indexOf('[') >= 0 || strFormula.indexOf(']') >= 0) {
					if (output != 'no') {
						alert('La formula non e\' sintatticamente corretta');
					}
					else {
						esitoFormula = esitoFormula + imgEsito + 'La formula contiene attributi non numerici' + '<br/>';
					}

					continueCheck = false;

				}

			}
			catch (e) {
			}

			try {
				var t = document.getElementById('DZT_Name');
				var selectedText = t.options[t.selectedIndex].text;
				if (getObjValue('Formula').indexOf(selectedText) >= 0) {
					alert('In una formula non deve comparire l\'attributo utilizzato come risultato calcolato');
					esitoFormula = esitoFormula + imgEsito + 'In una formula non deve comparire l\'attributo utilizzato come risultato calcolato' + '<br/>';
					continueCheck = false;

				}
			}
			catch (e) {
			}


			if (continueCheck) {

				try {
					//alert(strFormula);
					var a = eval(strFormula);

					if (output != 'no') {
						alert('La formula e\' sintatticamente corretta');
					}

				}
				catch (e) {
					if (output != 'no') {
						alert('La formula non e\' formalmente valida');
					}
					else {
						esitoFormula = esitoFormula + imgEsito + 'La formula non e\' sintatticamente corretta' + '<br/>';
					}
				}

			}

		}
		else {
			if (output != 'no') {
				alert('La formula non \' sintatticamente corretta');
			}
			else {
				esitoFormula = esitoFormula + imgEsito + 'La formula non e\' sintatticamente corretta' + '<br/>';
			}
		}

	}
	catch (e) {
	}


	return esitoFormula;

}

function openWinModale(page, height, width) {

	var pathRadice;

	if (isSingleWin())
		pathRadice = pathRoot;
	else
		pathRadice = '../../';

	if (height == undefined) {
		height = 650;
	}

	if (width == undefined) {
		width = 800;
	}

	if (page.indexOf("VINCOLI") > 0) {
		try {
			$(function () {
				$("#finestra_modale").load(pathRadice + page).dialog({
					resizable: true,
					height: height,
					width: (typeof isFaseII !== 'undefined' && isFaseII) ? "max-content" : width,
					dialogClass: (typeof isFaseII !== 'undefined' && isFaseII) ? "wizardFormula" : "",
					modal: true,
					buttons: {
						"OK": function () {
							var rowCalcolo = getObj('riga_wizard_formula').value;

							/* Travaso i dati dalla modale al documento */
							getObj('RVINCOLIGrid_' + rowCalcolo + '_Espressione').value = getObj('Formula').value;
							getObj('RVINCOLIGrid_' + rowCalcolo + '_Descrizione').value = getObj('Descrizione').value;

							$(this).dialog("close");
						}
						, "Verifica Vincoli": function () {
							verificaVincolo(getObj('Formula').value);
						}
						, "Annulla": function () {
							$(this).dialog("close");
						}
					}
				});
			});
		}
		catch (e) {

		}

	}
	else {

		try {
			$(function () {
				$("#finestra_modale").load(pathRadice + page).dialog({
					resizable: true,
					height: height,
					width: (typeof isFaseII !== 'undefined' && isFaseII) ? "max-content" : width,
					dialogClass: (typeof isFaseII !== 'undefined' && isFaseII) ? "wizardFormula" : "",
					modal: true,
					buttons: {
						"OK": function () {
							var rowCalcolo = getObj('riga_wizard_formula').value;

							/* Travaso i dati dalla modale al documento */
							getObj('RCALCOLIGrid_' + rowCalcolo + '_Formula').value = getObj('Formula').value;
							getObj('RCALCOLIGrid_' + rowCalcolo + '_Descrizione').value = getObj('Descrizione').value;
							getObj('RCALCOLIGrid_' + rowCalcolo + '_DZT_Name').value = getObj('DZT_Name').value;

							$(this).dialog("close");
						}
						, "Verifica formula": function () {
							verificaFormula(getObj('Formula').value);
						}
						, "Annulla": function () {
							$(this).dialog("close");
						}
					}
				});
			});
		}
		catch (e) {

		}
	}
}

function openWizardFormula(G, R, C) {
	var docReadonly = getObjValue('DOCUMENT_READONLY');

	if (docReadonly != '1') {
		if (G == 'VINCOLIGrid') {
			openWinModale('ctl_library/functions/FIELD/wizardFormula.asp?CONTESTO=VINCOLI&riga=' + R);
		}
		else {
			openWinModale('ctl_library/functions/FIELD/wizardFormula.asp?riga=' + R);
		}

	}
}

function hideAllCols() {
	ShowCol('MODELLI', 'DZT_Name', 'none');
	ShowCol('MODELLI', 'TipoFile', 'none');
	//ShowCol( 'MODELLI' , 'MOD_Bando' , 'none' );
	//ShowCol( 'MODELLI' , 'MOD_OffertaInd' , 'none' );
	ShowCol('MODELLI', 'MOD_BandoSempl', 'none');
	ShowCol('MODELLI', 'MOD_Cauzione', 'none');
	ShowCol('MODELLI', 'MOD_OffertaTec', 'none');
	ShowCol('MODELLI', 'MOD_Offerta', 'none');
	ShowCol('MODELLI', 'MOD_SCRITTURA_PRIVATA', 'none');
	ShowCol('MODELLI', 'MOD_PERFEZIONAMENTO_CONTRATTO', 'none');
	ShowCol('MODELLI', 'MOD_ConfLista', 'none');
	ShowCol('MODELLI', 'MOD_ConfDett', 'none');


}

function ShowAllCols() {
	/*if ( getObj('VersioneLinkedDoc').value == 'BANDO_SEMPLIFICATO' || getObj('VersioneLinkedDoc').value == 'BANDO_GARA' )
	{
		ShowCol( 'MODELLI' , 'MOD_Bando' , '' );
		ShowCol( 'MODELLI' , 'MOD_OffertaInd' , '' );
	}*/

	ShowCol('MODELLI', 'DZT_Name', '');
	ShowCol('MODELLI', 'TipoFile', '');
	ShowCol('MODELLI', 'MOD_BandoSempl', '');
	ShowCol('MODELLI', 'MOD_Cauzione', '');
	ShowCol('MODELLI', 'MOD_OffertaTec', '');
	ShowCol('MODELLI', 'MOD_Offerta', '');
	ShowCol('MODELLI', 'MOD_SCRITTURA_PRIVATA', '');
	ShowCol('MODELLI', 'MOD_PERFEZIONAMENTO_CONTRATTO', '');
	ShowCol('MODELLI', 'MOD_ConfLista', '');
	ShowCol('MODELLI', 'MOD_ConfDett', '');

	if (getObj('VersioneLinkedDoc').value == 'BANDO_ASTA') {
		//ShowCol( 'MODELLI' , 'MOD_Bando' , 'none' );
		//ShowCol( 'MODELLI' , 'MOD_OffertaInd' , 'none' );
		ShowCol('MODELLI', 'MOD_Cauzione', 'none');
		ShowCol('MODELLI', 'MOD_OffertaDrill', 'none');
		ShowCol('MODELLI', 'MOD_ConfLista', 'none');
		ShowCol('MODELLI', 'MOD_ConfDett', 'none');
		ShowCol('MODELLI', 'MOD_SCRITTURA_PRIVATA', 'none');
		ShowCol('MODELLI', 'MOD_PERFEZIONAMENTO_CONTRATTO', 'none');
	}
	//Se esiste l'attributo di testata GeneraConvenzione
	if (getObj('GeneraConvenzione')) {
		if (getObjValue('GeneraConvenzione') == '1') {
			ShowCol('MODELLI', 'MOD_SCRITTURA_PRIVATA', 'none');
			ShowCol('MODELLI', 'MOD_PERFEZIONAMENTO_CONTRATTO', 'none');
		}
	}
}

function hideTipoFile(riga) {
	var docReadonly = getObjValue('DOCUMENT_READONLY');
	var campo;
	var txtTipoFileRiga;
	var btnTipoFileRiga;
	var indexSel;
	var lista;
	var testoSelezionato;
	var fld_RichiediFirma;

	if (docReadonly != '1') {
		campo = getObj('RMODELLIGrid_' + riga + '_DZT_Name');

		indexSel = campo.selectedIndex;
		lista = campo.options;
		testoSelezionato = lista[indexSel].text;
		fld_RichiediFirma = getObj('RMODELLIGrid_' + riga + '_RichiediFirma');
	}
	else {
		//testoSelezionato = getObj('val_RMODELLIGrid_' + riga +'_DZT_Name').innerHTML;
		testoSelezionato = getObj('val_RMODELLIGrid_' + riga + '_DZT_Name').textContent;
		fld_RichiediFirma = getObj('RMODELLIGrid_' + riga + '_RichiediFirma_V');
	}

	txtTipoFileRiga = getObj('RMODELLIGrid_' + riga + '_TipoFile_edit_new');
	btnTipoFileRiga = getObj('RMODELLIGrid_' + riga + '_TipoFile_button');

	if (testoSelezionato.substring(0, 8) != 'Attach -') {
		txtTipoFileRiga.style.display = 'none';
		btnTipoFileRiga.style.display = 'none';
		try { fld_RichiediFirma.style.display = 'none'; } catch (e) { };
		//SetDomValue('RMODELLIGrid_' + riga + '_TipoFile','','');//se non � un allegato settiamo i tipifile a vuoto
		//FilterDom(  'RMODELLIGrid_' + riga + '_TipoFile' , 'TipoFile' , '', '' , '' , '');//se non � un allegato settiamo i tipifile a vuoto


	}
	else {

		//alert getObj('TipoFile').getElementsByTagName;
		if (getObj('RMODELLIGrid_' + riga + '_TipoFile').value == '')//se l'attributo � un allegato ed � vuoto, lo valorizziamo con un attributo nascosto che contiene i valori di default
		{
			//FilterDom(  'RMODELLIGrid_' + riga + '_TipoFile' , 'TipoFile' , getObj('tipofiledefault').value, '' , 'MODELLIGrid_' + riga  , '');

			//try{SetDomValue('RMODELLIGrid_' + riga + '_TipoFile' , getObj('tipofiledefault').value , getObj('tipofiledefault').value); }catch(e){}
			//try{SetDomValue('RMODELLIGrid_' + riga + '_TipoFile_edit' , 'pdf - Documento Acrobat<br/>p7m - Documento Firmato<br/>zip - File compression<br/>rar - File compression<br/>7-Zip - File compression', ''); }catch(e){}
			//try{SetDomValue('RMODELLIGrid_' + riga + '_TipoFile_edit_new' , '5 Selezionati', ''); }catch(e){}
		}
		//alert (getObj('RMODELLIGrid_' + riga + '_TipoFile_edit').value);
		txtTipoFileRiga.style.display = '';
		btnTipoFileRiga.style.display = '';
		fld_RichiediFirma.style.display = '';
	}




}


function nascondiQTFormule() {
	var numrow = GetProperty(getObj('FORMULEGrid'), 'numrow');
	var i;
	var valore = '';

	for (i = 0; i <= numrow; i++) {
		valore = valore + getObjValue('val_RFORMULEGrid_' + i + '_Operatore2');
	}

	//Se tutte le righe hanno la quantit� vuota
	if (valore == '') {
		ShowCol('FORMULE', 'Operatore2', 'none');
	}

}

function viewHelpDominio(obj) {
	var arr = obj.id.split('_');
	var row = arr[1];

	var selezione = obj.value;
	var typeAttrib = -1;

	if (obj.options[obj.selectedIndex].text.substring(0, 12) == 'Domain Ext -' || obj.options[obj.selectedIndex].text.substring(0, 8) == 'Domain -')
		typeAttrib = 8;

	if (obj.options[obj.selectedIndex].text.substring(0, 12) == 'Gerarchico -')
		typeAttrib = 5;

	if (typeAttrib == -1) {
		removeNode('help_dom_' + row);
	}
	else {
		var nomeAttributo = obj.value.replace('RMODELLIGrid_' + row + '_DZT_Name_', '');

		var span = document.createElement("span");
		var link = document.createElement("a");
		var img = document.createElement("img");

		img.setAttribute("alt", 'img_label_alt');
		img.setAttribute("class", 'Apri dettaglio');
		img.setAttribute("src", pathRoot + 'CTL_Library/images/Domain/Lente.gif');

		var urlHelp = pathRoot + 'CTL_LIBRARY/dztToDom.asp?DZT=' + encodeURIComponent(nomeAttributo);

		span.setAttribute("id", "help_dom_" + row);
		link.setAttribute("href", '#');
		link.setAttribute("onclick", 'ExecFunctionCenter(\'' + urlHelp + '#new#800,600\');return false;');

		removeNode('help_dom_' + row);

		link.appendChild(img);
		span.appendChild(link);

		getObj('val_RMODELLIGrid_' + row + '_DZT_Name').appendChild(span);

	}

}

function removeNode(id) {
	try {
		//Se c'era l'help lo tolgo
		var objHelp = getObj(id);
		objHelp.parentNode.removeChild(objHelp);
	}
	catch (e) {
	}
}

function onChangeDescAttrib(obj) {
	try {
		//Applico una trim sulla descrizione dell'attributo
		obj.value = obj.value.trim();
		//tolgo i doppi spazi e ne lascio sempre uno
		obj.value = ReplaceExtended(obj.value, '  ', ' ');
	}
	catch (e) {
	}

	try {
		Verifica_Formule_griglia();
	}
	catch (e) {
	}
	try {
		Verifica_Vincoli_griglia();
	}
	catch (e) {
	}
}
function Riga_not_edit() {

	try {
		if (getObj('LinkedDoc').value != '0' && getObj('LinkedDoc').value != '') {

			var numrow = GetProperty(getObj('MODELLIGrid'), 'numrow');

			for (k = 0; k <= numrow; k++) {
				//se richiesta la non editable la riga allora imposto il campo non editabili
				if (getObj('RMODELLIGrid_' + k + '_Presenza_Obbligatoria').value == '1') {
					try { SelectreadOnly('RMODELLIGrid_' + k + '_DZT_Name', true); } catch (e) { }
					try { TextreadOnly('RMODELLIGrid_' + k + '_Descrizione', true); } catch (e) { }
					//try{HierarchyreadOnly( 'RMODELLIGrid_' + k + '_TipoFile' , true );}catch(e){}
					//try{SelectreadOnly( 'RMODELLIGrid_' + k + '_LottoVoce' , true );}catch(e){}
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_Bando', true); } catch (e) { }
					//try{SelectreadOnly( 'RMODELLIGrid_' + k + '_MOD_OffertaInd' , true );}catch(e){}
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_BandoSempl', true); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_Cauzione', true); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_OffertaTec', true); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_Offerta', true); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_PDA', true); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_ConfDett', true); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_PDADrillTestata', true); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_PDADrillLista', true); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_OffertaDrill', true); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_ConfLista', true); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_OffertaINPUT', true); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_SCRITTURA_PRIVATA', true); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_PERFEZIONAMENTO_CONTRATTO', true); } catch (e) { }

					//try{SelectreadOnly( 'RMODELLIGrid_' + k + '_Numero_Decimali' , true );}catch(e){}
					//rimuovo il cestino se non modificabile
					try { getObj('MODELLIGrid_r' + k + '_c1').innerHTML = ReplaceExtended(getObj('MODELLIGrid_r' + k + '_c1').innerHTML, 'DettagliDel(', 'DettagliDel_OLD('); } catch (e) { }

				}
				else {

					try { SelectreadOnly('RMODELLIGrid_' + k + '_DZT_Name', false); } catch (e) { }

					if (getObj('RMODELLIGrid_' + k + '_NonEditabili').value == 'fissa') {
						TextreadOnly('RMODELLIGrid_' + k + '_Descrizione', true);
					}
					else {
						try { TextreadOnly('RMODELLIGrid_' + k + '_Descrizione', false); } catch (e) { }
					}

					try { HierarchyreadOnly('RMODELLIGrid_' + k + '_TipoFile', false); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_LottoVoce', false); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_Bando', false); } catch (e) { }
					//try{SelectreadOnly( 'RMODELLIGrid_' + k + '_MOD_OffertaInd' , false );}catch(e){}
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_BandoSempl', false); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_Cauzione', false); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_OffertaTec', false); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_Offerta', false); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_PDA', false); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_ConfDett', false); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_PDADrillTestata', false); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_PDADrillLista', false); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_OffertaDrill', false); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_ConfLista', false); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_OffertaINPUT', false); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_SCRITTURA_PRIVATA', false); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_PERFEZIONAMENTO_CONTRATTO', false); } catch (e) { }

					try { SelectreadOnly('RMODELLIGrid_' + k + '_Numero_Decimali', false); } catch (e) { }
					try { getObj('MODELLIGrid_r' + k + '_c1').innerHTML = ReplaceExtended(getObj('MODELLIGrid_r' + k + '_c1').innerHTML, 'DettagliDel_OLD(', 'DettagliDel('); } catch (e) { }

				}

			}
		}
	} catch (e) { }
}
function HierarchyreadOnly(objname, b) {
	var onclick;
	var obj;

	objname = objname + '_button';
	try {
		if (b == true) {
			obj = getObj(objname);
			onclick = obj.getAttribute('onclick');
			if (onclick.indexOf('&readonly=1') < 0 && onclick.indexOf('&readonly=0') < 0) {
				onclick = onclick.replace('&Value=', '&Value=&readonly=1');
				try { obj.setAttribute('onclick', onclick); } catch (e) { }
			}
			if (onclick.indexOf('&readonly=1') < 0 && onclick.indexOf('&readonly=0') > 0) {
				onclick = onclick.replace('&readonly=0', '&readonly=1');
				try { obj.setAttribute('onclick', onclick); } catch (e) { }
			}

		}
		else {
			obj = getObj(objname);
			onclick = obj.getAttribute('onclick');
			if (onclick.indexOf('&readonly=1') > 0) {
				onclick = onclick.replace('&readonly=1', '&readonly=0');
				try { obj.setAttribute('onclick', onclick); } catch (e) { }
			}
		}
	} catch (e) { }
}

function DettagliDel_OLD(grid, r, c) {
	DMessageBox('../', 'Operazione non consentita', 'Attenzione', 1, 400, 300);
	return;
}


function hideNumeroDecimali(riga) {
	var num = Number(getObj('RMODELLIGrid_' + riga + '_NumeroDec').value);
	var NumeroDecimali = getObj('RMODELLIGrid_' + riga + '_Numero_Decimali');

	if (num == 0) {
		NumeroDecimali.style.display = 'none';
	}
	else {
		NumeroDecimali.style.display = '';
	}


}


function ExportModelGrid() {
	var campi = { CIG: '', Titolo: '', Body: '' };
	var dest = '../../DASHBOARD/viewerExcel_x.asp?OPERATION=EXCEL&STORED_SQL=no&Sort=&SortOrder=&Table=CONFIG_MODELLI_LOTTI_MODELLI_VIEW_EXCEL&Caption=Modello&IDENTITY=row&FilterHide= idheader = ';
	var target = '';


	campi.CIG = getObjValue('CIG');
	dest = dest + getObjValue('IDDOC');
	dest = dest + '&HIDECOL=' + HIDECOL_XSLX;
	dest = dest + '&FILTER=CIG=\'' + getObjValue('CIG') + '\'';

	generaFormCollectionAndSubmit(campi, dest, target);
}

function EXP(a) {
	return 1;
}

function POTENZA(a, b) {
	return 1;
}

function OnChangeAmbito() {
	//getObj('val_TipoModelloAmpiezzaDiGamma_extraAttrib').value = '';
	var PresenzaAmpiezzaDiGamma = getObj('PresenzaAmpiezzaDiGamma').value;
	var ambito = getObjValue('MacroAreaMerc');
	if (PresenzaAmpiezzaDiGamma == 'si' && ambito != '') {

		var filter = 'SQL_WHERE= Ambito = \'' + ambito + '\'';
		FilterDom('TipoModelloAmpiezzaDiGamma', 'TipoModelloAmpiezzaDiGamma', '', filter, '', '');
	}
}

function ChangePresenzaDiGamma() {
	var DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;
	try {

		if (DOCUMENT_READONLY == '0') {
			ChangePresenzaDiGammaEdit()
		}
		else {
			ChangePresenzaDiGammaNonEdit()
		}
	} catch {

	}
}

function ChangePresenzaDiGammaEdit() {
	var PresenzaAmpiezzaDiGamma = getObj('PresenzaAmpiezzaDiGamma').value;
	if (PresenzaAmpiezzaDiGamma == 'si') {
		getObj('cap_TipoModelloAmpiezzaDiGamma').style.display = '';
		getObj('TipoModelloAmpiezzaDiGamma').style.display = '';
		getObj('cap_FNZ_UPD').style.display = '';
		getObj('FNZ_UPD_link').style.display = '';
	}
	else {
		getObj('cap_TipoModelloAmpiezzaDiGamma').style.display = 'none';
		getObj('TipoModelloAmpiezzaDiGamma').style.display = 'none';
		getObj('cap_FNZ_UPD').style.display = 'none';
		getObj('FNZ_UPD_link').style.display = 'none';
	}
}

function ChangePresenzaDiGammaNonEdit() {
	var PresenzaAmpiezzaDiGamma = getObj('PresenzaAmpiezzaDiGamma').value;
	if (PresenzaAmpiezzaDiGamma == 'si') {
		getObj('cap_TipoModelloAmpiezzaDiGamma').style.display = '';
		getObj('Cell_TipoModelloAmpiezzaDiGamma').offsetParent.offsetParent.style.display = '';
		getObj('cap_FNZ_UPD').style.display = '';
		getObj('FNZ_UPD').style.display = '';
	}
	else {
		getObj('cap_TipoModelloAmpiezzaDiGamma').style.display = 'none';
		getObj('Cell_TipoModelloAmpiezzaDiGamma').offsetParent.offsetParent.style.display = 'none';
		getObj('cap_FNZ_UPD').style.display = 'none';
		getObj('FNZ_UPD').style.display = 'none';
	}
}

function ApriModelloAmpiezzaDiGamma() {
	var DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;
	var TipoModelloAmpiezzaDiGamma;

	if (DOCUMENT_READONLY == '0') {
		TipoModelloAmpiezzaDiGamma = getObj('TipoModelloAmpiezzaDiGamma').value;
	}
	else {
		TipoModelloAmpiezzaDiGamma = getObj('val_TipoModelloAmpiezzaDiGamma_extraAttrib').value;
	}


	if (TipoModelloAmpiezzaDiGamma == '') {
		DMessageBox('../', 'E\' necessario selezionare prima il modello', 'Attenzione', 1, 400, 300);
		return;
	}
	ShowDocument('CONFIG_MODELLI', TipoModelloAmpiezzaDiGamma.replace('value#=#', ''), 'YES');
}


function ismultiplo(a, b) {
	return 1
}

function isempty(a) {
	return 1
}

